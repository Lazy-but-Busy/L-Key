import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/fretboard.dart';
import 'package:l_key/core/music/interval.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/scale.dart';
import 'package:l_key/core/music/tuning.dart';

/// Every fret on [string] carrying a position, for a quick shape comparison.
List<int> _fretsOn(List<FretPosition> positions, int string) => positions
    .where((p) => p.stringIndex == string)
    .map((p) => p.fret)
    .toList(growable: false);

void main() {
  group('FretRange', () {
    test('an inverted or negative range fails loudly', () {
      expect(
        () => FretRange(lowest: -1, highest: 5),
        throwsArgumentError,
      );
      expect(() => FretRange(lowest: 9, highest: 3), throwsArgumentError);
    });

    test('the range counts both ends and knows about the nut', () {
      final range = FretRange(lowest: 5, highest: 8);
      expect(range.length, 4);
      expect(range.contains(5), isTrue);
      expect(range.contains(8), isTrue);
      expect(range.contains(9), isFalse);
      expect(range.includesNut, isFalse);
      expect(FretRange.full.includesNut, isTrue);
    });
  });

  group('FretboardEngine.positions', () {
    test('A minor pentatonic in standard tuning is box 1 at frets 5 to 8', () {
      // DESIGN.md §25's diagram and the design system's ScalesScreen draw
      // exactly this shape. If the arithmetic is wrong, this is where it shows.
      const scale = Scale(Note(NoteLetter.a), ScaleType.minorPentatonic);
      final positions = FretboardEngine.positions(
        tuning: Tuning.standard,
        root: scale.root,
        intervals: scale.intervals,
        range: FretRange(lowest: 5, highest: 8),
      );

      expect(_fretsOn(positions, 0), <int>[5, 8]);
      expect(_fretsOn(positions, 1), <int>[5, 7]);
      expect(_fretsOn(positions, 2), <int>[5, 7]);
      expect(_fretsOn(positions, 3), <int>[5, 7]);
      expect(_fretsOn(positions, 4), <int>[5, 8]);
      expect(_fretsOn(positions, 5), <int>[5, 8]);
    });

    test('the roots of that box are the three the diagram lights up', () {
      const scale = Scale(Note(NoteLetter.a), ScaleType.minorPentatonic);
      final roots = FretboardEngine.positions(
        tuning: Tuning.standard,
        root: scale.root,
        intervals: scale.intervals,
        range: FretRange(lowest: 5, highest: 8),
      ).where((p) => p.isRoot).map((p) => '${p.stringIndex}:${p.fret}');

      // The low E at fret 5, the D string at fret 7 and the high E at fret 5 —
      // the three orange markers in the design system's ScalesScreen, whose
      // top-down string order is the mirror of the engine's.
      expect(roots, <String>['0:5', '2:7', '5:5']);
    });

    test('every position sounds a note the selection actually contains', () {
      final failures = <String>[];
      for (final tuning in Tuning.catalogue) {
        for (final type in ScaleType.values) {
          const root = Note(NoteLetter.d);
          final scale = Scale(root, type);
          if (!scale.isSpellable) continue;
          final wanted = scale.pitchClasses.toSet();
          for (final position in FretboardEngine.positions(
            tuning: tuning,
            root: root,
            intervals: scale.intervals,
          )) {
            if (!wanted.contains(position.pitch.note.pitchClass)) {
              failures.add('${tuning.name} ${type.slug}: $position');
            }
            if (position.pitch.note != position.note) {
              failures.add('${tuning.name} ${type.slug}: spelling disagrees');
            }
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('the note is spelled by the selection, not by the tuning', () {
      // The third fret of the A string sounds one pitch. In Eb major it is a
      // C; in B major the same sound is written B#.
      const flat = Scale(Note(NoteLetter.e, Accidental.flat), ScaleType.major);
      final inFlats = FretboardEngine.positions(
        tuning: Tuning.standard,
        root: flat.root,
        intervals: flat.intervals,
        range: FretRange(lowest: 6, highest: 6),
      ).firstWhere((p) => p.stringIndex == 0);
      expect(inFlats.note.name, 'Bb');

      const sharp = Scale(Note(NoteLetter.b), ScaleType.major);
      final inSharps = FretboardEngine.positions(
        tuning: Tuning.standard,
        root: sharp.root,
        intervals: sharp.intervals,
        range: FretRange(lowest: 6, highest: 6),
      ).firstWhere((p) => p.stringIndex == 0);
      expect(inSharps.note.name, 'A#');
    });

    test('the twelfth fret repeats the open string an octave up', () {
      final failures = <String>[];
      for (final tuning in Tuning.catalogue) {
        for (var string = 0; string < tuning.stringCount; string++) {
          final open = tuning.pitchAt(stringIndex: string, fret: 0);
          final twelfth = tuning.pitchAt(stringIndex: string, fret: 12);
          if (twelfth.midiNumber - open.midiNumber != 12) {
            failures.add('${tuning.name} string $string');
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('extended-range and bass necks are the same code path', () {
      // PRD.md §13 — 7-string, 8-string and bass, with no new positions typed.
      expect(Tuning.sevenString.stringCount, 7);
      expect(Tuning.eightString.stringCount, 8);
      expect(Tuning.bassFour.stringCount, 4);
      expect(Tuning.bassFive.stringCount, 5);

      const scale = Scale(Note(NoteLetter.e), ScaleType.minorPentatonic);
      for (final tuning in <Tuning>[
        Tuning.sevenString,
        Tuning.eightString,
        Tuning.bassFour,
        Tuning.bassFive,
      ]) {
        final strings = FretboardEngine.positions(
          tuning: tuning,
          root: scale.root,
          intervals: scale.intervals,
        ).map((p) => p.stringIndex).toSet();
        expect(strings.length, tuning.stringCount, reason: tuning.name);
      }

      // The seven-string's low B is a fourth below the six-string's low E.
      expect(
        Tuning.sevenString.openStrings.first.midiNumber,
        Tuning.standard.openStrings.first.midiNumber - 5,
      );
      // The eight-string adds another fourth below that.
      expect(
        Tuning.eightString.openStrings.first.midiNumber,
        Tuning.sevenString.openStrings.first.midiNumber - 5,
      );
    });

    test('an arpeggio is a chord quality on the same engine', () {
      // CLAUDE.md §4 — the fretboard reads ChordQuality rather than repeating
      // eighteen interval tables.
      final positions = FretboardEngine.positions(
        tuning: Tuning.standard,
        root: const Note(NoteLetter.a),
        intervals: ChordQuality.minorSeventh.intervals,
        range: FretRange(lowest: 5, highest: 8),
      );
      expect(
        positions.map((p) => p.degree.degree).toSet(),
        <String>{'1', 'b3', '5', 'b7'},
      );
      expect(_fretsOn(positions, 0), <int>[5, 8]);
    });

    test('the range is respected at both ends', () {
      final positions = FretboardEngine.positions(
        tuning: Tuning.standard,
        root: const Note(NoteLetter.c),
        intervals: ScaleType.major.intervals,
        range: FretRange(lowest: 3, highest: 7),
      );
      expect(positions.every((p) => p.fret >= 3 && p.fret <= 7), isTrue);
      expect(positions.any((p) => p.fret == 3), isTrue);
      expect(positions.any((p) => p.fret == 7), isTrue);
    });

    test('positions arrive ordered by string, then by fret', () {
      final positions = FretboardEngine.positions(
        tuning: Tuning.standard,
        root: const Note(NoteLetter.g),
        intervals: ScaleType.major.intervals,
      );
      for (var i = 1; i < positions.length; i++) {
        final previous = positions[i - 1];
        final current = positions[i];
        expect(
          current.stringIndex > previous.stringIndex ||
              (current.stringIndex == previous.stringIndex &&
                  current.fret > previous.fret),
          isTrue,
        );
      }
    });
  });

  group('FretboardEngine.allNotes', () {
    test('every fret of every string carries a note', () {
      final notes = FretboardEngine.allNotes(
        tuning: Tuning.standard,
        range: FretRange(lowest: 0, highest: 12),
      );
      expect(notes.length, 6 * 13);
    });

    test(
      'degrees are measured from the anchor and default to the low string',
      () {
        final fromE = FretboardEngine.allNotes(
          tuning: Tuning.standard,
          range: FretRange(lowest: 0, highest: 0),
        );
        expect(fromE.first.degree, Interval.unison);
        expect(fromE.first.isRoot, isTrue);

        final fromC = FretboardEngine.allNotes(
          tuning: Tuning.standard,
          range: FretRange(lowest: 0, highest: 0),
          root: const Note(NoteLetter.c),
        );
        expect(fromC.first.degree, Interval.majorThird);
        expect(fromC.first.isRoot, isFalse);
      },
    );

    test('flat spellings are available for a flat key', () {
      final sharps = FretboardEngine.allNotes(
        tuning: Tuning.standard,
        range: FretRange(lowest: 1, highest: 1),
      );
      expect(sharps.first.note.name, 'F');

      final flats = FretboardEngine.allNotes(
        tuning: Tuning.standard,
        range: FretRange(lowest: 2, highest: 2),
        preferFlats: true,
      );
      expect(flats.first.note.name, 'Gb');
    });
  });
}
