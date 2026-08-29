/// The `record`-backed [AudioInput].
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:l_key/core/audio/audio_input.dart';
import 'package:l_key/core/errors/failure.dart';
import 'package:record/record.dart';

/// Captures raw PCM from the microphone through the `record` plugin.
///
/// The only file in the application that imports that package, which a layer
/// test asserts. Everything above it is plain Dart.
final class RecordAudioInput implements AudioInput {
  /// Creates an input, optionally over an existing [recorder].
  RecordAudioInput({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  final StreamController<AudioInputStop> _interruptions =
      StreamController<AudioInputStop>.broadcast();

  StreamSubscription<RecordState>? _states;
  AudioInputFormat? _format;
  bool _running = false;
  bool _stopping = false;

  @override
  AudioInputFormat? get format => _format;

  @override
  Stream<AudioInputStop> get interruptions => _interruptions.stream;

  @override
  bool get isRunning => _running;

  @override
  Future<Stream<Uint8List>> start(AudioInputConfig config) async {
    if (_running) throw StateError('already capturing');

    if (!await _recorder.hasPermission(request: false)) {
      throw const PermissionFailure(
        permission: 'microphone',
        technicalDetail: 'record reported no microphone permission',
      );
    }

    // The granted configuration, which is not always the requested one. The
    // plugin only calls back when something differs, so the requested values
    // stand until it says otherwise — and if a device substitutes 48000 for
    // 44100 this is what keeps every reading correct rather than a tone and a
    // half sharp.
    _format = AudioInputFormat(
      sampleRate: config.sampleRate,
      channels: config.channels,
    );
    await _recorder.setOnConfigChanged((granted) {
      _format = AudioInputFormat(
        sampleRate: granted.sampleRate,
        channels: granted.numChannels,
      );
    });

    final stream = await _recorder.startStream(
      RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: config.sampleRate,
        numChannels: config.channels,
        autoGain: config.autoGain,
        noiseSuppress: config.noiseSuppress,
        echoCancel: config.echoCancel,
        // The least-processed source the platform offers. Anything else
        // applies speech tuning, which reshapes the harmonic structure the
        // detector reads and rolls off exactly where a low E lives.
        androidConfig: const AndroidRecordConfig(
          audioSource: AndroidAudioSource.unprocessed,
        ),
        // iOS suppresses haptics while recording unless asked not to, and the
        // tuner's whole tactile signal is the buzz when a string locks
        // (DESIGN.md §40).
        iosConfig: const IosRecordConfig(
          allowHapticsAndSystemSoundsDuringRecording: true,
        ),
        // A call or an alarm pauses capture and resumes it, rather than
        // ending the session and making the player start again.
        audioInterruption: AudioInterruptionMode.pauseResume,
      ),
    );

    _running = true;
    _states = _recorder.onStateChanged().listen(_onState);
    return stream;
  }

  void _onState(RecordState state) {
    if (!_running || _stopping) return;
    switch (state) {
      case RecordState.pause:
        _interruptions.add(AudioInputStop.interrupted);
      case RecordState.stop:
        _running = false;
        _interruptions.add(AudioInputStop.ended);
      case RecordState.record:
        break;
    }
  }

  @override
  Future<void> stop() async {
    if (!_running) return;
    _stopping = true;
    try {
      await _states?.cancel();
      _states = null;
      await _recorder.stop();
    } finally {
      _running = false;
      _stopping = false;
      _format = null;
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _interruptions.close();
    await _recorder.dispose();
  }
}
