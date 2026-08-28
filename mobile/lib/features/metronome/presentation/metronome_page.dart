import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_premium_note.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_segmented_control.dart';

/// The metronome screen — layout only.
///
/// The tempo and time signature are real, editable state, but nothing sounds
/// and no beat advances: timing belongs to the audio phase, and a metronome
/// that looked like it was running without keeping time would be exactly the
/// faked functionality CLAUDE.md §47 rules out.
class MetronomePage extends StatefulWidget {
  /// Creates the metronome screen.
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {
  static const int _minBpm = 30;
  static const int _maxBpm = 240;
  static const int _step = 4;

  int _bpm = 120;
  String _signature = '4/4';

  void _nudge(int delta) {
    setState(() => _bpm = (_bpm + delta).clamp(_minBpm, _maxBpm));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final beats = int.parse(_signature.split('/').first);

    return ListView(
      padding: lkFullScreenPadding,
      children: <Widget>[
        LkScreenHeader(
          title: l10n.toolMetronome,
          subtitle: l10n.metronomeSubtitle,
        ),
        const SizedBox(height: LkSpacing.s6),

        Container(
          padding: const EdgeInsets.all(LkSpacing.s6),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(
              color: colors.border,
              width: LkBorders.regular,
            ),
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
                    onTap: () => _nudge(-_step),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '$_bpm',
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
                    onTap: () => _nudge(_step),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: LkSpacing.s2,
                children: <Widget>[
                  for (var i = 0; i < beats; i++)
                    Container(
                      width: i == 0 ? LkSpacing.s4 : LkSpacing.s3,
                      height: i == 0 ? LkSpacing.s4 : LkSpacing.s3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.border,
                          width: LkBorders.regular,
                        ),
                      ),
                    ),
                ],
              ),
              LkSegmentedControl<String>(
                segments: const <String, String>{
                  '4/4': '4/4',
                  '3/4': '3/4',
                  '6/8': '6/8',
                },
                selected: _signature,
                onChanged: (value) => setState(() => _signature = value),
              ),
              Row(
                spacing: LkSpacing.s3,
                children: <Widget>[
                  Expanded(
                    child: LkButton(
                      label: l10n.metronomeTap,
                      variant: LkButtonVariant.secondary,
                    ),
                  ),
                  Expanded(
                    child: LkButton(
                      label: l10n.practiceStart,
                      variant: LkButtonVariant.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: LkSpacing.s6),

        LkPendingNote(message: l10n.metronomePending),
        const SizedBox(height: LkSpacing.s4),
        LkPremiumNote(capability: l10n.metronomeProNote),
      ],
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
            border: Border.all(
              color: colors.border,
              width: LkBorders.regular,
            ),
          ),
          child: Icon(icon, color: colors.textInverse),
        ),
      ),
    );
  }
}
