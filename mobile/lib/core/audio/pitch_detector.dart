/// The audio seam for the tuner.
///
/// CLAUDE.md §14 requires that the rest of the application never depend on a
/// specific DSP implementation, so the pitch-detection algorithm can be
/// replaced without touching the tuner engine, its state, or the UI. This file
/// defines that boundary and nothing else — **no DSP lives here.**
///
/// The intended pipeline (CLAUDE.md §14, README "Audio Architecture"):
///
/// ```text
/// Microphone -> Audio Input -> Audio Processing -> PitchDetector
///            -> Tuning Engine -> Tuner State -> UI
/// ```
library;

/// A single pitch observation produced by a [PitchDetector].
///
/// [confidence] is not optional decoration. CLAUDE.md §16 forbids telling a
/// user a result is correct when the algorithm is unsure, so every consumer
/// must branch on it rather than trusting [frequencyHz] blindly.
class DetectedPitch {
  /// Creates a pitch observation.
  const DetectedPitch({
    required this.frequencyHz,
    required this.confidence,
    required this.timestamp,
  }) : assert(
         confidence >= 0.0 && confidence <= 1.0,
         'confidence must be within 0.0..1.0',
       );

  /// A reading in which no pitch could be identified.
  const DetectedPitch.silent(this.timestamp) : frequencyHz = 0, confidence = 0;

  /// Fundamental frequency in hertz. Zero when nothing was detected.
  final double frequencyHz;

  /// How certain the detector is, from 0.0 to 1.0.
  final double confidence;

  /// When the underlying audio window was captured.
  final Duration timestamp;

  /// Whether a pitch was found at all.
  bool get hasPitch => frequencyHz > 0;
}

/// Detects the fundamental frequency of an incoming audio stream.
///
/// Implementations own their own audio session and must release the
/// microphone in [stop] — CLAUDE.md §50 requires audio processing to end when
/// the tuner closes or the app backgrounds, because it is the single largest
/// battery cost in the product.
abstract interface class PitchDetector {
  /// Begins listening and emits observations until [stop] is called.
  ///
  /// Throws a `PermissionFailure` if microphone access is refused.
  Stream<DetectedPitch> start();

  /// Stops listening and releases the microphone and audio session.
  Future<void> stop();

  /// Whether this detector is currently consuming audio.
  bool get isRunning;
}
