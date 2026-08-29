/// Every number the tuner's behaviour turns on, in one place.
///
/// Contains no Flutter. See docs/adr/0013.
library;

import 'package:meta/meta.dart';

/// The constants that decide when the tuner speaks and when it stays quiet.
///
/// Gathered into one object rather than scattered as private constants for
/// two reasons. Changing one after a device session is then a change to one
/// file, and a test can hand the session a deliberately extreme set to prove
/// that a given number is what produces a given behaviour.
///
/// **The level thresholds are estimates until a device says otherwise.**
/// Decibels relative to full scale are not comparable across devices, because
/// input gain is not: the same room reads differently on two phones. The
/// figures below come from typical behaviour — a quiet room around −55 dBFS,
/// a string plucked at arm's length peaking near −15 — and
/// docs/DEVICE-TESTING.md §2 is the procedure that confirms or replaces them.
@immutable
final class TunerThresholds {
  /// Creates a set of thresholds.
  const TunerThresholds({
    this.silenceFloorDbfs = -50,
    this.signalOnsetDbfs = -42,
    this.silenceHoldFrames = 6,
    this.onsetFrames = 2,
    this.enterTrackingConfidence = 0.75,
    this.leaveTrackingConfidence = 0.5,
    this.medianWindow = 5,
    this.settleDuration = const Duration(milliseconds: 600),
    this.settleReleaseCents = 6,
    this.hapticRearmDuration = const Duration(seconds: 2),
    this.targetSwitchGuard = const Duration(milliseconds: 300),
    this.tonalityGateFloor = 0.35,
    this.tonalityGateCeiling = 0.65,
  });

  /// The defaults, which are what ships.
  static const TunerThresholds defaults = TunerThresholds();

  /// Below this the tuner considers the room silent.
  final double silenceFloorDbfs;

  /// Above this it considers something to be playing.
  ///
  /// Eight decibels above the floor. The gap is deliberate: without it a note
  /// decaying through a single threshold flickers between listening and
  /// tracking several times a second.
  final double signalOnsetDbfs;

  /// How many consecutive quiet windows before declaring silence.
  ///
  /// About a seventh of a second, so a note that has stopped ringing is not
  /// mistaken for one that is merely between plucks.
  final int silenceHoldFrames;

  /// How many consecutive loud windows before declaring a signal.
  ///
  /// One loud window is a door closing.
  final int onsetFrames;

  /// The confidence at which the tuner will start naming a note.
  final double enterTrackingConfidence;

  /// The confidence at which it stops.
  ///
  /// Lower than [enterTrackingConfidence] on purpose. A reading hovering at
  /// one threshold would otherwise switch the whole screen on and off.
  final double leaveTrackingConfidence;

  /// How many recent frequencies the median is taken over.
  ///
  /// A median and not a mean: a mean smears a single octave slip across five
  /// frames and visibly moves the needle, while a median of five ignores it
  /// completely. Five frames is about a tenth of a second of lag.
  final int medianWindow;

  /// How long in tune counts as done.
  ///
  /// Long enough that a needle sweeping through centre while a peg turns does
  /// not fire, short enough not to feel dead.
  final Duration settleDuration;

  /// How far out of tune undoes a settled reading.
  ///
  /// Twice the tolerance, so a reading resting exactly on the boundary does
  /// not flicker the lock on and off.
  final double settleReleaseCents;

  /// How long before the tuning-lock haptic may fire again.
  ///
  /// DESIGN.md §40 asks for a haptic on tuner lock and warns against
  /// overusing them. Without this a string wavering across the boundary
  /// buzzes continuously.
  final Duration hapticRearmDuration;

  /// How long a different string must be nearest before the target moves.
  ///
  /// Real on a seven- or eight-string neck, where the low strings are close
  /// enough together that a note between two of them otherwise flaps.
  final Duration targetSwitchGuard;

  /// Below this tonality, the sound contributes nothing to confidence.
  ///
  /// There is deliberately **no level gate beside this one.** Loudness is
  /// evidence about whether anything is happening, which the silence
  /// thresholds already decide; it is not evidence about whether what is
  /// happening is a note. A quietly plucked string is still perfectly
  /// measurable, and a gate that dropped it would be punishing a player for
  /// having a light touch.
  final double tonalityGateFloor;

  /// Above this tonality, it contributes fully.
  final double tonalityGateCeiling;
}
