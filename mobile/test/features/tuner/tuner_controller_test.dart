import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/audio/audio_input.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/core/permissions/microphone_permission.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:l_key/features/tuner/domain/tuner_state.dart';
import 'package:l_key/features/tuner/presentation/tuner_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/waveforms.dart';

/// An input that counts how often it is released.
class _CountingAudioInput implements AudioInput {
  final StreamController<AudioInputStop> _stops =
      StreamController<AudioInputStop>.broadcast();
  StreamController<Uint8List>? _bytes;
  bool _running = false;

  int stopCount = 0;
  int disposeCount = 0;

  @override
  AudioInputFormat? get format =>
      _running ? const AudioInputFormat(sampleRate: 44100, channels: 1) : null;

  @override
  Stream<AudioInputStop> get interruptions => _stops.stream;

  @override
  bool get isRunning => _running;

  @override
  Future<Stream<Uint8List>> start(AudioInputConfig config) async {
    _running = true;
    final controller = StreamController<Uint8List>();
    _bytes = controller;
    return controller.stream;
  }

  void play(double frequencyHz) => _bytes?.add(
    toPcm16(
      sawtooth(frequencyHz: frequencyHz, sampleRate: 44100, length: 22050),
    ),
  );

  @override
  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    stopCount++;
    await _bytes?.close();
    _bytes = null;
  }

  @override
  Future<void> dispose() async {
    disposeCount++;
    await stop();
    await _stops.close();
  }
}

/// An input that refuses to open at all.
class _RefusingAudioInput implements AudioInput {
  @override
  AudioInputFormat? get format => null;

  @override
  Stream<AudioInputStop> get interruptions =>
      const Stream<AudioInputStop>.empty();

  @override
  bool get isRunning => false;

  @override
  Future<Stream<Uint8List>> start(AudioInputConfig config) async =>
      throw StateError('the recorder would not open');

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

class _ScriptedPermission implements MicrophonePermission {
  _ScriptedPermission(this.access);

  final MicrophoneAccess access;
  int settingsOpened = 0;

  @override
  Future<MicrophoneAccess> status() async => access;

  @override
  Future<MicrophoneAccess> request() async => access;

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

Future<ProviderContainer> _container({
  required AudioInput input,
  MicrophoneAccess access = MicrophoneAccess.granted,
  MicrophonePermission? permission,
  VoidCallback? haptics,
  Map<String, Object> preferences = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: <Override>[
      sharedPreferencesProvider.overrideWithValue(prefs),
      audioInputProvider.overrideWithValue(input),
      microphonePermissionProvider.overrideWithValue(
        permission ?? _ScriptedPermission(access),
      ),
      if (haptics != null) tunerHapticsProvider.overrideWithValue(haptics),
    ],
  );
  // The provider is auto-disposing, so without a listener it tears itself
  // down the moment a test lets go of it — taking the microphone with it,
  // which is the behaviour being tested rather than a way to set it up.
  return container..listen(tunerProvider, (_, _) {});
}

/// Lets the pipeline's state stream deliver.
///
/// States arrive asynchronously because audio does. Nothing is being waited
/// on here except a microtask.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  // AppLifecycleListener reaches for WidgetsBinding, and these are plain
  // tests rather than widget tests, so nothing has set one up yet.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TunerController lifecycle', () {
    test('nothing opens the microphone until the player asks', () async {
      // PRD.md §63 — no audio processing while the tuner is inactive. Merely
      // opening the screen must not open the microphone.
      final input = _CountingAudioInput();
      final container = await _container(input: input);
      addTearDown(container.dispose);

      expect(container.read(tunerProvider).status, TunerStatus.idle);
      expect(input.isRunning, isFalse);
    });

    test('disposing the provider releases the microphone', () async {
      // CLAUDE.md §50 asserted rather than trusted. The provider is
      // auto-disposing, so leaving the screen tears the microphone down by
      // construction — and this is the test that the construction holds.
      final input = _CountingAudioInput();
      final container = await _container(input: input);
      await container.read(tunerProvider.notifier).start();
      expect(input.isRunning, isTrue);

      container.dispose();
      await _settle();

      expect(input.isRunning, isFalse);
      expect(input.disposeCount, 1);
    });

    test('stopping releases it too, and says the tuner is idle', () async {
      final input = _CountingAudioInput();
      final container = await _container(input: input);
      addTearDown(container.dispose);

      final controller = container.read(tunerProvider.notifier);
      await controller.start();
      await controller.stop();
      await _settle();

      expect(input.isRunning, isFalse);
      expect(container.read(tunerProvider).status, TunerStatus.idle);
    });

