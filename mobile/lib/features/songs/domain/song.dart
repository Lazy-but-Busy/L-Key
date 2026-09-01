/// A song: title, artist, key, tempo, tuning, and its ChordPro content.
///
/// The song knows nothing about being Premium or free — that label lives in
/// the catalogue entry that pairs a `Song` with a `FeatureTier`, in the data
/// layer, the same split `Chord`/`ChordCatalogEntry` uses (CLAUDE.md §10,
/// docs/ARCHITECTURE.md).
///
/// Contains no Flutter.
library;

import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:meta/meta.dart';

/// Which of the song-library language filters a song belongs to
/// (CLAUDE.md §32, PRD.md §40).
enum SongLanguage {
  /// English-language lyrics.
  english,

  /// Myanmar-language lyrics.
  myanmar,
}

/// A song, as the library, the viewer and the transposer share it.
@immutable
final class Song {
  /// Creates a song.
  const Song({
    required this.title,
    required this.artist,
    required this.key,
    required this.bpm,
    required this.tuning,
    required this.chordPro,
    this.capo = 0,
    this.language = SongLanguage.english,
  });

  /// Song title.
  final String title;

  /// Performing artist, or `Traditional` for content with none.
  final String artist;

  /// The key the song is written in.
  final Note key;

  /// Tempo in beats per minute.
  final int bpm;

  /// The tuning the chords assume.
  final Tuning tuning;

  /// Suggested capo fret. 0 means no capo.
  final int capo;

  /// The song's chords and lyrics, in ChordPro (PRD.md §19–20).
  ///
  /// Parsed on demand by `ChordProParser` rather than eagerly, so a song a
  /// screen never opens never pays for parsing.
  final String chordPro;

  /// Which language filter this song matches.
  final SongLanguage language;

  @override
  bool operator ==(Object other) =>
      other is Song &&
      other.title == title &&
      other.artist == artist &&
      other.chordPro == chordPro;

  @override
  int get hashCode => Object.hash(title, artist, chordPro);

  @override
  String toString() => '$title — $artist';
}
