/// Where songs come from.
///
/// The interface is asynchronous even though the only implementation answers
/// from a const table. PRD.md §50 puts a Song CMS with bulk import in the
/// Admin Portal, so a second implementation will eventually reach the
/// network — and a screen built against a synchronous source would have to
/// be rewritten to cope. The four states CLAUDE.md §55 asks for are honest
/// from the first day this way.
///
/// Contains no Flutter.
library;

import 'package:l_key/features/songs/data/song_catalog.dart';

/// Reads the song library.
abstract interface class SongRepository {
  /// Every song, in catalogue order.
  Future<List<SongCatalogEntry>> browse();

  /// One song, or null when [id] names nothing.
  Future<SongCatalogEntry?> detail(String id);
}
