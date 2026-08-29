import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/music/tuning.dart';

/// The row of open strings, and the control that hands the choice back.
///
/// Strings are drawn lowest-sounding first, matching `Tuning.openStrings` and
/// the order a chord diagram uses. That is the opposite of the guitarist's
/// "sixth string", which is why the accessible label says the string's note
/// rather than a number the player might read the other way round.
class TunerStrings extends StatelessWidget {
  /// Creates the string row.
  const TunerStrings({
    required this.tuning,
    required this.selectedIndex,
    required this.isEnabled,
    required this.isAuto,
    required this.onSelect,
    required this.onAuto,
    super.key,
  });

  /// The tuning whose open strings are shown.
  final Tuning tuning;

  /// Which string is highlighted, whether chosen or found.
  final int? selectedIndex;

  /// Whether a string can be chosen at all. False in chromatic mode.
  final bool isEnabled;

  /// Whether the tuner is choosing the string itself.
  final bool isAuto;

  /// Called when the player locks a string.
  final void Function(int index) onSelect;

  /// Called when the player hands the choice back.
  final VoidCallback onAuto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      spacing: LkSpacing.s3,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.center,
          spacing: LkSpacing.s2,
          runSpacing: LkSpacing.s2,
          children: <Widget>[
            for (var i = 0; i < tuning.stringCount; i++)
              _StringButton(
                label: tuning.openStrings[i].note.displayName,
                octave: tuning.openStrings[i].octave,
                semanticLabel: l10n.tunerStringSemantics(
                  i + 1,
                  tuning.openStrings[i].name,
                ),
                isSelected: isEnabled && i == selectedIndex,
                onTap: isEnabled ? () => onSelect(i) : null,
              ),
          ],
        ),
        if (isEnabled && !isAuto)
          TextButton(
            onPressed: onAuto,
            child: Text(
              l10n.tunerAuto.toUpperCase(),
              style: context.lkType.technicalSm.copyWith(
                color: context.lkColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _StringButton extends StatelessWidget {
  const _StringButton({
    required this.label,
    required this.octave,
    required this.semanticLabel,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int octave;
  final String semanticLabel;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Semantics(
      button: true,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      enabled: onTap != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: onTap == null ? LkOpacity.disabled : 1,
          child: Container(
            width: LkDimens.buttonHeightMd,
            height: LkDimens.tapTarget,
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
              '$label$octave',
              style: context.lkType.technicalSm.copyWith(
                color: isSelected ? colors.accentOn : colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
