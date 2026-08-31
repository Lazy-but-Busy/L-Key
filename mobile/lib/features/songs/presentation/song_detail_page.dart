import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/core/music/capo.dart';
import 'package:l_key/features/songs/data/song_catalog.dart';
import 'package:l_key/features/songs/domain/chordpro_parser.dart';
import 'package:l_key/features/songs/domain/song_transpose.dart';
import 'package:l_key/features/songs/presentation/songs_controller.dart';
import 'package:l_key/shared/widgets/lk_async_view.dart';
import 'package:l_key/shared/widgets/lk_chip.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_empty_state.dart';
import 'package:l_key/shared/widgets/lk_icon_button.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_section_header.dart';

/// One song: its chords over its lyrics, and the controls a player reaches
/// for mid-performance without leaving the screen (DESIGN.md §28–29).
///
/// Nothing here recalculates music: transposing calls [SongTranspose],
/// reading the capo relationship calls [CapoEngine], and reading the chords
/// out of the raw ChordPro body calls [ChordProParser] (CLAUDE.md §8, §10).
class SongDetailPage extends ConsumerStatefulWidget {
  /// Creates the song detail screen for the catalogue entry [songId].
  const SongDetailPage({required this.songId, super.key});

  /// The catalogue id from the route, such as `amazing-grace`.
  final String songId;

