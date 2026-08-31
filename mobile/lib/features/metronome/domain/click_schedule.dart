/// Where every click lands, in samples.
///
/// Contains no Flutter and reads no clock. See docs/adr/0016.
library;

import 'package:l_key/features/metronome/domain/metronome_settings.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';
import 'package:meta/meta.dart';

/// One click, placed.
@immutable
final class ScheduledClick {
  /// Creates a placed click.
  const ScheduledClick({
    required this.sample,
    required this.pulse,
    required this.bar,
    required this.beat,
    required this.level,
    required this.isCountIn,
  });

  /// Where it sounds, counted in samples from the start of playback.
  final int sample;

  /// Which pulse it is, counted from the first pulse of bar one.
  ///
  /// Negative during a count-in, which is what makes the count-in part of the
  /// same timeline rather than a separate one to join up afterwards.
  final int pulse;

  /// Which bar it falls in, counted from zero. Negative during a count-in.
  final int bar;

  /// Which beat of its bar it falls on, counted from zero.
  final int beat;

  /// How much emphasis it carries.
  final AccentLevel level;

  /// Whether it belongs to the count-in rather than to the music.
  final bool isCountIn;

  @override
  String toString() =>
      'ScheduledClick(sample $sample, pulse $pulse, ${level.name})';
}

/// Turns a tempo into sample positions.
///
/// **The nth pulse is computed from n, never added to the last one.** That is
/// the whole reason a metronome built this way does not drift:
///
/// ```text
/// sample(n) = origin + (n * 60 * rate + d ~/ 2) ~/ d,  d = bpm * pulsesPerBeat
/// ```
///
/// At 240 BPM in sixteenths at 44.1 kHz a pulse is 2756.25 samples. Rounding
/// that period to 2756 and accumulating loses a quarter of a sample every
/// pulse — 54 milliseconds over ten minutes, which is audibly behind a drummer
/// by the end of a song. Computing the nth offset from the origin is wrong by
/// at most half a sample, forever, and it is self-correcting *within* a beat:
/// at 120 BPM the sixteenths land on 0, 5513, 11025, 16538 and the beat itself
/// on exactly 22050.
///
/// All of it is integer arithmetic, so no platform's floating point can move
/// a beat.
@immutable
final class ClickSchedule {
  /// Creates a schedule anchored at [originSample].
  const ClickSchedule({
    required this.settings,
    required this.sampleRate,
    this.originSample = 0,
    this.originPulse = 0,
    this.barOriginPulse = 0,
  });

  /// What is being played.
  final MetronomeSettings settings;

  /// The rate the sample positions are in.
  final int sampleRate;

  /// The sample the [originPulse] pulse falls on.
  final int originSample;

  /// The pulse number [originSample] corresponds to.
  ///
  /// A schedule re-anchors here rather than restarting from zero, so a tempo
  /// change keeps the beat it was on instead of jumping to a downbeat.
  final int originPulse;

  /// The pulse that begins a bar.
  ///
  /// Separate from [originPulse] because the two answer different questions.
  /// [originPulse] is where the *timing* is anchored, and a tempo change
  /// re-anchors it wherever the player happened to press — mid-bar, usually.
  /// This is where the *counting* is anchored, and it only moves when the
  /// meter does. Conflating them would make every tempo nudge restart the bar
  /// and put a downbeat on beat three.
  final int barOriginPulse;

  /// The first pulse of the timeline, which is negative when counting in.
  int get firstPulse =>
      barOriginPulse - settings.countIn.bars * settings.pulsesPerBar;

  /// How many pulses the count-in occupies.
  int get countInPulses => settings.countIn.bars * settings.pulsesPerBar;

  /// Where pulse [n] sounds, in samples.
  ///
  /// Defined for negative [n] as well, which is what puts the count-in on the
  /// same timeline as the music.
  int sampleOf(int n) {
    final denominator = settings.bpm * settings.subdivision.pulsesPerBeat;
    final offset = n - originPulse;
    final numerator = offset * 60 * sampleRate;
    // Round half up, and away from zero on the negative side, so a count-in
    // pulse is placed by the same rule as a musical one.
    final rounded = numerator >= 0
        ? (numerator + denominator ~/ 2) ~/ denominator
        : -((-numerator + denominator ~/ 2) ~/ denominator);
    return originSample + rounded;
  }

