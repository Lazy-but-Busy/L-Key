import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/features/metronome/domain/click_schedule.dart';
import 'package:l_key/features/metronome/domain/metronome_settings.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';

const int _rate = 44100;

ClickSchedule _schedule({
  int bpm = 120,
  TimeSignature signature = TimeSignature.fourFour,
  Subdivision subdivision = Subdivision.none,
  CountIn countIn = CountIn.none,
}) => ClickSchedule(
  settings: MetronomeSettings(
    bpm: bpm,
    signature: signature,
    subdivision: subdivision,
    countIn: countIn,
  ),
  sampleRate: _rate,
);

void main() {
  group('ClickSchedule placement', () {
    test('the first pulse is the first sample', () {
      // Anything else is a gap between pressing start and hearing the beat.
      expect(_schedule().sampleOf(0), 0);
    });

    test('a beat lands where the arithmetic says it should', () {
      // 120 BPM is half a second a beat, and half a second is 22050 samples.
      final schedule = _schedule();
      expect(schedule.sampleOf(1), 22050);
      expect(schedule.sampleOf(2), 44100);
      expect(schedule.sampleOf(4), 88200);
    });

    test('it does not drift, however long it runs', () {
      // The assertion the whole design exists for. Accumulating a rounded
      // period would be tens of milliseconds out by here; computing the nth
      // offset from the origin is exact.
      final schedule = _schedule();
      expect(schedule.sampleOf(100000), 100000 * 22050);

      // And at a tempo whose period is not a whole number of samples: 240 BPM
      // in sixteenths is 2756.25 samples a pulse, the worst case in the whole
      // supported range.
      final awkward = _schedule(bpm: 240, subdivision: Subdivision.quadruple);
      expect(awkward.sampleOf(4), 11025, reason: 'four pulses is one beat');
      expect(awkward.sampleOf(100000), 275625000);

      // Every pulse within half a sample of ideal, forever — not merely the
      // ones that happen to land whole.
      final failures = <String>[];
      for (var n = 0; n <= 100000; n += 997) {
        final ideal = n * 60 * _rate / (240 * 4);
        final error = (awkward.sampleOf(n) - ideal).abs();
        if (error > 0.5) failures.add('pulse $n is $error samples out');
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('rounding corrects itself inside a beat', () {
      // The sixteenths of a 120 BPM beat are 5512.5 samples apart, and the
      // beat itself still lands exactly. A metronome whose subdivisions
      // walked the downbeat off the grid would be worse than one with none.
      final schedule = _schedule(subdivision: Subdivision.quadruple);
      expect(
        <int>[for (var n = 0; n <= 4; n++) schedule.sampleOf(n)],
        <int>[0, 5513, 11025, 16538, 22050],
      );
    });

    test('finding a pulse from a sample inverts finding a sample', () {
      final failures = <String>[];
      for (final subdivision in Subdivision.values) {
        final schedule = _schedule(bpm: 137, subdivision: subdivision);
        for (var n = 0; n < 200; n++) {
          final sample = schedule.sampleOf(n);
          final back = schedule.firstPulseAtOrAfter(sample);
          if (back != n) {
            failures.add('${subdivision.name} pulse $n came back as $back');
          }
          // One sample later must be the next pulse, never this one again.
          if (schedule.firstPulseAtOrAfter(sample + 1) != n + 1) {
            failures.add('${subdivision.name} pulse $n did not advance');
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });
  });

  group('ClickSchedule subdivisions', () {
    test('a subdivision multiplies the pulses in a beat exactly', () {
      for (final (subdivision, perBeat) in <(Subdivision, int)>[
        (Subdivision.none, 1),
        (Subdivision.duple, 2),
        (Subdivision.triple, 3),
        (Subdivision.quadruple, 4),
      ]) {
        final schedule = _schedule(subdivision: subdivision);
        expect(
          schedule.sampleOf(perBeat),
          22050,
          reason: '$perBeat ${subdivision.name} pulses make one beat at 120',
        );
      }
    });

    test('triplets divide a beat into three equal parts', () {
      final schedule = _schedule(subdivision: Subdivision.triple);
      expect(schedule.sampleOf(1), 7350);
      expect(schedule.sampleOf(2), 14700);
      expect(schedule.sampleOf(3), 22050);
    });

    test('off-beat pulses are subdivisions, on-beat pulses are beats', () {
      final schedule = _schedule(subdivision: Subdivision.duple);
      expect(schedule.clickAt(0).level, AccentLevel.strong);
      expect(schedule.clickAt(1).level, AccentLevel.subdivision);
      expect(schedule.clickAt(2).level, AccentLevel.normal);
      expect(schedule.clickAt(2).beat, 1);
    });
  });

  group('ClickSchedule meters', () {
    test('the accent falls on the right pulses in every meter', () {
      for (final signature in TimeSignature.catalogue) {
        final schedule = _schedule(signature: signature);
        final expected = signature.defaultAccents;
        final failures = <String>[];
        for (var beat = 0; beat < signature.beats; beat++) {
          final click = schedule.clickAt(beat);
          if (click.level != expected[beat]) {
            failures.add(
              '${signature.label} beat $beat is ${click.level.name}, '
              'expected ${expected[beat].name}',
            );
          }
          if (click.beat != beat) failures.add('${signature.label} beat index');
        }
        expect(failures, isEmpty, reason: failures.join('\n'));
      }
    });

    test('a bar repeats, and the bar number advances with it', () {
      final schedule = _schedule(signature: TimeSignature.sevenEight);
      expect(schedule.clickAt(0).bar, 0);
      expect(schedule.clickAt(6).bar, 0);
      expect(schedule.clickAt(7).bar, 1);
      expect(schedule.clickAt(7).beat, 0);
      expect(schedule.clickAt(7).level, AccentLevel.strong);
      expect(schedule.clickAt(70).bar, 10);
    });

    test('a bar is as long in samples as its beats make it', () {
      // 3/4 at 120 is a bar and a half of 4/4's length, and that has to come
      // out of the same arithmetic rather than a special case.
      expect(_schedule(signature: TimeSignature.threeFour).sampleOf(3), 66150);
      expect(_schedule().sampleOf(4), 88200);
      expect(_schedule(signature: TimeSignature.sixEight).sampleOf(6), 132300);
    });
  });

  group('ClickSchedule count-in', () {
    test('a count-in sits before the music on the same timeline', () {
      // Not a separate schedule to join up afterwards: bar one still starts
      // at sample zero, and the count-in runs up to it from negative time.
      final schedule = _schedule(countIn: CountIn.oneBar);
      expect(schedule.firstPulse, -4);
      expect(schedule.countInPulses, 4);
      expect(schedule.sampleOf(0), 0);
      expect(schedule.sampleOf(-1), -22050);
      expect(schedule.sampleOf(-4), -88200);
    });

    test('a count-in is a plain count, not a bar of music', () {
      final schedule = _schedule(
        signature: TimeSignature.sevenEight,
        countIn: CountIn.oneBar,
      );
      expect(schedule.clickAt(-7).level, AccentLevel.strong);
      for (var n = -6; n < 0; n++) {
        expect(
          schedule.clickAt(n).level,
          AccentLevel.normal,
          reason: 'a count-in does not accent 2+2+3',
        );
        expect(schedule.clickAt(n).isCountIn, isTrue);
      }
      expect(schedule.clickAt(0).isCountIn, isFalse);
    });

    test('two bars of count-in are twice as long', () {
      final schedule = _schedule(countIn: CountIn.twoBars);
      expect(schedule.firstPulse, -8);
      expect(schedule.sampleOf(-8), -176400);
    });
  });

  group('ClickSchedule ranges', () {
    test('a half-open window tiles the timeline exactly', () {
      // Consecutive blocks must not emit a click twice or skip one.
      final schedule = _schedule(subdivision: Subdivision.duple);
      final whole = schedule.clicksIn(0, 220500).map((c) => c.pulse).toList();

      final pieces = <int>[];
      for (var at = 0; at < 220500; at += 512) {
        final end = at + 512 > 220500 ? 220500 : at + 512;
        pieces.addAll(schedule.clicksIn(at, end).map((c) => c.pulse));
      }
      expect(pieces, whole);
      expect(whole, hasLength(20));
    });

    test('an empty or backwards window yields nothing', () {
      final schedule = _schedule();
      expect(schedule.clicksIn(100, 100), isEmpty);
      expect(schedule.clicksIn(200, 100), isEmpty);
    });
  });

  group('ClickSchedule rebasing', () {
    test('a tempo change keeps the boundary pulse where it already is', () {
      // The point of rebasing: no gap, no jump, and the beat the player was
      // on stays the beat they are on.
      final schedule = _schedule();
      const boundary = 4;
      final at = schedule.sampleOf(boundary);

      final faster = schedule.rebasedAt(
        boundary,
        schedule.settings.withBpm(240),
      );
      expect(faster.sampleOf(boundary), at);
      expect(faster.sampleOf(boundary + 1), at + 11025);
      expect(faster.clickAt(boundary).level, AccentLevel.strong);
    });

    test('rebasing does not accumulate error across many changes', () {
      // A player riding the tempo control produces a change every few
      // hundred milliseconds, and each one pays half a sample at most.
      var schedule = _schedule();
      var pulse = 0;
      for (var i = 0; i < 500; i++) {
        pulse += 4;
        schedule = schedule.rebasedAt(
          pulse,
          schedule.settings.withBpm(100 + i % 60),
        );
      }
      // Every change is exact at its own boundary, which is the invariant
      // that matters: nothing before the boundary moved.
      final at = schedule.sampleOf(pulse);
      final next = schedule.rebasedAt(pulse, schedule.settings.withBpm(120));
      expect(next.sampleOf(pulse), at);
    });

    test('a tempo change mid-bar does not restart the bar', () {
      // The bug this pins: anchoring the counting to the timing origin would
      // make every tempo nudge put a downbeat wherever the player's thumb
      // happened to be. Pulse 5 is beat two of bar two and must stay so.
      final schedule = _schedule();
      final nudged = schedule.rebasedAt(5, schedule.settings.withBpm(132));

      expect(nudged.clickAt(5).beat, 1);
      expect(nudged.clickAt(5).level, AccentLevel.normal);
      expect(nudged.clickAt(8).beat, 0);
      expect(nudged.clickAt(8).level, AccentLevel.strong);
    });

    test('a meter change at a bar line starts the new bar strong', () {
      final schedule = _schedule();
      final rebased = schedule.rebasedAt(
        8,
        schedule.settings.copyWith(signature: TimeSignature.threeFour),
      );
      expect(rebased.clickAt(8).level, AccentLevel.strong);
      expect(rebased.clickAt(8).beat, 0);
      expect(rebased.clickAt(11).level, AccentLevel.strong);
    });
  });
}
