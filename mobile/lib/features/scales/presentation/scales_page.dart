import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/shared/widgets/lk_chip.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_skeleton.dart';

/// The scales screen — layout only.
///
/// The formula and root shown are static placeholders. Generating scale
/// positions from a key and a formula is the scale engine's job in the next
/// phase, and it must stay Flutter-free (CLAUDE.md §12).
class ScalesPage extends StatelessWidget {
  /// Creates the scales screen.
  const ScalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    return ListView(
      padding: lkFullScreenPadding,
      children: <Widget>[
        LkScreenHeader(
          title: l10n.toolScales,
          subtitle: l10n.scalesSubtitle,
        ),
        const SizedBox(height: LkSpacing.s6),
        Row(
          spacing: LkSpacing.s4,
          children: <Widget>[
            Expanded(
              child: LkStatChip(
                label: l10n.scalesFormula,
                value: '1 b3 4 5 b7',
              ),
            ),
            Expanded(
              child: LkStatChip(label: l10n.scalesRoot, value: 'A'),
            ),
          ],
        ),
        const SizedBox(height: LkSpacing.s6),
        Container(
          padding: const EdgeInsets.all(LkSpacing.s4),
          decoration: BoxDecoration(
            color: colors.surface,
            boxShadow: <BoxShadow>[LkShadows.regular(colors.border)],
          ),
          child: const LkSkeletonList(itemCount: 6, itemHeight: LkSpacing.s6),
        ),
        const SizedBox(height: LkSpacing.s6),
        LkPendingNote(message: l10n.scalesPending),
      ],
    );
  }
}
