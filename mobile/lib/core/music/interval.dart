/// Musical intervals, spelled rather than counted.
///
/// An interval is a *number* (second, third, seventh) and a *quality* (minor,
/// major, perfect, diminished, augmented). Both halves matter: an augmented
/// second and a minor third both span three semitones, but adding one to C
/// gives D♯ and the other gives E♭. Chord spelling depends on that difference
/// (CLAUDE.md §10), so this file never reduces an interval to its semitone
/// count alone.
///
/// Contains no Flutter. See docs/adr/0009.
library;

import 'package:meta/meta.dart';

/// The quality half of an interval.
///
/// Perfect applies to unisons, fourths, fifths and octaves; major and minor
/// apply to seconds, thirds, sixths and sevenths. Diminished and augmented
/// apply to both families, one semitone outside the base size.
enum IntervalQuality {
  /// A semitone below minor, or below perfect.
  diminished,

  /// A semitone below major. Seconds, thirds, sixths and sevenths only.
  minor,

  /// The base size for seconds, thirds, sixths and sevenths.
  major,

  /// The base size for unisons, fourths, fifths and octaves.
  perfect,

  /// A semitone above major, or above perfect.
  augmented,
}

/// A spelled interval: a diatonic number plus a quality.
///
/// [number] is one-based and diatonic — 1 is a unison, 3 a third, 9 a ninth.
/// Compound numbers above 8 are supported so a ninth stays a ninth rather than
/// collapsing into a second, which is what the `9`, `maj9` and `m9` chord
/// formulas need.
@immutable
final class Interval implements Comparable<Interval> {
  /// Creates an interval of [number] steps with the given [quality].
  ///
  /// Throws [ArgumentError] if the quality cannot apply to the number — there
  /// is no such thing as a major fifth or a perfect third.
  Interval(this.number, this.quality)
    : assert(number >= 1, 'interval numbers are one-based') {
    if (!_qualityFits(number, quality)) {
      throw ArgumentError.value(
        quality,
        'quality',
        'does not apply to interval number $number',
      );
    }
  }

  /// Perfect unison — the root itself.
  static final Interval unison = Interval(1, IntervalQuality.perfect);

  /// Augmented unison, one semitone. The ♯1 the chromatic scale spells with.
  static final Interval augmentedUnison = Interval(
    1,
    IntervalQuality.augmented,
  );

  /// Minor second, one semitone. The ♭9.
  static final Interval minorSecond = Interval(2, IntervalQuality.minor);

  /// Major second, two semitones. The sus2 tone.
  static final Interval majorSecond = Interval(2, IntervalQuality.major);

  /// Augmented second, three semitones. The ♯2 of the half-whole diminished
  /// scale, spelled as a second because it sits between the ♭2 and the 3.
  static final Interval augmentedSecond = Interval(
    2,
    IntervalQuality.augmented,
  );

  /// Minor third, three semitones.
  static final Interval minorThird = Interval(3, IntervalQuality.minor);

  /// Major third, four semitones.
  static final Interval majorThird = Interval(3, IntervalQuality.major);

  /// Perfect fourth, five semitones. The sus4 tone.
  static final Interval perfectFourth = Interval(4, IntervalQuality.perfect);

  /// Augmented fourth, six semitones. The ♯4 that makes Lydian Lydian.
  ///
  /// Six semitones is also a diminished fifth, and the difference is the whole
  /// point: Lydian's fourth degree is a fourth. F Lydian is F G A B C D E, and
  /// the B is a B — spell it C♭ and the scale has two Cs and no B.
  static final Interval augmentedFourth = Interval(
    4,
    IntervalQuality.augmented,
  );

  /// Diminished fifth, six semitones. The ♭5.
  static final Interval diminishedFifth = Interval(
    5,
    IntervalQuality.diminished,
  );

  /// Perfect fifth, seven semitones.
  static final Interval perfectFifth = Interval(5, IntervalQuality.perfect);

  /// Augmented fifth, eight semitones. The ♯5.
  static final Interval augmentedFifth = Interval(5, IntervalQuality.augmented);

  /// Minor sixth, eight semitones. The ♭6 of every minor-family scale.
  static final Interval minorSixth = Interval(6, IntervalQuality.minor);

  /// Major sixth, nine semitones.
  static final Interval majorSixth = Interval(6, IntervalQuality.major);

  /// Augmented sixth, ten semitones. The ♯6 of the whole-tone scale, which
  /// runs 1 2 3 ♯4 ♯5 ♯6 so that each of its six notes takes its own letter.
  static final Interval augmentedSixth = Interval(6, IntervalQuality.augmented);

