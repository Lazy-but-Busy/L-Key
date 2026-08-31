/// The speaker seam.
///
/// The mirror of `AudioInput` on the way out, and deliberately the same shape:
/// an interface that knows nothing about music, one platform file behind it,
/// and an implementation that admits when a device cannot play.
///
/// Contains no Flutter. See docs/adr/0016.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// What to ask the platform for when opening the speaker.
@immutable
final class AudioOutputConfig {
  /// Creates a playback request.
  const AudioOutputConfig({
    this.sampleRate = 44100,
    this.channels = 1,
    this.blockFrames = 512,
    this.feedThresholdFrames = 1536,
    this.targetBufferFrames = 3072,
    this.allowBackgroundAudio = false,
  });

  /// Requested samples per second. **A request, not a guarantee** — and this
  /// plugin offers no way to read back what the device granted.
  ///
  /// Unlike the tuner, where a substituted rate is a silent error, here it is
  /// audible: every tempo would be wrong by the same ratio. That is what
  /// docs/DEVICE-TESTING.md's drift measurement exists to catch.
  final int sampleRate;

  /// Requested channel count.
  final int channels;

  /// How many frames are rendered and handed over per feed.
  ///
  /// 512 is about 11.6 ms at 44.1 kHz. Small on purpose: the played-frame
  /// count only advances once per feed, and it is what moves the beat
  /// indicator, so the block length is also the visual quantisation. A block
  /// of 4096 would be a 93 ms lag between the click and the dot, which reads
  /// as the picture lagging the sound.
  final int blockFrames;

  /// Below this many queued frames the platform asks for more.
  ///
  /// Three blocks, so a refill is requested while three still stand ahead of
  /// it.
  final int feedThresholdFrames;

  /// How full the queue is kept.
  ///
  /// Six blocks, about 70 ms. This is the whole margin against a starved
  /// event loop, and it is why a hiccup is a rare audible gap rather than a
  /// drift.
  final int targetBufferFrames;

  /// Whether playback should continue when the app is not in the foreground.
  ///
  /// A metronome is asked to keep time while a player looks at a chart or
  /// locks the phone, which is the one audio feature in this app where
  /// carrying on is the correct behaviour rather than the battery cost
  /// `CLAUDE.md §50` warns about.
  final bool allowBackgroundAudio;
}

/// The format audio is actually being played in.
@immutable
final class AudioOutputFormat {
  /// Creates a format.
  const AudioOutputFormat({required this.sampleRate, required this.channels});

  /// Samples per second, as granted.
  final int sampleRate;

  /// Channels per frame, as granted.
  final int channels;

  @override
  bool operator ==(Object other) =>
      other is AudioOutputFormat &&
      other.sampleRate == sampleRate &&
      other.channels == channels;

  @override
  int get hashCode => Object.hash(sampleRate, channels);

  @override
  String toString() => 'AudioOutputFormat($sampleRate Hz, $channels ch)';
}

/// Why playback stopped without being asked to.
enum AudioOutputStop {
  /// Something else took the speaker: a call, an alarm, another app.
  interrupted,

  /// The platform ended playback and gave no reason.
  ended,
}

/// Asked for the next block of samples.
///
/// [remainingFrames] is what the platform still has queued — zero means the
/// buffer ran dry and a gap has already been heard.
typedef AudioOutputFeed = void Function(int remainingFrames);

/// A sink for raw playback audio.
///
/// Deliberately dumb, exactly as `AudioInput` is: it takes signed 16-bit
/// little-endian mono frames and knows nothing about tempo, beats or clicks.
///
/// **It is pull-driven, and that is the point.** The platform asks for the
/// next block when its own buffer runs low, so the device's sample clock —
/// not a Dart timer — decides when audio is consumed. Everything above this
/// interface computes *where* a click sits in the sample stream rather than
/// *when* to play it, which is what keeps a metronome from drifting
/// (docs/adr/0016).
///
/// Implementations must release the speaker in [stop]; a metronome left
/// playing behind a closed screen is the battery cost `CLAUDE.md §50` is
/// about.
abstract interface class AudioOutput {
  /// Whether this device can actually play audio.
  ///
  /// Asked rather than discovered by catching: an implementation that cannot
  /// play says so, following `ChordAudioPlayer.isAvailable`. Callers must
  /// check it before [start], which throws when it is false.
  bool get isAvailable;

  /// Opens the speaker and begins asking [onFeed] for samples.
  ///
  /// [onFeed] is called once per low-buffer or drained event, and must respond
  /// by calling [feed] exactly once.
  Future<void> start(
    AudioOutputConfig config, {
    required AudioOutputFeed onFeed,
  });

  /// Hands the platform the next block of samples.
  ///
  /// The list is copied by the platform before this returns, so the caller may
  /// reuse its buffer — which the renderer does, because allocating a fresh
  /// one ten times a second forever is garbage an app holding 60fps cannot
  /// afford.
  Future<void> feed(Int16List frames);

  /// The format audio is actually playing in, once running.
  AudioOutputFormat? get format;

  /// Fires when playback stops without [stop] having been called.
  Stream<AudioOutputStop> get interruptions;

  /// Stops playback and releases the speaker.
  Future<void> stop();

  /// Whether audio is currently playing.
  bool get isRunning;

  /// Releases the underlying player for good.
  Future<void> dispose();
}

/// The output for a device that cannot play audio.
///
/// Follows `UnavailableAudioInput` and `UnavailableChordAudioPlayer`: an
/// implementation that admits it cannot do the job rather than pretending
/// (CLAUDE.md §47). It is also the default the providers hand out, so a test
/// that forgets an override reaches this instead of a platform plugin.
final class UnavailableAudioOutput implements AudioOutput {
  /// Creates the unavailable output.
  const UnavailableAudioOutput();

  @override
  bool get isAvailable => false;

  @override
  AudioOutputFormat? get format => null;

  @override
  Stream<AudioOutputStop> get interruptions =>
      const Stream<AudioOutputStop>.empty();

  @override
  bool get isRunning => false;

  @override
  Future<void> start(
    AudioOutputConfig config, {
    required AudioOutputFeed onFeed,
  }) async => throw StateError('no audio output is available on this device');

  @override
  Future<void> feed(Int16List frames) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
