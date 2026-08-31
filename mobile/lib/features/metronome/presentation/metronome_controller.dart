import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/core/access/tiered_entry.dart';
import 'package:l_key/core/audio/audio_output.dart';
import 'package:l_key/core/audio/background_audio_service.dart';
import 'package:l_key/features/metronome/data/metronome_catalog.dart';
import 'package:l_key/features/metronome/data/metronome_settings_store.dart';
import 'package:l_key/features/metronome/domain/click_sound.dart';
import 'package:l_key/features/metronome/domain/metronome_settings.dart';
import 'package:l_key/features/metronome/domain/metronome_state.dart';
import 'package:l_key/features/metronome/domain/metronome_transport.dart';
import 'package:l_key/features/metronome/domain/tap_tempo.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';

/// Supplies the speaker.
///
/// Defaults to the implementation that admits it has none, so a test that
/// forgets to override this reaches a plain Dart object rather than a
/// platform plugin. The real one is installed in `main`.
final audioOutputProvider = Provider<AudioOutput>(
  (ref) => const UnavailableAudioOutput(),
);

/// Supplies the thing that keeps audio alive when the app is not in front.
///
/// Defaults to the implementation that holds nothing, which is the truth on
/// iOS — the background mode and the audio-session category do the whole job
/// there — and the right answer in every test. The Android service is
/// installed in `main`.
final backgroundAudioServiceProvider = Provider<BackgroundAudioService>(
  (ref) => const NoBackgroundAudioService(),
);

/// Fires the short buzz that marks a beat (DESIGN.md §40).
///
/// Behind a provider so a test can count the buzzes, which is the only way to
/// assert "on the beat, not on every subdivision" without a device.
final metronomeHapticsProvider = Provider<VoidCallback>(
  (ref) => HapticFeedback.lightImpact,
);

/// Reads a monotonic elapsed time, for tap tempo.
///
/// **The clock lives here and not in the domain.** A layer test forbids
/// `Stopwatch` and `DateTime.now()` anywhere `metronome/domain` can reach,
/// which is what keeps `TapTempo` a pure function of the durations it is
/// handed — and lets a test hand it a script instead of tapping.
final metronomeClockProvider = Provider<Duration Function()>((ref) {
  final stopwatch = Stopwatch()..start();
  ref.onDispose(stopwatch.stop);
  return () => stopwatch.elapsed;
});

/// The meters the picker offers, with their tier labels.
final metronomeSignaturesProvider = Provider<List<TieredEntry<TimeSignature>>>(
  (ref) => MetronomeCatalog.signatures,
);

/// The subdivisions the picker offers, with their tier labels.
final metronomeSubdivisionsProvider = Provider<List<TieredEntry<Subdivision>>>(
  (ref) => MetronomeCatalog.subdivisions,
);

/// The click voices the picker offers, with their tier labels.
final metronomeSoundsProvider = Provider<List<TieredEntry<ClickSound>>>(
  (ref) => MetronomeCatalog.sounds,
);

/// The metronome's state, and the speaker's lifetime.
///
/// **Not auto-disposing**, unlike `tunerProvider`. A metronome must keep time
/// while the player turns to a chord chart, and the practice screen drives the
/// same one. Nothing holds the speaker while it is idle, which is the battery
/// cost CLAUDE.md §50 is actually about; what it forbids is audio nobody asked
/// for, and this is audio somebody pressed start on.
final metronomeProvider = NotifierProvider<MetronomeController, MetronomeState>(
  MetronomeController.new,
);

/// Just the tempo, for screens that must not rebuild on every beat.
///
/// The practice screen shows a tempo and a transport button and nothing that
/// changes eight times a second, so it watches this instead of the whole
/// state.
final metronomeTempoProvider = Provider<MetronomeTempo>(
  (ref) => ref.watch(
    metronomeProvider.select(
      (state) => MetronomeTempo(
        bpm: state.settings.bpm,
        isRunning: state.isRunning,
        signature: state.settings.signature,
      ),
    ),
  ),
);

/// The coarse view of the metronome that other features consume.
@immutable
final class MetronomeTempo {
  /// Creates a tempo summary.
  const MetronomeTempo({
    required this.bpm,
    required this.isRunning,
    required this.signature,
  });

  /// Beats per minute.
  final int bpm;

  /// Whether the click is sounding.
  final bool isRunning;

  /// The meter.
  final TimeSignature signature;

  @override
  bool operator ==(Object other) =>
      other is MetronomeTempo &&
      other.bpm == bpm &&
      other.isRunning == isRunning &&
      other.signature == signature;

  @override
  int get hashCode => Object.hash(bpm, isRunning, signature);
}

