import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/features/songs/data/song_catalog.dart';
import 'package:l_key/features/songs/domain/song.dart';
import 'package:l_key/features/songs/presentation/songs_controller.dart';
import 'package:l_key/shared/widgets/lk_async_view.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart'
    show lkScreenPadding;
import 'package:l_key/shared/widgets/lk_empty_state.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_segmented_control.dart';
import 'package:l_key/shared/widgets/lk_song_card.dart';
import 'package:l_key/shared/widgets/lk_text_field.dart';

/// The song library.
///
/// Searching and filtering happen against the bundled catalogue, so every one
/// of the four states CLAUDE.md §55 asks for is reachable without a network:
/// the repository is asynchronous because the Song CMS (PRD.md §50) will
/// eventually replace it.
class SongsPage extends ConsumerStatefulWidget {
  /// Creates the song library screen.
  const SongsPage({super.key});

  @override
  ConsumerState<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends ConsumerState<SongsPage> {
  late final TextEditingController _query;

  @override
  void initState() {
    super.initState();
    // Seeded from the state rather than started empty, for the same reason
    // ChordsPage does it (docs/adr/0014): the field and the results are two
    // views of one fact and cannot contradict each other.
    _query = TextEditingController(
      text: ref.read(songBrowserProvider).query,
    );
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final browser = ref.watch(songBrowserProvider);
    final library = ref.watch(songLibraryProvider);
    final favorites = ref.watch(songFavoritesProvider);

    return ListView(
      padding: lkScreenPadding,
      children: <Widget>[
        LkScreenHeader(
          title: l10n.navSongs,
          subtitle: library.value != null
              ? l10n.songsCountLabel(library.value!.length)
              : null,
        ),
        const SizedBox(height: LkSpacing.s6),

        LkTextField(
          label: l10n.songsSearchLabel,
          hint: l10n.songsSearchHint,
          controller: _query,
          icon: Icons.search,
          hideLabel: true,
          onChanged: ref.read(songBrowserProvider.notifier).search,
        ),
        const SizedBox(height: LkSpacing.s4),

        LkSegmentedControl<SongFilter>(
          segments: <SongFilter, String>{
            SongFilter.all: l10n.songsFilterAll,
            SongFilter.myanmar: l10n.songsFilterMyanmar,
            SongFilter.english: l10n.songsFilterEnglish,
            SongFilter.favorites: l10n.songsFilterFavorites,
          },
          selected: browser.filter,
          onChanged: ref.read(songBrowserProvider.notifier).filterBy,
        ),
        const SizedBox(height: LkSpacing.s6),

        LkAsyncView<List<SongCatalogEntry>>(
          value: library,
          onRetry: () => ref.invalidate(songLibraryProvider),
          data: (context, entries) {
            final results = filterSongs(
              entries: entries,
              state: browser,
              favorites: favorites,
            );
            if (results.isEmpty) {
              final isFavorites = browser.filter == SongFilter.favorites;
              return LkEmptyState(
                headline: isFavorites
                    ? l10n.songsEmptyFavorites
                    : l10n.songsEmptySearch,
                body: isFavorites
                    ? l10n.songsEmptyFavoritesBody
                    : l10n.songsEmptySearchBody,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: LkSpacing.s4,
              children: <Widget>[
                for (final entry in results)
                  LkSongCard(
                    key: ValueKey<String>('song-${entry.id}'),
                    title: entry.song.title,
                    artist: entry.song.artist,
                    tag: entry.song.language == SongLanguage.myanmar
                        ? l10n.songsFilterMyanmar.toUpperCase()
                        : l10n.songsFilterEnglish.toUpperCase(),
                    bpm: entry.song.bpm,
                    highlightTempo: entry == results.first,
                    onTap: () => context.pushNamed(
                      AppRoutes.songDetailName,
                      pathParameters: <String, String>{'songId': entry.id},
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
