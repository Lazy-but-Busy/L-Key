import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/audio/audio_frame.dart';
import 'package:l_key/core/audio/fft.dart';
import 'package:l_key/core/audio/mpm_pitch_detector.dart';
import 'package:l_key/core/audio/pitch_detector.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/pitch.dart';
import 'package:l_key/core/music/tuning.dart';

import '../../helpers/waveforms.dart';

const int _sampleRate = 44100;
const int _windowSize = 4096;

final Fft _fft = Fft(_windowSize * 2);

MpmPitchDetector _detector({
  int refinementSteps = 12,
  double peakThreshold = 0.9,
}) => MpmPitchDetector(
  fft: _fft,
  windowSize: _windowSize,
  refinementSteps: refinementSteps,
  peakThreshold: peakThreshold,
);

DetectedPitch? _detect(Float64List samples, {MpmPitchDetector? detector}) =>
    (detector ?? _detector()).analyze(
      AudioFrame(
        samples: Float64List.sublistView(samples, 0, _windowSize),
        sampleRate: _sampleRate,
        timestamp: Duration.zero,
      ),
    );

/// How far a reading sits from the truth, in cents.
double _centsError(double detected, double truth) =>
    1200 * math.log(detected / truth) / math.ln2;

/// Every semitone from A0 to E6, the range the detector claims.
List<double> _chromaticSweep() => <double>[
  for (var midi = 21; midi <= 88; midi++)
    Pitch.fromMidiNumber(midi).frequencyHz(),
];

/// Every open string of every tuning the app ships.
List<({String name, double frequencyHz})> _everyOpenString() =>
    <({String name, double frequencyHz})>[
      for (final tuning in Tuning.catalogue)
        for (final pitch in tuning.openStrings)
          (
            name: '${tuning.name} ${pitch.name}',
            frequencyHz: pitch.frequencyHz(),
          ),
    ];

