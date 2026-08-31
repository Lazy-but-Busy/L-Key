import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/songs/domain/song.dart';
import 'package:l_key/features/songs/domain/song_transpose.dart';

Song _song(String chordPro, {Note key = const Note(NoteLetter.g)}) => Song(
  title: 'Test Song',
  artist: 'Test Artist',
  key: key,
  bpm: 100,
  tuning: Tuning.standard,
  chordPro: chordPro,
);

void main() {
  group('SongTranspose.transpose', () {
    test('moves every chord up by the given semitones', () {
      final original = _song('[G]Amazing [C]grace');
      final result = SongTranspose.transpose(original, 2);
      expect(result.chordPro, '[A]Amazing [D]grace');
    });

    test('moves the stored key along with the chords', () {
      final original = _song('[G]line');
      final result = SongTranspose.transpose(original, 2);
      expect(result.key, const Note(NoteLetter.a));
    });

    test('zero semitones returns the same song untouched', () {
      final original = _song('[G]line');
      expect(SongTranspose.transpose(original, 0), same(original));
    });

    test('preserves lyrics, whitespace and structure exactly', () {
      const body = '{start_of_verse}\n[G]Amazing   [C]grace\n{end_of_verse}';
      final result = SongTranspose.transpose(
        _song(body),
        1,
        preferFlats: true,
      );
      expect(
        result.chordPro,
        '{start_of_verse}\n[Ab]Amazing   [Db]grace\n{end_of_verse}',
      );
    });

    test("preserves a slash chord's bass relationship", () {
      final original = _song('[G/B]line');
      final result = SongTranspose.transpose(original, 2);
      expect(result.chordPro, '[A/C#]line');
    });

    test('leaves an unparseable bracket untouched rather than throwing', () {
      final original = _song('[not a chord]line');
      final result = SongTranspose.transpose(original, 2);
      expect(result.chordPro, '[not a chord]line');
    });

    test('negative semitones transpose down', () {
      final original = _song('[G]line');
      final result = SongTranspose.transpose(original, -2);
      expect(result.chordPro, '[F]line');
    });

    test('preferFlats chooses the black-key spelling', () {
      final original = _song('[G]line');
      final sharp = SongTranspose.transpose(original, 1);
      final flat = SongTranspose.transpose(original, 1, preferFlats: true);
      expect(sharp.chordPro, '[G#]line');
      expect(flat.chordPro, '[Ab]line');
    });
  });
}
