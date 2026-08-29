import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/interval.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/chords/domain/chord.dart';
import 'package:l_key/features/chords/domain/chord_analyzer.dart';
import 'package:l_key/features/chords/domain/chord_engine.dart';
import 'package:l_key/features/chords/domain/chord_voicing.dart';

/// Builds a shape from the way a chord chart writes one.
///
/// One character per string, **lowest-sounding first**, matching
/// `ChordVoicing.fretString`: `x` mutes, a digit frets, `0` is open. Frets
/// above nine are written as separate space-delimited fields.
ChordVoicing _shape(String frets) {
  final fields = frets.contains(' ')
      ? frets.split(' ')
      : frets.split('').toList();
  return ChordVoicing(
    strings: <FrettedString>[
      for (var index = 0; index < fields.length; index++)
        if (fields[index] == 'x')
          FrettedString.muted(index)
        else if (fields[index] == '0')
          FrettedString.open(index)
        else
          FrettedString.at(index, int.parse(fields[index])),
    ],
  );
}

/// The symbol the analyzer would print first.
String _name(String frets) =>
    ChordAnalyzer.analyze(_shape(frets)).best!.chord.symbol;

/// Every name the analyzer offers, best first.
List<String> _names(String frets) =>
    ChordAnalyzer.analyze(_shape(frets)).candidates
        .map((candidate) => candidate.chord.symbol)
        .toList();

