/// What the tuner offers, and the tier each entry is labelled with.
///
/// This is the data layer, and it is deliberately where [FeatureTier] lives.
/// A string's frequency does not change with a subscription, so `core/music/`
/// and `tuner/domain/` know nothing about tiers (CLAUDE.md §10). Even here the
/// label grants nothing — CLAUDE.md §23 and §51 put entitlement on the server,
/// and every entry in this file opens.
library;

import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/core/access/tiered_entry.dart';
import 'package:l_key/core/music/tuning.dart';

/// The tunings the tuner offers, standard first.
abstract final class TunerCatalog {
  /// The tunings, labelled by tier.
  ///
  /// PRD.md §10.1 gives standard tuning to everyone and §10.2 puts the rest
  /// behind Premium. PRD.md §44 is equally clear that the basic tuner is not
  /// to be paywalled, and it is not: this is a badge on a row, and every row
  /// selects.
  static List<TieredEntry<Tuning>> get tunings => <TieredEntry<Tuning>>[
    for (final tuning in Tuning.catalogue)
      TieredEntry<Tuning>(
        tuning,
        tuning == Tuning.standard ? FeatureTier.free : FeatureTier.premium,
      ),
  ];

  /// Chromatic tuning, which belongs to no tuning at all.
  ///
  /// Listed by PRD.md §10.2 as Premium. It has no strings, so it is not a
  /// [Tuning] and cannot sit in the list above.
  static const FeatureTier chromaticTier = FeatureTier.premium;
}
