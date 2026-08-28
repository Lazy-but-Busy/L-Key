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
    );
  }

  /// Which environment this build targets.
  final Environment environment;

  /// Root URL of the L Key backend.
  final String apiBaseUrl;

  /// Whether debug-level logging is permitted.
  final bool enableVerboseLogging;
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
