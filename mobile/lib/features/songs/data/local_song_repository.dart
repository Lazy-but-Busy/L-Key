/// The offline song library.
///
/// Answers entirely from the const catalogue, so the song library works with
/// no network at all — which CLAUDE.md §19 requires of saved songs, and which
/// is the whole reason the song domain contains no I/O.
library;

import 'package:l_key/features/songs/data/song_catalog.dart';
import 'package:l_key/features/songs/domain/song_repository.dart';

/// A [SongRepository] backed by the built-in catalogue.
final class LocalSongRepository implements SongRepository {
  /// Creates a repository over the built-in catalogue.
  const LocalSongRepository();

  @override
  Future<List<SongCatalogEntry>> browse() async => SongCatalog.entries;

  @override
  Future<SongCatalogEntry?> detail(String id) async {
    for (final entry in SongCatalog.entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }
}
