import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_router.dart';
import 'package:l_key/app/theme/app_theme.dart';
import 'package:l_key/core/config/app_config.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';

/// Root widget: wires theme, routing, settings and localisation together.
class LKeyApp extends ConsumerStatefulWidget {
  /// Creates the application root.
  const LKeyApp({super.key});

  @override
  ConsumerState<LKeyApp> createState() => _LKeyAppState();
}

class _LKeyAppState extends ConsumerState<LKeyApp> {
  /// Built once and never rebuilt. Recreating the router would recreate the
  /// shell's navigator keys and discard every branch's navigation stack.
  late final GoRouter _router = createRouter(
    environment: ref.read(appConfigProvider).environment,
  );

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'L Key',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Both themes are designed (DESIGN.md §68), so the OS choice is honoured
      // until the player overrides it in settings.
      themeMode: settings.themeMode,
      // Null follows the device locale through supportedLocales.
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
