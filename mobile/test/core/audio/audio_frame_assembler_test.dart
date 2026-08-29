import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/audio/audio_frame.dart';
import 'package:l_key/core/audio/audio_frame_assembler.dart';
import 'package:l_key/core/audio/biquad.dart';

import '../../helpers/waveforms.dart';

/// Everything the assembler emitted, copied out of the borrowed buffer.
List<({List<double> samples, Duration timestamp})> _collect(
  AudioFrameAssembler assembler,
  Uint8List pcm, {
  int chunkSize = 4096,
}) {
  final frames = <({List<double> samples, Duration timestamp})>[];
  for (var offset = 0; offset < pcm.lengthInBytes; offset += chunkSize) {
    final end = math.min(offset + chunkSize, pcm.lengthInBytes);
    assembler.addPcm16(
      Uint8List.sublistView(pcm, offset, end),
      (frame) => frames.add((
        samples: List<double>.of(frame.samples),
        timestamp: frame.timestamp,
      )),
    );
  }
  return frames;
}

void main() {
  group('AudioFrameAssembler decoding', () {
    test('it reads signed little-endian sixteen-bit samples', () {
      final assembler = AudioFrameAssembler(
        sampleRate: 8,
        windowSize: 4,
        hopSize: 4,
      );
      // 0x4000 = +half scale, 0xC000 = -half scale, 0x8000 = -full scale.
      final pcm = Uint8List.fromList(<int>[
        0x00, 0x40, //
        0x00, 0xC0, //
        0x00, 0x80, //
        0x00, 0x00, //
      ]);

      AudioFrame? seen;
      final captured = <double>[];
      assembler.addPcm16(pcm, (frame) {
        seen = frame;
        captured.addAll(frame.samples);
      });

      expect(seen, isNotNull);
      expect(captured[0], closeTo(0.5, 1e-9));
      expect(captured[1], closeTo(-0.5, 1e-9));
      expect(captured[2], closeTo(-1.0, 1e-9));
      expect(captured[3], closeTo(0.0, 1e-9));
    });

    test('a sample split across two chunks survives the boundary', () {
      // The bug that works on one device and not another: a platform chunk
      // can end between a sample's two bytes.
      const sampleRate = 8000;
      final signal = sine(
        frequencyHz: 200,
        sampleRate: sampleRate,
        length: 512,
      );
      final pcm = toPcm16(signal);

      final whole = _collect(
        AudioFrameAssembler(
          sampleRate: sampleRate,
          windowSize: 256,
          hopSize: 128,
        ),
        pcm,
      );
      final dribbled = _collect(
        AudioFrameAssembler(
          sampleRate: sampleRate,
          windowSize: 256,
          hopSize: 128,
        ),
        pcm,
        chunkSize: 1,
      );

      expect(dribbled.length, whole.length);
      final failures = <String>[];
      for (var f = 0; f < whole.length; f++) {
        for (var i = 0; i < whole[f].samples.length; i++) {
          if ((whole[f].samples[i] - dribbled[f].samples[i]).abs() > 1e-12) {
            failures.add('frame $f sample $i differs');
          }
        }
      }
      expect(failures, isEmpty, reason: failures.take(5).join('\n'));
    });

    test('a chunk that does not start on an even byte does not throw', () {
      // A platform-channel buffer carries no alignment guarantee, and an
      // Int16List view onto an odd offset throws. This is why the assembler
      // reads through ByteData.
      const sampleRate = 8000;
      final pcm = toPcm16(
        sine(frequencyHz: 200, sampleRate: sampleRate, length: 300),
      );
      final padded = Uint8List(pcm.lengthInBytes + 1)
        ..setRange(1, pcm.lengthInBytes + 1, pcm);
      final unaligned = Uint8List.sublistView(padded, 1);

      final assembler = AudioFrameAssembler(
        sampleRate: sampleRate,
        windowSize: 128,
        hopSize: 64,
      );
      expect(
        () => assembler.addPcm16(unaligned, (_) {}),
        returnsNormally,
      );
      expect(assembler.framesEmitted, greaterThan(0));
    });
  });

  group('AudioFrameAssembler framing', () {
    test('nothing is emitted until a whole window has arrived', () {
      final assembler = AudioFrameAssembler(
        sampleRate: 8000,
        windowSize: 256,
        hopSize: 64,
      );
      final short = toPcm16(Float64List(255));
      assembler.addPcm16(short, (_) {});
      expect(assembler.framesEmitted, 0);

      assembler.addPcm16(toPcm16(Float64List(1)), (_) {});
      expect(assembler.framesEmitted, 1);
    });

    test('one window arrives per hop once the buffer is primed', () {
      final assembler = AudioFrameAssembler(
        sampleRate: 8000,
        windowSize: 256,
        hopSize: 64,
      );
      // 256 primes the window, then one frame per 64 samples after it.
      _collect(assembler, toPcm16(Float64List(256 + 64 * 10)));
      expect(assembler.framesEmitted, 11);
    });

    test('consecutive windows overlap by everything but the hop', () {
      // 75% overlap is what makes forty-three analyses a second out of a
      // ninety-millisecond window.
      const windowSize = 256;
      const hopSize = 64;
      final frames = _collect(
        AudioFrameAssembler(
          sampleRate: 8000,
          windowSize: windowSize,
          hopSize: hopSize,
        ),
        toPcm16(sine(frequencyHz: 300, sampleRate: 8000, length: 1024)),
      );

      expect(frames.length, greaterThan(2));
      final failures = <String>[];
      for (var f = 1; f < frames.length; f++) {
        final previous = frames[f - 1].samples;
        final current = frames[f].samples;
        for (var i = 0; i < windowSize - hopSize; i++) {
          if ((previous[i + hopSize] - current[i]).abs() > 1e-12) {
            failures.add('frame $f is not the previous one shifted by a hop');
            break;
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('the sample buffer is reused rather than reallocated', () {
      // The ownership contract on AudioFrame.samples, asserted rather than
      // only documented. Dart cannot count allocations, so identity is the
      // available proof.
      final assembler = AudioFrameAssembler(
        sampleRate: 8000,
        windowSize: 128,
        hopSize: 64,
      );
      final buffers = <Float64List>[];
      assembler.addPcm16(
        toPcm16(Float64List(512)),
        (frame) => buffers.add(frame.samples),
      );

      expect(buffers.length, greaterThan(1));
      expect(identical(buffers.first, buffers.last), isTrue);
    });

    test('time is counted from samples, never read from a clock', () {
      // docs/adr/0012 — this is what lets a session test replay identically
      // on every machine.
      const sampleRate = 44100;
      const hopSize = 1024;
      final frames = _collect(
        AudioFrameAssembler(
          sampleRate: sampleRate,
          windowSize: 4096,
          hopSize: hopSize,
        ),
        toPcm16(Float64List(4096 + hopSize * 5)),
      );

      expect(frames.first.timestamp, Duration.zero);
      final failures = <String>[];
      for (var f = 0; f < frames.length; f++) {
        final expected = Duration(
          microseconds: f * hopSize * 1000000 ~/ sampleRate,
        );
        if (frames[f].timestamp != expected) {
          failures.add('frame $f: ${frames[f].timestamp} vs $expected');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('a reset forgets every buffered sample', () {
      final assembler =
          AudioFrameAssembler(
              sampleRate: 8000,
              windowSize: 128,
              hopSize: 64,
            )
            ..addPcm16(toPcm16(Float64List(100)), (_) {})
            ..reset()
            // Without the reset the 100 buffered samples plus 28 would emit.
            ..addPcm16(toPcm16(Float64List(100)), (_) {});
      expect(assembler.framesEmitted, 0);
    });

    test('an impossible window or hop fails loudly', () {
      expect(
        () => AudioFrameAssembler(sampleRate: 0, windowSize: 8, hopSize: 4),
        throwsArgumentError,
      );
      expect(
        () => AudioFrameAssembler(sampleRate: 8000, windowSize: 8, hopSize: 9),
        throwsArgumentError,
      );
      expect(
        () => AudioFrameAssembler(sampleRate: 8000, windowSize: 8, hopSize: 0),
        throwsArgumentError,
      );
    });
  });

  group('AudioFrameAssembler pre-filter', () {
    test('a high-pass keeps its memory across window boundaries', () {
      // The filter lives on the sample stream, not on a frame. Resetting it
      // per window would put a step at every boundary, which is exactly the
      // long-period structure the filter exists to remove.
      const sampleRate = 44100;
      final signal = withDcOffset(
        sine(frequencyHz: 220, sampleRate: sampleRate, length: 8192),
        0.3,
      );

      final frames = _collect(
        AudioFrameAssembler(
          sampleRate: sampleRate,
          windowSize: 2048,
          hopSize: 1024,
          preFilter: Biquad.highPass(
            sampleRate: sampleRate.toDouble(),
            cutoffHz: 25,
          ),
        ),
        toPcm16(signal),
      );

      // By the time the filter has settled the offset is gone, and no window
      // shows the jump a per-frame reset would leave.
      final settled = frames.last.samples;
      var mean = 0.0;
      for (final sample in settled) {
        mean += sample;
      }
      mean /= settled.length;
      expect(mean.abs(), lessThan(0.01));
    });
  });
}
