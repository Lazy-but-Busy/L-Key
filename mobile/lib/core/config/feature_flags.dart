/// Compile-time feature flags (CLAUDE.md §48).
///
/// Every high-risk or unfinished capability ships behind a flag that defaults
/// to **off**, so experimental work cannot reach production by accident.
/// Override at build time, for example:
///
/// ```sh
/// flutter run --dart-define=ENABLE_AI_ASSISTANT=true
/// ```
abstract final class FeatureFlags {
  /// AI Guitar Assistant (PRD.md §35). Requires network and a backend key.
  static const bool aiAssistant = bool.fromEnvironment('ENABLE_AI_ASSISTANT');

  /// Real-time chord recognition (CLAUDE.md §16). Unimplemented; the
  /// algorithm must expose confidence before this may be enabled.
  static const bool chordRecognition = bool.fromEnvironment(
    'ENABLE_CHORD_RECOGNITION',
  );

  /// Backing-track playback (PRD.md §31).
  static const bool backingTracks = bool.fromEnvironment(
    'ENABLE_BACKING_TRACKS',
  );

  /// Audio recording (PRD.md §32).
  static const bool recording = bool.fromEnvironment('ENABLE_RECORDING');

  /// The tuner's raw measurements, for calibrating thresholds on a real
  /// device (docs/DEVICE-TESTING.md). Never for players: it shows decibels,
  /// clarity and spectral flatness, none of which mean anything to a
  /// guitarist.
  static const bool tunerDiagnostics = bool.fromEnvironment(
    'ENABLE_TUNER_DIAGNOSTICS',
  );

  /// The metronome's buffer and timing measurements, for confirming its
  /// behaviour on a real device (docs/DEVICE-TESTING.md Part B). Never for
  /// players: fed frames and dropout counts mean nothing to a guitarist.
  static const bool metronomeDiagnostics = bool.fromEnvironment(
    'ENABLE_METRONOME_DIAGNOSTICS',
  );

  /// Community features (PRD.md §67, V3).
  static const bool community = bool.fromEnvironment('ENABLE_COMMUNITY');

  /// AdMob advertising (docs/adr/0018). Off until a platform implementation
  /// of `AdProvider` exists — enabling this today would still show nothing,
  /// since `UnavailableAdProvider` is the only implementation.
  static const bool ads = bool.fromEnvironment('ENABLE_ADS');

  /// All flags keyed by name, for diagnostics and tests.
  static const Map<String, bool> all = <String, bool>{
    'aiAssistant': aiAssistant,
    'chordRecognition': chordRecognition,
    'backingTracks': backingTracks,
    'recording': recording,
    'tunerDiagnostics': tunerDiagnostics,
    'metronomeDiagnostics': metronomeDiagnostics,
    'community': community,
    'ads': ads,
  };
}
