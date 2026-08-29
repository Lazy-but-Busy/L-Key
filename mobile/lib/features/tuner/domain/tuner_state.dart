/// What the tuner screen is showing, and why.
///
/// Contains no Flutter. See docs/adr/0013.
library;

import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/tuner/domain/tuner_reading.dart';
import 'package:l_key/features/tuner/domain/tuning_engine.dart';
import 'package:meta/meta.dart';

/// The states the tuner can be in.
///
/// Flat, sharp and in tune are deliberately **not** here. They are read off
/// [TunerReading.cents] against the tolerance, and having them in two places
/// is how the two come to disagree. PRD.md §10 asks for `IsInTune` as a field,
/// not as a mode.
enum TunerStatus {
  /// Not listening. Nothing holds the microphone.
  idle,

  /// Access was refused, but asking again is allowed.
  permissionRequired,

  /// Access was refused for good, or is not the player's to give.
  permissionBlocked,

  /// The microphone is opening.
  starting,

  /// Listening, and hearing nothing to work with.
  listening,

  /// Hearing something, but too little of a note to name it.
  noisy,

  /// Hearing more than one string at once.
  imperfectInput,

  /// Naming a note.
  tracking,

  /// Something went wrong.
  failed,
}

/// The numbers behind a reading, for the debug view only.
///
/// Never shown to a player. It exists so that docs/DEVICE-TESTING.md produces
/// measurements rather than impressions — the thresholds in
/// `TunerThresholds` cannot be calibrated against a feeling.
@immutable
final class TunerDiagnostics {
  /// Creates a diagnostic snapshot.
  const TunerDiagnostics({
    required this.rmsDbfs,
    required this.clarity,
    required this.confidence,
    required this.spectralFlatness,
    required this.clippedRatio,
    required this.residualRatio,
    required this.residualPartialCount,
    required this.peakCount,
    required this.rawFrequencyHz,
    required this.sampleRate,
    required this.windowSize,
    required this.hopSize,
    required this.framesPerSecond,
  });

  /// Level of the last window.
  final double rmsDbfs;

  /// The detector's raw periodicity.
  final double clarity;

  /// That periodicity gated by level and tonality.
  final double confidence;

  /// How noise-like the window was.
  final double spectralFlatness;

  /// What share of it was clipped.
  final double clippedRatio;

  /// What share of the spectrum one harmonic series left unexplained.
  final double residualRatio;

  /// How many partials the leftovers formed.
  final int residualPartialCount;

  /// How many peaks were resolved.
  final int peakCount;

  /// The unsmoothed frequency, before the median.
  final double? rawFrequencyHz;

  /// The rate the device actually granted.
  final int sampleRate;

  /// The window length in use.
  final int windowSize;

  /// The hop length in use.
  final int hopSize;

  /// How many windows a second are being analysed.
  final double framesPerSecond;
}

/// Everything the tuner screen renders from.
@immutable
final class TunerState {
  /// Creates a tuner state.
  const TunerState({
    this.status = TunerStatus.idle,
    this.tuning = Tuning.standard,
    this.mode = const TargetMode.auto(),
    this.isChromatic = false,
    this.referenceHz = 440,
    this.reading,
    this.failure,
    this.canOpenSettings = false,
    this.diagnostics,
  });

  /// What the screen is doing.
  final TunerStatus status;

  /// The tuning being tuned to.
  final Tuning tuning;

  /// Whether the tuner follows the nearest string or a chosen one.
  final TargetMode mode;

  /// Whether any note counts, rather than only this tuning's strings.
  final bool isChromatic;

  /// What A4 is taken to be.
  final double referenceHz;

  /// The current reading, when there is one.
  final TunerReading? reading;

  /// What went wrong, when something did.
  final Failure? failure;

  /// Whether sending the player to the system settings would help.
  ///
  /// False for a restricted device, where there is nothing there they can
  /// change and offering the button would waste their time.
  final bool canOpenSettings;

  /// Debug measurements, when the diagnostics flag is on.
  final TunerDiagnostics? diagnostics;

  /// Whether the microphone is, or is about to be, live.
  bool get isListening =>
      status == TunerStatus.starting ||
      status == TunerStatus.listening ||
      status == TunerStatus.noisy ||
      status == TunerStatus.imperfectInput ||
      status == TunerStatus.tracking;

  /// Returns a copy with the given fields replaced.
  ///
  /// [reading], [failure] and [diagnostics] use sentinels because null is a
  /// meaningful value for each — it means "there is none" rather than "leave
  /// it alone", which is the same contract `Settings.copyWith` uses.
  TunerState copyWith({
    TunerStatus? status,
    Tuning? tuning,
    TargetMode? mode,
    bool? isChromatic,
    double? referenceHz,
    Object? reading = _unset,
    Object? failure = _unset,
    bool? canOpenSettings,
    Object? diagnostics = _unset,
  }) => TunerState(
    status: status ?? this.status,
    tuning: tuning ?? this.tuning,
    mode: mode ?? this.mode,
    isChromatic: isChromatic ?? this.isChromatic,
    referenceHz: referenceHz ?? this.referenceHz,
    reading: identical(reading, _unset)
        ? this.reading
        : reading as TunerReading?,
    failure: identical(failure, _unset) ? this.failure : failure as Failure?,
    canOpenSettings: canOpenSettings ?? this.canOpenSettings,
    diagnostics: identical(diagnostics, _unset)
        ? this.diagnostics
        : diagnostics as TunerDiagnostics?,
  );

  static const Object _unset = Object();
}
