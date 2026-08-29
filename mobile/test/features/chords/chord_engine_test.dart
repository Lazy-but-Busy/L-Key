import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/chords/domain/chord.dart';
import 'package:l_key/features/chords/domain/chord_engine.dart';
import 'package:l_key/features/chords/domain/chord_quality.dart';
import 'package:l_key/features/chords/domain/chord_voicing.dart';
import 'package:l_key/features/chords/domain/voicing_library.dart';

/// The seventeen root spellings the library browses.
const List<String> _roots = <String>[
  'C',
  'C#',
  'Db',
  'D',
  'D#',
  'Eb',
  'E',
  'F',
  'F#',
  'Gb',
  'G',
  'G#',
  'Ab',
  'A',
  'A#',
  'Bb',
  'B',
];

Chord _chord(String root, ChordQuality quality) =>
    Chord(root: Note.tryParse(root)!, quality: quality);

void main() {
  group('ChordEngine coverage', () {
    test('every root and quality in the catalogue has a voicing', () {
      // CLAUDE.md §47 — a chord library with silent gaps is a half-feature.
      final missing = <String>[];
      for (final root in _roots) {
        for (final quality in ChordQuality.values) {
          final chord = _chord(root, quality);
          if (ChordEngine.voicingsFor(chord).isEmpty) missing.add(chord.symbol);
        }
      }
      expect(
        missing,
        isEmpty,
        reason: 'no shape reaches ${missing.join(", ")}',
      );
    });

    test('every voicing the engine returns spells its chord', () {
      // The invariant the whole shape library is held to: a wrong fret in the
      // data fails here rather than teaching someone the wrong chord.
      final failures = <String>[];
      for (final root in _roots) {
        for (final quality in ChordQuality.values) {
          final chord = _chord(root, quality);
          for (final voicing in ChordEngine.voicingsFor(chord)) {
            final problem = ChordEngine.problemWith(
              voicing,
              chord,
              Tuning.standard,
            );
            if (problem != null) {
              failures.add('${chord.symbol} ${voicing.fretString}: $problem');
            }
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('every voicing fits a hand', () {
      final failures = <String>[];
      for (final root in _roots) {
        for (final quality in ChordQuality.values) {
          final chord = _chord(root, quality);
          for (final voicing in ChordEngine.voicingsFor(chord)) {
            if (voicing.fretSpan > 4 || voicing.fingerCount > 4) {
              failures.add(
                '${chord.symbol} ${voicing.fretString} — '
                'span ${voicing.fretSpan}, ${voicing.fingerCount} fingers',
              );
            }
            if (voicing.soundingStrings.length < 3) {
              failures.add('${chord.symbol} ${voicing.fretString} — too thin');
            }
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('results are ordered from the nut upward and are distinct', () {
      final voicings = ChordEngine.voicingsFor(
        _chord('G', ChordQuality.major),
      );
      expect(voicings.length, greaterThan(1));
      expect(voicings.toSet().length, voicings.length, reason: 'duplicates');
      var previous = -1;
      for (final voicing in voicings) {
        expect(voicing.lowestFret, greaterThanOrEqualTo(previous));
        previous = voicing.lowestFret;
      }
    });

    test('the same shape is never listed twice', () {
      // A curated open chord and a movable shape slid to the nut can stop
      // identical frets and name different fingers. Two identical diagrams
      // with different numbers on them help nobody.
      for (final symbol in <String>['Em', 'Am', 'A7', 'Am7', 'E', 'C']) {
        final chord = Chord(
          root: Note.tryParse(symbol.substring(0, 1))!,
          quality: switch (symbol.substring(1)) {
            'm' => ChordQuality.minor,
            '7' => ChordQuality.dominantSeventh,
            'm7' => ChordQuality.minorSeventh,
            _ => ChordQuality.major,
          },
        );
        final shapes = ChordEngine.voicingsFor(
          chord,
        ).map((voicing) => voicing.fretString).toList();
        expect(
          shapes.toSet().length,
          shapes.length,
          reason: '$symbol lists $shapes',
        );
      }
    });

    test('the same chord always produces the same shapes', () {
      // CLAUDE.md §17 — this is arithmetic, not a judgement call.
      final chord = _chord('F#', ChordQuality.minorSeventh);
      expect(ChordEngine.voicingsFor(chord), ChordEngine.voicingsFor(chord));
    });
  });

  group('ChordEngine shapes', () {
    test('the open chords are the ones a beginner is taught', () {
      // PRD.md §11 names these as the free chords. The fret arrays are the
      // ones every chord book prints; if the engine stops producing them,
      // something in the library has drifted.
      const expected = <String, String>{
        'C': 'x32010',
        'D': 'xx0232',
        'E': '022100',
        'G': '320003',
        'A': 'x02220',
        'Am': 'x02210',
        'Dm': 'xx0231',
        'Em': '022000',
      };
      expected.forEach((symbol, frets) {
        final chord = Chord(
          root: Note.tryParse(symbol.substring(0, 1))!,
          quality: symbol.endsWith('m')
              ? ChordQuality.minor
              : ChordQuality.major,
        );
        expect(
          ChordEngine.voicingsFor(chord).first.fretString,
          frets,
          reason: '$symbol should open with $frets',
        );
      });
    });

    test('F and B are barre chords, and the barre is described', () {
      // PRD.md §11 lists F and B among the free chords, and neither has an
      // open form — the movable shapes have to cover them.
      final f = ChordEngine.voicingsFor(
        _chord('F', ChordQuality.major),
      ).first;
      expect(f.fretString, '133211');
      expect(f.barre, isNotNull);
      expect(f.barre!.fret, 1);
      expect(f.barre!.lowString, 0);
      expect(f.barre!.highString, 5);
      expect(f.barre!.finger, 1);

      final b = ChordEngine.voicingsFor(
        _chord('B', ChordQuality.major),
      ).first;
      expect(b.barre, isNotNull);
      expect(b.barre!.fret, 2);
    });

    test('a shape at the nut becomes open strings, not a barre at fret 0', () {
      // The E-shape slid to base fret 0 IS the open E chord. If the barre
      // survived, the diagram would draw a finger across the nut.
      final e = ChordEngine.voicingsFor(_chord('E', ChordQuality.major));
      expect(e.first.barre, isNull);
      expect(e.first.openStrings, <int>[0, 4, 5]);
    });

    test('string states are recorded, not inferred from a fret number', () {
      final c = ChordEngine.voicingsFor(_chord('C', ChordQuality.major)).first;
      expect(c.mutedStrings, <int>[0], reason: 'the low E is not played');
      expect(c.openStrings, <int>[3, 5]);
      expect(c.strings[1].state, StringState.fretted);
      expect(c.strings[1].fret, 3);
      expect(c.strings[1].finger, 3);
      expect(c.strings[0].finger, isNull, reason: 'a muted string has none');
      expect(c.strings[3].finger, isNull, reason: 'an open string has none');
    });

    test('a movable shape names the fret its grid starts at', () {
      final g = ChordEngine.voicingsFor(_chord('G', ChordQuality.major));
      final barred = g.firstWhere((voicing) => voicing.barre != null);
      expect(barred.baseFret, barred.barre!.fret);
      expect(barred.baseFret, greaterThan(0));

      final open = g.first;
      expect(open.baseFret, 0, reason: 'an open chord draws the nut');
    });

    test('a barre counts as one finger however many strings it holds', () {
      final f = ChordEngine.voicingsFor(
        _chord('F', ChordQuality.major),
      ).first;
      expect(f.soundingStrings.length, 6);
      expect(f.fingerCount, 4);
    });
  });

  group('ChordEngine slash chords', () {
    test('the named bass is the lowest note that sounds', () {
      const chord = Chord(
        root: Note(NoteLetter.c),
        quality: ChordQuality.major,
        bass: Note(NoteLetter.g),
      );
      final voicings = ChordEngine.voicingsFor(chord);
      expect(voicings, isNotEmpty, reason: 'C/G must be playable');
      for (final voicing in voicings) {
        final lowest = voicing.soundingPitches(Tuning.standard).first;
        expect(lowest.midiNumber % 12, const Note(NoteLetter.g).pitchClass);
      }
    });

    test('a bass outside the chord is understood, not rewritten', () {
      // C/D is not an inversion — the D is an added tone, and the chord knows
      // the difference even though no curated shape plays it.
      const chord = Chord(
        root: Note(NoteLetter.c),
        quality: ChordQuality.major,
        bass: Note(NoteLetter.d),
      );
      expect(chord.bassIsChordTone, isFalse);
      expect(chord.pitchClasses, contains(const Note(NoteLetter.d).pitchClass));
      expect(chord.symbol, 'C/D');
    });

    test('a slash chord with no shape returns nothing rather than a lie', () {
      // CLAUDE.md §47 — the empty state is honest; a voicing whose bass is
      // simply the wrong note is not.
      const chord = Chord(
        root: Note(NoteLetter.c),
        quality: ChordQuality.major,
        bass: Note(NoteLetter.d),
      );
      expect(ChordEngine.voicingsFor(chord), isEmpty);
    });

    test('the curated slash chords all resolve to a playable shape', () {
      const expected = <String, String>{
        'C/G': '332010',
        'C/E': '032010',
        'D/F#': '200232',
        'G/B': 'x20003',
        'Am/G': '302210',
        'F/C': 'x33211',
        'Em/B': 'x22000',
        'D/A': 'x00232',
      };
      for (final slash in slashVoicings) {
        final chord = Chord(
          root: slash.root,
          quality: slash.quality,
          bass: slash.bass,
        );
        final voicings = ChordEngine.voicingsFor(chord);
        expect(voicings, isNotEmpty, reason: '${chord.symbol} has no shape');
        expect(voicings.first.fretString, expected[chord.symbol]);
      }
    });
  });

  group('voicing library', () {
    test('no curated open voicing duplicates another', () {
      final seen = <String>{};
      for (final open in openVoicings) {
        final key =
            '${open.root.name}|${open.quality.slug}|'
            '${open.frets.join(",")}';
        expect(seen.add(key), isTrue, reason: 'duplicate $key');
      }
    });

    test('every quality is reachable by at least one movable shape', () {
      // Five quality/family combinations have no playable shape. That is fine
      // as long as the other family covers the quality on every root.
      for (final quality in ChordQuality.values) {
        expect(
          movableShapes.any((shape) => shape.quality == quality),
          isTrue,
          reason: '${quality.slug} has no movable shape at all',
        );
      }
    });

    test('a movable shape puts its root string at the base fret', () {
      for (final shape in movableShapes) {
        expect(
          shape.offsets[shape.rootString],
          0,
          reason: '${shape.name} ${shape.quality.slug} is misaligned',
        );
      }
    });
  });
}
