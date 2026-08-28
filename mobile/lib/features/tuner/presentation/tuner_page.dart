import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_premium_note.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';

/// The six strings of standard tuning.
const List<({String note, int octave})> _standardTuning =
    <({String note, int octave})>[
      (note: 'E', octave: 2),
      (note: 'A', octave: 2),
      (note: 'D', octave: 3),
      (note: 'G', octave: 3),
      (note: 'B', octave: 3),
      (note: 'E', octave: 4),
    ];

/// The tuner screen — layout only.
///
/// There is no microphone, no pitch detection and no needle movement here.
/// `PitchDetector` exists as an interface with no implementation, and
/// CLAUDE.md §47 forbids simulating accuracy, so the meter sits at rest and
/// the screen says plainly that listening arrives with the audio phase.
class TunerPage extends ConsumerStatefulWidget {
  /// Creates the tuner screen.
  const TunerPage({super.key});

  @override
  ConsumerState<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends ConsumerState<TunerPage> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final pitch = ref.watch(
      settingsProvider.select((s) => s.referencePitchHz),
    );
    final string = _standardTuning[_selected];

    return LkDetailScaffold(
      title: l10n.toolTuner,
      fallbackRoute: AppRoutes.tools,
      child: ListView(
        padding: lkScreenPadding,
        children: <Widget>[
          LkScreenHeader(
            title: l10n.toolTuner,
            subtitle: l10n.tunerSubtitle,
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
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  spacing: LkSpacing.s2,
                  children: <Widget>[
                    Text(
                      string.note,
                      style: LkTypeScale.displayXl.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      '${string.octave}',
                      style: LkTypeScale.h2.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
                // The needle rests at centre because nothing is listening.
                _RestingMeter(),
                Text(
                  '${l10n.homeQuickTuneTuning.toUpperCase()} · '
                  '${pitch.round()} HZ',
                  style: LkTypeScale.technical.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: LkSpacing.s6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (var i = 0; i < _standardTuning.length; i++)
                _StringButton(
                  label:
                      '${_standardTuning[i].note}${_standardTuning[i].octave}',
                  isSelected: i == _selected,
                  onTap: () => setState(() => _selected = i),
                ),
            ],
          ),
          const SizedBox(height: LkSpacing.s6),

          LkPendingNote(message: l10n.tunerPending),
          const SizedBox(height: LkSpacing.s4),
          LkPremiumNote(capability: l10n.tunerProNote),
        ],
      ),
    );
  }
}

class _RestingMeter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Container(
      height: LkDimens.buttonHeightMd,
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        border: Border.all(color: colors.border, width: LkBorders.regular),
      ),
      child: Center(
        child: Container(
          width: LkBorders.regular,
          height: LkDimens.buttonHeightMd,
          color: colors.border,
        ),
      ),
    );
  }
}

class _StringButton extends StatelessWidget {
  const _StringButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
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
          width: LkDimens.buttonHeightMd,
          height: LkDimens.buttonHeightMd,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.accent : colors.surface,
            border: Border.all(
              color: colors.border,
              width: LkBorders.regular,
            ),
            boxShadow: isSelected
                ? <BoxShadow>[LkShadows.sm(colors.border)]
                : null,
          ),
          child: Text(
            label,
            style: LkTypeScale.technical.copyWith(
              color: isSelected ? colors.accentOn : colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
