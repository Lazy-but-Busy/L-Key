import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/localization/music_names.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/features/tuner/domain/tuner_state.dart';
import 'package:l_key/features/tuner/domain/tuning_engine.dart';
import 'package:l_key/features/tuner/presentation/tuner_controller.dart';
import 'package:l_key/features/tuner/presentation/widgets/tuner_diagnostics_card.dart';
import 'package:l_key/features/tuner/presentation/widgets/tuner_permission_gate.dart';
import 'package:l_key/features/tuner/presentation/widgets/tuner_strings.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_tuner_meter.dart';

/// The tuner screen.
///
/// It lays out and nothing else. Every number on it — the note, the cents, the
/// in-tune verdict — arrives already decided from `tuner/domain`, and the
/// microphone's lifetime belongs to the controller (CLAUDE.md §8, §14).
class TunerPage extends ConsumerStatefulWidget {
  /// Creates the tuner screen.
  const TunerPage({super.key});

  @override
  ConsumerState<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends ConsumerState<TunerPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The shell keeps every tab's stack alive, so a tuner left open on the
    // Tools tab stays mounted while the player reads a chord chart.
    // TickerMode is how a branch says whether it is the visible one, and it
    // is the only thing this widget tells the controller — a layout fact,
    // which is the one kind a widget is allowed to know (CLAUDE.md §8, §50).
    final visible = TickerMode.valuesOf(context).enabled;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(tunerProvider.notifier).setVisible(visible: visible);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(tunerProvider);
    final controller = ref.read(tunerProvider.notifier);

    return ListView(
      padding: lkFullScreenPadding,
      children: <Widget>[
        LkScreenHeader(
          title: l10n.toolTuner,
          subtitle: _subtitle(l10n, state),
        ),
        const SizedBox(height: LkSpacing.s6),

        if (state.status == TunerStatus.permissionRequired ||
            state.status == TunerStatus.permissionBlocked)
          TunerPermissionGate(
            isBlocked: state.status == TunerStatus.permissionBlocked,
            canOpenSettings: state.canOpenSettings,
            onAllow: controller.start,
            onOpenSettings: controller.openSettings,
          )
        else ...<Widget>[
          _Meter(state: state),
          const SizedBox(height: LkSpacing.s5),
          TunerStrings(
            tuning: state.tuning,
            selectedIndex: _selectedIndex(state),
            isEnabled: !state.isChromatic,
            onSelect: controller.selectString,
            onAuto: controller.selectAuto,
            isAuto: state.mode is AutoTargetMode,
          ),
          const SizedBox(height: LkSpacing.s5),
          _Transport(state: state, controller: controller),
        ],

        if (state.status == TunerStatus.failed && state.failure != null) ...[
          const SizedBox(height: LkSpacing.s5),
          _Failure(failure: state.failure!, onRetry: controller.start),
        ],

        const SizedBox(height: LkSpacing.s6),
        _TuningPicker(state: state, controller: controller),

        if (state.diagnostics != null) ...[
          const SizedBox(height: LkSpacing.s6),
          TunerDiagnosticsCard(diagnostics: state.diagnostics!),
        ],
      ],
    );
  }

  int? _selectedIndex(TunerState state) => switch (state.mode) {
    StringTargetMode(:final index) => index,
    AutoTargetMode() => state.reading?.targetStringIndex,
  };

  String _subtitle(AppLocalizations l10n, TunerState state) =>
      state.isChromatic ? l10n.tunerChromatic : tuningName(l10n, state.tuning);
}

/// The meter, and the words that go with whatever the tuner is hearing.
class _Meter extends StatelessWidget {
  const _Meter({required this.state});

  final TunerState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reading = state.reading;
    final label = _statusLabel(l10n, state);

