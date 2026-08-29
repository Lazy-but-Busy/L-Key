/// One window of audio, on its way to the analyzers.
///
/// Contains no Flutter. See docs/adr/0012.
library;

import 'dart:typed_data';

/// A fixed-length window of mono samples, normalised to −1.0…1.0.
///
/// **[samples] is a buffer the assembler reuses.** It holds this window's
/// audio only for the duration of the synchronous call it was handed to, and
/// the next frame overwrites it. Anything that needs to outlive the call must
/// copy. This is deliberate and is why the class is not `@immutable` like the
/// rest of `core/`: at forty-three windows a second a fresh
/// `Float64List(4096)` each time is 1.4 MB/s of garbage in an app that has to
/// hold 60fps (mobile CLAUDE.md §15, PRD.md §63). Claiming immutability here
/// would be a lie, and a lie the compiler cannot catch.
final class AudioFrame {
  /// Wraps [samples] with the rate and time they were captured at.
  const AudioFrame({
    required this.samples,
    required this.sampleRate,
    required this.timestamp,
  });

  /// The window's audio, normalised to −1.0…1.0. Borrowed, not owned.
  final Float64List samples;

  /// Samples per second, **as the device actually granted it**.
  ///
  /// Never assume the rate that was requested. A device that quietly
  /// substitutes 48000 for 44100 shifts every reading by roughly a tone and a
  /// half, silently, and everything downstream derives its bounds from this
  /// field so that substitution stays harmless.
  final int sampleRate;

  /// When this window began, measured from the start of the stream.
  ///
  /// Counted from samples, not read from a clock, so a test that feeds a
  /// known number of windows advances time by exactly the same amount on
  /// every machine.
  final Duration timestamp;

  /// How many samples the window holds.
  int get length => samples.length;
}
