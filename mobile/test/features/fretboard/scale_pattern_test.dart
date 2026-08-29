import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/fretboard.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/scale.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/fretboard/domain/scale_pattern.dart';

List<ScalePosition> _boxesOf(Scale scale, {Tuning tuning = Tuning.standard}) =>
    ScalePatternEngine.boxes(
      tuning: tuning,
      root: scale.root,
      intervals: scale.intervals,
    );

/// The frets a position uses on one string.
List<int> _fretsOn(ScalePosition position, int string) => position.positions
    .where((p) => p.stringIndex == string)
    .map((p) => p.fret)
    .toList(growable: false);

void main() {
  group('Pentatonic boxes', () {
    const aMinorPentatonic = Scale(
      Note(NoteLetter.a),
      ScaleType.minorPentatonic,
    );

    test('box 1 is the shape the design system draws', () {
      // The PENTA marker table in the design system's ScalesScreen, note for
      // note. Its string order runs high to low, so it is mirrored here.
      final box = _boxesOf(aMinorPentatonic).first;
      expect(box.index, 1);
      expect(box.range, FretRange(lowest: 5, highest: 8));
      expect(_fretsOn(box, 5), <int>[5, 8]); // high E
      expect(_fretsOn(box, 4), <int>[5, 8]); // B
      expect(_fretsOn(box, 3), <int>[5, 7]); // G
      expect(_fretsOn(box, 2), <int>[5, 7]); // D
      expect(_fretsOn(box, 1), <int>[5, 7]); // A
      expect(_fretsOn(box, 0), <int>[5, 8]); // low E
    });

    test('the five boxes are the five every guitarist is taught', () {
      final boxes = _boxesOf(aMinorPentatonic);
      expect(boxes.length, 5);
      // Box 3 is five frets wide, not four: the B string reaches from 10 to
      // 13 and no four-fret window covers it. A fixed window length would
      // have quietly reported the wrong shape here.
      expect(
        boxes.map((b) => '${b.range.lowest}-${b.range.highest}'),
        <String>['5-8', '7-10', '9-13', '12-15', '14-17'],
      );
    });

    test('boxes ascend the neck and overlap, so the neck is covered', () {
      final boxes = _boxesOf(aMinorPentatonic);
      for (var i = 1; i < boxes.length; i++) {
        expect(boxes[i].range.lowest, greaterThan(boxes[i - 1].range.lowest));
        // Overlapping is what lets a player move between positions; a gap
        // would mean a stretch of neck no box covers.
        expect(
          boxes[i].range.lowest,
          lessThanOrEqualTo(boxes[i - 1].range.highest),
        );
      }
    });

    test('every box carries at least two notes on every string', () {
      // The property that defines a box, asserted over every scale, every
      // catalogue tuning and every root spelling.
      final failures = <String>[];
      for (final tuning in Tuning.catalogue) {
        for (final type in ScaleType.values) {
          if (type == ScaleType.chromatic) continue;
          const root = Note(NoteLetter.a);
          final scale = Scale(root, type);
          if (!scale.isSpellable) continue;
          for (final box in _boxesOf(scale, tuning: tuning)) {
            for (var s = 0; s < tuning.stringCount; s++) {
              if (_fretsOn(box, s).length < 2) {
                failures.add(
                  '${tuning.name} ${type.slug} box ${box.index}: '
                  'string $s has ${_fretsOn(box, s).length}',
                );
              }
            }
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('box 1 holds the root on the lowest string', () {
      final failures = <String>[];
      for (final type in ScaleType.values) {
        if (type == ScaleType.chromatic) continue;
        for (final letter in NoteLetter.values) {
          final scale = Scale(Note(letter), type);
          if (!scale.isSpellable) continue;
          final boxes = _boxesOf(scale);
          if (boxes.isEmpty) {
            failures.add('${scale.root.name} ${type.slug} has no boxes');
            continue;
          }
          final hasRoot = boxes.first.positions.any(
            (p) => p.stringIndex == 0 && p.isRoot,
          );
          if (!hasRoot) {
            failures.add('${scale.root.name} ${type.slug} box 1: no low root');
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test(
      'the chromatic scale has no boxes rather than twelve meaningless ones',
      () {
        // CLAUDE.md §47 — an empty state, not an invented one. Every window of
        // the chromatic scale is identical, so a "box" would say nothing.
        expect(
          _boxesOf(const Scale(Note(NoteLetter.c), ScaleType.chromatic)),
          isEmpty,
        );
      },
    );

    test('bass and extended-range necks get boxes too', () {
      for (final tuning in <Tuning>[
        Tuning.bassFour,
        Tuning.sevenString,
        Tuning.eightString,
      ]) {
        final boxes = _boxesOf(aMinorPentatonic, tuning: tuning);
        expect(boxes, isNotEmpty, reason: tuning.name);
        expect(boxes.first.kind, ScalePatternKind.box);
      }
    });
  });

  group('Three notes per string', () {
    test('a seven-note scale gives three notes on every string', () {
      final patterns = ScalePatternEngine.threeNotesPerString(
        tuning: Tuning.standard,
        root: const Note(NoteLetter.c),
        intervals: ScaleType.major.intervals,
      );
      expect(patterns, isNotEmpty);
      for (final pattern in patterns) {
        expect(pattern.positions.length, 18);
        for (var s = 0; s < 6; s++) {
          expect(_fretsOn(pattern, s).length, 3, reason: 'string $s');
        }
      }
    });

    test('the pattern ascends: every note is higher than the last', () {
      final failures = <String>[];
      for (final type in <ScaleType>[
        ScaleType.major,
        ScaleType.dorian,
        ScaleType.harmonicMinor,
      ]) {
        for (final pattern in ScalePatternEngine.threeNotesPerString(
          tuning: Tuning.standard,
          root: const Note(NoteLetter.g),
          intervals: type.intervals,
        )) {
          final notes = pattern.positions;
          for (var i = 1; i < notes.length; i++) {
            if (notes[i].pitch.midiNumber <= notes[i - 1].pitch.midiNumber) {
              failures.add('${type.slug} pattern ${pattern.index} at $i');
            }
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('a five-note scale has no three-note-per-string pattern', () {
      expect(
        ScalePatternEngine.threeNotesPerString(
          tuning: Tuning.standard,
          root: const Note(NoteLetter.a),
          intervals: ScaleType.minorPentatonic.intervals,
        ),
        isEmpty,
      );
    });
  });
}
