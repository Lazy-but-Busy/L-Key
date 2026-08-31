/// Every number the metronome's behaviour turns on, in one place.
///
/// Contains no Flutter and reads no clock. See docs/adr/0016.
library;

import 'package:meta/meta.dart';

/// The constants that decide how the metronome feels.
///
/// Gathered into one object rather than scattered as private constants, for
/// the reasons `TunerThresholds` gives: changing one after a device session is
/// then a change to one file, and a test can hand a deliberately extreme set
/// in to prove that a given number is what produces a given behaviour.
///
/// **The dropout figures are estimates until a device says otherwise.** How
/// often a phone's audio buffer runs dry depends on its audio path and on
/// what else is running. docs/DEVICE-TESTING.md is the procedure that
/// confirms or replaces them.
@immutable
final class MetronomeThresholds {
  /// Creates a set of thresholds.
  const MetronomeThresholds({
    this.tapWindow = 5,
    this.tapResetGap = const Duration(milliseconds: 2500),
    this.tapOutlierFactor = 1.5,
    this.dropoutsBeforeWarning = 3,
    this.dropoutWindow = const Duration(seconds: 10),
  });

  /// The defaults, which are what ships.
  static const MetronomeThresholds defaults = MetronomeThresholds();

  /// How many tap intervals the estimate is taken over.
  ///
  /// Five intervals is six taps: long enough to average out the twenty
  /// milliseconds of jitter in a human finger, short enough that a player
  /// deliberately changing tempo is followed within about two seconds.
  final int tapWindow;

  /// How long a gap ends a tapping phrase.
  ///
  /// **Derived, not chosen.** One beat at the slowest tempo the app offers —
  /// 30 BPM — is two seconds, and this is that plus a quarter. A gap longer
  /// than the slowest beat in the product cannot be part of a tempo, so what
  /// follows it is a new phrase rather than an absurdly slow one.
  final Duration tapResetGap;

  /// How far from the median an interval may sit before it is discarded.
  ///
  /// One and a half catches both hands' worth of mistake: a double tap lands
  /// near half the median and a missed tap near twice it, while ordinary
  /// unevenness of a few per cent passes untouched.
  final double tapOutlierFactor;

  /// How many drained buffers inside [dropoutWindow] before the screen says so.
  ///
  /// One is a notification arriving. Several in ten seconds is a device that
  /// cannot keep time, and a metronome that stutters in silence is worse than
  /// one that admits it (CLAUDE.md §37, §47).
  final int dropoutsBeforeWarning;

  /// The window [dropoutsBeforeWarning] is counted over.
  final Duration dropoutWindow;
}
