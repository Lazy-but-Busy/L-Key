import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container([
  Map<String, Object> initial = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: <Override>[
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
}

void main() {
  group('SettingsController', () {
    test('defaults follow the system and A440', () async {
      final container = await _container();
      addTearDown(container.dispose);

      final settings = container.read(settingsProvider);
      expect(settings.locale, isNull, reason: 'null follows the OS locale');
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.referencePitchHz, Settings.defaultReferencePitchHz);
    });

    test('choices survive a restart', () async {
      final container = await _container();

      container.read(settingsProvider.notifier)
        ..setLocale(const Locale('my'))
        ..setThemeMode(ThemeMode.dark)
        ..setReferencePitch(432);
      // A fresh container over the same store is what a relaunch looks like.
      container.dispose();
      final prefs = await SharedPreferences.getInstance();
      final restarted = ProviderContainer(
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(restarted.dispose);

      final settings = restarted.read(settingsProvider);
      expect(settings.locale?.languageCode, 'my');
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.referencePitchHz, 432);
    });

    test('clearing the language returns to following the system', () async {
      final container = await _container(<String, Object>{
        'settings.locale': 'my',
      });
      addTearDown(container.dispose);

      expect(container.read(settingsProvider).locale?.languageCode, 'my');

      container.read(settingsProvider.notifier).setLocale(null);
      expect(container.read(settingsProvider).locale, isNull);
    });

    test('an unrecognised stored theme falls back to the system', () async {
      // Guards against a value written by a future build, or a corrupted one.
      final container = await _container(<String, Object>{
        'settings.themeMode': 'sepia',
      });
      addTearDown(container.dispose);

      expect(container.read(settingsProvider).themeMode, ThemeMode.system);
    });
  });
}
