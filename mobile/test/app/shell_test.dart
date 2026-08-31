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
import 'package:l_key/features/chords/presentation/chord_analyzer_page.dart';
import 'package:l_key/features/chords/presentation/chord_detail_page.dart';
import 'package:l_key/features/chords/presentation/chords_page.dart';
import 'package:l_key/features/home/presentation/home_page.dart';
import 'package:l_key/features/metronome/presentation/metronome_page.dart';
import 'package:l_key/features/profile/presentation/profile_page.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:l_key/features/settings/presentation/settings_page.dart';
import 'package:l_key/features/songs/presentation/songs_page.dart';
import 'package:l_key/features/tools/presentation/tools_page.dart';
import 'package:l_key/features/tuner/presentation/tuner_page.dart';
import 'package:l_key/shared/widgets/lk_bottom_nav_bar.dart';
import 'package:l_key/shared/widgets/lk_empty_state.dart';
import 'package:l_key/shared/widgets/lk_top_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the real router inside the real app scaffolding.
///
/// A fresh [GoRouter] per test is required: `StatefulShellRoute` carries a
/// private `GlobalKey`, so sharing one instance across tests makes two live
/// routers collide.
Future<GoRouter> pumpApp(
  WidgetTester tester, {
  Environment environment = Environment.local,
  Locale? locale,
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
        locale: locale,
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
    testWidgets('starts on Home and offers the four sections', (tester) async {
      await pumpApp(tester);

      expect(find.byType(HomePage), findsOneWidget);
      for (final label in <String>['Home', 'Tools', 'Songs', 'Profile']) {
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

    testWidgets('a tool takes the whole screen and offers a way back', (
      tester,
    ) async {
      // ADR-0014 supersedes ADR-0007's chrome table: a tool is a dedicated
      // screen with a back control, not a section with a bar underneath it.
      await pumpApp(tester);

      await tester.tap(tab('Tools'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tuner'));
      await tester.pumpAndSettle();

      expect(find.byType(TunerPage), findsOneWidget);
      expect(find.byType(LkBottomNavBar), findsNothing);
      expect(find.byType(LkTopAppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(ToolsPage), findsOneWidget);
      expect(find.byType(LkBottomNavBar), findsOneWidget);
    });

    testWidgets('a tool opened from Home returns to Home', (tester) async {
      // The tuner is owned by Tools and reachable from Home. Pushing above
      // the shell means the player comes back to where they were rather than
      // being left in another section (ADR-0007 accepted that as the cost of
      // nesting; ADR-0014 removes it).
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.graphic_eq));
      await tester.pumpAndSettle();
      expect(find.byType(TunerPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(tab('Home'), findsOneWidget);
    });

    testWidgets('the analyzer returns to the chord library', (tester) async {
      await pumpApp(tester);

      await tester.tap(tab('Tools'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chords'));
      await tester.pumpAndSettle();
      expect(find.byType(ChordsPage), findsOneWidget);

      await tester.tap(find.text('ANALYZE A SHAPE'));
      await tester.pumpAndSettle();
      expect(find.byType(ChordAnalyzerPage), findsOneWidget);
      expect(find.byType(LkBottomNavBar), findsNothing);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(ChordsPage), findsOneWidget);
    });

    testWidgets('the system back gesture leaves a tool, not the app', (
      tester,
    ) async {
      // Android's back and iOS's back-swipe both arrive here. The tool is an
      // ordinary route on the root navigator, so it pops before AppShell's
      // PopScope sees anything.
      await pumpApp(tester);

      await tester.tap(tab('Tools'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Metronome'));
      await tester.pumpAndSettle();
      expect(find.byType(MetronomePage), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(ToolsPage), findsOneWidget);
      expect(find.byType(LkBottomNavBar), findsOneWidget);
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

    testWidgets('the wordmark bar appears only on the four sections', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(find.byType(LkTopAppBar), findsOneWidget);

      for (final section in <String>['Tools', 'Songs', 'Profile']) {
        await tester.tap(tab(section));
        await tester.pumpAndSettle();
        expect(
          find.byType(LkTopAppBar),
          findsOneWidget,
          reason: '$section is a section root and keeps the bar',
        );
      }
    });

    testWidgets('every section root keeps both bars', (tester) async {
      // The counterpart to the tool tests: the four sections are the only
      // surfaces that carry the wordmark and the bottom bar (ADR-0014).
      await pumpApp(tester);

      for (final section in <String>['Home', 'Tools', 'Songs']) {
        await tester.tap(tab(section));
        await tester.pumpAndSettle();
        expect(find.byType(LkTopAppBar), findsOneWidget, reason: section);
        expect(find.byType(LkBottomNavBar), findsOneWidget, reason: section);
        expect(find.byIcon(Icons.arrow_back), findsNothing, reason: section);
      }
    });

    testWidgets('settings keeps the bar above the shell', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(LkTopAppBar), findsOneWidget);
      expect(find.byType(LkBottomNavBar), findsNothing);
    });

    testWidgets('the bar survives Burmese on a small phone', (tester) async {
      // Burmese labels are routinely longer than their English originals, and
      // an earlier build overflowed the row by 20px on a 390pt phone
      // (DESIGN.md §36). 320pt is the narrowest phone worth supporting.
      tester.view.physicalSize = const Size(320 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester, locale: const Locale('my'));

      expect(tester.takeException(), isNull);
    });

    testWidgets('a chord deep link builds its way back to Tools', (
      tester,
    ) async {
      // The paths stay nested under the section that owns them even though
      // the pages sit above the shell, so go_router builds Tools and the
      // chord library underneath and back walks out through both (ADR-0014).
      final router = await pumpApp(tester);

      router.go('/tools/chords/c-major');
      await tester.pumpAndSettle();

      expect(find.byType(ChordDetailPage), findsOneWidget);
      expect(find.byType(LkBottomNavBar), findsNothing);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(ChordsPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(ToolsPage), findsOneWidget);
      expect(find.byType(LkBottomNavBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unknown chord id is a screen, not a crash', (tester) async {
      final router = await pumpApp(tester);

      router.go('/tools/chords/h-flat-wobble');
      await tester.pumpAndSettle();

      expect(find.byType(ChordDetailPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a search survives a trip into a chord and back', (
      tester,
    ) async {
      // The page stays mounted under the pushed chord, so the query is still
      // there — and the box shows it. The requirement is that the two agree,
      // not that either is empty.
      await pumpApp(tester);
      await tester.tap(tab('Tools'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chords'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Cmaj7');
      await tester.pumpAndSettle();
      // By key, because the search field also renders the text 'Cmaj7'.
      await tester.tap(find.byKey(const ValueKey<String>('chord-c-maj7')));
      await tester.pumpAndSettle();
      expect(find.byType(ChordDetailPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Cmaj7',
      );
      expect(find.byType(LkEmptyState), findsNothing);
    });

    testWidgets('leaving the chord library resets its search', (tester) async {
      // The reported bug. The query provider used to outlive every mount of
      // ChordsPage while its text field did not, so the player came back to
      // an empty search box sitting above a filtered list — and, if the
      // query had matched nothing, to an empty state with no visible text to
      // clear.
      await pumpApp(tester);
      await tester.tap(tab('Tools'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chords'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.byType(LkEmptyState), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(ToolsPage), findsOneWidget);

      await tester.tap(find.text('Chords'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(
        find.byType(LkEmptyState),
        findsNothing,
        reason: "an empty query must never show a previous search's results",
      );
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
