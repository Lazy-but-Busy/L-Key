import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:l_key/features/songs/data/local_song_repository.dart';
import 'package:l_key/features/songs/data/song_catalog.dart';
import 'package:l_key/features/songs/data/song_favorites_store.dart';
import 'package:l_key/features/songs/domain/song.dart';
import 'package:l_key/features/songs/domain/song_repository.dart';
import 'package:l_key/features/songs/domain/song_search.dart';

/// Where songs are read from.
///
/// Overridden in tests to supply a failing or empty library, which is the
/// only way the error and empty states can be exercised honestly.
final songRepositoryProvider = Provider<SongRepository>(
  (ref) => const LocalSongRepository(),
);

/// Where favorited song ids are stored.
final songFavoritesStoreProvider = Provider<SongFavoritesStore>(
  (ref) => SongFavoritesStore(ref.watch(sharedPreferencesProvider)),
);

/// How the library narrows by language, in addition to search.
enum SongFilter {
  /// Everything.
  all,

  /// Myanmar-language songs only.
  myanmar,

  /// English-language songs only.
  english,

  /// Favorited songs only.
  favorites,
}

/// What the song browser is currently showing.
@immutable
class SongBrowserState {
  /// Creates a browser state.
  const SongBrowserState({this.query = '', this.filter = SongFilter.all});

  /// The player's search text.
  final String query;

  /// The active language/favorites filter.
  final SongFilter filter;

  /// Returns a copy with the given fields replaced.
  SongBrowserState copyWith({String? query, SongFilter? filter}) =>
      SongBrowserState(
        query: query ?? this.query,
        filter: filter ?? this.filter,
      );
}

/// Holds the browser's query and filter.
///
/// Only the player's *intent* lives here. Which songs match is derived, not
/// stored, so the two can never disagree (docs/ARCHITECTURE.md).
class SongBrowserController extends Notifier<SongBrowserState> {
  @override
  SongBrowserState build() => const SongBrowserState();

  /// Sets the search text.
  void search(String query) => state = state.copyWith(query: query);

  /// Sets the language/favorites filter.
  void filterBy(SongFilter filter) => state = state.copyWith(filter: filter);
}

/// The song browser's query and filter.
///
/// Auto-disposing, so the state lives exactly as long as the screen that owns
/// it (docs/adr/0014's chord-search lesson applies here too).
final songBrowserProvider =
    NotifierProvider<SongBrowserController, SongBrowserState>(
      SongBrowserController.new,
      isAutoDispose: true,
    );

/// Every song in the library.
final songLibraryProvider = FutureProvider<List<SongCatalogEntry>>(
  (ref) => ref.watch(songRepositoryProvider).browse(),
);

/// One song, or null when the id names nothing.
// The family builder's own type is not nameable from flutter_riverpod's
// public surface, so the annotation the lint wants cannot be written.
// ignore: specify_nonobvious_property_types
final songDetailProvider = FutureProvider.family<SongCatalogEntry?, String>(
  (ref, id) => ref.watch(songRepositoryProvider).detail(id),
);

/// The favorited song ids.
class SongFavoritesController extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.watch(songFavoritesStoreProvider).read();

  /// Favorites [songId] if it is not already, or un-favorites it if it is.
  void toggle(String songId) {
    ref.read(songFavoritesStoreProvider).toggle(songId);
    final next = Set<String>.of(state);
    if (!next.remove(songId)) next.add(songId);
    state = next;
  }
}

/// The favorited song ids, backed by [SongFavoritesStore].
final songFavoritesProvider =
    NotifierProvider<SongFavoritesController, Set<String>>(
      SongFavoritesController.new,
    );

/// Applies the filter and the search to the library.
List<SongCatalogEntry> filterSongs({
  required List<SongCatalogEntry> entries,
  required SongBrowserState state,
  required Set<String> favorites,
}) {
  final byFilter = entries.where((entry) {
    return switch (state.filter) {
      SongFilter.all => true,
      SongFilter.myanmar => entry.song.language == SongLanguage.myanmar,
      SongFilter.english => entry.song.language == SongLanguage.english,
      SongFilter.favorites => favorites.contains(entry.id),
    };
  });

  return SongSearch.rank<SongCatalogEntry>(
    byFilter,
    state.query,
    songOf: (entry) => entry.song,
  );
}