    return Column(
      spacing: LkSpacing.s3,
      children: <Widget>[
        LkTunerMeter(
          // The note the microphone is hearing, not the one being tuned
          // towards. They diverge as soon as the string is more than half a
          // semitone out, and the player needs to know which note is
          // actually sounding (PRD.md §10.1, DESIGN.md §21).
          note: reading?.detectedNote.note.displayName,
          octave: reading?.detectedNote.octave,
          frequencyHz: reading?.frequencyHz,
          cents: reading?.cents,
          isInTune: reading?.isInTune ?? false,
          tuningLabel: state.isChromatic
              ? l10n.tunerChromatic
              : tuningName(l10n, state.tuning),
          referencePitchLabel: l10n.tunerReferencePitch(
            state.referenceHz.round(),
          ),
          statusLabel: label,
          semanticsLabel: l10n.tunerMeterSemantics(
            reading == null ? '—' : reading.detectedNote.name,
            label,
          ),
        ),
        if (_targetLine(l10n, state) case final target?)
          Text(
            target,
            textAlign: TextAlign.center,
            style: context.lkType.technicalSm.copyWith(
              color: context.lkColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (_guidance(l10n, state) case final guidance?)
          Text(
            guidance,
            textAlign: TextAlign.center,
            style: context.lkType.bodySmall.copyWith(
              color: context.lkColors.textSecondary,
            ),
          ),
      ],
    );
  }

  /// The centre readout. DESIGN.md §42 forbids meaning carried by colour
  /// alone, so this always says in words what the needle says in position and
  /// the orange says in colour.
  String _statusLabel(AppLocalizations l10n, TunerState state) {
    final reading = state.reading;
    if (reading != null) {
      if (reading.isInTune) return l10n.tunerInTune;
      final cents = reading.cents.round().abs();
      return reading.cents < 0
          ? l10n.tunerCentsFlat(cents)
          : l10n.tunerCentsSharp(cents);
    }
    return switch (state.status) {
      TunerStatus.noisy => l10n.tunerNoisy,
      TunerStatus.imperfectInput => l10n.tunerImperfectInput,
      TunerStatus.listening || TunerStatus.starting => l10n.tunerListening,
      // At rest the meter has nothing to report, and a dash says so without
      // repeating the button underneath it.
      _ => '—',
    };
  }

  /// Names the note being tuned towards, when it is not the note sounding.
  ///
  /// The needle and the cents figure always measure against the target, so
  /// once the string is more than half a semitone out the hero glyph and the
  /// number would otherwise appear to contradict one another. Naming the
  /// destination is what reconciles them, and it says nothing at all while
  /// the two agree.
  String? _targetLine(AppLocalizations l10n, TunerState state) {
    final reading = state.reading;
    if (reading == null) return null;
    if (reading.detectedNote == reading.targetNote) return null;
    return l10n.tunerTuningTo(reading.targetNote.name).toUpperCase();
  }

  String? _guidance(AppLocalizations l10n, TunerState state) {
    if (state.reading != null) return null;
    return switch (state.status) {
      TunerStatus.noisy => l10n.tunerNoisyBody,
      TunerStatus.imperfectInput => l10n.tunerImperfectInputBody,
      TunerStatus.listening || TunerStatus.starting => l10n.tunerListeningBody,
      _ => null,
    };
  }
}

class _Transport extends StatelessWidget {
  const _Transport({required this.state, required this.controller});

  final TunerState state;
  final TunerController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listening = state.isListening;

    // Listening is an explicit choice rather than something that happens on
    // arrival: the microphone is the largest battery cost in the product
    // (CLAUDE.md §50, PRD.md §63), and a player should be able to see when it
    // is open.
    if (listening) {
      return LkButton(
        label: l10n.tunerStop,
        onPressed: controller.stop,
        variant: LkButtonVariant.secondary,
        block: true,
      );
    }
    return LkButton(
      label: l10n.tunerStart,
      onPressed: controller.start,
      block: true,
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.failure, required this.onRetry});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(LkSpacing.s4),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        border: Border.all(color: colors.border, width: LkBorders.regular),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: LkSpacing.s3,
        children: <Widget>[
          Text(
            l10n.errorUnexpected,
            style: context.lkType.body.copyWith(color: colors.textPrimary),
          ),
          Text(
            l10n.errorUnexpectedBody,
            style: context.lkType.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          LkButton(
            label: l10n.commonRetry,
            onPressed: onRetry,
            variant: LkButtonVariant.secondary,
            size: LkButtonSize.medium,
          ),
        ],
      ),
    );
  }
}

class _TuningPicker extends ConsumerWidget {
  const _TuningPicker({required this.state, required this.controller});

  final TunerState state;
  final TunerController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final entries = ref.watch(tunerTuningsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: LkSpacing.s3,
      children: <Widget>[
        Text(
          l10n.fretboardTuning.toUpperCase(),
          style: context.lkType.label.copyWith(color: colors.textSecondary),
        ),
        Wrap(
          spacing: LkSpacing.s2,
          runSpacing: LkSpacing.s2,
          children: <Widget>[
            for (final entry in entries)
              _TuningChip(
                label: tuningName(l10n, entry.value),
                premiumLabel: l10n.commonPro,
                isPremium: entry.tier == FeatureTier.premium,
                isSelected: !state.isChromatic && state.tuning == entry.value,
                onTap: () => controller.selectTuning(entry.value),
              ),
            _TuningChip(
              label: l10n.tunerChromatic,
              premiumLabel: l10n.commonPro,
              isPremium: true,
              isSelected: state.isChromatic,
              onTap: controller.selectChromatic,
            ),
          ],
        ),
      ],
    );
  }
}

class _TuningChip extends StatelessWidget {
  const _TuningChip({
    required this.label,
    required this.premiumLabel,
    required this.isPremium,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String premiumLabel;
  final bool isPremium;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Semantics(
      button: true,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: LkDimens.tapTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: LkSpacing.s3,
            vertical: LkSpacing.s2,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.accent : colors.surface,
            border: Border.all(color: colors.border, width: LkBorders.regular),
            boxShadow: isSelected
                ? <BoxShadow>[LkShadows.sm(colors.border)]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: LkSpacing.s2,
            children: <Widget>[
              Text(
                label,
                style: context.lkType.technicalSm.copyWith(
                  color: isSelected ? colors.accentOn : colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // The badge is a label and authorizes nothing: every tuning in
              // this row selects (CLAUDE.md §23, PRD.md §44).
              if (isPremium) LkPremiumBadge(label: premiumLabel),
            ],
          ),
        ),
      ),
    );
  }
}
