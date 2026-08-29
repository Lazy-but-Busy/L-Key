/// PCM bytes in, a description of the sound out.
///
/// Contains no Flutter. See docs/adr/0012.
library;

import 'dart:typed_data';

import 'package:l_key/core/audio/audio_frame.dart';
import 'package:l_key/core/audio/audio_frame_assembler.dart';
import 'package:l_key/core/audio/biquad.dart';
import 'package:l_key/core/audio/fft.dart';
import 'package:l_key/core/audio/frequency_analyzer.dart';
import 'package:l_key/core/audio/mpm_pitch_detector.dart';
import 'package:l_key/core/audio/pitch_detector.dart';
import 'package:l_key/core/audio/spectrum_features.dart';
import 'package:meta/meta.dart';

/// Everything one window of audio yielded.
@immutable
final class AnalysisFrame {
  /// Creates an analysed window.
  const AnalysisFrame({
    required this.features,
    required this.pitch,
    required this.timestamp,
  });

  /// What is in the sound: level, tonality, peaks.
  final SpectrumFeatures features;

  /// The window's fundamental, or null when it has no usable period.
  final DetectedPitch? pitch;

  /// When the window began, counted from the start of the stream.
  final Duration timestamp;
}

/// Assembles, describes and pitch-tracks a stream of PCM bytes.
///
/// This is the whole audio half of mobile CLAUDE.md §14's chain, and it holds
/// no microphone — bytes go in, [AnalysisFrame]s come out. That is what lets
/// the pipeline be driven end to end in a test from a synthesised waveform,
/// and what will let chord recognition (§16) consume the same frames without
/// a second pipeline being built beside this one.
///
/// Every large buffer belongs to the objects inside it and is reused; only the
/// small per-frame values are allocated (mobile CLAUDE.md §15).
final class AudioPipeline {
  /// Builds a pipeline for audio arriving at [sampleRate].
  ///
  /// One [Fft] is built at twice the window and shared: the detector needs
  /// that size for a linear autocorrelation, and the analyzer gets finer peak
  /// placement out of the same transform for nothing.
  factory AudioPipeline({
    required int sampleRate,
    int windowSize = defaultWindowSize,
    int? hopSize,
    double highPassHz = defaultHighPassHz,
    double minimumHz = 27.5,
    double maximumHz = 1318.51,
  }) {
    final hop = hopSize ?? windowSize ~/ 4;
    final fft = Fft(windowSize * 2);
    return AudioPipeline._(
      sampleRate,
      windowSize,
      hop,
      AudioFrameAssembler(
        sampleRate: sampleRate,
        windowSize: windowSize,
        hopSize: hop,
        preFilter: Biquad.highPass(
          sampleRate: sampleRate.toDouble(),
          cutoffHz: highPassHz,
        ),
      ),
      FrequencyAnalyzer(fft: fft, windowSize: windowSize),
      MpmPitchDetector(
        fft: fft,
        windowSize: windowSize,
        minimumHz: minimumHz,
        maximumHz: maximumHz,
      ),
    );
  }

  const AudioPipeline._(
    this.sampleRate,
    this.windowSize,
    this.hopSize,
    this._assembler,
    this._analyzer,
    this._detector,
  );

  /// 4096 samples is 93 ms at 44.1 kHz, which holds two and a half periods of
  /// the lowest note the app tunes and still lets a window overlap its
  /// neighbour by three quarters.
  static const int defaultWindowSize = 4096;

  /// 8192, for a bass whose lowest string sits below [bassThresholdHz].
  static const int bassWindowSize = 8192;

  /// Below this, a window has to be twice as long to hold enough periods.
  static const double bassThresholdHz = 55;

  /// Well under the lowest note and well above nothing: handling noise and a
  /// microphone's low-frequency wander drift the waveform's baseline, which
  /// invents long-period structure and pulls a reading an octave down.
  static const double defaultHighPassHz = 25;

  /// The window a tuning needs, given its lowest open string.
  ///
  /// A rule rather than a constant, so a five-string bass gets what it needs
  /// without a guitar paying for it.
  static int windowSizeFor(double lowestStringHz) =>
      lowestStringHz < bassThresholdHz ? bassWindowSize : defaultWindowSize;

  /// Samples per second this pipeline was built for.
  final int sampleRate;

  /// How many samples each analysed window holds.
  final int windowSize;

  /// How many new samples separate one window from the next.
  final int hopSize;

  final AudioFrameAssembler _assembler;
  final FrequencyAnalyzer _analyzer;
  final PitchDetector _detector;

  /// How many windows a second this pipeline produces.
  double get framesPerSecond => sampleRate / hopSize;

  /// Feeds one chunk of PCM in, calling [onFrame] once per complete window.
  void addPcm16(Uint8List chunk, void Function(AnalysisFrame frame) onFrame) {
    _assembler.addPcm16(chunk, (frame) => onFrame(_analyze(frame)));
  }

  AnalysisFrame _analyze(AudioFrame frame) {
    final features = _analyzer.analyze(frame);
    return AnalysisFrame(
      features: features,
      pitch: _detector.analyze(frame),
      timestamp: frame.timestamp,
    );
  }

  /// Forgets every buffered sample and the filter's memory.
  void reset() => _assembler.reset();
}
