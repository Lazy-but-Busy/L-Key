/// Scales, modes and their degree formulas.
///
/// A scale is a root plus an ordered set of spelled intervals, exactly as a
/// chord quality is (`chord_quality.dart`). That is the whole model: nothing
/// here stores notes, fret positions or patterns, because all three are
/// derivable and a stored copy is a second source of truth waiting to drift
/// (CLAUDE.md §12).
///
/// Degrees are spelled, not counted. Lydian's fourth is a ♯4 and Locrian's
/// fifth is a ♭5, and both span six semitones — F Lydian is F G A B C D E, and
/// writing that B as a C♭ would give the scale two Cs and no B. This is the
/// same reason `Note` is a letter and an accidental (docs/adr/0009).
///
/// Contains no Flutter. See docs/adr/0011.
library;

import 'package:l_key/core/music/interval.dart';
import 'package:l_key/core/music/note.dart';
import 'package:meta/meta.dart';

/// How a scale is grouped in the interface.
///
/// Purely a browsing aid — it carries no musical meaning the formula does not
/// already carry, and nothing in the engine branches on it.
enum ScaleCategory {
  /// The major scale and its pentatonic.
  major,

  /// The minor scales and the minor pentatonic.
  minor,

  /// The seven modes of the major scale.
  mode,

  /// Five-note scales.
  pentatonic,

  /// The blues scale.
  blues,

  /// Scales built from a repeating interval pattern rather than a key.
  symmetric,
}

/// A scale, as the interval formula that turns a root into a set of notes.
///
/// PRD.md §14 names five free scales and eleven Premium ones. All sixteen are
/// here, plus Ionian and Aeolian — a modes list that omits two of the seven
/// teaches the modes wrongly, and they cost one enum entry each.
enum ScaleType {
  /// Major — 1 2 3 4 5 6 7.
  major('major', ScaleCategory.major),

  /// Natural minor — 1 2 b3 4 5 b6 b7.
  naturalMinor('natural-minor', ScaleCategory.minor),

  /// Harmonic minor — 1 2 b3 4 5 b6 7.
  harmonicMinor('harmonic-minor', ScaleCategory.minor),

  /// Melodic minor, ascending — 1 2 b3 4 5 6 7.
  melodicMinor('melodic-minor', ScaleCategory.minor),

  /// Ionian — the major scale under its modal name.
  ionian('ionian', ScaleCategory.mode),

  /// Dorian — 1 2 b3 4 5 6 b7.
  dorian('dorian', ScaleCategory.mode),

  /// Phrygian — 1 b2 b3 4 5 b6 b7.
  phrygian('phrygian', ScaleCategory.mode),

  /// Lydian — 1 2 3 #4 5 6 7.
  lydian('lydian', ScaleCategory.mode),

  /// Mixolydian — 1 2 3 4 5 6 b7.
  mixolydian('mixolydian', ScaleCategory.mode),

  /// Aeolian — the natural minor under its modal name.
  aeolian('aeolian', ScaleCategory.mode),

  /// Locrian — 1 b2 b3 4 b5 b6 b7.
  locrian('locrian', ScaleCategory.mode),

  /// Major pentatonic — 1 2 3 5 6.
  majorPentatonic('major-pentatonic', ScaleCategory.pentatonic),

  /// Minor pentatonic — 1 b3 4 5 b7.
  minorPentatonic('minor-pentatonic', ScaleCategory.pentatonic),

  /// Blues — the minor pentatonic with the ♭5 passing tone.
  blues('blues', ScaleCategory.blues),

  /// Whole tone — 1 2 3 #4 #5 #6, six notes a tone apart.
  wholeTone('whole-tone', ScaleCategory.symmetric),

  /// Diminished, whole-half — 1 2 b3 4 b5 b6 bb7 7.
  diminishedWholeHalf('diminished-whole-half', ScaleCategory.symmetric),

  /// Diminished, half-whole — 1 b2 #2 3 #4 5 6 b7.
  diminishedHalfWhole('diminished-half-whole', ScaleCategory.symmetric),

  /// Chromatic — all twelve notes.
  chromatic('chromatic', ScaleCategory.symmetric);

  const ScaleType(this.slug, this.category);

  /// A URL-safe identifier used in route paths and catalogue ids.
  final String slug;

  /// How the scale is grouped in the interface.
  final ScaleCategory category;

