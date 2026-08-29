import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/features/chords/data/chord_catalog.dart';
import 'package:l_key/features/chords/presentation/chords_controller.dart';
import 'package:l_key/shared/widgets/lk_async_view.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_empty_state.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';
import 'package:l_key/shared/widgets/lk_pressable.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_segmented_control.dart';
import 'package:l_key/shared/widgets/lk_text_field.dart';

/// The chord library.
///
/// Searching and filtering happen against the offline catalogue, so every one
/// of the four states CLAUDE.md §55 asks for is reachable without a network:
/// the repository is asynchronous because the chord CMS (PRD.md §51) will
/// eventually replace it.
class ChordsPage extends ConsumerStatefulWidget {
  /// Creates the chord library screen.
  const ChordsPage({super.key});

  @override
  ConsumerState<ChordsPage> createState() => _ChordsPageState();
}

class _ChordsPageState extends ConsumerState<ChordsPage> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final browser = ref.watch(chordBrowserProvider);
    final library = ref.watch(chordLibraryProvider);

    return LkDetailScaffold(
      title: l10n.toolChords,
      fallbackRoute: AppRoutes.tools,
      child: ListView(
        padding: lkScreenPadding,
        children: <Widget>[
          LkScreenHeader(
            title: l10n.toolChords,
            subtitle: l10n.chordsSubtitle,
          ),
          const SizedBox(height: LkSpacing.s5),

          // The way in for a player who has a shape under their fingers and
          // no name for it — the opposite question to the one the search box
          // answers.
          LkButton(
            label: l10n.chordAnalyzerOpen,
            onPressed: () => context.pushNamed(AppRoutes.chordAnalyzerName),
            variant: LkButtonVariant.secondary,
            block: true,
          ),
          const SizedBox(height: LkSpacing.s5),

          LkTextField(
            label: l10n.chordsSearchLabel,
            hint: l10n.chordsSearchHint,
            controller: _query,
            icon: Icons.search,
            hideLabel: true,
            onChanged: ref.read(chordBrowserProvider.notifier).search,
          ),
          const SizedBox(height: LkSpacing.s4),

          LkSegmentedControl<ChordFilter>(
            segments: <ChordFilter, String>{
              ChordFilter.all: l10n.chordsFilterAll,
              ChordFilter.triads: l10n.chordsFilterTriads,
              ChordFilter.sevenths: l10n.chordsFilterSevenths,
              ChordFilter.extended: l10n.chordsFilterExtended,
            },
            selected: browser.filter,
            onChanged: ref.read(chordBrowserProvider.notifier).filterBy,
          ),
          const SizedBox(height: LkSpacing.s6),

          LkAsyncView<List<ChordCatalogEntry>>(
            value: library,
            onRetry: () => ref.invalidate(chordLibraryProvider),
            data: (context, entries) {
              final results = filterChords(
                entries: entries,
                state: browser,
                l10n: l10n,
              );
              if (results.isEmpty) {
                return LkEmptyState(
                  headline: l10n.chordsEmptySearch,
                  body: l10n.chordsEmptySearchBody,
                  centered: false,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: LkSpacing.s3,
                children: <Widget>[
                  for (final entry in results) _ChordRow(entry: entry),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// One chord in the list.
class _ChordRow extends StatelessWidget {
  const _ChordRow({required this.entry});

  final ChordCatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final quality = qualityName(l10n, entry.chord.quality);

    return LkPressable(
      // Identity for a list that is filtered and re-ranked on every
      // keystroke, so Flutter matches a row to the same chord across a
      // rebuild rather than to whatever now sits at that index.
      key: ValueKey<String>('chord-${entry.id}'),
      minHeight: LkDimens.tapTarget,
      padding: const EdgeInsets.symmetric(
        horizontal: LkSpacing.s4,
        vertical: LkSpacing.s3,
      ),
      semanticLabel: '${entry.chord.displaySymbol} $quality',
      onTap: () => context.pushNamed(
        AppRoutes.chordDetailName,
        pathParameters: <String, String>{'chordId': entry.id},
      ),
      child: Row(
        spacing: LkSpacing.s3,
        children: <Widget>[
          Text(
            entry.chord.displaySymbol,
            style: context.lkType.h3.copyWith(color: colors.textPrimary),
          ),
          Expanded(
            child: Text(
              quality.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: context.lkType.label.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          // A label, not a lock. Entitlement is the server's decision
          // (CLAUDE.md §23) and every chord here opens.
          if (entry.tier == FeatureTier.premium)
            const LkPremiumBadge(label: 'PRO'),
        ],
      ),
    );
  }
}
