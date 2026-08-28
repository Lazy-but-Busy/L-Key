import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/features/chords/data/chord_catalog.dart';
import 'package:l_key/features/chords/domain/chord.dart';
import 'package:l_key/features/chords/domain/chord_quality.dart';
import 'package:l_key/features/chords/domain/chord_search.dart';
import 'package:l_key/features/chords/domain/chord_symbol.dart';

/// Stands in for the localised names the presentation layer passes down.
const Map<ChordQuality, List<String>> _names = <ChordQuality, List<String>>{
  ChordQuality.major: <String>['major', 'မေဂျာ'],
  ChordQuality.minor: <String>['minor', 'မိုင်နာ'],
  ChordQuality.majorSeventh: <String>['major 7', 'မေဂျာ ၇'],
};

Chord _chord(String symbol) => ChordSymbol.tryParse(symbol)!;

List<String> _search(String query) => ChordSearch.rank<ChordCatalogEntry>(
  ChordCatalog.entries,
  query,
  chordOf: (entry) => entry.chord,
  qualityNames: _names,
).map((entry) => entry.chord.symbol).toList();

void main() {
  group('ChordSearch.normalise', () {
    test('folds the two ways an accidental is written into one', () {
      // CLAUDE.md §32 — a player types whichever their keyboard offers.
      expect(ChordSearch.normalise('C♯'), ChordSearch.normalise('C#'));
      expect(ChordSearch.normalise('E♭maj7'), ChordSearch.normalise('ebmaj7'));
      expect(ChordSearch.normalise('C°7'), 'cdim7');
    });

    test('ignores case, spacing and separators', () {
      expect(ChordSearch.normalise('  A m 7  '), 'am7');
      expect(ChordSearch.normalise('C-maj_7'), 'cmaj7');
    });

    test('leaves Myanmar text intact apart from spacing', () {
      // Burmese has no case and its combining marks must not be touched.
      expect(ChordSearch.normalise('မေဂျာ'), 'မေဂျာ');
      expect(ChordSearch.normalise(' မေဂျာ '), 'မေဂျာ');
    });
  });

  group('ChordSearch.score', () {
    test('an exact symbol beats a prefix, which beats a substring', () {
      final exact = ChordSearch.score(_chord('Cmaj7'), 'Cmaj7')!;
      final prefix = ChordSearch.score(_chord('Cmaj7'), 'Cma')!;
      final inside = ChordSearch.score(_chord('Cmaj7'), 'maj7')!;
      expect(exact, greaterThan(prefix));
      expect(prefix, greaterThan(inside));
    });

    test('a chord nothing matches scores null, not zero', () {
      expect(ChordSearch.score(_chord('Cmaj7'), 'wobble'), isNull);
    });

    test('an empty query matches everything equally', () {
      expect(ChordSearch.score(_chord('Cmaj7'), '   '), 0);
    });

    test('finds a chord by its spelled-out name in either language', () {
      expect(
        ChordSearch.score(_chord('Cmaj7'), 'C major 7', qualityNames: _names),
        isNotNull,
      );
      expect(
        ChordSearch.score(_chord('Cmaj7'), 'C မေဂျာ ၇', qualityNames: _names),
        isNotNull,
      );
      expect(
        ChordSearch.score(_chord('Am'), 'မိုင်နာ', qualityNames: _names),
        isNotNull,
      );
    });
  });

  group('ChordSearch.rank', () {
    test('the chord you typed comes first', () {
      expect(_search('Am').first, 'Am');
      expect(_search('C#m7b5').first, 'C#m7b5');
      expect(_search('C♯m7♭5').first, 'C#m7b5');
    });

    test('a root alone returns that root, not the whole library', () {
      final results = _search('Bb');
      expect(results, isNotEmpty);
      expect(
        results.every((symbol) => symbol.startsWith('Bb')),
        isTrue,
        reason: 'searching Bb returned $results',
      );
    });

    test('a query nothing matches returns nothing', () {
      // The empty state is a real state, not an error (CLAUDE.md §55).
      expect(_search('zzz'), isEmpty);
    });

    test('an empty query returns the catalogue in its own order', () {
      final all = _search('');
      expect(all.length, ChordCatalog.entries.length);
      expect(all.first, 'C');
    });

    test('a Myanmar query finds English-named chords', () {
      final results = _search('မိုင်နာ');
      expect(results, isNotEmpty);
      expect(results.first, 'Cm', reason: 'roots stay in catalogue order');
    });
  });

  group('ChordCatalog', () {
    test('ids are URL-safe and unique', () {
      final seen = <String>{};
      final unsafe = RegExp('[^a-z0-9-]');
      for (final entry in ChordCatalog.entries) {
        expect(
          seen.add(entry.id),
          isTrue,
          reason: '${entry.id} appears twice',
        );
        expect(
          unsafe.hasMatch(entry.id),
          isFalse,
          reason: '${entry.id} needs escaping in a route',
        );
      }
    });

    test('an id spells out its accidental', () {
      expect(ChordCatalog.idFor(_chord('C#m7b5')), 'c-sharp-m7b5');
      expect(ChordCatalog.idFor(_chord('Db')), 'd-flat-major');
      expect(ChordCatalog.idFor(_chord('G/B')), 'g-major-over-b');
    });

    test('the catalogue covers every root and quality, plus slash chords', () {
      expect(
        ChordCatalog.entries.length,
        greaterThanOrEqualTo(
          ChordCatalog.roots.length * ChordQuality.values.length,
        ),
      );
      expect(
        ChordCatalog.entries.any((entry) => entry.chord.isSlash),
        isTrue,
      );
    });
  });
}
