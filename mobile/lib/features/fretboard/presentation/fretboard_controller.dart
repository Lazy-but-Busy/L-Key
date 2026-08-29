import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/fretboard.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/scale.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/fretboard/data/local_fretboard_repository.dart';
import 'package:l_key/features/fretboard/domain/caged.dart';
import 'package:l_key/features/fretboard/domain/fretboard_repository.dart';
import 'package:l_key/features/fretboard/domain/fretboard_selection.dart';
import 'package:l_key/features/fretboard/domain/scale_pattern.dart';

/// Where the fretboard's options are read from.
///
/// Overridden in tests to supply a failing or empty catalogue, which is the
/// only way the error and empty states can be exercised honestly.
final fretboardRepositoryProvider = Provider<FretboardRepository>(
  (ref) => const LocalFretboardRepository(),
);

/// Every tuning, scale and arpeggio the pickers offer.
final fretboardOptionsProvider = FutureProvider<FretboardOptions>(
  (ref) => ref.watch(fretboardRepositoryProvider).load(),
);

/// What the neck is showing: a scale, one of the modes, an arpeggio, or every
/// note there is.
enum FretboardKind {
  /// The scales — major, minor, the pentatonics and the symmetric ones.
  scale,

  /// The seven modes of the major scale.
  mode,

  /// A chord's tones, one note at a time.
  arpeggio,

  /// Every note on the neck, with no selection at all.
  notes,
}

/// What a marker prints.
enum FretboardLabels {
  /// The note name — `A`, `C♯`.
  notes,

  /// The degree above the root — `1`, `b3`.
  intervals,
}

/// Which region of the neck is in view.
enum FretboardFocusKind {
  /// The whole fret range the player has chosen.
  fullNeck,

  /// One box of the current scale.
  box,

  /// One of the five CAGED shapes.
  caged,
}

/// A chosen region of the neck.
@immutable
final class FretboardFocus {
  /// Creates a focus.
  const FretboardFocus._(this.kind, {this.boxIndex, this.shape});

  /// The whole range.
  const FretboardFocus.fullNeck() : this._(FretboardFocusKind.fullNeck);

  /// The [index]th box of the current scale, one-based.
  const FretboardFocus.box(int index)
    : this._(FretboardFocusKind.box, boxIndex: index);

  /// One CAGED shape.
  const FretboardFocus.caged(CagedShape shape)
    : this._(FretboardFocusKind.caged, shape: shape);

  /// Which kind of region this is.
  final FretboardFocusKind kind;

  /// The box number, when [kind] is a box.
  final int? boxIndex;

  /// The shape, when [kind] is CAGED.
  final CagedShape? shape;

  @override
  bool operator ==(Object other) =>
      other is FretboardFocus &&
      other.kind == kind &&
      other.boxIndex == boxIndex &&
      other.shape == shape;

  @override
  int get hashCode => Object.hash(kind, boxIndex, shape);
}

/// What the player has asked the fretboard to show.
///
/// Intent only. Which notes that produces is derived, never stored, so the
/// two can never disagree (docs/ARCHITECTURE.md).
@immutable
final class FretboardState {
  /// Creates a state.
  const FretboardState({
    this.tuning = Tuning.standard,
    this.root = const Note(NoteLetter.a),
    this.kind = FretboardKind.scale,
    this.scaleType = ScaleType.minorPentatonic,
    this.arpeggio = ChordQuality.minorSeventh,
    this.labels = FretboardLabels.notes,
    this.focus = const FretboardFocus.fullNeck(),
    this.lowestFret = 0,
    this.fretCount = 16,
  });

  /// The tuning the neck sounds in.
  final Tuning tuning;

  /// The note every degree is measured from.
  final Note root;

  /// Whether a scale, a mode, an arpeggio or the note map is shown.
  final FretboardKind kind;

  /// The scale or mode, when one is shown.
  final ScaleType scaleType;

  /// The chord quality, when an arpeggio is shown.
  final ChordQuality arpeggio;

  /// Whether markers print note names or degrees.
  final FretboardLabels labels;

  /// Which region of the neck is in view.
  final FretboardFocus focus;

  /// The lowest fret the player has scrolled to.
  final int lowestFret;

  /// How many frets wide the player's window is.
  final int fretCount;

  /// The player's own fret window, before a box or shape narrows it.
  FretRange get chosenRange =>
      FretRange(lowest: lowestFret, highest: lowestFret + fretCount - 1);

  /// Returns a copy with the given fields replaced.
  FretboardState copyWith({
    Tuning? tuning,
    Note? root,
    FretboardKind? kind,
    ScaleType? scaleType,
    ChordQuality? arpeggio,
    FretboardLabels? labels,
    FretboardFocus? focus,
    int? lowestFret,
    int? fretCount,
  }) => FretboardState(
    tuning: tuning ?? this.tuning,
    root: root ?? this.root,
    kind: kind ?? this.kind,
    scaleType: scaleType ?? this.scaleType,
    arpeggio: arpeggio ?? this.arpeggio,
    labels: labels ?? this.labels,
    focus: focus ?? this.focus,
    lowestFret: lowestFret ?? this.lowestFret,
    fretCount: fretCount ?? this.fretCount,
  );
}

