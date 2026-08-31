import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/features/metronome/domain/click_sound.dart';
import 'package:l_key/features/metronome/domain/metronome_state.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';
import 'package:l_key/features/metronome/presentation/metronome_controller.dart';
import 'package:l_key/features/metronome/presentation/widgets/metronome_beat_indicator.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';
import 'package:l_key/shared/widgets/lk_premium_note.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_section_header.dart';
import 'package:l_key/shared/widgets/lk_segmented_control.dart';

/// The metronome screen.
///
/// It lays out and nothing else. Which beat is sounding, where it falls in the
/// bar and how much emphasis it carries all arrive already decided from
/// `metronome/domain`, and the speaker's lifetime belongs to the controller
/// (CLAUDE.md §8, §14).
class MetronomePage extends ConsumerWidget {
  /// Creates the metronome screen.
  const MetronomePage({super.key});

  /// How far one press of the tempo stepper moves.
  ///
  /// One, not the four the Phase 02 layout used: a metronome that cannot be
  /// set to 92 is not a metronome. Holding repeats, so the range is still
  /// crossable in a couple of seconds.
  static const int bpmStep = 1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(metronomeProvider);
    final controller = ref.read(metronomeProvider.notifier);
    final settings = state.settings;

    return LkDetailScaffold(
      title: l10n.toolMetronome,
      fallbackRoute: AppRoutes.tools,
      child: ListView(
        padding: lkScreenPadding,
        children: <Widget>[
          LkScreenHeader(
            title: l10n.toolMetronome,
            subtitle: '${settings.signature.label} · ${settings.bpm} BPM',
          ),
          const SizedBox(height: LkSpacing.s6),

          _TransportCard(state: state, controller: controller),

          if (state.status == MetronomeStatus.unavailable) ...<Widget>[
            const SizedBox(height: LkSpacing.s4),
            _Notice(message: l10n.metronomeUnavailable),
          ],
          if (state.isStruggling) ...<Widget>[
            const SizedBox(height: LkSpacing.s4),
            _Notice(message: l10n.metronomeStruggling),
          ],
          const SizedBox(height: LkSpacing.s6),

          LkSectionHeader(title: l10n.metronomeSignature),
          const SizedBox(height: LkSpacing.s3),
          _SignaturePicker(state: state, controller: controller),
          const SizedBox(height: LkSpacing.s6),

          LkSectionHeader(title: l10n.metronomeAccents),
          const SizedBox(height: LkSpacing.s3),
          _AccentEditor(state: state, controller: controller),
          const SizedBox(height: LkSpacing.s6),

          LkSectionHeader(title: l10n.metronomeSubdivision),
          const SizedBox(height: LkSpacing.s3),
          LkSegmentedControl<Subdivision>(
            segments: <Subdivision, String>{
              Subdivision.none: l10n.metronomeSubdivisionNone,
              Subdivision.duple: l10n.metronomeSubdivisionDuple,
              Subdivision.triple: l10n.metronomeSubdivisionTriple,
              Subdivision.quadruple: l10n.metronomeSubdivisionQuadruple,
            },
            selected: settings.subdivision,
            onChanged: controller.setSubdivision,
          ),
          const SizedBox(height: LkSpacing.s6),

          LkSectionHeader(title: l10n.metronomeSound),
          const SizedBox(height: LkSpacing.s3),
          _SoundPicker(state: state, controller: controller),
          const SizedBox(height: LkSpacing.s6),

          LkSectionHeader(title: l10n.metronomeCountIn),
          const SizedBox(height: LkSpacing.s3),
          LkSegmentedControl<CountIn>(
            segments: <CountIn, String>{
              CountIn.none: l10n.metronomeCountInNone,
              CountIn.oneBar: l10n.metronomeCountInOneBar,
              CountIn.twoBars: l10n.metronomeCountInTwoBars,
            },
            selected: settings.countIn,
            onChanged: controller.setCountIn,
          ),
          const SizedBox(height: LkSpacing.s5),

          _HapticsToggle(state: state, controller: controller),
          const SizedBox(height: LkSpacing.s6),

          LkPremiumNote(capability: l10n.metronomeProNote),
        ],
      ),
    );
  }
}

