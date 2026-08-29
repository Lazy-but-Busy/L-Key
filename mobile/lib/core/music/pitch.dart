/// A note in a specific octave, and the arithmetic that turns it into a
/// frequency.
///
/// The tuner (PRD.md §10) and the fretboard (CLAUDE.md §13) both need this, so
/// it sits in `core/` rather than inside one feature.
///
/// Contains no Flutter. See docs/adr/0009.
library;

import 'dart:math' as math;

import 'package:l_key/core/music/note.dart';
import 'package:meta/meta.dart';

/// A spelled note at a specific octave.
///
/// Octaves follow scientific pitch notation, where middle C is C4 and the
/// guitar's low string is E2. The octave belongs to the *letter*, so B♯3 and
/// C4 are the same sounding pitch written two ways — which is why
/// [midiNumber] is derived from the letter's natural pitch class rather than
/// from [Note.pitchClass].
@immutable
final class Pitch implements Comparable<Pitch> {
  /// Creates a pitch from a [note] and a scientific-notation [octave].
  const Pitch(this.note, this.octave);

  /// The pitch whose equal-tempered frequency is closest to [frequencyHz].
  ///
  /// The tuner's first question — what note is this? — and the reverse of
  /// [frequencyHz]. Chord recognition needs the same mapping, which is why it
  /// lives here rather than in the tuner (docs/adr/0009).
  ///
  /// Spelling has to be chosen, because a frequency knows nothing about
  /// letters: 277.18 Hz is C♯4 and D♭4 equally. [preferFlats] picks, and a
  /// caller that already knows the key or the tuning should name the pitch
  /// itself instead of asking here.
  ///
  /// Throws [ArgumentError] for a frequency at or below zero, or one outside
  /// MIDI 12 (C0, 16.35 Hz) to 120 (C9, 8372 Hz) — beyond that the answer
  /// would be arithmetic rather than music.
  factory Pitch.nearestTo(
    double frequencyHz, {
    double referenceHz = 440,
    bool preferFlats = false,
  }) {
    if (frequencyHz <= 0 || !frequencyHz.isFinite) {
      throw ArgumentError.value(
        frequencyHz,
        'frequencyHz',
        'must be finite and above zero',
      );
    }
    final exact = 69 + 12 * _log2(frequencyHz / referenceHz);
    final midi = exact.round();
    if (midi < 12 || midi > 120) {
      throw ArgumentError.value(
        frequencyHz,
        'frequencyHz',
        'lies outside C0..C9 at a reference of $referenceHz Hz',
      );
    }
    return Pitch.fromMidiNumber(midi, preferFlats: preferFlats);
  }

  /// The pitch at [midiNumber], spelled with sharps unless [preferFlats].
  factory Pitch.fromMidiNumber(int midiNumber, {bool preferFlats = false}) =>
      Pitch(
        Note.fromPitchClass(midiNumber % 12, preferFlats: preferFlats),
        midiNumber ~/ 12 - 1,
      );

  /// The nearest pitch to [frequencyHz], or null where [Pitch.nearestTo]
  /// would throw.
  ///
  /// The house pattern for a value that arrives from outside and may simply
  /// not be one: a parser returns null rather than throwing (docs/adr/0009).
  static Pitch? tryNearestTo(
    double frequencyHz, {
    double referenceHz = 440,
    bool preferFlats = false,
  }) {
    if (frequencyHz <= 0 || !frequencyHz.isFinite) return null;
    final exact = 69 + 12 * _log2(frequencyHz / referenceHz);
    final midi = exact.round();
    if (midi < 12 || midi > 120) return null;
    return Pitch.fromMidiNumber(midi, preferFlats: preferFlats);
  }

  /// The spelled note.
  final Note note;

  /// Scientific-notation octave. Middle C is octave 4.
  final int octave;

  /// MIDI note number, where middle C (C4) is 60 and A4 is 69.
  ///
  /// Derived from the letter's natural pitch class plus the accidental, not
  /// from the wrapped [Note.pitchClass], so C♭4 sits a semitone below C4
  /// rather than jumping an octave.
  int get midiNumber =>
      (octave + 1) * 12 +
      note.letter.naturalPitchClass +
      note.accidental.offset;

  /// Frequency in hertz for a given [referenceHz] tuning of A4.
  ///
  /// Equal temperament: every semitone is the twelfth root of two.
  double frequencyHz({double referenceHz = 440}) =>
      referenceHz * math.pow(2, (midiNumber - 69) / 12).toDouble();

  /// How far [frequencyHz] lies from this pitch, in cents.
  ///
  /// Positive means the sounding note is **above** this pitch and the tuner's
  /// needle moves right; negative means flat and the needle moves left
  /// (DESIGN.md §22). A hundred cents is one semitone.
  ///
  /// Throws [ArgumentError] for a frequency at or below zero, because the
  /// honest answer there is negative infinity and no caller wants it.
  double centsFrom(double frequencyHz, {double referenceHz = 440}) {
    if (frequencyHz <= 0 || !frequencyHz.isFinite) {
      throw ArgumentError.value(
        frequencyHz,
        'frequencyHz',
        'must be finite and above zero',
      );
    }
    return 1200 *
        _log2(frequencyHz / this.frequencyHz(referenceHz: referenceHz));
  }

  static double _log2(double value) => math.log(value) / math.ln2;

  /// How many semitones [other] lies above this pitch. Negative when below.
  int semitonesTo(Pitch other) => other.midiNumber - midiNumber;

  /// The pitch [semitones] above this one, respelled chromatically.
  ///
  /// Use this for fret arithmetic, where the sounding pitch matters and the
  /// spelling is decided later by the chord it belongs to.
  Pitch transposeChromatically(int semitones, {bool preferFlats = false}) {
    final target = midiNumber + semitones;
    return Pitch(
      Note.fromPitchClass(target % 12, preferFlats: preferFlats),
      target ~/ 12 - 1,
    );
  }

  /// Scientific notation, such as `E2` or `F#4`.
  String get name => '${note.name}$octave';

  @override
  int compareTo(Pitch other) => midiNumber.compareTo(other.midiNumber);

  @override
  bool operator ==(Object other) =>
      other is Pitch && other.note == note && other.octave == octave;

  @override
  int get hashCode => Object.hash(note, octave);

  @override
  String toString() => name;
}
