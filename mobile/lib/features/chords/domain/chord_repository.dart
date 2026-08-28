/// Where chords come from.
///
/// The interface is asynchronous even though the only implementation answers
/// from a const table. PRD.md §51 puts a chord CMS in the Admin Portal, so a
/// second implementation will eventually reach the network — and a screen
/// built against a synchronous source would have to be rewritten to cope. The
/// four states CLAUDE.md §55 asks for are honest from the first day this way.
///
/// Contains no Flutter.
library;

import 'package:l_key/features/chords/data/chord_catalog.dart';

/// Reads the chord library.
abstract interface class ChordRepository {
  /// Every chord, in catalogue order.
  Future<List<ChordCatalogEntry>> browse();

  /// One chord and its voicings, or null when [id] names nothing.
  Future<ChordDetail?> detail(String id);
}
