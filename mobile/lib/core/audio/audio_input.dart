/// The microphone seam.
///
/// Contains no Flutter. See docs/adr/0012.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// What to ask the platform for.
///
/// The three processing flags are off, and that is not a default worth
/// changing. Automatic gain control fights the level gate and flattens the
/// decay of a plucked note; noise suppression and echo cancellation are tuned
/// for speech and reshape exactly the harmonic structure the detector reads.
/// All three make a tuner worse.
@immutable
final class AudioInputConfig {
  /// Creates a capture request.
  const AudioInputConfig({
    this.sampleRate = 44100,
    this.channels = 1,
    this.autoGain = false,
    this.noiseSuppress = false,
    this.echoCancel = false,
  });

  /// Requested samples per second. **A request, not a guarantee** — read the
  /// granted rate back from [AudioInput.format] once running.
  final int sampleRate;

  /// Requested channel count.
  final int channels;

  /// Whether the platform may ride the input gain.
  final bool autoGain;

  /// Whether the platform may apply speech noise suppression.
  final bool noiseSuppress;

  /// Whether the platform may apply echo cancellation.
  final bool echoCancel;
}

/// The format audio is actually arriving in.
@immutable
final class AudioInputFormat {
  /// Creates a format.
  const AudioInputFormat({required this.sampleRate, required this.channels});

  /// Samples per second, as granted.
  final int sampleRate;

  /// Channels per frame, as granted.
  final int channels;

  @override
  bool operator ==(Object other) =>
      other is AudioInputFormat &&
      other.sampleRate == sampleRate &&
      other.channels == channels;

  @override
  int get hashCode => Object.hash(sampleRate, channels);

  @override
  String toString() => 'AudioInputFormat($sampleRate Hz, $channels ch)';
}

/// Why a capture stopped without being asked to.
enum AudioInputStop {
  /// Something else took the microphone: a call, an alarm, another app.
  interrupted,

  /// The platform ended the stream and gave no reason.
  ended,
}

/// A source of raw microphone audio.
///
/// Deliberately dumb: it hands over signed 16-bit little-endian mono bytes in
/// whatever size the platform feels like, and knows nothing about windows,
/// pitch or music. Everything above it is plain Dart and testable without a
/// device, and the plugin behind it can be replaced without any of that
/// moving (CLAUDE.md §14).
///
/// Implementations must release the microphone in [stop] — CLAUDE.md §50
/// makes that the single largest battery cost in the product.
abstract interface class AudioInput {
  /// Begins capture and returns the byte stream.
  ///
  /// Completes with a `PermissionFailure` when microphone access is refused.
  /// The returned stream is single-subscription.
  Future<Stream<Uint8List>> start(AudioInputConfig config);

  /// The format audio is actually arriving in, once running.
  ///
  /// **Never assume this matches what was requested.** A device that grants
  /// 48000 where 44100 was asked for shifts every reading by roughly a tone
  /// and a half, and nothing on screen would look wrong.
  AudioInputFormat? get format;

  /// Fires when capture stops without [stop] having been called.
  Stream<AudioInputStop> get interruptions;

  /// Stops capture and releases the microphone.
  Future<void> stop();

  /// Whether audio is currently being captured.
  bool get isRunning;

  /// Releases the underlying recorder for good.
  Future<void> dispose();
}

/// The input for a device that has no microphone available.
///
/// Follows `UnavailableChordAudioPlayer`: an implementation that admits it
/// cannot do the job rather than pretending (CLAUDE.md §47). It is also the
/// default the providers hand out, so a test that forgets an override reaches
/// this instead of a platform plugin.
final class UnavailableAudioInput implements AudioInput {
  /// Creates the unavailable input.
  const UnavailableAudioInput();

  @override
  AudioInputFormat? get format => null;

  @override
  Stream<AudioInputStop> get interruptions =>
      const Stream<AudioInputStop>.empty();

  @override
  bool get isRunning => false;

  @override
  Future<Stream<Uint8List>> start(AudioInputConfig config) async =>
      throw StateError('no microphone is available on this device');

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
