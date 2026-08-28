import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_theme.dart';

/// Wraps [child] in the minimum app scaffolding a widget needs: theme,
/// localisation delegates and a Riverpod scope.
///
/// Every screen and component test goes through this so a widget can never
/// pass because a test host happened to supply a Material default the real
/// app does not.
Widget lkTestHost({
  required Widget child,
  ThemeData? theme,
  Locale locale = const Locale('en'),
  List<Override> overrides = const <Override>[],
  bool disableAnimations = false,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: theme ?? AppTheme.light,
      locale: locale,
      // Exactly what the real app installs, so a test host can never be more
      // forgiving about a locale than production is.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: disableAnimations),
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
}

/// Pumps [child] inside [lkTestHost].
Future<void> pumpLk(
  WidgetTester tester, {
  required Widget child,
  ThemeData? theme,
  Locale locale = const Locale('en'),
  List<Override> overrides = const <Override>[],
  bool disableAnimations = false,
}) {
  return tester.pumpWidget(
    lkTestHost(
      child: child,
      theme: theme,
      locale: locale,
      overrides: overrides,
      disableAnimations: disableAnimations,
    ),
  );
}
