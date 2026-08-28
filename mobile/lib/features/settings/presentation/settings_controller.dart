import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The player's persisted preferences.
@immutable
class Settings {
  /// Creates a settings snapshot.
  const Settings({
    this.locale,
    this.themeMode = ThemeMode.system,
    this.referencePitchHz = defaultReferencePitchHz,
  });

  /// A440 — the tuning reference every tuner defaults to.
  static const double defaultReferencePitchHz = 440;

  /// Chosen language, or null to follow the operating system.
  final Locale? locale;

  /// Chosen theme, or [ThemeMode.system] to follow the operating system.
  final ThemeMode themeMode;

  /// Tuning reference in hertz.
  final double referencePitchHz;

  /// Returns a copy with the given fields replaced.
  ///
  /// [locale] uses a sentinel because null is a meaningful value here — it
  /// means "follow the system" rather than "leave unchanged".
  Settings copyWith({
    Object? locale = _unset,
    ThemeMode? themeMode,
    double? referencePitchHz,
  }) {
    return Settings(
      locale: identical(locale, _unset) ? this.locale : locale as Locale?,
      themeMode: themeMode ?? this.themeMode,
      referencePitchHz: referencePitchHz ?? this.referencePitchHz,
    );
  }

  static const Object _unset = Object();
}

/// Supplies the preference store.
///
/// Deliberately unimplemented so a test that forgets to provide one fails
/// loudly rather than silently writing to the device, which is the same
/// contract `appConfigProvider` uses.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be set'),
);

/// Reads and writes [Settings].
///
/// Writes are fire-and-forget: the in-memory state updates immediately so the
/// UI never waits on disk, and a failed write costs a preference rather than
/// data.
class SettingsController extends Notifier<Settings> {
  static const String _localeKey = 'settings.locale';
  static const String _themeKey = 'settings.themeMode';
  static const String _pitchKey = 'settings.referencePitchHz';

  SharedPreferences get _store => ref.read(sharedPreferencesProvider);

  @override
  Settings build() {
    final store = ref.read(sharedPreferencesProvider);
    final languageCode = store.getString(_localeKey);

    return Settings(
      locale: languageCode == null ? null : Locale(languageCode),
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == store.getString(_themeKey),
        orElse: () => ThemeMode.system,
      ),
      referencePitchHz:
          store.getDouble(_pitchKey) ?? Settings.defaultReferencePitchHz,
    );
  }

  /// Sets the language, or passes null to follow the operating system.
  void setLocale(Locale? locale) {
    state = state.copyWith(locale: locale);
    if (locale == null) {
      _ignore(_store.remove(_localeKey));
    } else {
      _ignore(_store.setString(_localeKey, locale.languageCode));
    }
  }

  /// Sets the theme.
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _ignore(_store.setString(_themeKey, mode.name));
  }

  /// Sets the tuning reference in hertz.
  void setReferencePitch(double hz) {
    state = state.copyWith(referencePitchHz: hz);
    _ignore(_store.setDouble(_pitchKey, hz));
  }

  /// Preferences are best-effort: a failed write must never surface as an
  /// unhandled error or block the interface.
  void _ignore(Future<void> future) => future.ignore();
}

/// The active settings.
final settingsProvider = NotifierProvider<SettingsController, Settings>(
  SettingsController.new,
);
