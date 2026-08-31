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
  );

  static const Object _unset = Object();

  @override
  String toString() =>
      'MetronomeState(${status.name}, ${settings.bpm} BPM, '
      'bar $bar beat $beat)';
}
