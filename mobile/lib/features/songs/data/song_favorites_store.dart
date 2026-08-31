/// Where favorited songs live between launches.
library;

import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the favorited song ids through `shared_preferences`.
///
/// Its own store rather than a field on `Settings`, matching
/// `MetronomeSettingsStore`'s reasoning: favoriting a song should not rebuild
/// anything that watches unrelated settings. Writes are fire-and-forget so
/// the interface never waits on disk (docs/adr/0008).
final class SongFavoritesStore {
  /// Creates a store over the supplied preferences.
  const SongFavoritesStore(this._preferences);

  static const String _key = 'songs.favorites';

  final SharedPreferences _preferences;

  /// The currently favorited song ids.
  Set<String> read() =>
      (_preferences.getStringList(_key) ?? const <String>[]).toSet();

  /// Favorites [songId] if it is not already, or un-favorites it if it is.
  void toggle(String songId) {
    final current = read();
    if (!current.remove(songId)) current.add(songId);
    _preferences.setStringList(_key, current.toList(growable: false)).ignore();
  }
}
