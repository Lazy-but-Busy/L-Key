/// What the fretboard offers, and the tier each entry is labelled with.
///
/// This is the data layer, and it is deliberately where [FeatureTier] lives.
/// A scale's notes do not change with a subscription, so `core/music/` and
/// `fretboard/domain/` know nothing about tiers (CLAUDE.md §10). Even here the
/// label grants nothing — CLAUDE.md §23 and §51 put entitlement on the server,
/// and every entry in this file opens.
///
/// The scales feature reads these lists too. A scale screen is a fretboard
/// view of one scale, and one owner for the catalogue is better than two that
/// can disagree; see docs/adr/0011.
library;

import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/scale.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:meta/meta.dart';

/// A catalogue entry: something the picker offers, and its tier label.
@immutable
final class TieredEntry<T> {
  /// Creates an entry.
  const TieredEntry(this.value, this.tier);

  /// The thing on offer.
  final T value;

  /// The tier it is *labelled* with. It authorizes nothing.
  final FeatureTier tier;
}

/// The tunings, scales, arpeggios and roots the fretboard offers.
abstract final class FretboardCatalog {
  /// The tunings, standard first.
  ///
  /// PRD.md §10.1 gives standard tuning to everyone and §10.2 puts the rest
  /// behind Premium, including the seven-string, eight-string and bass necks.
  static List<TieredEntry<Tuning>> get tunings => <TieredEntry<Tuning>>[
    for (final tuning in Tuning.catalogue)
      TieredEntry<Tuning>(
        tuning,
        tuning == Tuning.standard ? FeatureTier.free : FeatureTier.premium,
      ),
  ];

  /// The scales PRD.md §14 names as available to everyone.
  static const Set<ScaleType> _freeScales = <ScaleType>{
    ScaleType.major,
    ScaleType.naturalMinor,
    ScaleType.minorPentatonic,
    ScaleType.majorPentatonic,
    ScaleType.blues,
  };

  /// Every scale, in `ScaleType`'s own order: the scales, then the seven
  /// modes, then the pentatonics, the blues scale and the symmetric ones.
  static List<TieredEntry<ScaleType>> get scales => <TieredEntry<ScaleType>>[
    for (final type in ScaleType.values)
      TieredEntry<ScaleType>(
        type,
        _freeScales.contains(type) ? FeatureTier.free : FeatureTier.premium,
      ),
  ];

  /// The chord qualities offered as arpeggios.
  ///
  /// A subset of the eighteen the chord library spells: an arpeggio is played
  /// one note at a time, and the extended qualities crowd the neck into an
  /// unreadable wash rather than teaching a shape. PRD.md §13 puts arpeggios
  /// behind Premium as a group.
  static const List<ChordQuality> _arpeggioQualities = <ChordQuality>[
    ChordQuality.major,
    ChordQuality.minor,
    ChordQuality.diminished,
    ChordQuality.augmented,
    ChordQuality.majorSeventh,
    ChordQuality.minorSeventh,
    ChordQuality.dominantSeventh,
    ChordQuality.diminishedSeventh,
    ChordQuality.halfDiminished,
    ChordQuality.sixth,
    ChordQuality.minorSixth,
  ];

  /// The arpeggios, all Premium-labelled (PRD.md §13).
  static List<TieredEntry<ChordQuality>> get arpeggios =>
      <TieredEntry<ChordQuality>>[
        for (final quality in _arpeggioQualities)
          TieredEntry<ChordQuality>(quality, FeatureTier.premium),
      ];

  /// The root spellings the picker offers.
  ///
  /// The canonical seventeen from `Note.spellings`, the same list the chord
  /// browser shows. Filtered per scale by [rootsFor], because a root a scale
  /// cannot be written on should not be offered on it.
  static const List<Note> roots = Note.spellings;

  /// The roots [type] can actually be written on.
  ///
  /// Almost always all seventeen. A♯ whole tone is the exception the filter
  /// exists for: its ♯6 would need an F triple sharp, so a musician writes
  /// B♭ whole tone, and the picker offers exactly that (see `Scale`).
  static List<Note> rootsFor(ScaleType type) => <Note>[
    for (final root in roots)
      if (Scale(root, type).isSpellable) root,
  ];
}
