/// The click voices the metronome can speak in.
///
/// Contains no Flutter and reads no clock. See docs/adr/0016.
library;

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
  stick,
}
