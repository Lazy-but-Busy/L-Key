import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/core/access/tiered_entry.dart';
import 'package:l_key/core/audio/audio_input.dart';
import 'package:l_key/core/config/feature_flags.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/core/permissions/microphone_permission.dart';
import 'package:l_key/core/permissions/platform/permission_handler_microphone_permission.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:l_key/features/tuner/data/tuner_catalog.dart';
import 'package:l_key/features/tuner/domain/tuner_pipeline.dart';
import 'package:l_key/features/tuner/domain/tuner_state.dart';

/// Supplies the microphone.
///
/// Defaults to the implementation that admits it has none, so a test that
/// forgets to override this reaches a plain Dart object rather than a
/// platform plugin. The real one is installed in `main`.
final audioInputProvider = Provider<AudioInput>(
  (ref) => const UnavailableAudioInput(),
);

/// Supplies microphone permission.
final microphonePermissionProvider = Provider<MicrophonePermission>(
  (ref) => const PermissionHandlerMicrophonePermission(),
);

/// Fires the short buzz that says a string has locked (DESIGN.md §40).
///
/// Behind a provider so a test can count the buzzes, which is the only way to
/// assert "once, not forty-three times a second" without a device.
final tunerHapticsProvider = Provider<VoidCallback>(
  (ref) => HapticFeedback.mediumImpact,
);

/// The tunings the picker offers, with their tier labels.
final tunerTuningsProvider = Provider<List<TieredEntry<Tuning>>>(
  (ref) => TunerCatalog.tunings,
);

/// The tuner's state, and the microphone's lifetime.
///
/// Auto-disposing, so leaving the screen releases the microphone by
/// construction rather than by remembering to (CLAUDE.md §50).
final tunerProvider = NotifierProvider<TunerController, TunerState>(
  TunerController.new,
  isAutoDispose: true,
);

/// Owns the pipeline, the lifecycle and the haptic edge.
///
/// The audio processing is all below this: the controller subscribes,
/// republishes and decides when the microphone may be open. No DSP lives here
/// and none lives in a widget (CLAUDE.md §8, §14).
class TunerController extends Notifier<TunerState> {
  TunerPipeline? _pipeline;
  StreamSubscription<TunerState>? _states;
  AppLifecycleListener? _lifecycle;
  bool _resumeWhenForegrounded = false;
  bool _isVisible = true;

  @override
  TunerState build() {
    final referenceHz = ref.watch(
      settingsProvider.select((s) => s.referencePitchHz),
    );

    final pipeline = TunerPipeline(
      input: ref.read(audioInputProvider),
      permission: ref.read(microphonePermissionProvider),
      referenceHz: referenceHz,
      // The flag is a compile-time constant, so in a default build the
      // analyzer sees this as passing `false` to a parameter that already
      // defaults to it. It is not redundant: with the dart-define set, this
      // is what turns the diagnostics on.
      // ignore: avoid_redundant_argument_values
      collectDiagnostics: FeatureFlags.tunerDiagnostics,
    );
    _pipeline = pipeline;
    _states = pipeline.states.listen(_onState);

    // The observer belongs here rather than in the widget: CLAUDE.md §8 keeps
    // widgets to layout, and §50 wants the microphone released on every path
    // out — including the app being backgrounded, which no widget sees.
    _lifecycle = AppLifecycleListener(
      onPause: _suspend,
      onHide: _suspend,
      onRestart: _resume,
      onShow: _resume,
    );

    ref.onDispose(() {
      _lifecycle?.dispose();
      unawaited(_states?.cancel());
      unawaited(pipeline.dispose());
    });

    return pipeline.state;
  }

  /// Opens the microphone and starts listening.
  Future<void> start() => _pipeline?.start() ?? Future<void>.value();

  /// Stops listening and releases the microphone.
  Future<void> stop() {
    _resumeWhenForegrounded = false;
    return _pipeline?.stop() ?? Future<void>.value();
  }

  /// Opens this app's page in the operating system settings.
  Future<bool> openSettings() async => await _pipeline?.openSettings() ?? false;

  /// Locks the tuner to one string.
  void selectString(int index) => _pipeline?.selectString(index);

  /// Hands the choice of string back to the tuner.
  void selectAuto() => _pipeline?.selectAuto();

  /// Changes tuning.
  Future<void> selectTuning(Tuning tuning) =>
      _pipeline?.selectTuning(tuning) ?? Future<void>.value();

  /// Switches to naming any note rather than one of a tuning's strings.
  void selectChromatic() => _pipeline?.selectChromatic();

  /// Tells the controller whether its screen is on show.
  ///
  /// The shell keeps each tab's stack alive, so a tuner left on the Tools tab
  /// is still mounted while the player reads a chord chart. Without this the
  /// microphone would stay open behind another screen, which is exactly the
  /// battery cost CLAUDE.md §50 is about.
  void setVisible({required bool visible}) {
    if (_isVisible == visible) return;
    _isVisible = visible;
    if (visible) {
      _resume();
    } else {
      _suspend();
    }
  }

  void _onState(TunerState next) {
    state = next;
    if (_pipeline?.takeHapticCue() ?? false) {
      ref.read(tunerHapticsProvider)();
    }
  }

  void _suspend() {
    if (!state.isListening) return;
    _resumeWhenForegrounded = true;
    unawaited(_pipeline?.stop());
  }

  void _resume() {
    if (!_resumeWhenForegrounded || !_isVisible) return;
    _resumeWhenForegrounded = false;
    unawaited(_pipeline?.start());
  }
}
