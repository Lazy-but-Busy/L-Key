import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/audio/audio_pipeline.dart';
import 'package:l_key/core/audio/pitch_detector.dart';
import 'package:l_key/core/audio/spectrum_features.dart';
import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/core/permissions/microphone_permission.dart';
import 'package:l_key/features/tuner/domain/tuner_state.dart';
import 'package:l_key/features/tuner/domain/tuner_thresholds.dart';
import 'package:l_key/features/tuner/domain/tuning_engine.dart';
import 'package:l_key/features/tuner/domain/tuning_session.dart';

/// How long one analysed window is, at the shipped window and hop.
const Duration _frameStep = Duration(microseconds: 1024 * 1000000 ~/ 44100);

/// A frame built by hand, so a test states the measurements it means rather
/// than synthesising audio and hoping it produces them.
AnalysisFrame _frame({
  required Duration at,
  double? frequencyHz,
  double clarity = 0.95,
  double rmsDbfs = -20,
  double spectralFlatness = 0.02,
  List<SpectralPeak> peaks = const <SpectralPeak>[],
}) => AnalysisFrame(
  features: SpectrumFeatures(
    rmsDbfs: rmsDbfs,
    peakAmplitude: 0.5,
    clippedRatio: 0,
    spectralFlatness: spectralFlatness,
    binHz: 5.38,
    peaks: peaks,
  ),
  pitch: frequencyHz == null
      ? null
      : DetectedPitch(
          frequencyHz: frequencyHz,
          clarity: clarity,
          timestamp: at,
        ),
  timestamp: at,
);

/// A frequency a known number of cents from an open string.
double _string(
  int index, {
  double cents = 0,
  Tuning tuning = Tuning.standard,
}) =>
    tuning.openStrings[index].frequencyHz() *
    math.pow(2, cents / 1200).toDouble();

/// Feeds [count] identical frames, advancing time by one window each.
Duration _feed(
  TuningSession session,
  Duration from,
  int count, {
  double? frequencyHz,
  double clarity = 0.95,
  double rmsDbfs = -20,
  double spectralFlatness = 0.02,
  List<SpectralPeak> peaks = const <SpectralPeak>[],
}) {
  var at = from;
  for (var i = 0; i < count; i++) {
    session.onFrame(
      _frame(
        at: at,
        frequencyHz: frequencyHz,
        clarity: clarity,
        rmsDbfs: rmsDbfs,
        spectralFlatness: spectralFlatness,
        peaks: peaks,
      ),
    );
    at += _frameStep;
  }
  return at;
}

/// A session already listening.
TuningSession _listening({
  TunerThresholds thresholds = TunerThresholds.defaults,
  Tuning tuning = Tuning.standard,
}) => TuningSession(thresholds: thresholds, tuning: tuning)
  ..onPermission(MicrophoneAccess.granted)
  ..onStarted();

