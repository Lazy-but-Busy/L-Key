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

    test('the catalogue covers PRD.md §10.2 and the extended-range necks', () {
      // Fourteen tunings, every name unique, and nothing shipped twice.
      expect(Tuning.catalogue.length, 14);
      expect(Tuning.catalogue.first, Tuning.standard);
      expect(
        Tuning.catalogue.map((t) => t.name).toSet().length,
        Tuning.catalogue.length,
      );
      expect(
        Tuning.catalogue.map((t) => t.stringCount).toSet(),
        <int>{4, 5, 6, 7, 8},
      );
    });

    test(
      'every catalogue tuning is spelled and ordered lowest string first',
      () {
        // Getting the order backwards silently mirrors every diagram, so it is
        // asserted rather than trusted.
        final failures = <String>[];
        for (final tuning in Tuning.catalogue) {
          if (tuning.openStrings.isEmpty) {
            failures.add('${tuning.name} is empty');
          }
          for (var i = 1; i < tuning.stringCount; i++) {
            if (tuning.openStrings[i].midiNumber <
                tuning.openStrings[i - 1].midiNumber) {
              failures.add(
                '${tuning.name} string $i sounds below string ${i - 1}',
              );
            }
          }
        }
        expect(failures, isEmpty, reason: failures.join('\n'));
      },
    );

    test('drop D lowers the sixth string and nothing else', () {
      expect(
        Tuning.dropD.openStrings.map((p) => p.name).toList(),
        <String>['D2', 'A2', 'D3', 'G3', 'B3', 'E4'],
      );
      expect(
        Tuning.dropD.openStrings.sublist(1),
        Tuning.standard.openStrings.sublist(1),
      );
    });

    test('half a step down is written with flats, as players write it', () {
      expect(
        Tuning.halfStepDown.openStrings.map((p) => p.name).toList(),
        <String>['Eb2', 'Ab2', 'Db3', 'Gb3', 'Bb3', 'Eb4'],
      );
      for (var i = 0; i < 6; i++) {
        expect(
          Tuning.halfStepDown.openStrings[i].midiNumber,
          Tuning.standard.openStrings[i].midiNumber - 1,
        );
      }
    });

    test('DADGAD and the open tunings sound the chords they are named for', () {
      expect(
        Tuning.dadgad.openStrings.map((p) => p.name).toList(),
        <String>['D2', 'A2', 'D3', 'G3', 'A3', 'D4'],
      );
      // Open G, D and E sound a major triad on all six open strings.
      const expected = <String, List<int>>{
        'open-g': <int>[7, 11, 2],
        'open-d': <int>[2, 6, 9],
        'open-e': <int>[4, 8, 11],
      };
      for (final entry in expected.entries) {
        final tuning = Tuning.catalogue.firstWhere(
          (t) => t.name == entry.key,
        );
        expect(
          tuning.openStrings.map((p) => p.note.pitchClass).toSet(),
          entry.value.toSet(),
          reason: entry.key,
        );
      }
    });

    test('the extended-range necks extend the standard one downward', () {
      expect(
        Tuning.sevenString.openStrings.sublist(1),
        Tuning.standard.openStrings,
      );
      expect(
        Tuning.eightString.openStrings.sublist(1),
        Tuning.sevenString.openStrings,
      );
      expect(Tuning.eightString.openStrings.first.name, 'F#1');
    });

    test('a bass sounds an octave below the guitar strings it shares', () {
      expect(
        Tuning.bassFour.openStrings.map((p) => p.name).toList(),
        <String>['E1', 'A1', 'D2', 'G2'],
      );
      for (var i = 0; i < 4; i++) {
        expect(
          Tuning.bassFour.openStrings[i].midiNumber,
          Tuning.standard.openStrings[i].midiNumber - 12,
        );
      }
      expect(
        Tuning.bassFive.openStrings.sublist(1),
        Tuning.bassFour.openStrings,
      );
    });
  });
}
