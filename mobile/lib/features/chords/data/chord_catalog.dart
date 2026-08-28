/// The chords the library offers, and the tier each one is labelled with.
///
/// This is the data layer, and it is deliberately where [FeatureTier] lives.
/// A chord's notes do not change with a subscription, so the engine and the
/// entities under `domain/` know nothing about tiers (CLAUDE.md §10). The
/// catalogue is the seam where a commercial label is attached to musical fact,
/// and even here the label grants nothing — CLAUDE.md §23 and §51 put
/// entitlement on the server.
library;

import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/features/chords/domain/chord.dart';
import 'package:l_key/features/chords/domain/chord_quality.dart';
import 'package:l_key/features/chords/domain/chord_voicing.dart';
import 'package:l_key/features/chords/domain/voicing_library.dart';
import 'package:meta/meta.dart';

/// One chord in the library, with a route-safe identifier and a tier label.
@immutable
final class ChordCatalogEntry {
  /// Creates a catalogue entry.
  const ChordCatalogEntry({
    required this.id,
    required this.chord,
    required this.tier,
  });

  /// A stable, URL-safe identifier, such as `c-major` or `c-sharp-m7b5`.
  ///
  /// Used as a route parameter, so it must survive a round trip through a URL
  /// and must not change once content links to it.
  final String id;

  /// The chord itself.
  final Chord chord;

  /// The tier this entry is *labelled* with. It authorizes nothing.
  final FeatureTier tier;

  @override
  bool operator ==(Object other) =>
      other is ChordCatalogEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A voicing together with the tier it is labelled with.
///
/// PRD.md §11 puts "alternative voicings" behind Premium. The label lives here
/// rather than on [ChordVoicing] so the engine stays free of it.
typedef TieredVoicing = ({ChordVoicing voicing, FeatureTier tier});

/// The full chord detail a screen needs.
@immutable
final class ChordDetail {
  /// Creates a chord detail.
  const ChordDetail({
    required this.entry,
    required this.voicings,
  });

  /// The catalogue entry.
  final ChordCatalogEntry entry;

  /// Playable shapes, nearest the nut first. May be empty.
  final List<TieredVoicing> voicings;

  /// The chord itself, for convenience.
  Chord get chord => entry.chord;
}

/// Builds and holds the chord catalogue.
abstract final class ChordCatalog {
  /// The root spellings the library browses.
  ///
  /// Seventeen rather than twelve: a player looking for D♭ should not have to
  /// know it is filed under C♯. The engine accepts any spelling; this is the
  /// list the browser shows.
  static const List<Note> roots = <Note>[
    Note(NoteLetter.c),
    Note(NoteLetter.c, Accidental.sharp),
    Note(NoteLetter.d, Accidental.flat),
    Note(NoteLetter.d),
    Note(NoteLetter.d, Accidental.sharp),
    Note(NoteLetter.e, Accidental.flat),
    Note(NoteLetter.e),
    Note(NoteLetter.f),
    Note(NoteLetter.f, Accidental.sharp),
    Note(NoteLetter.g, Accidental.flat),
    Note(NoteLetter.g),
    Note(NoteLetter.g, Accidental.sharp),
    Note(NoteLetter.a, Accidental.flat),
    Note(NoteLetter.a),
    Note(NoteLetter.a, Accidental.sharp),
    Note(NoteLetter.b, Accidental.flat),
    Note(NoteLetter.b),
  ];

  /// The chords PRD.md §11 names as available to everyone.
  ///
  /// Everything else is labelled Premium. The label is descriptive; nothing in
  /// this codebase acts on it.
  static const Set<String> _freeIds = <String>{
    'c-major',
    'd-major',
    'e-major',
    'f-major',
    'g-major',
    'a-major',
    'b-major',
    'a-minor',
    'd-minor',
    'e-minor',
  };

  /// Every chord in the library, roots ascending and simplest quality first.
  static List<ChordCatalogEntry> get entries {
    final built = <ChordCatalogEntry>[];
    for (final root in roots) {
      for (final quality in ChordQuality.values) {
        final id = idFor(Chord(root: root, quality: quality));
        built.add(
          ChordCatalogEntry(
            id: id,
            chord: Chord(root: root, quality: quality),
            tier: _freeIds.contains(id)
                ? FeatureTier.free
                : FeatureTier.premium,
          ),
        );
      }
    }
    for (final slash in slashVoicings) {
      final chord = Chord(
        root: slash.root,
        quality: slash.quality,
        bass: slash.bass,
      );
      built.add(
        ChordCatalogEntry(
          id: idFor(chord),
          chord: chord,
          tier: FeatureTier.premium,
        ),
      );
    }
    return List<ChordCatalogEntry>.unmodifiable(built);
  }

  /// The route-safe identifier for [chord].
  ///
  /// `C#m7b5` becomes `c-sharp-m7b5`; `G/B` becomes `g-major-over-b`. Sharps
  /// and flats are spelled out because `#` has to be escaped in a URL and a
  /// bare `b` is ambiguous next to a letter.
  static String idFor(Chord chord) {
    final buffer = StringBuffer(
      '${_noteSlug(chord.root)}-${chord.quality.slug}',
    );
    if (chord.bass != null) buffer.write('-over-${_noteSlug(chord.bass!)}');
    return buffer.toString();
  }

  static String _noteSlug(Note note) {
    final accidental = switch (note.accidental) {
      Accidental.doubleFlat => '-double-flat',
      Accidental.flat => '-flat',
      Accidental.natural => '',
      Accidental.sharp => '-sharp',
      Accidental.doubleSharp => '-double-sharp',
    };
    return '${note.letter.symbol.toLowerCase()}$accidental';
  }
}