  @override
  ConsumerState<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends ConsumerState<SongDetailPage> {
  int _semitones = 0;
  double _fontScale = 1;
  bool _autoScrollEnabled = false;

  static const double _minFontScale = 0.75;
  static const double _maxFontScale = 1.5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(songDetailProvider(widget.songId));
    final favorites = ref.watch(songFavoritesProvider);

    return LkDetailScaffold(
      title: l10n.navSongs,
      fallbackRoute: AppRoutes.songs,
      child: ListView(
        padding: lkScreenPadding,
        children: <Widget>[
          LkAsyncView<SongCatalogEntry?>(
            value: detail,
            onRetry: () => ref.invalidate(songDetailProvider(widget.songId)),
            isEmpty: (data) => data == null,
            empty: (context) => LkEmptyState(
              headline: l10n.songDetailNotFound,
              body: l10n.songDetailNotFoundBody,
            ),
            data: (context, data) => _SongDetail(
              entry: data!,
              semitones: _semitones,
              fontScale: _fontScale,
              autoScrollEnabled: _autoScrollEnabled,
              isFavorite: favorites.contains(widget.songId),
              onTranspose: (delta) => setState(() => _semitones += delta),
              onFontScale: (delta) => setState(
                () => _fontScale = (_fontScale + delta).clamp(
                  _minFontScale,
                  _maxFontScale,
                ),
              ),
              onAutoScrollToggled: (value) =>
                  setState(() => _autoScrollEnabled = value),
              onFavoriteToggled: () => ref
                  .read(songFavoritesProvider.notifier)
                  .toggle(widget.songId),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongDetail extends StatelessWidget {
  const _SongDetail({
    required this.entry,
    required this.semitones,
    required this.fontScale,
    required this.autoScrollEnabled,
    required this.isFavorite,
    required this.onTranspose,
    required this.onFontScale,
    required this.onAutoScrollToggled,
    required this.onFavoriteToggled,
  });

  final SongCatalogEntry entry;
  final int semitones;
  final double fontScale;
  final bool autoScrollEnabled;
  final bool isFavorite;
  final ValueChanged<int> onTranspose;
  final ValueChanged<double> onFontScale;
  final ValueChanged<bool> onAutoScrollToggled;
  final VoidCallback onFavoriteToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final song = semitones == 0
        ? entry.song
        : SongTranspose.transpose(entry.song, semitones);
    final sounding = CapoEngine.soundingKeyFor(song.key, song.capo);
    final lines = ChordProParser.parse(song.chordPro).lines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: LkScreenHeader(
                title: song.title,
                subtitle: song.artist,
              ),
            ),
            if (entry.tier == FeatureTier.premium)
              const Padding(
                padding: EdgeInsets.only(top: LkSpacing.s1),
                child: LkPremiumBadge(label: 'PRO'),
              ),
            LkIconButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              semanticLabel: isFavorite
                  ? l10n.songDetailUnfavorite
                  : l10n.songDetailFavorite,
              variant: isFavorite
                  ? LkIconButtonVariant.accent
                  : LkIconButtonVariant.ring,
              onPressed: onFavoriteToggled,
            ),
          ],
        ),
        const SizedBox(height: LkSpacing.s5),

        Row(
          spacing: LkSpacing.s3,
          children: <Widget>[
            Expanded(
              child: LkStatChip(
                label: l10n.songDetailKey,
                value: song.key.displayName,
              ),
            ),
            Expanded(
              child: LkStatChip(
                label: l10n.songDetailCapo,
                value: song.capo == 0
                    ? l10n.songDetailNoCapo
                    : song.capo.toString(),
              ),
            ),
            if (song.capo != 0)
              Expanded(
                child: LkStatChip(
                  label: l10n.songDetailSounds,
                  value: sounding.displayName,
                ),
              ),
            Expanded(
              child: LkStatChip(
                label: l10n.songDetailTuning,
                value: song.tuning.name,
              ),
            ),
          ],
        ),
        const SizedBox(height: LkSpacing.s6),

        _Controls(
          semitones: semitones,
          fontScale: fontScale,
          autoScrollEnabled: autoScrollEnabled,
          onTranspose: onTranspose,
          onFontScale: onFontScale,
          onAutoScrollToggled: onAutoScrollToggled,
        ),
        const SizedBox(height: LkSpacing.s6),

        for (final line in lines)
          _ChordProLineView(line: line, fontScale: fontScale),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.semitones,
    required this.fontScale,
    required this.autoScrollEnabled,
    required this.onTranspose,
    required this.onFontScale,
    required this.onAutoScrollToggled,
  });

  final int semitones;
  final double fontScale;
  final bool autoScrollEnabled;
  final ValueChanged<int> onTranspose;
  final ValueChanged<double> onFontScale;
  final ValueChanged<bool> onAutoScrollToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: LkSpacing.s4,
      children: <Widget>[
        _StepperRow(
          label: l10n.songDetailTranspose,
          value: l10n.songDetailTransposeValue(semitones),
          onDecrement: () => onTranspose(-1),
          onIncrement: () => onTranspose(1),
        ),
        _StepperRow(
          label: l10n.songDetailFontSize,
          value: '${(fontScale * 100).round()}%',
          onDecrement: () => onFontScale(-0.125),
          onIncrement: () => onFontScale(0.125),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.songDetailAutoScroll,
                style: context.lkType.body.copyWith(color: colors.textPrimary),
              ),
            ),
            Switch(value: autoScrollEnabled, onChanged: onAutoScrollToggled),
          ],
        ),
        if (autoScrollEnabled)
          LkPendingNote(message: l10n.songDetailAutoScrollNote),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final String value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: context.lkType.body.copyWith(color: colors.textPrimary),
          ),
        ),
        LkIconButton(
          icon: Icons.remove,
          semanticLabel: '$label -',
          variant: LkIconButtonVariant.ring,
          onPressed: onDecrement,
        ),
        SizedBox(
          width: LkSpacing.s12,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: context.lkType.technical.copyWith(color: colors.textPrimary),
          ),
        ),
        LkIconButton(
          icon: Icons.add,
          semanticLabel: '$label +',
          variant: LkIconButtonVariant.ring,
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

class _ChordProLineView extends StatelessWidget {
  const _ChordProLineView({required this.line, required this.fontScale});

  final ChordProLine line;
  final double fontScale;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    if (line.segments.isEmpty) {
      return const SizedBox(height: LkSpacing.s4);
    }

    final chordStyle = context.lkType.technicalSm.copyWith(
      color: colors.accent,
      fontSize: (context.lkType.technicalSm.fontSize ?? 12) * fontScale,
    );
    final lyricStyle = context.lkType.body.copyWith(
      color: colors.textPrimary,
      fontSize: (context.lkType.body.fontSize ?? 16) * fontScale,
    );

    final row = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final segment in line.segments)
            if (segment.lyric.isNotEmpty || segment.chord != null)
              Padding(
                padding: const EdgeInsets.only(bottom: LkSpacing.s2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(segment.chord?.displaySymbol ?? '', style: chordStyle),
                    Text(
                      segment.lyric.isEmpty ? ' ' : segment.lyric,
                      style: lyricStyle,
                    ),
                  ],
                ),
              ),
        ],
      ),
    );

    if (line.sectionLabel == null) return row;

    return Padding(
      padding: const EdgeInsets.only(top: LkSpacing.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LkSectionHeader(title: line.sectionLabel!),
          const SizedBox(height: LkSpacing.s2),
          row,
        ],
      ),
    );
  }
}
