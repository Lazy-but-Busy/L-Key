/// The seam a chord's audio playback will arrive behind.
///
/// **Nothing here makes a sound.** PRD.md §11 lists audio playback on the
/// chord detail screen and DESIGN.md §23 draws a play button, but sampling or
/// synthesising a guitar is its own piece of work. CLAUDE.md §47 forbids
/// pretending otherwise, so the interface exists, the only implementation
/// reports itself unavailable, and the screen says so rather than showing a
/// button that does nothing.
///
/// This mirrors `core/audio/PitchDetector`: the seam is defined now so the
/// eventual implementation can be dropped in without the chord screen
/// changing (CLAUDE.md §14, docs/ARCHITECTURE.md).
///
/// Contains no Flutter.
library;

import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/chords/domain/chord_voicing.dart';

/// Sounds a chord voicing.
abstract interface class ChordAudioPlayer {
  /// Whether this player can actually produce sound right now.
  ///
  /// The interface must check this before offering playback. A player that
  /// returns false has no audio to give and will throw if asked.
  bool get isAvailable;

  /// Whether a voicing is sounding at this moment.
  bool get isPlaying;

  /// Sounds [voicing] as it would ring on [tuning].
  ///
  /// Throws [UnsupportedError] when [isAvailable] is false.
  Future<void> play(ChordVoicing voicing, {Tuning tuning = Tuning.standard});

  /// Stops anything currently sounding.
  Future<void> stop();
}

/// The only implementation there is: one that admits it cannot play.
///
/// Wired in as the default so the chord screen renders an honest disabled
/// control instead of a button that silently does nothing.
final class UnavailableChordAudioPlayer implements ChordAudioPlayer {
  /// Creates the unavailable player.
  const UnavailableChordAudioPlayer();

  @override
  bool get isAvailable => false;

  @override
  bool get isPlaying => false;

  @override
  Future<void> play(
    ChordVoicing voicing, {
    Tuning tuning = Tuning.standard,
  }) async {
    throw UnsupportedError(
      'No chord audio engine is installed. Check isAvailable before calling '
      'play.',
    );
  }

  @override
  Future<void> stop() async {}
}
