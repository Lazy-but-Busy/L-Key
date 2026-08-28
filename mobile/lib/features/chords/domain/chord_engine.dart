/// Turns a chord into the shapes a guitarist can actually play.
///
/// Deterministic and Flutter-free (CLAUDE.md §10, §11). The same chord always
/// produces the same voicings in the same order, which is what makes the
/// exhaustive test over the whole catalogue meaningful — and what keeps an AI
/// feature out of a job that is arithmetic (CLAUDE.md §17).
///
/// See docs/adr/0010.
library;

import 'package:l_key/core/music/interval.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/chords/domain/chord.dart';
import 'package:l_key/features/chords/domain/chord_shape.dart';
import 'package:l_key/features/chords/domain/chord_voicing.dart';
import 'package:l_key/features/chords/domain/voicing_library.dart';

/// Why a voicing was rejected, or that it was not.
///
/// A named reason rather than a bare bool, because the test suite reports it
/// and a silent rejection would hide a broken shape.
enum VoicingProblem {
  /// Sounds a note that is not in the chord.
  foreignNote,

  /// Leaves out a tone the chord cannot do without.
  missingTone,

  /// Asks the hand to cover more than four frets.
  handSpan,

  /// Asks for more than four fingers.
  fingerCount,

  /// The barre does not line up with the strings it claims to hold.
  inconsistentBarre,

  /// The chord names a bass note that is not the lowest thing sounding.
  wrongBass,

  /// Sounds nothing at all.
  silent,
}

/// The chord engine.
///
/// Everything is a pure function of its arguments. There is no cache, no
/// state, and no reaching back into anything (docs/ARCHITECTURE.md).
abstract final class ChordEngine {
  /// How many voicings [voicingsFor] returns by default.
  static const int defaultMaxResults = 6;

  /// The highest base fret a movable shape is slid to.
  ///
  /// Past the twelfth fret a shape simply repeats an octave higher, so there
  /// is nothing new to show.
  static const int highestBaseFret = 12;

  /// Playable shapes for [chord], nearest the nut first.
  ///
  /// Curated open-position voicings come first, then movable shapes ordered by
  /// base fret. Every voicing returned has been through [problemWith]; a shape
  /// that does not spell the chord never reaches the interface.
  static List<ChordVoicing> voicingsFor(
    Chord chord, {
    Tuning tuning = Tuning.standard,
    int maxResults = defaultMaxResults,
  }) {
    final results = <ChordVoicing>[];

    if (chord.isSlash) {
      for (final slash in slashVoicings) {
        if (slash.root != chord.root ||
            slash.quality != chord.quality ||
            slash.bass != chord.bass) {
          continue;
        }
        final voicing = slash.toVoicing();
        if (problemWith(voicing, chord, tuning) == null) results.add(voicing);
      }
    }

    for (final open in openVoicings) {
      if (open.root != chord.root || open.quality != chord.quality) continue;
      final voicing = open.toVoicing();
      if (problemWith(voicing, chord, tuning) == null) results.add(voicing);
    }

    final movable = <ChordVoicing>[];
    for (final shape in movableShapes) {
      if (shape.quality != chord.quality) continue;
      final baseFret = _baseFretFor(shape, chord.root, tuning);
      if (baseFret == null) continue;
      for (final fret in <int>[
        baseFret,
        if (baseFret + 12 <= highestBaseFret) baseFret + 12,
      ]) {
        final voicing = shape.at(fret);
        if (problemWith(voicing, chord, tuning) != null) continue;
        if (results.contains(voicing) || movable.contains(voicing)) continue;
        movable.add(voicing);
      }
    }
    movable.sort((a, b) => a.lowestFret.compareTo(b.lowestFret));

    return <ChordVoicing>[
      ...results,
      ...movable,
    ].take(maxResults).toList(growable: false);
  }

  /// The fret that puts [shape]'s root string on [root], or null when the
  /// shape cannot reach it inside [highestBaseFret].
  static int? _baseFretFor(MovableShape shape, Note root, Tuning tuning) {
    if (shape.rootString >= tuning.stringCount) return null;
    final open = tuning.openStrings[shape.rootString];
    final distance = (root.pitchClass - open.midiNumber % 12 + 12) % 12;
    return distance <= highestBaseFret ? distance : null;
  }

  /// Why [voicing] does not spell [chord], or null when it does.
  ///
  /// This is the contract the whole shape library is held to. The test suite
  /// runs it over every catalogue entry, so a wrong fret in the data fails the
  /// build rather than teaching someone the wrong chord (CLAUDE.md §47).
  static VoicingProblem? problemWith(
    ChordVoicing voicing,
    Chord chord,
    Tuning tuning,
  ) {
    final sounding = voicing.soundingStrings.toList();
    if (sounding.isEmpty) return VoicingProblem.silent;

    final sounded = voicing.soundingPitchClasses(tuning);
    if (sounded.difference(chord.pitchClasses).isNotEmpty) {
      return VoicingProblem.foreignNote;
    }

    final omittable = chord.quality.omittableIntervals;
    for (final interval in chord.quality.intervals) {
      if (omittable.contains(interval)) continue;
      final note = chord.root.transposeBy(interval);
      if (!sounded.contains(note.pitchClass)) return VoicingProblem.missingTone;
    }

    if (voicing.fretSpan > 4) return VoicingProblem.handSpan;
    if (voicing.fingerCount > 4) return VoicingProblem.fingerCount;

    final barre = voicing.barre;
    if (barre != null) {
      if (barre.lowString >= barre.highString) {
        return VoicingProblem.inconsistentBarre;
      }
      for (final string in voicing.strings) {
        if (!barre.covers(string.stringIndex)) continue;
        final fret = string.soundingFret;
        if (fret != null && fret < barre.fret) {
          return VoicingProblem.inconsistentBarre;
        }
      }
    }

    final bass = chord.bass;
    if (bass != null) {
      final lowest = voicing.soundingPitches(tuning).first;
      if (lowest.midiNumber % 12 != bass.pitchClass) {
        return VoicingProblem.wrongBass;
      }
    }

    return null;
  }

  /// The interval each string sounds above the chord's root, null where muted.
  ///
  /// The diagram uses this to mark the root strings in Guitar Orange
  /// (DESIGN.md §25).
  static List<Interval?> intervalsPerString(
    ChordVoicing voicing,
    Chord chord,
    Tuning tuning,
  ) {
    final notes = voicing.soundingNotes(tuning, spelling: chord.notes);
    return <Interval?>[
      for (final note in notes)
        if (note == null) null else chord.intervalOf(note),
    ];
  }
}
