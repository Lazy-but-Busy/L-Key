/// The McLeod pitch method, which is how the tuner finds a note.
///
/// Contains no Flutter. See docs/adr/0012.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:l_key/core/audio/audio_frame.dart';
import 'package:l_key/core/audio/fft.dart';
import 'package:l_key/core/audio/pitch_detector.dart';

/// Finds a fundamental by the normalised square difference function.
///
/// **Why the period and not the spectrum.** At a 4096-sample window one
/// spectrum bin spans 5.4 Hz, which at the low E's 82.41 Hz is a whole
/// semitone — so the best a peak-picker could do is interpolate within a bin
/// it cannot resolve. Worse, a plucked low E through a phone microphone
/// routinely arrives with its fundamental fifteen decibels below its second
/// harmonic, so the tallest peak in the spectrum sits at 164.8 Hz and a
/// spectral tuner reads an octave high by construction. The repetition period
/// is unchanged by how weak the first harmonic is, and this measures that.
///
/// **Why NSDF and not YIN.** They are two normalisations of the same
/// autocorrelation and their accuracy is comparable. NSDF is bounded in
/// −1…1 and its peak height *is* a periodicity measure, which is exactly the
/// shape [DetectedPitch.clarity] needs; YIN's difference function is unbounded
/// and needs an arbitrary mapping to get there. YIN also leans on an absolute
/// threshold that behaves badly on the low strings, where the fundamental is
/// weakest, while McLeod's rule is relative to the signal.
final class MpmPitchDetector implements PitchDetector {
  /// Builds a detector for [windowSize] windows using [fft].
  ///
  /// [fft] must be at least twice [windowSize]: the autocorrelation is taken
  /// through the transform, and a circular one would wrap the window's tail
  /// onto its head and invent periodicity that is not there.
  MpmPitchDetector({
    required Fft fft,
    required int windowSize,
    this.minimumHz = 27.5,
    this.maximumHz = 1318.51,
    this.peakThreshold = 0.9,
    this.clarityFloor = 0.35,
    this.refinementSteps = 12,
  }) : _fft = fft,
       _windowSize = windowSize,
       _signal = Float64List(windowSize),
       _re = Float64List(fft.size),
       _im = Float64List(fft.size),
       _nsdf = Float64List(windowSize) {
    if (fft.size < windowSize * 2) {
      throw ArgumentError.value(
        fft.size,
        'fft.size',
        'must be at least twice the window size of $windowSize',
      );
    }
    if (minimumHz <= 0 || maximumHz <= minimumHz) {
      throw ArgumentError.value(
        maximumHz,
        'maximumHz',
        'must sit above a positive minimumHz',
      );
    }
  }

  /// The lowest note reported: a five-string bass's low B is 30.87 Hz and A0
  /// leaves headroom below it.
  ///
  /// This and [maximumHz] are the range that can be relied on. The search runs
  /// a semitone past each end so a note sitting exactly on the boundary is
  /// still found, so a reading may land marginally outside.
  @override
  final double minimumHz;

  /// The highest note reported. E6 is two octaves above the guitar's top open
  /// string, which covers a capo and a chromatic reading of a harmonic.
  @override
  final double maximumHz;

  /// How close to the tallest key maximum a candidate must come.
  ///
  /// **This constant is the octave defence.** Lower it and a shorter period
  /// is accepted where the fundamental is weak, and the reading jumps an
  /// octave up — which is precisely the case a guitar's low strings present.
  /// There is a regression test that loosens it and watches the error appear.
  /// McLeod's 0.9.
  final double peakThreshold;

  /// Below this periodicity nothing is reported at all.
  ///
  /// CLAUDE.md §16: an algorithm that is unsure must say so rather than offer
  /// a number the interface will present as a note.
  final double clarityFloor;

  /// How many bisections refine the interpolated peak.
  ///
  /// Parabolic interpolation over three integer lags is accurate to a few
  /// hundredths of a sample near the low strings, where a period is hundreds
  /// of samples long. It is not enough near the top string, where a period is
  /// only 134 samples and a tenth of a sample is three cents. These steps
  /// search the true function between lags. Zero turns them off, which is what
  /// the test that proves they earn their place uses.
  final int refinementSteps;

