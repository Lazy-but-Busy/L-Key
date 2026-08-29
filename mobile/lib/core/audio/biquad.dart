/// A one-section IIR filter, used to keep rumble out of the pitch detector.
///
/// Contains no Flutter. See docs/adr/0012.
library;

import 'dart:math' as math;
import 'dart:typed_data';

/// A second-order IIR section in transposed direct form II.
///
/// Stateful **across frames**, which is why it belongs to the sample stream
/// and not to a single window: reset it at every frame boundary and the
/// discontinuity that produces is itself a signal the detector would have to
/// explain away.
///
/// The tuner uses one as a high-pass. Handling noise, a table knock and the
/// low-frequency wander of a phone microphone all put energy well below the
/// lowest note a guitar or bass can sound, and that energy drifts the
/// waveform's baseline — which manufactures long-period structure in the
/// autocorrelation and pulls the detector an octave down.
final class Biquad {
  /// A high-pass at [cutoffHz], from the Audio EQ Cookbook.
  ///
  /// The default [q] of 1/√2 is Butterworth: as flat as a second-order
  /// section gets in the passband, which matters because the passband starts
  /// only half an octave above a five-string bass's low B.
  factory Biquad.highPass({
    required double sampleRate,
    required double cutoffHz,
    double q = math.sqrt1_2,
  }) {
    if (sampleRate <= 0) {
      throw ArgumentError.value(sampleRate, 'sampleRate', 'must be positive');
    }
    if (cutoffHz <= 0 || cutoffHz >= sampleRate / 2) {
      throw ArgumentError.value(
        cutoffHz,
        'cutoffHz',
        'must sit between zero and the Nyquist frequency',
      );
    }
    if (q <= 0) {
      throw ArgumentError.value(q, 'q', 'must be positive');
    }

    final w0 = 2 * math.pi * cutoffHz / sampleRate;
    final cosW0 = math.cos(w0);
    final alpha = math.sin(w0) / (2 * q);

    final a0 = 1 + alpha;
    return Biquad._(
      b0: (1 + cosW0) / 2 / a0,
      b1: -(1 + cosW0) / a0,
      b2: (1 + cosW0) / 2 / a0,
      a1: -2 * cosW0 / a0,
      a2: (1 - alpha) / a0,
    );
  }

  Biquad._({
    required this._b0,
    required this._b1,
    required this._b2,
    required this._a1,
    required this._a2,
  });

  final double _b0;
  final double _b1;
  final double _b2;
  final double _a1;
  final double _a2;

  double _s1 = 0;
  double _s2 = 0;

  /// Filters one sample and advances the state.
  double process(double x) {
    final y = _b0 * x + _s1;
    _s1 = _b1 * x - _a1 * y + _s2;
    _s2 = _b2 * x - _a2 * y;
    return y;
  }

  /// Filters the first [length] samples of [buffer] in place.
  void processInPlace(Float64List buffer, [int? length]) {
    final end = length ?? buffer.length;
    for (var i = 0; i < end; i++) {
      buffer[i] = process(buffer[i]);
    }
  }

  /// Clears the filter's memory, as at the start of a new listening session.
  void reset() {
    _s1 = 0;
    _s2 = 0;
  }
}
