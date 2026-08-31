/// Route paths and names, in one place so no widget hardcodes a string.
///
/// The four branch roots are the primary sections (ADR-0017 cut Learn from
/// PRD.md §7's original five). Detail screens sit under the section that owns
/// them, so a deep link restores the right tab. `/settings` is the exception:
/// it is reachable from the top bar of every screen, so no section owns it
/// and it pushes above the shell.
abstract final class AppRoutes {
  /// Home — the first branch and the app's entry point.
  static const String home = '/';

  /// Name for named navigation to [home].
  static const String homeName = 'home';

  /// Tools hub.
  static const String tools = '/tools';

  /// Name for named navigation to [tools].
  static const String toolsName = 'tools';

  /// Tuner, owned by Tools.
  static const String tuner = '/tools/tuner';

  /// Name for named navigation to [tuner].
  static const String tunerName = 'tuner';

  /// Metronome, owned by Tools.
  static const String metronome = '/tools/metronome';

  /// Name for named navigation to [metronome].
  static const String metronomeName = 'metronome';

  /// Chord library, owned by Tools.
  static const String chords = '/tools/chords';

  /// Name for named navigation to [chords].
  static const String chordsName = 'chords';

  /// A single chord, owned by the chord library.
  ///
  /// The first route in the app to carry a path parameter. `:chordId` is a
  /// catalogue id such as `c-major` or `c-sharp-m7b5` — spelled out rather
  /// than symbolic so it survives a URL unescaped.
  static const String chordDetail = '/tools/chords/:chordId';

  /// Name for named navigation to [chordDetail].
  static const String chordDetailName = 'chordDetail';

  /// The chord analyzer, owned by the chord library.
  ///
  /// A sibling of [chordDetail] and declared before it, because `analyzer`
  /// would otherwise be matched as a `:chordId`. No catalogue id is a bare
  /// word, and a test asserts it.
  static const String chordAnalyzer = '/tools/chords/analyzer';

  /// Name for named navigation to [chordAnalyzer].
  static const String chordAnalyzerName = 'chordAnalyzer';

  /// Interactive fretboard, owned by Tools.
  static const String fretboard = '/tools/fretboard';

  /// Name for named navigation to [fretboard].
  static const String fretboardName = 'fretboard';

  /// Scales, owned by Tools.
  static const String scales = '/tools/scales';

  /// Name for named navigation to [scales].
  static const String scalesName = 'scales';

  /// Song library.
  static const String songs = '/songs';

  /// Name for named navigation to [songs].
  static const String songsName = 'songs';

  /// Profile.
  static const String profile = '/profile';

  /// Name for named navigation to [profile].
  static const String profileName = 'profile';

  /// Settings. Pushed above the shell — no section owns it.
  static const String settings = '/settings';

  /// Name for named navigation to [settings].
  static const String settingsName = 'settings';

  /// Developer-only design-token showcase. Not a product surface.
  static const String foundation = '/foundation';

  /// Name for named navigation to [foundation].
  static const String foundationName = 'foundation';
}
