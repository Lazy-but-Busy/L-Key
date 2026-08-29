/// Microphone to screen state, in one place.
///
/// Contains no Flutter. See docs/adr/0013.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:l_key/core/audio/audio_input.dart';
import 'package:l_key/core/audio/audio_pipeline.dart';
import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/core/permissions/microphone_permission.dart';
import 'package:l_key/features/tuner/domain/tuner_state.dart';
import 'package:l_key/features/tuner/domain/tuner_thresholds.dart';
import 'package:l_key/features/tuner/domain/tuning_session.dart';

/// Runs a tuning session over a microphone.
///
/// The last link of mobile CLAUDE.md §14's chain before Riverpod: it asks for
/// permission, opens the input, feeds bytes through an [AudioPipeline] into a
/// [TuningSession], and publishes the states that come out. It holds no
/// widgets and no Flutter, so the whole thing can be driven in a test from a
/// scripted audio input.
///
/// **It releases the microphone on every path out** — stop, interruption,
/// error and dispose alike — because CLAUDE.md §50 makes that the largest
/// battery cost in the product and a missed path is a microphone left open.
final class TunerPipeline {
  /// Creates a pipeline over [input], gated by [permission].
  factory TunerPipeline({
    required AudioInput input,
    required MicrophonePermission permission,
    TunerThresholds thresholds = TunerThresholds.defaults,
    Tuning tuning = Tuning.standard,
    double referenceHz = 440,
    bool collectDiagnostics = false,
    AudioInputConfig config = const AudioInputConfig(),
  }) => TunerPipeline._(
    input,
    permission,
    config,
    collectDiagnostics,
    TuningSession(
      thresholds: thresholds,
      tuning: tuning,
      referenceHz: referenceHz,
      collectDiagnostics: collectDiagnostics,
    ),
  );

  TunerPipeline._(
    this._input,
    this._permission,
    this.config,
    this._collectDiagnostics,
    this._session,
  );

  final AudioInput _input;
  final MicrophonePermission _permission;

  /// What is asked of the platform when capture starts.
  final AudioInputConfig config;
  final bool _collectDiagnostics;

  final StreamController<TunerState> _states =
      StreamController<TunerState>.broadcast();

  final TuningSession _session;
  AudioPipeline? _audio;
  StreamSubscription<Uint8List>? _bytes;
  StreamSubscription<AudioInputStop>? _stops;
  bool _starting = false;

  /// The states the screen renders from.
  Stream<TunerState> get states => _states.stream;

  /// The latest state, for anything that needs it without subscribing.
  TunerState get state => _session.state;

  /// Whether the tuning-lock haptic is due.
  bool takeHapticCue() => _session.takeHapticCue();

  /// Asks for the microphone and begins listening.
  ///
  /// Safe to call twice: the second call does nothing rather than opening a
  /// second recorder.
  Future<void> start() async {
    if (_starting || _input.isRunning) return;
    _starting = true;
    try {
      var access = await _permission.status();
      if (access == MicrophoneAccess.denied) {
        access = await _permission.request();
      }
      _publish(_session.onPermission(access));
      if (access != MicrophoneAccess.granted) return;

      final stream = await _input.start(config);
      final format = _input.format;

      // The window follows the tuning, because a five-string bass's low B
      // needs twice as long a one to hold enough periods as a guitar does.
      final lowest = _session.state.tuning.openStrings.first.frequencyHz(
        referenceHz: _session.state.referenceHz,
      );
      final audio = AudioPipeline(
        sampleRate: format?.sampleRate ?? config.sampleRate,
        windowSize: AudioPipeline.windowSizeFor(lowest),
      );
      _audio = audio;
      if (_collectDiagnostics) _session.describePipeline(audio);

      _stops = _input.interruptions.listen(_onInterrupted);
      _bytes = stream.listen(
        _onBytes,
        onError: _onStreamError,
        onDone: _onStreamDone,
        cancelOnError: true,
      );

      _publish(_session.onStarted());
    } on Failure catch (failure) {
      await _release();
      _publish(_session.onError(failure));
    } on Object catch (error) {
      await _release();
      _publish(
        _session.onError(UnexpectedFailure(technicalDetail: '$error')),
      );
    } finally {
      _starting = false;
    }
  }

  /// Stops listening and releases the microphone.
  Future<void> stop() async {
    await _release();
    _publish(_session.onStopped());
  }

  /// Opens the operating system's settings page for this app.
  Future<bool> openSettings() => _permission.openSettings();

  /// Locks the tuner to one string.
  void selectString(int index) => _publish(_session.selectString(index));

  /// Hands the choice of string back to the tuner.
  void selectAuto() => _publish(_session.selectAuto());

  /// Changes tuning, restarting the audio if the window length has to change.
  Future<void> selectTuning(Tuning tuning) async {
    final wasListening = _input.isRunning;
    _publish(_session.selectTuning(tuning));

    final needed = AudioPipeline.windowSizeFor(
      tuning.openStrings.first.frequencyHz(
        referenceHz: _session.state.referenceHz,
      ),
    );
    if (wasListening && needed != _audio?.windowSize) {
      await stop();
      await start();
    }
  }

  /// Switches to naming any note rather than one of a tuning's strings.
  void selectChromatic() => _publish(_session.selectChromatic());

  /// Changes what A4 is taken to be.
  void setReferencePitch(double hz) => _publish(_session.setReferencePitch(hz));

  /// Releases the microphone and closes the state stream for good.
  Future<void> dispose() async {
    await _release();
    await _input.dispose();
    await _states.close();
  }

  void _onBytes(Uint8List chunk) {
    _audio?.addPcm16(chunk, (frame) => _publish(_session.onFrame(frame)));
  }

  void _onInterrupted(AudioInputStop reason) {
    unawaited(_release());
    _publish(_session.onInterrupted());
  }

  void _onStreamDone() {
    if (!_input.isRunning) return;
    unawaited(_release());
    _publish(_session.onInterrupted());
  }

  void _onStreamError(Object error) {
    unawaited(_release());
    _publish(_session.onError(UnexpectedFailure(technicalDetail: '$error')));
  }

  Future<void> _release() async {
    await _bytes?.cancel();
    _bytes = null;
    await _stops?.cancel();
    _stops = null;
    _audio?.reset();
    _audio = null;
    await _input.stop();
  }

  void _publish(TunerState state) {
    if (!_states.isClosed) _states.add(state);
  }
}
