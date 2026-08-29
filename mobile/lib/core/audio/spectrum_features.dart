/// What a window of audio contains, as distinct from what pitch it has.
///
/// Contains no Flutter. See docs/adr/0012.
library;

import 'dart:math' as math;

import 'package:meta/meta.dart';

/// One resolved peak in the magnitude spectrum.
@immutable
final class SpectralPeak {
  /// Creates a peak.
  const SpectralPeak({required this.frequencyHz, required this.magnitude});

  /// Where the peak sits, interpolated between bins.
  final double frequencyHz;

  /// How tall it is, in the spectrum's own units.
  final double magnitude;

  @override
  String toString() =>
      'SpectralPeak(${frequencyHz.toStringAsFixed(1)} Hz, $magnitude)';
}

/// The case for saying more than one string is ringing.
///
/// Deliberately a set of measurements rather than a verdict, so the numbers
/// that produced [isPolyphonic] can be read in the diagnostics view and
/// asserted in a test.
@immutable
final class PolyphonyEvidence {
  /// Creates the evidence.
  const PolyphonyEvidence({
    required this.residualRatio,
    required this.residualPartialCount,
    required this.residualFundamentalHz,
  });

  /// Nothing was left unexplained.
  static const PolyphonyEvidence none = PolyphonyEvidence(
    residualRatio: 0,
    residualPartialCount: 0,
    residualFundamentalHz: null,
  );

  /// How wide of an exact multiple a partial may sit and still be counted as
  /// belonging to the series.
  ///
  /// Comfortably above the error parabolic interpolation leaves on a peak,
  /// and wide enough to absorb the stiffness that pulls a steel string's
  /// eighth partial sharp.
  static const double toleranceCents = 35;

  /// How much of the spectrum's energy must be unexplained before a second
  /// note is a better explanation than an imperfect first one.
  static const double residualRatioThreshold = 0.35;

  /// How many partials the leftovers must line up into.
  ///
  /// One stray peak is a room resonance or a string buzz. Two or more in a
  /// series is a note.
  static const int minimumResidualPartials = 2;

  /// The share of peak energy that no harmonic of the detected pitch explains.
  final double residualRatio;

  /// How many leftover peaks form a harmonic series of their own.
  final int residualPartialCount;

  /// The strongest unexplained peak, if there was one.
  final double? residualFundamentalHz;

  /// Whether a second, independent partial series is present.
  ///
  /// That is the whole of the claim, and it is narrower than "there are two
  /// notes". **An octave double-stop is invisible to it**, and to any method
  /// that only looks at which frequencies are present: E2 and E3 together
  /// produce the same set of frequencies as one E2 with a strong second
  /// harmonic. There is a test asserting exactly that failure, so the limit
  /// stays a known property rather than becoming a bug report
  /// (CLAUDE.md §47). A fifth is the next-hardest interval for the same
  /// reason — most of the upper note's partials are also the lower one's —
  /// while fourths and thirds, which is what neighbouring guitar strings
  /// mostly are, separate cleanly.
  bool get isPolyphonic =>
      residualRatio > residualRatioThreshold &&
      residualPartialCount >= minimumResidualPartials;
}

/// Everything about a window except its pitch.
///
/// The split matters: this answers *what is in this sound*, and a
/// `PitchDetector` answers *what single period does it have*. They are the
/// "Audio Processing" and "Pitch Detection" boxes of mobile CLAUDE.md §14, and
/// keeping them apart is what lets chord recognition (§16) reuse this half
/// without touching a detector that is monophonic by definition.
@immutable
final class SpectrumFeatures {
  /// Creates a description of one window.
  const SpectrumFeatures({
    required this.rmsDbfs,
    required this.peakAmplitude,
    required this.clippedRatio,
    required this.spectralFlatness,
    required this.binHz,
    required this.peaks,
  });

  /// Loudness, in decibels relative to full scale.
  ///
  /// A full-scale sine reads −3.01, silence reads the −120 floor. The
  /// absolute scale is not comparable between devices, because input gain is
  /// not — which is why every threshold that reads it is calibrated in
  /// docs/DEVICE-TESTING.md rather than trusted.
  final double rmsDbfs;