/// The tempo, the beat and the transport.
class _TransportCard extends StatelessWidget {
  const _TransportCard({required this.state, required this.controller});

  final MetronomeState state;
  final MetronomeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final settings = state.settings;

    return Container(
      padding: const EdgeInsets.all(LkSpacing.s6),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border, width: LkBorders.regular),
        boxShadow: <BoxShadow>[LkShadows.regular(colors.border)],
      ),
      child: Column(
        spacing: LkSpacing.s6,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: LkSpacing.s4,
            children: <Widget>[
              _StepButton(
                icon: Icons.remove,
                semanticLabel: l10n.metronomeSlower,
                onTap: () => controller.nudgeBpm(-MetronomePage.bpmStep),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${settings.bpm}',
                    style: context.lkType.displayXl.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.metronomeBpm,
                    style: context.lkType.label.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              _StepButton(
                icon: Icons.add,
                semanticLabel: l10n.metronomeFaster,
                onTap: () => controller.nudgeBpm(MetronomePage.bpmStep),
              ),
            ],
          ),

          MetronomeBeatIndicator(
            accents: settings.accents,
            beat: state.beat,
            isRunning: state.isRunning,
          ),

          if (state.status == MetronomeStatus.countingIn)
            Text(
              l10n.metronomeCountingIn,
              style: context.lkType.label.copyWith(color: colors.accent),
            ),

          Row(
            spacing: LkSpacing.s3,
            children: <Widget>[
              Expanded(
                child: _TapButton(controller: controller),
              ),
              Expanded(
                child: LkButton(
                  label: state.isRunning
                      ? l10n.metronomeStop
                      : l10n.metronomeStart,
                  variant: state.isRunning
                      ? LkButtonVariant.secondary
                      : LkButtonVariant.accent,
                  onPressed: controller.toggle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The tap-tempo button, which counts while a phrase is in progress.
class _TapButton extends StatefulWidget {
  const _TapButton({required this.controller});

  final MetronomeController controller;

  @override
  State<_TapButton> createState() => _TapButtonState();
}

class _TapButtonState extends State<_TapButton> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LkButton(
      label: _taps > 1 ? l10n.metronomeTapAgain(_taps) : l10n.metronomeTap,
      variant: LkButtonVariant.secondary,
      onPressed: () => setState(() => _taps = widget.controller.tap()),
    );
  }
}

/// The meter picker.
class _SignaturePicker extends ConsumerWidget {
  const _SignaturePicker({required this.state, required this.controller});

  final MetronomeState state;
  final MetronomeController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(metronomeSignaturesProvider);
    return Wrap(
      spacing: LkSpacing.s2,
      runSpacing: LkSpacing.s2,
      children: <Widget>[
        for (final entry in entries)
          _Choice(
            label: entry.value.label,
            isSelected: entry.value == state.settings.signature,
            tier: entry.tier,
            onTap: () => controller.setSignature(entry.value),
          ),
      ],
    );
  }
}

/// The click-voice picker.
class _SoundPicker extends ConsumerWidget {
  const _SoundPicker({required this.state, required this.controller});

  final MetronomeState state;
  final MetronomeController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(metronomeSoundsProvider);

    String name(ClickSound sound) => switch (sound) {
      ClickSound.woodblock => l10n.metronomeSoundWoodblock,
      ClickSound.click => l10n.metronomeSoundClick,
      ClickSound.beep => l10n.metronomeSoundBeep,
      ClickSound.stick => l10n.metronomeSoundStick,
    };

    return Wrap(
      spacing: LkSpacing.s2,
      runSpacing: LkSpacing.s2,
      children: <Widget>[
        for (final entry in entries)
          _Choice(
            label: name(entry.value),
            isSelected: entry.value == state.settings.sound,
            tier: entry.tier,
            onTap: () => controller.setSound(entry.value),
          ),
      ],
    );
  }
}

/// One beat's emphasis, tapped to cycle.
///
/// A separate control from the indicator on purpose: a target that also
/// repaints on every beat is a poor one to hit.
class _AccentEditor extends StatelessWidget {
  const _AccentEditor({required this.state, required this.controller});

  final MetronomeState state;
  final MetronomeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    String name(AccentLevel level) => switch (level) {
      AccentLevel.strong => l10n.metronomeAccentStrong,
      AccentLevel.accent => l10n.metronomeAccentAccent,
      AccentLevel.silent => l10n.metronomeAccentSilent,
      _ => l10n.metronomeAccentNormal,
    };

    return Wrap(
      spacing: LkSpacing.s2,
      runSpacing: LkSpacing.s2,
      children: <Widget>[
        for (var i = 0; i < state.settings.accents.length; i++)
          Semantics(
            button: true,
            label: l10n.metronomeAccentSemantics(
              i + 1,
              name(state.settings.accents[i]),
            ),
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => controller.cycleAccent(i),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: LkDimens.tapTarget,
                height: LkDimens.tapTarget,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: switch (state.settings.accents[i]) {
                    AccentLevel.strong || AccentLevel.accent => colors.accent,
                    AccentLevel.silent => colors.surfaceSunken,
                    _ => colors.surface,
                  },
                  border: Border.all(
                    color: colors.border,
                    width: LkBorders.regular,
                  ),
                ),
                child: Text(
                  // The level is spelled out, never carried by the fill alone
                  // (DESIGN.md §42).
                  switch (state.settings.accents[i]) {
                    AccentLevel.strong => '1',
                    AccentLevel.accent => '>',
                    AccentLevel.silent => '–',
                    _ => '·',
                  },
                  style: context.lkType.technical.copyWith(
                    color: switch (state.settings.accents[i]) {
                      AccentLevel.strong ||
                      AccentLevel.accent => colors.accentOn,
                      AccentLevel.silent => colors.textTertiary,
                      _ => colors.textPrimary,
                    },
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The beat-haptic switch.
class _HapticsToggle extends StatelessWidget {
  const _HapticsToggle({required this.state, required this.controller});

  final MetronomeState state;
  final MetronomeController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            l10n.metronomeHaptics,
            style: context.lkType.body.copyWith(color: colors.textPrimary),
          ),
        ),
        Switch(
          value: state.settings.hapticsEnabled,
          onChanged: (value) => controller.setHaptics(enabled: value),
        ),
      ],
    );
  }
}

/// A choice chip carrying a tier label that grants nothing.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.isSelected,
    required this.tier,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final FeatureTier tier;
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
          height: LkDimens.tapTarget,
          padding: const EdgeInsets.symmetric(horizontal: LkSpacing.s3),
          decoration: BoxDecoration(
            color: isSelected ? colors.surfaceInverse : colors.surface,
            border: Border.all(color: colors.border, width: LkBorders.regular),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: LkSpacing.s2,
            children: <Widget>[
              Text(
                label,
                style: context.lkType.technical.copyWith(
                  color: isSelected ? colors.textInverse : colors.textPrimary,
                ),
              ),
              // The label is presentational. Every row here opens: entitlement
              // is the server's decision (CLAUDE.md §23, §51).
              if (tier == FeatureTier.premium)
                LkPremiumBadge(label: AppLocalizations.of(context).commonPro),
            ],
          ),
        ),
      ),
    );
  }
}

/// A plain line of text the screen owes the player.
class _Notice extends StatelessWidget {
  const _Notice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    return Container(
      padding: const EdgeInsets.all(LkSpacing.s4),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        border: Border.all(color: colors.border, width: LkBorders.regular),
      ),
      child: Text(
        message,
        style: context.lkType.bodySmall.copyWith(color: colors.textPrimary),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: LkDimens.buttonHeightMd,
          height: LkDimens.buttonHeightMd,
          decoration: BoxDecoration(
            color: colors.surfaceInverse,
            border: Border.all(color: colors.border, width: LkBorders.regular),
          ),
          child: Icon(icon, color: colors.textInverse),
        ),
      ),
    );
  }
}
