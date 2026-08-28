import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/features/home/presentation/home_mock_data.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_empty_state.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_segmented_control.dart';
import 'package:l_key/shared/widgets/lk_song_card.dart';
import 'package:l_key/shared/widgets/lk_text_field.dart';

/// The song filters.
enum _Filter { all, myanmar, english, favorites }

// Placeholder library standing in for the song API (PRD.md §19).
const List<MockSong> _mockLibrary = <MockSong>[
  ...mockRecentSongs,
  MockSong(
    title: 'Acoustic Guitar Song',
    artist: 'L Key Originals',
    tag: 'FINGERSTYLE',
    bpm: 92,
  ),
];

/// The song library.
///
/// Search filters the placeholder list locally so the empty state is real and
/// reachable rather than a screenshot. Server-side search across Myanmar and
/// English text (PRD.md §40) arrives with the content API.
class SongsPage extends StatefulWidget {
  /// Creates the song library screen.
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  final TextEditingController _query = TextEditingController();
  _Filter _filter = _Filter.all;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<MockSong> get _results {
    if (_filter == _Filter.favorites) return const <MockSong>[];
    final q = _query.text.trim().toLowerCase();
    if (q.isEmpty) return _mockLibrary;
    return _mockLibrary
        .where(
          (s) =>
              s.title.toLowerCase().contains(q) ||
              s.artist.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = _results;

    return ListView(
      padding: lkScreenPadding,
      children: <Widget>[
        LkScreenHeader(
          title: l10n.navSongs,
          subtitle: l10n.songsCountLabel(_mockLibrary.length),
        ),
        const SizedBox(height: LkSpacing.s6),

        LkTextField(
          label: l10n.songsSearchLabel,
          hint: l10n.songsSearchHint,
          controller: _query,
          icon: Icons.search,
          hideLabel: true,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: LkSpacing.s4),

        LkSegmentedControl<_Filter>(
          segments: <_Filter, String>{
            _Filter.all: l10n.songsFilterAll,
            _Filter.myanmar: l10n.songsFilterMyanmar,
            _Filter.english: l10n.songsFilterEnglish,
            _Filter.favorites: l10n.songsFilterFavorites,
          },
          selected: _filter,
          onChanged: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: LkSpacing.s6),

        if (results.isEmpty)
          LkEmptyState(
            headline: _filter == _Filter.favorites
                ? l10n.songsEmptyFavorites
                : l10n.songsEmptySearch,
            body: _filter == _Filter.favorites
                ? l10n.songsEmptyFavoritesBody
                : l10n.songsEmptySearchBody,
          )
        else
          for (final song in results) ...<Widget>[
            LkSongCard(
              title: song.title,
              artist: song.artist,
              tag: song.tag,
              bpm: song.bpm,
              highlightTempo: song == results.first,
            ),
            const SizedBox(height: LkSpacing.s4),
          ],
      ],
    );
  }
}
