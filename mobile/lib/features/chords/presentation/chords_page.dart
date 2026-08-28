import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_skeleton.dart';

/// The chord library screen — layout only.
///
/// No chord is computed here. The chord engine (names, intervals, voicings,
/// fingerings, transposition) is the next phase's work, and CLAUDE.md §11
/// forbids doing that arithmetic inside a widget, so the diagram area shows
/// its structure rather than an invented shape.
class ChordsPage extends StatelessWidget {
  /// Creates the chord library screen.
  const ChordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    return ListView(
      padding: lkFullScreenPadding,
      children: <Widget>[
        LkScreenHeader(
          title: l10n.toolChords,
          subtitle: l10n.chordsSubtitle,
        ),
        const SizedBox(height: LkSpacing.s6),
        Container(
          padding: const EdgeInsets.all(LkSpacing.s6),
          decoration: BoxDecoration(
            color: colors.surface,
            boxShadow: <BoxShadow>[LkShadows.regular(colors.border)],
          ),
          child: const LkSkeletonList(itemCount: 4),
        ),
        const SizedBox(height: LkSpacing.s6),
        LkPendingNote(message: l10n.chordsPending),
      ],
    );
  }
}
