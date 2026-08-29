import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/audio/fft.dart';

/// The definition of the transform, written out longhand.
///
/// This is the oracle. docs/adr/0012 declines an FFT dependency on the grounds
/// that the third party's job can be fully verified in twenty lines of test,
/// and these are the twenty lines.
({Float64List re, Float64List im}) _naiveDft(Float64List re, Float64List im) {
  final n = re.length;
  final outRe = Float64List(n);
  final outIm = Float64List(n);
  for (var k = 0; k < n; k++) {
    var sumRe = 0.0;
    var sumIm = 0.0;
    for (var t = 0; t < n; t++) {
      final angle = -2 * math.pi * t * k / n;
      sumRe += re[t] * math.cos(angle) - im[t] * math.sin(angle);
      sumIm += re[t] * math.sin(angle) + im[t] * math.cos(angle);
    }
    outRe[k] = sumRe;
    outIm[k] = sumIm;
  }
  return (re: outRe, im: outIm);
}

Float64List _randomSignal(int length, int seed) {
  final random = math.Random(seed);
  return Float64List.fromList(<double>[
    for (var i = 0; i < length; i++) random.nextDouble() * 2 - 1,
  ]);
}

void main() {
  group('Fft', () {
    test('it agrees with the definition of the transform', () {
      // docs/adr/0012 — the assertion that replaces a dependency.
      const size = 64;
      final re = _randomSignal(size, 7);
      final im = _randomSignal(size, 8);
      final expected = _naiveDft(re, im);

      Fft(size).forward(re, im);

      final failures = <String>[];
      for (var k = 0; k < size; k++) {
        if ((re[k] - expected.re[k]).abs() > 1e-9) {
          failures.add('bin $k real: ${re[k]} vs ${expected.re[k]}');
        }
        if ((im[k] - expected.im[k]).abs() > 1e-9) {
          failures.add('bin $k imaginary: ${im[k]} vs ${expected.im[k]}');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('an impulse spreads evenly across every bin', () {
      final re = Float64List(32)..[0] = 1;
      final im = Float64List(32);
      Fft(32).forward(re, im);

      for (var k = 0; k < 32; k++) {
        expect(re[k], closeTo(1, 1e-12), reason: 'bin $k');
        expect(im[k], closeTo(0, 1e-12), reason: 'bin $k');
      }
    });

    test('a bin-centred sinusoid lands in exactly one conjugate pair', () {
      const size = 64;
      const bin = 5;
      final re = Float64List(size);
      final im = Float64List(size);
      for (var i = 0; i < size; i++) {
        re[i] = math.cos(2 * math.pi * bin * i / size);
      }

      Fft(size).forward(re, im);

      final magnitudes = <double>[
        for (var k = 0; k < size; k++) math.sqrt(re[k] * re[k] + im[k] * im[k]),
      ];
      expect(magnitudes[bin], closeTo(size / 2, 1e-9));
      expect(magnitudes[size - bin], closeTo(size / 2, 1e-9));
      for (var k = 0; k < size; k++) {
        if (k == bin || k == size - bin) continue;
        expect(
          magnitudes[k],
          closeTo(0, 1e-9),
          reason: 'bin $k should be empty',
        );
      }
    });

    test('an inverse undoes a forward', () {
      const size = 256;
      final original = _randomSignal(size, 11);
      final re = Float64List.fromList(original);
      final im = Float64List(size);
      Fft(size)
        ..forward(re, im)
        ..inverse(re, im);

      final failures = <String>[];
      for (var i = 0; i < size; i++) {
        if ((re[i] - original[i]).abs() > 1e-10) {
          failures.add('sample $i: ${re[i]} vs ${original[i]}');
        }
        if (im[i].abs() > 1e-10) {
          failures.add('sample $i grew an imaginary part: ${im[i]}');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test("Parseval's theorem holds, so no energy is invented or lost", () {
      const size = 128;
      final signal = _randomSignal(size, 13);
      final re = Float64List.fromList(signal);
      final im = Float64List(size);

      var timeEnergy = 0.0;
      for (final sample in signal) {
        timeEnergy += sample * sample;
      }

      Fft(size).forward(re, im);
      var frequencyEnergy = 0.0;
      for (var k = 0; k < size; k++) {
        frequencyEnergy += re[k] * re[k] + im[k] * im[k];
      }

      expect(frequencyEnergy / size, closeTo(timeEnergy, 1e-9));
    });

    test('the tables carry no state between transforms', () {
      // One Fft is shared by the analyzer and the detector, so a transform
      // must not leave anything behind for the next caller.
      final fft = Fft(64);
      final first = _randomSignal(64, 17);

      final reA = Float64List.fromList(first);
      final imA = Float64List(64);
      fft.forward(reA, imA);

      final reB = Float64List.fromList(first);
      final imB = Float64List(64);
      fft
        ..forward(Float64List(64), Float64List(64))
        ..forward(reB, imB);

      for (var k = 0; k < 64; k++) {
        expect(reB[k], closeTo(reA[k], 1e-12), reason: 'bin $k');
        expect(imB[k], closeTo(imA[k], 1e-12), reason: 'bin $k');
      }
    });

    test('a size that is not a power of two fails loudly', () {
      expect(() => Fft(100), throwsArgumentError);
      expect(() => Fft(0), throwsArgumentError);
      expect(() => Fft(1), throwsArgumentError);
    });

    test('a buffer of the wrong length fails loudly', () {
      expect(
        () => Fft(64).forward(Float64List(32), Float64List(64)),
        throwsArgumentError,
      );
    });
  });
}