  /// One equal-tempered semitone as a frequency ratio.
  static const double _semitone = 1.0594630943592953;

  final Fft _fft;
  final int _windowSize;
  final Float64List _signal;
  final Float64List _re;
  final Float64List _im;
  final Float64List _nsdf;

  @override
  DetectedPitch? analyze(AudioFrame frame) {
    if (frame.length != _windowSize) {
      throw ArgumentError.value(
        frame.length,
        'frame.length',
        'this detector is built for $_windowSize samples',
      );
    }

    // Bounds come from the frame's own rate, never from a requested one. A
    // device that quietly grants 48000 instead of 44100 would otherwise shift
    // every reading by about a tone and a half, silently.
    final sampleRate = frame.sampleRate;
    // The searched range runs a semitone past the declared one at each end.
    // A note sitting exactly on the boundary has a period that falls between
    // two lags, and interpolation has to be able to land either side of it —
    // without the margin the top of the range reads an octave down.
    final lowest = minimumHz / _semitone;
    final highest = maximumHz * _semitone;
    final minLag = math.max(2, (sampleRate / highest).floor());
    final maxLag = math.min(
      (sampleRate / lowest).ceil(),
      _windowSize ~/ 2 - 1,
    );
    if (maxLag <= minLag + 2) return null;

    _prepare(frame.samples);
    _computeNsdf(maxLag + 1);

    final peak = _choosePeak(minLag, maxLag);
    if (peak == null) return null;

    final refined = _refine(peak, minLag, maxLag);
    final frequencyHz = sampleRate / refined.lag;
    if (frequencyHz < lowest || frequencyHz > highest) return null;

    return DetectedPitch(
      frequencyHz: frequencyHz,
      clarity: refined.clarity.clamp(0.0, 1.0),
      timestamp: frame.timestamp,
    );
  }

  /// Copies the window out and takes its mean off.
  ///
  /// A baseline offset is a very long period as far as an autocorrelation is
  /// concerned, and it pulls the answer down an octave. The stream's high-pass
  /// removes most of it; this removes what is left within the window.
  void _prepare(Float64List samples) {
    var mean = 0.0;
    for (var i = 0; i < _windowSize; i++) {
      mean += samples[i];
    }
    mean /= _windowSize;
    for (var i = 0; i < _windowSize; i++) {
      _signal[i] = samples[i] - mean;
    }
  }

  /// Fills [_nsdf] up to [maxLag] with `2·r(τ) / m'(τ)`.
  void _computeNsdf(int maxLag) {
    // Autocorrelation through the transform: pad to twice the window so the
    // result is linear rather than circular, transform, take the power
    // spectrum, and come back.
    _re.setRange(0, _windowSize, _signal);
    _re.fillRange(_windowSize, _fft.size, 0);
    _im.fillRange(0, _fft.size, 0);
    _fft.forward(_re, _im);
    for (var k = 0; k < _fft.size; k++) {
      _re[k] = _re[k] * _re[k] + _im[k] * _im[k];
      _im[k] = 0;
    }
    _fft.inverse(_re, _im);

    // m'(0) is twice the window's energy, and each step drops the one sample
    // that leaves each end of the overlap.
    var m = 0.0;
    for (var i = 0; i < _windowSize; i++) {
      m += _signal[i] * _signal[i];
    }
    m *= 2;

    _nsdf[0] = m == 0 ? 0 : 2 * _re[0] / m;
    for (var tau = 1; tau <= maxLag; tau++) {
      final leaving = _signal[tau - 1];
      final trailing = _signal[_windowSize - tau];
      m -= leaving * leaving + trailing * trailing;
      _nsdf[tau] = m <= 0 ? 0 : 2 * _re[tau] / m;
    }
  }

