import 'dart:math' as math;

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

    test('a frequency resolves to the pitch it is nearest', () {
      // PRD.md §10 — the tuner's first question. This is the reverse of
      // frequencyHz, and the two must agree.
      expect(Pitch.nearestTo(440).name, 'A4');
      expect(Pitch.nearestTo(82.41).name, 'E2');
      expect(Pitch.nearestTo(329.63).name, 'E4');
      expect(Pitch.nearestTo(30.87).name, 'B0');
    });

    test('every pitch survives the round trip through its own frequency', () {
      // If nearestTo and frequencyHz disagree anywhere in the instrument's
      // range, the tuner names the wrong string.
      final failures = <String>[];
      for (var midi = 21; midi <= 96; midi++) {
        final pitch = Pitch.fromMidiNumber(midi);
        final back = Pitch.nearestTo(pitch.frequencyHz());
        if (back != pitch) {
          failures.add('${pitch.name} came back as ${back.name}');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('a frequency knows nothing about spelling, so the caller picks', () {
      // docs/adr/0009 — 277.18 Hz is C#4 and Db4 equally. Neither is more
      // correct, so nearestTo takes the choice rather than inventing one.
      expect(Pitch.nearestTo(277.18).name, 'C#4');
      expect(Pitch.nearestTo(277.18, preferFlats: true).name, 'Db4');
    });

    test('sharp is positive and flat is negative', () {
      // DESIGN.md §22 — sharp moves the needle right, flat moves it left, so
      // the sign of the cents value is what decides which way it goes.
      const e2 = Pitch(Note(NoteLetter.e), 2);
      expect(e2.centsFrom(82.4069), closeTo(0, 0.1));
      expect(e2.centsFrom(83), greaterThan(0));
      expect(e2.centsFrom(82), lessThan(0));
    });

    test('a hundred cents is a semitone and fifty is the halfway point', () {
      const a4 = Pitch(Note(NoteLetter.a), 4);
      const bFlat4 = Pitch(Note(NoteLetter.b, Accidental.flat), 4);
      expect(a4.centsFrom(bFlat4.frequencyHz()), closeTo(100, 0.001));
      expect(bFlat4.centsFrom(a4.frequencyHz()), closeTo(-100, 0.001));

      // The geometric mean of two adjacent semitones sits 50 cents from each.
      final between = math.sqrt(a4.frequencyHz() * bFlat4.frequencyHz());
      expect(a4.centsFrom(between), closeTo(50, 0.001));
      expect(bFlat4.centsFrom(between), closeTo(-50, 0.001));
    });

    test('the nearest pitch flips at the halfway point, not before', () {
      // The boundary matters: a string 49 cents sharp is still that string
      // being sharp, not the next one being flat.
      const e2 = Pitch(Note(NoteLetter.e), 2);
      final base = e2.frequencyHz();
      expect(Pitch.nearestTo(base * _centsRatio(49)).name, 'E2');
      expect(Pitch.nearestTo(base * _centsRatio(51)).name, 'F2');
    });

    test('a reference other than A440 moves every target', () {
      // PRD.md §10.2 offers a configurable reference pitch. Changing it must
      // move the whole grid, not just A.
      const a4 = Pitch(Note(NoteLetter.a), 4);
      expect(a4.frequencyHz(referenceHz: 432), closeTo(432, 0.001));
      expect(a4.centsFrom(440, referenceHz: 432), closeTo(31.767, 0.01));

      const e2 = Pitch(Note(NoteLetter.e), 2);
      expect(e2.frequencyHz(referenceHz: 432), closeTo(80.907, 0.01));
      expect(Pitch.nearestTo(80.907, referenceHz: 432).name, 'E2');
    });

    test('a frequency nothing could have sounded fails loudly', () {
      // CLAUDE.md §37 wants a handled outcome. Silence reaches the detector as
      // an absent reading, never as 0 Hz, so a zero here is a caller bug.
      expect(() => Pitch.nearestTo(0), throwsArgumentError);
      expect(() => Pitch.nearestTo(-1), throwsArgumentError);
      expect(() => Pitch.nearestTo(double.nan), throwsArgumentError);
      expect(() => Pitch.nearestTo(1), throwsArgumentError);
      expect(() => Pitch.nearestTo(20000), throwsArgumentError);
      expect(
        () => const Pitch(Note(NoteLetter.e), 2).centsFrom(0),
        throwsArgumentError,
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

/// The frequency ratio of a [cents] interval, for building a pitch a known
/// distance from a target.
double _centsRatio(double cents) => math.pow(2, cents / 1200).toDouble();
