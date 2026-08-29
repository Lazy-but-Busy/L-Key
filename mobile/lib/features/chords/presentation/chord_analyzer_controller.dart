import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/chords/domain/chord_analyzer.dart';
import 'package:l_key/features/chords/domain/chord_voicing.dart';

/// The shape the player has built, and the tuning it is built in.
///
/// Only the shape lives here. What it is *called* is derived by
/// [chordAnalysisProvider], never stored, so the diagram and its name cannot
/// disagree (docs/ARCHITECTURE.md).
@immutable
final class ChordAnalyzerState {
  /// Creates a state.
  const ChordAnalyzerState({required this.tuning, required this.strings});

  /// A neck with every string muted, which is where the screen opens and
  /// where `Clear` returns it.
  ChordAnalyzerState.silent(this.tuning)
    : strings = List<FrettedString>.unmodifiable(<FrettedString>[
        for (var index = 0; index < tuning.stringCount; index++)
          FrettedString.muted(index),
      ]);

  /// The tuning the strings sound in.
  final Tuning tuning;

  /// One entry per string, lowest-sounding first.
  final List<FrettedString> strings;

  /// The shape, in the type the rest of the chord feature already speaks.
  ChordVoicing get voicing => ChordVoicing(strings: strings);

  /// Whether anything at all is sounding.
  bool get isSilent => strings.every((string) => !string.sounds);

  /// The fret this string is stopped at, 0 when open, null when muted.
  int? frettedAt(int stringIndex) => strings[stringIndex].soundingFret;

  /// Returns a copy with one string replaced.
  ChordAnalyzerState withString(FrettedString string) => ChordAnalyzerState(
    tuning: tuning,
    strings: List<FrettedString>.unmodifiable(<FrettedString>[
      for (final existing in strings)
        if (existing.stringIndex == string.stringIndex) string else existing,
    ]),
  );
}

/// Holds the shape the player is building.
class ChordAnalyzerController extends Notifier<ChordAnalyzerState> {
  @override
  ChordAnalyzerState build() => ChordAnalyzerState.silent(Tuning.standard);

  /// Stops [stringIndex] at [fret], or mutes it when it is already there.
  ///
  /// Tapping a marker a second time is how a string is taken back out of the
  /// shape without reaching for a separate control, which matters on a neck
  /// where the markers are the largest targets on screen.
  void selectFret(int stringIndex, int fret) {
    if (state.frettedAt(stringIndex) == fret) {
      mute(stringIndex);
      return;
    }
    state = state.withString(
      fret == 0
          ? FrettedString.open(stringIndex)
          : FrettedString.at(stringIndex, fret),
    );
  }

  /// Takes [stringIndex] out of the shape.
  void mute(int stringIndex) =>
      state = state.withString(FrettedString.muted(stringIndex));

  /// Mutes [stringIndex], or brings a muted string back open.
  ///
  /// The gutter control has to do something in both directions: a muted
  /// string has no marker left to tap, so a button that only ever muted
  /// would be dead half the time.
  void toggleString(int stringIndex) {
    if (state.strings[stringIndex].sounds) {
      mute(stringIndex);
      return;
    }
    state = state.withString(FrettedString.open(stringIndex));
  }

  /// Returns every string to muted.
  void clear() => state = ChordAnalyzerState.silent(state.tuning);

  /// Switches tuning, and empties the shape with it.
  ///
  /// A seven-string neck has a string the shape does not have an entry for,
  /// and carrying frets across a retune would silently rename the chord
  /// under the player's hands.
  void selectTuning(Tuning tuning) => state = ChordAnalyzerState.silent(tuning);
}

/// The shape being analysed.
final chordAnalyzerProvider =
    NotifierProvider<ChordAnalyzerController, ChordAnalyzerState>(
      ChordAnalyzerController.new,
      isAutoDispose: true,
    );

/// What that shape turns out to be.
///
/// Auto-disposing like the shape it derives from: a long-lived provider
/// watching a short-lived one would keep the short-lived one alive and the
/// screen would reopen on the last player's chord.
final chordAnalysisProvider = Provider<ChordAnalysis>((ref) {
  final state = ref.watch(chordAnalyzerProvider);
  return ChordAnalyzer.analyze(state.voicing, tuning: state.tuning);
}, isAutoDispose: true);
