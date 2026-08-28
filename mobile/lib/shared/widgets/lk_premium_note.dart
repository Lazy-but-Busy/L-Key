import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';

/// A one-line note about what Premium adds to the surface above it.
///
/// DESIGN.md §32 wants Premium to promise capability rather than luxury, so
/// this states the capability and marks it — nothing more.
class LkPremiumNote extends StatelessWidget {
  /// Creates a Premium note.
  const LkPremiumNote({required this.capability, super.key});

  /// The already-localised description of what Premium unlocks.
  final String capability;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: LkSpacing.s2,
      children: <Widget>[
        Flexible(
          child: Text(
            capability.toUpperCase(),
            textAlign: TextAlign.center,
            style: LkTypeScale.technicalSm.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ),
        LkPremiumBadge(label: l10n.commonPro),
      ],
    );
  }
}
