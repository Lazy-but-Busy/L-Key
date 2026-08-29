import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/audio/audio_pipeline.dart';
import 'package:l_key/core/music/tuning.dart';

import '../../helpers/waveforms.dart';

const int _sampleRate = 44100;

List<AnalysisFrame> _run(AudioPipeline pipeline, Uint8List pcm) {
  final frames = <AnalysisFrame>[];
  pipeline.addPcm16(pcm, frames.add);
  return frames;
}

void main() {
  group('AudioPipeline', () {
    test('a synthesised string comes out the far end as a pitch', () {
      // The whole audio half of CLAUDE.md §14's chain, driven end to end
      // without a microphone: bytes in, a described and pitched window out.
      final pipeline = AudioPipeline(sampleRate: _sampleRate);
      final frames = _run(
        pipeline,
        toPcm16(
          sawtooth(
            frequencyHz: 110,
            sampleRate: _sampleRate,
            length: _sampleRate ~/ 2,
          ),
        ),
      );

      expect(frames, isNotEmpty);
      final settled = frames.last;
      expect(settled.pitch, isNotNull);
      expect(settled.pitch!.frequencyHz, closeTo(110, 1));
      expect(settled.features.rmsDbfs, greaterThan(-20));
      expect(settled.features.spectralFlatness, lessThan(0.2));
    });

    test('silence produces frames that describe silence', () {
      // Every window is still analysed; it simply has no pitch. The tuner
      // needs the level to decide it is silence, so the frame still arrives.
      final frames = _run(
        AudioPipeline(sampleRate: _sampleRate),
        toPcm16(Float64List(_sampleRate ~/ 4)),
      );

      expect(frames, isNotEmpty);
      expect(frames.every((f) => f.pitch == null), isTrue);
      expect(frames.last.features.rmsDbfs, lessThan(-100));
    });

    test('it produces about forty-three windows a second', () {
      // Fast enough that a median of five costs only a tenth of a second of
      // lag, and slow enough to leave the frame budget alone.
      //
      // Counted as the difference between one second and two, because the
      // very first window has to wait for a whole window's worth of samples
      // and would otherwise make the rate look low.
      int framesIn(int seconds) => _run(
        AudioPipeline(sampleRate: _sampleRate),
        toPcm16(
          sine(
            frequencyHz: 220,
            sampleRate: _sampleRate,
            length: _sampleRate * seconds,
          ),
        ),
      ).length;

      expect(
        AudioPipeline(sampleRate: _sampleRate).framesPerSecond,
        closeTo(43, 1),
      );
      expect(framesIn(2) - framesIn(1), closeTo(43, 1));
    });

    test('timestamps advance by exactly one hop', () {
      final pipeline = AudioPipeline(sampleRate: _sampleRate);
      final frames = _run(
        pipeline,
        toPcm16(
          sine(
            frequencyHz: 220,
            sampleRate: _sampleRate,
            length: _sampleRate ~/ 2,
          ),
        ),
      );

      final failures = <String>[];
      for (var i = 0; i < frames.length; i++) {
        final expected = Duration(
          microseconds: i * pipeline.hopSize * 1000000 ~/ _sampleRate,
        );
        if (frames[i].timestamp != expected) {
          failures.add('frame $i: ${frames[i].timestamp} vs $expected');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('a bass gets a longer window and a guitar does not pay for it', () {
      // A rule rather than a constant: below 55 Hz a window has to be twice
      // as long to hold enough periods to measure.
      final failures = <String>[];
      for (final tuning in Tuning.catalogue) {
        final lowest = tuning.openStrings.first.frequencyHz();
        final window = AudioPipeline.windowSizeFor(lowest);
        final expected = lowest < AudioPipeline.bassThresholdHz
            ? AudioPipeline.bassWindowSize
            : AudioPipeline.defaultWindowSize;
        if (window != expected) {
          failures.add('${tuning.name} at $lowest Hz got $window');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));

      expect(
        AudioPipeline.windowSizeFor(
          Tuning.bassFive.openStrings.first.frequencyHz(),
        ),
        AudioPipeline.bassWindowSize,
      );
      expect(
        AudioPipeline.windowSizeFor(
          Tuning.standard.openStrings.first.frequencyHz(),
        ),
        AudioPipeline.defaultWindowSize,
      );
    });

    test('a five-string bass low B is found with the longer window', () {
      // 30.87 Hz. The short window holds fewer than three periods of it.
      final pipeline = AudioPipeline(
        sampleRate: _sampleRate,
        windowSize: AudioPipeline.bassWindowSize,
      );
      final truth = Tuning.bassFive.openStrings.first.frequencyHz();
      final frames = _run(
        pipeline,
        toPcm16(
          sawtooth(
            frequencyHz: truth,
            sampleRate: _sampleRate,
            length: _sampleRate,
          ),
        ),
      );

      expect(frames.last.pitch, isNotNull);
      expect(frames.last.pitch!.frequencyHz, closeTo(truth, 0.5));
    });

    test('a reset clears the buffer and the filter alike', () {
      final pipeline = AudioPipeline(sampleRate: _sampleRate);
      final primed = _run(
        pipeline,
        toPcm16(
          sine(
            frequencyHz: 220,
            sampleRate: _sampleRate,
            length: 4000,
          ),
        ),
      );
      expect(primed, isEmpty);

      pipeline.reset();
      final afterReset = _run(pipeline, toPcm16(Float64List(4000)));
      expect(afterReset, isEmpty);
    });

    test('a granted rate other than the requested one is simply used', () {
      // The silent catastrophe, handled by construction: nothing in the chain
      // holds a rate of its own.
      const granted = 48000;
      final pipeline = AudioPipeline(sampleRate: granted);
      final truth = Tuning.standard.openStrings.first.frequencyHz();
      final frames = _run(
        pipeline,
        toPcm16(
          sawtooth(
            frequencyHz: truth,
            sampleRate: granted,
            length: granted ~/ 2,
          ),
        ),
      );

      expect(frames.last.pitch!.frequencyHz, closeTo(truth, 0.5));
    });
  });
}
