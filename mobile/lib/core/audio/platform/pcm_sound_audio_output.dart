/// The `flutter_pcm_sound`-backed [AudioOutput].
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:l_key/core/audio/audio_output.dart';

/// Plays raw PCM through the `flutter_pcm_sound` plugin.
///
/// The only file in the application that imports that package, which a layer
/// test asserts. Everything above it is plain Dart.
///
/// The plugin's API is entirely static, so this class is the piece that gives
/// it an instance's lifetime: two metronomes cannot be open at once, and
/// [stop] is what actually hands the speaker back.
final class PcmSoundAudioOutput implements AudioOutput {
  /// Creates an output.
  PcmSoundAudioOutput();

  final StreamController<AudioOutputStop> _interruptions =
      StreamController<AudioOutputStop>.broadcast();

  AudioOutputFormat? _format;
  bool _running = false;

  @override
  AudioOutputFormat? get format => _format;

  @override
  Stream<AudioOutputStop> get interruptions => _interruptions.stream;

  @override
  bool get isRunning => _running;

  @override
  Future<void> start(
    AudioOutputConfig config, {
    required AudioOutputFeed onFeed,
  }) async {
    if (_running) throw StateError('already playing');

    // The plugin prints a line on every method call at its default level, and
    // a metronome calls `feed` ten times a second for as long as a player
    // practises. CLAUDE.md §38 wants verbose logging gone before release;
    // this is the switch that removes it.
    await FlutterPcmSound.setLogLevel(LogLevel.none);

    await FlutterPcmSound.setup(
      sampleRate: config.sampleRate,
      channelCount: config.channels,
      // Playback, so the click keeps sounding with the screen locked rather
      // than being ducked or silenced (docs/adr/0016). It is the plugin's
      // default today, and stated anyway: the difference between playback and
      // ambient is whether a locked phone keeps time, which is too load
      // bearing to inherit silently.
      // ignore: avoid_redundant_argument_values
      iosAudioCategory: IosAudioCategory.playback,
      iosAllowBackgroundAudio: config.allowBackgroundAudio,
    );

    // The requested rate is all there is; see AudioOutputConfig.sampleRate.
    _format = AudioOutputFormat(
      sampleRate: config.sampleRate,
      channels: config.channels,
    );

    await FlutterPcmSound.setFeedThreshold(config.feedThresholdFrames);
    FlutterPcmSound.setFeedCallback((remainingFrames) {
      if (_running) onFeed(remainingFrames);
    });

    _running = true;

    // Primes the pump: the plugin only starts asking for samples once it has
    // been given some, so the first block is requested explicitly.
    FlutterPcmSound.start();
  }

  @override
  Future<void> feed(Int16List frames) async {
    if (!_running) return;
    // The plugin sends `bytes.buffer` in its entirety, so the view handed over
    // must span exactly the frames meant to be played and nothing else. The
    // renderer's buffer owns its own store, which is what makes this a
    // zero-copy hand-off rather than the per-call allocation
    // `PcmArrayInt16.fromList` would cost ten times a second.
    await FlutterPcmSound.feed(
      PcmArrayInt16(bytes: frames.buffer.asByteData()),
    );
  }

  @override
  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    _format = null;
    FlutterPcmSound.setFeedCallback(null);
    await FlutterPcmSound.release();
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _interruptions.close();
  }
}
