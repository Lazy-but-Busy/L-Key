/// Playable regions of the neck — boxes and three-notes-per-string patterns.
///
/// Nothing here is stored. A "box" is not a table of dots; it is a fret window
/// with a property, and the property is what the code looks for: **every
/// string carries at least two of the scale's notes**. Search the neck for the
/// windows with that property and the five pentatonic boxes every guitarist
/// knows come back, in order, for any root and any tuning — including a
/// seven-string, an eight-string and a bass, which no hand-typed table would
/// have covered.
///
/// Contains no Flutter. See docs/adr/0011.
library;

import 'package:l_key/core/music/fretboard.dart';
import 'package:l_key/core/music/interval.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/pitch.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:meta/meta.dart';

/// How a pattern was derived.
enum ScalePatternKind {
  /// A fret window with at least two notes on every string.
  box,

  /// Exactly three notes on every string, running up the neck.
  threeNotesPerString,
}

/// One playable region of the neck.
@immutable
final class ScalePosition {
  /// Creates a position.
  const ScalePosition({
    required this.index,
    required this.kind,
    required this.range,
    required this.positions,
  });

  /// Which position this is, one-based and ascending up the neck.
  final int index;

  /// How it was derived.
  final ScalePatternKind kind;

  /// The frets it spans.
  final FretRange range;

  /// The notes inside it, ordered by string then fret.
  final List<FretPosition> positions;

  @override
  String toString() => 'ScalePosition($index, ${kind.name}, $range)';
}

/// Finds the playable regions of a scale on a neck.
abstract final class ScalePatternEngine {
  /// The highest fret the search will look at by default.
  ///
  /// Twenty-two is the shortest neck the product needs to serve; past it a
  /// pattern only repeats an octave higher and there is nothing new to show,
  /// which is the same reason `ChordEngine` stops movable shapes at twelve.
  static const int defaultMaxFret = 22;

  /// Fewest notes a string must carry for a window to count as a box.
  static const int _minNotesPerString = 2;

  /// The boxes of the scale defined by [root] and [intervals].
  ///
  /// One box per degree, ordered up the neck: box *i* is the window whose
  /// lowest note on the lowest string is the *i*th degree. For A minor
  /// pentatonic in standard tuning that is frets 5–8, 7–10, 9–13, 12–15 and
  /// 14–17 — the five shapes as they are taught, third box included, which is
  /// the wide one no fixed window length would have found.
  ///
  /// Returns empty for a scale with no shape to find: the chromatic scale
  /// fills every window equally, so a "box" would mean nothing (CLAUDE.md §47
  /// — better an empty state than an invented one).
  static List<ScalePosition> boxes({
    required Tuning tuning,
    required Note root,
    required List<Interval> intervals,
    int maxFret = defaultMaxFret,
  }) {
    if (intervals.length >= 12) return const <ScalePosition>[];

    // Four frets for a five- or six-note scale, five for a seven- or
    // eight-note one: the extra note per string needs the extra fret. A box
    // may grow past that when it has to — the pentatonic's third box really
    // does span five frets — but never past a hand's reach.
    final shortest = intervals.length <= 6 ? 4 : 5;
    final longest = shortest + 2;

    final classes = <int>[
      for (final interval in intervals)
        (root.pitchClass + interval.semitones) % 12,
    ];

    final found = <ScalePosition>[];
    // Box 1 holds the root on the lowest string, and each box after it is the
    // next degree further up — so the anchors ascend rather than wrapping back
    // to the nut. Without the cursor, A minor pentatonic's fourth box would be
    // reported at the open E instead of at the twelfth fret.
    var cursor = 0;
    for (var degree = 0; degree < intervals.length; degree++) {
      final anchor = _lowestFretOf(
        tuning: tuning,
        stringIndex: 0,
        pitchClass: classes[degree],
        from: cursor,
      );
      cursor = anchor + 1;

      // The window must open on this degree, so it may not reach back far
      // enough to swallow the degree below it on the lowest string — that
      // window belongs to the previous box.
      final below = classes[(degree - 1 + classes.length) % classes.length];
      final floor = _highestFretBelow(
        tuning: tuning,
        stringIndex: 0,
        pitchClass: below,
        limit: anchor,
      );

      final range = _windowAt(
        tuning: tuning,
        root: root,
        intervals: intervals,
        anchor: anchor,
        floor: floor + 1,
        shortest: shortest,
        longest: longest,
      );
      if (range.highest > maxFret) continue;
      found.add(
        ScalePosition(
          index: degree + 1,
          kind: ScalePatternKind.box,
          range: range,
          positions: FretboardEngine.positions(
            tuning: tuning,
            root: root,
            intervals: intervals,
            range: range,
          ),
        ),
      );
    }
    return found;
  }