  /// The intervals above the root, in ascending order.
  ///
  /// Every entry starts at [Interval.unison] so a formula reads the way a
  /// player writes it — `1 b3 4 5 b7`, not `b3 4 5 b7`.
  List<Interval> get intervals => switch (this) {
    ScaleType.major || ScaleType.ionian => <Interval>[
      Interval.unison,
      Interval.majorSecond,
      Interval.majorThird,
      Interval.perfectFourth,
      Interval.perfectFifth,
      Interval.majorSixth,
      Interval.majorSeventh,
    ],
    ScaleType.naturalMinor || ScaleType.aeolian => <Interval>[
      Interval.unison,
      Interval.majorSecond,
      Interval.minorThird,
      Interval.perfectFourth,
      Interval.perfectFifth,
      Interval.minorSixth,
      Interval.minorSeventh,
    ],
    ScaleType.harmonicMinor => <Interval>[
      Interval.unison,
      Interval.majorSecond,
      Interval.minorThird,
      Interval.perfectFourth,
      Interval.perfectFifth,
      Interval.minorSixth,
      Interval.majorSeventh,
    ],
    ScaleType.melodicMinor => <Interval>[
      Interval.unison,
      Interval.majorSecond,
      Interval.minorThird,
      Interval.perfectFourth,
      Interval.perfectFifth,
      Interval.majorSixth,
      Interval.majorSeventh,
    ],
    ScaleType.dorian => <Interval>[
      Interval.unison,
      Interval.majorSecond,
      Interval.minorThird,
      Interval.perfectFourth,
      Interval.perfectFifth,
      Interval.majorSixth,
      Interval.minorSeventh,
    ],
    ScaleType.phrygian => <Interval>[
      Interval.unison,
      Interval.minorSecond,
      Interval.minorThird,
      Interval.perfectFourth,
      Interval.perfectFifth,
      Interval.minorSixth,
      Interval.minorSeventh,
    ],
    ScaleType.lydian => <Interval>[
      Interval.unison,
      Interval.majorSecond,
      Interval.majorThird,
      Interval.augmentedFourth,
      Interval.perfectFifth,
      Interval.majorSixth,
      Interval.majorSeventh,
    ],
    ScaleType.mixolydian => <Interval>[
      Interval.unison,
      Interval.majorSecond,
      Interval.majorThird,
      Interval.perfectFourth,
      Interval.perfectFifth,
      Interval.majorSixth,
      Interval.minorSeventh,
    ],
    ScaleType.locrian => <Interval>[
      Interval.unison,
      Interval.minorSecond,
      Interval.minorThird,
      Interval.perfectFourth,
      Interval.diminishedFifth,
      Interval.minorSixth,
      Interval.minorSeventh,
    ],
    ScaleType.majorPentatonic => <Interval>[
      Interval.unison,
      Interval.majorSecond,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.majorSixth,
    ],
    ScaleType.minorPentatonic => <Interval>[
      Interval.unison,
      Interval.minorThird,
      Interval.perfectFourth,
      Interval.perfectFifth,
      Interval.minorSeventh,
    ],
    ScaleType.blues => <Interval>[
      Interval.unison,
      Interval.minorThird,
      Interval.perfectFourth,
      Interval.diminishedFifth,
      Interval.perfectFifth,
      Interval.minorSeventh,
    ],
    ScaleType.wholeTone => <Interval>[
      Interval.unison,
      Interval.majorSecond,
      Interval.majorThird,
      Interval.augmentedFourth,
      Interval.augmentedFifth,
      Interval.augmentedSixth,
    ],
    ScaleType.diminishedWholeHalf => <Interval>[
      Interval.unison,
      Interval.majorSecond,
      Interval.minorThird,
      Interval.perfectFourth,
      Interval.diminishedFifth,
      Interval.minorSixth,
      Interval.diminishedSeventh,
      Interval.majorSeventh,
    ],
    ScaleType.diminishedHalfWhole => <Interval>[
      Interval.unison,
      Interval.minorSecond,
      Interval.augmentedSecond,
      Interval.majorThird,
      Interval.augmentedFourth,
      Interval.perfectFifth,
      Interval.majorSixth,
      Interval.minorSeventh,
    ],
    ScaleType.chromatic => <Interval>[
      Interval.unison,
      Interval.augmentedUnison,
      Interval.majorSecond,
      Interval.augmentedSecond,
      Interval.majorThird,
      Interval.perfectFourth,
      Interval.augmentedFourth,
      Interval.perfectFifth,
      Interval.augmentedFifth,
      Interval.majorSixth,
      Interval.augmentedSixth,
      Interval.majorSeventh,
    ],
  };

