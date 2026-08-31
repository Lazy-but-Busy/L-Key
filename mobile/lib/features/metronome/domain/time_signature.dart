/// Meters, subdivisions and where the emphasis falls.
///
/// Contains no Flutter and reads no clock. See docs/adr/0016.
library;

import 'package:meta/meta.dart';

/// How much emphasis one pulse carries.
///
/// Five levels and four voices: [silent] sounds nothing. It is in the model
/// from the start because the renderer needs a no-voice case anyway, and
/// because a strumming pattern is exactly a per-pulse list of these — which is
/// what will make PRD.md §18 cheap rather than a rewrite.
enum AccentLevel {
  /// The first beat of a bar.
  strong,

  /// The head of a group inside a bar, as the 4 of 7/8's 2+2+3.
  accent,

  /// An ordinary beat.
  normal,

  /// A pulse between beats, when a subdivision is sounding.
  subdivision,

  /// A beat the player has deliberately muted.
  silent,
}

/// How many pulses each beat is divided into.
enum Subdivision {
  /// One pulse per beat.
  none(1),

  /// Two — eighths against a quarter-note beat.
  duple(2),

  /// Three — triplets.
  triple(3),

  /// Four — sixteenths against a quarter-note beat.
  quadruple(4);

  const Subdivision(this.pulsesPerBeat);

  /// How many pulses one beat becomes.
  final int pulsesPerBeat;
}

/// How many bars are counted before the first bar proper.
enum CountIn {
  /// Start immediately.
  none(0),

  /// One bar.
  oneBar(1),

  /// Two bars.
  twoBars(2);

  const CountIn(this.bars);

  /// How many bars are counted in.
  final int bars;
}

/// A time signature, and the emphasis that comes with it by default.
///
/// **The tempo counts the note value in the denominator.** In 4/4 that is the
/// quarter, in 6/8 the eighth: set 120 and hear 120 clicks a minute, whatever
/// the meter. The alternative — counting 6/8 in dotted quarters, so 120 gives
/// two clicks a bar — is how a conductor reads it and is what several
/// metronomes do, and it is defensible. This one is chosen because "the number
/// on the screen is the number of clicks you hear" holds for every meter with
/// no exceptions to learn, and because the grouping is not lost: it is carried
/// by [defaultAccents] instead, which is where a listener actually hears it.
/// docs/adr/0016 records the choice.
@immutable
final class TimeSignature {
  /// Creates a signature.
  ///
  /// Throws [ArgumentError] for a meter no notation uses.
  factory TimeSignature(int beats, int unit) {
    if (beats < minimumBeats || beats > maximumBeats) {
      throw ArgumentError.value(
        beats,
        'beats',
        'must be between $minimumBeats and $maximumBeats',
      );
    }
    if (!allowedUnits.contains(unit)) {
      throw ArgumentError.value(unit, 'unit', 'must be one of $allowedUnits');
    }
    return TimeSignature._(beats, unit);
  }

  const TimeSignature._(this.beats, this.unit);

  /// Creates a signature, or null when the meter is one no notation uses.
  ///
  /// For values arriving from outside the app — a preferences file, a stored
  /// exercise — where being wrong is expected and throwing would be the wrong
  /// answer.
  static TimeSignature? tryOf(int beats, int unit) =>
      beats < minimumBeats ||
          beats > maximumBeats ||
          !allowedUnits.contains(unit)
      ? null
      : TimeSignature._(beats, unit);

  /// The fewest beats a bar may have.
  static const int minimumBeats = 1;

  /// The most beats a bar may have.
  ///
  /// Sixteen covers every meter in common practice and keeps the beat
  /// indicator to a width a phone can draw.
  static const int maximumBeats = 16;

  /// The note values a bar may be counted in: half, quarter, eighth.
  static const Set<int> allowedUnits = <int>{2, 4, 8};

  /// Four beats to the bar, counted in quarters.
  static const TimeSignature fourFour = TimeSignature._(4, 4);

  /// Three beats to the bar, counted in quarters.
  static const TimeSignature threeFour = TimeSignature._(3, 4);

  /// Two beats to the bar, counted in quarters.
  static const TimeSignature twoFour = TimeSignature._(2, 4);

  /// Five beats to the bar, grouped three then two.
  static const TimeSignature fiveFour = TimeSignature._(5, 4);

  /// Six beats to the bar, counted in eighths, grouped in threes.
  static const TimeSignature sixEight = TimeSignature._(6, 8);

  /// Seven beats to the bar, grouped two, two, three.
  static const TimeSignature sevenEight = TimeSignature._(7, 8);

  /// Nine beats to the bar, counted in eighths, grouped in threes.
  static const TimeSignature nineEight = TimeSignature._(9, 8);

  /// Twelve beats to the bar, counted in eighths, grouped in threes.
  static const TimeSignature twelveEight = TimeSignature._(12, 8);

  /// The signatures the picker offers, in the order it offers them.
  static const List<TimeSignature> catalogue = <TimeSignature>[
    fourFour,
    threeFour,
    twoFour,
    sixEight,
    fiveFour,
    sevenEight,
    nineEight,
    twelveEight,
  ];

  /// How many beats are in one bar.
  final int beats;

  /// The note value one beat is worth: 2 a half, 4 a quarter, 8 an eighth.
  final int unit;

  /// How this signature is written.
  String get label => '$beats/$unit';

  /// Where the emphasis falls when the player has not said otherwise.
  ///
  /// Bar one is always [AccentLevel.strong]. Meters that are heard in groups
  /// rather than in even beats — the threes of 6/8, the 3+2 of 5/4, the 2+2+3
  /// of 7/8 — mark each group's head [AccentLevel.accent], because a metronome
  /// that clicks seven even beats in 7/8 is not counting 7/8, it is counting
  /// to seven.
  List<AccentLevel> get defaultAccents {
    final heads = _groupHeads;
    return <AccentLevel>[
      for (var beat = 0; beat < beats; beat++)
        if (beat == 0)
          AccentLevel.strong
        else if (heads.contains(beat))
          AccentLevel.accent
        else
          AccentLevel.normal,
    ];
  }

  /// The beat index that starts each group after the first.
  Set<int> get _groupHeads {
    final grouping = _grouping;
    if (grouping == null) return const <int>{};
    final heads = <int>{};
    var at = 0;
    for (final size in grouping) {
      at += size;
      if (at < beats) heads.add(at);
    }
    return heads;
  }

  /// How the bar divides, or null when it divides evenly into single beats.
  List<int>? get _grouping {
    // Compound meters are felt in threes.
    if (unit == 8 && beats > 3 && beats % 3 == 0) {
      return List<int>.filled(beats ~/ 3, 3);
    }
    return switch ((beats, unit)) {
      (5, _) => const <int>[3, 2],
      (7, 8) => const <int>[2, 2, 3],
      (7, _) => const <int>[4, 3],
      _ => null,
    };
  }

  /// How many pulses one bar holds under [subdivision].
  int pulsesPerBar(Subdivision subdivision) =>
      beats * subdivision.pulsesPerBeat;

  @override
  bool operator ==(Object other) =>
      other is TimeSignature && other.beats == beats && other.unit == unit;

  @override
  int get hashCode => Object.hash(beats, unit);

  @override
  String toString() => 'TimeSignature($label)';
}
