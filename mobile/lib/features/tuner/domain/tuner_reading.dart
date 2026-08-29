/// What the tuner knows about one note, in the shape PRD.md §10 asks for.
///
/// Contains no Flutter. See docs/adr/0013.
library;

import 'package:l_key/core/music/pitch.dart';
import 'package:meta/meta.dart';

/// Which way the needle points.
enum TuningDirection {
  /// Below the target. The needle moves left (DESIGN.md §22).
  flat,

  /// Within tolerance. The needle locks centrally.
  inTune,

  /// Above the target. The needle moves right.
  sharp,
}

/// One settled reading of a string.
///
/// The field list is PRD.md §10's technical requirement almost verbatim —
/// DetectedNote, Frequency, TargetFrequency, Cents, Confidence, IsInTune —
/// because that is the structured data the specification says the engine must
/// expose and the interface must not compute for itself.
@immutable
final class TunerReading {
  /// Creates a reading.
  const TunerReading({
    required this.detectedNote,
    required this.frequencyHz,
    required this.targetNote,
    required this.targetFrequencyHz,
    required this.cents,
    required this.confidence,
    required this.isInTune,
    required this.isSettled,
    this.targetStringIndex,
  });

  /// The nearest note to what is sounding, spelled by the target.
  final Pitch detectedNote;

  /// What is sounding, in hertz.
  final double frequencyHz;

  /// The note being tuned towards.
  final Pitch targetNote;

  /// What that note should sound at, given the reference pitch.
  final double targetFrequencyHz;

  /// How far off the target the string is. Positive is sharp.
  final double cents;

  /// How much to trust this, from 0.0 to 1.0.
  ///
  /// The detector's raw periodicity gated by level and tonality — a period can
  /// be perfectly clear and still belong to a fan rather than a string
  /// (CLAUDE.md §16).
  final double confidence;

  /// Whether the string is within tolerance right now.
  final bool isInTune;

  /// Whether it has *stayed* within tolerance long enough to call it done.
  ///
  /// Distinct from [isInTune] because a needle sweeping through centre while
  /// a peg turns is in tune for an instant and is not finished. This is the
  /// edge the haptic fires on (DESIGN.md §40).
  final bool isSettled;

  /// Which string is being tuned, or null in chromatic mode.
  ///
  /// Indexed lowest-sounding first, like `Tuning.openStrings`.
  final int? targetStringIndex;

  /// Which way the needle points.
  TuningDirection get direction {
    if (isInTune) return TuningDirection.inTune;
    return cents < 0 ? TuningDirection.flat : TuningDirection.sharp;
  }

  /// Returns a copy with the settled flag replaced.
  TunerReading copyWith({bool? isSettled}) => TunerReading(
    detectedNote: detectedNote,
    frequencyHz: frequencyHz,
    targetNote: targetNote,
    targetFrequencyHz: targetFrequencyHz,
    cents: cents,
    confidence: confidence,
    isInTune: isInTune,
    isSettled: isSettled ?? this.isSettled,
    targetStringIndex: targetStringIndex,
  );

  @override
  String toString() =>
      'TunerReading(${targetNote.name} ${cents.toStringAsFixed(1)} cents, '
      'confidence ${confidence.toStringAsFixed(2)})';
}
