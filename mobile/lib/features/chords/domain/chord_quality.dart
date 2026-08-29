/// The chord qualities the library ships, each as an interval formula.
///
/// Every quality is a list of spelled intervals above the root. Nothing here
/// is a chord *shape* — that is `chord_shape.dart`'s job. Keeping the formula
/// separate is what lets a new quality be a data-only change (CLAUDE.md §11).
///
/// Contains no Flutter. See docs/adr/0009.
library;

import 'package:l_key/core/music/interval.dart';

/// A chord quality: the interval formula that turns a root into a chord.
///
/// PRD.md §11 names fourteen. Four more are here because a chord library
/// without them cannot spell real songs: guitar notation writes `dim` when it
/// means `dim7`, `m7b5` is unavoidable in a minor key, and `m6` and `7sus4`
/// appear constantly in the repertoire.
enum ChordQuality {
  /// Major triad — 1 3 5.
  major('', 'major'),

  /// Minor triad — 1 b3 5.
  minor('m', 'minor'),

  /// Dominant seventh — 1 3 5 b7.
  dominantSeventh('7', '7'),

  /// Major seventh — 1 3 5 7.
  majorSeventh('maj7', 'maj7'),

  /// Minor seventh — 1 b3 5 b7.
  minorSeventh('m7', 'm7'),

  /// Major sixth — 1 3 5 6.
  sixth('6', '6'),

  /// Dominant ninth — 1 3 5 b7 9.
  ninth('9', '9'),

  /// Major ninth — 1 3 5 7 9.
  majorNinth('maj9', 'maj9'),

  /// Minor ninth — 1 b3 5 b7 9.
  minorNinth('m9', 'm9'),

  /// Suspended second — 1 2 5.
  suspendedSecond('sus2', 'sus2'),

  /// Suspended fourth — 1 4 5.
  suspendedFourth('sus4', 'sus4'),

  /// Added ninth — 1 3 5 9, with no seventh.
  addedNinth('add9', 'add9'),

  /// Diminished triad — 1 b3 b5.
  diminished('dim', 'dim'),

  /// Augmented triad — 1 3 #5.
  augmented('aug', 'aug'),

  /// Diminished seventh — 1 b3 b5 bb7.
  diminishedSeventh('dim7', 'dim7'),

  /// Half-diminished seventh — 1 b3 b5 b7.
  halfDiminished('m7b5', 'm7b5'),

  /// Minor sixth — 1 b3 5 6.
  minorSixth('m6', 'm6'),

  /// Dominant seventh suspended fourth — 1 4 5 b7.
  seventhSuspendedFourth('7sus4', '7sus4');

  const ChordQuality(this.symbol, this.slug);

  /// The suffix written after the root, such as `m7` in `Am7`.
  ///
  /// Major is the empty string, because a major chord is written `C`.
  final String symbol;

  /// A URL-safe identifier used in route paths and catalogue ids.
  final String slug;

