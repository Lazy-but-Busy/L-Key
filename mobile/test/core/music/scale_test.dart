import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/interval.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/scale.dart';

List<String> _names(Scale scale) =>
    scale.notes.map((n) => n.name).toList(growable: false);

void main() {
  group('ScaleType formulas', () {
    test('PRD.md §14 names every scale the library ships', () {
      // Five free, eleven Premium, plus Ionian and Aeolian — a modes list
      // missing two of the seven teaches the modes wrongly.
      expect(ScaleType.values.length, 18);
      expect(ScaleType.major.formula, '1 2 3 4 5 6 7');
      expect(ScaleType.naturalMinor.formula, '1 2 b3 4 5 b6 b7');
      expect(ScaleType.minorPentatonic.formula, '1 b3 4 5 b7');
      expect(ScaleType.majorPentatonic.formula, '1 2 3 5 6');
      expect(ScaleType.blues.formula, '1 b3 4 b5 5 b7');
    });

    test('the modes are the major scale rotated, not seven new formulas', () {
      // Every mode's semitone set is a rotation of the major scale's.
      const wanted = <int>{0, 2, 4, 5, 7, 9, 11};
      const modes = <ScaleType>[
        ScaleType.ionian,
        ScaleType.dorian,
        ScaleType.phrygian,
        ScaleType.lydian,
        ScaleType.mixolydian,
        ScaleType.aeolian,
        ScaleType.locrian,
      ];
      for (var index = 0; index < modes.length; index++) {
        final offsets = modes[index].intervals.map((i) => i.semitones).toList();
        final shift = <int>[0, 2, 4, 5, 7, 9, 11][index];
        final rotated = <int>{
          for (final degree in wanted) (degree - shift + 12) % 12,
        };
        expect(
          offsets.toSet(),
          rotated,
          reason: '${modes[index].name} is not the major scale rotated',
        );
      }
    });

    test('every formula ascends and starts on the root', () {
      final failures = <String>[];
      for (final type in ScaleType.values) {
        final offsets = type.intervals.map((i) => i.semitones).toList();
        if (offsets.first != 0) {
          failures.add('${type.slug} does not start on 1');
        }
        for (var i = 1; i < offsets.length; i++) {
          if (offsets[i] <= offsets[i - 1]) {
            failures.add('${type.slug} does not ascend at degree ${i + 1}');
          }
        }
        if (offsets.toSet().length != offsets.length) {
          failures.add('${type.slug} names one pitch class twice');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });
  });

  group('Scale spelling', () {
    test('a seven-note scale uses each of the seven letters once', () {
      // This is what a diatonic scale *is*, and it is the assertion an
      // integer-based engine cannot make at all (docs/adr/0009).
      final failures = <String>[];
      for (final type in ScaleType.values) {
        if (type.noteCount != 7) continue;
        for (final root in Note.spellings) {
          final scale = Scale(root, type);
          if (!scale.isSpellable) continue;
          final letters = scale.notes.map((n) => n.letter).toSet();
          if (letters.length != 7) {
            failures.add('${scale.root.name} ${type.slug}: ${_names(scale)}');
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('the Lydian fourth is a sharp four, not a flat five', () {
      // Both span six semitones. Only one lands on the fourth letter, and F
      // Lydian spelled with a C flat would have two Cs and no B.
      expect(
        _names(const Scale(Note(NoteLetter.f), ScaleType.lydian)),
        <String>[
          'F',
          'G',
          'A',
          'B',
          'C',
          'D',
          'E',
        ],
      );
      expect(
        const Scale(Note(NoteLetter.c), ScaleType.lydian).notes[3].name,
        'F#',
      );
    });

    test('sharp keys keep their sharps and flat keys keep their flats', () {
      expect(
        _names(
          const Scale(Note(NoteLetter.f, Accidental.sharp), ScaleType.major),
        ),
        <String>['F#', 'G#', 'A#', 'B', 'C#', 'D#', 'E#'],
      );
      expect(
        _names(
          const Scale(Note(NoteLetter.g, Accidental.flat), ScaleType.major),
        ),
        <String>['Gb', 'Ab', 'Bb', 'Cb', 'Db', 'Eb', 'F'],
      );
    });

    test('harmonic minor needs a double flat nowhere and a leading tone', () {
      expect(
        _names(const Scale(Note(NoteLetter.a), ScaleType.harmonicMinor)),
        <String>['A', 'B', 'C', 'D', 'E', 'F', 'G#'],
      );
    });

    test('the diminished scale spells its double-flat seventh', () {
      expect(
        _names(
          const Scale(Note(NoteLetter.c), ScaleType.diminishedWholeHalf),
        ),
        <String>['C', 'D', 'Eb', 'F', 'Gb', 'Ab', 'Bbb', 'B'],
      );
    });

    test('the chromatic scale spells twelve notes on seven letters', () {
      expect(
        _names(const Scale(Note(NoteLetter.c), ScaleType.chromatic)),
        <String>[
          'C',
          'C#',
          'D',
          'D#',
          'E',
          'F',
          'F#',
          'G',
          'G#',
          'A',
          'A#',
          'B',
        ],
      );
    });

    test('an unspellable root reports itself instead of throwing later', () {
      // A# whole tone would need an F triple sharp for its #6. A musician
      // writes Bb whole tone instead, and the catalogue offers that root.
      const unspellable = Scale(
        Note(NoteLetter.a, Accidental.sharp),
        ScaleType.wholeTone,
      );
      expect(unspellable.isSpellable, isFalse);
      expect(() => unspellable.notes, throwsArgumentError);

      const spellable = Scale(
        Note(NoteLetter.b, Accidental.flat),
        ScaleType.wholeTone,
      );
      expect(spellable.isSpellable, isTrue);
      expect(_names(spellable), <String>['Bb', 'C', 'D', 'E', 'F#', 'G#']);
    });
  });

  group('Scale relationships', () {
    test('the second mode of C major is D dorian', () {
      final mode = const Scale(Note(NoteLetter.c), ScaleType.major).modeAt(2);
      expect(mode, isNotNull);
      expect(mode!.root.name, 'D');
      expect(mode.type, ScaleType.dorian);
      expect(
        mode.pitchClasses.toSet(),
        const Scale(Note(NoteLetter.c), ScaleType.major).pitchClasses.toSet(),
      );
    });

    test('every mode of a major scale is one of the seven named modes', () {
      final failures = <String>[];
      const expected = <ScaleType>[
        ScaleType.ionian,
        ScaleType.dorian,
        ScaleType.phrygian,
        ScaleType.lydian,
        ScaleType.mixolydian,
        ScaleType.aeolian,
        ScaleType.locrian,
      ];
      for (var degree = 1; degree <= 7; degree++) {
        final mode = const Scale(
          Note(NoteLetter.c),
          ScaleType.ionian,
        ).modeAt(degree);
        if (mode?.type != expected[degree - 1]) {
          failures.add('degree $degree gave ${mode?.type.slug}');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('a rotation nobody names comes back null rather than invented', () {
      // CLAUDE.md §37 — a handled outcome, not a made-up scale name.
      expect(
        const Scale(Note(NoteLetter.a), ScaleType.blues).modeAt(3),
        isNull,
      );
      expect(
        const Scale(Note(NoteLetter.c), ScaleType.major).modeAt(0),
        isNull,
      );
      expect(
        const Scale(Note(NoteLetter.c), ScaleType.major).modeAt(8),
        isNull,
      );
    });

    test('a degree is found by sound and answered by spelling', () {
      const scale = Scale(Note(NoteLetter.e, Accidental.flat), ScaleType.major);
      // G# and Ab are one sound; the scale answers with its own degree.
      expect(
        scale.intervalOf(const Note(NoteLetter.g, Accidental.sharp)),
        Interval.perfectFourth,
      );
      expect(scale.intervalOf(const Note(NoteLetter.b)), isNull);
      expect(scale.contains(const Note(NoteLetter.b)), isFalse);
    });

    test('transposing keeps the formula and moves the root', () {
      const scale = Scale(Note(NoteLetter.a), ScaleType.minorPentatonic);
      final up = scale.transpose(3);
      expect(up.type, ScaleType.minorPentatonic);
      expect(up.root.name, 'C');
      expect(scale.transpose(3, preferFlats: true).root.name, 'C');
      expect(scale.transpose(1, preferFlats: true).root.name, 'Bb');
      expect(scale.transpose(1).root.name, 'A#');
    });
  });
}
