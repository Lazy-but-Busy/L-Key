/// The songs the library offers, and the tier each one is labelled with.
///
/// This is the data layer, and it is deliberately where [FeatureTier] lives —
/// a song's chords do not change with a subscription, so `Song` itself knows
/// nothing about tiers (CLAUDE.md §10), the same split `Chord` and
/// `ChordCatalogEntry` use.
///
/// The bundled songs are placeholder content standing in for the Song CMS
/// (PRD.md §50): two public-domain traditionals with no rights concerns, and
/// one Myanmar-language sample built from the app's own tagline rather than
/// any third party's lyrics (CLAUDE.md §31 — never scrape or embed
/// copyrighted song content). None of this ships as real catalogue content;
/// it exists so the library, search, and viewer have something honest to
/// show before Phase 09's content API exists.
library;

import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/songs/domain/song.dart';
import 'package:meta/meta.dart';

/// One song in the library, with a route-safe identifier and a tier label.
@immutable
final class SongCatalogEntry {
  /// Creates a catalogue entry.
  const SongCatalogEntry({
    required this.id,
    required this.song,
    required this.tier,
  });

  /// A stable, URL-safe identifier, such as `amazing-grace`.
  final String id;

  /// The song itself.
  final Song song;

  /// The tier this entry is *labelled* with. It authorizes nothing
  /// (CLAUDE.md §23, §51).
  final FeatureTier tier;

  @override
  bool operator ==(Object other) => other is SongCatalogEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Builds and holds the song catalogue.
abstract final class SongCatalog {
  static const Song _amazingGrace = Song(
    title: 'Amazing Grace',
    artist: 'Traditional',
    key: Note(NoteLetter.g),
    bpm: 76,
    tuning: Tuning.standard,
    chordPro: '''
{title: Amazing Grace}
{artist: Traditional}
{key: G}

{start_of_verse}
[G]Amazing [G7]grace, how [C]sweet the [G]sound
That [Em]saved a [D]wretch like [G]me
[G]I [G7]once was [C]lost, but [G]now am [D]found
Was [G]blind, but [D]now I [G]see
{end_of_verse}''',
  );

  static const Song _scarboroughFair = Song(
    title: 'Scarborough Fair',
    artist: 'Traditional',
    key: Note(NoteLetter.d),
    bpm: 96,
    tuning: Tuning.standard,
    chordPro: '''
{title: Scarborough Fair}
{artist: Traditional}
{key: Dm}

{start_of_verse}
Are you [Dm]going to [C]Scarborough [Dm]Fair
[C]Parsley, [Dm]sage, rose[C]mary and [Dm]thyme
Re[Dm]member me [C]to one who [Dm]lives there
[C]She once [Dm]was a true [C]love of [Dm]mine
{end_of_verse}''',
  );

  static const Song _sampleMyanmarSong = Song(
    title: 'သီချင်းနမူနာ',
    artist: 'L Key Originals',
    key: Note(NoteLetter.c),
    bpm: 100,
    tuning: Tuning.standard,
    language: SongLanguage.myanmar,
    chordPro: '''
{title: သီချင်းနမူနာ}
{artist: L Key Originals}
{key: C}

{start_of_verse}
[C]ညှိပါ။ [F]လေ့လာပါ။ [G]လေ့ကျင့်ပါ။ [C]တီးပါ။
{end_of_verse}''',
  );

  /// Every song the app ships as sample content, in library order.
  static const List<SongCatalogEntry> entries = <SongCatalogEntry>[
    SongCatalogEntry(
      id: 'amazing-grace',
      song: _amazingGrace,
      tier: FeatureTier.free,
    ),
    SongCatalogEntry(
      id: 'scarborough-fair',
      song: _scarboroughFair,
      tier: FeatureTier.premium,
    ),
    SongCatalogEntry(
      id: 'sample-song-my',
      song: _sampleMyanmarSong,
      tier: FeatureTier.free,
    ),
  ];
}
