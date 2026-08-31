import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/app/theme/app_theme.dart';
import 'package:l_key/features/chords/presentation/chord_detail_page.dart';
import 'package:l_key/features/chords/presentation/chords_page.dart';
import 'package:l_key/features/fretboard/presentation/fretboard_page.dart';
import 'package:l_key/features/metronome/presentation/metronome_page.dart';
import 'package:l_key/features/profile/presentation/profile_page.dart';
import 'package:l_key/features/scales/presentation/scales_page.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:l_key/features/settings/presentation/settings_page.dart';
import 'package:l_key/features/songs/presentation/song_detail_page.dart';
import 'package:l_key/features/songs/presentation/songs_page.dart';
import 'package:l_key/features/tools/presentation/tools_page.dart';
import 'package:l_key/features/tuner/presentation/tuner_page.dart';
import 'package:l_key/shared/widgets/lk_empty_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/pump.dart';

Future<List<Override>> _overrides() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  return <Override>[sharedPreferencesProvider.overrideWithValue(prefs)];
}

void main() {
  // Home is exercised through the shell test, which supplies its router.
  final screens = <String, Widget Function()>{
    'Tools': ToolsPage.new,
    'Tuner': TunerPage.new,
    'Metronome': MetronomePage.new,
    'Chords': ChordsPage.new,
    'Chord detail': () => const ChordDetailPage(chordId: 'c-major'),
    'Scales': ScalesPage.new,
    'Fretboard': FretboardPage.new,
    'Songs': SongsPage.new,
    'Song detail': () => const SongDetailPage(songId: 'amazing-grace'),
    'Profile': ProfilePage.new,
    'Settings': SettingsPage.new,
  };

  group('every screen renders', () {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} in light, dark and Burmese', (tester) async {
        final overrides = await _overrides();

        for (final theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
          await pumpLk(
            tester,
            child: entry.value(),
            theme: theme,
            overrides: overrides,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        // DESIGN.md §36 — Burmese is a first-class language, not a layer on
        // top, so every screen has to survive it without overflowing.
        await pumpLk(
          tester,
          child: entry.value(),
          locale: const Locale('my'),
          overrides: overrides,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('SongsPage', () {
    testWidgets('search that matches nothing shows the empty state', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const SongsPage(),
        overrides: await _overrides(),
      );

      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();

      expect(find.byType(LkEmptyState), findsOneWidget);
      expect(find.text('NO SONGS MATCH.'), findsOneWidget);
    });

    testWidgets('the favourites filter shows its own empty state', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const SongsPage(),
        overrides: await _overrides(),
      );

      await tester.tap(find.text('FAVORITES'));
      await tester.pumpAndSettle();

      expect(find.text('NO FAVORITES YET.'), findsOneWidget);
    });
  });

  group('SongDetailPage', () {
    testWidgets('an unknown song shows the empty state, not a crash', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const SongDetailPage(songId: 'not-a-real-song'),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LkEmptyState), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('transposing up moves the offset and the displayed key', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const SongDetailPage(songId: 'amazing-grace'),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('0 st'), findsOneWidget);

      // The transpose row's control is the first `+`; font size's is second.
      await tester.tap(find.byIcon(Icons.add).first);
      await tester.pumpAndSettle();

      expect(find.text('1 st'), findsOneWidget);
      expect(find.text('G♯'), findsWidgets);
      expect(find.text('G'), findsNothing);
    });

    testWidgets('favoriting toggles the icon', (tester) async {
      await pumpLk(
        tester,
        child: const SongDetailPage(songId: 'amazing-grace'),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });
  });

  group('ToolsPage', () {
    testWidgets('premium tools are marked and not navigable', (tester) async {
      await pumpLk(
        tester,
        child: const ToolsPage(),
        overrides: await _overrides(),
      );

      // The badge always carries the word, never colour alone.
      expect(find.text('PRO'), findsNWidgets(2));
      expect(find.byIcon(Icons.lock_outline), findsWidgets);
    });
  });
}
