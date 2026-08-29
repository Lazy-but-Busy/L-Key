/// The CAGED system: five major-chord shapes that tile the whole neck.
///
/// CAGED is one observation dressed up as a system — every major chord on a
/// six-string guitar in standard tuning is one of the five open shapes C, A,
/// G, E or D, moved. So the data here is five open chords, and everything else
/// is the arithmetic that slides them: a shape whose open form spells its own
/// letter sits, for root R, at the fret that carries its letter to R.
///
/// Five hand-written shapes rather than a derivation, because a shape is a
/// *fingering* and the fingerings are the thing being taught (PRD.md §15).
/// They are not trusted, though: [CagedEngine.problemWith] is run over every
/// position the engine returns, and the test suite runs it over all twelve
/// roots, the same way `ChordEngine.problemWith` guards the chord catalogue
/// (docs/adr/0010).
///
/// Contains no Flutter. See docs/adr/0011.
library;

import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/fretboard.dart';
import 'package:l_key/core/music/interval.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/pitch.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:meta/meta.dart';

/// Fret offset marking a string a CAGED shape does not play.
const int cagedMutedString = -1;

/// The five shapes, in the order the acronym names them.
enum CagedShape {
  /// The open C shape — x 3 2 0 1 0, root on the fifth string.
  c('C', 0, <int>[cagedMutedString, 3, 2, 0, 1, 0]),

  /// The open A shape — x 0 2 2 2 0, root on the fifth string.
  a('A', 9, <int>[cagedMutedString, 0, 2, 2, 2, 0]),

  /// The open G shape — 3 2 0 0 0 3, root on the sixth string.
  g('G', 7, <int>[3, 2, 0, 0, 0, 3]),

  /// The open E shape — 0 2 2 1 0 0, root on the sixth string.
  e('E', 4, <int>[0, 2, 2, 1, 0, 0]),

  /// The open D shape — x x 0 2 3 2, root on the fourth string.
  d('D', 2, <int>[cagedMutedString, cagedMutedString, 0, 2, 3, 2]);

  const CagedShape(this.letter, this.openRootPitchClass, this.openFrets);

  /// The letter the shape is named after. A stable id, not display copy.
  final String letter;

  /// Pitch class of the chord the shape spells in its open position.
  final int openRootPitchClass;

  /// The open form's frets, one per string, lowest-sounding first.
  ///
  /// [cagedMutedString] for a string the shape does not play. Sliding the
  /// shape adds the same number to every played entry, which is what makes a
  /// barre chord a moved open chord.
  final List<int> openFrets;

  /// How far up the neck the shape must move to spell [root].
  int shiftFor(Note root) => (root.pitchClass - openRootPitchClass + 12) % 12;
}

/// One CAGED shape placed on the neck for a particular root.
@immutable
final class CagedPosition {
  /// Creates a placed shape.
  const CagedPosition({
    required this.shape,
    required this.root,
    required this.shift,
    required this.range,
    required this.tones,
  });

  /// Which of the five shapes this is.
  final CagedShape shape;

  /// The chord it spells.
  final Note root;

  /// How many frets the open shape moved to get here. 0 is the open position.
  final int shift;

  /// The frets the shape occupies.
  final FretRange range;

  /// Every chord tone under the hand, ordered by string then fret.
  final List<FretPosition> tones;

  @override
  String toString() =>
      'CagedPosition(${shape.letter} shape, ${root.name}, $range)';
}

/// What can be wrong with a placed CAGED shape.
enum CagedProblem {
  /// A string sounds a note that is not in the chord.
  foreignNote,

  /// The shape does not sound the root, the third or the fifth.
  missingTone,

  /// The shape spans more frets than a hand covers.
  handSpan,
}

/// Places the five shapes on the neck.
abstract final class CagedEngine {
  /// The furthest a shape may reach and still be a position rather than a
  /// stretch. Four frets, as `ChordEngine` uses for a chord voicing.
  static const int maxSpan = 4;

