import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/features/metronome/domain/metronome_thresholds.dart';
import 'package:l_key/features/metronome/domain/tap_tempo.dart';

/// Taps [count] times, [millis] apart, and returns the last result.
///
/// Time is handed in rather than measured, which is the whole reason these
/// assertions can be exact.
TapTempoResult _tapEvenly(
  TapTempo tempo, {
  required int count,
  required int millis,
  int fromMs = 0,
}) {
  late TapTempoResult result;
  for (var i = 0; i < count; i++) {
    result = tempo.tap(Duration(milliseconds: fromMs + i * millis));
  }
  return result;
}

void main() {
  group('TapTempo arithmetic', () {
    test('evenly spaced taps give exactly the tempo they describe', () {
      // PRD.md §16 lists tap tempo as a free capability, and the whole point
      // of it is that it lands on the tempo the player meant.
      for (final (millis, bpm) in <(int, int)>[
        (2000, 30),
        (1000, 60),
        (750, 80),
        (500, 120),
        (400, 150),
        (250, 240),
      ]) {
        final result = _tapEvenly(TapTempo(), count: 6, millis: millis);
        expect(
          result.bpm,
          bpm,
          reason: '$millis ms between taps is $bpm BPM',
        );
      }
    });

    test('it rounds half up rather than truncating', () {
      // 505 ms is 118.81 BPM and must not become 118; 501 ms is 119.76 and
      // must not become 119. Truncation would make every tapped tempo read
      // slightly slow, consistently, which is the kind of bias nobody
      // notices and everybody feels.
      expect(_tapEvenly(TapTempo(), count: 6, millis: 505).bpm, 119);
      expect(_tapEvenly(TapTempo(), count: 6, millis: 501).bpm, 120);
    });

    test('the same taps always give the same tempo', () {
      // Integer arithmetic throughout, so no platform's floating point can
      // move the answer (docs/adr/0016).
      final answers = <int?>{
        for (var run = 0; run < 500; run++)
          _tapEvenly(TapTempo(), count: 6, millis: 437).bpm,
      };
      expect(answers, hasLength(1));
    });

    test('two taps are enough, one is not', () {
      final tempo = TapTempo();

      final first = tempo.tap(Duration.zero);
      expect(first.bpm, isNull, reason: 'one tap is not a tempo');
      expect(first.tapCount, 1);
      expect(first.isNewPhrase, isTrue);

      final second = tempo.tap(const Duration(milliseconds: 500));
      expect(second.bpm, 120);
      expect(second.tapCount, 2);
      expect(second.isNewPhrase, isFalse);
    });
  });

  group('TapTempo intervals', () {
    test('a fumbled double tap does not move the tempo', () {
      // A finger that bounces produces one interval near half the others.
      // Rejecting it is the difference between a usable control and one that
      // punishes an unsteady hand.
      final tempo = TapTempo();
      _tapEvenly(tempo, count: 5, millis: 500);
      expect(tempo.tap(const Duration(milliseconds: 2100)).bpm, 120);
      expect(tempo.tap(const Duration(milliseconds: 2600)).bpm, 120);
    });

    test('a missed tap does not halve the tempo', () {
      // One interval near twice the median: the player was late, not slower.
      final tempo = TapTempo();
      _tapEvenly(tempo, count: 5, millis: 500);
      expect(tempo.tap(const Duration(milliseconds: 3000)).bpm, 120);
    });

    test('ordinary unevenness is kept, not rejected', () {
      // A few per cent of jitter is how humans tap, and averaging it is the
      // point. 500, 500, 500, 520 averages to 505 -> 119.
      final tempo = TapTempo()
        ..tap(Duration.zero)
        ..tap(const Duration(milliseconds: 500))
        ..tap(const Duration(milliseconds: 1000))
        ..tap(const Duration(milliseconds: 1500));
      expect(tempo.tap(const Duration(milliseconds: 2020)).bpm, 119);
    });

    test('a long gap starts a new phrase rather than an absurd tempo', () {
      // The gap threshold is one beat at 30 BPM plus a quarter, so anything
      // slower than the product's slowest tempo cannot be a tempo at all.
      final tempo = TapTempo();
      _tapEvenly(tempo, count: 4, millis: 500);

      final after = tempo.tap(const Duration(milliseconds: 6000));
      expect(after.isNewPhrase, isTrue);
      expect(after.bpm, isNull);
      expect(after.tapCount, 1);

      // And the old phrase does not contaminate the new one.
      expect(tempo.tap(const Duration(milliseconds: 7000)).bpm, 60);
    });

    test(
      'a timestamp that goes backwards resets instead of going negative',
      () {
        // The caller owns the stopwatch, so it can be restarted underneath us.
        final tempo = TapTempo();
        _tapEvenly(tempo, count: 4, millis: 500);

        final rewound = tempo.tap(const Duration(milliseconds: 10));
        expect(rewound.isNewPhrase, isTrue);
        expect(rewound.bpm, isNull);
      },
    );

    test('it follows a player who changes tempo', () {
      // The window is five intervals, so a deliberate change has to win
      // within a bar or two or the control feels broken.
      final tempo = TapTempo();
      _tapEvenly(tempo, count: 6, millis: 500);
      expect(tempo.tap(const Duration(milliseconds: 3000)).bpm, 120);

      final result = _tapEvenly(
        tempo,
        count: 8,
        millis: 1000,
        fromMs: 4000,
      );
      expect(result.bpm, 60);
    });

    test('a reset forgets the phrase', () {
      final tempo = TapTempo();
      _tapEvenly(tempo, count: 4, millis: 500);
      tempo.reset();
      expect(tempo.tapCount, 0);
      expect(tempo.tap(const Duration(milliseconds: 9000)).bpm, isNull);
    });
  });

  group('TapTempo bounds', () {
    test('tapping faster than the metronome plays clamps to the maximum', () {
      // 100 ms is 600 BPM. The metronome stops at 240, and tap tempo must not
      // be a way round a limit the rest of the app enforces.
      expect(_tapEvenly(TapTempo(), count: 6, millis: 100).bpm, 240);
    });

    test('tapping slower than the metronome plays clamps to the minimum', () {
      // 2400 ms is 25 BPM, and still inside the phrase gap, so it produces a
      // tempo — clamped to 30 rather than refused.
      expect(_tapEvenly(TapTempo(), count: 6, millis: 2400).bpm, 30);
    });

    test("the bounds are the metronome's own, not this class's idea", () {
      // Configurable, so the class is complete on its own, and configured
      // with the settings' range so a tapped tempo is always one the
      // settings will accept.
      final narrow = TapTempo(minimumBpm: 100, maximumBpm: 110);
      expect(_tapEvenly(narrow, count: 6, millis: 500).bpm, 110);
    });

    test('an extreme threshold set proves which number does the work', () {
      // TunerThresholds' contract, applied here: a test can hand in a
      // deliberately odd set and see the behaviour follow it.
      final patient = TapTempo(
        thresholds: const MetronomeThresholds(
          tapResetGap: Duration(seconds: 30),
        ),
      );
      final result = patient.tap(Duration.zero);
      expect(result.isNewPhrase, isTrue);
      // A ten-second gap would end a default phrase; here it does not, and
      // the resulting 6 BPM is clamped to the floor.
      expect(patient.tap(const Duration(seconds: 10)).bpm, 30);
    });
  });
}
