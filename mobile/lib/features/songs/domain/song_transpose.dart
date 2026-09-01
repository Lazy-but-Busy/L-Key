/// Transposing a whole song by semitone (PRD.md §21).
///
/// `Chord.transpose` already transposes one chord; this walks a song's
/// ChordPro body and applies it to every bracketed chord token, leaving the
/// lyrics, whitespace, section directives and any chord it cannot spell
/// completely untouched — which is what "preserve song structure" and
/// "preserve slash chords" come down to at the text level.
///
/// Contains no Flutter.
library;

import 'package:l_key/features/chords/domain/chord_symbol.dart';
import 'package:l_key/features/songs/domain/song.dart';

/// Transposes a [Song] by semitone.
abstract final class SongTranspose {
  static final RegExp _bracketChord = RegExp(r'\[([^\[\]]*)\]');

  /// The same song [semitones] higher (or lower, if negative), with its key
  /// and every chord it could spell respelled to match.
  ///
  /// A bracket whose contents are not a chord this app understands is left
  /// exactly as written, rather than thrown away (CLAUDE.md §37) — the same
  /// rule `ChordProParser` applies when reading it.
  static Song transpose(Song song, int semitones, {bool preferFlats = false}) {
    if (semitones == 0) return song;

    final transposedBody = song.chordPro.replaceAllMapped(_bracketChord, (
      match,
    ) {
      final chord = ChordSymbol.tryParse(match.group(1) ?? '');
      if (chord == null) return match.group(0)!;
      final moved = chord.transpose(semitones, preferFlats: preferFlats);
      return '[${moved.symbol}]';
    });

    return Song(
      title: song.title,
      artist: song.artist,
      key: song.key.transposeChromatically(
        semitones,
        preferFlats: preferFlats,
      ),
      bpm: song.bpm,
      tuning: song.tuning,
      capo: song.capo,
      chordPro: transposedBody,
      language: song.language,
    );
  }
}