  /// The shortest window that starts on [anchor]'s degree and gives every
  /// string enough of the scale.
  ///
  /// Searched from the shortest length upward and, at each length, from the
  /// lowest allowed start upward, so consecutive boxes overlap as much as they
  /// can and a player can slide from one into the next. [floor] is the first
  /// fret the window may open at — one above the previous degree on the lowest
  /// string, so a box never swallows the box below it.
  ///
  /// Falls back to the shortest window at the anchor when nothing qualifies,
  /// so a box always exists rather than a degree silently vanishing from the
  /// position list.
  static FretRange _windowAt({
    required Tuning tuning,
    required Note root,
    required List<Interval> intervals,
    required int anchor,
    required int floor,
    required int shortest,
    required int longest,
  }) {
    for (var length = shortest; length <= longest; length++) {
      for (var start = floor < 0 ? 0 : floor; start <= anchor; start++) {
        final range = FretRange(lowest: start, highest: start + length - 1);
        if (_qualifies(
          tuning: tuning,
          root: root,
          intervals: intervals,
          range: range,
        )) {
          return range;
        }
      }
    }
    return FretRange(lowest: anchor, highest: anchor + shortest - 1);
  }

  /// The three-notes-per-string patterns of a seven-note scale.
  ///
  /// Pattern *i* starts on the *i*th degree on the lowest string and then
  /// simply keeps going: three notes per string, each one the next note of the
  /// scale above the last. Returns empty for anything but a seven-note scale,
  /// where the idea does not apply.
  static List<ScalePosition> threeNotesPerString({
    required Tuning tuning,
    required Note root,
    required List<Interval> intervals,
    int maxFret = defaultMaxFret,
  }) {
    if (intervals.length != 7) return const <ScalePosition>[];

    final classes = <int>[
      for (final interval in intervals)
        (root.pitchClass + interval.semitones) % 12,
    ];
    final spelling = <int, Note>{
      for (final interval in intervals)
        (root.pitchClass + interval.semitones) % 12: root.transposeBy(interval),
    };
    final degrees = <int, Interval>{
      for (final interval in intervals)
        (root.pitchClass + interval.semitones) % 12: interval,
    };

    final found = <ScalePosition>[];
    for (var start = 0; start < 7; start++) {
      final picked = <FretPosition>[];
      var step = start;
      var floor = 0;
      var ok = true;

      for (var string = 0; string < tuning.stringCount && ok; string++) {
        for (var n = 0; n < 3; n++) {
          final wanted = classes[step % 7];
          final fret = _lowestFretOf(
            tuning: tuning,
            stringIndex: string,
            pitchClass: wanted,
            from: floor,
          );
          if (fret > maxFret) {
            ok = false;
            break;
          }
          final sounded = tuning.pitchAt(stringIndex: string, fret: fret);
          picked.add(
            FretPosition(
              stringIndex: string,
              fret: fret,
              pitch: Pitch(spelling[wanted]!, sounded.octave),
              note: spelling[wanted]!,
              degree: degrees[wanted]!,
            ),
          );
          floor = fret + 1;
          step += 1;
        }
        // The next string picks up above the last note played, not above the
        // fret it was played at — otherwise the pattern drifts up the neck.
        if (string + 1 < tuning.stringCount) {
          floor = _fretSounding(
            tuning: tuning,
            stringIndex: string + 1,
            atLeast: picked.last.pitch,
          );
        }
      }

      if (!ok || picked.isEmpty) continue;
      final frets = picked.map((p) => p.fret);
      found.add(
        ScalePosition(
          index: start + 1,
          kind: ScalePatternKind.threeNotesPerString,
          range: FretRange(
            lowest: frets.reduce((a, b) => a < b ? a : b),
            highest: frets.reduce((a, b) => a > b ? a : b),
          ),
          positions: picked,
        ),
      );
    }
    return found;
  }

  /// Whether every string carries enough of the scale inside [range].
  static bool _qualifies({
    required Tuning tuning,
    required Note root,
    required List<Interval> intervals,
    required FretRange range,
  }) {
    final counts = List<int>.filled(tuning.stringCount, 0);
    for (final position in FretboardEngine.positions(
      tuning: tuning,
      root: root,
      intervals: intervals,
      range: range,
    )) {
      counts[position.stringIndex] += 1;
    }
    return counts.every((count) => count >= _minNotesPerString);
  }

  /// The lowest fret at or above [from] on [stringIndex] sounding [pitchClass].
  static int _lowestFretOf({
    required Tuning tuning,
    required int stringIndex,
    required int pitchClass,
    int from = 0,
  }) {
    final open = tuning.openStrings[stringIndex].note.pitchClass;
    final offset = (pitchClass - open - from + 1200) % 12;
    return from + offset;
  }

  /// The highest fret below [limit] on [stringIndex] sounding [pitchClass].
  ///
  /// Can go negative, which reads as "the note below this one is behind the
  /// nut" and leaves the window free to open at fret 0.
  static int _highestFretBelow({
    required Tuning tuning,
    required int stringIndex,
    required int pitchClass,
    required int limit,
  }) {
    final open = tuning.openStrings[stringIndex].note.pitchClass;
    final offset = (limit - 1 - pitchClass + open + 1200) % 12;
    return limit - 1 - offset;
  }

  /// The lowest fret on [stringIndex] that sounds at or above [atLeast].
  static int _fretSounding({
    required Tuning tuning,
    required int stringIndex,
    required Pitch atLeast,
  }) {
    final open = tuning.openStrings[stringIndex];
    final distance = atLeast.midiNumber - open.midiNumber;
    return distance < 0 ? 0 : distance;
  }
}
