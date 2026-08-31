import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/capo.dart';
import 'package:l_key/core/music/note.dart';

void main() {
  group('CapoEngine.soundingKeyFor', () {
    test("matches PRD.md §22's own example: capo 2, play C, sounds D", () {
      const c = Note(NoteLetter.c);
      const d = Note(NoteLetter.d);
      expect(CapoEngine.soundingKeyFor(c, 2), d);
    });

    test('no capo sounds the played key unchanged', () {
      const g = Note(NoteLetter.g);
      expect(CapoEngine.soundingKeyFor(g, 0), g);
    });

    test('respells a black key with flats when asked', () {
      const g = Note(NoteLetter.g);
      final sharp = CapoEngine.soundingKeyFor(g, 1);
      final flat = CapoEngine.soundingKeyFor(g, 1, preferFlats: true);
      expect(sharp, isNot(flat));
      expect(sharp.isEnharmonicWith(flat), isTrue);
    });
  });

  group('CapoEngine.alternativesFor', () {
    test('every alternative actually sounds the requested key', () {
      const d = Note(NoteLetter.d);
      for (final position in CapoEngine.alternativesFor(d)) {
        expect(position.soundingKey, d);
        expect(CapoEngine.soundingKeyFor(position.playedKey, position.fret), d);
      }
    });

    test('fret 0 plays the sounding key directly', () {
      const a = Note(NoteLetter.a);
      final atZero = CapoEngine.alternativesFor(a).first;
      expect(atZero.fret, 0);
      expect(atZero.playedKey, a);
    });

    test('covers capo positions 0 through 7', () {
      const e = Note(NoteLetter.e);
      final frets = CapoEngine.alternativesFor(e).map((p) => p.fret).toList();
      expect(frets, List<int>.generate(8, (i) => i));
    });
  });
}
