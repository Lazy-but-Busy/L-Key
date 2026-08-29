import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/interval.dart';

void main() {
  group('Interval', () {
    test('spans the semitones the chord formulas assume', () {
      // Every one of these appears in a PRD.md §11 chord formula, so a wrong
      // entry here mis-spells a chord rather than merely failing a test.
      expect(Interval.unison.semitones, 0);
      expect(Interval.minorSecond.semitones, 1);
      expect(Interval.majorSecond.semitones, 2);
      expect(Interval.minorThird.semitones, 3);
      expect(Interval.majorThird.semitones, 4);
      expect(Interval.perfectFourth.semitones, 5);
      expect(Interval.diminishedFifth.semitones, 6);
      expect(Interval.perfectFifth.semitones, 7);
      expect(Interval.augmentedFifth.semitones, 8);
      expect(Interval.majorSixth.semitones, 9);
      expect(Interval.diminishedSeventh.semitones, 9);
      expect(Interval.minorSeventh.semitones, 10);
      expect(Interval.majorSeventh.semitones, 11);
      expect(Interval.majorNinth.semitones, 14);
    });

    test('a diminished seventh and a major sixth share a size, not a name', () {
      // This is the whole reason intervals are spelled rather than counted:
      // dim7 needs the seventh so its note lands on the seventh letter.
      expect(
        Interval.diminishedSeventh.semitones,
        Interval.majorSixth.semitones,
      );
      expect(Interval.diminishedSeventh, isNot(Interval.majorSixth));
      expect(Interval.diminishedSeventh.letterSteps, 6);
      expect(Interval.majorSixth.letterSteps, 5);
    });

    test('a ninth stays compound instead of folding into a second', () {
      expect(Interval.majorNinth.letterSteps, 8);
      expect(
        Interval.majorNinth.semitones - Interval.majorSecond.semitones,
        12,
      );
    });

    test('quality must belong to the interval family', () {
      expect(() => Interval(5, IntervalQuality.major), throwsArgumentError);
      expect(() => Interval(3, IntervalQuality.perfect), throwsArgumentError);
      expect(Interval(4, IntervalQuality.augmented).semitones, 6);
      expect(Interval(4, IntervalQuality.diminished).semitones, 4);
    });

    test('writes degree notation the way a formula does', () {
      expect(Interval.unison.degree, '1');
      expect(Interval.minorThird.degree, 'b3');
      expect(Interval.augmentedFifth.degree, '#5');
      expect(Interval.diminishedFifth.degree, 'b5');
      expect(Interval.diminishedSeventh.degree, 'bb7');
      expect(Interval.majorNinth.degree, '9');
    });

    test('parses degree notation back, including double flats', () {
      for (final degree in <String>['1', 'b3', '3', '#5', 'b5', 'bb7', '9']) {
        expect(Interval.tryParseDegree(degree)?.degree, degree);
      }
      expect(Interval.tryParseDegree('♭3'), Interval.minorThird);
      expect(Interval.tryParseDegree('♯5'), Interval.augmentedFifth);
    });

    test('unparseable input returns null rather than throwing', () {
      // CLAUDE.md §37 — this reads content and player input.
      for (final bad in <String>['', 'x', 'b', 'bb5', '#', '0']) {
        expect(
          Interval.tryParseDegree(bad),
          isNull,
          reason: '"$bad" is not a degree',
        );
      }
    });
  });
}
