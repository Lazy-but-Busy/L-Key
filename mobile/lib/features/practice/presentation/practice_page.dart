import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/features/metronome/presentation/metronome_controller.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_card.dart';
import 'package:l_key/shared/widgets/lk_chip.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_premium_note.dart';
import 'package:l_key/shared/widgets/lk_progress_bar.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';

/// One exercise in the session plan.
@immutable
class _PlanItem {
  const _PlanItem({
    required this.title,
    required this.minutes,
    required this.isDone,
  });

  final String title;
  final int minutes;
  final bool isDone;
}

// Placeholder content standing in for the practice API (PRD.md §24).
const List<_PlanItem> _mockPlan = <_PlanItem>[
  _PlanItem(title: 'CHORD SWITCHING', minutes: 10, isDone: true),
  _PlanItem(title: 'PENTATONIC', minutes: 10, isDone: true),
  _PlanItem(title: 'STRUMMING', minutes: 10, isDone: false),
];

const int _mockStreakDays = 6;
const int _mockElapsedMinutes = 20;
const int _mockPlannedMinutes = 30;

/// The practice session screen.
///
/// Reached from Home and from Learn, and owned by the Learn section so a deep
/// link restores the right tab. The timer does not run: session tracking and
/// its persistence are a later phase, so the figures are a static plan rather
/// than an invented measurement (CLAUDE.md §47).
class PracticePage extends ConsumerStatefulWidget {
  /// Creates the practice screen.
  const PracticePage({super.key});

  @override
  ConsumerState<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage> {
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    return LkDetailScaffold(
      title: l10n.practiceTitle,
      fallbackRoute: AppRoutes.learn,
      child: ListView(
        padding: lkScreenPadding,
        children: <Widget>[
          LkScreenHeader(
            title: l10n.practiceTitle,
            subtitle: l10n.practiceStreakDays(_mockStreakDays),
          ),
          const SizedBox(height: LkSpacing.s6),

          LkCard(
            variant: LkCardVariant.ring,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: LkSpacing.s4,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  spacing: LkSpacing.s2,
                  children: <Widget>[
                    Text(
                      '$_mockElapsedMinutes:00',
                      style: context.lkType.h1.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '/ $_mockPlannedMinutes:00',
                      style: context.lkType.technicalSm.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                LkProgressBar(
                  value: _mockElapsedMinutes.toDouble(),
                  max: _mockPlannedMinutes.toDouble(),
                  semanticLabel: l10n.practiceSession,
                ),
                for (final item in _mockPlan) _PlanRow(item: item),
                LkButton(
                  label: _isRunning ? l10n.practicePause : l10n.practiceStart,
                  variant: _isRunning
                      ? LkButtonVariant.primary
                      : LkButtonVariant.accent,
                  block: true,
                  onPressed: () => setState(() => _isRunning = !_isRunning),
                ),
              ],
            ),
          ),
          const SizedBox(height: LkSpacing.s6),

          Row(
            spacing: LkSpacing.s4,
            children: <Widget>[
              Expanded(
                child: LkStatChip(
                  label: l10n.practiceStatStreak,
                  value: l10n.practiceStreakDays(_mockStreakDays),
                ),
              ),
              Expanded(
                child: LkStatChip(
                  label: l10n.practiceStatThisWeek,
                  value: '142',
                ),
              ),
              Expanded(
                child: LkStatChip(
                  label: l10n.practiceStatBestBpm,
                  value: '96',
                ),
              ),
            ],
          ),
          const SizedBox(height: LkSpacing.s6),

          const _TempoRow(),
          const SizedBox(height: LkSpacing.s6),

          LkPremiumNote(capability: l10n.practiceProNote),
        ],
      ),
    );
  }
}

/// The metronome's tempo, and a way to start it without leaving the screen.
///
/// **This is the whole of the practice/metronome integration, on purpose.**
/// The session timer, its persistence and every statistic on this screen still
/// belong to a later phase, and a tempo row that implied otherwise would be
/// the invented measurement CLAUDE.md §47 rules out. It watches
/// [metronomeTempoProvider] rather than the whole state, so a running
/// metronome does not rebuild this screen on every beat.
class _TempoRow extends ConsumerWidget {
  const _TempoRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final tempo = ref.watch(metronomeTempoProvider);

    return Container(
      padding: const EdgeInsets.all(LkSpacing.s4),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border, width: LkBorders.regular),
      ),
      child: Row(
        spacing: LkSpacing.s4,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${tempo.bpm}',
                style: context.lkType.h2.copyWith(color: colors.textPrimary),
              ),
              Text(
                l10n.metronomeBpm,
                style: context.lkType.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          Expanded(
            child: Text(
              '${l10n.toolMetronome} · ${tempo.signature.label}',
              style: context.lkType.technical.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          LkButton(
            label: tempo.isRunning ? l10n.metronomeStop : l10n.metronomeStart,
            variant: LkButtonVariant.secondary,
            onPressed: ref.read(metronomeProvider.notifier).toggle,
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.item});

  final _PlanItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Semantics(
      label: item.title,
      value: '${item.minutes}',
      checked: item.isDone,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: LkSpacing.s3),
          child: Row(
            spacing: LkSpacing.s3,
            children: <Widget>[
              Container(
                width: LkSpacing.s4,
                height: LkSpacing.s4,
                decoration: BoxDecoration(
                  color: item.isDone ? colors.accent : colors.surface,
                  border: Border.all(
                    color: colors.border,
                    width: LkBorders.regular,
                  ),
                ),
                child: item.isDone
                    ? Icon(
                        Icons.check,
                        size: LkSpacing.s3,
                        color: colors.accentOn,
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  item.title,
                  style: context.lkType.technical.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${item.minutes}',
                style: context.lkType.label.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
