import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/music/tuning.dart';

/// The tuning's open strings, and the control that hands the choice back.
///
/// Drawn as a column with the first string on top, which is how a guitarist
/// reads a chord chart and how `LkFretboard` draws a neck. `Tuning` indexes
/// lowest-sounding first, so the rows iterate downwards and the guitarist's
/// string number is `stringCount - index` — the same arithmetic
/// `chord_diagram.dart` and `fretboard_neck.dart` already do.
///
/// The number is on screen as well as in the accessible label, because
/// "E2" alone does not tell a beginner which string to pluck.
class TunerStrings extends StatelessWidget {
  /// Creates the string list.
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
  ///
  /// When it is, a highlighted row is one the tuner *found*, so it says so
  /// in words rather than looking like something the player picked.
  final bool isAuto;

  /// Called when the player locks a string.
  final void Function(int index) onSelect;

  /// Called when the player hands the choice back.
  final VoidCallback onAuto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: LkSpacing.s3,
      children: <Widget>[
        Text(
          l10n.tunerStringsTitle.toUpperCase(),
          style: context.lkType.label.copyWith(color: colors.textSecondary),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: LkSpacing.s2,
          children: <Widget>[
            for (var index = tuning.stringCount - 1; index >= 0; index--)
              _StringRow(
                number: tuning.stringCount - index,
                note: tuning.openStrings[index].note.displayName,
                octave: tuning.openStrings[index].octave,
                semanticLabel: _semanticsFor(l10n, index),
                isSelected: isEnabled && index == selectedIndex,
                isHeard: isEnabled && isAuto && index == selectedIndex,
                heardLabel: l10n.tunerHearingSemantics,
                onTap: isEnabled ? () => onSelect(index) : null,
              ),
          ],
        ),
        if (isEnabled && !isAuto)
          Align(
            child: TextButton(
              onPressed: onAuto,
              child: Text(
                l10n.tunerAuto.toUpperCase(),
                style: context.lkType.technicalSm.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _semanticsFor(AppLocalizations l10n, int index) {
    // Guitarists count from the high E down, the opposite of the engine's
    // low-to-high indexing. Announcing the low E as "String 1" was the
    // reverse of what a player would say.
    final label = l10n.tunerStringSemantics(
      tuning.stringCount - index,
      tuning.openStrings[index].name,
    );
    return isEnabled && isAuto && index == selectedIndex
        ? '$label, ${l10n.tunerHearingSemantics}'
        : label;
  }
}

/// One string in the list.
class _StringRow extends StatelessWidget {
  const _StringRow({
    required this.number,
    required this.note,
    required this.octave,
    required this.semanticLabel,
    required this.isSelected,
    required this.isHeard,
    required this.heardLabel,
    required this.onTap,
  });

  final int number;
  final String note;
  final int octave;
  final String semanticLabel;
  final bool isSelected;
  final bool isHeard;
  final String heardLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final foreground = isSelected ? colors.accentOn : colors.textPrimary;

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
            constraints: const BoxConstraints(minHeight: LkDimens.tapTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: LkSpacing.s4,
              vertical: LkSpacing.s2,
            ),
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
            child: Row(
              spacing: LkSpacing.s4,
              children: <Widget>[
                SizedBox(
                  width: LkSpacing.s4,
                  child: Text(
                    '$number',
                    textAlign: TextAlign.center,
                    style: context.lkType.technicalSm.copyWith(
                      color: isSelected ? colors.accentOn : colors.textTertiary,
                    ),
                  ),
                ),
                Text(
                  '$note$octave',
                  style: context.lkType.technical.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // DESIGN.md §42 — the orange fill is never the only thing
                // saying which string the tuner has found.
                if (isHeard)
                  Text(
                    heardLabel.toUpperCase(),
                    style: context.lkType.technicalSm.copyWith(
                      color: foreground,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
