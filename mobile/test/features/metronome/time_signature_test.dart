import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/features/metronome/domain/metronome_settings.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';

void main() {
  group('TimeSignature', () {
    test('a bar holds the beats it says it does', () {
      // PRD.md §16 — 4/4 free, the rest labelled Premium and all of them
      // playable. The count is the thing every other calculation rests on.
      for (final (signature, beats) in <(TimeSignature, int)>[
        (TimeSignature.fourFour, 4),
        (TimeSignature.threeFour, 3),
        (TimeSignature.twoFour, 2),
        (TimeSignature.fiveFour, 5),
        (TimeSignature.sixEight, 6),
        (TimeSignature.sevenEight, 7),
        (TimeSignature.nineEight, 9),
        (TimeSignature.twelveEight, 12),
      ]) {
        expect(signature.beats, beats, reason: signature.label);
      }
    });

    test('the tempo counts the denominator, so 120 is always 120 clicks', () {
      // docs/adr/0016 — the alternative, counting 6/8 in dotted quarters, is
      // what a conductor reads. This one is chosen so "the number on screen
      // is the number of clicks you hear" has no exceptions, and the
      // grouping is carried by the accents instead. 6/8 therefore has six
      // beats, not two.
      expect(TimeSignature.sixEight.beats, 6);
      expect(TimeSignature.twelveEight.beats, 12);
    });

    test('every default pattern has one level per beat', () {
      // An accent list shorter than the bar is an index waiting to throw.
      final failures = <String>[];
      for (final signature in TimeSignature.catalogue) {
        if (signature.defaultAccents.length != signature.beats) {
          failures.add(
            '${signature.label} has ${signature.defaultAccents.length} '
            'levels for ${signature.beats} beats',
          );
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('bar one is always the strong beat', () {
      final failures = <String>[];
      for (final signature in TimeSignature.catalogue) {
        if (signature.defaultAccents.first != AccentLevel.strong) {
          failures.add('${signature.label} does not start strong');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('meters heard in groups mark the group heads', () {
      // A metronome that clicks seven even beats in 7/8 is not counting 7/8,
      // it is counting to seven.
      expect(TimeSignature.sevenEight.defaultAccents, <AccentLevel>[
        AccentLevel.strong,
        AccentLevel.normal,
        AccentLevel.accent,
        AccentLevel.normal,
        AccentLevel.accent,
        AccentLevel.normal,
        AccentLevel.normal,
      ], reason: '7/8 is 2+2+3');

      expect(TimeSignature.fiveFour.defaultAccents, <AccentLevel>[
        AccentLevel.strong,
        AccentLevel.normal,
        AccentLevel.normal,
        AccentLevel.accent,
        AccentLevel.normal,
      ], reason: '5/4 is 3+2');

      expect(TimeSignature.sixEight.defaultAccents, <AccentLevel>[
        AccentLevel.strong,
        AccentLevel.normal,
        AccentLevel.normal,
        AccentLevel.accent,
        AccentLevel.normal,
        AccentLevel.normal,
      ], reason: '6/8 is two groups of three');

      expect(TimeSignature.twelveEight.defaultAccents, <AccentLevel>[
        AccentLevel.strong,
        AccentLevel.normal,
        AccentLevel.normal,
        AccentLevel.accent,
        AccentLevel.normal,
        AccentLevel.normal,
        AccentLevel.accent,
        AccentLevel.normal,
        AccentLevel.normal,
        AccentLevel.accent,
        AccentLevel.normal,
        AccentLevel.normal,
      ], reason: '12/8 is four groups of three');
    });

    test('meters that divide evenly get no interior accents', () {
      expect(
        TimeSignature.fourFour.defaultAccents,
        <AccentLevel>[
          AccentLevel.strong,
          AccentLevel.normal,
          AccentLevel.normal,
          AccentLevel.normal,
        ],
      );
      expect(TimeSignature.threeFour.defaultAccents, <AccentLevel>[
        AccentLevel.strong,
        AccentLevel.normal,
        AccentLevel.normal,
      ]);
    });

    test('a meter no notation uses is refused', () {
      expect(() => TimeSignature(0, 4), throwsArgumentError);
      expect(() => TimeSignature(17, 4), throwsArgumentError);
      expect(() => TimeSignature(4, 3), throwsArgumentError);
      expect(() => TimeSignature(4, 16), throwsArgumentError);
    });

    test('a custom signature is a first-class one', () {
      // PRD.md §16 lists custom time signatures, so they are constructed the
      // same way and behave the same way as the catalogue entries.
      final elevenEight = TimeSignature(11, 8);
      expect(elevenEight.label, '11/8');
      expect(elevenEight.defaultAccents, hasLength(11));
      expect(elevenEight.defaultAccents.first, AccentLevel.strong);
    });

    test('two signatures written the same way are the same signature', () {
      expect(TimeSignature(4, 4), TimeSignature.fourFour);
      expect(TimeSignature(4, 4).hashCode, TimeSignature.fourFour.hashCode);
      expect(TimeSignature(3, 4), isNot(TimeSignature.fourFour));
    });
  });

  group('Subdivision', () {
    test('each subdivision multiplies the pulses in a beat', () {
      expect(Subdivision.none.pulsesPerBeat, 1);
      expect(Subdivision.duple.pulsesPerBeat, 2);
      expect(Subdivision.triple.pulsesPerBeat, 3);
      expect(Subdivision.quadruple.pulsesPerBeat, 4);
    });

    test('a bar holds beats times subdivision pulses', () {
      expect(TimeSignature.fourFour.pulsesPerBar(Subdivision.none), 4);
      expect(TimeSignature.fourFour.pulsesPerBar(Subdivision.duple), 8);
      expect(TimeSignature.fourFour.pulsesPerBar(Subdivision.triple), 12);
      expect(TimeSignature.fourFour.pulsesPerBar(Subdivision.quadruple), 16);
      expect(TimeSignature.sevenEight.pulsesPerBar(Subdivision.duple), 14);
      expect(TimeSignature.sixEight.pulsesPerBar(Subdivision.triple), 18);
    });
  });

  group('MetronomeSettings emphasis', () {
    test('on-beat pulses carry the beat, off-beat pulses are subdivisions', () {
      final settings = MetronomeSettings(subdivision: Subdivision.quadruple);

      expect(settings.accentAt(0), AccentLevel.strong);
      expect(settings.accentAt(1), AccentLevel.subdivision);
      expect(settings.accentAt(3), AccentLevel.subdivision);
      expect(settings.accentAt(4), AccentLevel.normal, reason: 'beat two');
      expect(settings.accentAt(8), AccentLevel.normal);
      expect(settings.accentAt(12), AccentLevel.normal);
    });

    test('the pattern repeats every bar', () {
      final settings = MetronomeSettings(subdivision: Subdivision.duple);
      expect(settings.pulsesPerBar, 8);
      expect(settings.accentAt(8), AccentLevel.strong);
      expect(settings.accentAt(9), AccentLevel.subdivision);
      expect(settings.accentAt(80), AccentLevel.strong);
    });

    test('a silenced beat silences its subdivisions with it', () {
      // A muted beat that still ticked three times would not be muted.
      final settings = MetronomeSettings(
        subdivision: Subdivision.triple,
      ).withAccentAt(1, AccentLevel.silent);

      expect(settings.accentAt(3), AccentLevel.silent);
      expect(settings.accentAt(4), AccentLevel.silent);
      expect(settings.accentAt(5), AccentLevel.silent);
      expect(settings.accentAt(6), AccentLevel.normal, reason: 'beat three');
    });

    test('7/8 in eighths still accents 2+2+3', () {
      final settings = MetronomeSettings(signature: TimeSignature.sevenEight);
      expect(settings.accentAt(0), AccentLevel.strong);
      expect(settings.accentAt(2), AccentLevel.accent);
      expect(settings.accentAt(4), AccentLevel.accent);
      expect(settings.accentAt(6), AccentLevel.normal);
    });
  });

  group('MetronomeSettings bounds', () {
    test('a tempo outside the range is clamped, never carried', () {
      // These values arrive from a preferences file as often as from a
      // button, and a preferences file is not a trusted input.
      expect(MetronomeSettings(bpm: 0).bpm, 30);
      expect(MetronomeSettings(bpm: -5).bpm, 30);
      expect(MetronomeSettings(bpm: 1000).bpm, 240);
      expect(MetronomeSettings().bpm, 120);
      expect(MetronomeSettings().withBpm(9999).bpm, 240);
      expect(MetronomeSettings().withBpm(1).bpm, 30);
    });

    test('an accent pattern that does not fit the bar is replaced', () {
      final settings = MetronomeSettings(
        signature: TimeSignature.threeFour,
        accents: const <AccentLevel>[AccentLevel.strong, AccentLevel.normal],
      );
      expect(settings.accents, TimeSignature.threeFour.defaultAccents);
    });

    test('changing the meter discards a pattern that no longer fits', () {
      // A five-beat pattern in a bar of three is not a preference, it is a
      // crash waiting to be indexed.
      final settings = MetronomeSettings(
        signature: TimeSignature.fiveFour,
      ).copyWith(signature: TimeSignature.threeFour);

      expect(settings.accents, hasLength(3));
      expect(settings.accents, TimeSignature.threeFour.defaultAccents);
    });

    test('changing anything else keeps the pattern the player set', () {
      final settings = MetronomeSettings()
          .withAccentAt(2, AccentLevel.silent)
          .copyWith(bpm: 90);
      expect(settings.accents[2], AccentLevel.silent);
      expect(settings.bpm, 90);
    });

    test('a subdivision level cannot be stored as a beat', () {
      // It is what the pulses between beats get, and storing it here would
      // make a downbeat return it.
      final settings = MetronomeSettings(
        accents: const <AccentLevel>[
          AccentLevel.subdivision,
          AccentLevel.subdivision,
          AccentLevel.normal,
          AccentLevel.normal,
        ],
      );
      expect(settings.accents[0], AccentLevel.normal);
      expect(settings.accentAt(0), AccentLevel.normal);
    });

    test('the accent list cannot be modified behind the settings back', () {
      final settings = MetronomeSettings();
      expect(
        () => settings.accents[0] = AccentLevel.silent,
        throwsUnsupportedError,
      );
    });

    test('two settings describing the same thing are equal', () {
      expect(MetronomeSettings(bpm: 90), MetronomeSettings(bpm: 90));
      expect(
        MetronomeSettings(bpm: 90).hashCode,
        MetronomeSettings(bpm: 90).hashCode,
      );
      expect(MetronomeSettings(bpm: 90), isNot(MetronomeSettings(bpm: 91)));
    });
  });
}
