import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/core/config/environment.dart';

/// Build-time application configuration.
///
/// Values arrive through `--dart-define`; nothing here may hold a secret.
/// CLAUDE.md §22 and §24 keep payment and signing keys server-side, so the
/// client only ever learns which backend to talk to.
class AppConfig {
  /// Creates a configuration explicitly. Prefer [AppConfig.fromEnvironment].
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableVerboseLogging,
    required this.admobAppIdAndroid,
    required this.admobAppIdIos,
    required this.admobBannerUnitId,
    required this.admobNativeUnitId,
    required this.admobRewardedUnitId,
  });

  /// Reads configuration from the compile-time environment.
  factory AppConfig.fromEnvironment() {
    const env = String.fromEnvironment('APP_ENV', defaultValue: 'local');
    const url = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:3000',
    );
    final environment = Environment.parse(env);
    return AppConfig(
      environment: environment,
      apiBaseUrl: url,
      // Verbose logs must never reach production (CLAUDE.md §38).
      enableVerboseLogging: environment != Environment.production,
      // Google's own published sample/test identifiers (docs/adr/0018) —
      // safe as defaults, never real inventory. Every environment must
      // override these with real ids before release; ADR-0018 and
      // mobile/config/README.md say so.
      admobAppIdAndroid: const String.fromEnvironment(
        'ADMOB_APP_ID_ANDROID',
        defaultValue: 'ca-app-pub-3940256099942544~3347511713',
      ),
      admobAppIdIos: const String.fromEnvironment(
        'ADMOB_APP_ID_IOS',
        defaultValue: 'ca-app-pub-3940256099942544~1458002511',
      ),
      admobBannerUnitId: const String.fromEnvironment(
        'ADMOB_BANNER_UNIT_ID',
        defaultValue: 'ca-app-pub-3940256099942544/6300978111',
      ),
      admobNativeUnitId: const String.fromEnvironment(
        'ADMOB_NATIVE_UNIT_ID',
        defaultValue: 'ca-app-pub-3940256099942544/2247696110',
      ),
      admobRewardedUnitId: const String.fromEnvironment(
        'ADMOB_REWARDED_UNIT_ID',
        defaultValue: 'ca-app-pub-3940256099942544/5224354917',
      ),
    );
  }

  /// Which environment this build targets.
  final Environment environment;

  /// Root URL of the L Key backend.
  final String apiBaseUrl;

  /// Whether debug-level logging is permitted.
  final bool enableVerboseLogging;

  /// AdMob application id for Android. Not a secret (CLAUDE.md §22) — it
  /// identifies the app to AdMob, the same way a bundle id does.
  final String admobAppIdAndroid;

  /// AdMob application id for iOS.
  final String admobAppIdIos;

  /// AdMob banner ad unit id.
  final String admobBannerUnitId;

  /// AdMob native ad unit id.
  final String admobNativeUnitId;

  /// AdMob rewarded ad unit id.
  final String admobRewardedUnitId;
}

/// Provides the build-time configuration to the widget tree.
///
/// Deliberately unimplemented: it is overridden at the root in `main`, so a
/// test that forgets to supply a configuration fails loudly rather than
/// silently running against a default (ADR-0002).
///
/// It lives here rather than in `main.dart` so feature code can read the
/// configuration without importing the application entry point.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('appConfigProvider must be overridden'),
);
