import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/shared/widgets/lk_button.dart';

/// What the tuner shows when it has no microphone to listen with.
///
/// Three outcomes with three different next steps (CLAUDE.md §37). Before
/// asking, it says what the microphone is for and what happens to the audio,
/// because a permission prompt with no context is one people decline. Once
/// refused for good, the only thing that helps is the system settings — a
/// retry button would fail forever. And where the device itself forbids it,
/// no button is offered at all, because there is nothing there to change.
class TunerPermissionGate extends StatelessWidget {
  /// Creates the gate.
  const TunerPermissionGate({
    required this.isBlocked,
    required this.canOpenSettings,
    required this.onAllow,
    required this.onOpenSettings,
    super.key,
  });

  /// Whether access was refused for good, rather than merely not yet given.
  final bool isBlocked;

  /// Whether the system settings would help.
  final bool canOpenSettings;

  /// Asks the operating system for access.
  final VoidCallback onAllow;

  /// Opens this app's page in the system settings.
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    final (headline, body) = switch ((isBlocked, canOpenSettings)) {
      (false, _) => (l10n.tunerMicNeeded, l10n.tunerMicNeededBody),
      (true, true) => (l10n.tunerMicBlocked, l10n.tunerMicBlockedBody),
      (true, false) => (l10n.tunerMicRestricted, l10n.tunerMicRestrictedBody),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LkSpacing.s6),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border, width: LkBorders.regular),
        boxShadow: <BoxShadow>[LkShadows.regular(colors.border)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: LkSpacing.s4,
        children: <Widget>[
          Text(
            headline,
            style: context.lkType.h3.copyWith(color: colors.textPrimary),
          ),
          Text(
            body,
            style: context.lkType.body.copyWith(color: colors.textSecondary),
          ),
          if (!isBlocked)
            LkButton(
              label: l10n.tunerAllowMicrophone,
              onPressed: onAllow,
              block: true,
            )
          else if (canOpenSettings)
            LkButton(
              label: l10n.commonOpenSettings,
              onPressed: onOpenSettings,
              variant: LkButtonVariant.secondary,
              block: true,
            ),
        ],
      ),
    );
  }
}
