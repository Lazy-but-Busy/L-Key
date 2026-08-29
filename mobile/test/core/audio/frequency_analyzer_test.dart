import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/audio/audio_frame.dart';
import 'package:l_key/core/audio/fft.dart';
import 'package:l_key/core/audio/frequency_analyzer.dart';
import 'package:l_key/core/audio/spectrum_features.dart';

import '../../helpers/waveforms.dart';

const int _sampleRate = 44100;
const int _windowSize = 4096;

final Fft _fft = Fft(_windowSize * 2);

SpectrumFeatures _analyze(Float64List samples) =>
    FrequencyAnalyzer(
      fft: _fft,
      windowSize: _windowSize,
    ).analyze(
      AudioFrame(
        samples: samples,
        sampleRate: _sampleRate,
        timestamp: Duration.zero,
      ),
    );

Float64List _sine(double frequencyHz, {double amplitude = 0.5}) => sine(
  frequencyHz: frequencyHz,
  sampleRate: _sampleRate,
  length: _windowSize,
  amplitude: amplitude,
);

void main() {
  group('FrequencyAnalyzer level', () {
    test('a full-scale sine reads three decibels below full scale', () {
      // The root mean square of a unit sine is 1/sqrt(2), which is -3.01 dB.
      // Every silence threshold is calibrated against this scale.
      expect(_analyze(_sine(440, amplitude: 1)).rmsDbfs, closeTo(-3.01, 0.05));
      expect(_analyze(_sine(440)).rmsDbfs, closeTo(-9.03, 0.05));
    });

    test('silence reads the floor rather than negative infinity', () {
      final features = _analyze(Float64List(_windowSize));
      expect(features.rmsDbfs, -120);
      expect(features.peakAmplitude, 0);
      expect(features.peaks, isEmpty);
    });

    test('an overloaded input is reported as clipped', () {
      // A clipped signal still has a period and still reads accurately; the
      // player just needs telling to back off.
      final clean = _analyze(_sine(220));
      expect(clean.clippedRatio, 0);

      final clipped = _analyze(hardClip(_sine(220, amplitude: 2), 1));
      expect(clipped.clippedRatio, greaterThan(0.4));
    });
  });

  group('FrequencyAnalyzer tonality', () {
    test('flatness separates a tone from noise, which loudness cannot', () {
      // Room noise and a plucked string can sit at the same level. This is
      // the measurement that tells them apart.
      final tone = _analyze(_sine(220)).spectralFlatness;
      final rich = _analyze(
        sawtooth(
          frequencyHz: 220,
          sampleRate: _sampleRate,
          length: _windowSize,
        ),
      ).spectralFlatness;
      final hiss = _analyze(
        noise(length: _windowSize, seed: 3),
      ).spectralFlatness;

      expect(tone, lessThan(rich));
      expect(rich, lessThan(hiss));
      expect(tone, lessThan(0.05));
      expect(hiss, greaterThan(0.3));
    });
  });

  group('FrequencyAnalyzer peaks', () {
    test('two tones are both found, placed between bins', () {
      // At a 4096-sample window one bin spans 5.4 Hz, so without parabolic
      // interpolation a peak could be nearly three Hz out and no harmonic
      // check to thirty-five cents would mean anything.
      final features = _analyze(
        mix(<Float64List>[
          _sine(220, amplitude: 0.4),
          _sine(330, amplitude: 0.4),
        ]),
      );

      final found = features.peaks.map((p) => p.frequencyHz).toList();
      expect(
        found.any((f) => (f - 220).abs() < 1),
        isTrue,
        reason: 'no peak near 220 in $found',
      );
      expect(
        found.any((f) => (f - 330).abs() < 1),
        isTrue,
        reason: 'no peak near 330 in $found',
      );
    });

    test('a string explains its own spectrum; noise explains nothing', () {
      final string = _analyze(
        sawtooth(
          frequencyHz: 110,
          sampleRate: _sampleRate,
          length: _windowSize,
        ),
      );
      expect(string.harmonicEnergyRatio(110), greaterThan(0.9));
      expect(string.harmonicEnergyRatio(165), lessThan(0.5));

      final hiss = _analyze(noise(length: _windowSize, seed: 5));
      expect(hiss.harmonicEnergyRatio(110), lessThan(0.4));
    });

    test(
      'the harmonic ratio cannot resolve an octave, and must not be asked to',
      () {
        // A low E through a phone microphone often arrives with its
        // fundamental all but gone, which is the case that matters. Here
        // every partial from the second up is present and the first is
        // missing: the true 82.41 Hz explains all of it, and the octave above
        // explains most of it, because half those partials are its harmonics
        // too.
        //
        // Finding the period is the detector's job. This asserts that the
        // spectrum cannot do it, so nobody reaches for the wrong tool.
        final features = _analyze(
          harmonicTone(
            frequencyHz: 82.41,
            sampleRate: _sampleRate,
            length: _windowSize,
            harmonicGains: <double>[
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
        expect(features.harmonicEnergyRatio(82.41), greaterThan(0.95));
        expect(features.harmonicEnergyRatio(164.81), greaterThan(0.5));
      },
    );
  });

  group('SpectrumFeatures.explainWith', () {
    // Built by hand rather than from audio, because the arithmetic is the
    // whole of the claim and it should be readable without a spectrum.
    SpectrumFeatures featuresFrom(List<SpectralPeak> peaks) => SpectrumFeatures(
      rmsDbfs: -20,
      peakAmplitude: 0.5,
      clippedRatio: 0,
      spectralFlatness: 0.02,
      binHz: 5.38,
      peaks: peaks,
    );

    test('one string leaves nothing to explain', () {
      final features = featuresFrom(const <SpectralPeak>[
        SpectralPeak(frequencyHz: 110, magnitude: 1),
        SpectralPeak(frequencyHz: 220, magnitude: 0.5),
        SpectralPeak(frequencyHz: 330, magnitude: 0.33),
        SpectralPeak(frequencyHz: 440, magnitude: 0.25),
      ]);

      final evidence = features.explainWith(110);
      expect(evidence.residualRatio, closeTo(0, 0.001));
      expect(evidence.isPolyphonic, isFalse);
    });

    test('a second series in the leftovers is what polyphony means', () {
      // A2 and C#3 ringing together: two harmonic series that do not share
      // partials, which is the ordinary case of a second string sounding.
      final features = featuresFrom(const <SpectralPeak>[
        SpectralPeak(frequencyHz: 110, magnitude: 1),
        SpectralPeak(frequencyHz: 220, magnitude: 0.5),
        SpectralPeak(frequencyHz: 138.59, magnitude: 0.9),
        SpectralPeak(frequencyHz: 277.18, magnitude: 0.45),
        SpectralPeak(frequencyHz: 415.77, magnitude: 0.3),
      ]);

      final evidence = features.explainWith(110);
      expect(evidence.residualFundamentalHz, closeTo(138.59, 0.01));
      expect(evidence.residualPartialCount, greaterThanOrEqualTo(2));
      expect(evidence.residualRatio, greaterThan(0.35));
      expect(evidence.isPolyphonic, isTrue);
    });

    test('both conditions are required, not either', () {
      // One loud stray peak is a room resonance or a buzz, not a note. The
      // conjunction is what stops the tuner crying wolf.
      final features = featuresFrom(const <SpectralPeak>[
        SpectralPeak(frequencyHz: 110, magnitude: 1),
        SpectralPeak(frequencyHz: 220, magnitude: 0.5),
        SpectralPeak(frequencyHz: 173, magnitude: 0.95),
      ]);

      final evidence = features.explainWith(110);
      expect(evidence.residualRatio, greaterThan(0.35));
      expect(evidence.residualPartialCount, lessThan(2));
      expect(evidence.isPolyphonic, isFalse);
    });

    test('an octave double-stop is invisible, and that is a known limit', () {
      // E2 with E3 produces the same set of frequencies as one E2 with a
      // strong second harmonic. No method that only looks at which
      // frequencies are present can separate them. Asserted so the limit
      // stays a documented property rather than arriving as a bug report
      // (CLAUDE.md §47).
      final features = featuresFrom(const <SpectralPeak>[
        SpectralPeak(frequencyHz: 82.41, magnitude: 1),
        SpectralPeak(frequencyHz: 164.81, magnitude: 1),
        SpectralPeak(frequencyHz: 247.22, magnitude: 0.6),
        SpectralPeak(frequencyHz: 329.63, magnitude: 0.6),
      ]);

      expect(features.explainWith(82.41).isPolyphonic, isFalse);
    });

    test('a sub-harmonic leftover is a wrong octave, not a second note', () {
      // Claiming two notes when the detector merely picked the wrong octave
      // would be inventing one.
      final features = featuresFrom(const <SpectralPeak>[
        SpectralPeak(frequencyHz: 55, magnitude: 1),
        SpectralPeak(frequencyHz: 165, magnitude: 0.8),
        SpectralPeak(frequencyHz: 275, magnitude: 0.7),
      ]);

      final evidence = features.explainWith(110);
      expect(evidence.residualPartialCount, 0);
      expect(evidence.isPolyphonic, isFalse);
    });

    test('nothing to explain is not evidence of anything', () {
      final features = featuresFrom(const <SpectralPeak>[]);
      expect(features.explainWith(110).isPolyphonic, isFalse);
      expect(features.harmonicEnergyRatio(110), 0);
    });
  });

  group('FrequencyAnalyzer contract', () {
    test('a window of the wrong length fails loudly', () {
      expect(
        () => _analyze(Float64List(1024)),
        throwsArgumentError,
      );
    });

    test('a transform smaller than the window fails loudly', () {
      expect(
        () => FrequencyAnalyzer(fft: Fft(512), windowSize: 4096),
        throwsArgumentError,
      );
    });
  });
}