  /// The largest absolute sample in the window.
  final double peakAmplitude;

  /// The share of samples sitting at or beyond full scale.
  ///
  /// A clipped signal still has a period and still reads accurately, but the
  /// player should be told to back off the microphone.
  final double clippedRatio;

  /// Geometric mean of the magnitudes over their arithmetic mean, 0…1.
  ///
  /// Near zero for a tone, near one for white noise. This is what separates
  /// "someone is talking" from "someone plucked a string" — a distinction
  /// loudness alone cannot make.
  final double spectralFlatness;

  /// How many hertz one spectrum bin spans.
  final double binHz;

  /// The resolved peaks, strongest first.
  final List<SpectralPeak> peaks;

  /// The share of peak energy explained by harmonics of [fundamentalHz].
  ///
  /// Near one for a single string. **Not** a way to find the octave: every
  /// harmonic of 220 Hz is also a harmonic of 110 Hz, so a 110 Hz tone scores
  /// highly at both. Finding the period is the detector's job, and there is a
  /// test asserting this limitation so nobody reaches for the wrong tool.
  double harmonicEnergyRatio(double fundamentalHz) {
    if (peaks.isEmpty || fundamentalHz <= 0) return 0;

    var explained = 0.0;
    var total = 0.0;
    for (final peak in peaks) {
      final energy = peak.magnitude * peak.magnitude;
      total += energy;
      if (_harmonicOf(peak.frequencyHz, fundamentalHz) != null) {
        explained += energy;
      }
    }
    return total == 0 ? 0 : explained / total;
  }

  /// Explains the spectrum with one harmonic series and weighs what is left.
  PolyphonyEvidence explainWith(double fundamentalHz) {
    if (peaks.isEmpty || fundamentalHz <= 0) return PolyphonyEvidence.none;

    final residual = <SpectralPeak>[];
    var residualEnergy = 0.0;
    var totalEnergy = 0.0;
    for (final peak in peaks) {
      final energy = peak.magnitude * peak.magnitude;
      totalEnergy += energy;
      if (_harmonicOf(peak.frequencyHz, fundamentalHz) == null) {
        residual.add(peak);
        residualEnergy += energy;
      }
    }

    if (totalEnergy == 0 || residual.isEmpty) return PolyphonyEvidence.none;

    // The strongest leftover is the candidate second note.
    final second = residual.first;

    // A leftover that is a sub-harmonic of the detected pitch is the detector
    // having picked the wrong octave, not a second string. Saying "two notes"
    // there would be inventing one.
    if (_octaveRelated(second.frequencyHz, fundamentalHz)) {
      return PolyphonyEvidence(
        residualRatio: residualEnergy / totalEnergy,
        residualPartialCount: 0,
        residualFundamentalHz: second.frequencyHz,
      );
    }

    var partials = 0;
    for (final peak in residual) {
      if (identical(peak, second)) continue;
      final harmonic = _harmonicOf(
        peak.frequencyHz,
        second.frequencyHz,
        maxHarmonic: 6,
      );
      if (harmonic != null) partials++;
    }

    return PolyphonyEvidence(
      residualRatio: residualEnergy / totalEnergy,
      residualPartialCount: partials,
      residualFundamentalHz: second.frequencyHz,
    );
  }

  /// Which harmonic of [fundamentalHz] this frequency is, or null.
  static int? _harmonicOf(
    double frequencyHz,
    double fundamentalHz, {
    int maxHarmonic = 12,
  }) {
    if (fundamentalHz <= 0 || frequencyHz <= 0) return null;
    final ratio = frequencyHz / fundamentalHz;
    final k = ratio.round();
    if (k < 1 || k > maxHarmonic) return null;
    final cents = 1200 * math.log(ratio / k) / math.ln2;
    return cents.abs() <= PolyphonyEvidence.toleranceCents ? k : null;
  }

  static bool _octaveRelated(double a, double b) {
    for (var k = 2; k <= 6; k++) {
      if (_harmonicOf(a, b / k, maxHarmonic: 1) != null) return true;
      if (_harmonicOf(b, a / k, maxHarmonic: 1) != null) return true;
    }
    return false;
  }
}
