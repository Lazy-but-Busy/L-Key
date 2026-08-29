import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/pitch.dart';
import 'package:l_key/core/music/tuning.dart';

void main() {
  group('Pitch', () {
    test('MIDI numbers follow scientific pitch notation', () {
      expect(const Pitch(Note(NoteLetter.c), 4).midiNumber, 60);
      expect(const Pitch(Note(NoteLetter.a), 4).midiNumber, 69);
      expect(const Pitch(Note(NoteLetter.e), 2).midiNumber, 40);
    });

    test('an octave belongs to the letter, not to the sounding pitch', () {
      // B#3 and C4 sound alike; the octave number follows the letter, so B#3
      // must land on 60 rather than jumping to the next octave.
      expect(
        const Pitch(Note(NoteLetter.b, Accidental.sharp), 3).midiNumber,
        60,
      );
      expect(
        const Pitch(Note(NoteLetter.c, Accidental.flat), 4).midiNumber,
        59,
      );
    });

    test('frequencies match the standard tuning reference', () {
      // PRD.md §10 — the tuner reads these; the values are the published
      // equal-tempered frequencies for A440.
      expect(
        const Pitch(Note(NoteLetter.a), 4).frequencyHz(),
        closeTo(440, 0.001),
      );
      expect(
        const Pitch(Note(NoteLetter.e), 2).frequencyHz(),
        closeTo(82.407, 0.01),
      );
      expect(
        const Pitch(Note(NoteLetter.e), 4).frequencyHz(),
        closeTo(329.628, 0.01),
      );
    });

    test('a different reference pitch moves every frequency with it', () {
      // Settings offers a reference pitch; it must not be ignored here.
      expect(
        const Pitch(Note(NoteLetter.a), 4).frequencyHz(referenceHz: 432),
        closeTo(432, 0.001),
      );
    });
  });

  group('Tuning', () {
    test('standard tuning is E2 A2 D3 G3 B3 E4, lowest string first', () {
      expect(Tuning.standard.stringCount, 6);
      expect(
        Tuning.standard.openStrings.map((p) => p.name).toList(),
        <String>['E2', 'A2', 'D3', 'G3', 'B3', 'E4'],
      );
    });

    test('fret arithmetic walks up from the open string', () {
      // Third fret of the A string is C — the note the open C chord roots on.
      expect(Tuning.standard.pitchAt(stringIndex: 1, fret: 3).name, 'C3');
      expect(Tuning.standard.pitchAt(stringIndex: 0, fret: 0).name, 'E2');
      expect(Tuning.standard.pitchAt(stringIndex: 0, fret: 12).name, 'E3');
      expect(Tuning.standard.pitchAt(stringIndex: 5, fret: 3).name, 'G4');
    });

    test('an impossible string or fret fails loudly', () {
      expect(
        () => Tuning.standard.pitchAt(stringIndex: 6, fret: 0),
        throwsRangeError,
      );
      expect(
        () => Tuning.standard.pitchAt(stringIndex: 0, fret: -1),
        throwsArgumentError,
      );
    });
  });
}
