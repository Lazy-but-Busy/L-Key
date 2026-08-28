import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/features/home/presentation/home_mock_data.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_card.dart';
import 'package:l_key/shared/widgets/lk_icon_button.dart';
import 'package:l_key/shared/widgets/lk_pressable.dart';
import 'package:l_key/shared/widgets/lk_progress_bar.dart';
import 'package:l_key/shared/widgets/lk_section_header.dart';
import 'package:l_key/shared/widgets/lk_song_card.dart';

/// The Home screen.
///
/// Section order follows DESIGN.md §20: greeting, Quick Tune, quick tools,
/// continue practice, recent songs. The tuner is the most prominent action on
/// the screen and the only orange surface, which is what keeps the accent
/// meaningful (DESIGN.md §7).
class HomePage extends StatelessWidget {
  /// Creates the Home screen.
  const HomePage({super.key});

  String _greeting(AppLocalizations l10n, DateTime now) {
    if (now.hour < 12) return l10n.homeGreetingMorning;
    if (now.hour < 18) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        LkSpacing.s6,
        0,
        LkSpacing.s6,
        LkSpacing.s6,
      ),
      children: <Widget>[
        Text(
          _greeting(l10n, DateTime.now()),
          style: context.lkType.h2.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: LkSpacing.s1),
        Text(
          l10n.homeGuitarist.toUpperCase(),
          style: context.lkType.h1.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: LkSpacing.s8),

        _QuickTuneCard(
          onOpen: () => context.goNamed(AppRoutes.tunerName),
        ),
        const SizedBox(height: LkSpacing.s4),

        // DESIGN.md §20 lists Quick Tools as its own section between Quick
        // Tune and Continue Practice.
        for (final tool in <(String, String)>[
          (l10n.toolMetronome, AppRoutes.metronomeName),
          (l10n.toolChords, AppRoutes.chordsName),
          (l10n.toolScales, AppRoutes.scalesName),
        ]) ...<Widget>[
          _QuickToolRow(
            label: tool.$1,
            onTap: () => context.goNamed(tool.$2),
          ),
          const SizedBox(height: LkSpacing.s4),
        ],
        const SizedBox(height: LkSpacing.s5),

        _DailySessionCard(
          onResume: () => context.goNamed(AppRoutes.practiceName),
        ),
        const SizedBox(height: LkSpacing.s8),

        LkSectionHeader(
          title: l10n.homeRecentRiffs,
          actionLabel: l10n.homeViewLibrary,
          onAction: () => context.goNamed(AppRoutes.songsName),
        ),
        const SizedBox(height: LkSpacing.s4),
        for (final song in mockRecentSongs) ...<Widget>[
          LkSongCard(
            title: song.title,
            artist: song.artist,
            tag: song.tag,
            bpm: song.bpm,
            onTap: () => context.goNamed(AppRoutes.songsName),
          ),
          const SizedBox(height: LkSpacing.s4),
        ],
        _ImportTile(label: l10n.homeImportTab),
      ],
    );
  }
}

class _QuickTuneCard extends StatelessWidget {
  const _QuickTuneCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    return LkPressable(
      onTap: onOpen,
      background: colors.accent,
      padding: const EdgeInsets.all(LkSpacing.s6),
      semanticLabel: '${l10n.homeQuickTune} ${l10n.homeQuickTuneTuning}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: LkSpacing.s8,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.homeQuickTune,
                  style: context.lkType.h2.copyWith(color: colors.accentOn),
                ),
              ),
              Icon(Icons.graphic_eq, color: colors.accentOn),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.homeQuickTuneTuning.toUpperCase(),
                  style: context.lkType.technical.copyWith(
                    color: colors.accentOn,
                  ),
                ),
              ),
              LkIconButton(
                icon: Icons.play_arrow,
                semanticLabel: l10n.homeStartTuner,
                size: LkDimens.iconBoxLg,
                circular: true,
                onPressed: onOpen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickToolRow extends StatelessWidget {
  const _QuickToolRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return LkPressable(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: LkSpacing.s4),
      semanticLabel: label,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.lkType.h4.copyWith(color: colors.textPrimary),
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: LkSpacing.s5,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _DailySessionCard extends StatelessWidget {
  const _DailySessionCard({required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    return LkCard(
      title: l10n.homeDailySession,
      label: mockSessionFocus,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: LkSpacing.s3,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: LkSpacing.s2,
            children: <Widget>[
              Text(
                '$mockSessionElapsedMinutes:00',
                style: context.lkType.h1.copyWith(color: colors.textPrimary),
              ),
              Text(
                '/ $mockSessionTotalMinutes:00',
                style: context.lkType.technicalSm.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          LkProgressBar(
            value: mockSessionElapsedMinutes.toDouble(),
            max: mockSessionTotalMinutes.toDouble(),
            semanticLabel: l10n.homeDailySession,
          ),
          LkButton(
            label: l10n.commonResume,
            onPressed: onResume,
            block: true,
            icon: const Icon(Icons.arrow_forward, size: LkSpacing.s4),
            iconAtEnd: true,
          ),
        ],
      ),
    );
  }
}

class _ImportTile extends StatelessWidget {
  const _ImportTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return LkPressable(
      background: colors.surfaceSunken,
      padding: const EdgeInsets.symmetric(vertical: LkSpacing.s12),
      semanticLabel: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: LkSpacing.s4,
        children: <Widget>[
          Container(
            width: LkDimens.iconBoxCircle,
            height: LkDimens.iconBoxCircle,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.border,
                width: LkBorders.regular,
              ),
            ),
            child: Icon(Icons.add, color: colors.textPrimary),
          ),
          Text(
            label,
            style: context.lkType.h2.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
