import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/localization/music_names.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/scale.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/fretboard/data/fretboard_catalog.dart';
import 'package:l_key/features/fretboard/domain/fretboard_repository.dart';
import 'package:l_key/features/fretboard/presentation/fretboard_controller.dart';
import 'package:l_key/features/fretboard/presentation/widgets/fretboard_neck.dart';
import 'package:l_key/shared/widgets/lk_async_view.dart';
import 'package:l_key/shared/widgets/lk_chip.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_empty_state.dart';
import 'package:l_key/shared/widgets/lk_icon_button.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_section_header.dart';
import 'package:l_key/shared/widgets/lk_segmented_control.dart';

/// The interactive fretboard (PRD.md §13).
///
/// Every control here sets *intent*; not one of them computes a note. The
/// neck is derived by `fretboardViewProvider` from the engines in
/// `core/music/` and `fretboard/domain/`, so the widget lays out and nothing
/// else (CLAUDE.md §8).
class FretboardPage extends ConsumerWidget {
  /// Creates the fretboard screen.
  const FretboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final options = ref.watch(fretboardOptionsProvider);

    return LkAsyncView<FretboardOptions>(
      value: options,
      onRetry: () => ref.invalidate(fretboardOptionsProvider),
      isEmpty: (data) => data.isEmpty,
      empty: (context) => LkEmptyState(
        headline: l10n.fretboardEmpty,
        body: l10n.fretboardEmptyBody,
      ),
      data: (context, data) => _Fretboard(options: data),
    );
  }
}

class _Fretboard extends ConsumerWidget {
  const _Fretboard({required this.options});

  final FretboardOptions options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(fretboardProvider);
    final view = ref.watch(fretboardViewProvider);
    final controller = ref.read(fretboardProvider.notifier);

    final title = switch (state.kind) {
      FretboardKind.scale || FretboardKind.mode =>
        '${state.root.displayName} ${scaleName(l10n, state.scaleType)}',
      FretboardKind.arpeggio =>
        '${state.root.displayName}${state.arpeggio.symbol}',
      FretboardKind.notes => l10n.fretboardKindNotes,
    };

    return ListView(
      padding: lkFullScreenPadding,
      children: <Widget>[
        LkScreenHeader(title: l10n.toolFretboard, subtitle: title),
        const SizedBox(height: LkSpacing.s6),

        _Field(
          label: l10n.fretboardSound,
          child: LkSegmentedControl<FretboardKind>(
            segments: <FretboardKind, String>{
              FretboardKind.scale: l10n.fretboardKindScale,
              FretboardKind.mode: l10n.fretboardKindMode,
              FretboardKind.arpeggio: l10n.fretboardKindArpeggio,
              FretboardKind.notes: l10n.fretboardKindNotes,
            },
            selected: state.kind,
            onChanged: controller.selectKind,
          ),
        ),

        if (state.kind == FretboardKind.scale ||
            state.kind == FretboardKind.mode)
          _Field(
            label: l10n.toolScales,
            tier: _tierOfScale(options, state.scaleType),
            child: LkSegmentedControl<ScaleType>(
              segments: <ScaleType, String>{
                for (final entry in options.scales)
                  if (_belongsTo(state.kind, entry.value))
                    entry.value: scaleName(l10n, entry.value),
              },
              selected: state.scaleType,
              onChanged: controller.selectScale,
            ),
          ),

        if (state.kind == FretboardKind.arpeggio)
          _Field(
            label: l10n.fretboardKindArpeggio,
            tier: FeatureTier.premium,
            child: LkSegmentedControl<ChordQuality>(
              segments: <ChordQuality, String>{
                for (final entry in options.arpeggios)
                  entry.value: entry.value.symbol.isEmpty
                      ? l10n.chordQualityMajor
                      : entry.value.symbol,
              },
              selected: state.arpeggio,
              onChanged: controller.selectArpeggio,
            ),
          ),

        _Field(
          label: l10n.fretboardRoot,
          child: LkSegmentedControl<Note>(
            segments: <Note, String>{
              for (final root in _rootsFor(state)) root: root.displayName,
            },
            selected: state.root,
            onChanged: controller.selectRoot,
          ),
        ),

        _Field(
          label: l10n.fretboardTuning,
          tier: _tierOfTuning(options, state.tuning),
          child: LkSegmentedControl<Tuning>(
            segments: <Tuning, String>{
              for (final entry in options.tunings)
                entry.value: tuningName(l10n, entry.value),
            },
            selected: state.tuning,
            onChanged: controller.selectTuning,
          ),
        ),

        _Field(
          label: l10n.fretboardPosition,
          child: LkSegmentedControl<FretboardFocus>(
            segments: <FretboardFocus, String>{
              const FretboardFocus.fullNeck(): l10n.fretboardFullNeck,
              for (final box in view.boxes)
                FretboardFocus.box(box.index): l10n.fretboardBox(box.index),
              for (final shape in view.cagedPositions)
                FretboardFocus.caged(shape.shape): l10n.fretboardCagedShape(
                  shape.shape.letter,
                ),
            },
            selected: state.focus,
            onChanged: controller.focusOn,
          ),
        ),

        _Field(
          label: l10n.fretboardLabels,
          child: LkSegmentedControl<FretboardLabels>(
            segments: <FretboardLabels, String>{
              FretboardLabels.notes: l10n.fretboardLabelNotes,
              FretboardLabels.intervals: l10n.fretboardLabelIntervals,
            },
            selected: state.labels,
            onChanged: controller.selectLabels,
          ),
        ),

        _FretRangeControl(
          range: '${view.range.lowest}–${view.range.highest}',
          readout: l10n.fretboardFretRange(
            view.range.lowest,
            view.range.highest,
          ),
          onSlide: controller.slideBy,
          onResize: controller.resizeBy,
        ),

        const SizedBox(height: LkSpacing.s6),

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
            title: title,
          ),

        const SizedBox(height: LkSpacing.s6),

        if (view.scale != null)
          Row(
            spacing: LkSpacing.s4,
            children: <Widget>[
              Expanded(
                child: LkStatChip(
                  label: l10n.scalesFormula,
                  value: view.scale!.formula,
                ),
              ),
              Expanded(
                child: LkStatChip(
                  label: l10n.scalesNotes,
                  value: view.scale!.notes.map((n) => n.displayName).join(' '),
                ),
              ),
            ],
          ),

        if (view.cagedPositions.isEmpty && state.tuning != Tuning.standard) ...[
          const SizedBox(height: LkSpacing.s4),
          _Note(message: l10n.fretboardCagedUnavailable),
        ],
      ],
    );
  }

  /// Which scales the current picker offers.
  ///
  /// The modes picker shows the seven modes; the scales picker shows
  /// everything else. Ionian and Aeolian are modal names for the major and
  /// natural minor scales, so they appear once, under Modes.
  static bool _belongsTo(FretboardKind kind, ScaleType type) =>
      kind == FretboardKind.mode
      ? type.category == ScaleCategory.mode
      : type.category != ScaleCategory.mode;

  /// The roots the current selection can be written on.
  static List<Note> _rootsFor(FretboardState state) =>
      state.kind == FretboardKind.scale || state.kind == FretboardKind.mode
      ? FretboardCatalog.rootsFor(state.scaleType)
      : FretboardCatalog.roots;

  static FeatureTier _tierOfScale(FretboardOptions options, ScaleType type) =>
      options.scales.firstWhere((entry) => entry.value == type).tier;

  static FeatureTier _tierOfTuning(FretboardOptions options, Tuning tuning) =>
      options.tunings.firstWhere((entry) => entry.value == tuning).tier;
}

