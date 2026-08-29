import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/audio/biquad.dart';

import '../../helpers/waveforms.dart';

/// The steady-state gain the filter applies at [frequencyHz], in decibels.
///
/// Measured rather than derived, by running a tone through and comparing the
/// settled amplitude with the input's.
double _gainDb(Biquad filter, double frequencyHz, int sampleRate) {
  const length = 44100;
  final input = sine(
    frequencyHz: frequencyHz,
    sampleRate: sampleRate,
    length: length,
  );
  final output = Float64List(length);
  for (var i = 0; i < length; i++) {
    output[i] = filter.process(input[i]);
  }

  // Skip the first tenth so the filter's transient is not measured.
  final settled = Float64List.sublistView(output, length ~/ 10);
  final reference = Float64List.sublistView(input, length ~/ 10);
  return rmsDbfs(settled) - rmsDbfs(reference);
}

void main() {
  group('Biquad.highPass', () {
    test('it passes the lowest note the app can tune, near untouched', () {
      // A five-string bass's low B is 30.87 Hz. The cutoff sits below it on
      // purpose, and Butterworth is chosen because the passband starts only
      // half an octave up.
      final filter = Biquad.highPass(sampleRate: 44100, cutoffHz: 25);
      expect(_gainDb(filter, 82.41, 44100), closeTo(0, 0.5));

      filter.reset();
      expect(_gainDb(filter, 30.87, 44100), greaterThan(-3));
    });

    test('it removes the rumble that fakes a long period', () {
      // Handling noise and microphone wander sit well below any note, and
      // the baseline drift they cause is what pulls the detector an octave
      // down (docs/adr/0012).
      final filter = Biquad.highPass(sampleRate: 44100, cutoffHz: 25);
      expect(_gainDb(filter, 5, 44100), lessThan(-25));

      filter.reset();
      expect(_gainDb(filter, 10, 44100), lessThan(-15));
    });

    test('a constant offset decays to nothing', () {
      final filter = Biquad.highPass(sampleRate: 44100, cutoffHz: 25);
      var last = 0.0;
      for (var i = 0; i < 44100; i++) {
        last = filter.process(1);
      }
      expect(last.abs(), lessThan(1e-3));
    });

    test('a reset clears the memory', () {
      final filter = Biquad.highPass(sampleRate: 44100, cutoffHz: 25);
      for (var i = 0; i < 1000; i++) {
        filter.process(1);
      }
      final dirty = filter.process(0);
      filter.reset();
      expect(filter.process(0), 0.0);
      expect(dirty, isNot(0.0));
    });

    test('it filters a buffer in place identically to sample by sample', () {
      final a = Biquad.highPass(sampleRate: 44100, cutoffHz: 25);
      final b = Biquad.highPass(sampleRate: 44100, cutoffHz: 25);
      final signal = sine(frequencyHz: 100, sampleRate: 44100, length: 512);

      final oneByOne = Float64List.fromList(<double>[
        for (final sample in signal) a.process(sample),
      ]);
      final inPlace = Float64List.fromList(signal);
      b.processInPlace(inPlace);

      for (var i = 0; i < signal.length; i++) {
        expect(inPlace[i], closeTo(oneByOne[i], 1e-12), reason: 'sample $i');
      }
    });

    test('an impossible filter fails loudly', () {
      expect(
        () => Biquad.highPass(sampleRate: 0, cutoffHz: 25),
        throwsArgumentError,
      );
      expect(
        () => Biquad.highPass(sampleRate: 44100, cutoffHz: 0),
        throwsArgumentError,
      );
      // At or above Nyquist there is nothing left to pass.
      expect(
        () => Biquad.highPass(sampleRate: 44100, cutoffHz: 22050),
        throwsArgumentError,
      );
      expect(
        () => Biquad.highPass(sampleRate: 44100, cutoffHz: 25, q: 0),
        throwsArgumentError,
      );
    });
  });
}