  /// How many notes the scale has before it repeats.
  int get noteCount => intervals.length;

  /// The degree formula as a player writes it, such as `1 b3 4 5 b7`.
  String get formula => intervals.map((i) => i.degree).join(' ');
}

/// A scale in a key: a root note and a [ScaleType].
@immutable
final class Scale {
  /// Creates a scale on [root].
  const Scale(this.root, this.type);

  /// The note the formula is measured from.
  final Note root;

  /// The formula itself.
  final ScaleType type;

  /// The intervals above [root], in ascending order.
  List<Interval> get intervals => type.intervals;

  /// The degree formula, such as `1 b3 4 5 b7`.
  String get formula => type.formula;

  /// Whether every degree of this scale has a spelling on this root.
  ///
  /// Almost always true, and false exactly where a musician would change the
  /// root's spelling rather than the scale's: A♯ whole tone needs an F triple
  /// sharp for its ♯6, which is why the scale is written B♭ whole tone. The
  /// catalogue offers only spellable roots (`features/fretboard/data/`), so
  /// nothing in the interface can reach an unspellable one.
  bool get isSpellable =>
      intervals.every((i) => root.tryTransposeBy(i) != null);

  /// The notes of the scale, spelled, ascending from [root].
  ///
  /// Throws [ArgumentError] when [isSpellable] is false.
  List<Note> get notes =>
      intervals.map(root.transposeBy).toList(growable: false);

  /// The pitch classes the scale occupies, 0–11.
  ///
  /// Order follows [intervals]; duplicates are impossible because no formula
  /// here names the same pitch class twice.
  List<int> get pitchClasses => intervals
      .map((i) => (root.pitchClass + i.semitones) % 12)
      .toList(growable: false);

  /// Whether [note] sounds in this scale, regardless of how it is spelled.
  bool contains(Note note) => pitchClasses.contains(note.pitchClass);

  /// The degree [note] occupies, or null when it is outside the scale.
  ///
  /// Matches by sound rather than by spelling, so a G♯ query finds the A♭ of
  /// a flat-spelled scale. The interval returned is the scale's own, so the
  /// answer is still spelled correctly.
  Interval? intervalOf(Note note) {
    final classes = pitchClasses;
    final index = classes.indexOf(note.pitchClass);
    return index == -1 ? null : intervals[index];
  }

  /// The same formula moved [semitones] up, respelled chromatically.
  Scale transpose(int semitones, {bool preferFlats = false}) => Scale(
    root.transposeChromatically(semitones, preferFlats: preferFlats),
    type,
  );

  /// This scale rotated to start on its [degree]th note, or null when the
  /// rotation is not a scale this catalogue names.
  ///
  /// `Scale(C, major).modeAt(2)` is D dorian: the same seven notes, a
  /// different tonic. [degree] is one-based, so `modeAt(1)` returns an
  /// equivalent of this scale.
  ///
  /// Returns null rather than throwing for a rotation with no name — the
  /// second mode of the blues scale is a real set of notes and not a scale
  /// anyone calls anything (CLAUDE.md §37).
  Scale? modeAt(int degree) {
    if (degree < 1 || degree > intervals.length) return null;
    if (!isSpellable) return null;

    final offsets = intervals.map((i) => i.semitones).toList();
    final shift = offsets[degree - 1];
    final rotated = <int>[
      for (var i = 0; i < offsets.length; i++)
        (offsets[(i + degree - 1) % offsets.length] - shift + 12) % 12,
    ]..sort();

    final newRoot = notes[degree - 1];
    // Same category first, so a mode of a mode keeps its modal name: the sixth
    // mode of C Ionian is A Aeolian, not the identically-sounding A natural
    // minor a `ScaleType.values` walk would reach first.
    for (final sameCategory in <bool>[true, false]) {
      for (final candidate in ScaleType.values) {
        if ((candidate.category == type.category) != sameCategory) continue;
        final theirs = candidate.intervals.map((i) => i.semitones).toList()
          ..sort();
        if (_sameInts(theirs, rotated)) return Scale(newRoot, candidate);
      }
    }
    return null;
  }

  static bool _sameInts(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is Scale && other.root == root && other.type == type;

  @override
  int get hashCode => Object.hash(root, type);

  @override
  String toString() => '${root.name} ${type.slug}';
}
