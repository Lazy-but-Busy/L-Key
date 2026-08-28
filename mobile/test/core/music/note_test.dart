import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/interval.dart';
import 'package:l_key/core/music/note.dart';

void main() {
  group('Note', () {
    test('pitch class folds the accidental into the letter', () {
      expect(const Note(NoteLetter.c).pitchClass, 0);
      expect(const Note(NoteLetter.c, Accidental.sharp).pitchClass, 1);
      expect(const Note(NoteLetter.d, Accidental.flat).pitchClass, 1);
      expect(const Note(NoteLetter.b, Accidental.sharp).pitchClass, 0);
      expect(const Note(NoteLetter.c, Accidental.flat).pitchClass, 11);
      expect(const Note(NoteLetter.b, Accidental.doubleFlat).pitchClass, 9);
      expect(const Note(NoteLetter.f, Accidental.doubleSharp).pitchClass, 7);
    });

    test('enharmonic notes are equal in sound and not in identity', () {
      const cSharp = Note(NoteLetter.c, Accidental.sharp);
      const dFlat = Note(NoteLetter.d, Accidental.flat);
      expect(cSharp.isEnharmonicWith(dFlat), isTrue);
      expect(cSharp, isNot(dFlat));
      expect(cSharp.hashCode, isNot(dFlat.hashCode));
    });

    test('transposing by an interval keeps the letter the interval names', () {
      // C plus a minor third is E flat, never D sharp — this is the property
      // the whole spelling model exists for (CLAUDE.md §10).
      const c = Note(NoteLetter.c);
      expect(c.transposeBy(Interval.minorThird).name, 'Eb');
      expect(c.transposeBy(Interval.majorThird).name, 'E');
      expect(c.transposeBy(Interval.augmentedFifth).name, 'G#');
      expect(c.transposeBy(Interval.diminishedFifth).name, 'Gb');

      const cSharp = Note(NoteLetter.c, Accidental.sharp);
      expect(cSharp.transposeBy(Interval.minorThird).name, 'E');
      expect(cSharp.transposeBy(Interval.majorThird).name, 'E#');
      expect(cSharp.transposeBy(Interval.majorSeventh).name, 'B#');

      const eFlat = Note(NoteLetter.e, Accidental.flat);
      expect(eFlat.transposeBy(Interval.majorThird).name, 'G');
      expect(eFlat.transposeBy(Interval.diminishedSeventh).name, 'Dbb');

      const gSharp = Note(NoteLetter.g, Accidental.sharp);
      expect(gSharp.transposeBy(Interval.majorSeventh).name, 'F##');
      expect(gSharp.transposeBy(Interval.diminishedSeventh).name, 'F');
    });

    test('double accidentals round-trip through name and parse', () {
      for (final spelling in <String>[
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
        'Cb',
        'B#',
        'Fb',
        'E#',
        'Bbb',
        'F##',
        'Dbb',
        'G##',
      ]) {
        expect(
          Note.tryParse(spelling)?.name,
          spelling,
          reason: '$spelling did not survive parse and print',
        );
      }
    });

    test('parses unicode accidentals and lowercase letters', () {
      expect(Note.tryParse('f#')?.name, 'F#');
      expect(Note.tryParse('E♭')?.name, 'Eb');
      expect(Note.tryParse('  bb ')?.name, 'Bb');
      expect(Note.tryParse('B♭♭')?.name, 'Bbb');
    });

    test('unparseable input returns null rather than throwing', () {
      for (final bad in <String>['', 'H', 'Cx', '#', 'C###', 'CB']) {
        expect(Note.tryParse(bad), isNull, reason: '"$bad" is not a note');
      }
    });

    test('chromatic transposition picks a spelling and wraps the octave', () {
      const b = Note(NoteLetter.b);
      expect(b.transposeChromatically(1).name, 'C');
      expect(const Note(NoteLetter.c).transposeChromatically(1).name, 'C#');
      expect(
        const Note(NoteLetter.c)
            .transposeChromatically(1, preferFlats: true)
            .name,
        'Db',
      );
      expect(const Note(NoteLetter.c).transposeChromatically(-1).name, 'B');
      expect(const Note(NoteLetter.c).transposeChromatically(12).name, 'C');
    });

    test('display name uses typographic accidentals', () {
      expect(const Note(NoteLetter.f, Accidental.sharp).displayName, 'F♯');
      expect(
        const Note(NoteLetter.b, Accidental.doubleFlat).displayName,
        'B♭♭',
      );
      expect(const Note(NoteLetter.c).displayName, 'C');
    });
  });
}
