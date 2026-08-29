import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/localization/music_names.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/chords/data/chord_catalog.dart';
import 'package:l_key/features/chords/domain/chord_analyzer.dart';
import 'package:l_key/features/chords/presentation/chord_analyzer_controller.dart';
import 'package:l_key/features/chords/presentation/chords_controller.dart';
import 'package:l_key/features/chords/presentation/widgets/chord_shape_editor.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_empty_state.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_section_header.dart';
import 'package:l_key/shared/widgets/lk_segmented_control.dart';

/// The chord analyzer.
///
/// The player builds a shape on the neck and L Key names it. Every musical
/// judgement — which notes sound, which chords they could be, which name
/// leads — arrives already decided from `ChordAnalyzer`, which is the same
/// eighteen formulas the chord library draws from (CLAUDE.md §8, §11).
class ChordAnalyzerPage extends ConsumerWidget {
  /// Creates the chord analyzer screen.
  const ChordAnalyzerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(chordAnalyzerProvider);
    final analysis = ref.watch(chordAnalysisProvider);
    final controller = ref.read(chordAnalyzerProvider.notifier);

    return LkDetailScaffold(
      title: l10n.chordAnalyzer,
      fallbackRoute: AppRoutes.chords,
      child: ListView(
        padding: lkScreenPadding,
        children: <Widget>[
          LkScreenHeader(
            title: l10n.chordAnalyzer,
            subtitle: l10n.chordAnalyzerSubtitle,
          ),
          const SizedBox(height: LkSpacing.s6),

          _TuningPicker(
            tuning: state.tuning,
            onChanged: controller.selectTuning,
          ),
          const SizedBox(height: LkSpacing.s5),

          _Neck(state: state, analysis: analysis, controller: controller),
          const SizedBox(height: LkSpacing.s5),

          _Transport(state: state, onClear: controller.clear),
          const SizedBox(height: LkSpacing.s6),

          _Result(state: state, analysis: analysis),
        ],
      ),
    );
  }
}

/// The tuning the shape is built in.
class _TuningPicker extends StatelessWidget {
  const _TuningPicker({required this.tuning, required this.onChanged});

  final Tuning tuning;
  final ValueChanged<Tuning> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final entries = ChordCatalog.tunings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: LkSpacing.s3,
      children: <Widget>[
        Row(
          spacing: LkSpacing.s2,
          children: <Widget>[
            Text(
              l10n.fretboardTuning.toUpperCase(),
              style: context.lkType.label.copyWith(color: colors.textSecondary),
            ),
            // A label, not a lock: every tuning here selects (CLAUDE.md §23).
            if (entries.any(
              (entry) =>
                  entry.value == tuning && entry.tier == FeatureTier.premium,
            ))
              LkPremiumBadge(label: l10n.commonPro),
          ],
        ),
        LkSegmentedControl<Tuning>(
          segments: <Tuning, String>{
            for (final entry in entries)
              entry.value: tuningName(l10n, entry.value),
          },
          selected: tuning,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// The editable neck, scrolled horizontally because it is wider than a phone.
class _Neck extends StatelessWidget {
  const _Neck({
    required this.state,
    required this.analysis,
    required this.controller,
  });

  final ChordAnalyzerState state;
  final ChordAnalysis analysis;
  final ChordAnalyzerController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tuning = state.tuning;
    final root = analysis.best?.chord.root;

    String noteAt(int stringIndex, int fret) =>
        tuning.pitchAt(stringIndex: stringIndex, fret: fret).note.displayName;

    // Guitarists count strings from the high string down.
    int number(int stringIndex) => tuning.stringCount - stringIndex;

    return Semantics(
      container: true,
      label: l10n.chordAnalyzerNeckSemantics(tuning.stringCount),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ChordShapeEditor(
          tuning: tuning,
          strings: state.strings,
          labelOf: noteAt,
          isRootAt: (stringIndex, fret) =>
              root != null &&
              tuning.pitchAt(stringIndex: stringIndex, fret: fret).midiNumber %
                      12 ==
                  root.pitchClass,
          describeCell: (stringIndex, fret) => fret == 0
              ? l10n.chordAnalyzerCellOpenSemantics(
                  number(stringIndex),
                  noteAt(stringIndex, fret),
                )
              : l10n.chordAnalyzerCellSemantics(
                  number(stringIndex),
                  fret,
                  noteAt(stringIndex, fret),
                ),
          describeToggle: (stringIndex) => state.strings[stringIndex].sounds
              ? l10n.chordAnalyzerMuteSemantics(number(stringIndex))
              : l10n.chordAnalyzerUnmuteSemantics(number(stringIndex)),
          onSelect: controller.selectFret,
          onToggle: controller.toggleString,
        ),
      ),
    );
  }
}

/// Clear, and the play control that admits it cannot play.
class _Transport extends ConsumerWidget {
  const _Transport({required this.state, required this.onClear});

