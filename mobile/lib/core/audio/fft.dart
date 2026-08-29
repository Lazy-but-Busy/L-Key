/// A fast Fourier transform, written here rather than depended on.
///
/// Contains no Flutter. See docs/adr/0012.
library;

import 'dart:math' as math;
import 'dart:typed_data';

/// An in-place iterative radix-2 Cooley–Tukey FFT of a fixed [size].
///
/// One instance is built per size and shared: the twiddle and bit-reversal
/// tables are immutable, so the analyzer and the pitch detector use the same
/// object. Callers supply their own scratch buffers, which is what keeps the
/// audio path free of per-frame allocation (mobile CLAUDE.md §15).
///
/// **Why this is hand-written.** CLAUDE.md §42 asks whether a dependency is
/// actually necessary. The only maintained pure-Dart option allocates a fresh
/// output list per call — forty-three times a second, forever, in a 60fps app
/// — and wrapping it to recover buffer reuse is more code than this file.
/// Correctness is not taken on trust either way: `fft_test.dart` checks this
/// against a naive DFT, so the third party's job is one we can fully verify in
/// twenty lines of test.
final class Fft {
  /// Builds the tables for transforms of exactly [size] points.
  ///
  /// Throws [ArgumentError] unless [size] is a power of two of at least 2.
  Fft(this.size)
    : _cos = Float64List(size ~/ 2),
      _sin = Float64List(size ~/ 2),
      _reversed = Uint32List(size) {
    if (size < 2 || (size & (size - 1)) != 0) {
      throw ArgumentError.value(size, 'size', 'must be a power of two, >= 2');
    }

    final half = size ~/ 2;
    for (var i = 0; i < half; i++) {
      final angle = 2 * math.pi * i / size;
      _cos[i] = math.cos(angle);
      _sin[i] = math.sin(angle);
    }

    var bits = 0;
    while (1 << bits < size) {
      bits++;
    }
    for (var i = 0; i < size; i++) {
      var value = i;
      var reversed = 0;
      for (var bit = 0; bit < bits; bit++) {
        reversed = (reversed << 1) | (value & 1);
        value >>= 1;
      }
      _reversed[i] = reversed;
    }
  }

  /// How many points each transform covers.
  final int size;

  final Float64List _cos;
  final Float64List _sin;
  final Uint32List _reversed;

  /// Transforms [re] and [im] in place, forward.
  ///
  /// Both lists must be exactly [size] long. For real input, fill [im] with
  /// zeroes.
  void forward(Float64List re, Float64List im) {
    if (re.length != size || im.length != size) {
      throw ArgumentError('buffers must both be $size long');
    }

    for (var i = 0; i < size; i++) {
      final j = _reversed[i];
      if (j > i) {
        final tempRe = re[i];
        re[i] = re[j];
        re[j] = tempRe;
        final tempIm = im[i];
        im[i] = im[j];
        im[j] = tempIm;
      }
    }

    for (var halfSize = 1; halfSize < size; halfSize *= 2) {
      final step = size ~/ (halfSize * 2);
      for (var i = 0; i < size; i += halfSize * 2) {
        for (var j = i, k = 0; j < i + halfSize; j++, k += step) {
          final partner = j + halfSize;
          final tRe = re[partner] * _cos[k] + im[partner] * _sin[k];
          final tIm = -re[partner] * _sin[k] + im[partner] * _cos[k];
          re[partner] = re[j] - tRe;
          im[partner] = im[j] - tIm;
          re[j] += tRe;
          im[j] += tIm;
        }
      }
    }
  }

  /// Transforms [re] and [im] in place, inverse, scaled so that an inverse of
  /// a forward returns the original signal.
  ///
  /// Swapping the two halves conjugates the kernel, which is the whole of the
  /// inverse besides the scaling.
  void inverse(Float64List re, Float64List im) {
    forward(im, re);
    for (var i = 0; i < size; i++) {
      re[i] /= size;
      im[i] /= size;
    }
  }
}