  /// McLeod's key-maximum rule: the *first* peak that comes close enough to
  /// the tallest one.
  ///
  /// Between each rising and falling zero crossing there is exactly one key
  /// maximum. Taking the tallest outright would often land on twice the true
  /// period, because a periodic signal repeats at every multiple of it; taking
  /// the first that clears [peakThreshold] takes the shortest period that
  /// explains the signal, which is the definition of the fundamental.
  ({int lag, double value})? _choosePeak(int minLag, int maxLag) {
    final maxima = <int>[];

    var tau = 1;
    // The hump at zero lag is the signal correlated with itself and says
    // nothing; walk past it.
    while (tau < maxLag && _nsdf[tau] > 0) {
      tau++;
    }

    while (tau < maxLag) {
      while (tau < maxLag && _nsdf[tau] <= 0) {
        tau++;
      }
      if (tau >= maxLag) break;

      var bestLag = tau;
      var best = _nsdf[tau];
      while (tau < maxLag && _nsdf[tau] > 0) {
        if (_nsdf[tau] > best) {
          best = _nsdf[tau];
          bestLag = tau;
        }
        tau++;
      }
      if (bestLag > 1 && bestLag < maxLag) maxima.add(bestLag);
    }

    if (maxima.isEmpty) return null;

    var tallest = 0.0;
    for (final lag in maxima) {
      if (_nsdf[lag] > tallest) tallest = _nsdf[lag];
    }
    if (tallest < clarityFloor) return null;

    final threshold = tallest * peakThreshold;
    for (final lag in maxima) {
      if (_nsdf[lag] < threshold) continue;
      // The shortest period that explains the signal is the fundamental. If
      // that period is shorter than the range allows, the sound is not one
      // this instrument can make — a whistle, feedback, a squeak — and the
      // honest answer is none. Reporting the first in-range multiple instead
      // would name a note nothing played.
      return lag < minLag ? null : (lag: lag, value: _nsdf[lag]);
    }
    return null;
  }

  /// Places the peak between lags: parabolic first, then bisection.
  ({double lag, double clarity}) _refine(
    ({int lag, double value}) peak,
    int minLag,
    int maxLag,
  ) {
    final before = _nsdf[peak.lag - 1];
    final at = peak.value;
    final after = _nsdf[peak.lag + 1];

    final denominator = before - 2 * at + after;
    final shift = denominator == 0
        ? 0.0
        : (0.5 * (before - after) / denominator).clamp(-1.0, 1.0);
    var lag = peak.lag + shift;
    var clarity = at - 0.25 * (before - after) * shift;

    if (refinementSteps > 0) {
      final searched = _search(lag, minLag, maxLag);
      // Only taken when it actually improves on the parabola, so a noisy
      // window cannot be walked somewhere worse.
      if (searched != null && searched.clarity >= clarity) {
        lag = searched.lag;
        clarity = searched.clarity;
      }
    }

    return (lag: lag, clarity: clarity);
  }

  /// A golden-section search of the true function either side of [around].
  ({double lag, double clarity})? _search(
    double around,
    int minLag,
    int maxLag,
  ) {
    var low = math.max(around - 1, minLag.toDouble());
    var high = math.min(around + 1, (maxLag - 1).toDouble());
    if (high - low < 1e-6) return null;

    const inverseGolden = 0.6180339887498949;
    var c = high - (high - low) * inverseGolden;
    var d = low + (high - low) * inverseGolden;
    var fc = _nsdfAt(c);
    var fd = _nsdfAt(d);

    for (var step = 0; step < refinementSteps; step++) {
      if (fc > fd) {
        high = d;
        d = c;
        fd = fc;
        c = high - (high - low) * inverseGolden;
        fc = _nsdfAt(c);
      } else {
        low = c;
        c = d;
        fc = fd;
        d = low + (high - low) * inverseGolden;
        fd = _nsdfAt(d);
      }
    }

    final lag = (low + high) / 2;
    return (lag: lag, clarity: _nsdfAt(lag));
  }

  /// The normalised square difference at a lag that need not be a whole
  /// number of samples, reading between samples where it has to.
  double _nsdfAt(double lag) {
    final span = _windowSize - lag.ceil() - 1;
    if (span <= 0) return 0;

    var correlation = 0.0;
    var energy = 0.0;
    for (var j = 0; j < span; j++) {
      final shifted = _sampleAt(j + lag);
      final here = _signal[j];
      correlation += here * shifted;
      energy += here * here + shifted * shifted;
    }
    return energy <= 0 ? 0 : 2 * correlation / energy;
  }

  double _sampleAt(double position) {
    final index = position.floor();
    if (index < 0 || index + 1 >= _windowSize) return 0;
    final fraction = position - index;
    return _signal[index] * (1 - fraction) + _signal[index + 1] * fraction;
  }
}
