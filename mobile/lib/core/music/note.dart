/// Spelled note names: a letter plus an accidental.
///
/// A note is not a number. C♯ and D♭ sound the same and are never equal here,
/// because chord spelling depends on the letter: C♯ major is C♯ E♯ G♯ and D♭
/// major is D♭ F A♭. Reducing either to "pitch class 1" loses the information
/// that makes a chord readable (CLAUDE.md §10).
///
/// Contains no Flutter. See docs/adr/0009.
library;

import 'package:l_key/core/music/interval.dart';
import 'package:meta/meta.dart';

/// The seven natural letters, in diatonic order from C.
enum NoteLetter {
  /// C — diatonic step 0, pitch class 0.
  c('C', 0, 0),

  /// D — diatonic step 1, pitch class 2.
  d('D', 1, 2),

  /// E — diatonic step 2, pitch class 4.
  e('E', 2, 4),

  /// F — diatonic step 3, pitch class 5.
  f('F', 3, 5),

  /// G — diatonic step 4, pitch class 7.
  g('G', 4, 7),

  /// A — diatonic step 5, pitch class 9.
  a('A', 5, 9),

  /// B — diatonic step 6, pitch class 11.
  b('B', 6, 11);

  const NoteLetter(this.symbol, this.step, this.naturalPitchClass);

  /// The uppercase letter.
  final String symbol;

  /// Position in the diatonic cycle, 0 for C through 6 for B.
  final int step;

  /// Pitch class of the unaltered letter, 0–11 with C at 0.
  final int naturalPitchClass;

  /// The letter [steps] diatonic steps above this one, wrapping past B.
  NoteLetter transposeSteps(int steps) => NoteLetter.values[(step + steps) % 7];

  /// The letter written [symbol], or null if it is not one of the seven.
  static NoteLetter? tryParse(String symbol) {
    final upper = symbol.toUpperCase();
    for (final letter in NoteLetter.values) {
      if (letter.symbol == upper) return letter;
    }
    return null;
  }
}

/// How far a note is bent from its natural letter, in semitones.
///
/// Double accidentals are not decoration: a diminished seventh chord cannot be
/// spelled without them. E♭dim7 is E♭ G♭ B♭♭ D♭♭.
enum Accidental {
  /// Two semitones down, written `bb`.
  doubleFlat(-2, 'bb', '♭♭'),

  /// One semitone down, written `b`.
  flat(-1, 'b', '♭'),

  /// Unaltered.
  natural(0, '', ''),

  /// One semitone up, written `#`.
  sharp(1, '#', '♯'),

  /// Two semitones up, written `##`.
  doubleSharp(2, '##', '♯♯');

  const Accidental(this.offset, this.ascii, this.unicode);

  /// Semitone offset from the natural letter, −2 to +2.
  final int offset;

  /// Plain-text form, safe for identifiers and search input.
  final String ascii;

  /// Typographic form for display.
  final String unicode;

  /// The accidental for a semitone [offset], or null if outside −2…+2.
  static Accidental? fromOffset(int offset) {
    for (final accidental in Accidental.values) {
      if (accidental.offset == offset) return accidental;
    }
    return null;
  }
}

/// A spelled note name, without an octave.
///
/// Use `Pitch` when a specific octave matters.
@immutable
final class Note implements Comparable<Note> {
  /// Creates a note from a [letter] and an [accidental].
  const Note(this.letter, [this.accidental = Accidental.natural]);

  /// A note for [pitchClass], spelled with sharps unless [preferFlats] is set.
  ///
  /// The five black keys are the only ambiguous cases; the seven naturals
  /// always come back as naturals.
  factory Note.fromPitchClass(int pitchClass, {bool preferFlats = false}) {
    const sharps = <Note>[
      Note(NoteLetter.c),
      Note(NoteLetter.c, Accidental.sharp),
      Note(NoteLetter.d),
      Note(NoteLetter.d, Accidental.sharp),
      Note(NoteLetter.e),
      Note(NoteLetter.f),
      Note(NoteLetter.f, Accidental.sharp),
      Note(NoteLetter.g),
      Note(NoteLetter.g, Accidental.sharp),
      Note(NoteLetter.a),
      Note(NoteLetter.a, Accidental.sharp),
      Note(NoteLetter.b),
    ];
    const flats = <Note>[
      Note(NoteLetter.c),
      Note(NoteLetter.d, Accidental.flat),
      Note(NoteLetter.d),
      Note(NoteLetter.e, Accidental.flat),
      Note(NoteLetter.e),
      Note(NoteLetter.f),
      Note(NoteLetter.g, Accidental.flat),
      Note(NoteLetter.g),
      Note(NoteLetter.a, Accidental.flat),
      Note(NoteLetter.a),
      Note(NoteLetter.b, Accidental.flat),
      Note(NoteLetter.b),
    ];
    final cls = pitchClass % 12;
    return preferFlats ? flats[cls] : sharps[cls];
  }