/// Owns the transport, the lifecycle, the tap stopwatch and the haptic edge.
///
/// The timing is all below this: the controller subscribes, republishes and
/// decides when the speaker may be open. No scheduling lives here and none
/// lives in a widget (CLAUDE.md §8).
class MetronomeController extends Notifier<MetronomeState> {
  MetronomeTransport? _transport;
  MetronomeSettingsStore? _store;
  StreamSubscription<MetronomeState>? _states;
  AppLifecycleListener? _lifecycle;
  TapTempo? _taps;
  bool _isForeground = true;

  @override
  MetronomeState build() {
    final store = MetronomeSettingsStore(ref.read(sharedPreferencesProvider));
    _store = store;
    _taps = TapTempo();

    final transport = MetronomeTransport(
      output: ref.read(audioOutputProvider),
      background: ref.read(backgroundAudioServiceProvider),
      settings: store.read(),
    );
    _transport = transport;
    _states = transport.states.listen(_onState);

    // Haptics are suppressed while the app is not in front: a phone buzzing
    // in a pocket for twenty minutes is a real battery cost with nobody to
    // feel it. The audio itself deliberately keeps going.
    _lifecycle = AppLifecycleListener(
      onPause: () => _isForeground = false,
      onHide: () => _isForeground = false,
      onRestart: () => _isForeground = true,
      onShow: () => _isForeground = true,
    );

    ref.onDispose(() {
      _lifecycle?.dispose();
      unawaited(_states?.cancel());
      unawaited(transport.dispose());
    });

    return transport.state;
  }

  /// Opens the speaker and starts keeping time.
  Future<void> start() => _transport?.start() ?? Future<void>.value();

  /// Stops keeping time and releases the speaker.
  Future<void> stop() => _transport?.stop() ?? Future<void>.value();

  /// Starts if stopped, stops if running.
  Future<void> toggle() => state.isRunning ? stop() : start();

  /// Sets the tempo, clamped.
  void setBpm(int bpm) => _apply(state.settings.withBpm(bpm));

  /// Moves the tempo by [delta] beats per minute.
  void nudgeBpm(int delta) => setBpm(state.settings.bpm + delta);

  /// Sets the meter.
  void setSignature(TimeSignature signature) =>
      _apply(state.settings.copyWith(signature: signature));

  /// Sets how each beat is divided.
  void setSubdivision(Subdivision subdivision) =>
      _apply(state.settings.copyWith(subdivision: subdivision));

  /// Sets which click voice sounds.
  void setSound(ClickSound sound) =>
      _apply(state.settings.copyWith(sound: sound));

  /// Sets how many bars are counted before the first.
  void setCountIn(CountIn countIn) =>
      _apply(state.settings.copyWith(countIn: countIn));

  /// Turns the beat haptic on or off.
  void setHaptics({required bool enabled}) =>
      _apply(state.settings.copyWith(hapticsEnabled: enabled));

  /// Changes the emphasis of one beat.
  void setAccent(int beat, AccentLevel level) =>
      _apply(state.settings.withAccentAt(beat, level));

  /// Cycles one beat through the emphases a player can choose.
  ///
  /// Subdivision is not in the cycle: it is what the pulses *between* beats
  /// get, never a beat's own emphasis.
  void cycleAccent(int beat) {
    const cycle = <AccentLevel>[
      AccentLevel.strong,
      AccentLevel.accent,
      AccentLevel.normal,
      AccentLevel.silent,
    ];
    final current = state.settings.accents[beat];
    final next = cycle[(cycle.indexOf(current) + 1) % cycle.length];
    setAccent(beat, next);
  }

  /// Records a tap, and follows the tempo it implies.
  ///
  /// Returns how many taps are in the phrase, so the button can say whether
  /// it is still listening.
  int tap() {
    final taps = _taps;
    if (taps == null) return 0;
    final result = taps.tap(ref.read(metronomeClockProvider)());
    if (result.bpm != null) setBpm(result.bpm!);
    return result.tapCount;
  }

  void _apply(MetronomeSettings settings) {
    // The notification names the tempo, so it has to follow it. The builder
    // comes from the screen, which is where localisations live.
    final describe = _describeNotification;
    if (describe != null) _transport?.notification = describe(settings);
    _transport?.apply(settings);
    _store?.write(settings);
  }

  /// Builds the background notification's copy for a given settings value.
  ///
  /// Set by a screen, because that is where localisations live: the platform
  /// side hardcodes no user-facing text, and Burmese is a first-class
  /// language (DESIGN.md §36).
  BackgroundAudioNotification Function(MetronomeSettings)?
  _describeNotification;

  /// Installs the builder, and applies it to the current settings.
  void describeNotificationWith(
    BackgroundAudioNotification Function(MetronomeSettings) builder,
  ) {
    _describeNotification = builder;
    _transport?.notification = builder(state.settings);
  }

  void _onState(MetronomeState next) {
    state = next;
    if ((_transport?.takeHapticCue() ?? false) &&
        next.settings.hapticsEnabled &&
        _isForeground) {
      ref.read(metronomeHapticsProvider)();
    }
  }
}