  /// The first pulse at or after [sample].
  ///
  /// The inverse of [sampleOf], and used to find where a block of audio
  /// starts in musical terms without walking every pulse before it.
  int firstPulseAtOrAfter(int sample) {
    final denominator = settings.bpm * settings.subdivision.pulsesPerBeat;
    final numerator = (sample - originSample) * denominator;
    final period = 60 * sampleRate;
    // Ceiling division, correct for negatives too.
    var pulse = originPulse + _ceilDiv(numerator, period);
    // Rounding means the closed form can land one either side; step back to
    // the true first pulse rather than trusting the estimate.
    while (pulse > firstPulse && sampleOf(pulse - 1) >= sample) {
      pulse--;
    }
    while (sampleOf(pulse) < sample) {
      pulse++;
    }
    return pulse < firstPulse ? firstPulse : pulse;
  }

  /// Every click sounding in `[fromSample, toSample)`.
  ///
  /// Half-open, so consecutive blocks tile the timeline exactly and no click
  /// is emitted twice or skipped.
  List<ScheduledClick> clicksIn(int fromSample, int toSample) {
    if (toSample <= fromSample) return const <ScheduledClick>[];

    final clicks = <ScheduledClick>[];
    var pulse = firstPulseAtOrAfter(fromSample);
    while (true) {
      final sample = sampleOf(pulse);
      if (sample >= toSample) break;
      if (sample >= fromSample) clicks.add(clickAt(pulse));
      pulse++;
    }
    return clicks;
  }

  /// What pulse [n] is, musically.
  ScheduledClick clickAt(int n) {
    final perBar = settings.pulsesPerBar;
    final offset = n - barOriginPulse;
    // Floor division, so a negative count-in pulse lands in bar -1 rather
    // than rounding toward zero into bar 0.
    final bar = _floorDiv(offset, perBar);
    final within = offset - bar * perBar;
    final level = settings.accentAt(within);
    final isCountIn = n < 0;

    return ScheduledClick(
      sample: sampleOf(n),
      pulse: n,
      bar: bar,
      beat: within ~/ settings.subdivision.pulsesPerBeat,
      // A count-in is a plain count: every pulse the same but the bar's
      // first, so it reads as preparation rather than as music.
      level: isCountIn
          ? (within == 0 ? AccentLevel.strong : AccentLevel.normal)
          : level,
      isCountIn: isCountIn,
    );
  }

  /// A copy re-anchored so that [pulse] falls on the sample it already does.
  ///
  /// This is how a tempo change avoids both a gap and a jump: the boundary
  /// pulse keeps its position, and everything after it is spaced by the new
  /// tempo. One rounding of half a sample is paid per change, and nothing
  /// accumulates across them.
  /// The bar is restarted at [pulse] when the meter changed, because the
  /// pulses no longer divide into bars the same way; a tempo change leaves the
  /// counting exactly where it was.
  ClickSchedule rebasedAt(int pulse, MetronomeSettings next) {
    final metreChanged =
        next.signature != settings.signature ||
        next.subdivision != settings.subdivision;
    return ClickSchedule(
      settings: next,
      sampleRate: sampleRate,
      originSample: sampleOf(pulse),
      originPulse: pulse,
      barOriginPulse: metreChanged ? pulse : barOriginPulse,
    );
  }

  static int _floorDiv(int a, int b) {
    final quotient = a ~/ b;
    return (a % b != 0 && (a < 0) != (b < 0)) ? quotient - 1 : quotient;
  }

  static int _ceilDiv(int a, int b) {
    final quotient = a ~/ b;
    return (a % b != 0 && (a < 0) == (b < 0)) ? quotient + 1 : quotient;
  }
}
