/// Something the interface offers, and the tier it is labelled with.
///
/// Contains no Flutter.
library;

import 'package:l_key/core/access/feature_tier.dart';
import 'package:meta/meta.dart';

/// A catalogue entry: something a picker offers, and its tier label.
///
/// Lives in `core/access/` beside [FeatureTier] rather than in a feature's
/// data layer, because the fretboard, the scales screen and the tuner all
/// offer the same fourteen tunings and one of them would otherwise have to
/// import another's catalogue. This is the move docs/adr/0011 made for
/// `ChordQuality`, for the same reason.
///
/// **The tier authorizes nothing.** CLAUDE.md §23 and §51 put entitlement on
/// the server; this is a label the interface can show and no more.
@immutable
final class TieredEntry<T> {
  /// Creates an entry.
  const TieredEntry(this.value, this.tier);

  /// The thing on offer.
  final T value;

  /// The tier it is *labelled* with. It authorizes nothing.
  final FeatureTier tier;
}
