/// The audio seam for the tuner.
///
/// CLAUDE.md §14 requires that the rest of the application never depend on a
/// specific DSP implementation, so the pitch-detection algorithm can be
/// replaced without touching the tuner engine, its state, or the UI. This file
/// defines that boundary and nothing else — **no DSP lives here.**
///
/// The pipeline (CLAUDE.md §14, README "Audio Architecture"):
///
/// ```text
/// Microphone -> Audio Input -> Audio Processing -> PitchDetector
///            -> Tuning Engine -> Tuner State -> UI
/// ```
///
/// Contains no Flutter. See docs/adr/0012.
library;

import 'package:l_key/core/audio/audio_frame.dart';
import 'package:meta/meta.dart';

/// A single pitch observation produced by a [PitchDetector].
@immutable
final class DetectedPitch {
  /// Creates a pitch observation.
  const DetectedPitch({
    required this.frequencyHz,
    required this.clarity,
    required this.timestamp,
  }) : assert(
         clarity >= 0.0 && clarity <= 1.0,
         'clarity must be within 0.0..1.0',
       );

  /// Fundamental frequency in hertz.
  final double frequencyHz;

  /// How periodic the window was, from 0.0 to 1.0.
  ///
  /// **Not the tuner's confidence, and deliberately not called that.** This is
  /// the raw periodicity of the waveform and nothing else; a detector can be
  /// completely certain about the period of a signal that is far too quiet to
  /// act on, or that is a fan rather than a string. The tuner combines this
  /// with level and tonality to get a number it is willing to show, and one
  /// name for two numbers is the sort of thing that reaches the UI as the
  /// wrong one (CLAUDE.md §16).
  final double clarity;

  /// When the underlying audio window was captured.
  final Duration timestamp;

  @override
  bool operator ==(Object other) =>
      other is DetectedPitch &&
      other.frequencyHz == frequencyHz &&
      other.clarity == clarity &&
      other.timestamp == timestamp;

  @override
  int get hashCode => Object.hash(frequencyHz, clarity, timestamp);

  @override
  String toString() =>
      'DetectedPitch(${frequencyHz.toStringAsFixed(2)} Hz, '
      'clarity ${clarity.toStringAsFixed(3)})';
}

/// Finds the fundamental frequency of one window of audio.
///
/// **Pure and synchronous.** It owns no microphone, no stream and no state
/// between frames: the same window analysed twice gives the same answer, and
/// two windows in either order give the same two answers. That is what makes
/// the algorithm testable against a synthetic waveform rather than only
/// through a fake audio stream, and it is why capture lives behind a separate
/// `AudioInput` rather than inside here (docs/adr/0012).
abstract interface class PitchDetector {
  /// Returns the window's fundamental, or null when it has no usable period.
  ///
  /// Null rather than a zero-frequency reading: silence, noise and a signal
  /// outside the instrument's range all have no answer, and one absent
  /// representation is easier to handle than a sentinel (CLAUDE.md §37).
  DetectedPitch? analyze(AudioFrame frame);

  /// The lowest frequency this detector will report.
  double get minimumHz;

  /// The highest frequency this detector will report.
  double get maximumHz;
}
