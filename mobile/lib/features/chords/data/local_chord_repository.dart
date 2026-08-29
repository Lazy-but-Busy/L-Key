/// The offline chord library.
///
/// Answers entirely from the const catalogue and the engine, so the chord
/// library works with no network at all — which CLAUDE.md §19 requires of it,
/// and which is the whole reason the music engines contain no I/O.
library;

import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/chords/data/chord_catalog.dart';
import 'package:l_key/features/chords/domain/chord_engine.dart';
import 'package:l_key/features/chords/domain/chord_repository.dart';

/// A [ChordRepository] backed by the built-in catalogue.
final class LocalChordRepository implements ChordRepository {
  /// Creates a repository over the built-in catalogue.
  const LocalChordRepository({this.tuning = Tuning.standard});

  /// The tuning voicings are calculated against.
  final Tuning tuning;

  @override
  Future<List<ChordCatalogEntry>> browse() async => ChordCatalog.entries;

  @override
  Future<ChordDetail?> detail(String id) async {
    for (final entry in ChordCatalog.entries) {
      if (entry.id != id) continue;
      final voicings = ChordEngine.voicingsFor(entry.chord, tuning: tuning);
      return ChordDetail(
        entry: entry,
        voicings: <TieredVoicing>[
          for (var index = 0; index < voicings.length; index++)
            (
              voicing: voicings[index],
              // PRD.md §11 calls alternative voicings a Premium capability.
              // The first shape a player sees is never labelled.
              tier: index == 0 ? FeatureTier.free : entry.tier,
            ),
        ],
      );
    }
    return null;
  }
}