/// A labelled control, with the Premium label when the current choice carries
/// one. The label authorizes nothing — every option here selects
/// (CLAUDE.md §23, §51).
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.tier});

  final String label;
  final Widget child;
  final FeatureTier? tier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LkSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: LkSpacing.s2,
        children: <Widget>[
          Row(
            spacing: LkSpacing.s2,
            children: <Widget>[
              Flexible(child: LkSectionHeader(title: label)),
              // 'PRO' is the brand mark, not translated copy (DESIGN.md §32).
              if (tier == FeatureTier.premium)
                const LkPremiumBadge(label: 'PRO'),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

/// The fret window control: slide the neck, widen or narrow the view.
class _FretRangeControl extends StatelessWidget {
  const _FretRangeControl({
    required this.range,
    required this.readout,
    required this.onSlide,
    required this.onResize,
  });

  final String range;
  final String readout;
  final ValueChanged<int> onSlide;
  final ValueChanged<int> onResize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    return Row(
      spacing: LkSpacing.s2,
      children: <Widget>[
        Expanded(child: LkSectionHeader(title: l10n.fretboardFrets)),
        Semantics(
          label: readout,
          excludeSemantics: true,
          child: Text(
            range,
            style: context.lkType.technical.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        LkIconButton(
          icon: Icons.chevron_left,
          semanticLabel: l10n.fretboardMoveDown,
          onPressed: () => onSlide(-1),
        ),
        LkIconButton(
          icon: Icons.remove,
          semanticLabel: l10n.fretboardNarrow,
          onPressed: () => onResize(-1),
        ),
        LkIconButton(
          icon: Icons.add,
          semanticLabel: l10n.fretboardWiden,
          onPressed: () => onResize(1),
        ),
        LkIconButton(
          icon: Icons.chevron_right,
          semanticLabel: l10n.fretboardMoveUp,
          onPressed: () => onSlide(1),
        ),
      ],
    );
  }
}

/// A plain statement of something the app cannot do yet, or does not apply.
class _Note extends StatelessWidget {
  const _Note({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Text(
      message,
      style: context.lkType.bodySmall.copyWith(color: colors.textSecondary),
    );
  }
}
