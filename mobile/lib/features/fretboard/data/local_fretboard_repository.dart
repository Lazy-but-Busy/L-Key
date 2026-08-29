/// The offline fretboard catalogue.
///
/// Everything the fretboard needs is arithmetic over const tables, so this
/// never touches the network — PRD.md §42 and CLAUDE.md §19 put the fretboard
/// and scales in the offline set.
library;

import 'package:l_key/features/fretboard/data/fretboard_catalog.dart';
import 'package:l_key/features/fretboard/domain/fretboard_repository.dart';

/// Serves the built-in catalogue.
final class LocalFretboardRepository implements FretboardRepository {
  /// Creates the repository.
  const LocalFretboardRepository();

  @override
  Future<FretboardOptions> load() async => FretboardOptions(
    tunings: FretboardCatalog.tunings,
    scales: FretboardCatalog.scales,
    arpeggios: FretboardCatalog.arpeggios,
  );
}