/// Holds the player's intent and nothing else.
class FretboardController extends Notifier<FretboardState> {
  /// The narrowest and widest windows the fret control allows.
  static const int minFrets = 5;

  /// The widest window, and the highest fret the neck draws.
  static const int maxFrets = 24;

  /// The last fret the control will scroll to.
  static const int highestFret = 24;

  @override
  FretboardState build() => const FretboardState();

  /// Changes the tuning. CAGED does not survive it, so the focus resets.
  void selectTuning(Tuning tuning) => state = state.copyWith(
    tuning: tuning,
    focus: const FretboardFocus.fullNeck(),
  );

  /// Changes the root. Boxes move with it, so the focus resets.
  void selectRoot(Note root) => state = state.copyWith(
    root: root,
    focus: const FretboardFocus.fullNeck(),
  );

  /// Switches between scales, modes, arpeggios and the note map.
  void selectKind(FretboardKind kind) {
    final type = switch (kind) {
      FretboardKind.mode =>
        state.scaleType.category == ScaleCategory.mode
            ? state.scaleType
            : ScaleType.dorian,
      FretboardKind.scale =>
        state.scaleType.category == ScaleCategory.mode
            ? ScaleType.minorPentatonic
            : state.scaleType,
      FretboardKind.arpeggio || FretboardKind.notes => state.scaleType,
    };
    state = state.copyWith(
      kind: kind,
      scaleType: type,
      focus: const FretboardFocus.fullNeck(),
    );
  }

  /// Chooses a scale or a mode.
  ///
  /// A root the scale cannot be written on is replaced by one it can — A♯
  /// whole tone becomes B♭ whole tone, which is how it is written anyway.
  void selectScale(ScaleType type) {
    // Respelling the same sound with flats is what fixes it: transposing by
    // zero semitones keeps the pitch and changes only the spelling.
    final respelled = state.root.transposeChromatically(0, preferFlats: true);
    final root = Scale(state.root, type).isSpellable
        ? state.root
        : (Scale(respelled, type).isSpellable
              ? respelled
              : const Note(NoteLetter.c));
    state = state.copyWith(
      scaleType: type,
      root: root,
      // Choosing Dorian means the neck is showing a mode, whichever picker
      // the choice came from — the scales screen has one list, not two.
      kind: type.category == ScaleCategory.mode
          ? FretboardKind.mode
          : FretboardKind.scale,
      focus: const FretboardFocus.fullNeck(),
    );
  }

  /// Chooses an arpeggio.
  void selectArpeggio(ChordQuality quality) => state = state.copyWith(
    arpeggio: quality,
    focus: const FretboardFocus.fullNeck(),
  );

  /// Switches marker labels between note names and degrees.
  void selectLabels(FretboardLabels labels) =>
      state = state.copyWith(labels: labels);

  /// Focuses a region of the neck.
  void focusOn(FretboardFocus focus) => state = state.copyWith(focus: focus);

  /// Widens or narrows the fret window by one fret.
  void resizeBy(int frets) {
    final count = (state.fretCount + frets).clamp(minFrets, maxFrets);
    state = state.copyWith(
      fretCount: count,
      lowestFret: state.lowestFret.clamp(0, highestFret - count + 1),
      focus: const FretboardFocus.fullNeck(),
    );
  }

  /// Slides the fret window up or down the neck.
  void slideBy(int frets) => state = state.copyWith(
    lowestFret: (state.lowestFret + frets).clamp(
      0,
      highestFret - state.fretCount + 1,
    ),
    focus: const FretboardFocus.fullNeck(),
  );
}

/// The player's intent.
final fretboardProvider = NotifierProvider<FretboardController, FretboardState>(
  FretboardController.new,
);

/// Everything a fretboard screen draws, derived from the intent.
@immutable
final class FretboardView {
  /// Creates a view.
  const FretboardView({
    required this.tuning,
    required this.range,
    required this.positions,
    required this.boxes,
    required this.cagedPositions,
    this.scale,
    this.selection,
  });

  /// The tuning being drawn.
  final Tuning tuning;

  /// The frets in view, after a box or shape has narrowed the window.
  final FretRange range;

  /// The markers, ordered by string then fret.
  final List<FretPosition> positions;

  /// The boxes available for the current selection. Empty for the note map,
  /// for an arpeggio and for the chromatic scale.
  final List<ScalePosition> boxes;

  /// The CAGED shapes for the current root. Empty outside standard tuning.
  final List<CagedPosition> cagedPositions;

  /// The scale, when one is selected.
  final Scale? scale;

  /// The selection, when one is made. Null for the note map.
  final FretboardSelection? selection;

  /// Whether the current window has nothing in it.
  bool get isEmpty => positions.isEmpty;
}

/// The neck as it should be drawn.
///
/// Everything here is recomputed from [fretboardProvider]; nothing is cached
/// and nothing is stored twice.
final fretboardViewProvider = Provider<FretboardView>(
  (ref) => _viewFor(ref.watch(fretboardProvider)),
);

