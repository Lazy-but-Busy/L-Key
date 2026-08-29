/// The fretboard, calculated rather than tabulated.
///
/// There is no table of note positions anywhere in this file. A tuning knows
/// what each open string sounds; a fret adds a semitone; everything else falls
/// out of arithmetic (CLAUDE.md §13). That is what makes a seven-string, an
/// eight-string, a bass and a custom tuning the same code path, and it is why
/// adding a tuning is a data change with no new positions to type or to get
/// wrong.
///
/// The engine returns *facts*: which string, which fret, which pitch, which
/// spelled note, which degree of the selection. Nothing here decides colour,
/// size or layout — the widget renders what it is given (CLAUDE.md §8).
///
/// Contains no Flutter. See docs/adr/0011.
library;

import 'package:l_key/core/music/interval.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/pitch.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:meta/meta.dart';

/// An inclusive span of frets, with 0 meaning the open string.
@immutable
final class FretRange {
  /// Creates a range from [lowest] to [highest], both inclusive.
  ///
  /// Throws [ArgumentError] for a negative low fret or an inverted range,
  /// because either one silently produces an empty neck.
  FretRange({required this.lowest, required this.highest}) {
    if (lowest < 0) {
      throw ArgumentError.value(lowest, 'lowest', 'must not be negative');
    }
    if (highest < lowest) {
      throw ArgumentError.value(highest, 'highest', 'must not be below lowest');
    }
  }

  /// The nut to the fifteenth fret — the default view.
  ///
  /// Fifteen rather than twelve or twenty-four: twelve cuts off the octave
  /// repeat a player checks a pattern against, and twenty-four is unreadable
  /// on a phone. DESIGN.md §25 draws a technical neck, not a full instrument.
  static final FretRange full = FretRange(lowest: 0, highest: 15);

  /// Lowest fret in the range. 0 is the open string.
  final int lowest;

  /// Highest fret in the range, inclusive.
  final int highest;

  /// How many frets the range covers, counting both ends.
  int get length => highest - lowest + 1;

  /// Whether [fret] falls inside the range.
  bool contains(int fret) => fret >= lowest && fret <= highest;

  /// Whether the range starts at the nut, so the open strings are in view.
  bool get includesNut => lowest == 0;

  @override
  bool operator ==(Object other) =>
      other is FretRange && other.lowest == lowest && other.highest == highest;

  @override
  int get hashCode => Object.hash(lowest, highest);

  @override
  String toString() => 'FretRange($lowest–$highest)';
}

/// One place on the neck, and what it means.
@immutable
final class FretPosition {
  /// Creates a position.
  const FretPosition({
    required this.stringIndex,
    required this.fret,
    required this.pitch,
    required this.note,
    required this.degree,
  });

  /// Which string, **lowest-sounding first** — `Tuning`'s convention, which is
  /// the opposite of the guitarist's "sixth string". Stated here because
  /// getting it backwards silently mirrors the whole neck.
  final int stringIndex;

  /// Which fret, with 0 meaning the open string.
  final int fret;

  /// The pitch the position sounds, octave included.
  final Pitch pitch;

  /// The note as the *selection* spells it.
  ///
  /// Not as the tuning spells it: in E♭ major the third fret of the A string
  /// is a C, and in the key of B it is the same sound written B♯. The
  /// selection owns the spelling (docs/adr/0009).
  final Note note;

  /// Which degree of the selection this position is — `1`, `b3`, `5`.
  final Interval degree;

  /// Whether this position sounds the selection's root.
  bool get isRoot => degree.number == 1 && degree.semitones == 0;

  @override
  bool operator ==(Object other) =>
      other is FretPosition &&
      other.stringIndex == stringIndex &&
      other.fret == fret &&
      other.note == note;

  @override
  int get hashCode => Object.hash(stringIndex, fret, note);

  @override
  String toString() => 'FretPosition(s$stringIndex f$fret ${note.name})';
}

