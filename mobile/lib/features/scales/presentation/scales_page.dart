import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/scale.dart';
import 'package:l_key/features/fretboard/data/fretboard_catalog.dart';
import 'package:l_key/features/fretboard/domain/fretboard_repository.dart';
import 'package:l_key/features/fretboard/presentation/fretboard_controller.dart';
import 'package:l_key/features/fretboard/presentation/widgets/fretboard_neck.dart';
import 'package:l_key/shared/widgets/lk_async_view.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_chip.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_empty_state.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_segmented_control.dart';

/// The scales screen (DESIGN.md §26).
///
/// A scale in one view: its name, the box in view, its formula, its notes and
/// its shape on the neck. Everything is computed by the scale and fretboard
/// engines; nothing on this screen is a placeholder.
///
/// It shares its state with the fretboard tool, so choosing A Dorian here and
/// opening the fretboard shows A Dorian rather than starting over.
class ScalesPage extends ConsumerWidget {
  /// Creates the scales screen.
  const ScalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final options = ref.watch(fretboardOptionsProvider);

    return LkAsyncView<FretboardOptions>(
      value: options,
      onRetry: () => ref.invalidate(fretboardOptionsProvider),
      isEmpty: (data) => data.scales.isEmpty,
      empty: (context) => LkEmptyState(
        headline: l10n.fretboardEmpty,
        body: l10n.fretboardEmptyBody,
      ),
      data: (context, data) => _Scales(options: data),
    );
  }
}

class _Scales extends ConsumerWidget {
  const _Scales({required this.options});

  final FretboardOptions options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final state = ref.watch(fretboardProvider);
    final view = ref.watch(scaleViewProvider);
    final controller = ref.read(fretboardProvider.notifier);

    // The screen always shows a scale, so a root the picker cannot spell is
    // replaced before anything is drawn rather than throwing underneath it.
    final scale = view.scale ?? Scale(state.root, ScaleType.minorPentatonic);
    final tier = options.scales
        .firstWhere((entry) => entry.value == scale.type)
        .tier;
    final box = state.focus.kind == FretboardFocusKind.box
        ? state.focus.boxIndex
        : null;

    return ListView(
      padding: lkFullScreenPadding,
      children: <Widget>[
        LkScreenHeader(
          title: '${scale.root.displayName} ${scaleName(l10n, scale.type)}',
          subtitle: box == null
              ? l10n.scalesSubtitle
              : l10n.scalesBoxSubtitle(
                  box,
                  view.range.lowest,
                  view.range.highest,
                ),
        ),
        const SizedBox(height: LkSpacing.s6),

        Row(
          spacing: LkSpacing.s2,
          children: <Widget>[
            Flexible(
              child: LkSegmentedControl<ScaleType>(
                segments: <ScaleType, String>{
                  for (final entry in options.scales)
                    if (entry.value.category != ScaleCategory.mode)
                      entry.value: scaleName(l10n, entry.value),
                },
                selected: scale.type,
                onChanged: controller.selectScale,
              ),
            ),
            // 'PRO' is the brand mark, not translated copy (DESIGN.md §32).
            // It labels; it authorizes nothing (CLAUDE.md §23).
            if (tier == FeatureTier.premium) const LkPremiumBadge(label: 'PRO'),
          ],
        ),
        const SizedBox(height: LkSpacing.s4),

        LkSegmentedControl<Note>(
          segments: <Note, String>{
            for (final root in FretboardCatalog.rootsFor(scale.type))
              root: root.displayName,
          },
          selected: scale.root,
          onChanged: controller.selectRoot,
        ),
        const SizedBox(height: LkSpacing.s6),

        Row(
          spacing: LkSpacing.s4,
          children: <Widget>[
            Expanded(
              child: LkStatChip(
                label: l10n.scalesFormula,
                value: scale.formula,
              ),
            ),
            Expanded(
              child: LkStatChip(
                label: l10n.scalesRoot,
                value: scale.root.displayName,
              ),
            ),
          ],
        ),
        const SizedBox(height: LkSpacing.s4),

        LkStatChip(
          label: l10n.scalesNotes,
          value: scale.notes.map((n) => n.displayName).join(' '),
        ),
        const SizedBox(height: LkSpacing.s6),

        if (view.boxes.isNotEmpty)
          LkSegmentedControl<FretboardFocus>(
            segments: <FretboardFocus, String>{
              const FretboardFocus.fullNeck(): l10n.fretboardFullNeck,
              for (final position in view.boxes)
                FretboardFocus.box(position.index): l10n.fretboardBox(
                  position.index,
                ),
            },
            selected: state.focus.kind == FretboardFocusKind.caged
                ? const FretboardFocus.fullNeck()
                : state.focus,
            onChanged: controller.focusOn,
          ),
        const SizedBox(height: LkSpacing.s4),

        if (view.isEmpty)
          LkEmptyState(
            headline: l10n.fretboardEmpty,
            body: l10n.fretboardEmptyBody,
          )
        else
          FretboardNeck(
            tuning: view.tuning,
            range: view.range,
            positions: view.positions,
            labels: state.labels,
            title: '${scale.root.displayName} ${scaleName(l10n, scale.type)}',
          ),
        const SizedBox(height: LkSpacing.s6),

        LkButton(
          label: l10n.scalesOpenFretboard,
          variant: LkButtonVariant.accent,
          onPressed: () => context.goNamed(AppRoutes.fretboardName),
        ),
        const SizedBox(height: LkSpacing.s4),

        // No practice control and no play button: there is no audio engine
        // and no metronome yet, and CLAUDE.md §47 says say so rather than
        // ship a control that does nothing.
        Text(
          l10n.scalesAudioPending,
          style: context.lkType.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
