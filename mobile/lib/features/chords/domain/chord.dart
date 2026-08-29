/// A chord: a spelled root, a quality, and optionally a bass note.
///
/// The chord knows its own notes and formula and nothing about the guitar.
/// Fretboard shapes live in `chord_voicing.dart` and `chord_engine.dart`, so
/// this type is equally usable from the song transposer, the fretboard, or a
/// backend that never draws anything (CLAUDE.md §10).
///
/// Contains no Flutter. See docs/adr/0009.
library;

import 'package:l_key/core/music/interval.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/features/chords/domain/chord_quality.dart';
import 'package:meta/meta.dart';

/// A chord, deterministically spelled from its root and quality.
@immutable
final class Chord {
  /// Creates a chord on [root] with the given [quality].
  ///
  /// [bass] makes it a slash chord such as `C/G`. It may be a chord tone (an
  /// inversion) or a note from outside the chord (`C/D`); both are legal and
  /// [bassIsChordTone] tells them apart.
  const Chord({required this.root, required this.quality, this.bass});

  /// The root, spelled. `Db` and `C#` are different chords here.
  final Note root;

  /// The interval formula the chord is built from.
  final ChordQuality quality;

  /// The note that must sound lowest, or null for root position.
  final Note? bass;

  /// The chord's notes, spelled, in formula order starting at the root.
  ///
  /// Derived by adding each of the quality's intervals to the root, which is
  /// what makes `C#maj7` come out as C# E# G# B# rather than as a set of
  /// enharmonic near-misses.
  List<Note> get notes =>
      quality.intervals.map(root.transposeBy).toList(growable: false);

  /// The pitch classes the chord sounds, without duplicates.
  ///
  /// Includes [bass] when it is not already a chord tone, because `C/D` really
  /// does sound a D.
  Set<int> get pitchClasses => <int>{
    ...notes.map((note) => note.pitchClass),
    if (bass != null) bass!.pitchClass,
  };

  /// The interval formula as it is printed in the interface, e.g. `1 b3 5 b7`.
  String get intervalFormula =>
      quality.intervals.map((interval) => interval.degree).join(' ');

  /// The chord symbol, e.g. `C`, `Am7`, `C#m7b5/G`.
  String get symbol {
    final buffer = StringBuffer('${root.name}${quality.symbol}');
    if (bass != null) buffer.write('/${bass!.name}');
    return buffer.toString();
  }

  /// The chord symbol using typographic accidentals, e.g. `C♯m7♭5/G`.
  String get displaySymbol {
    final suffix = quality.symbol.replaceAll('b5', '♭5').replaceAll('#5', '♯5');
    final buffer = StringBuffer('${root.displayName}$suffix');
    if (bass != null) buffer.write('/${bass!.displayName}');
    return buffer.toString();
  }

  /// Whether the chord names a bass note at all.
  bool get isSlash => bass != null;

  /// Whether the named bass is one of the chord's own notes.
  ///
  /// True for `C/G`, an inversion. False for `C/D`, which adds a tone.
  bool get bassIsChordTone =>
      bass != null && notes.any((note) => note.pitchClass == bass!.pitchClass);

  /// The same chord [semitones] higher, respelled chromatically.
  ///
  /// Used by the capo assistant and the song transposer (PRD.md §21–22).
  /// [preferFlats] chooses the spelling of the black keys; the quality and the
  /// bass relationship are preserved exactly.
  Chord transpose(int semitones, {bool preferFlats = false}) => Chord(
    root: root.transposeChromatically(semitones, preferFlats: preferFlats),
    quality: quality,
    bass: bass?.transposeChromatically(semitones, preferFlats: preferFlats),
  );

  /// The interval of [note] above the root, or null if it is not a chord tone.
  ///
  /// The chord diagram labels each string with this.
  Interval? intervalOf(Note note) {
    final chordNotes = notes;
    for (var i = 0; i < chordNotes.length; i++) {
      if (chordNotes[i].pitchClass == note.pitchClass) {
        return quality.intervals[i];
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is Chord &&
      other.root == root &&
      other.quality == quality &&
      other.bass == bass;

  @override
  int get hashCode => Object.hash(root, quality, bass);

  @override
  String toString() => symbol;
}
