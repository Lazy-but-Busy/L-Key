import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// The single Premium signal in the system.
///
/// DESIGN.md §32 and §69 are explicit: no gold, no gradients, no glow —
/// Premium is the word `PRO` on Guitar Orange. The word is always present, so
/// the badge never carries its meaning by colour alone (DESIGN.md §42).
///
/// This is presentational only. It reflects a caller's claim about a feature,
/// never an entitlement decision — those are server-side (PRD.md §46).
class LkPremiumBadge extends StatelessWidget {
  /// Creates a badge.
  const LkPremiumBadge({required this.label, super.key, this.inverse = false});

  /// The localised badge text, conventionally `PRO`.
  final String label;

  /// Renders black-on-inverse instead of the orange fill, for use on a
  /// surface that is already orange.
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: inverse ? colors.surfaceInverse : colors.accent,
        border: Border.all(color: colors.border, width: LkBorders.regular),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: LkSpacing.s2,
          vertical: LkSpacing.s1,
        ),
        child: Text(
          label.toUpperCase(),
          style: LkTypeScale.label.copyWith(
            color: inverse ? colors.textInverse : colors.accentOn,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
