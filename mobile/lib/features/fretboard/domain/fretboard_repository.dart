/// Where the fretboard's options come from.
///
/// Const tables today, an admin-managed catalogue tomorrow — PRD.md §52 puts
/// scales under the CMS. The interface is asynchronous even though the only
/// implementation is synchronous, so the screen models loading, success, empty
/// and error honestly from the start (docs/ARCHITECTURE.md) and swapping the
/// source later touches no widget.
///
/// Contains no Flutter.
library;

import 'package:l_key/core/access/tiered_entry.dart';
import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/scale.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:meta/meta.dart';

/// Everything the fretboard's pickers offer.
@immutable
final class FretboardOptions {
  /// Creates the option set.
  const FretboardOptions({
    required this.tunings,
    required this.scales,
    required this.arpeggios,
  });

  /// The tunings on offer, standard first.
  final List<TieredEntry<Tuning>> tunings;

  /// The scales and modes on offer.
  final List<TieredEntry<ScaleType>> scales;

  /// The chord qualities offered as arpeggios.
  final List<TieredEntry<ChordQuality>> arpeggios;

  /// Whether there is nothing to show. Drives the empty state.
  bool get isEmpty => tunings.isEmpty || scales.isEmpty;
}

/// Reads the fretboard's options.
///
// A one-method interface is exactly what this seam is for: it is the place a
// CMS-backed source replaces the const tables, and a top-level function
// cannot be overridden in a provider or faked in a test.
// ignore: one_member_abstracts
abstract interface class FretboardRepository {
  /// Every tuning, scale and arpeggio the interface offers.
  Future<FretboardOptions> load();
}