void main() {
  group('TuningSession permission', () {
    test('each refusal leads somewhere different', () {
      // CLAUDE.md §37 — four outcomes, four next steps. A restricted device
      // offers no settings button, because there is nothing there the player
      // can change and sending them would waste their time.
      expect(
        TuningSession().onPermission(MicrophoneAccess.granted).status,
        TunerStatus.starting,
      );

      final denied = TuningSession().onPermission(MicrophoneAccess.denied);
      expect(denied.status, TunerStatus.permissionRequired);
      expect(denied.canOpenSettings, isFalse);

      final blocked = TuningSession().onPermission(
        MicrophoneAccess.permanentlyDenied,
      );
      expect(blocked.status, TunerStatus.permissionBlocked);
      expect(blocked.canOpenSettings, isTrue);

      final restricted = TuningSession().onPermission(
        MicrophoneAccess.restricted,
      );
      expect(restricted.status, TunerStatus.permissionBlocked);
      expect(restricted.canOpenSettings, isFalse);
    });
  });

  group('TuningSession lifecycle', () {
    test('it starts idle and holds the microphone for nothing', () {
      expect(TuningSession().state.status, TunerStatus.idle);
      expect(TuningSession().state.isListening, isFalse);
    });

    test('a frame arriving while idle changes nothing', () {
      final session = TuningSession()
        ..onFrame(_frame(at: Duration.zero, frequencyHz: 110));
      expect(session.state.status, TunerStatus.idle);
    });

    test('an interruption is not an error and must not look like one', () {
      // A call or an alarm is not something the player did wrong. Showing an
      // error state for it would be blaming them for a phone call.
      final session = _listening();
      _feed(session, Duration.zero, 6, frequencyHz: _string(0));
      expect(session.state.status, TunerStatus.tracking);

      final after = session.onInterrupted();
      expect(after.status, TunerStatus.idle);
      expect(after.failure, isNull);
      expect(after.reading, isNull);
    });

    test('a genuine failure is one', () {
      final state = _listening().onError(
        const UnexpectedFailure(technicalDetail: 'stream blew up'),
      );
      expect(state.status, TunerStatus.failed);
      expect(state.failure, isNotNull);
    });

    test('stopping clears the reading', () {
      final session = _listening();
      _feed(session, Duration.zero, 6, frequencyHz: _string(0));
      expect(session.onStopped().reading, isNull);
    });
  });

  group('TuningSession silence', () {
    test('one loud window is a door closing, not a note', () {
      final session = _listening()
        ..onFrame(_frame(at: Duration.zero, frequencyHz: _string(0)));
      expect(session.state.status, TunerStatus.listening);
    });

    test('a sustained signal is a note', () {
      final session = _listening();
      _feed(session, Duration.zero, 6, frequencyHz: _string(0));
      expect(session.state.status, TunerStatus.tracking);
    });

    test('a note between the thresholds keeps tracking', () {
      // The eight decibels between the floor and the onset are what stop a
      // decaying note flickering several times a second.
      final session = _listening();
      var at = _feed(session, Duration.zero, 6, frequencyHz: _string(0));
      expect(session.state.status, TunerStatus.tracking);

      at = _feed(session, at, 10, frequencyHz: _string(0), rmsDbfs: -46);
      expect(session.state.status, TunerStatus.tracking);
    });

    test('a sustained quiet returns to listening, and not before', () {
      final session = _listening();
      var at = _feed(session, Duration.zero, 6, frequencyHz: _string(0));

      at = _feed(session, at, 5, rmsDbfs: -70);
      expect(
        session.state.status,
        TunerStatus.tracking,
        reason: 'five quiet windows is not yet silence',
      );

      _feed(session, at, 1, rmsDbfs: -70);
      expect(session.state.status, TunerStatus.listening);
      expect(session.state.reading, isNull);
    });
  });

  group('TuningSession confidence', () {
    test('a noisy room is heard as noise, not as a note', () {
      // Loudness alone cannot tell someone talking from someone playing.
      // Spectral flatness can, and this is where it is used.
      final session = _listening();
      _feed(
        session,
        Duration.zero,
        6,
        frequencyHz: _string(0),
        spectralFlatness: 0.9,
      );
      expect(session.state.status, TunerStatus.noisy);
      expect(session.state.reading, isNull);
    });

    test('a window with no period at all is noise', () {
      final session = _listening();
      _feed(session, Duration.zero, 6);
      expect(session.state.status, TunerStatus.noisy);
    });

    test('entering needs more confidence than staying', () {
      // A reading hovering at one threshold would switch the whole screen on
      // and off; two thresholds stop that.
      final session = _listening();
      _feed(session, Duration.zero, 6, frequencyHz: _string(0), clarity: 0.62);
      expect(
        session.state.status,
        TunerStatus.noisy,
        reason: '0.62 is above the leaving threshold but below entering',
      );

      final tracking = _listening();
      var at = _feed(
        tracking,
        Duration.zero,
        6,
        frequencyHz: _string(0),
      );
      expect(tracking.state.status, TunerStatus.tracking);

      at = _feed(tracking, at, 3, frequencyHz: _string(0), clarity: 0.62);
      expect(
        tracking.state.status,
        TunerStatus.tracking,
        reason: 'the same confidence holds a reading it could not start',
      );
    });

    test('a quietly plucked string is read as readily as a hard one', () {
      // Loudness says whether anything is happening, which the silence
      // thresholds already decide. It says nothing about whether what is
      // happening is a note, so there is no level gate on confidence and a
      // light touch is not punished.
      final session = _listening();
      final at = _feed(session, Duration.zero, 6, frequencyHz: _string(0));
      expect(session.state.status, TunerStatus.tracking);

      _feed(session, at, 4, frequencyHz: _string(0), rmsDbfs: -48);
      expect(session.state.status, TunerStatus.tracking);
    });

    test('a signal too quiet to start does not start one', () {
      // Between the floor and the onset nothing new begins, which is what
      // stops a distant television being read as a note.
      final session = _listening();
      _feed(session, Duration.zero, 6, frequencyHz: _string(0), rmsDbfs: -48);
      expect(session.state.status, TunerStatus.listening);
    });
  });

  group('TuningSession smoothing', () {
    test('one octave slip in five frames never reaches the screen', () {
      // The defence a player actually experiences. A median of five ignores a
      // single outlier completely; a mean would smear it across five frames
      // and visibly move the needle.
      final session = _listening();
      var at = _feed(session, Duration.zero, 4, frequencyHz: _string(0));
      at = _feed(session, at, 1, frequencyHz: _string(0) * 2);
      at = _feed(session, at, 2, frequencyHz: _string(0));

      expect(session.state.status, TunerStatus.tracking);
      expect(session.state.reading!.targetStringIndex, 0);
      expect(session.state.reading!.cents.abs(), lessThan(5));
    });
  });

  group('TuningSession imperfect input', () {
    // A2 and C#3 ringing together: two harmonic series that do not share
    // partials, which is what a second string sounding looks like.
    const twoStrings = <SpectralPeak>[
      SpectralPeak(frequencyHz: 110, magnitude: 1),
      SpectralPeak(frequencyHz: 220, magnitude: 0.5),
      SpectralPeak(frequencyHz: 138.59, magnitude: 0.9),
      SpectralPeak(frequencyHz: 277.18, magnitude: 0.45),
      SpectralPeak(frequencyHz: 415.77, magnitude: 0.3),
    ];

    test('a second ringing string is named as one, and no note is claimed', () {
      final session = _listening();
      _feed(
        session,
        Duration.zero,
        6,
        frequencyHz: 110,
        peaks: twoStrings,
      );
      expect(session.state.status, TunerStatus.imperfectInput);
      expect(
        session.state.reading,
        isNull,
        reason: 'we do not know which string they meant, so we name none',
      );
    });

    test('one stray peak is a buzz, not a second string', () {
      final session = _listening();
      _feed(
        session,
        Duration.zero,
        6,
        frequencyHz: 110,
        peaks: const <SpectralPeak>[
          SpectralPeak(frequencyHz: 110, magnitude: 1),
          SpectralPeak(frequencyHz: 220, magnitude: 0.5),
          SpectralPeak(frequencyHz: 173, magnitude: 0.95),
        ],
      );
      expect(session.state.status, TunerStatus.tracking);
    });

    test('nothing is claimed about two notes when there is not even one', () {
      // CLAUDE.md §47 — saying "more than one string" without having found a
      // period would be inventing the first one.
      final session = _listening();
      _feed(session, Duration.zero, 6, peaks: twoStrings);
      expect(session.state.status, TunerStatus.noisy);
    });
  });

  group('TuningSession settling', () {
    test('in tune is not the same as finished', () {
      // A needle sweeping through centre while a peg turns is in tune for an
      // instant, and the player is not done.
      final session = _listening();
      var at = _feed(session, Duration.zero, 6, frequencyHz: _string(0));
      expect(session.state.reading!.isInTune, isTrue);
      expect(session.state.reading!.isSettled, isFalse);

      // Six hundred milliseconds is about twenty-six windows.
      at = _feed(session, at, 26, frequencyHz: _string(0));
      expect(session.state.reading!.isSettled, isTrue);
    });

    test('settling holds through a wobble but not a real drift', () {
      final session = _listening();
      var at = _feed(session, Duration.zero, 30, frequencyHz: _string(0));
      expect(session.state.reading!.isSettled, isTrue);

      at = _feed(session, at, 6, frequencyHz: _string(0, cents: 4));
      expect(
        session.state.reading!.isSettled,
        isTrue,
        reason: 'four cents is inside the release band',
      );

      _feed(session, at, 6, frequencyHz: _string(0, cents: 12));
      expect(session.state.reading!.isSettled, isFalse);
    });

    test('the lock buzzes once, not forty-three times a second', () {
      // DESIGN.md §40 asks for a haptic on tuner lock and warns against
      // overusing them.
      final session = _listening();
      var at = _feed(session, Duration.zero, 6, frequencyHz: _string(0));

      var cues = 0;
      for (var i = 0; i < 100; i++) {
        session.onFrame(_frame(at: at, frequencyHz: _string(0)));
        if (session.takeHapticCue()) cues++;
        at += _frameStep;
      }
      expect(cues, 1);
    });

    test('a fresh string re-arms the lock', () {
      final session = _listening();
      var at = _feed(session, Duration.zero, 30, frequencyHz: _string(0));
      expect(session.takeHapticCue(), isTrue);

      // Away for well over the re-arm window, then back.
      at = _feed(session, at, 100, frequencyHz: _string(0, cents: 40));
      _feed(session, at, 30, frequencyHz: _string(0));
      expect(session.takeHapticCue(), isTrue);
    });
  });

  group('TuningSession target selection', () {
    test('the target does not flap between neighbouring strings', () {
      // Real on a seven- or eight-string neck, where the low strings sit
      // close enough that a note between two of them would otherwise switch
      // the highlight back and forth several times a second.
      final session = _listening(tuning: Tuning.eightString);
      var at = _feed(
        session,
        Duration.zero,
        6,
        frequencyHz: _string(1, tuning: Tuning.eightString),
      );
      final settledOn = session.state.reading!.targetStringIndex;

      // Two frames of a neighbour is not enough to move the target.
      at = _feed(
        session,
        at,
        2,
        frequencyHz: _string(2, tuning: Tuning.eightString),
      );
      expect(session.state.reading!.targetStringIndex, settledOn);

      // Sustained, it moves.
      _feed(
        session,
        at,
        20,
        frequencyHz: _string(2, tuning: Tuning.eightString),
      );
      expect(session.state.reading!.targetStringIndex, isNot(settledOn));
    });

    test('a chosen string overrides the automatic choice', () {
      final session = _listening();
      _feed(session, Duration.zero, 6, frequencyHz: _string(0));
      expect(session.state.reading!.targetStringIndex, 0);

      session.selectString(5);
      _feed(session, _frameStep * 6, 6, frequencyHz: _string(0));
      expect(session.state.reading!.targetStringIndex, 5);
      expect(session.state.reading!.cents, lessThan(-2000));

      session.selectAuto();
      _feed(session, _frameStep * 12, 6, frequencyHz: _string(0));
      expect(
        session.state.reading!.targetStringIndex,
        0,
        reason: 'handing the choice back must take effect at once',
      );
    });

    test('changing tuning clears what was being read', () {
      final session = _listening();
      _feed(session, Duration.zero, 6, frequencyHz: _string(0));
      expect(session.state.reading, isNotNull);

      final after = session.selectTuning(Tuning.dropD);
      expect(after.tuning, Tuning.dropD);
      expect(after.reading, isNull);
      expect(after.mode, const TargetMode.auto());
    });

    test('chromatic mode names any note and highlights no string', () {
      final session = _listening()..selectChromatic();
      _feed(session, _frameStep, 6, frequencyHz: 100);

      expect(session.state.isChromatic, isTrue);
      expect(session.state.reading!.targetNote.name, 'G2');
      expect(session.state.reading!.targetStringIndex, isNull);
    });
  });

  group('TuningSession reference pitch', () {
    test('changing it re-reads the same frequency differently', () {
      final session = _listening();
      _feed(session, Duration.zero, 6, frequencyHz: 82.407);
      expect(session.state.reading!.cents.abs(), lessThan(0.1));

      session.setReferencePitch(432);
      _feed(session, _frameStep * 6, 6, frequencyHz: 82.407);
      expect(session.state.reading!.cents, closeTo(31.77, 0.5));
    });
  });

  group('TuningSession determinism', () {
    test('the same frames produce the same states, every time', () {
      // docs/adr/0013 — no clock in the session, so a run is reproducible.
      List<TunerStatus> run() {
        final session = _listening();
        final statuses = <TunerStatus>[];
        var at = Duration.zero;
        for (var i = 0; i < 40; i++) {
          session.onFrame(
            _frame(
              at: at,
              frequencyHz: i < 20 ? _string(0) : null,
              rmsDbfs: i < 20 ? -20 : -70,
            ),
          );
          statuses.add(session.state.status);
          at += _frameStep;
        }
        return statuses;
      }

      expect(run(), run());
    });

    test('a timestamp going backwards neither throws nor settles', () {
      final session = _listening();
      _feed(session, const Duration(seconds: 5), 6, frequencyHz: _string(0));
      expect(
        () => session.onFrame(
          _frame(at: Duration.zero, frequencyHz: _string(0)),
        ),
        returnsNormally,
      );
      expect(session.state.reading!.isSettled, isFalse);
    });
  });

  group('TuningSession diagnostics', () {
    test('they are off unless asked for', () {
      final session = _listening();
      _feed(session, Duration.zero, 6, frequencyHz: _string(0));
      expect(session.state.diagnostics, isNull);
    });

    test('when asked for they carry the numbers a device test needs', () {
      final session = TuningSession(collectDiagnostics: true)
        ..describePipeline(AudioPipeline(sampleRate: 44100))
        ..onPermission(MicrophoneAccess.granted)
        ..onStarted();
      _feed(session, Duration.zero, 6, frequencyHz: _string(0));

      final diagnostics = session.state.diagnostics!;
      expect(diagnostics.rmsDbfs, -20);
      expect(diagnostics.clarity, 0.95);
      expect(diagnostics.confidence, greaterThan(0.7));
      expect(diagnostics.sampleRate, 44100);
      expect(diagnostics.windowSize, 4096);
      expect(diagnostics.framesPerSecond, closeTo(43, 1));
    });
  });
}
