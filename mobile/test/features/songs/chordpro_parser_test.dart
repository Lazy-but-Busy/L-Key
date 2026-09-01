import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/features/songs/domain/chordpro_parser.dart';

void main() {
  group('ChordProParser.parse', () {
    test('reads title and artist metadata directives', () {
      final song = ChordProParser.parse('''
{title: Amazing Grace}
{artist: Traditional}
''');
      expect(song.metadata['title'], 'Amazing Grace');
      expect(song.metadata['artist'], 'Traditional');
    });

    test('folds directive aliases onto one metadata key', () {
      final byLong = ChordProParser.parse('{title: A}\n{artist: B}');
      final byShort = ChordProParser.parse('{t: A}\n{st: B}');
      expect(byShort.metadata['title'], byLong.metadata['title']);
      expect(byShort.metadata['artist'], byLong.metadata['artist']);
    });

    test('keeps an unrecognised directive rather than dropping it', () {
      final song = ChordProParser.parse('{tempo: 120}');
      expect(song.metadata['tempo'], '120');
    });

    test('splits a lyric line into chord-anchored segments', () {
      final song = ChordProParser.parse('[G]Amazing [D]grace');
      final segments = song.lines.single.segments;
      expect(segments.map((s) => s.lyric), <String>['', 'Amazing ', 'grace']);
      expect(segments[0].chord, isNull);
      expect(segments[1].chord?.symbol, 'G');
      expect(segments[2].chord?.symbol, 'D');
    });

    test('labels only the first line of a section', () {
      final song = ChordProParser.parse(
        '{start_of_verse}\n[G]line one\nline two\n{end_of_verse}',
      );
      expect(song.lines[0].sectionLabel, 'Verse');
      expect(song.lines[1].sectionLabel, isNull);
    });

    test('preserves a blank line as an empty-segment line', () {
      final song = ChordProParser.parse('one\n\ntwo');
      expect(song.lines.length, 3);
      expect(song.lines[1].segments, isEmpty);
    });

    test('an unterminated bracket keeps the rest of the line as text', () {
      final song = ChordProParser.parse('[Gopen bracket never closes');
      final segments = song.lines.single.segments;
      expect(segments.single.lyric, '[Gopen bracket never closes');
      expect(segments.single.chord, isNull);
    });

    test('a bracket that is not a chord this app can spell stays literal', () {
      // CLAUDE.md §37 — malformed content degrades gracefully rather than
      // throwing or silently vanishing.
      final song = ChordProParser.parse('[not a chord]lyric');
      final segments = song.lines.single.segments;
      expect(segments.single.lyric, '[not a chord]lyric');
      expect(segments.single.chord, isNull);
    });

    test('never throws on malformed input', () {
      const inputs = <String>[
        '',
        '{',
        '}',
        '{}',
        '[',
        ']',
        '[[[',
        '{{{unclosed',
        '{:}',
      ];
      for (final input in inputs) {
        expect(() => ChordProParser.parse(input), returnsNormally);
      }
    });
  });
}
