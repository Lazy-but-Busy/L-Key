import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/router/app_router.dart';
import 'package:l_key/app/theme/app_theme.dart';
import 'package:l_key/core/config/app_config.dart';
import 'package:l_key/core/config/environment.dart';
import 'package:l_key/features/home/presentation/home_page.dart';
import 'package:l_key/features/profile/presentation/profile_page.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:l_key/features/settings/presentation/settings_page.dart';
import 'package:l_key/features/songs/presentation/songs_page.dart';
import 'package:l_key/features/tools/presentation/tools_page.dart';
import 'package:l_key/features/tuner/presentation/tuner_page.dart';
import 'package:l_key/shared/widgets/lk_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the real router inside the real app scaffolding.
///
/// A fresh [GoRouter] per test is required: `StatefulShellRoute` carries a
/// private `GlobalKey`, so sharing one instance across tests makes two live
/// routers collide.
Future<GoRouter> pumpApp(
  WidgetTester tester, {
  Environment environment = Environment.local,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  final router = createRouter(environment: environment);

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        appConfigProvider.overrideWithValue(
          AppConfig(
            environment: environment,
            apiBaseUrl: 'http://localhost:3000',
            enableVerboseLogging: false,
          ),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// Scopes a finder to the bottom bar.
///
/// Section names appear twice on screen -- Home lists "Tools" as a quick tool
/// and the bar labels the tab -- so an unscoped `find.text` is ambiguous.
Finder tab(String label) => find.descendant(
  of: find.byType(LkBottomNavBar),
  matching: find.text(label),
);

void main() {
  group('AppShell', () {
    testWidgets('starts on Home and offers the five sections', (tester) async {
      await pumpApp(tester);

      expect(find.byType(HomePage), findsOneWidget);
      for (final label in <String>[
        'Home',
        'Tools',
        'Learn',
        'Songs',
        'Profile',
      ]) {
        expect(tab(label), findsOneWidget, reason: '$label tab missing');
      }
    });

    testWidgets('each tab shows its section', (tester) async {
      await pumpApp(tester);

      await tester.tap(tab('Tools'));
      await tester.pumpAndSettle();
      expect(find.byType(ToolsPage), findsOneWidget);

      await tester.tap(tab('Songs'));
      await tester.pumpAndSettle();
      expect(find.byType(SongsPage), findsOneWidget);

      await tester.tap(tab('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('a branch keeps its own stack across a tab switch', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(tab('Tools'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tuner'));
      await tester.pumpAndSettle();
      expect(find.byType(TunerPage), findsOneWidget);

      await tester.tap(tab('Songs'));
      await tester.pumpAndSettle();
      expect(find.byType(TunerPage), findsNothing);

      await tester.tap(tab('Tools'));
      await tester.pumpAndSettle();
      expect(
        find.byType(TunerPage),
        findsOneWidget,
        reason: 'the Tools stack should survive leaving the tab',
      );
    });

    testWidgets('settings pushes above the shell from any section', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(tab('Songs'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      // Pushed above the shell rather than nested under Profile, so the
      // player is not silently moved to another tab.
      expect(find.byType(SongsPage), findsNothing);
    });

    testWidgets('the developer showcase is unreachable in production', (
      tester,
    ) async {
      final router = await pumpApp(tester, environment: Environment.production);

      router.go('/foundation');
      await tester.pumpAndSettle();

      expect(find.text('FOUNDATION'), findsNothing);
    });
  });
}
