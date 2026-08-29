/// Turns a window of audio into a description of what is in it.
///
/// Contains no Flutter. See docs/adr/0012.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:l_key/core/audio/audio_frame.dart';
import 'package:l_key/core/audio/fft.dart';
import 'package:l_key/core/audio/spectrum_features.dart';

/// Measures level, tonality and spectral peaks for one window.
///
/// Every large buffer is allocated once here and reused for the life of the
/// object; only the small [SpectrumFeatures] and its peak list are built per
/// window (mobile CLAUDE.md §15, PRD.md §63).
///
/// A **Hann** window is applied, unlike the pitch detector's rectangular one.
/// The two want opposite things: here low sidelobes matter, because a
/// rectangular window's leakage manufactures peaks that would then be counted
/// as a second note; there a taper would bias the autocorrelation toward
/// short lags and cause octave errors.
final class FrequencyAnalyzer {
  /// Analyses [windowSize] windows using [fft].
  ///
  /// [fft] may be larger than [windowSize], in which case the window is
  /// zero-padded — which costs nothing extra when the same transform is
  /// already sized for the detector, and doubles how finely a peak can be
  /// placed.
  FrequencyAnalyzer({required Fft fft, required int windowSize})
    : _fft = fft,
      _windowSize = windowSize,
      _hann = Float64List(windowSize),
      _re = Float64List(fft.size),
      _im = Float64List(fft.size),
      _magnitudes = Float64List(fft.size ~/ 2 + 1) {
    if (windowSize > fft.size) {
      throw ArgumentError.value(
        windowSize,
        'windowSize',
        'must not exceed the transform size of ${fft.size}',
      );
    }
    for (var i = 0; i < windowSize; i++) {
      _hann[i] = 0.5 - 0.5 * math.cos(2 * math.pi * i / (windowSize - 1));
    }
  }

  /// A sample at or beyond this magnitude is treated as clipped.
  static const double clippingThreshold = 0.99;

  /// How far below the strongest peak a peak may sit and still be counted.
  static const double peakFloorDb = -20;

  /// How many times the spectrum's median a peak must exceed, so that a noisy
  /// window does not report a hundred peaks.
  static const double peakNoiseFloorFactor = 4;

  /// The most peaks reported, strongest first.
  static const int maximumPeaks = 32;

  final Fft _fft;
  final int _windowSize;
  final Float64List _hann;
  final Float64List _re;
  final Float64List _im;
  final Float64List _magnitudes;

  /// Describes one window.
  SpectrumFeatures analyze(AudioFrame frame) {
    if (frame.length != _windowSize) {
      throw ArgumentError.value(
        frame.length,
        'frame.length',
        'this analyzer is built for $_windowSize samples',
      );
    }

    final samples = frame.samples;

    var sumSquares = 0.0;
    var peakAmplitude = 0.0;
    var clipped = 0;
    for (var i = 0; i < _windowSize; i++) {
      final sample = samples[i];
      sumSquares += sample * sample;
      final magnitude = sample.abs();
      if (magnitude > peakAmplitude) peakAmplitude = magnitude;
      if (magnitude >= clippingThreshold) clipped++;
    }
    final rms = math.sqrt(sumSquares / _windowSize);

    for (var i = 0; i < _windowSize; i++) {
      _re[i] = samples[i] * _hann[i];
      _im[i] = 0;
    }
    _re.fillRange(_windowSize, _fft.size, 0);
    _im.fillRange(_windowSize, _fft.size, 0);
    _fft.forward(_re, _im);

    final bins = _magnitudes.length;
    for (var k = 0; k < bins; k++) {
      _magnitudes[k] = math.sqrt(_re[k] * _re[k] + _im[k] * _im[k]);
    }

    final binHz = frame.sampleRate / _fft.size;

    return SpectrumFeatures(
      rmsDbfs: rms <= 0 ? -120 : 20 * math.log(rms) / math.ln10,
      peakAmplitude: peakAmplitude,
      clippedRatio: clipped / _windowSize,
      spectralFlatness: _flatness(bins),
      binHz: binHz,
      peaks: _pickPeaks(bins, binHz),
    );
  }

  /// Geometric over arithmetic mean: zero for a tone, one for white noise.
  double _flatness(int bins) {
    var logSum = 0.0;
    var sum = 0.0;
    var counted = 0;
    // Bin zero is the mean of the window, which the high-pass has already
    // taken out and which says nothing about tonality either way.
    for (var k = 1; k < bins; k++) {
      final magnitude = _magnitudes[k];
      logSum += math.log(magnitude + 1e-12);
      sum += magnitude;
      counted++;
    }
    if (counted == 0 || sum == 0) return 0;
    final geometric = math.exp(logSum / counted);
    final arithmetic = sum / counted;
    return (geometric / arithmetic).clamp(0.0, 1.0);
  }

  List<SpectralPeak> _pickPeaks(int bins, double binHz) {
    var strongest = 0.0;
    for (var k = 1; k < bins; k++) {
      if (_magnitudes[k] > strongest) strongest = _magnitudes[k];
    }
    if (strongest <= 0) return const <SpectralPeak>[];

    final sorted = Float64List.fromList(
      Float64List.sublistView(_magnitudes, 1, bins),
    )..sort();
    final median = sorted[sorted.length ~/ 2];

    final floor = math.max(
      strongest * math.pow(10, peakFloorDb / 20).toDouble(),
      median * peakNoiseFloorFactor,
    );

    final found = <SpectralPeak>[];
    for (var k = 1; k < bins - 1; k++) {
      final magnitude = _magnitudes[k];
      if (magnitude < floor) continue;
      final before = _magnitudes[k - 1];
      final after = _magnitudes[k + 1];
      if (magnitude <= before || magnitude < after) continue;

      // Parabolic interpolation places the true peak between bins, which is
      // what makes a harmonic check to thirty-five cents meaningful at all.
      final denominator = before - 2 * magnitude + after;
      final offset = denominator == 0
          ? 0.0
          : 0.5 * (before - after) / denominator;
      found.add(
        SpectralPeak(
          frequencyHz: (k + offset) * binHz,
          magnitude: magnitude,
        ),
      );
    }

    found.sort((a, b) => b.magnitude.compareTo(a.magnitude));
    return found.length <= maximumPeaks
        ? List<SpectralPeak>.unmodifiable(found)
        : List<SpectralPeak>.unmodifiable(found.take(maximumPeaks));
  }
}
