import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';
import 'package:l_key/shared/widgets/lk_pressable.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';

/// One row in the Tools hub.
@immutable
class _Tool {
  const _Tool({required this.label, this.route, this.isPremium = false});

  final String label;
  final String? route;
  final bool isPremium;
}

/// The Tools hub.
///
/// Premium rows carry the `PRO` badge and are not navigable. That is a
/// presentational lock only — there is no entitlement source yet, and
/// PRD.md §46 puts that decision on the server, so nothing here decides
/// anything about access.
class ToolsPage extends StatelessWidget {
  /// Creates the Tools hub.
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final tools = <_Tool>[
      _Tool(label: l10n.toolTuner, route: AppRoutes.tunerName),
      _Tool(label: l10n.toolMetronome, route: AppRoutes.metronomeName),
      _Tool(label: l10n.toolChords, route: AppRoutes.chordsName),
      _Tool(label: l10n.toolScales, route: AppRoutes.scalesName),
      _Tool(label: l10n.toolTransposer),
      _Tool(label: l10n.toolCapo),
      _Tool(label: l10n.toolEarTraining, isPremium: true),
      _Tool(label: l10n.toolRecording, isPremium: true),
    ];

    return ListView(
      padding: lkScreenPadding,
      children: <Widget>[
        LkScreenHeader(title: l10n.toolsTitle, subtitle: l10n.toolsSubtitle),
        const SizedBox(height: LkSpacing.s6),
        for (final tool in tools) ...<Widget>[
          _ToolRow(tool: tool),
          const SizedBox(height: LkSpacing.s4),
        ],
      ],
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({required this.tool});

  final _Tool tool;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final route = tool.route;

    final available = route != null && !tool.isPremium;
    final semantics = tool.isPremium
        ? '${tool.label}, ${l10n.premiumLocked}'
        : route == null
        ? '${tool.label}, ${l10n.commonComingSoon}'
        : tool.label;

    return LkPressable(
      onTap: available ? () => context.goNamed(route) : null,
      enabled: available,
      padding: const EdgeInsets.symmetric(horizontal: LkSpacing.s4),
      semanticLabel: semantics,
      child: Row(
        spacing: LkSpacing.s3,
        children: <Widget>[
          Flexible(
            child: Text(
              tool.label,
              style: LkTypeScale.h4.copyWith(color: colors.textPrimary),
            ),
          ),
          if (tool.isPremium) LkPremiumBadge(label: l10n.commonPro),
          const Spacer(),
          Icon(
            available ? Icons.chevron_right : Icons.lock_outline,
            size: LkSpacing.s5,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