/// The neck as the scales screen draws it.
///
/// Always a scale, whatever the fretboard tool was last showing. Without this
/// the scales screen would print a scale's name and formula over an arpeggio's
/// notes if the player had left the fretboard on Arpeggios.
final scaleViewProvider = Provider<FretboardView>((ref) {
  final state = ref.watch(fretboardProvider);
  return _viewFor(
    state.copyWith(
      kind: state.scaleType.category == ScaleCategory.mode
          ? FretboardKind.mode
          : FretboardKind.scale,
    ),
  );
});

FretboardView _viewFor(FretboardState state) {
  final selection = switch (state.kind) {
    FretboardKind.scale ||
    FretboardKind.mode => ScaleSelection(Scale(state.root, state.scaleType)),
    FretboardKind.arpeggio => ArpeggioSelection(state.root, state.arpeggio),
    FretboardKind.notes => null,
  };

  final boxes = selection is ScaleSelection && selection.isSpellable
      ? ScalePatternEngine.boxes(
          tuning: state.tuning,
          root: selection.root,
          intervals: selection.intervals,
          maxFret: FretboardController.highestFret,
        )
      : const <ScalePosition>[];

  final caged = CagedEngine.positionsFor(
    root: state.root,
    tuning: state.tuning,
    maxFret: FretboardController.highestFret,
  );

  final range = _rangeFor(state, boxes: boxes, caged: caged);

  final positions = selection == null
      ? FretboardEngine.allNotes(
          tuning: state.tuning,
          range: range,
          root: state.root,
        )
      : FretboardEngine.positions(
          tuning: state.tuning,
          root: selection.root,
          intervals: selection.intervals,
          range: range,
        );

  return FretboardView(
    tuning: state.tuning,
    range: range,
    positions: positions,
    boxes: boxes,
    cagedPositions: caged,
    scale: selection is ScaleSelection ? selection.scale : null,
    selection: selection,
  );
}

/// The window the focus asks for, falling back to the player's own.
FretRange _rangeFor(
  FretboardState state, {
  required List<ScalePosition> boxes,
  required List<CagedPosition> caged,
}) => switch (state.focus.kind) {
  FretboardFocusKind.fullNeck => state.chosenRange,
  FretboardFocusKind.box =>
    boxes
            .where((b) => b.index == state.focus.boxIndex)
            .map((b) => b.range)
            .firstOrNull ??
        state.chosenRange,
  FretboardFocusKind.caged =>
    caged
            .where((c) => c.shape == state.focus.shape)
            .map((c) => c.range)
            .firstOrNull ??
        state.chosenRange,
};

/// The localised name of one tuning.
///
/// The domain has no access to a localisation file, so this is the bridge —
/// `Tuning.name` is a stable id, never display copy.
String tuningName(AppLocalizations l10n, Tuning tuning) =>
    switch (tuning.name) {
      'drop-d' => l10n.tuningDropD,
      'drop-c' => l10n.tuningDropC,
      'drop-b' => l10n.tuningDropB,
      'half-step-down' => l10n.tuningHalfStepDown,
      'full-step-down' => l10n.tuningFullStepDown,
      'dadgad' => l10n.tuningDadgad,
      'open-g' => l10n.tuningOpenG,
      'open-d' => l10n.tuningOpenD,
      'open-e' => l10n.tuningOpenE,
      'seven-string' => l10n.tuningSevenString,
      'eight-string' => l10n.tuningEightString,
      'bass-four' => l10n.tuningBassFour,
      'bass-five' => l10n.tuningBassFive,
      _ => l10n.tuningStandard,
    };

/// The localised name of one scale.
String scaleName(AppLocalizations l10n, ScaleType type) => switch (type) {
  ScaleType.major => l10n.scaleMajor,
  ScaleType.naturalMinor => l10n.scaleNaturalMinor,
  ScaleType.harmonicMinor => l10n.scaleHarmonicMinor,
  ScaleType.melodicMinor => l10n.scaleMelodicMinor,
  ScaleType.ionian => l10n.scaleIonian,
  ScaleType.dorian => l10n.scaleDorian,
  ScaleType.phrygian => l10n.scalePhrygian,
  ScaleType.lydian => l10n.scaleLydian,
  ScaleType.mixolydian => l10n.scaleMixolydian,
  ScaleType.aeolian => l10n.scaleAeolian,
  ScaleType.locrian => l10n.scaleLocrian,
  ScaleType.majorPentatonic => l10n.scaleMajorPentatonic,
  ScaleType.minorPentatonic => l10n.scaleMinorPentatonic,
  ScaleType.blues => l10n.scaleBlues,
  ScaleType.wholeTone => l10n.scaleWholeTone,
  ScaleType.diminishedWholeHalf => l10n.scaleDiminishedWholeHalf,
  ScaleType.diminishedHalfWhole => l10n.scaleDiminishedHalfWhole,
  ScaleType.chromatic => l10n.scaleChromatic,
};
