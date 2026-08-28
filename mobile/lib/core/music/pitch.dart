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