  /// The intervals above the root, in formula order.
  List<Interval> get intervals => switch (this) {
    ChordQuality.major => <Interval>[
      Interval.unison,
      Interval.majorThird,
      Interval.perfectFifth,
    ],
    ChordQuality.minor => <Interval>[
      Interval.unison,
      Interval.minorThird,
      Interval.perfectFifth,
    ],
    ChordQuality.dominantSeventh => <Interval>[
      Interval.unison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
    ],
    ChordQuality.majorSeventh => <Interval>[
      Interval.unison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.majorSeventh,
    ],
    ChordQuality.minorSeventh => <Interval>[
      Interval.unison,
      Interval.minorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
    ],
    ChordQuality.sixth => <Interval>[
      Interval.unison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.majorSixth,
    ],
    ChordQuality.ninth => <Interval>[
      Interval.unison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
      Interval.majorNinth,
    ],
    ChordQuality.majorNinth => <Interval>[
      Interval.unison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.majorSeventh,
      Interval.majorNinth,
    ],
    ChordQuality.minorNinth => <Interval>[
      Interval.unison,
      Interval.minorThird,
      Interval.perfectFifth,
      Interval.minorSeventh,
      Interval.majorNinth,
    ],
    ChordQuality.suspendedSecond => <Interval>[
      Interval.unison,
      Interval.majorSecond,
      Interval.perfectFifth,
    ],
    ChordQuality.suspendedFourth => <Interval>[
      Interval.unison,
      Interval.perfectFourth,
      Interval.perfectFifth,
    ],
    ChordQuality.addedNinth => <Interval>[
      Interval.unison,
      Interval.majorThird,
      Interval.perfectFifth,
      Interval.majorNinth,
    ],
    ChordQuality.diminished => <Interval>[
      Interval.unison,
      Interval.minorThird,
      Interval.diminishedFifth,
    ],
    ChordQuality.augmented => <Interval>[
      Interval.unison,
      Interval.majorThird,
      Interval.augmentedFifth,
    ],
    ChordQuality.diminishedSeventh => <Interval>[
      Interval.unison,
      Interval.minorThird,
      Interval.diminishedFifth,
      Interval.diminishedSeventh,
    ],
    ChordQuality.halfDiminished => <Interval>[
      Interval.unison,
      Interval.minorThird,
      Interval.diminishedFifth,
      Interval.minorSeventh,
    ],
    ChordQuality.minorSixth => <Interval>[
      Interval.unison,
      Interval.minorThird,
      Interval.perfectFifth,
      Interval.majorSixth,
    ],
    ChordQuality.seventhSuspendedFourth => <Interval>[
      Interval.unison,
      Interval.perfectFourth,
      Interval.perfectFifth,
      Interval.minorSeventh,
    ],
  };

  /// Intervals a six-string voicing may leave out.
  ///
  /// The rule is one line: **the perfect fifth is omittable from a chord of
  /// four or more tones; an altered fifth never is.** Six strings and four
  /// fingers cannot carry a five-note chord, and the fifth is the tone the ear
  /// supplies for itself — the open C7 every chord book prints is x32310,
  /// which has no G in it. Drop the ♭5 from a dim7, by contrast, and the
  /// result is a minor sixth chord, not a dim7 with a missing note.
  List<Interval> get omittableIntervals {
    final tones = intervals;
    final hasPerfectFifth = tones.contains(Interval.perfectFifth);
    return tones.length >= 4 && hasPerfectFifth
        ? <Interval>[Interval.perfectFifth]
        : const <Interval>[];
  }

  /// Alternative spellings accepted when parsing a chord symbol.
  ///
  /// Ordered longest-first by the parser, so `maj7` is never read as `m` plus
  /// a leftover `aj7`.
  List<String> get aliases => switch (this) {
    ChordQuality.major => <String>['maj', 'M', 'Δ'],
    ChordQuality.minor => <String>['min', '-'],
    ChordQuality.dominantSeventh => <String>['dom7'],
    ChordQuality.majorSeventh => <String>['M7', 'Δ7', 'ma7'],
    ChordQuality.minorSeventh => <String>['min7', '-7'],
    ChordQuality.sixth => <String>['maj6', 'M6'],
    ChordQuality.ninth => <String>['dom9'],
    ChordQuality.majorNinth => <String>['M9', 'Δ9'],
    ChordQuality.minorNinth => <String>['min9', '-9'],
    ChordQuality.suspendedSecond => <String>['sus9'],
    ChordQuality.suspendedFourth => <String>['sus'],
    ChordQuality.addedNinth => <String>['add2'],
    ChordQuality.diminished => <String>['°', 'o'],
    ChordQuality.augmented => <String>['+'],
    ChordQuality.diminishedSeventh => <String>['°7', 'o7'],
    ChordQuality.halfDiminished => <String>['ø', 'ø7', 'min7b5', '-7b5'],
    ChordQuality.minorSixth => <String>['min6', '-6'],
    ChordQuality.seventhSuspendedFourth => <String>['7sus'],
  };
}