/// Turns a tuning and a set of degrees into positions on the neck.
abstract final class FretboardEngine {
  /// Every position in [range] that sounds one of [intervals] above [root].
  ///
  /// The selection is expressed as a root and a degree list rather than as a
  /// scale or a chord, so one method serves a scale, a mode, an arpeggio and a
  /// CAGED shape alike. `Scale.intervals` and `ChordQuality.intervals` both
  /// fit it without an adapter.
  ///
  /// Positions come back ordered by string, then by fret, which is the order a
  /// diagram draws them and the order a screen reader should hear them.
  ///
  /// Throws [ArgumentError] when a degree cannot be spelled on [root] — the
  /// same loud failure `Note.transposeBy` gives, because a selection that
  /// cannot be written is a bug in the caller, not a user's mistake.
  static List<FretPosition> positions({
    required Tuning tuning,
    required Note root,
    required List<Interval> intervals,
    FretRange? range,
  }) {
    final window = range ?? FretRange.full;

    // One pass over the selection builds the lookup; the neck walk is then a
    // map read per fret rather than a search.
    final spelling = <int, Note>{};
    final degrees = <int, Interval>{};
    for (final interval in intervals) {
      final pitchClass = (root.pitchClass + interval.semitones) % 12;
      // First spelling wins. Only the chromatic and diminished formulas name
      // two degrees a semitone apart that could collide, and they do not.
      spelling.putIfAbsent(pitchClass, () => root.transposeBy(interval));
      degrees.putIfAbsent(pitchClass, () => interval);
    }

    final found = <FretPosition>[];
    for (var string = 0; string < tuning.stringCount; string++) {
      for (var fret = window.lowest; fret <= window.highest; fret++) {
        final pitch = tuning.pitchAt(stringIndex: string, fret: fret);
        final pitchClass = pitch.note.pitchClass;
        final note = spelling[pitchClass];
        if (note == null) continue;
        found.add(
          FretPosition(
            stringIndex: string,
            fret: fret,
            pitch: Pitch(note, pitch.octave),
            note: note,
            degree: degrees[pitchClass]!,
          ),
        );
      }
    }
    return found;
  }

  /// Every note on the neck, for the plain note map.
  ///
  /// Degrees are measured from [root], which defaults to the lowest open
  /// string so the labels mean something even when no scale is selected.
  static List<FretPosition> allNotes({
    required Tuning tuning,
    FretRange? range,
    Note? root,
    bool preferFlats = false,
  }) {
    final anchor = root ?? tuning.openStrings.first.note;
    final chromatic = <Interval>[
      for (var semitone = 0; semitone < 12; semitone++)
        _chromaticDegree(semitone),
    ];
    final window = range ?? FretRange.full;

    final found = <FretPosition>[];
    for (var string = 0; string < tuning.stringCount; string++) {
      for (var fret = window.lowest; fret <= window.highest; fret++) {
        final pitch = tuning.pitchAt(stringIndex: string, fret: fret);
        final semitones = (pitch.note.pitchClass - anchor.pitchClass + 12) % 12;
        final note = Note.fromPitchClass(
          pitch.note.pitchClass,
          preferFlats: preferFlats,
        );
        found.add(
          FretPosition(
            stringIndex: string,
            fret: fret,
            pitch: Pitch(note, pitch.octave),
            note: note,
            degree: chromatic[semitones],
          ),
        );
      }
    }
    return found;
  }

  /// The degree notation the note-map view labels a semitone distance with.
  ///
  /// Sharp-side spellings throughout, because the note map has no key to take
  /// its accidentals from.
  static Interval _chromaticDegree(int semitones) => switch (semitones) {
    0 => Interval.unison,
    1 => Interval.augmentedUnison,
    2 => Interval.majorSecond,
    3 => Interval.augmentedSecond,
    4 => Interval.majorThird,
    5 => Interval.perfectFourth,
    6 => Interval.augmentedFourth,
    7 => Interval.perfectFifth,
    8 => Interval.augmentedFifth,
    9 => Interval.majorSixth,
    10 => Interval.augmentedSixth,
    _ => Interval.majorSeventh,
  };
}
