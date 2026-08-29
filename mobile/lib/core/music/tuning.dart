/// Guitar tunings, and the fret arithmetic that hangs off them.
///
/// A tuning is the ordered list of open-string pitches. Everything the
/// fretboard and the chord diagram need — which note a fret produces, how many
/// strings there are — is derived from it rather than hardcoded, so a custom
/// or seven-string tuning (PRD.md §10, §13) needs no new code.
///
/// Contains no Flutter. See docs/adr/0009.
library;

import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/pitch.dart';
import 'package:meta/meta.dart';

/// An ordered set of open-string pitches.
///
/// Strings are indexed **low to high**: index 0 is the lowest-sounding string,
/// the one drawn leftmost in a chord diagram and written first in a fret
/// array. This is the opposite of the guitarist's "sixth string" naming, and
/// it is stated here because getting it backwards silently mirrors every
/// diagram.
@immutable
final class Tuning {
  /// Creates a tuning from [openStrings], ordered lowest-sounding first.
  /// [openStrings] must not be empty; [pitchAt] range-checks every access.
  const Tuning({required this.name, required this.openStrings});

  /// Standard six-string tuning, E2 A2 D3 G3 B3 E4.
  static const Tuning standard = Tuning(
    name: 'standard',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.e), 2),
      Pitch(Note(NoteLetter.a), 2),
      Pitch(Note(NoteLetter.d), 3),
      Pitch(Note(NoteLetter.g), 3),
      Pitch(Note(NoteLetter.b), 3),
      Pitch(Note(NoteLetter.e), 4),
    ],
  );

  /// A stable identifier, not display copy. UI names come from the ARB files.
  final String name;

  /// Open-string pitches, lowest-sounding first.
  final List<Pitch> openStrings;

  /// How many strings the tuning has.
  int get stringCount => openStrings.length;

  /// The pitch sounded by [fret] on [stringIndex], counting the open string as
  /// fret 0.
  ///
  /// Throws [RangeError] for a string the tuning does not have, and
  /// [ArgumentError] for a negative fret.
  Pitch pitchAt({required int stringIndex, required int fret}) {
    if (stringIndex < 0 || stringIndex >= stringCount) {
      throw RangeError.index(stringIndex, openStrings, 'stringIndex');
    }
    if (fret < 0) {
      throw ArgumentError.value(fret, 'fret', 'must not be negative');
    }
    return openStrings[stringIndex].transposeChromatically(fret);
  }

  @override
  bool operator ==(Object other) =>
      other is Tuning &&
      other.name == name &&
      _sameStrings(other.openStrings, openStrings);

  @override
  int get hashCode => Object.hash(name, Object.hashAll(openStrings));

  static bool _sameStrings(List<Pitch> a, List<Pitch> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'Tuning($name: ${openStrings.map((p) => p.name).join(" ")})';
}
