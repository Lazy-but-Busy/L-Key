import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_router.dart';
import 'package:l_key/app/theme/app_theme.dart';

/// Root widget: wires theme, routing and localisation together.
class LKeyApp extends StatefulWidget {
  /// Creates the application root.
  const LKeyApp({super.key});

  @override
  State<LKeyApp> createState() => _LKeyAppState();
}

class _LKeyAppState extends State<LKeyApp> {
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'L Key',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Both themes are designed (DESIGN.md §68), so the OS choice is
      // honoured. ThemeMode.system is the MaterialApp default.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
