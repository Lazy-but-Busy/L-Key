/// The click voices the metronome can speak in.
///
/// Contains no Flutter and reads no clock. See docs/adr/0016.
library;

import 'package:l_key/features/metronome/domain/time_signature.dart';
import 'package:meta/meta.dart';

/// How one click is built.
///
/// Every voice is the same recipe with different numbers: a band-passed noise
/// burst for the attack, a sine body under it for pitch, and one envelope over
/// both. Keeping the method identical across levels is what makes the four
/// accents of a sound recognisably one instrument rather than four.
@immutable
final class ClickVoiceSpec {
  /// Creates a voice.
  const ClickVoiceSpec({
    required this.centreHz,
    required this.q,
    required this.noiseMix,
    required this.bodyHz,
    required this.decayMs,
    required this.peak,
    this.attackMs = 1.5,
    this.seed = 0x5EED,
  });

  /// Where the noise burst is centred, in hertz.
  final double centreHz;

  /// Centre frequency over bandwidth. Higher is narrower, and more pitched.
  final double q;

  /// How much of the result is noise rather than the sine body, 0 to 1.
  final double noiseMix;

  /// The pitch of the body under the burst, in hertz.
  final double bodyHz;

  /// How long the click takes to fall to silence, in milliseconds.
  final double decayMs;

  /// How loud the click is at its peak, 0 to 1.
  final double peak;

  /// How long the click takes to reach full amplitude, in milliseconds.
  ///
  /// Not zero. A hard step is a broadband pop that some converters clip, and
  /// a millisecond and a half is inaudible as softening.
  final double attackMs;

  /// The noise seed.
  ///
  /// A field rather than a constant so a click renders to the same samples
  /// every time, which is what lets a test assert the waveform.
  final int seed;
}

/// Which click the metronome sounds.
///
/// Every one is synthesised rather than shipped as an audio file. Four sounds
/// across four accent levels would be sixteen recordings, a decoder and a
/// resampling path; each of these is a handful of numbers that renders to the
/// same samples on every device, which is also what lets a test assert the
/// waveform rather than trust it (docs/adr/0016).
enum ClickSound {
  /// Warm and acoustic. The default, and the only free-labelled sound.
  woodblock,

  /// Dry, electronic and very short. The most precise-feeling.
  click,

  /// A plain digital metronome tone. Cuts through a loud room.
  beep,

  /// A percussive rim, with a little body under it.
  stick;

  /// How this sound speaks at [level], or null when it says nothing.
  ///
  /// Levels differ only in frequency and loudness, never in method. The
  /// accent is carried by both together, because pitch alone is lost on a
  /// phone speaker and loudness alone is lost in a loud room.
  ClickVoiceSpec? voiceFor(AccentLevel level) {
    if (level == AccentLevel.silent) return null;

    final (centre, peak) = switch (level) {
      AccentLevel.strong => (2.0, 0.90),
      AccentLevel.accent => (1.4, 0.70),
      AccentLevel.normal => (1.0, 0.55),
      AccentLevel.subdivision => (1.6, 0.30),
      AccentLevel.silent => (1.0, 0.0),
    };

    return switch (this) {
      ClickSound.woodblock => ClickVoiceSpec(
        centreHz: 1000 * centre,
        q: 2,
        noiseMix: 0.55,
        bodyHz: 800 * centre,
        decayMs: 32,
        peak: peak,
      ),
      ClickSound.click => ClickVoiceSpec(
        centreHz: 2200 * centre,
        q: 1.2,
        noiseMix: 0,
        bodyHz: 1400 * centre,
        decayMs: 8,
        peak: peak,
      ),
      ClickSound.beep => ClickVoiceSpec(
        centreHz: 1000 * centre,
        q: 4,
        noiseMix: 0,
        bodyHz: 1000 * centre,
        decayMs: 45,
        peak: peak,
        attackMs: 4,
      ),
      ClickSound.stick => ClickVoiceSpec(
        centreHz: 1800 * centre,
        q: 0.8,
        noiseMix: 0.85,
        bodyHz: 220 * centre,
        decayMs: 55,
        peak: peak,
      ),
    };
  }
}
