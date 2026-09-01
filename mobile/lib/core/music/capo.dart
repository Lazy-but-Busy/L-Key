/// The capo assistant's arithmetic: played key vs. sounding key (PRD.md §22).
///
/// A capo raises every open string by a fixed number of semitones, so the
/// chord shapes a player fingers ("play C") sound a different key than what
/// is written on the page ("sounds D") once the capo goes on. This is plain
/// semitone transposition over [Note.transposeChromatically] — no new music
/// theory, just the direction reversed for the "what capo gets me this key"
/// question.
///
/// Contains no Flutter. See docs/adr/0009.
library;

import 'package:l_key/core/music/note.dart';
import 'package:meta/meta.dart';

/// One capo position and the key relationship it creates.
@immutable
final class CapoPosition {
  /// Creates a capo position.
  const CapoPosition({
    required this.fret,
    required this.playedKey,
    required this.soundingKey,
  });

  /// The fret the capo sits on. 0 means no capo.
  final int fret;

  /// The key the player fingers, reading chord shapes as if in this key.
  final Note playedKey;

  /// The key that actually sounds once the capo raises every string.
  final Note soundingKey;

  @override
  bool operator ==(Object other) =>
      other is CapoPosition &&
      other.fret == fret &&
      other.playedKey == playedKey &&
      other.soundingKey == soundingKey;

  @override
  int get hashCode => Object.hash(fret, playedKey, soundingKey);

  @override
  String toString() => 'Capo $fret: play $playedKey, sounds $soundingKey';
}

/// Capo position math: played key, sounding key, and the alternatives.
abstract final class CapoEngine {
  /// The key that sounds when [playedKey] is fingered with a capo at [fret].
  ///
  /// PRD.md §22's own example: `soundingKeyFor(C, 2)` is D — "Capo 2, Play C,
  /// Sounds D".
  static Note soundingKeyFor(
    Note playedKey,
    int fret, {
    bool preferFlats = false,
  }) => playedKey.transposeChromatically(fret, preferFlats: preferFlats);

  /// Every capo position from 0–7 that produces [soundingKey], with the
  /// played key each one would require.
  ///
  /// PRD.md §22 calls these the "alternative capo positions" — the same
  /// target key reached by fingering a different shape further up the neck.
  static List<CapoPosition> alternativesFor(
    Note soundingKey, {
    bool preferFlats = false,
  }) => <CapoPosition>[
    for (var fret = 0; fret <= 7; fret++)
      CapoPosition(
        fret: fret,
        playedKey: soundingKey.transposeChromatically(
          -fret,
          preferFlats: preferFlats,
        ),
        soundingKey: soundingKey,
      ),
  ];
}
