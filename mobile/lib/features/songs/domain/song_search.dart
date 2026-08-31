/// Matching a typed query against song titles and artists.
///
/// Search has to work in English and in Myanmar (CLAUDE.md §32, PRD.md §40),
/// so this folds through the same [SearchText.normalise] chord search uses —
/// shared rather than duplicated, so the two never quietly diverge.
///
/// Contains no Flutter.
library;

import 'package:l_key/core/music/search_text.dart';
import 'package:l_key/features/songs/domain/song.dart';

/// A song and how well it matched a query.
final class SongMatch<T> {
  /// Creates a match.
  const SongMatch({required this.value, required this.score});

  /// Whatever was being searched — usually a catalogue entry.
  final T value;

  /// Higher is a better match. Only meaningful relative to other results.
  final int score;
}

/// Ranked matching over song titles and artists.
abstract final class SongSearch {
  /// Scores [song] against [query], or returns null when it does not match.
  static int? score(Song song, String query) {
    final needle = SearchText.normalise(query);
    if (needle.isEmpty) return 0;

    final title = SearchText.normalise(song.title);
    final artist = SearchText.normalise(song.artist);

    if (title == needle) return 100;
    if (title.startsWith(needle)) return 80;
    if (artist == needle) return 60;
    if (artist.startsWith(needle)) return 50;
    if (title.contains(needle)) return 30;
    if (artist.contains(needle)) return 20;
    return null;
  }

  /// Ranks [candidates] against [query], best first.
  ///
  /// Ties keep the order they came in, so the catalogue's own ordering
  /// decides between equal matches.
  static List<T> rank<T>(
    Iterable<T> candidates,
    String query, {
    required Song Function(T candidate) songOf,
  }) {
    final matches = <SongMatch<T>>[];
    var index = 0;
    for (final candidate in candidates) {
      final value = score(songOf(candidate), query);
      if (value != null) {
        matches.add(
          SongMatch<T>(value: candidate, score: value * 10000 - index),
        );
      }
      index += 1;
    }
    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches.map((match) => match.value).toList(growable: false);
  }
}
