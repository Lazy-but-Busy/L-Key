/// The deployment environment the app was built for.
///
/// Selected at build time with `--dart-define-from-file=config/<env>.json`;
/// see docs/ENVIRONMENTS.md. Native build flavours are deliberately deferred
/// to a later phase — dart-defines carry everything Phase 01 needs.
enum Environment {
  /// Developer machine. Points at a local backend.
  local,

  /// Shared development server.
  dev,

  /// Pre-production verification.
  staging,

  /// Live users.
  production;

  /// Parses [value] into an [Environment], falling back to [Environment.local].
  static Environment parse(String value) {
    return Environment.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Environment.local,
    );
  }

  /// Whether developer-only surfaces may be shown.
  ///
  /// Gates the foundation showcase so it can never reach a release build.
  bool get allowsDeveloperTools => this != Environment.production;
}
