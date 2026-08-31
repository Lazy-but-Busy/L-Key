/// Placeholder content for the Home screen.
///
/// This stands in for data the song API will supply once Phase 09 lands. It
/// is deliberately isolated in one file so it is trivial to delete: nothing
/// here is localised, because song titles are content rather than interface
/// copy.
library;

/// A song as the Home and Songs screens render it.
class MockSong {
  /// Creates a placeholder song.
  const MockSong({
    required this.title,
    required this.artist,
    required this.tag,
    required this.bpm,
  });

  /// Song title.
  final String title;

  /// Performing artist, rendered uppercase.
  final String artist;

  /// Short descriptor such as `RHYTHM` or `LEAD`.
  final String tag;

  /// Tempo in beats per minute.
  final int bpm;
}

/// Recently played songs shown on Home.
const List<MockSong> mockRecentSongs = <MockSong>[
  MockSong(
    title: 'Master of Puppets',
    artist: 'Metallica',
    tag: 'RHYTHM',
    bpm: 120,
  ),
  MockSong(
    title: 'Voodoo Child',
    artist: 'Jimi Hendrix',
    tag: 'LEAD',
    bpm: 85,
  ),
];
