import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// A compact statistic: an uppercase caption over a value.
///
/// Used for the streak / practice / best-BPM rows. Numbers are musical facts,
/// so the value is always set in the technical face and never rounded for
/// looks.
class LkStatChip extends StatelessWidget {
  /// Creates a statistic chip.
  const LkStatChip({required this.label, required this.value, super.key});

  /// Uppercase localised caption.
  final String label;

  /// The already-formatted value.
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Semantics(
      label: '$label $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(LkSpacing.s4),
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          boxShadow: <BoxShadow>[LkShadows.regular(colors.border)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: LkSpacing.s1,
          children: <Widget>[
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: context.lkType.label.copyWith(color: colors.textSecondary),
            ),
            Text(
              value,
              textAlign: TextAlign.center,
              style: context.lkType.technical.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