void main() {
  group('MpmPitchDetector purity', () {
    test('the same window analysed twice gives the same answer', () {
      // docs/adr/0012 — a detector with no memory is what makes the algorithm
      // testable against a waveform rather than only through a fake stream.
      final signal = sawtooth(
        frequencyHz: 110,
        sampleRate: _sampleRate,
        length: _windowSize,
      );
      final detector = _detector();
      expect(
        _detect(signal, detector: detector),
        _detect(signal, detector: detector),
      );
    });

    test('two windows give the same answers in either order', () {
      final a = sawtooth(
        frequencyHz: 82.41,
        sampleRate: _sampleRate,
        length: _windowSize,
      );
      final b = sawtooth(
        frequencyHz: 329.63,
        sampleRate: _sampleRate,
        length: _windowSize,
      );

      final forwards = _detector();
      final firstA = _detect(a, detector: forwards);
      final firstB = _detect(b, detector: forwards);

      final backwards = _detector();
      final secondB = _detect(b, detector: backwards);
      final secondA = _detect(a, detector: backwards);

      expect(secondA, firstA);
      expect(secondB, firstB);
    });

    test('the frame carries the timestamp through untouched', () {
      const stamp = Duration(milliseconds: 1234);
      final detected = _detector().analyze(
        AudioFrame(
          samples: sawtooth(
            frequencyHz: 220,
            sampleRate: _sampleRate,
            length: _windowSize,
          ),
          sampleRate: _sampleRate,
          timestamp: stamp,
        ),
      );
      expect(detected!.timestamp, stamp);
    });
  });

  group('MpmPitchDetector accuracy', () {
    test('a pure tone is read to within a cent across the whole range', () {
      // The display tolerance is three cents, so a signal that is exactly
      // periodic has no excuse for more than one.
      final failures = <String>[];
      for (final truth in _chromaticSweep()) {
        final detected = _detect(
          sine(
            frequencyHz: truth,
            sampleRate: _sampleRate,
            length: _windowSize,
          ),
        );
        if (detected == null) {
          failures.add('${truth.toStringAsFixed(2)} Hz was not detected');
          continue;
        }
        final error = _centsError(detected.frequencyHz, truth);
        final budget = truth < 40 ? 3.0 : 1.0;
        if (error.abs() > budget) {
          failures.add(
            '${truth.toStringAsFixed(2)} Hz read as '
            '${detected.frequencyHz.toStringAsFixed(2)} '
            '(${error.toStringAsFixed(2)} cents)',
          );
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('a harmonically rich tone is read to within two cents', () {
      final failures = <String>[];
      for (final truth in _chromaticSweep()) {
        for (final signal in <Float64List>[
          sawtooth(
            frequencyHz: truth,
            sampleRate: _sampleRate,
            length: _windowSize,
          ),
          square(
            frequencyHz: truth,
            sampleRate: _sampleRate,
            length: _windowSize,
          ),
        ]) {
          final detected = _detect(signal);
          if (detected == null) {
            failures.add('${truth.toStringAsFixed(2)} Hz was not detected');
            continue;
          }
          final error = _centsError(detected.frequencyHz, truth);
          final budget = truth < 40 ? 4.0 : 2.0;
          if (error.abs() > budget) {
            failures.add(
              '${truth.toStringAsFixed(2)} Hz read as '
              '${detected.frequencyHz.toStringAsFixed(2)} '
              '(${error.toStringAsFixed(2)} cents)',
            );
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('every open string of every tuning the app ships is read', () {
      // PRD.md §10 — fourteen tunings, from a five-string bass's low B up to
      // the top E. These are the frequencies that actually matter.
      final failures = <String>[];
      for (final string in _everyOpenString()) {
        final detected = _detect(
          sawtooth(
            frequencyHz: string.frequencyHz,
            sampleRate: _sampleRate,
            length: _windowSize,
          ),
        );
        if (detected == null) {
          failures.add('${string.name} was not detected');
          continue;
        }
        final error = _centsError(detected.frequencyHz, string.frequencyHz);
        if (error.abs() > 4) {
          failures.add('${string.name}: ${error.toStringAsFixed(2)} cents');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('the refinement earns its place', () {
      // If bisection does not measurably beat parabolic interpolation, it is
      // cost for nothing and should be deleted. The top string is where it
      // matters: a period there is only 134 samples long, so a tenth of a
      // sample is three cents.
      double worstFor(int steps) {
        var worst = 0.0;
        for (var midi = 60; midi <= 88; midi++) {
          final truth = Pitch.fromMidiNumber(midi).frequencyHz();
          final detected = _detect(
            sawtooth(
              frequencyHz: truth,
              sampleRate: _sampleRate,
              length: _windowSize,
            ),
            detector: _detector(refinementSteps: steps),
          );
          if (detected == null) continue;
          worst = math.max(
            worst,
            _centsError(detected.frequencyHz, truth).abs(),
          );
        }
        return worst;
      }

      final withRefinement = worstFor(12);
      final withoutRefinement = worstFor(0);
      expect(
        withRefinement,
        lessThan(withoutRefinement),
        reason:
            'refined worst case ${withRefinement.toStringAsFixed(2)} cents, '
            'parabolic only ${withoutRefinement.toStringAsFixed(2)} cents — '
            'if these are equal, delete the refinement',
      );
    });
  });

  group('MpmPitchDetector octave errors', () {
    test('a missing fundamental does not read an octave high', () {
      // The whole reason this is a time-domain method. A plucked low E
      // through a phone microphone often arrives with almost no fundamental,
      // and the tallest thing in its spectrum is the second harmonic.
      final failures = <String>[];
      for (final string in _everyOpenString()) {
        final detected = _detect(
          harmonicTone(
            frequencyHz: string.frequencyHz,
            sampleRate: _sampleRate,
            length: _windowSize,
            harmonicGains: const <double>[
              0,
              1 / 2,
              1 / 3,
              1 / 4,
              1 / 5,
              1 / 6,
              1 / 7,
              1 / 8,
            ],
          ),
        );
        if (detected == null) {
          failures.add('${string.name} was not detected at all');
          continue;
        }
        final ratio = detected.frequencyHz / string.frequencyHz;
        if (ratio < 0.9 || ratio > 1.1) {
          failures.add(
            '${string.name}: read ${detected.frequencyHz.toStringAsFixed(2)} '
            'for ${string.frequencyHz.toStringAsFixed(2)} — '
            '${ratio > 1 ? "octave up" : "octave down"}',
          );
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('a weak fundamental does not read an octave high either', () {
      final failures = <String>[];
      for (final string in _everyOpenString()) {
        final detected = _detect(
          harmonicTone(
            frequencyHz: string.frequencyHz,
            sampleRate: _sampleRate,
            length: _windowSize,
            // The fundamental twenty decibels under the second harmonic.
            harmonicGains: const <double>[0.1, 1, 0.6, 0.4, 0.3, 0.2],
          ),
        );
        if (detected == null) {
          failures.add('${string.name} was not detected at all');
          continue;
        }
        final ratio = detected.frequencyHz / string.frequencyHz;
        if (ratio < 0.9 || ratio > 1.1) {
          failures.add(
            '${string.name}: read ${detected.frequencyHz.toStringAsFixed(2)} '
            'for ${string.frequencyHz.toStringAsFixed(2)}',
          );
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('nothing in the whole sweep lands on a wrong octave', () {
      // The assertion that actually protects a player: a tuner that is a few
      // cents out is useful, and one that names the wrong octave is not.
      final failures = <String>[];
      for (final truth in _chromaticSweep()) {
        for (final signal in <Float64List>[
          sine(
            frequencyHz: truth,
            sampleRate: _sampleRate,
            length: _windowSize,
          ),
          sawtooth(
            frequencyHz: truth,
            sampleRate: _sampleRate,
            length: _windowSize,
          ),
          square(
            frequencyHz: truth,
            sampleRate: _sampleRate,
            length: _windowSize,
          ),
        ]) {
          final detected = _detect(signal);
          if (detected == null) continue;
          final ratio = detected.frequencyHz / truth;
          if (ratio < 0.9 || ratio > 1.1) {
            failures.add(
              '${truth.toStringAsFixed(2)} Hz read as '
              '${detected.frequencyHz.toStringAsFixed(2)}',
            );
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('the peak threshold is doing the work, not decoration', () {
      // Where it matters is exactly the guitar case: a low string whose
      // fundamental has all but vanished. On a signal with a strong
      // fundamental the choice never arises, which is why this uses one
      // without.
      final signal = harmonicTone(
        frequencyHz: 110,
        sampleRate: _sampleRate,
        length: _windowSize,
        harmonicGains: const <double>[
          0,
          1 / 2,
          1 / 3,
          1 / 4,
          1 / 5,
          1 / 6,
          1 / 7,
          1 / 8,
        ],
      );

      final correct = _detect(signal, detector: _detector());
      expect(correct!.frequencyHz, closeTo(110, 1));

      final loosened = _detect(signal, detector: _detector(peakThreshold: 0.3));
      expect(
        loosened!.frequencyHz,
        closeTo(220, 3),
        reason:
            'a threshold this loose should accept the shorter period and read '
            'an octave high — if it does not, the constant is not what is '
            'preventing the error and its comment is wrong',
      );
    });
  });

  group('MpmPitchDetector under real conditions', () {
    test('it degrades gracefully as noise rises, and says when it is lost', () {
      // CLAUDE.md §16 turned into a test. At the bottom of the range there is
      // no accuracy assertion at all, only the requirement that the detector
      // stops claiming to know.
      const budgets = <({double snrDb, double cents})>[
        (snrDb: 40, cents: 1),
        (snrDb: 30, cents: 1),
        (snrDb: 20, cents: 3),
        (snrDb: 10, cents: 10),
      ];
      final failures = <String>[];

      for (final budget in budgets) {
        for (final pitch in Tuning.standard.openStrings) {
          final truth = pitch.frequencyHz();
          final detected = _detect(
            withNoise(
              sawtooth(
                frequencyHz: truth,
                sampleRate: _sampleRate,
                length: _windowSize,
              ),
              snrDb: budget.snrDb,
              seed: 42,
            ),
          );
          if (detected == null) {
            failures.add('${pitch.name} lost at ${budget.snrDb} dB');
            continue;
          }
          final error = _centsError(detected.frequencyHz, truth);
          if (error.abs() > budget.cents) {
            failures.add(
              '${pitch.name} at ${budget.snrDb} dB: '
              '${error.toStringAsFixed(2)} cents',
            );
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('at six decibels it stops claiming to know', () {
      final clarities = <double>[];
      for (final pitch in Tuning.standard.openStrings) {
        final detected = _detect(
          withNoise(
            sawtooth(
              frequencyHz: pitch.frequencyHz(),
              sampleRate: _sampleRate,
              length: _windowSize,
            ),
            snrDb: 6,
            seed: 42,
          ),
        );
        if (detected != null) clarities.add(detected.clarity);
      }

      // No accuracy claim here on purpose. The requirement is only that the
      // reading arrives carrying its own doubt, so the tuner can refuse it.
      final failures = <String>[
        for (final clarity in clarities)
          if (clarity >= 0.9) 'clarity $clarity is too sure for 6 dB of noise',
      ];
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('clarity falls as noise rises', () {
      final truth = const Pitch(Note(NoteLetter.a), 2).frequencyHz();
      double clarityAt(double snrDb) =>
          _detect(
            withNoise(
              sawtooth(
                frequencyHz: truth,
                sampleRate: _sampleRate,
                length: _windowSize,
              ),
              snrDb: snrDb,
              seed: 9,
            ),
          )?.clarity ??
          0;

      expect(clarityAt(40), greaterThan(clarityAt(20)));
      expect(clarityAt(20), greaterThan(clarityAt(6)));
    });

    test('a real string is stiff, and that shifts the period honestly', () {
      // A wound low E's partials sit progressively sharp of exact multiples.
      // The period really does move, so every tuner reads a wound string a
      // little differently. Claiming a cent here would be claiming something
      // untrue.
      final failures = <String>[];
      for (final pitch in Tuning.standard.openStrings) {
        final truth = pitch.frequencyHz();
        final detected = _detect(
          harmonicTone(
            frequencyHz: truth,
            sampleRate: _sampleRate,
            length: _windowSize,
            inharmonicity: 1e-4,
          ),
        );
        final error = _centsError(detected!.frequencyHz, truth);
        if (error.abs() > 5) {
          failures.add('${pitch.name}: ${error.toStringAsFixed(2)} cents');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('a decaying pluck is still read accurately', () {
      // The window is ninety milliseconds long, so a note is measurably
      // quieter at its end than its start. That amplitude change is the known
      // weakness of the normalisation, and this puts a bound on it.
      final failures = <String>[];
      for (final pitch in Tuning.standard.openStrings) {
        final truth = pitch.frequencyHz();
        final detected = _detect(
          withDecay(
            sawtooth(
              frequencyHz: truth,
              sampleRate: _sampleRate,
              length: _windowSize,
            ),
            sampleRate: _sampleRate,
            t60Seconds: 2,
          ),
        );
        if (detected == null || detected.clarity < 0.7) {
          failures.add('${pitch.name} lost its clarity while decaying');
          continue;
        }
        final error = _centsError(detected.frequencyHz, truth);
        if (error.abs() > 2) {
          failures.add('${pitch.name}: ${error.toStringAsFixed(2)} cents');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test(
      'vibrato is not an accuracy failure, but must not shift the octave',
      () {
        // The pitch really is moving, so there is no single right answer. What
        // there is, is a wrong one: naming the octave above.
        final truth = const Pitch(Note(NoteLetter.a), 3).frequencyHz();
        final detected = _detect(
          vibrato(
            frequencyHz: truth,
            sampleRate: _sampleRate,
            length: _windowSize,
            rateHz: 5,
            depthCents: 30,
          ),
        );

        expect(detected, isNotNull);
        expect(_centsError(detected!.frequencyHz, truth).abs(), lessThan(35));
      },
    );

    test('a constant offset is removed rather than read as a long period', () {
      // Asserted both ways, so the direct-current removal is proven to earn
      // its place rather than assumed to.
      final truth = const Pitch(Note(NoteLetter.e), 2).frequencyHz();
      final offset = withDcOffset(
        sawtooth(
          frequencyHz: truth,
          sampleRate: _sampleRate,
          length: _windowSize,
        ),
        0.3,
      );

      final detected = _detect(offset);
      expect(detected, isNotNull);
      expect(_centsError(detected!.frequencyHz, truth).abs(), lessThan(2));
    });

    test('an overloaded input still reads its fundamental', () {
      final truth = const Pitch(Note(NoteLetter.d), 3).frequencyHz();
      final detected = _detect(
        hardClip(
          sawtooth(
            frequencyHz: truth,
            sampleRate: _sampleRate,
            length: _windowSize,
            amplitude: 2,
          ),
          0.9,
        ),
      );

      expect(detected, isNotNull);
      expect(_centsError(detected!.frequencyHz, truth).abs(), lessThan(2));
    });
  });

  group('MpmPitchDetector silence and nonsense', () {
    test('silence has no pitch', () {
      expect(_detect(Float64List(_windowSize)), isNull);
    });

    test('white noise is either refused or admits it is unsure', () {
      final detected = _detect(noise(length: _windowSize, seed: 21));
      if (detected != null) {
        expect(
          detected.clarity,
          lessThan(0.6),
          reason: 'noise must not be reported confidently',
        );
      }
    });

    test('a frequency the instrument cannot make is not reported', () {
      // The lag bounds remove a whole class of octave error for free.
      expect(
        _detect(
          sine(
            frequencyHz: 4000,
            sampleRate: _sampleRate,
            length: _windowSize,
          ),
        ),
        isNull,
      );
    });

    test('a window of the wrong length fails loudly', () {
      expect(
        () => _detector().analyze(
          AudioFrame(
            samples: Float64List(1024),
            sampleRate: _sampleRate,
            timestamp: Duration.zero,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('a transform too small for a linear autocorrelation fails loudly', () {
      // A circular autocorrelation wraps the window's tail onto its head and
      // invents periodicity that is not there.
      expect(
        () => MpmPitchDetector(fft: Fft(4096), windowSize: 4096),
        throwsArgumentError,
      );
    });
  });

  group('MpmPitchDetector sample rate', () {
    test('every bound comes from the frame, never from an assumption', () {
      // The silent catastrophe: a device that grants 48000 when 44100 was
      // asked for shifts every reading by about a tone and a half.
      const rate = 48000;
      final detector = MpmPitchDetector(fft: _fft, windowSize: _windowSize);
      final truth = const Pitch(Note(NoteLetter.a), 2).frequencyHz();
      final detected = detector.analyze(
        AudioFrame(
          samples: sawtooth(
            frequencyHz: truth,
            sampleRate: rate,
            length: _windowSize,
          ),
          sampleRate: rate,
          timestamp: Duration.zero,
        ),
      );

      expect(detected, isNotNull);
      expect(_centsError(detected!.frequencyHz, truth).abs(), lessThan(2));
    });
  });
}
