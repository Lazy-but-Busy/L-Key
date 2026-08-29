import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/chords/domain/chord.dart';
import 'package:l_key/features/chords/domain/chord_engine.dart';
import 'package:l_key/features/chords/domain/chord_quality.dart';
import 'package:l_key/features/chords/domain/chord_shape.dart';
import 'package:l_key/features/chords/domain/chord_voicing.dart';

/// The open C chord: x32010.
ChordVoicing get _openC => const ChordVoicing(
  strings: <FrettedString>[
    FrettedString.muted(0),
    FrettedString.at(1, 3, finger: 3),
    FrettedString.at(2, 2, finger: 2),
    FrettedString.open(3),
    FrettedString.at(4, 1, finger: 1),
    FrettedString.open(5),
  ],
);

void main() {
  group('FrettedString', () {
    test('an open string sounds at fret zero, a muted one not at all', () {
      const muted = FrettedString.muted(0);
      const open = FrettedString.open(1);
      const stopped = FrettedString.at(2, 3, finger: 3);

      expect(muted.sounds, isFalse);
      expect(muted.soundingFret, isNull);
      expect(open.sounds, isTrue);
      expect(open.soundingFret, 0);
      expect(stopped.soundingFret, 3);
      expect(stopped.finger, 3);
    });
  });

  group('ChordVoicing', () {
    test('reports its string states rather than guessing them', () {
      expect(_openC.mutedStrings, <int>[0]);
      expect(_openC.openStrings, <int>[3, 5]);
      expect(_openC.soundingStrings.length, 5);
      expect(_openC.fretString, 'x32010');
    });

    test('measures the hand, not the neck', () {
      expect(_openC.lowestFret, 1);
      expect(_openC.highestFret, 3);
      expect(_openC.fretSpan, 3);
      expect(_openC.fingerCount, 3);
    });

    test('an open chord draws the nut', () {
      expect(_openC.includesNut, isTrue);
      expect(_openC.baseFret, 0);
      expect(_openC.isOpenPosition, isTrue);
    });

    test('sounds the notes the tuning says it does', () {
      final notes = _openC.soundingNotes(Tuning.standard);
      expect(
        notes.map((note) => note?.name).toList(),
        <String?>[null, 'C', 'E', 'G', 'C', 'E'],
      );
    });

    test('spells its notes the way the chord does', () {
      // The third of C# major must print as E#, not F, even though the fret
      // arithmetic only knows the pitch class.
      const chord = Chord(
        root: Note(NoteLetter.c, Accidental.sharp),
        quality: ChordQuality.major,
      );
      final voicing = ChordEngine.voicingsFor(chord).first;
      final notes = voicing
          .soundingNotes(Tuning.standard, spelling: chord.notes)
          .whereType<Note>()
          .map((note) => note.name)
          .toSet();
      expect(notes, <String>{'C#', 'E#', 'G#'});
    });

    test('a fret above nine is written so it cannot be misread', () {
      final high = const MovableShape(
        name: 'E-shape',
        quality: ChordQuality.major,
        rootString: 0,
        offsets: <int>[0, 2, 2, 1, 0, 0],
        fingers: <int>[1, 3, 4, 2, 1, 1],
        barreToString: 5,
      ).at(10);
      expect(high.fretString, '10 12 12 11 10 10');
    });
  });

  group('Barre', () {
    test('covers an inclusive range of strings', () {
      const barre = Barre(fret: 1, lowString: 0, highString: 5);
      expect(barre.stringSpan, 6);
      expect(barre.covers(0), isTrue);
      expect(barre.covers(5), isTrue);
      expect(barre.covers(6), isFalse);
      expect(barre.finger, 1);
    });
  });

  group('MovableShape', () {
    const eShapeMajor = MovableShape(
      name: 'E-shape',
      quality: ChordQuality.major,
      rootString: 0,
      offsets: <int>[0, 2, 2, 1, 0, 0],
      fingers: <int>[1, 3, 4, 2, 1, 1],
      barreToString: 5,
    );

    test('slid up the neck it names a different chord each fret', () {
      expect(eShapeMajor.at(1).fretString, '133211');
      expect(eShapeMajor.at(3).fretString, '355433');
      expect(eShapeMajor.at(8).fretString, '8 10 10 9 8 8');
    });

    test('at the nut the barre becomes open strings', () {
      // Otherwise the diagram draws a finger laid across the nut.
      final open = eShapeMajor.at(0);
      expect(open.barre, isNull);
      expect(open.fretString, '022100');
      expect(open.openStrings, <int>[0, 4, 5]);
      expect(open.strings[0].finger, isNull);
    });

    test('above the nut the barre is described, not inferred', () {
      final barred = eShapeMajor.at(5);
      expect(barred.barre, isNotNull);
      expect(barred.barre!.fret, 5);
      expect(barred.barre!.lowString, 0);
      expect(barred.barre!.highString, 5);
      expect(barred.baseFret, 5);
      expect(barred.includesNut, isFalse);
    });
  });
}
