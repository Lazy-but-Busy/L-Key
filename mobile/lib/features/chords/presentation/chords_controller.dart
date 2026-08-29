import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/features/chords/data/chord_catalog.dart';
import 'package:l_key/features/chords/data/local_chord_repository.dart';
import 'package:l_key/features/chords/domain/chord_audio.dart';
import 'package:l_key/features/chords/domain/chord_repository.dart';
import 'package:l_key/features/chords/domain/chord_search.dart';

/// Where chords are read from.
///
/// Overridden in tests to supply a failing or empty library, which is the only
/// way the error and empty states can be exercised honestly.
final chordRepositoryProvider = Provider<ChordRepository>(
  (ref) => const LocalChordRepository(),
);

/// The chord audio engine.
///
/// Defaults to the one that admits it cannot play. When a real engine exists
/// it is overridden here and no screen changes (CLAUDE.md §47).
final chordAudioPlayerProvider = Provider<ChordAudioPlayer>(
  (ref) => const UnavailableChordAudioPlayer(),
);

/// How the browser narrows the library by chord shape.
enum ChordFilter {
  /// Everything.
  all,

  /// Three-note chords.
  triads,

  /// Four-note chords built on a seventh or a sixth.
  sevenths,

  /// Ninths and added-note chords.
  extended,
}

/// What the chord browser is currently showing.
@immutable
class ChordBrowserState {
  /// Creates a browser state.
  const ChordBrowserState({this.query = '', this.filter = ChordFilter.all});

  /// The player's search text.
  final String query;

  /// The active shape filter.
  final ChordFilter filter;

  /// Returns a copy with the given fields replaced.
  ChordBrowserState copyWith({String? query, ChordFilter? filter}) =>
      ChordBrowserState(
        query: query ?? this.query,
        filter: filter ?? this.filter,
      );
}

/// Holds the browser's query and filter.
///
/// Only the player's *intent* lives here. Which chords match is derived, not
/// stored, so the two can never disagree (docs/ARCHITECTURE.md).
class ChordBrowserController extends Notifier<ChordBrowserState> {
  @override
  ChordBrowserState build() => const ChordBrowserState();

  /// Sets the search text.
  void search(String query) => state = state.copyWith(query: query);

  /// Sets the shape filter.
  void filterBy(ChordFilter filter) => state = state.copyWith(filter: filter);
}

/// The chord browser's query and filter.
///
/// Auto-disposing, so the state lives exactly as long as the screen that owns
/// it. A root-scoped provider outlived every mount of `ChordsPage`, and the
/// page's `TextEditingController` did not — which is how an empty search box
/// came to sit above a filtered list. See docs/adr/0014.
final chordBrowserProvider =
    NotifierProvider<ChordBrowserController, ChordBrowserState>(
      ChordBrowserController.new,
      isAutoDispose: true,
    );

/// Every chord in the library.
final chordLibraryProvider = FutureProvider<List<ChordCatalogEntry>>(
  (ref) => ref.watch(chordRepositoryProvider).browse(),
);

/// One chord and its shapes, or null when the id names nothing.
// The family builder's own type is not nameable from flutter_riverpod's
// public surface, so the annotation the lint wants cannot be written.
// ignore: specify_nonobvious_property_types
final chordDetailProvider = FutureProvider.family<ChordDetail?, String>(
  (ref, id) => ref.watch(chordRepositoryProvider).detail(id),
);

/// Applies the filter and the search to the library.
///
/// Localised quality names are read here, in the presentation layer, and
/// handed to the Flutter-free search (CLAUDE.md §10, §32) so a Burmese query
/// finds an English-named chord.
List<ChordCatalogEntry> filterChords({
  required List<ChordCatalogEntry> entries,
  required ChordBrowserState state,
  required AppLocalizations l10n,
}) {
  final byShape = entries.where((entry) {
    final count = entry.chord.quality.intervals.length;
    return switch (state.filter) {
      ChordFilter.all => true,
      ChordFilter.triads => count == 3,
      ChordFilter.sevenths => count == 4,
      ChordFilter.extended => count >= 5,
    };
  });

  return ChordSearch.rank<ChordCatalogEntry>(
    byShape,
    state.query,
    chordOf: (entry) => entry.chord,
    qualityNames: qualityNames(l10n),
  );
}

/// The localised name of every chord quality.
///
/// The domain has no access to a localisation file, so this is the bridge.
Map<ChordQuality, List<String>> qualityNames(AppLocalizations l10n) =>
    <ChordQuality, List<String>>{
      for (final quality in ChordQuality.values)
        quality: <String>[qualityName(l10n, quality), quality.symbol],
    };

/// The localised name of one chord quality.
String qualityName(AppLocalizations l10n, ChordQuality quality) =>
    switch (quality) {
      ChordQuality.major => l10n.chordQualityMajor,
      ChordQuality.minor => l10n.chordQualityMinor,
      ChordQuality.dominantSeventh => l10n.chordQualityDominantSeventh,
      ChordQuality.majorSeventh => l10n.chordQualityMajorSeventh,
      ChordQuality.minorSeventh => l10n.chordQualityMinorSeventh,
      ChordQuality.sixth => l10n.chordQualitySixth,
      ChordQuality.ninth => l10n.chordQualityNinth,
      ChordQuality.majorNinth => l10n.chordQualityMajorNinth,
      ChordQuality.minorNinth => l10n.chordQualityMinorNinth,
      ChordQuality.suspendedSecond => l10n.chordQualitySuspendedSecond,
      ChordQuality.suspendedFourth => l10n.chordQualitySuspendedFourth,
      ChordQuality.addedNinth => l10n.chordQualityAddedNinth,
      ChordQuality.diminished => l10n.chordQualityDiminished,
      ChordQuality.augmented => l10n.chordQualityAugmented,
      ChordQuality.diminishedSeventh => l10n.chordQualityDiminishedSeventh,
      ChordQuality.halfDiminished => l10n.chordQualityHalfDiminished,
      ChordQuality.minorSixth => l10n.chordQualityMinorSixth,
      ChordQuality.seventhSuspendedFourth =>
        l10n.chordQualitySeventhSuspendedFourth,
    };
