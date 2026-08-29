/// Turns a frequency into a reading against a target.
///
/// Contains no Flutter. See docs/adr/0013.
library;

import 'package:l_key/core/music/pitch.dart';
import 'package:l_key/features/tuner/domain/tuner_reading.dart';
import 'package:l_key/features/tuner/domain/tuning_target.dart';
import 'package:meta/meta.dart';

/// Whether the tuner picks the string or the player does.
sealed class TargetMode {
  const TargetMode();

  /// Follow whatever string is nearest to what is being played.
  const factory TargetMode.auto() = AutoTargetMode;

  /// Stay on the string the player chose, however far off it is.
  const factory TargetMode.string(int index) = StringTargetMode;
}

/// Follows whatever is nearest.
@immutable
final class AutoTargetMode extends TargetMode {
  /// Creates the automatic mode.
  const AutoTargetMode();

  @override
  bool operator ==(Object other) => other is AutoTargetMode;

  @override
  int get hashCode => (AutoTargetMode).hashCode;
}

/// Locked to one string.
@immutable
final class StringTargetMode extends TargetMode {
  /// Locks to the string at [index], counting lowest-sounding first.
  const StringTargetMode(this.index);

  /// Which string, lowest-sounding first.
  final int index;

  @override
  bool operator ==(Object other) =>
      other is StringTargetMode && other.index == index;

  @override
  int get hashCode => index.hashCode;
}

/// Measures a frequency against the note it is meant to be.
///
/// Pure arithmetic over `core/music` — no audio, no state, no Flutter. The
/// interface renders what comes out of here and computes nothing of its own
/// (PRD.md §10, CLAUDE.md §8).
@immutable
final class TuningEngine {
  /// Creates an engine aiming through [selector].
  const TuningEngine({
    required this.selector,
    this.referenceHz = 440,
    this.toleranceCents = defaultToleranceCents,
  });

  /// How close counts as in tune.
  ///
  /// Three cents, matching the design system's TunerMeter. Well inside what a
  /// player can hear — around five cents on a sustained note — and wide
  /// enough that a real string, whose stiffness moves its own period, can
  /// actually reach it.
  static const double defaultToleranceCents = 3;

  /// How the target note is chosen.
  final TuningTargetSelector selector;

  /// What A4 is taken to be. PRD.md §10.2 makes this configurable.
  final double referenceHz;

  /// How far from the target still counts as in tune.
  final double toleranceCents;

  /// Reads [frequencyHz] against the target [mode] selects.
  ///
  /// Returns null when the mode names a string the tuning does not have, or
  /// when the frequency could not belong to any note at all.
  TunerReading? read({
    required double frequencyHz,
    required double confidence,
    TargetMode mode = const TargetMode.auto(),
    bool isSettled = false,
  }) {
    if (frequencyHz <= 0 || !frequencyHz.isFinite) return null;

    final target = switch (mode) {
      AutoTargetMode() => selector.nearestTo(
        frequencyHz,
        referenceHz: referenceHz,
      ),
      StringTargetMode(:final index) => selector.forString(index),
    };
    if (target == null) return null;

    final cents = target.pitch.centsFrom(frequencyHz, referenceHz: referenceHz);

    // What is actually sounding, which is not always the target. On a locked
    // string they diverge as soon as the player is tuning an A up to an E,
    // and the reading has to be honest about both.
    final detected = Pitch.tryNearestTo(
      frequencyHz,
      referenceHz: referenceHz,
    );
    if (detected == null) return null;

    return TunerReading(
      detectedNote: cents.abs() < 50 ? target.pitch : detected,
      frequencyHz: frequencyHz,
      targetNote: target.pitch,
      targetFrequencyHz: target.pitch.frequencyHz(referenceHz: referenceHz),
      cents: cents,
      confidence: confidence.clamp(0.0, 1.0),
      isInTune: cents.abs() <= toleranceCents,
      isSettled: isSettled,
      targetStringIndex: target.stringIndex,
    );
  }

  /// Returns a copy aiming through a different selector or reference.
  TuningEngine copyWith({
    TuningTargetSelector? selector,
    double? referenceHz,
    double? toleranceCents,
  }) => TuningEngine(
    selector: selector ?? this.selector,
    referenceHz: referenceHz ?? this.referenceHz,
    toleranceCents: toleranceCents ?? this.toleranceCents,
  );
}
