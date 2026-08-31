import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/features/metronome/domain/click_schedule.dart';
import 'package:l_key/features/metronome/domain/click_sound.dart';
import 'package:l_key/features/metronome/domain/click_synth.dart';
import 'package:l_key/features/metronome/domain/click_track_renderer.dart';
import 'package:l_key/features/metronome/domain/metronome_settings.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';

const int _rate = 44100;

int _peakOf(Int16List samples) {
  var loudest = 0;
  for (final sample in samples) {
    final magnitude = sample.abs();
    if (magnitude > loudest) loudest = magnitude;
  }
  return loudest;
}

/// Where the sound starts in [samples], as the first sample past silence.
int _onsetOf(Int16List samples, {int threshold = 200}) {
  for (var i = 0; i < samples.length; i++) {
    if (samples[i].abs() > threshold) return i;
  }
  return -1;
}

/// The sample offsets of every click in [samples].
///
/// The mirror of `test/helpers/waveforms.dart` for the output side: it reads
/// the beat positions back out of rendered audio, so a test can assert where
/// the clicks actually are rather than trusting the schedule twice.
///
/// [gap] is a refractory period, longer than a click and shorter than the
/// fastest beat under test, so one click's decay is not counted as several.
List<int> _onsets(Int16List samples, {int threshold = 200, int gap = 5000}) {
  final found = <int>[];
  var last = -gap * 2;
  for (var i = 0; i < samples.length; i++) {
    if (samples[i].abs() > threshold && i - last >= gap) {
      found.add(i);
      last = i;
    }
  }
  return found;
}

/// Asserts that [samples] holds clicks at [expected], within the attack ramp.
///
/// The onsets are a few samples late by construction: the envelope opens over
/// a millisecond and a half rather than stepping, so the first samples of a
/// click sit under any sensible threshold.
void _expectOnsets(Int16List samples, List<int> expected) {
  final found = _onsets(samples);
  expect(found, hasLength(expected.length), reason: 'found $found');
  for (var i = 0; i < expected.length; i++) {
    expect(
      found[i],
      closeTo(expected[i], 80),
      reason: 'click $i is at ${found[i]}, expected near ${expected[i]}',
    );
  }
}

