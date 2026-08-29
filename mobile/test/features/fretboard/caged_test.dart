import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/fretboard.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/pitch.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/chords/domain/chord_shape.dart';
import 'package:l_key/features/chords/domain/voicing_library.dart';
import 'package:l_key/features/fretboard/domain/caged.dart';

/// The twelve sounds, one spelling each — CAGED is about neck geometry, and
/// the geometry does not care whether the root is written C♯ or D♭.
const List<Note> _roots = <Note>[
  Note(NoteLetter.c),
  Note(NoteLetter.c, Accidental.sharp),
  Note(NoteLetter.d),
  Note(NoteLetter.e, Accidental.flat),
  Note(NoteLetter.e),
  Note(NoteLetter.f),
  Note(NoteLetter.f, Accidental.sharp),
  Note(NoteLetter.g),
  Note(NoteLetter.a, Accidental.flat),
  Note(NoteLetter.a),
  Note(NoteLetter.b, Accidental.flat),
  Note(NoteLetter.b),
];

void main() {
  group('CagedShape data', () {
    test('the five shapes are the five open chords they are named after', () {
      // Each shape at shift 0 must spell its own letter. If a fret in the
      // table is mistyped, this is the assertion that catches it.
      final failures = <String>[];
      for (final shape in CagedShape.values) {
        final root = Note(NoteLetter.tryParse(shape.letter)!);
        if (shape.shiftFor(root) != 0) {
          failures.add('${shape.letter} shape does not open on ${root.name}');
        }
        final placed = CagedEngine.positionsFor(root: root).where(
          (p) => p.shape == shape,
        );
        if (placed.isEmpty) {
          failures.add('${shape.letter} shape is missing for ${root.name}');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('the E and A shapes agree with the chord voicing library', () {
      // The same two shapes are written down twice, in two files, for two
      // purposes. They must not drift apart (CLAUDE.md §4).
      final eShape = movableShapes.firstWhere(
        (s) => s.name == 'E-shape' && s.quality == ChordQuality.major,
      );
      final aShape = movableShapes.firstWhere(
        (s) => s.name == 'A-shape' && s.quality == ChordQuality.major,
      );
      expect(CagedShape.e.openFrets, eShape.offsets);
      expect(
        CagedShape.a.openFrets,
        aShape.offsets.map((o) => o == mutedOffset ? cagedMutedString : o),
      );
    });
  });

  group('CagedEngine.positionsFor', () {
    test('every root gets all five shapes on the neck', () {
      final failures = <String>[];
      for (final root in _roots) {
        final placed = CagedEngine.positionsFor(root: root);
        if (placed.length != 5) {
          failures.add('${root.name}: ${placed.length} shapes');
        }
        if (placed.map((p) => p.shape).toSet().length != 5) {
          failures.add('${root.name}: a shape appears twice');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('every placed shape passes the invariant', () {
      // The same guard docs/adr/0010 put over the chord catalogue: hand-typed
      // fret data is data, and data has typos a compiler cannot see.
      final failures = <String>[];
      for (final root in _roots) {
        for (final position in CagedEngine.positionsFor(root: root)) {
          final problem = CagedEngine.problemWith(position, Tuning.standard);
          if (problem != null) {
            failures.add('${root.name} ${position.shape.letter}: $problem');
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('the shapes tile the neck in a rotation of C-A-G-E-D', () {
      const cycle = <CagedShape>[
        CagedShape.c,
        CagedShape.a,
        CagedShape.g,
        CagedShape.e,
        CagedShape.d,
      ];
      final failures = <String>[];
      for (final root in _roots) {
        final order = CagedEngine.positionsFor(
          root: root,
        ).map((p) => p.shape).toList();
        final start = cycle.indexOf(order.first);
        for (var i = 0; i < order.length; i++) {
          if (order[i] != cycle[(start + i) % 5]) {
            failures.add(
              '${root.name}: ${order.map((s) => s.letter).join()}',
            );
            break;
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('consecutive shapes overlap, so no stretch of neck is uncovered', () {
      final failures = <String>[];
      for (final root in _roots) {
        final placed = CagedEngine.positionsFor(root: root);
        for (var i = 1; i < placed.length; i++) {
          if (placed[i].range.lowest > placed[i - 1].range.highest + 1) {
            failures.add(
              '${root.name}: gap between ${placed[i - 1].shape.letter} '
              'and ${placed[i].shape.letter}',
            );
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('C major reads C-A-G-E-D from the nut upward', () {
      final placed = CagedEngine.positionsFor(root: const Note(NoteLetter.c));
      expect(
        placed.map((p) => p.shape.letter),
        <String>['C', 'A', 'G', 'E', 'D'],
      );
      // The open C shape, then the barre at 3, the G shape at 5, the E-shape
      // barre at 8 and the D shape at 10 — the positions every CAGED lesson
      // draws.
      expect(placed.map((p) => p.shift), <int>[0, 3, 5, 8, 10]);
      expect(
        placed.first.tones.map((t) => t.fret),
        <int>[3, 2, 0, 1, 0],
      );
    });

    test('the root is always among the tones, and spelled by the chord', () {
      final failures = <String>[];
      for (final root in _roots) {
        for (final position in CagedEngine.positionsFor(root: root)) {
          if (!position.tones.any((t) => t.isRoot)) {
            failures.add('${root.name} ${position.shape.letter}: no root');
          }
          for (final tone in position.tones) {
            if (tone.note != root.transposeBy(tone.degree)) {
              failures.add('${root.name} ${position.shape.letter}: spelling');
            }
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('CAGED is a claim about standard tuning and says so elsewhere', () {
      // PRD.md §15 teaches five shapes on a six-string guitar. They are not
      // true of a bass or a seven-string, and CLAUDE.md §47 would rather the
      // engine return nothing than invent a sixth system.
      for (final tuning in <Tuning>[
        Tuning.bassFour,
        Tuning.sevenString,
        Tuning.eightString,
        Tuning.dropD,
      ]) {
        expect(
          CagedEngine.positionsFor(
            root: const Note(NoteLetter.g),
            tuning: tuning,
          ),
          isEmpty,
          reason: tuning.name,
        );
      }
    });

    test('the invariant rejects a shape that is quietly wrong', () {
      // Proof the guard has teeth: move one fret of the open C shape and the
      // chord it spells is no longer a C.
      final good = CagedEngine.positionsFor(
        root: const Note(NoteLetter.c),
      ).first;
      expect(CagedEngine.problemWith(good, Tuning.standard), isNull);

      final broken = CagedPosition(
        shape: good.shape,
        root: good.root,
        shift: good.shift,
        range: good.range,
        tones: good.tones
            .map(
              (t) => t.stringIndex == 1
                  ? FretPosition(
                      stringIndex: t.stringIndex,
                      fret: t.fret + 1,
                      pitch: Pitch(t.note, t.pitch.octave),
                      note: t.note,
                      degree: t.degree,
                    )
                  : t,
            )
            .toList(),
      );
      expect(
        CagedEngine.problemWith(broken, Tuning.standard),
        CagedProblem.foreignNote,
      );
    });
  });
}