    test('leaving the tab releases it, and coming back resumes', () async {
      // The shell keeps every tab's stack alive, so a tuner left open on the
      // Tools tab is still mounted while the player reads a chord chart.
      final input = _CountingAudioInput();
      final container = await _container(input: input);
      addTearDown(container.dispose);

      final controller = container.read(tunerProvider.notifier);
      await controller.start();
      expect(input.isRunning, isTrue);

      controller.setVisible(visible: false);
      await _settle();
      expect(input.isRunning, isFalse);

      controller.setVisible(visible: true);
      await _settle();
      expect(input.isRunning, isTrue);
    });

    test('a tuner that was not listening does not start itself', () async {
      final input = _CountingAudioInput();
      final container = await _container(input: input);
      addTearDown(container.dispose);

      container.read(tunerProvider.notifier)
        ..setVisible(visible: false)
        ..setVisible(visible: true);
      await _settle();

      expect(input.isRunning, isFalse);
      expect(container.read(tunerProvider).status, TunerStatus.idle);
    });

    test('starting twice does not open a second recorder', () async {
      final input = _CountingAudioInput();
      final container = await _container(input: input);
      addTearDown(container.dispose);

      final controller = container.read(tunerProvider.notifier);
      await controller.start();
      await controller.start();

      expect(input.isRunning, isTrue);
      expect(input.stopCount, 0);
    });
  });

  group('TunerController permission', () {
    test('a refusal is a state, not an error', () async {
      final input = _CountingAudioInput();
      final container = await _container(
        input: input,
        access: MicrophoneAccess.denied,
      );
      addTearDown(container.dispose);

      await container.read(tunerProvider.notifier).start();
      await _settle();
      final state = container.read(tunerProvider);

      expect(state.status, TunerStatus.permissionRequired);
      expect(state.failure, isNull);
      expect(input.isRunning, isFalse);
    });

    test('a permanent refusal offers the settings page', () async {
      final permission = _ScriptedPermission(
        MicrophoneAccess.permanentlyDenied,
      );
      final container = await _container(
        input: _CountingAudioInput(),
        permission: permission,
      );
      addTearDown(container.dispose);

      final controller = container.read(tunerProvider.notifier);
      await controller.start();
      await _settle();
      expect(container.read(tunerProvider).canOpenSettings, isTrue);

      await controller.openSettings();
      expect(permission.settingsOpened, 1);
    });

    test(
      'a restricted device is offered nothing, because nothing helps',
      () async {
        final container = await _container(
          input: _CountingAudioInput(),
          access: MicrophoneAccess.restricted,
        );
        addTearDown(container.dispose);

        await container.read(tunerProvider.notifier).start();
        await _settle();
        final state = container.read(tunerProvider);

        expect(state.status, TunerStatus.permissionBlocked);
        expect(state.canOpenSettings, isFalse);
      },
    );
  });

  group('TunerController failure', () {
    test(
      'a recorder that will not open shows an error, and no exception',
      () async {
        // CLAUDE.md §37 — the technical detail goes to the failure's log field
        // and never to the screen.
        final container = await _container(input: _RefusingAudioInput());
        addTearDown(container.dispose);

        await container.read(tunerProvider.notifier).start();
        await _settle();
        final state = container.read(tunerProvider);

        expect(state.status, TunerStatus.failed);
        expect(state.failure, isNotNull);
        expect(state.failure!.technicalDetail, contains('would not open'));
      },
    );
  });

  group('TunerController haptics', () {
    test('the lock buzzes once, not once per window', () async {
      // DESIGN.md §40 asks for a haptic on tuner lock and warns against
      // overusing them. Counting them is the only way to assert that without
      // a device.
      var buzzes = 0;
      final input = _CountingAudioInput();
      final container = await _container(
        input: input,
        haptics: () => buzzes++,
      );
      addTearDown(container.dispose);

      await container.read(tunerProvider.notifier).start();
      // Two seconds of a perfectly in-tune A string is eighty-odd windows.
      final a2 = Tuning.standard.openStrings[1].frequencyHz();
      input
        ..play(a2)
        ..play(a2)
        ..play(a2)
        ..play(a2);
      await _settle();

      expect(container.read(tunerProvider).reading?.isSettled, isTrue);
      expect(buzzes, 1);
    });
  });

  group('TunerController settings', () {
    test('it takes the reference pitch from settings', () async {
      // PRD.md §10.2 — the tuner and the settings screen must agree, so the
      // controller reads the one persisted value rather than keeping its own.
      final container = await _container(
        input: _CountingAudioInput(),
        preferences: <String, Object>{'settings.referencePitchHz': 432.0},
      );
      addTearDown(container.dispose);

      expect(container.read(tunerProvider).referenceHz, 432);
    });
  });
}