  /// The seventeen spellings the interface offers as a root.
  ///
  /// Ascending by pitch, with the sharp before the flat where a sound has
  /// both. Seventeen rather than twelve because a player looking for D♭
  /// should not have to know it is filed under C♯ — the engines accept any
  /// spelling, and this is the list a picker shows. Double accidentals and
  /// the theoretical spellings (E♯, B♯, C♭, F♭) are left out: they occur
  /// inside chords and scales, never as the key someone chooses.
  static const List<Note> spellings = <Note>[
    Note(NoteLetter.c),
    Note(NoteLetter.c, Accidental.sharp),
    Note(NoteLetter.d, Accidental.flat),
    Note(NoteLetter.d),
    Note(NoteLetter.d, Accidental.sharp),
    Note(NoteLetter.e, Accidental.flat),
    Note(NoteLetter.e),
    Note(NoteLetter.f),
    Note(NoteLetter.f, Accidental.sharp),
    Note(NoteLetter.g, Accidental.flat),
    Note(NoteLetter.g),
    Note(NoteLetter.g, Accidental.sharp),
    Note(NoteLetter.a, Accidental.flat),
    Note(NoteLetter.a),
    Note(NoteLetter.a, Accidental.sharp),
    Note(NoteLetter.b, Accidental.flat),
    Note(NoteLetter.b),
  ];

  /// The natural letter.
  final NoteLetter letter;

  /// How far the letter is bent.
  final Accidental accidental;

  /// Pitch class 0–11, C at 0. Two enharmonic notes share one.
  int get pitchClass =>
      (letter.naturalPitchClass + accidental.offset + 12) % 12;

  /// Plain-text name, such as `C`, `F#` or `Bbb`.
  String get name => '${letter.symbol}${accidental.ascii}';

  /// Typographic name, such as `C`, `F♯` or `B♭♭`.
  String get displayName => '${letter.symbol}${accidental.unicode}';

  /// Whether [other] sounds the same without being spelled the same.
  ///
  /// C♯ is enharmonic with D♭ and equal to neither.
  bool isEnharmonicWith(Note other) => pitchClass == other.pitchClass;

  /// The note [interval] above this one, spelled correctly.
  ///
  /// The letter moves by the interval's diatonic steps and the accidental
  /// absorbs whatever is left over, which is what makes C plus a minor third
  /// give E♭ rather than D♯.
  ///
  /// Throws [ArgumentError] if the result would need more than a double
  /// accidental.
  Note transposeBy(Interval interval) {
    final result = tryTransposeBy(interval);
    if (result == null) {
      throw ArgumentError(
        'transposing $name by ${interval.degree} needs an accidental beyond '
        'a double sharp or double flat',
      );
    }
    return result;
  }

  /// The note [interval] above this one, or null when no spelling exists.
  ///
  /// Same arithmetic as [transposeBy], without the throw. Use it when the
  /// caller is *asking whether* a spelling exists rather than asserting that
  /// it does — the scale catalogue does exactly that, because A♯ whole tone
  /// would need an F triple sharp and is written B♭ whole tone instead.
  Note? tryTransposeBy(Interval interval) {
    final target = letter.transposeSteps(interval.letterSteps);
    final natural = target.naturalPitchClass;
    final wanted = (pitchClass + interval.semitones) % 12;

    // The offset that bends the target letter onto the wanted pitch class,
    // folded into −6…+5 so an octave wrap does not read as a huge alteration.
    var offset = (wanted - natural + 12) % 12;
    if (offset > 6) offset -= 12;

    final result = Accidental.fromOffset(offset);
    return result == null ? null : Note(target, result);
  }

  /// The note [semitones] above this one, respelled chromatically.
  ///
  /// Unlike [transposeBy] this has no diatonic anchor, so it picks a spelling:
  /// sharps by default, flats when [preferFlats] is set. Use it to transpose a
  /// whole chord or song; use [transposeBy] to spell a chord's own tones.
  ///
  /// Negative [semitones] transpose down.
  Note transposeChromatically(int semitones, {bool preferFlats = false}) {
    final target = (pitchClass + semitones) % 12;
    return Note.fromPitchClass(
      target < 0 ? target + 12 : target,
      preferFlats: preferFlats,
    );
  }

  /// Parses `C`, `f#`, `Bb`, `E♭` or `Bbb`.
  ///
  /// Returns null on anything else rather than throwing, because this parses
  /// text that may have come from content or from a player (CLAUDE.md §37).
  static Note? tryParse(String input) {
    final text = input.trim();
    if (text.isEmpty) return null;

    final letter = NoteLetter.tryParse(text[0]);
    if (letter == null) return null;

    var offset = 0;
    for (var i = 1; i < text.length; i++) {
      switch (text[i]) {
        case 'b':
        case '♭':
          offset -= 1;
        case '#':
        case '♯':
          offset += 1;
        case '♮':
          break;
        default:
          return null;
      }
    }

    final accidental = Accidental.fromOffset(offset);
    return accidental == null ? null : Note(letter, accidental);
  }

  /// Orders by pitch class, then by letter so enharmonics sort stably.
  @override
  int compareTo(Note other) {
    final byPitch = pitchClass.compareTo(other.pitchClass);
    return byPitch != 0 ? byPitch : letter.step.compareTo(other.letter.step);
  }

  @override
  bool operator ==(Object other) =>
      other is Note && other.letter == letter && other.accidental == accidental;

  @override
  int get hashCode => Object.hash(letter, accidental);

  @override
  String toString() => name;
}