void main() {
  group('ClickSynth', () {
    test('the same voice always renders the same samples', () {
      // The seed is a field precisely so this holds. Without it a test could
      // only assert that a click was loud, which is not an assertion.
      final spec = ClickSound.woodblock.voiceFor(AccentLevel.strong)!;
      final first = ClickSynth.render(spec, _rate);
      final second = ClickSynth.render(spec, _rate);
      expect(first, second);
    });

    test('a click sounds, and then stops sounding', () {
      final samples = ClickSynth.render(
        ClickSound.woodblock.voiceFor(AccentLevel.normal)!,
        _rate,
      );
      expect(_peakOf(samples), greaterThan(1000));
      expect(
        samples.last,
        0,
        reason: 'a click that ends mid-swing pops on every beat',
      );
    });

    test('it decays rather than holding', () {
      // A metronome click that rang for a whole beat would be a drone.
      final samples = ClickSynth.render(
        ClickSound.woodblock.voiceFor(AccentLevel.strong)!,
        _rate,
      );
      final head = _peakOf(
        Int16List.sublistView(samples, 0, samples.length ~/ 4),
      );
      final tail = _peakOf(
        Int16List.sublistView(samples, 3 * samples.length ~/ 4),
      );
      expect(tail, lessThan(head ~/ 8));
    });

    test('it never clips', () {
      // Signed 16-bit wraps rather than saturating, so a click that overshot
      // would not be loud, it would be a burst of noise.
      final failures = <String>[];
      for (final sound in ClickSound.values) {
        for (final level in AccentLevel.values) {
          final spec = sound.voiceFor(level);
          if (spec == null) continue;
          final peak = _peakOf(ClickSynth.render(spec, _rate));
          if (peak > 32767) failures.add('${sound.name}/${level.name} clipped');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('it opens softly enough not to pop', () {
      // A hard step is a broadband transient that some converters clip.
      final samples = ClickSynth.render(
        ClickSound.woodblock.voiceFor(AccentLevel.strong)!,
        _rate,
      );
      expect(samples[0].abs(), lessThan(_peakOf(samples) ~/ 10));
    });

    test('an accent is louder than the beat it accents', () {
      // DESIGN.md §27 wants the accent stronger. In audio that is loudness,
      // and it has to survive the band-pass, which is why the synth
      // normalises to a measured peak rather than a predicted one.
      final failures = <String>[];
      for (final sound in ClickSound.values) {
        final strong = _peakOf(
          ClickSynth.render(sound.voiceFor(AccentLevel.strong)!, _rate),
        );
        final normal = _peakOf(
          ClickSynth.render(sound.voiceFor(AccentLevel.normal)!, _rate),
        );
        final subdivision = _peakOf(
          ClickSynth.render(sound.voiceFor(AccentLevel.subdivision)!, _rate),
        );
        if (strong <= normal) {
          failures.add('${sound.name}: accent is not louder');
        }
        if (normal <= subdivision) {
          failures.add('${sound.name}: subdivision is not quieter');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('a silent beat has no voice at all', () {
      for (final sound in ClickSound.values) {
        expect(sound.voiceFor(AccentLevel.silent), isNull);
      }
      expect(ClickSynth(sampleRate: _rate).voice(AccentLevel.silent), isNull);
    });

    test('changing the sound re-renders the voices', () {
      final synth = ClickSynth(sampleRate: _rate);
      final before = synth.voice(AccentLevel.strong);
      synth.sound = ClickSound.beep;
      expect(synth.sound, ClickSound.beep);
      expect(synth.voice(AccentLevel.strong), isNot(before));
    });
  });

  group('ClickTrackRenderer', () {
    test('a click lands on exactly the sample it was scheduled for', () {
      final synth = ClickSynth(sampleRate: _rate);
      final renderer = ClickTrackRenderer(synth: synth);
      final schedule = ClickSchedule(
        settings: MetronomeSettings(),
        sampleRate: _rate,
      );

      final out = Int16List(88200);
      renderer.render(out, schedule, 0, 88200);

      expect(_onsetOf(out), lessThan(80), reason: 'the first beat is first');
      _expectOnsets(out, <int>[0, 22050, 44100, 66150]);
    });

    test('rendering in blocks sounds the same as rendering all at once', () {
      // The property the whole design rests on: the block size is free to
      // change, and the renderer could move to an isolate, without a single
      // sample sounding different.
      final schedule = ClickSchedule(
        settings: MetronomeSettings(
          bpm: 137,
          signature: TimeSignature.sevenEight,
          subdivision: Subdivision.triple,
        ),
        sampleRate: _rate,
      );

      const total = 200000;
      final whole = Int16List(total);
      ClickTrackRenderer(
        synth: ClickSynth(sampleRate: _rate),
      ).render(whole, schedule, 0, total);

      for (final block in <int>[37, 512, 4096]) {
        final pieced = Int16List(total);
        final renderer = ClickTrackRenderer(
          synth: ClickSynth(sampleRate: _rate),
        );
        final scratch = Int16List(block);
        for (var at = 0; at < total; at += block) {
          final end = at + block > total ? total : at + block;
          renderer.render(scratch, schedule, at, end);
          pieced.setRange(at, end, scratch);
        }
        expect(
          pieced,
          whole,
          reason: 'a $block-sample block changed the audio',
        );
      }
    });

    test('a click straddling a block boundary keeps its tail', () {
      // The case that a naive renderer truncates: the click starts in the
      // previous block and must still be ringing at the start of this one.
      final schedule = ClickSchedule(
        settings: MetronomeSettings(),
        sampleRate: _rate,
      );
      final renderer = ClickTrackRenderer(synth: ClickSynth(sampleRate: _rate));

      // The beat at 22050 begins 50 samples before this window opens.
      final out = Int16List(512);
      renderer.render(out, schedule, 22100, 22612);
      expect(
        _peakOf(out),
        greaterThan(100),
        reason: "the tail of the previous block's click was cut off",
      );
    });

    test('a stretch with no clicks in it is silent', () {
      final schedule = ClickSchedule(
        settings: MetronomeSettings(),
        sampleRate: _rate,
      );
      final out = Int16List(512);
      ClickTrackRenderer(
        synth: ClickSynth(sampleRate: _rate),
      ).render(out, schedule, 15000, 15512);
      expect(_peakOf(out), 0);
    });

    test('a reused buffer never leaks the block before it', () {
      final schedule = ClickSchedule(
        settings: MetronomeSettings(),
        sampleRate: _rate,
      );
      final renderer = ClickTrackRenderer(synth: ClickSynth(sampleRate: _rate));
      final out = Int16List(512);

      renderer.render(out, schedule, 0, 512);
      expect(_peakOf(out), greaterThan(0));

      renderer.render(out, schedule, 15000, 15512);
      expect(_peakOf(out), 0, reason: 'the previous block was still in there');
    });

    test('a silenced beat renders silence where it would have sounded', () {
      final schedule = ClickSchedule(
        settings: MetronomeSettings().withAccentAt(1, AccentLevel.silent),
        sampleRate: _rate,
      );
      final out = Int16List(88200);
      ClickTrackRenderer(
        synth: ClickSynth(sampleRate: _rate),
      ).render(out, schedule, 0, 88200);

      _expectOnsets(out, <int>[0, 44100, 66150]);
    });

    test('the count-in sounds before the music does', () {
      final schedule = ClickSchedule(
        settings: MetronomeSettings(countIn: CountIn.oneBar),
        sampleRate: _rate,
      );
      final out = Int16List(88200);
      ClickTrackRenderer(
        synth: ClickSynth(sampleRate: _rate),
      ).render(out, schedule, -88200, 0);

      _expectOnsets(out, <int>[0, 22050, 44100, 66150]);
    });
  });
}
