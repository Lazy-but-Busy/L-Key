import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:l_key/shared/widgets/lk_card.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_icon_button.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_segmented_control.dart';

/// The settings screen.
///
/// Reachable from the top bar of every section, which is why it pushes above
/// the shell rather than living inside one: binding it to a tab would move the
/// player somewhere they did not ask to go.
class SettingsPage extends ConsumerWidget {
  /// Creates the settings screen.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return LkDetailScaffold(
      title: l10n.settingsTitle,
      fallbackRoute: AppRoutes.profile,
      child: ListView(
        padding: lkScreenPadding,
        children: <Widget>[
          LkScreenHeader(title: l10n.settingsTitle),
          const SizedBox(height: LkSpacing.s6),

          Text(
            l10n.settingsSectionGeneral.toUpperCase(),
            style: context.lkType.label.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: LkSpacing.s3),
          LkCard(
            variant: LkCardVariant.ring,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: LkSpacing.s5,
              children: <Widget>[
                _Row(
                  label: l10n.settingsLanguage,
                  control: LkSegmentedControl<String>(
                    segments: <String, String>{
                      'my': l10n.settingsLanguageMyanmar,
                      'en': l10n.settingsLanguageEnglish,
                    },
                    selected:
                        settings.locale?.languageCode ??
                        Localizations.localeOf(context).languageCode,
                    onChanged: (code) => controller.setLocale(Locale(code)),
                  ),
                ),
                _Row(
                  label: l10n.settingsAppearance,
                  control: LkSegmentedControl<ThemeMode>(
                    segments: <ThemeMode, String>{
                      ThemeMode.system: l10n.settingsThemeSystem,
                      ThemeMode.light: l10n.settingsThemeLight,
                      ThemeMode.dark: l10n.settingsThemeDark,
                    },
                    selected: settings.themeMode,
                    onChanged: controller.setThemeMode,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: LkSpacing.s6),

          Text(
            l10n.settingsSectionAudio.toUpperCase(),
            style: context.lkType.label.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: LkSpacing.s3),
          LkCard(
            variant: LkCardVariant.ring,
            child: _Row(
              label: l10n.settingsReferencePitch,
              control: _ReferencePitch(
                hz: settings.referencePitchHz,
                onChanged: controller.setReferencePitch,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.control});

  final String label;
  final Widget control;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: LkSpacing.s2,
      children: <Widget>[
        Text(
          label,
          style: context.lkType.body.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        control,
      ],
    );
  }
}

/// A stepper for the tuning reference.
///
/// A stepper rather than a slider or a text field: the values that matter are
/// whole hertz a few either side of 440, and a player nudging to 442 should
/// not have to aim at a track or open a keyboard. The range is the one
/// orchestras and period instruments actually use.
class _ReferencePitch extends StatelessWidget {
  const _ReferencePitch({required this.hz, required this.onChanged});

  final double hz;
  final void Function(double hz) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: LkSpacing.s2,
      children: <Widget>[
        LkIconButton(
          icon: Icons.remove,
          semanticLabel: l10n.settingsReferencePitchLower,
          onPressed: hz > Settings.minimumReferencePitchHz
              ? () => onChanged(hz - 1)
              : null,
          variant: LkIconButtonVariant.ring,
          size: LkDimens.iconBoxSm,
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            '${hz.round()} Hz',
            style: context.lkType.technical.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        LkIconButton(
          icon: Icons.add,
          semanticLabel: l10n.settingsReferencePitchRaise,
          onPressed: hz < Settings.maximumReferencePitchHz
              ? () => onChanged(hz + 1)
              : null,
          variant: LkIconButtonVariant.ring,
          size: LkDimens.iconBoxSm,
        ),
      ],
    );
  }
}
