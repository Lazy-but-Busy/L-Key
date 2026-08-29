import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/features/chords/domain/chord.dart';
import 'package:l_key/features/chords/domain/chord_symbol.dart';

List<String> _names(Chord chord) =>
    chord.notes.map((note) => note.name).toList();

void main() {
  group('Chord spelling', () {
    test('every quality spells correctly on C', () {
      const expected = <ChordQuality, List<String>>{
        ChordQuality.major: <String>['C', 'E', 'G'],
        ChordQuality.minor: <String>['C', 'Eb', 'G'],
        ChordQuality.dominantSeventh: <String>['C', 'E', 'G', 'Bb'],
        ChordQuality.majorSeventh: <String>['C', 'E', 'G', 'B'],
        ChordQuality.minorSeventh: <String>['C', 'Eb', 'G', 'Bb'],
        ChordQuality.sixth: <String>['C', 'E', 'G', 'A'],
        ChordQuality.ninth: <String>['C', 'E', 'G', 'Bb', 'D'],
        ChordQuality.majorNinth: <String>['C', 'E', 'G', 'B', 'D'],
        ChordQuality.minorNinth: <String>['C', 'Eb', 'G', 'Bb', 'D'],
        ChordQuality.suspendedSecond: <String>['C', 'D', 'G'],
        ChordQuality.suspendedFourth: <String>['C', 'F', 'G'],
        ChordQuality.addedNinth: <String>['C', 'E', 'G', 'D'],
        ChordQuality.diminished: <String>['C', 'Eb', 'Gb'],
        ChordQuality.augmented: <String>['C', 'E', 'G#'],
        ChordQuality.diminishedSeventh: <String>['C', 'Eb', 'Gb', 'Bbb'],
        ChordQuality.halfDiminished: <String>['C', 'Eb', 'Gb', 'Bb'],
        ChordQuality.minorSixth: <String>['C', 'Eb', 'G', 'A'],
        ChordQuality.seventhSuspendedFourth: <String>['C', 'F', 'G', 'Bb'],
      };
      expect(
        expected.keys.length,
        ChordQuality.values.length,
        reason: 'a new quality needs a spelling here',
      );
      expected.forEach((quality, notes) {
        final chord = Chord(root: const Note(NoteLetter.c), quality: quality);
        expect(_names(chord), notes, reason: chord.symbol);
      });
    });

    test('sharp roots keep their sharp spellings', () {
      // C#maj7 is C# E# G# B#. Spelling it C# F G# C would be four different
      // letters for the same four sounds and unreadable on a stave.
      const cSharpMaj7 = Chord(
        root: Note(NoteLetter.c, Accidental.sharp),
        quality: ChordQuality.majorSeventh,
      );
      expect(_names(cSharpMaj7), <String>['C#', 'E#', 'G#', 'B#']);

      const gSharpMinor = Chord(
        root: Note(NoteLetter.g, Accidental.sharp),
        quality: ChordQuality.minor,
      );
      expect(_names(gSharpMinor), <String>['G#', 'B', 'D#']);
    });

    test('flat roots keep their flat spellings', () {
      const dFlatMaj7 = Chord(
        root: Note(NoteLetter.d, Accidental.flat),
        quality: ChordQuality.majorSeventh,
      );
      expect(_names(dFlatMaj7), <String>['Db', 'F', 'Ab', 'C']);
    });

    test('enharmonic roots make different chords that sound alike', () {
      const cSharp = Chord(
        root: Note(NoteLetter.c, Accidental.sharp),
        quality: ChordQuality.major,
      );
      const dFlat = Chord(
        root: Note(NoteLetter.d, Accidental.flat),
        quality: ChordQuality.major,
      );
      expect(_names(cSharp), <String>['C#', 'E#', 'G#']);
      expect(_names(dFlat), <String>['Db', 'F', 'Ab']);
      expect(cSharp, isNot(dFlat));
      expect(cSharp.pitchClasses, dFlat.pitchClasses);
    });

    test('diminished sevenths need double flats', () {
      // The reason the note model carries double accidentals at all.
      const eFlat = Chord(
        root: Note(NoteLetter.e, Accidental.flat),
        quality: ChordQuality.diminishedSeventh,
      );
      expect(_names(eFlat), <String>['Eb', 'Gb', 'Bbb', 'Dbb']);

      const gSharp = Chord(
        root: Note(NoteLetter.g, Accidental.sharp),
        quality: ChordQuality.diminishedSeventh,
      );
      expect(_names(gSharp), <String>['G#', 'B', 'D', 'F']);
    });

    test('formulas read the way PRD.md §11 writes them', () {
      Chord chord(ChordQuality quality) =>
          Chord(root: const Note(NoteLetter.c), quality: quality);
      expect(chord(ChordQuality.major).intervalFormula, '1 3 5');
      expect(chord(ChordQuality.minor).intervalFormula, '1 b3 5');
      expect(chord(ChordQuality.dominantSeventh).intervalFormula, '1 3 5 b7');
      expect(chord(ChordQuality.halfDiminished).intervalFormula, '1 b3 b5 b7');
      expect(
        chord(ChordQuality.diminishedSeventh).intervalFormula,
        '1 b3 b5 bb7',
      );
      expect(chord(ChordQuality.minorNinth).intervalFormula, '1 b3 5 b7 9');
    });

    test('an interval can be recovered from a note', () {
      const chord = Chord(
        root: Note(NoteLetter.a),
        quality: ChordQuality.minorSeventh,
      );
      expect(chord.intervalOf(const Note(NoteLetter.a))?.degree, '1');
      expect(chord.intervalOf(const Note(NoteLetter.c))?.degree, 'b3');
      expect(chord.intervalOf(const Note(NoteLetter.g))?.degree, 'b7');
      expect(chord.intervalOf(const Note(NoteLetter.f)), isNull);
    });
  });

  group('Chord transposition', () {
    test('a chord keeps its quality and its bass relationship', () {
      // PRD.md §21 — transposing must preserve slash chords.
      const chord = Chord(
        root: Note(NoteLetter.a),
        quality: ChordQuality.minorSeventh,
        bass: Note(NoteLetter.g),
      );
      final up = chord.transpose(2);
      expect(up.symbol, 'Bm7/A');
      expect(up.quality, ChordQuality.minorSeventh);
    });

    test('transposition wraps past B and can go down', () {
      const b = Chord(
        root: Note(NoteLetter.b),
        quality: ChordQuality.major,
      );
      expect(b.transpose(1).symbol, 'C');
      expect(b.transpose(-1).symbol, 'A#');
      expect(b.transpose(12).symbol, 'B');
    });

    test('flat keys can be asked for', () {
      const c = Chord(
        root: Note(NoteLetter.c),
        quality: ChordQuality.major,
      );
      expect(c.transpose(1).symbol, 'C#');
      expect(c.transpose(1, preferFlats: true).symbol, 'Db');
    });
  });

  group('Chord symbols', () {
    test('round-trips every quality on every catalogue root', () {
      const roots = <String>[
        'C',
        'C#',
        'Db',
        'D',
        'D#',
        'Eb',
        'E',
        'F',
        'F#',
        'Gb',
        'G',
        'G#',
        'Ab',
        'A',
        'A#',
        'Bb',
        'B',
      ];
      for (final root in roots) {
        for (final quality in ChordQuality.values) {
          final chord = Chord(root: Note.tryParse(root)!, quality: quality);
          expect(
            ChordSymbol.tryParse(chord.symbol),
            chord,
            reason: '${chord.symbol} did not survive a round trip',
          );
        }
      }
    });

    test('reads the spellings other people write', () {
      expect(ChordSymbol.tryParse('CM7')?.quality, ChordQuality.majorSeventh);
      expect(ChordSymbol.tryParse('CΔ7')?.quality, ChordQuality.majorSeventh);
      expect(ChordSymbol.tryParse('Cmaj7')?.quality, ChordQuality.majorSeventh);
      expect(ChordSymbol.tryParse('C-7')?.quality, ChordQuality.minorSeventh);
      expect(ChordSymbol.tryParse('Cmin7')?.quality, ChordQuality.minorSeventh);
      expect(
        ChordSymbol.tryParse('C°7')?.quality,
        ChordQuality.diminishedSeventh,
      );
      expect(ChordSymbol.tryParse('Cø')?.quality, ChordQuality.halfDiminished);
      expect(ChordSymbol.tryParse('C+')?.quality, ChordQuality.augmented);
      expect(
        ChordSymbol.tryParse('Csus')?.quality,
        ChordQuality.suspendedFourth,
      );
    });

    test('reads unicode accidentals in the root and the quality', () {
      expect(ChordSymbol.tryParse('C♯m7♭5')?.symbol, 'C#m7b5');
      expect(ChordSymbol.tryParse('E♭maj7')?.symbol, 'Ebmaj7');
    });

    test('reads slash chords, including a bass outside the chord', () {
      final inversion = ChordSymbol.tryParse('C/G');
      expect(inversion?.bass?.name, 'G');
      expect(inversion?.bassIsChordTone, isTrue);

      final added = ChordSymbol.tryParse('C/D');
      expect(added?.bass?.name, 'D');
      expect(added?.bassIsChordTone, isFalse);

      expect(ChordSymbol.tryParse('D/F#')?.symbol, 'D/F#');
    });

    test('unreadable input returns null rather than throwing', () {
      // CLAUDE.md §37 — song content and search boxes both reach this.
      for (final bad in <String>[
        '',
        'H',
        'Cwobble',
        'C/',
        'C/H',
        '7',
        'Cmaj77',
        '/G',
      ]) {
        expect(
          ChordSymbol.tryParse(bad),
          isNull,
          reason: '"$bad" is not a chord',
        );
      }
    });

    test('display symbols use typographic accidentals', () {
      expect(ChordSymbol.tryParse('C#m7b5/G')?.displaySymbol, 'C♯m7♭5/G');
      expect(ChordSymbol.tryParse('Bb')?.displaySymbol, 'B♭');
    });
  });
}