void main() {
  group('ChordAnalyzer names the common shapes', () {
    test('the chords a beginner builds come back by name', () {
      // The four shapes §10 and §35 of the brief name explicitly.
      expect(_name('x32010'), 'C'); // C E G
      expect(_name('x02210'), 'Am'); // A C E
      expect(_name('320003'), 'G'); // G B D
      expect(_name('022100'), 'E');
    });

    test('every quality the brief names is identified from a real shape', () {
      // The shapes come from ChordEngine rather than from arithmetic done
      // here: a fingering nobody can play would prove nothing, and a fret
      // number miscounted in a test is indistinguishable from a bug.
      const cases = <(String, ChordQuality)>[
        ('C', ChordQuality.major),
        ('A', ChordQuality.minor),
        ('C', ChordQuality.dominantSeventh),
        ('C', ChordQuality.majorSeventh),
        ('A', ChordQuality.minorSeventh),
        ('D', ChordQuality.suspendedSecond),
        ('D', ChordQuality.suspendedFourth),
        ('C', ChordQuality.diminished),
        ('C', ChordQuality.augmented),
        ('C', ChordQuality.diminishedSeventh),
        ('B', ChordQuality.halfDiminished),
      ];
      for (final (rootName, quality) in cases) {
        final chord = Chord(root: Note.tryParse(rootName)!, quality: quality);
        final voicing = ChordEngine.voicingsFor(chord).first;
        final best = ChordAnalyzer.analyze(voicing).best;

        expect(
          best,
          isNotNull,
          reason: '${chord.symbol} (${voicing.fretString}) was named nothing',
        );
        expect(
          best!.chord.root,
          chord.root,
          reason:
              '${chord.symbol} (${voicing.fretString}) '
              'came back as ${best.chord.symbol}',
        );
        expect(
          best.chord.quality,
          quality,
          reason:
              '${chord.symbol} (${voicing.fretString}) '
              'came back as ${best.chord.symbol}',
        );
      }
    });
  });

  group('ChordAnalyzer separates the root from the bass', () {
    test('a chord over one of its own notes is a slash chord', () {
      // §13 of the brief: the lowest note is not the root. C/E contains
      // C E G, and the root is C however low the E sits.
      expect(_name('032010'), 'C/E');
      expect(_name('x20003'), 'G/B');
      expect(_name('2x0232'), 'D/F#');
    });

    test('the root stays the root, and the bass is a separate fact', () {
      final analysis = ChordAnalyzer.analyze(_shape('032010'));
      final chord = analysis.best!.chord;

      expect(chord.root, const Note(NoteLetter.c));
      expect(chord.quality, ChordQuality.major);
      expect(chord.bass, const Note(NoteLetter.e));
      expect(chord.isSlash, isTrue);
      expect(chord.bassIsChordTone, isTrue);
      expect(analysis.bass!.name, 'E2');
    });

    test('the same notes over their own root are not a slash chord', () {
      expect(ChordAnalyzer.analyze(_shape('x32010')).best!.chord.bass, isNull);
    });
  });

  group('ChordAnalyzer prefers the simple reading', () {
    test('C E G is C and nothing more elaborate', () {
      // §16 — an absurdly complicated name must never beat a simple valid
      // one. C E G has exactly one honest reading.
      expect(_names('x32010'), <String>['C']);
    });

    test('an exact name beats one that has to leave a tone out', () {
      // A C E is A minor exactly, and a C sixth chord missing its fifth.
      // Both are true; only one is what anyone would write.
      final names = _names('x02210');
      expect(names.first, 'Am');
      expect(names, contains('C6/A'));
      expect(
        names.indexOf('Am'),
        lessThan(names.indexOf('C6/A')),
        reason: 'an omission always costs more than it saves',
      );
    });

    test('a symmetrical chord has several true names, in a fixed order', () {
      // An augmented triad is three names for three sounds. The bass
      // decides which one leads; the rest stay available.
      final names = _names('x3211x');
      expect(names.first, 'Caug');
      expect(names.length, greaterThan(1));
      expect(names.skip(1), everyElement(contains('/')));
    });

    test('the lowest note decides between two equally exact readings', () {
      // C D G is C suspended second and G suspended fourth at once.
      expect(_name('x3001x'), 'Csus2');
      expect(_names('x3001x'), contains('Gsus4/C'));
    });
  });

  group('ChordAnalyzer refuses rather than invents', () {
    test('two notes are not enough for a chord the library can spell', () {
      // C and E alone. Every quality that contains both also needs a tone
      // that is not omittable, so v1 names nothing. When C(no5) arrives this
      // test is what will notice.
      expect(ChordAnalyzer.analyze(_shape('x32xxx')).candidates, isEmpty);
    });

    test('one note is a note, and says so', () {
      final analysis = ChordAnalyzer.analyze(_shape('x3xxxx'));
      expect(analysis.isSingleNote, isTrue);
      expect(analysis.isSilent, isFalse);
      expect(analysis.candidates, isEmpty);
      expect(analysis.pitches.single.name, 'C3');
    });

    test('a muted shape sounds nothing and claims nothing', () {
      final analysis = ChordAnalyzer.analyze(_shape('xxxxxx'));
      expect(analysis.isSilent, isTrue);
      expect(analysis.candidates, isEmpty);
      expect(analysis.bass, isNull);
    });

    test('a chord the library has no formula for is named nothing', () {
      // C D E F# G A B — every white note and one black. No quality in
      // core/music covers it, and the honest answer is silence.
      expect(ChordAnalyzer.analyze(_shape('012341')).candidates, isEmpty);
    });
  });

  group('ChordAnalyzer invariants', () {
    test('every name it offers really does contain every note played', () {
      // The property that makes the whole list trustworthy. If it ever
      // suggests a chord missing a note the player is sounding, the name is
      // simply wrong.
      const shapes = <String>[
        'x32010',
        'x02210',
        '320003',
        '032010',
        'x3211x',
        'x02010',
        '022100',
        'xx1212',
      ];
      for (final frets in shapes) {
        final voicing = _shape(frets);
        final played = voicing.soundingPitchClasses(Tuning.standard);
        for (final candidate in ChordAnalyzer.analyze(voicing).candidates) {
          final tones = candidate.chord.pitchClasses;
          expect(
            played.difference(tones),
            isEmpty,
            reason:
                '$frets: ${candidate.chord.symbol} does not contain every '
                'note the shape sounds',
          );
        }
      }
    });

    test('it only ever omits a tone the chord engine allows omitting', () {
      // One omission rule in the codebase, not two (docs/adr/0010).
      for (final frets in <String>['x02210', 'x32310', 'x32000']) {
        for (final candidate in ChordAnalyzer.analyze(
          _shape(frets),
        ).candidates) {
          expect(
            candidate.omitted,
            everyElement(
              isIn(candidate.chord.quality.omittableIntervals),
            ),
            reason: '$frets: ${candidate.chord.symbol} omits too much',
          );
          if (candidate.omitted.isNotEmpty) {
            expect(candidate.isExact, isFalse);
          }
        }
      }
    });

    test('the same shape analyses the same way every time', () {
      // Determinism is what keeps this arithmetic rather than a guess
      // (CLAUDE.md §17).
      for (final frets in <String>['x32010', 'x3211x', 'xx1212']) {
        expect(_names(frets), _names(frets));
      }
    });

    test('it never suggests more names than it says it will', () {
      // A diminished seventh is four names for four sounds, and every
      // inversion of it is the same set again.
      expect(
        ChordAnalyzer.analyze(_shape('xx1212')).candidates.length,
        lessThanOrEqualTo(ChordAnalyzer.maxCandidates),
      );
    });
  });

  group('ChordAnalyzer agrees with the chord engine', () {
    test('every voicing the engine draws, the analyzer can name', () {
      // The two directions of one engine. If the library can draw C♯m7b5 and
      // then cannot read its own diagram back, they have drifted apart.
      final failures = <String>[];
      for (final root in Note.spellings) {
        for (final quality in ChordQuality.values) {
          final chord = Chord(root: root, quality: quality);
          final voicings = ChordEngine.voicingsFor(chord);
          if (voicings.isEmpty) continue;
          for (final voicing in voicings) {
            final named = ChordAnalyzer.analyze(voicing).candidates.any(
              (candidate) =>
                  candidate.chord.root == chord.root &&
                  candidate.chord.quality == chord.quality,
            );
            if (!named) {
              failures.add(
                '${chord.symbol} ${voicing.fretString} came back as '
                '${_names(voicing.fretString)}',
              );
            }
          }
        }
      }
      expect(failures, isEmpty, reason: failures.take(20).join('\n'));
    });

    test("the degrees it labels are the chord engine's own", () {
      final voicing = _shape('x32010');
      final analysis = ChordAnalyzer.analyze(voicing);
      expect(
        analysis.degrees,
        ChordEngine.intervalsPerString(
          voicing,
          analysis.best!.chord,
          Tuning.standard,
        ),
      );
      expect(analysis.degrees[0], isNull, reason: 'the low E is muted');
      expect(analysis.degrees[1], Interval.unison);
    });

    test('the notes are spelled by the chord that was found', () {
      // A shape has no key to sit in, so the spelling is decided by which
      // reading costs fewer accidentals — and that lands on the one a chord
      // chart actually prints. D♭ major is five flats; C♯ major is seven
      // sharps and an E♯.
      final analysis = ChordAnalyzer.analyze(_shape('x43121'));
      expect(analysis.best!.chord.symbol, 'Db');
      expect(
        analysis.notes.whereType<Note>().map((note) => note.name).toSet(),
        <String>{'Db', 'F', 'Ab'},
      );
    });

    test('a black-key triad comes back spelled the way it is written', () {
      // The same rule across every black key. Both spellings stay in the
      // list; this is only about which one leads.
      // F♯ and G♭ are the one genuine coin flip: six sharps against six
      // flats, three accidentals either way. The declaration order in
      // Note.spellings settles it, which is arbitrary and deterministic
      // rather than musical — and both stay in the list.
      const expected = <String, String>{
        'x43121': 'Db',
        'x65343': 'Eb',
        'x98676': 'F#',
        'x 11 10 8 9 8': 'Ab',
        'x 13 12 10 11 10': 'Bb',
      };
      expected.forEach((frets, symbol) {
        expect(_name(frets), symbol, reason: '$frets read as ${_names(frets)}');
      });
    });

    test('the other spelling is still offered, never discarded', () {
      // C♯ major is a real chord and a real thing to be told, just not the
      // first thing (docs/adr/0009 — a spelling is information, not noise).
      expect(_names('x43121'), contains('C#'));
    });
  });
}
