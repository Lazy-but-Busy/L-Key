import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_routes.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_card.dart';
import 'package:l_key/shared/widgets/lk_chip.dart';
import 'package:l_key/shared/widgets/lk_detail_scaffold.dart';
import 'package:l_key/shared/widgets/lk_screen_header.dart';
import 'package:l_key/shared/widgets/lk_segmented_control.dart';

/// The Profile screen: identity, statistics, Premium entry and settings.
///
/// The player is always a guest here. Accounts arrive with the backend, and
/// PRD.md §9 keeps the core tools usable without one, so nothing on this
/// screen gates behind sign-in.
class ProfilePage extends ConsumerWidget {
  /// Creates the Profile screen.
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return ListView(
      padding: lkScreenPadding,
      children: <Widget>[
        LkScreenHeader(title: l10n.navProfile),
        const SizedBox(height: LkSpacing.s6),

        LkCard(
          variant: LkCardVariant.ring,
          padding: const EdgeInsets.all(LkSpacing.s3),
          child: Row(
            spacing: LkSpacing.s4,
            children: <Widget>[
              Container(
                width: LkDimens.iconBoxLg,
                height: LkDimens.iconBoxLg,
                decoration: BoxDecoration(
                  color: colors.surfaceSunken,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.border,
                    width: LkBorders.regular,
                  ),
                ),
                child: Icon(Icons.person, color: colors.textSecondary),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      l10n.profileGuest,
                      style: context.lkType.bodyLarge.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.profileMemberSince(DateTime.now().year),
                      style: context.lkType.label.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: LkSpacing.s6),

        Row(
          spacing: LkSpacing.s4,
          children: <Widget>[
            Expanded(
              child: LkStatChip(
                label: l10n.practiceStatStreak,
                value: l10n.practiceStreakDays(6),
              ),
            ),
            Expanded(
              child: LkStatChip(
                label: l10n.profileStatPractice,
                value: '14.2',
              ),
            ),
            Expanded(
              child: LkStatChip(label: l10n.profileStatSongs, value: '18'),
            ),
          ],
        ),
        const SizedBox(height: LkSpacing.s6),

        // Premium is presentational only: there is no entitlement source yet
        // and PRD.md §46 puts that decision on the server.
        LkCard(
          tone: LkCardTone.accent,
          title: l10n.profileGoPro,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: LkSpacing.s3,
            children: <Widget>[
              Text(
                l10n.profileGoProBody,
                style: context.lkType.body.copyWith(color: colors.accentOn),
              ),
              LkButton(label: l10n.profileSeePlans, block: true),
            ],
          ),
        ),
        const SizedBox(height: LkSpacing.s6),

        LkCard(
          variant: LkCardVariant.ring,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: LkSpacing.s4,
            children: <Widget>[
              _SettingRow(
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
              _SettingRow(
                label: l10n.settingsAppearance,
                control: LkSegmentedControl<ThemeMode>(
                  segments: <ThemeMode, String>{
                    ThemeMode.light: l10n.settingsThemeLight,
                    ThemeMode.dark: l10n.settingsThemeDark,
                  },
                  selected: settings.themeMode == ThemeMode.dark
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  onChanged: controller.setThemeMode,
                ),
              ),
              LkButton(
                label: l10n.commonSettings,
                variant: LkButtonVariant.secondary,
                size: LkButtonSize.medium,
                block: true,
                onPressed: () => context.pushNamed(AppRoutes.settingsName),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.control});

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
