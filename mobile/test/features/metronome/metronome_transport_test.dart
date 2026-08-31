import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/audio/audio_output.dart';
import 'package:l_key/core/audio/background_audio_service.dart';
import 'package:l_key/features/metronome/domain/metronome_settings.dart';
import 'package:l_key/features/metronome/domain/metronome_state.dart';
import 'package:l_key/features/metronome/domain/metronome_transport.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';

/// An output that records what it was fed and lets a test move the playhead.
///
/// The device's playback position is the metronome's only clock, so a test
/// that owns that position owns time — which is how these assertions are
/// exact without a speaker anywhere.
class _FakeAudioOutput implements AudioOutput {
  final List<Int16List> fed = <Int16List>[];
  final StreamController<AudioOutputStop> _stops =
      StreamController<AudioOutputStop>.broadcast();

  AudioOutputFeed? _onFeed;
  bool _running = false;
  int stopCount = 0;
  int disposeCount = 0;

  /// Frames the fake claims to have played.
  int played = 0;

  @override
  bool isAvailable = true;

  @override
  AudioOutputFormat? get format =>
      _running ? const AudioOutputFormat(sampleRate: 44100, channels: 1) : null;

  @override
  Stream<AudioOutputStop> get interruptions => _stops.stream;

  @override
  bool get isRunning => _running;

  @override
  Future<void> start(
    AudioOutputConfig config, {
    required AudioOutputFeed onFeed,
  }) async {
    _running = true;
    _onFeed = onFeed;
  }

  @override
  Future<void> feed(Int16List frames) async {
    // Copied, because the transport reuses one buffer for every block.
    fed.add(Int16List.fromList(frames));
  }

  @override
  Future<void> stop() async {
    if (_running) stopCount++;
    _running = false;
    _onFeed = null;
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
    await stop();
    await _stops.close();
  }

  /// Total frames handed over so far.
  int get fedFrames => fed.fold(0, (total, block) => total + block.length);

  /// Asks the transport for more, as the platform would.
  void demand() => _onFeed?.call(fedFrames - played);

  /// Plays [frames] more, a block at a time, as a real device would.
  ///
  /// Jumping the whole way at once would outrun the queued audio, which is a
  /// starved buffer rather than the passage of time.
  Future<void> play(int frames, {int step = 512}) async {
    var left = frames;
    while (left > 0) {
      final next = left < step ? left : step;
      played += next;
      demand();
      await Future<void>.delayed(Duration.zero);
      left -= next;
    }
  }

  /// Reports that something else took the speaker.
  void interrupt() => _stops.add(AudioOutputStop.interrupted);
}

/// A background holder that records what it was asked to do.
class _FakeBackground implements BackgroundAudioService {
  final StreamController<void> _requests = StreamController<void>.broadcast();
  int startCount = 0;
  int updateCount = 0;
  int stopCount = 0;
  BackgroundAudioNotification? last;

  @override
  bool isSupported = true;

  @override
  Stream<void> get stopRequests => _requests.stream;

  @override
  Future<void> start(BackgroundAudioNotification notification) async {
    startCount++;
    last = notification;
  }

  @override
  Future<void> update(BackgroundAudioNotification notification) async {
    updateCount++;
    last = notification;
  }

  @override
  Future<void> stop() async => stopCount++;

  @override
  Future<void> dispose() async => _requests.close();

  /// The player pressed Stop in the notification shade.
  void requestStop() => _requests.add(null);
}

const _config = AudioOutputConfig(allowBackgroundAudio: true);

MetronomeTransport _transport(
  _FakeAudioOutput output, {
  MetronomeSettings? settings,
  BackgroundAudioService background = const NoBackgroundAudioService(),
}) => MetronomeTransport(
  output: output,
  settings: settings,
  background: background,
);

const _copy = BackgroundAudioNotification(
  title: 'Metronome',
  body: '120 BPM',
  stopLabel: 'Stop',
);