  /// The five shapes for [root], ordered up the neck.
  ///
  /// The order is a rotation of C-A-G-E-D that depends on the root: for C it
  /// reads C-A-G-E-D, for B it reads A-G-E-D-C. That is the point of the
  /// system — whichever shape you are in, the next one up the neck is the next
  /// letter round the cycle.
  ///
  /// Returns empty for anything but a six-string tuning. CAGED is a statement
  /// about standard tuning and it is not true of a bass or a seven-string;
  /// inventing an answer there would be a lie the interface then teaches
  /// (CLAUDE.md §47).
  static List<CagedPosition> positionsFor({
    required Note root,
    Tuning tuning = Tuning.standard,
    int maxFret = 15,
  }) {
    if (tuning != Tuning.standard) return const <CagedPosition>[];

    final placed = <CagedPosition>[];
    for (final shape in CagedShape.values) {
      final position = _place(
        shape: shape,
        root: root,
        tuning: tuning,
        maxFret: maxFret,
      );
      if (position == null) continue;
      if (problemWith(position, tuning) != null) continue;
      placed.add(position);
    }
    placed.sort((a, b) => a.range.lowest.compareTo(b.range.lowest));
    return placed;
  }

  /// The first thing wrong with [position], or null when it is sound.
  ///
  /// Data has typos a compiler cannot see. This is what stops a mistyped
  /// fret in the five-shape table from reaching a screen and teaching a
  /// guitarist a chord that is not the chord (docs/adr/0010).
  static CagedProblem? problemWith(CagedPosition position, Tuning tuning) {
    final chordClasses = <int>{
      for (final interval in ChordQuality.major.intervals)
        (position.root.pitchClass + interval.semitones) % 12,
    };

    final sounded = <int>{};
    for (final tone in position.tones) {
      // Read the string and fret through the tuning rather than trusting the
      // note the position carries. A mistyped fret would otherwise agree with
      // itself and the check would pass over a chord that is not the chord.
      final actual = tuning
          .pitchAt(stringIndex: tone.stringIndex, fret: tone.fret)
          .note
          .pitchClass;
      if (!chordClasses.contains(actual)) return CagedProblem.foreignNote;
      if (actual != tone.note.pitchClass) return CagedProblem.foreignNote;
      sounded.add(actual);
    }
    if (sounded.length < chordClasses.length) return CagedProblem.missingTone;

    final stopped = position.tones.where((t) => t.fret > 0).map((t) => t.fret);
    if (stopped.isNotEmpty) {
      final low = stopped.reduce((a, b) => a < b ? a : b);
      final high = stopped.reduce((a, b) => a > b ? a : b);
      if (high - low + 1 > maxSpan) return CagedProblem.handSpan;
    }
    return null;
  }

  /// Slides [shape] to [root] and reads the notes under it.
  static CagedPosition? _place({
    required CagedShape shape,
    required Note root,
    required Tuning tuning,
    required int maxFret,
  }) {
    if (shape.openFrets.length != tuning.stringCount) return null;
    final shift = shape.shiftFor(root);

    final tones = <FretPosition>[];
    for (var string = 0; string < shape.openFrets.length; string++) {
      final open = shape.openFrets[string];
      if (open == cagedMutedString) continue;
      final fret = open + shift;
      if (fret > maxFret) return null;
      final pitch = tuning.pitchAt(stringIndex: string, fret: fret);
      final degree = _degreeOf(root, pitch);
      if (degree == null) return null;
      tones.add(
        FretPosition(
          stringIndex: string,
          fret: fret,
          pitch: Pitch(root.transposeBy(degree), pitch.octave),
          note: root.transposeBy(degree),
          degree: degree,
        ),
      );
    }
    if (tones.isEmpty) return null;

    final frets = tones.map((t) => t.fret);
    return CagedPosition(
      shape: shape,
      root: root,
      shift: shift,
      range: FretRange(
        lowest: frets.reduce((a, b) => a < b ? a : b),
        highest: frets.reduce((a, b) => a > b ? a : b),
      ),
      tones: tones,
    );
  }

  /// Which degree of the major triad on [root] the pitch sounds, or null.
  static Interval? _degreeOf(Note root, Pitch pitch) {
    for (final interval in ChordQuality.major.intervals) {
      if ((root.pitchClass + interval.semitones) % 12 ==
          pitch.note.pitchClass) {
        return interval;
      }
    }
    return null;
  }
}
