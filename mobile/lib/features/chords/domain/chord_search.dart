/// Matching a typed query against chord names.
///
/// Search has to work in English and in Myanmar (CLAUDE.md §32, PRD.md §40),
/// and a chord is written in three different registers at once: a symbol
/// (`Cmaj7`), a spelled-out name (`C major 7`), and whatever the player's
/// language calls it. All three are matched.
///
/// The domain never reads a localisation file, so display names arrive as an
/// argument. That keeps this Flutter-free and testable without a widget tree
/// (CLAUDE.md §10).
///
/// Contains no Flutter.
library;

import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/features/chords/domain/chord.dart';

/// A chord and how well it matched a query.
final class ChordMatch<T> {
  /// Creates a match.
  const ChordMatch({required this.value, required this.score});

  /// Whatever was being searched — usually a catalogue entry.
  final T value;

  /// Higher is a better match. Only meaningful relative to other results.
  final int score;
}

/// Ranked matching over chord names.
abstract final class ChordSearch {
  /// Folds a query or a name into the form both sides are compared in.
  ///
  /// Unicode accidentals become their ASCII equivalents so `C♯` and `C#` are
  /// one query, case is dropped, and every kind of space and separator goes —
  /// a player typing `c maj 7` means `Cmaj7`. Burmese text is left alone apart
  /// from case and spacing, which is all that is safe to do to it.
  static String normalise(String input) {
    final buffer = StringBuffer();
    for (final rune in input.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      switch (char) {
        case '♯':
          buffer.write('#');
        case '♭':
          buffer.write('b');
        case '°':
          buffer.write('dim');
        // The query is lower-cased before this loop, so a typed capital
        // delta arrives here already folded.
        case 'δ':
          buffer.write('maj');
        case ' ':
        case '\t':
        case '\u00a0':
        case '-':
        case '_':
          break;
        default:
          buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Scores [chord] against [query], or returns null when it does not match.
  ///
  /// [qualityNames] supplies the localised name of each quality — pass the
  /// English map, the Myanmar map, or both merged, depending on what the
  /// caller wants findable.
  static int? score(
    Chord chord,
    String query, {
    Map<ChordQuality, List<String>> qualityNames =
        const <ChordQuality, List<String>>{},
  }) {
    final needle = normalise(query);
    if (needle.isEmpty) return 0;

    final symbol = normalise(chord.symbol);
    if (symbol == needle) return 100;
    if (symbol.startsWith(needle)) return 80;

    final root = normalise(chord.root.name);
    final names = qualityNames[chord.quality] ?? const <String>[];
    for (final name in names) {
      final full = normalise('$root $name');
      if (full == needle) return 90;
      if (full.startsWith(needle)) return 70;
      if (normalise(name) == needle) return 50;
      if (normalise(name).startsWith(needle)) return 40;
    }

    if (symbol.contains(needle)) return 30;
    if (root == needle) return 60;
    return null;
  }

  /// Ranks [candidates] against [query], best first.
  ///
  /// Ties keep the order they came in, so the catalogue's own ordering — roots
  /// ascending, simplest quality first — decides between equal matches.
  static List<T> rank<T>(
    Iterable<T> candidates,
    String query, {
    required Chord Function(T candidate) chordOf,
    Map<ChordQuality, List<String>> qualityNames =
        const <ChordQuality, List<String>>{},
  }) {
    final matches = <ChordMatch<T>>[];
    var index = 0;
    for (final candidate in candidates) {
      final value = score(
        chordOf(candidate),
        query,
        qualityNames: qualityNames,
      );
      if (value != null) {
        matches.add(
          ChordMatch<T>(value: candidate, score: value * 10000 - index),
        );
      }
      index += 1;
    }
    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches.map((match) => match.value).toList(growable: false);
  }
}