void main() {
  group('MetronomeTransport playback', () {
    test(
      'starting fills the buffer ahead without playing anything yet',
      () async {
        final output = _FakeAudioOutput();
        final transport = _transport(output);
        addTearDown(transport.dispose);

        await transport.start();
        output.demand();

        expect(
          output.fedFrames,
          greaterThanOrEqualTo(_config.targetBufferFrames),
        );
        expect(transport.state.status, MetronomeStatus.running);
      },
    );

    test('the first click is the first sample fed', () async {
      // Anything else is a gap between pressing start and hearing the beat.
      final output = _FakeAudioOutput();
      final transport = _transport(output);
      addTearDown(transport.dispose);

      await transport.start();
      output.demand();

      var loudest = 0;
      for (final sample in output.fed.first) {
        if (sample.abs() > loudest) loudest = sample.abs();
      }
      expect(loudest, greaterThan(1000));
    });

    test('the beat does not move until the device has played it', () async {
      // The assertion that the picture follows the sound. Audio is rendered
      // ahead of the playhead, and the indicator must not run ahead with it
      // (docs/adr/0016). The downbeat is the exception, and only because
      // sample zero sounds the instant playback begins.
      final output = _FakeAudioOutput();
      final transport = _transport(output);
      addTearDown(transport.dispose);

      final seen = <int>[];
      transport.states.listen((state) {
        if (state.status == MetronomeStatus.running) seen.add(state.beat);
      });

      await transport.start();
      for (var i = 0; i < 20; i++) {
        output.demand();
      }
      await Future<void>.delayed(Duration.zero);

      // Nearly a beat of audio is queued and none of it has been played.
      expect(
        output.fedFrames,
        greaterThanOrEqualTo(_config.targetBufferFrames),
      );
      expect(output.played, 0);
      expect(
        seen.where((beat) => beat != 0),
        isEmpty,
        reason: 'the metronome advanced a beat nobody has heard',
      );

      // It also does not keep rendering forever: the queue is held at the
      // target depth, not filled to exhaustion.
      expect(
        output.fedFrames,
        lessThan(_config.targetBufferFrames + _config.blockFrames * 2),
      );
    });

    test(
      'playing the samples advances exactly the beats they contain',
      () async {
        final output = _FakeAudioOutput();
        final transport = _transport(output);
        addTearDown(transport.dispose);

        final beats = <int>[];
        transport.states.listen((state) {
          if (state.status == MetronomeStatus.running) beats.add(state.beat);
        });

        await transport.start();
        output.demand();

        // 120 BPM is 22050 samples a beat; four beats is one bar.
        for (var beat = 1; beat <= 4; beat++) {
          await output.play(22050);
          expect(
            transport.state.beat,
            beat % 4,
            reason: 'after $beat beats of audio',
          );
        }
        expect(transport.state.bar, 1);
      },
    );

    test('the accent falls on the beat the meter says it does', () async {
      final output = _FakeAudioOutput();
      final transport = _transport(
        output,
        settings: MetronomeSettings(signature: TimeSignature.sevenEight),
      );
      addTearDown(transport.dispose);

      await transport.start();
      output.demand();

      final levels = <AccentLevel>[transport.state.level];
      for (var i = 0; i < 6; i++) {
        await output.play(22050);
        levels.add(transport.state.level);
      }

      expect(levels, TimeSignature.sevenEight.defaultAccents);
    });
  });

  group('MetronomeTransport count-in', () {
    test('it counts in before it starts counting', () async {
      final output = _FakeAudioOutput();
      final transport = _transport(
        output,
        settings: MetronomeSettings(countIn: CountIn.oneBar),
      );
      addTearDown(transport.dispose);

      await transport.start();
      output.demand();
      expect(transport.state.status, MetronomeStatus.countingIn);
      expect(transport.state.countInBeatsRemaining, 4);

      for (var i = 0; i < 4; i++) {
        await output.play(22050);
      }
      expect(transport.state.status, MetronomeStatus.running);
      expect(transport.state.bar, 0);
      expect(transport.state.beat, 0);
    });
  });

  group('MetronomeTransport changes', () {
    test('a tempo change while stopped takes effect immediately', () async {
      final output = _FakeAudioOutput();
      final transport = _transport(output);
      addTearDown(transport.dispose);

      transport.apply(transport.settings.withBpm(90));
      expect(transport.state.settings.bpm, 90);

      await transport.start();
      output.demand();
      await output.play(29400); // one beat at 90 BPM
      expect(transport.state.beat, 1);
    });

    test('a tempo change while running does not lose the beat', () async {
      final output = _FakeAudioOutput();
      final transport = _transport(output);
      addTearDown(transport.dispose);

      await transport.start();
      output.demand();
      await output.play(22050);
      expect(transport.state.beat, 1);

      transport.apply(transport.settings.withBpm(240));
      await output.play(80000);
      // It kept counting rather than jumping back to a downbeat.
      expect(transport.state.isRunning, isTrue);
      expect(transport.state.settings.bpm, 240);
    });
  });

  group('MetronomeTransport lifecycle', () {
    test('it releases the speaker on every path out', () async {
      // CLAUDE.md §50 — a missed path is a metronome left playing behind a
      // closed screen. The tuner's `_CountingAudioInput` contract, applied
      // to the way out.
      for (final (name, exit)
          in <
            (
              String,
              Future<void> Function(
                MetronomeTransport,
                _FakeAudioOutput,
              ),
            )
          >[
            ('stop', (transport, output) => transport.stop()),
            ('dispose', (transport, output) => transport.dispose()),
            (
              'interruption',
              (transport, output) async {
                output.interrupt();
                await Future<void>.delayed(Duration.zero);
              },
            ),
          ]) {
        final output = _FakeAudioOutput();
        final transport = _transport(output);
        await transport.start();
        await exit(transport, output);
        expect(output.stopCount, 1, reason: 'the $name path left it open');
      }
    });

    test(
      'an interruption is not an error and must not look like one',
      () async {
        // A phone call is not something the player did wrong.
        final output = _FakeAudioOutput();
        final transport = _transport(output);
        addTearDown(transport.dispose);

        await transport.start();
        output
          ..demand()
          ..interrupt();
        await Future<void>.delayed(Duration.zero);

        expect(transport.state.status, MetronomeStatus.idle);
        expect(transport.state.failure, isNull);
      },
    );

    test('a device that cannot play says so rather than failing', () async {
      final output = _FakeAudioOutput()..isAvailable = false;
      final transport = _transport(output);
      addTearDown(transport.dispose);

      await transport.start();

      expect(transport.state.status, MetronomeStatus.unavailable);
      expect(output.fed, isEmpty);
    });

    test('starting twice does not open two players', () async {
      final output = _FakeAudioOutput();
      final transport = _transport(output);
      addTearDown(transport.dispose);

      await transport.start();
      await transport.start();
      await transport.stop();

      expect(output.stopCount, 1);
    });

    test('stopping puts the count back to the top', () async {
      final output = _FakeAudioOutput();
      final transport = _transport(output);
      addTearDown(transport.dispose);

      await transport.start();
      output.demand();
      await output.play(44100);
      expect(transport.state.beat, 2);

      await transport.stop();
      expect(transport.state.beat, 0);
      expect(transport.state.bar, 0);
      expect(transport.state.status, MetronomeStatus.idle);
    });
  });

  group('MetronomeTransport dropouts', () {
    test('a drained buffer is counted, not swallowed', () async {
      // CLAUDE.md §37 — a metronome that stutters in silence is worse than
      // one that says so.
      final output = _FakeAudioOutput();
      final transport = _transport(output);
      addTearDown(transport.dispose);

      await transport.start();
      output.demand();

      output.played = output.fedFrames;
      output.demand();
      await Future<void>.delayed(Duration.zero);

      expect(transport.state.dropouts, greaterThan(0));
    });

    test('repeated dropouts say so on screen', () async {
      final output = _FakeAudioOutput();
      final transport = _transport(output);
      addTearDown(transport.dispose);

      await transport.start();
      for (var i = 0; i < 4; i++) {
        output.played = output.fedFrames;
        output.demand();
        await Future<void>.delayed(Duration.zero);
      }

      expect(transport.state.isStruggling, isTrue);
    });
  });

  group('MetronomeTransport diagnostics', () {
    test('the measurements are off unless asked for', () async {
      // A player never sees these, so they are not gathered by default.
      final output = _FakeAudioOutput();
      final transport = _transport(output);
      addTearDown(transport.dispose);

      await transport.start();
      output.demand();
      expect(transport.state.diagnostics, isNull);
    });

    test('they report what the audio path is actually doing', () async {
      // docs/DEVICE-TESTING.md Part B reads these; they must be measurements,
      // not restatements of the settings.
      final output = _FakeAudioOutput();
      final transport = MetronomeTransport(
        output: output,
        collectDiagnostics: true,
      );
      addTearDown(transport.dispose);

      await transport.start();
      output.demand();

      final diagnostics = transport.state.diagnostics!;
      expect(diagnostics.sampleRate, 44100);
      expect(diagnostics.blockFrames, _config.blockFrames);
      expect(diagnostics.fedFrames, output.fedFrames);
      expect(diagnostics.playedFrames, 0);
      expect(
        diagnostics.bufferedFrames,
        greaterThanOrEqualTo(_config.targetBufferFrames),
      );
      expect(
        diagnostics.nextClickInMs,
        closeTo(500, 1),
        reason: 'the second beat at 120 BPM is half a second out',
      );
    });

    test('stopping leaves no stale numbers behind', () async {
      final output = _FakeAudioOutput();
      final transport = MetronomeTransport(
        output: output,
        collectDiagnostics: true,
      );
      addTearDown(transport.dispose);

      await transport.start();
      output.demand();
      expect(transport.state.diagnostics, isNotNull);

      await transport.stop();
      expect(transport.state.diagnostics, isNull);
    });
  });

  group('MetronomeTransport background', () {
    test('it asks to keep playing, and lets go on every path out', () async {
      // CLAUDE.md §50 — audio that outlives its reason is the battery cost.
      // The service is what Android requires to keep a click alive behind a
      // locked screen, and it must be released exactly as the speaker is.
      final background = _FakeBackground();
      final output = _FakeAudioOutput();
      final transport = _transport(output, background: background)
        ..notification = _copy;
      addTearDown(transport.dispose);

      await transport.start();
      expect(background.startCount, 1);
      expect(background.last, _copy);

      await transport.stop();
      expect(background.stopCount, greaterThanOrEqualTo(1));
    });

    test('a platform that needs no holder is not asked for one', () async {
      // iOS keeps playing on the background audio mode alone, and saying so
      // is more honest than a no-op that pretends to hold something.
      final background = _FakeBackground()..isSupported = false;
      final output = _FakeAudioOutput();
      final transport = _transport(output, background: background)
        ..notification = _copy;
      addTearDown(transport.dispose);

      await transport.start();
      expect(background.startCount, 0);
    });

    test('stopping from the shade really releases the speaker', () async {
      // A notification whose Stop button only dismissed the notification,
      // over a click that carried on, would be worse than none.
      final background = _FakeBackground();
      final output = _FakeAudioOutput();
      final transport = _transport(output, background: background)
        ..notification = _copy;
      addTearDown(transport.dispose);

      await transport.start();
      background.requestStop();
      await Future<void>.delayed(Duration.zero);

      expect(transport.state.status, MetronomeStatus.idle);
      expect(output.stopCount, 1);
    });

    test('the notification follows the tempo', () async {
      final background = _FakeBackground();
      final output = _FakeAudioOutput();
      final transport = _transport(output, background: background)
        ..notification = _copy;
      addTearDown(transport.dispose);

      await transport.start();
      transport.apply(transport.settings.withBpm(90));
      await Future<void>.delayed(Duration.zero);

      expect(background.updateCount, greaterThanOrEqualTo(1));
    });
  });

  group('MetronomeTransport haptics', () {
    test('the cue fires on accents and never on subdivisions', () async {
      // DESIGN.md §40 asks for a haptic on the beat and warns against
      // overusing them; sixteen buzzes a second at 240 BPM is the overuse.
      final output = _FakeAudioOutput();
      final transport = _transport(
        output,
        settings: MetronomeSettings(subdivision: Subdivision.quadruple),
      );
      addTearDown(transport.dispose);

      await transport.start();
      output.demand();
      expect(transport.takeHapticCue(), isTrue, reason: 'the downbeat');
      expect(transport.takeHapticCue(), isFalse, reason: 'read once');

      // Three sixteenths pass; none of them is a beat.
      for (var i = 0; i < 3; i++) {
        await output.play(5513);
        expect(transport.takeHapticCue(), isFalse);
      }
    });
  });
}
