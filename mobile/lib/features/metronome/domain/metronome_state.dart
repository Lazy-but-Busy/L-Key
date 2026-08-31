/// What the metronome screen is showing, and why.
///
/// Contains no Flutter and reads no clock. See docs/adr/0016.
library;

import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/features/metronome/domain/metronome_settings.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';
import 'package:meta/meta.dart';

/// The states the metronome can be in.
enum MetronomeStatus {
  /// Not playing. Nothing holds the speaker.
  idle,

  /// The speaker is opening.
  starting,

  /// Counting in, before the first bar proper.
  countingIn,

  /// Keeping time.
  running,

  /// This device cannot play audio at all.
  unavailable,

  /// Something went wrong.
  failed,
}

/// The numbers behind playback, for the debug view only.
///
/// Never shown to a player. It exists so that docs/DEVICE-TESTING.md Part B
/// produces measurements rather than impressions — the buffer sizes in
/// `AudioOutputConfig` cannot be calibrated against a feeling.
@immutable
final class MetronomeDiagnostics {
  /// Creates a snapshot.
  const MetronomeDiagnostics({
    required this.sampleRate,
    required this.blockFrames,
    required this.targetBufferFrames,
    required this.fedFrames,
    required this.playedFrames,
    required this.dropouts,
    required this.nextClickSample,
  });

  /// The rate playback was opened at.
  final int sampleRate;

  /// How many frames are rendered per feed.
  final int blockFrames;

  /// How full the queue is kept.
  final int targetBufferFrames;

  /// Frames handed to the device since playback began.
  final int fedFrames;

  /// Frames the device says it has played.
  final int playedFrames;

  /// How many times its buffer has run dry.
  final int dropouts;

  /// Where the next click sits, in samples, or null when stopped.
  final int? nextClickSample;

  /// How many frames are queued ahead of the playhead.
  int get bufferedFrames => fedFrames - playedFrames;

  /// How far ahead of the playhead the next click is, in milliseconds.
  double? get nextClickInMs => nextClickSample == null
      ? null
      : (nextClickSample! - playedFrames) * 1000 / sampleRate;
}

/// Everything the metronome screen renders from.
@immutable
final class MetronomeState {
  /// Creates a state.
  const MetronomeState({
    required this.settings,
    this.status = MetronomeStatus.idle,
    this.bar = 0,
    this.beat = 0,
    this.level = AccentLevel.strong,
    this.countInBeatsRemaining = 0,
    this.dropouts = 0,
    this.isStruggling = false,
    this.failure,
    this.diagnostics,
  });

  /// What is being played, whether or not it is playing.
  final MetronomeSettings settings;

  /// What the metronome is doing.
  final MetronomeStatus status;

  /// Which bar is sounding, counted from zero.
  final int bar;

  /// Which beat of the bar is sounding, counted from zero.
  ///
  /// **It follows the audio, not a timer.** The transport advances it from
  /// the frames the device reports it has actually played, so the indicator
  /// can never run ahead of the click (docs/adr/0016).
  final int beat;

  /// How much emphasis the sounding beat carries.
  final AccentLevel level;

  /// How many count-in beats are left, or zero when not counting in.
  final int countInBeatsRemaining;

  /// How many times the device's buffer has run dry.
  ///
  /// A hiccup shifts everything after it later by the length of the gap; it
  /// never changes the tempo, because every click is still placed from the
  /// schedule's own origin. Counted rather than swallowed, because a
  /// metronome that stutters in silence is worse than one that says so
  /// (CLAUDE.md §37).
  final int dropouts;

  /// Whether the device is dropping out often enough to say so on screen.
  final bool isStruggling;

  /// What went wrong, when [status] is [MetronomeStatus.failed].
  final Failure? failure;

  /// The measurements behind playback, when the diagnostics flag is set.
  final MetronomeDiagnostics? diagnostics;

  /// Whether the metronome is sounding, or about to.
  bool get isRunning =>
      status == MetronomeStatus.starting ||
      status == MetronomeStatus.countingIn ||
      status == MetronomeStatus.running;

  /// The tempo, for anything that only needs the number.
  int get bpm => settings.bpm;

  /// Which meter is playing.
  TimeSignature get signature => settings.signature;

  /// [failure] and the counters use sentinels because null is a meaningful
  /// value for each: it means "there is none" rather than "leave it alone",
  /// which is the contract `TunerState.copyWith` already uses.
  MetronomeState copyWith({
    MetronomeSettings? settings,
    MetronomeStatus? status,
    int? bar,
    int? beat,
    AccentLevel? level,
    int? countInBeatsRemaining,
    int? dropouts,
    bool? isStruggling,
    Object? failure = _unset,
    Object? diagnostics = _unset,
  }) => MetronomeState(
    settings: settings ?? this.settings,
    status: status ?? this.status,
    bar: bar ?? this.bar,
    beat: beat ?? this.beat,
    level: level ?? this.level,
    countInBeatsRemaining: countInBeatsRemaining ?? this.countInBeatsRemaining,
    dropouts: dropouts ?? this.dropouts,
    isStruggling: isStruggling ?? this.isStruggling,
    failure: identical(failure, _unset) ? this.failure : failure as Failure?,
    diagnostics: identical(diagnostics, _unset)
        ? this.diagnostics
        : diagnostics as MetronomeDiagnostics?,
  );

  static const Object _unset = Object();

  @override
  String toString() =>
      'MetronomeState(${status.name}, ${settings.bpm} BPM, '
      'bar $bar beat $beat)';
}