  /// Diminished seventh, nine semitones. The ♭♭7 that only dim7 uses.
  static final Interval diminishedSeventh = Interval(
    7,
    IntervalQuality.diminished,
  );

  /// Minor seventh, ten semitones. The ♭7.
  static final Interval minorSeventh = Interval(7, IntervalQuality.minor);

  /// Major seventh, eleven semitones.
  static final Interval majorSeventh = Interval(7, IntervalQuality.major);

  /// Major ninth, fourteen semitones.
  static final Interval majorNinth = Interval(9, IntervalQuality.major);

  /// The diatonic size, one-based. 1 is a unison, 3 a third, 9 a ninth.
  final int number;

  /// Whether the interval is diminished, minor, major, perfect or augmented.
  final IntervalQuality quality;

  /// Semitones spanned by a perfect or major interval of [number].
  static const List<int> _baseSemitones = <int>[0, 2, 4, 5, 7, 9, 11];

  /// Whether [number] belongs to the perfect family (unison, fourth, fifth,
  /// octave) rather than the major/minor family.
  static bool isPerfectNumber(int number) {
    const perfect = <int>{1, 4, 5};
    return perfect.contains(_simpleNumber(number));
  }

  static int _simpleNumber(int number) => (number - 1) % 7 + 1;

  static bool _qualityFits(int number, IntervalQuality quality) {
    final perfectFamily = isPerfectNumber(number);
    return switch (quality) {
      IntervalQuality.perfect => perfectFamily,
      IntervalQuality.major || IntervalQuality.minor => !perfectFamily,
      IntervalQuality.diminished || IntervalQuality.augmented => true,
    };
  }

  /// How many semitones the interval spans.
  ///
  /// Compound intervals add an octave per extra seven — a major ninth is a
  /// major second plus twelve.
  int get semitones {
    final simple = _simpleNumber(number);
    final octaves = (number - simple) ~/ 7;
    final base = _baseSemitones[simple - 1];
    final offset = switch (quality) {
      IntervalQuality.perfect || IntervalQuality.major => 0,
      IntervalQuality.minor => -1,
      IntervalQuality.diminished => isPerfectNumber(number) ? -1 : -2,
      IntervalQuality.augmented => 1,
    };
    return base + offset + octaves * 12;
  }

  /// How many diatonic letter steps the interval moves. A third moves two
  /// letters, a ninth moves eight.
  int get letterSteps => number - 1;

  /// The interval written the way a chord formula writes it: `1`, `b3`, `#5`,
  /// `bb7`, `9`.
  ///
  /// This is the degree notation used by PRD.md §11's formulas and by
  /// DESIGN.md §23's chord detail, not the `m3`/`P5` academic notation.
  String get degree {
    final prefix = switch (quality) {
      IntervalQuality.perfect || IntervalQuality.major => '',
      IntervalQuality.minor => 'b',
      IntervalQuality.augmented => '#',
      IntervalQuality.diminished => isPerfectNumber(number) ? 'b' : 'bb',
    };
    return '$prefix$number';
  }

  /// Parses degree notation such as `1`, `b3`, `#5`, `bb7` or `9`.
  ///
  /// Returns null rather than throwing, because this parses text that may have
  /// come from content or from a player.
  static Interval? tryParseDegree(String input) {
    final text = input.trim();
    if (text.isEmpty) return null;

    var index = 0;
    var alteration = 0;
    while (index < text.length) {
      final c = text[index];
      if (c == 'b' || c == '♭') {
        alteration -= 1;
      } else if (c == '#' || c == '♯') {
        alteration += 1;
      } else {
        break;
      }
      index += 1;
    }

    final number = int.tryParse(text.substring(index));
    if (number == null || number < 1) return null;

    final perfectFamily = isPerfectNumber(number);
    final quality = switch (alteration) {
      0 => perfectFamily ? IntervalQuality.perfect : IntervalQuality.major,
      -1 => perfectFamily ? IntervalQuality.diminished : IntervalQuality.minor,
      -2 => perfectFamily ? null : IntervalQuality.diminished,
      1 => IntervalQuality.augmented,
      _ => null,
    };
    if (quality == null) return null;
    return Interval(number, quality);
  }

  @override
  int compareTo(Interval other) {
    final byNumber = number.compareTo(other.number);
    return byNumber != 0 ? byNumber : semitones.compareTo(other.semitones);
  }

  @override
  bool operator ==(Object other) =>
      other is Interval && other.number == number && other.quality == quality;

  @override
  int get hashCode => Object.hash(number, quality);

  @override
  String toString() => degree;
}
