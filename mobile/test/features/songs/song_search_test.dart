import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/songs/domain/song.dart';
import 'package:l_key/features/songs/domain/song_search.dart';

Song _song(String title, String artist) => Song(
  title: title,
  artist: artist,
  key: const Note(NoteLetter.c),
  bpm: 100,
  tuning: Tuning.standard,
  chordPro: '',
);

void main() {
  group('SongSearch.score', () {
    test('an exact title match beats a prefix, which beats a substring', () {
      final exact = SongSearch.score(
        _song('Amazing Grace', 'Traditional'),
        'Amazing Grace',
      )!;
      final prefix = SongSearch.score(
        _song('Amazing Grace', 'Traditional'),
        'Amazing',
      )!;
      final substring = SongSearch.score(
        _song('Not Amazing', 'Traditional'),
        'Amazing',
      )!;
      expect(exact, greaterThan(prefix));
      expect(prefix, greaterThan(substring));
    });

    test('a song nothing matches scores null, not zero', () {
      expect(
        SongSearch.score(_song('Amazing Grace', 'Traditional'), 'zzz'),
        isNull,
      );
    });

    test('an empty query matches everything equally', () {
      expect(SongSearch.score(_song('Amazing Grace', 'Traditional'), ''), 0);
    });

    test('matches by artist as well as title', () {
      expect(
        SongSearch.score(_song('Some Song', 'Traditional'), 'Traditional'),
        isNotNull,
      );
    });

    test('finds a Myanmar-titled song by a Myanmar query', () {
      final song = _song('သီချင်းနမူနာ', 'L Key Originals');
      expect(SongSearch.score(song, 'သီချင်းနမူနာ'), isNotNull);
    });

    test('is case- and spacing-insensitive', () {
      final song = _song('Amazing Grace', 'Traditional');
      expect(SongSearch.score(song, 'amazing grace'), isNotNull);
      expect(SongSearch.score(song, 'AMAZINGGRACE'), isNotNull);
    });
  });

  group('SongSearch.rank', () {
    test('the song you typed comes first', () {
      final songs = <Song>[
        _song('Scarborough Fair', 'Traditional'),
        _song('Amazing Grace', 'Traditional'),
      ];
      final ranked = SongSearch.rank(songs, 'Amazing Grace', songOf: (s) => s);
      expect(ranked.first.title, 'Amazing Grace');
    });

    test('a query nothing matches returns nothing', () {
      final songs = <Song>[_song('Amazing Grace', 'Traditional')];
      expect(SongSearch.rank(songs, 'zzz', songOf: (s) => s), isEmpty);
    });

    test('an empty query returns the catalogue in its own order', () {
      final songs = <Song>[
        _song('Scarborough Fair', 'Traditional'),
        _song('Amazing Grace', 'Traditional'),
      ];
      final ranked = SongSearch.rank(songs, '', songOf: (s) => s);
      expect(ranked.map((s) => s.title).toList(), <String>[
        'Scarborough Fair',
        'Amazing Grace',
      ]);
    });
  });
}
