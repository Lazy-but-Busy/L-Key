/// What the tuner is aiming at.
///
/// Contains no Flutter. See docs/adr/0013.
library;

import 'package:l_key/core/music/pitch.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:meta/meta.dart';

/// A note to tune towards, and which string it is if it is one.
@immutable
final class TuningTarget {
  /// Creates a target.
  const TuningTarget({required this.pitch, this.stringIndex});

  /// The note being aimed at, spelled as the tuning spells it.
  final Pitch pitch;

  /// Which string, or null in chromatic mode.
  final int? stringIndex;

  @override
  bool operator ==(Object other) =>
      other is TuningTarget &&
      other.pitch == pitch &&
      other.stringIndex == stringIndex;

  @override
  int get hashCode => Object.hash(pitch, stringIndex);

  @override
  String toString() => 'TuningTarget(${pitch.name}, string $stringIndex)';
}

/// Picks the note a frequency should be measured against.
abstract interface class TuningTargetSelector {
  /// The nearest target to [frequencyHz].
  TuningTarget nearestTo(double frequencyHz, {double referenceHz});

  /// The target for one string, or null if there is no such string.
  TuningTarget? forString(int index);

  /// How many strings there are to choose between. Zero in chromatic mode.
  int get stringCount;
}

/// Aims at the open strings of one tuning.
///
/// The spelling matters and comes from the tuning, not from the frequency.
/// Half-step-down is written with flats because that is how players write and
/// say it, so its lowest string must read E♭2 and never D♯2 — which only
/// works because a `Pitch` is a spelled letter rather than a number
/// (docs/adr/0009).
@immutable
final class StringTargetSelector implements TuningTargetSelector {
  /// Aims at [tuning]'s open strings.
  const StringTargetSelector(this.tuning);

  /// The tuning whose strings are on offer.
  final Tuning tuning;

  @override
  int get stringCount => tuning.stringCount;

  @override
  TuningTarget? forString(int index) => index < 0 || index >= tuning.stringCount
      ? null
      : TuningTarget(pitch: tuning.openStrings[index], stringIndex: index);

  @override
  TuningTarget nearestTo(double frequencyHz, {double referenceHz = 440}) {
    var bestIndex = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < tuning.stringCount; i++) {
      final distance = tuning.openStrings[i]
          .centsFrom(frequencyHz, referenceHz: referenceHz)
          .abs();
      // Strictly less, so a frequency exactly between two strings takes the
      // lower index rather than depending on iteration order.
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return TuningTarget(
      pitch: tuning.openStrings[bestIndex],
      stringIndex: bestIndex,
    );
  }
}

/// Aims at the nearest note of the chromatic scale, whatever it is.
///
/// PRD.md §10.2 lists chromatic tuning as a Premium capability. It has no
/// strings, so nothing selects one and nothing is highlighted.
@immutable
final class ChromaticTargetSelector implements TuningTargetSelector {
  /// Creates a chromatic selector.
  const ChromaticTargetSelector({this.preferFlats = false});

  /// Whether to name the black keys with flats.
  ///
  /// A frequency cannot choose: 277.18 Hz is C♯4 and D♭4 equally
  /// (docs/adr/0009).
  final bool preferFlats;

  @override
  int get stringCount => 0;

  @override
  TuningTarget? forString(int index) => null;

  @override
  TuningTarget nearestTo(double frequencyHz, {double referenceHz = 440}) =>
      TuningTarget(
        pitch: Pitch.nearestTo(
          frequencyHz,
          referenceHz: referenceHz,
          preferFlats: preferFlats,
        ),
      );
}