  final ChordAnalyzerState state;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final audio = ref.watch(chordAudioPlayerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: LkSpacing.s3,
      children: <Widget>[
        Row(
          spacing: LkSpacing.s3,
          children: <Widget>[
            Expanded(
              child: LkButton(
                label: l10n.commonClear,
                onPressed: state.isSilent ? null : onClear,
                variant: LkButtonVariant.secondary,
                block: true,
              ),
            ),
            Expanded(
              child: LkButton(
                label: l10n.chordPlay,
                // No audio engine exists. The control is disabled and the
                // reason is written underneath rather than faked
                // (CLAUDE.md §47).
                onPressed: audio.isAvailable && !state.isSilent
                    ? () => audio.play(state.voicing, tuning: state.tuning)
                    : null,
                block: true,
              ),
            ),
          ],
        ),
        if (!audio.isAvailable)
          Text(
            l10n.chordPlayUnavailable,
            textAlign: TextAlign.center,
            style: context.lkType.bodySmall.copyWith(
              color: context.lkColors.textSecondary,
            ),
          ),
      ],
    );
  }
}

/// What the shape turned out to be.
class _Result extends StatelessWidget {
  const _Result({required this.state, required this.analysis});

  final ChordAnalyzerState state;
  final ChordAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (analysis.isSilent) {
      return LkEmptyState(
        headline: l10n.chordAnalyzerEmpty,
        body: l10n.chordAnalyzerEmptyBody,
        centered: false,
      );
    }
    if (analysis.isSingleNote) {
      return LkEmptyState(
        headline: l10n.chordAnalyzerSingleNote(
          analysis.pitches.first.note.displayName,
        ),
        body: l10n.chordAnalyzerSingleNoteBody,
        centered: false,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: LkSpacing.s5,
      children: <Widget>[
        _Notes(analysis: analysis, stringCount: state.tuning.stringCount),
        if (analysis.best != null) _Intervals(analysis: analysis),
        if (analysis.candidates.isEmpty)
          LkEmptyState(
            headline: l10n.chordAnalyzerNoMatch,
            body: l10n.chordAnalyzerNoMatchBody,
            centered: false,
          )
        else
          _Candidates(analysis: analysis),
      ],
    );
  }
}

/// The notes the shape sounds, lowest first, and which of them is the bass.
class _Notes extends StatelessWidget {
  const _Notes({required this.analysis, required this.stringCount});

  final ChordAnalysis analysis;
  final int stringCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final sounded = <String>[
      for (var index = 0; index < analysis.notes.length; index++)
        if (analysis.notes[index] case final note?) note.displayName,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: LkSpacing.s2,
      children: <Widget>[
        LkSectionHeader(title: l10n.chordNotes),
        Text(
          sounded.join(' · '),
          style: context.lkType.technicalLg.copyWith(
            color: colors.textPrimary,
          ),
        ),
        if (analysis.bass case final bass?)
          Text(
            '${l10n.chordAnalyzerBass.toUpperCase()}  ${bass.name}',
            style: context.lkType.technicalSm.copyWith(
              color: colors.textSecondary,
            ),
          ),
      ],
    );
  }
}

/// The degree each sounding string plays above the best candidate's root.
class _Intervals extends StatelessWidget {
  const _Intervals({required this.analysis});

  final ChordAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final degrees = <String>[
      for (final degree in analysis.degrees)
        if (degree != null) degree.degree,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: LkSpacing.s2,
      children: <Widget>[
        LkSectionHeader(title: l10n.chordAnalyzerIntervals),
        Text(
          degrees.join(' · '),
          style: context.lkType.technicalLg.copyWith(
            color: context.lkColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Every name the shape could go by, best first.
class _Candidates extends StatelessWidget {
  const _Candidates({required this.analysis});

  final ChordAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: LkSpacing.s3,
      children: <Widget>[
        LkSectionHeader(title: l10n.chordAnalyzerPossible),
        for (final candidate in analysis.candidates)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: LkSpacing.s4,
              vertical: LkSpacing.s3,
            ),
            constraints: const BoxConstraints(minHeight: LkDimens.tapTarget),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(
                color: colors.border,
                width: LkBorders.regular,
              ),
              boxShadow: candidate == analysis.best
                  ? <BoxShadow>[LkShadows.sm(colors.border)]
                  : null,
            ),
            child: Row(
              spacing: LkSpacing.s3,
              children: <Widget>[
                Text(
                  candidate.chord.displaySymbol,
                  style: context.lkType.h3.copyWith(color: colors.textPrimary),
                ),
                const Spacer(),
                // A name that leaves a tone out is still a true name, and
                // saying which tone is missing is what keeps it honest.
                if (candidate.omitted.isNotEmpty)
                  Flexible(
                    child: Text(
                      l10n.chordAnalyzerOmits(
                        candidate.omitted
                            .map((interval) => interval.degree)
                            .join(' '),
                      ),
                      overflow: TextOverflow.ellipsis,
                      style: context.lkType.technicalSm.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
