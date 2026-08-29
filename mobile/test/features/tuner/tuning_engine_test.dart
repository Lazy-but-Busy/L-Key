import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/pitch.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/tuner/domain/tuner_reading.dart';
import 'package:l_key/features/tuner/domain/tuning_engine.dart';
import 'package:l_key/features/tuner/domain/tuning_target.dart';

TuningEngine _engineFor(Tuning tuning, {double referenceHz = 440}) =>
    TuningEngine(
      selector: StringTargetSelector(tuning),
      referenceHz: referenceHz,
    );

/// A frequency a known number of cents from [pitch].
double _offBy(Pitch pitch, double cents, {double referenceHz = 440}) =>
    pitch.frequencyHz(referenceHz: referenceHz) *
    math.pow(2, cents / 1200).toDouble();

void main() {
  group('TuningEngine against every tuning', () {
    test('an open string played exactly right reads exactly right', () {
      // PRD.md §10 — fourteen tunings, every string. This is the assertion
      // that the whole catalogue is actually tunable.
      final failures = <String>[];
      for (final tuning in Tuning.catalogue) {
        final engine = _engineFor(tuning);
        for (var i = 0; i < tuning.stringCount; i++) {
          final pitch = tuning.openStrings[i];
          final reading = engine.read(
            frequencyHz: pitch.frequencyHz(),
            confidence: 1,
          );
          if (reading == null) {
            failures.add('${tuning.name} string $i produced no reading');
            continue;
          }
          if (reading.cents.abs() > 0.001) {
            failures.add('${tuning.name} ${pitch.name}: ${reading.cents}');
          }
          if (!reading.isInTune) {
            failures.add('${tuning.name} ${pitch.name} was not in tune');
          }
          if (reading.targetStringIndex != i) {
            failures.add(
              '${tuning.name} ${pitch.name} selected string '
              '${reading.targetStringIndex}',
            );
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('a string is named the way the tuning writes it', () {
      // docs/adr/0009's payoff. Half-step-down is spelled with flats because
      // that is how players say it, so its lowest string must read Eb2 and
      // never D#2 — which a tuner built on pitch-class numbers cannot do.
      final reading = _engineFor(Tuning.halfStepDown).read(
        frequencyHz: Tuning.halfStepDown.openStrings.first.frequencyHz(),
        confidence: 1,
      );
      expect(reading!.targetNote.name, 'Eb2');
      expect(reading.targetNote.note.displayName, 'E♭');

      final sharp = _engineFor(Tuning.dropB).read(
        frequencyHz: Tuning.dropB.openStrings[1].frequencyHz(),
        confidence: 1,
      );
      expect(sharp!.targetNote.name, 'F#2');
    });

    test('the reading carries exactly what PRD.md §10 asks for', () {
      final e2 = Tuning.standard.openStrings.first;
      final reading = _engineFor(Tuning.standard).read(
        frequencyHz: _offBy(e2, -12),
        confidence: 0.8,
      );

      expect(reading!.detectedNote, e2);
      expect(reading.frequencyHz, closeTo(_offBy(e2, -12), 0.001));
      expect(reading.targetNote, e2);
      expect(reading.targetFrequencyHz, closeTo(82.407, 0.01));
      expect(reading.cents, closeTo(-12, 0.01));
      expect(reading.confidence, 0.8);
      expect(reading.isInTune, isFalse);
    });
  });

  group('TuningEngine direction and tolerance', () {
    test('flat points left and sharp points right', () {
      // DESIGN.md §22.
      final engine = _engineFor(Tuning.standard);
      final a2 = Tuning.standard.openStrings[1];

      expect(
        engine.read(frequencyHz: _offBy(a2, -20), confidence: 1)!.direction,
        TuningDirection.flat,
      );
      expect(
        engine.read(frequencyHz: _offBy(a2, 20), confidence: 1)!.direction,
        TuningDirection.sharp,
      );
      expect(
        engine.read(frequencyHz: a2.frequencyHz(), confidence: 1)!.direction,
        TuningDirection.inTune,
      );
    });

    test('the tolerance boundary is inclusive, and three cents wide', () {
      final engine = _engineFor(Tuning.standard);
      final d3 = Tuning.standard.openStrings[2];

      expect(
        engine.read(frequencyHz: _offBy(d3, 2.99), confidence: 1)!.isInTune,
        isTrue,
      );
      expect(
        engine.read(frequencyHz: _offBy(d3, 3.01), confidence: 1)!.isInTune,
        isFalse,
      );
      expect(
        engine.read(frequencyHz: _offBy(d3, -3.01), confidence: 1)!.isInTune,
        isFalse,
      );
    });

    test('a wider tolerance is honoured', () {
      const engine = TuningEngine(
        selector: StringTargetSelector(Tuning.standard),
        toleranceCents: 10,
      );
      final g3 = Tuning.standard.openStrings[3];
      expect(
        engine.read(frequencyHz: _offBy(g3, 8), confidence: 1)!.isInTune,
        isTrue,
      );
    });
  });

  group('TuningEngine target selection', () {
    test('it follows whichever string is nearest', () {
      final engine = _engineFor(Tuning.standard);
      final failures = <String>[];
      for (var i = 0; i < Tuning.standard.stringCount; i++) {
        final reading = engine.read(
          frequencyHz: _offBy(Tuning.standard.openStrings[i], 15),
          confidence: 1,
        );
        if (reading!.targetStringIndex != i) {
          failures.add('string $i selected ${reading.targetStringIndex}');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('a note between two strings takes the nearer one', () {
      // Deliberately deterministic: the geometric mean of two strings is
      // equidistant in cents, and the lower index wins rather than whichever
      // the loop happened to reach first.
      final engine = _engineFor(Tuning.standard);
      final e2 = Tuning.standard.openStrings[0].frequencyHz();
      final a2 = Tuning.standard.openStrings[1].frequencyHz();

      expect(
        engine
            .read(frequencyHz: math.sqrt(e2 * a2) * 0.99, confidence: 1)!
            .targetStringIndex,
        0,
      );
      expect(
        engine
            .read(frequencyHz: math.sqrt(e2 * a2) * 1.01, confidence: 1)!
            .targetStringIndex,
        1,
      );
      expect(
        engine
            .read(frequencyHz: math.sqrt(e2 * a2), confidence: 1)!
            .targetStringIndex,
        0,
        reason: 'an exact tie must resolve the same way every time',
      );
    });

    test('a locked string stays locked, however far off the playing is', () {
      // Tuning an A up to an E is a real thing to do, and the tuner must not
      // quietly decide the player meant the A string.
      final engine = _engineFor(Tuning.standard);
      final reading = engine.read(
        frequencyHz: Tuning.standard.openStrings[5].frequencyHz(),
        confidence: 1,
        mode: const TargetMode.string(0),
      );

      expect(reading!.targetStringIndex, 0);
      expect(reading.targetNote.name, 'E2');
      expect(reading.cents, closeTo(2400, 0.01));
      expect(reading.isInTune, isFalse);
    });

    test('a locked reading still names what is actually sounding', () {
      // The needle says how far from E2 it is; the note has to say what the
      // player is really playing, or the screen contradicts their ears.
      final reading = _engineFor(Tuning.standard).read(
        frequencyHz: Tuning.standard.openStrings[5].frequencyHz(),
        confidence: 1,
        mode: const TargetMode.string(0),
      );
      expect(reading!.detectedNote.name, 'E4');
      expect(reading.targetNote.name, 'E2');
    });

    test('a string the tuning does not have produces no reading', () {
      expect(
        _engineFor(Tuning.standard).read(
          frequencyHz: 110,
          confidence: 1,
          mode: const TargetMode.string(9),
        ),
        isNull,
      );
      expect(
        _engineFor(Tuning.standard).read(
          frequencyHz: 110,
          confidence: 1,
          mode: const TargetMode.string(-1),
        ),
        isNull,
      );
    });
  });

  group('TuningEngine chromatic mode', () {
    test('it names the nearest note and highlights no string', () {
      // PRD.md §10.2. A chromatic tuner belongs to no tuning, so nothing is
      // selected and the string row shows nothing.
      const engine = TuningEngine(selector: ChromaticTargetSelector());
      final reading = engine.read(frequencyHz: 100, confidence: 1);

      expect(reading!.targetNote.name, 'G2');
      expect(reading.targetStringIndex, isNull);
      expect(reading.cents, closeTo(35.08, 0.1));
    });

    test('it can be asked to spell with flats', () {
      const sharps = TuningEngine(selector: ChromaticTargetSelector());
      const flats = TuningEngine(
        selector: ChromaticTargetSelector(preferFlats: true),
      );
      expect(
        sharps.read(frequencyHz: 277.18, confidence: 1)!.targetNote.name,
        'C#4',
      );
      expect(
        flats.read(frequencyHz: 277.18, confidence: 1)!.targetNote.name,
        'Db4',
      );
    });
  });

  group('TuningEngine reference pitch', () {
    test('a different reference moves every target', () {
      // PRD.md §10.2 makes the reference configurable, and it has to move the
      // whole grid rather than only the A.
      final engine = _engineFor(Tuning.standard, referenceHz: 432);
      final reading = engine.read(frequencyHz: 82.407, confidence: 1);

      expect(reading!.targetFrequencyHz, closeTo(80.907, 0.01));
      expect(reading.cents, closeTo(31.77, 0.1));
      expect(reading.isInTune, isFalse);
    });

    test('a string tuned to the new reference reads in tune', () {
      final engine = _engineFor(Tuning.standard, referenceHz: 432);
      final target = const Pitch(
        Note(NoteLetter.e),
        2,
      ).frequencyHz(referenceHz: 432);

      final reading = engine.read(frequencyHz: target, confidence: 1);
      expect(reading!.cents, closeTo(0, 0.001));
      expect(reading.isInTune, isTrue);
    });
  });

  group('TuningEngine refusals', () {
    test('a frequency nothing could have sounded produces no reading', () {
      final engine = _engineFor(Tuning.standard);
      expect(engine.read(frequencyHz: 0, confidence: 1), isNull);
      expect(engine.read(frequencyHz: -5, confidence: 1), isNull);
      expect(engine.read(frequencyHz: double.nan, confidence: 1), isNull);
      expect(engine.read(frequencyHz: double.infinity, confidence: 1), isNull);
    });

    test('confidence is clamped rather than trusted', () {
      final engine = _engineFor(Tuning.standard);
      expect(engine.read(frequencyHz: 110, confidence: 5)!.confidence, 1.0);
      expect(engine.read(frequencyHz: 110, confidence: -1)!.confidence, 0.0);
    });
  });
}
