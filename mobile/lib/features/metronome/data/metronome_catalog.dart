/// What the metronome offers, and the tier each entry is labelled with.
///
/// This is the data layer, and it is deliberately where [FeatureTier] lives. A
/// beat's position does not change with a subscription, so
/// `metronome/domain/` knows nothing about tiers (CLAUDE.md §10). Even here
/// the label grants nothing — CLAUDE.md §23 and §51 put entitlement on the
/// server, and **every entry in this file plays**.
library;

import 'package:l_key/core/access/feature_tier.dart';
import 'package:l_key/core/access/tiered_entry.dart';
import 'package:l_key/features/metronome/domain/click_sound.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';

/// The choices the metronome screen offers.
abstract final class MetronomeCatalog {
  /// The meters, with their tier labels.
  ///
  /// PRD.md §16 puts 4/4 in the free tier and the rest behind Premium.
  static List<TieredEntry<TimeSignature>> get signatures =>
      <TieredEntry<TimeSignature>>[
        for (final signature in TimeSignature.catalogue)
          TieredEntry<TimeSignature>(
            signature,
            signature == TimeSignature.fourFour
                ? FeatureTier.free
                : FeatureTier.premium,
          ),
      ];

  /// The subdivisions, with their tier labels.
  static List<TieredEntry<Subdivision>> get subdivisions =>
      <TieredEntry<Subdivision>>[
        for (final subdivision in Subdivision.values)
          TieredEntry<Subdivision>(
            subdivision,
            subdivision == Subdivision.none
                ? FeatureTier.free
                : FeatureTier.premium,
          ),
      ];

  /// The click voices, with their tier labels.
  static List<TieredEntry<ClickSound>> get sounds => <TieredEntry<ClickSound>>[
    for (final sound in ClickSound.values)
      TieredEntry<ClickSound>(
        sound,
        sound == ClickSound.woodblock ? FeatureTier.free : FeatureTier.premium,
      ),
  ];

  /// Editing the accent pattern is a Premium capability (PRD.md §16).
  static const FeatureTier accentsTier = FeatureTier.premium;

  /// A custom meter is a Premium capability (PRD.md §16).
  static const FeatureTier customSignatureTier = FeatureTier.premium;
}
