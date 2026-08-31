import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/audio/audio_output.dart';
import 'package:l_key/features/metronome/presentation/metronome_controller.dart';
import 'package:l_key/features/practice/presentation/practice_page.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/pump.dart';

class _SilentAudioOutput implements AudioOutput {
  final StreamController<AudioOutputStop> _stops =
      StreamController<AudioOutputStop>.broadcast();
  AudioOutputFeed? _onFeed;
  bool _running = false;

  @override
  bool get isAvailable => true;

  @override
  AudioOutputFormat? get format => null;

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
    _onFeed?.call(0);
  }

  @override
  Future<void> feed(Int16List frames) async {}

  @override
  Future<void> stop() async {
    _running = false;
    _onFeed = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _stops.close();
  }
}

Future<List<Override>> _overrides() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final preferences = await SharedPreferences.getInstance();
  return <Override>[
    sharedPreferencesProvider.overrideWithValue(preferences),
    audioOutputProvider.overrideWithValue(_SilentAudioOutput()),
  ];
}

void main() {
  setUp(openWideTestSurface);
  tearDown(resetTestSurface);

  group('PracticePage tempo', () {
    testWidgets('it shows the metronome tempo and can start it', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const PracticePage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('120'), findsOneWidget);
      // Two buttons say START: the session's and the metronome's. The tempo
      // row's is the last one down the screen.
      expect(find.text('START'), findsNWidgets(2));

      await tester.tap(find.text('START').last);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('STOP'), findsOneWidget);
    });

    testWidgets('it invents no session data', (tester) async {
      // Phase 08 owns practice sessions. The tempo row is the whole of the
      // integration, and the figures around it are still the static plan they
      // were, not an invented measurement (CLAUDE.md §47).
      await pumpLk(
        tester,
        child: const PracticePage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('20:00'), findsOneWidget);
      expect(find.text('/ 30:00'), findsOneWidget);
      expect(find.text('6 days'), findsWidgets);
    });

    testWidgets('the practice timer is still its own control', (tester) async {
      // Two buttons, two meanings: the session's own Start is unchanged and
      // does not drive the click, so nothing implies a session is running.
      await pumpLk(
        tester,
        child: const PracticePage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('START'), findsNWidgets(2));

      // Pressing the session button leaves the metronome alone.
      await tester.tap(find.text('START').first);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('PAUSE'), findsOneWidget);
      expect(find.text('START'), findsOneWidget);
    });
  });
}
