import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/audio/audio_input.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/core/permissions/microphone_permission.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:l_key/features/tuner/presentation/tuner_controller.dart';
import 'package:l_key/features/tuner/presentation/tuner_page.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';
import 'package:l_key/shared/widgets/lk_tuner_meter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/pump.dart';
import '../../helpers/waveforms.dart';

/// An input that plays a synthesised string into the pipeline.
///
/// The whole chain runs for real — assembler, analyzer, detector, session —
/// with only the microphone replaced, which is the closest a test can get to
/// a guitar without one.
class _ScriptedAudioInput implements AudioInput {
  _ScriptedAudioInput({required this.frequencyHz});

  final double frequencyHz;
  final StreamController<AudioInputStop> _stops =
      StreamController<AudioInputStop>.broadcast();
  StreamController<Uint8List>? _bytes;
  bool _running = false;
  int stopCount = 0;

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

  /// Pushes half a second of a sawtooth in, which is a dozen analysed windows.
  void play() {
    _bytes?.add(
      toPcm16(
        sawtooth(frequencyHz: frequencyHz, sampleRate: 44100, length: 22050),
      ),
    );
  }

  /// Pushes silence in.
  void playSilence() => _bytes?.add(toPcm16(Float64List(22050)));

  /// Something else took the microphone.
  void interrupt() => _stops.add(AudioInputStop.interrupted);

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
    await stop();
    await _stops.close();
  }
}

/// A permission that answers however the test needs it to.
class _ScriptedPermission implements MicrophonePermission {
  _ScriptedPermission(this.access);

  MicrophoneAccess access;
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

Future<List<Override>> _overrides({
  AudioInput? input,
  MicrophonePermission? permission,
  VoidCallback? haptics,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  return <Override>[
    sharedPreferencesProvider.overrideWithValue(prefs),
    audioInputProvider.overrideWithValue(
      input ?? const UnavailableAudioInput(),
    ),
    microphonePermissionProvider.overrideWithValue(
      permission ?? _ScriptedPermission(MicrophoneAccess.granted),
    ),
    if (haptics != null) tunerHapticsProvider.overrideWithValue(haptics),
  ];
}

/// What a screen reader hears when it lands on the meter.
String _meterSemantics(WidgetTester tester) =>
    tester.getSemantics(find.byType(LkTunerMeter)).label;

void main() {
  setUp(openWideTestSurface);
  tearDown(resetTestSurface);

  group('TunerPage permission', () {
    testWidgets('it explains what the microphone is for before asking', (
      tester,
    ) async {
      // A prompt with no context is one people decline.
      final permission = _ScriptedPermission(MicrophoneAccess.denied);
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(permission: permission),
      );
      await tester.tap(find.text('START LISTENING'));
      await tester.pumpAndSettle();

      expect(find.text('The tuner needs your microphone'), findsOneWidget);
      expect(find.textContaining('Nothing is recorded'), findsOneWidget);
      expect(find.text('ALLOW MICROPHONE'), findsOneWidget);
    });

    testWidgets('a permanent refusal offers settings, not a retry', (
      tester,
    ) async {
      // CLAUDE.md §37 — retrying would fail forever, so it is not offered.
      final permission = _ScriptedPermission(
        MicrophoneAccess.permanentlyDenied,
      );
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(permission: permission),
      );
      await tester.tap(find.text('START LISTENING'));
      await tester.pumpAndSettle();

      expect(find.text('Microphone access is turned off'), findsOneWidget);
      expect(find.text('OPEN SETTINGS'), findsOneWidget);
      expect(find.text('ALLOW MICROPHONE'), findsNothing);

      await tester.tap(find.text('OPEN SETTINGS'));
      await tester.pumpAndSettle();
      expect(permission.settingsOpened, 1);
    });

    testWidgets('a restricted device is told the truth and offered nothing', (
      tester,
    ) async {
      // Parental controls or a managed device. There is nothing in the
      // settings the player can change, and a button there would waste their
      // time.
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(
          permission: _ScriptedPermission(MicrophoneAccess.restricted),
        ),
      );
      await tester.tap(find.text('START LISTENING'));
      await tester.pumpAndSettle();

      expect(find.text('Microphone access is not available'), findsOneWidget);
      expect(find.text('OPEN SETTINGS'), findsNothing);
    });
  });

  group('TunerPage states', () {
    testWidgets('at rest it names no note and claims nothing', (tester) async {
      // CLAUDE.md §47 — a meter parked at centre with a note on it would be
      // a tuner pretending to hear something.
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LkTunerMeter), findsOneWidget);
      expect(find.text('START LISTENING'), findsOneWidget);
      expect(find.text('IN TUNE'), findsNothing);
    });

    testWidgets('listening to a quiet room says so and offers a next step', (
      tester,
    ) async {
      final input = _ScriptedAudioInput(frequencyHz: 110);
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(input: input),
      );
      await tester.tap(find.text('START LISTENING'));
      await tester.pumpAndSettle();

      input.playSilence();
      await tester.pumpAndSettle();

      expect(find.text('LISTENING'), findsOneWidget);
      expect(find.text('Pluck a single string.'), findsOneWidget);
      expect(find.text('STOP'), findsOneWidget);
    });

    testWidgets('a played string is named, measured and shown in tune', (
      tester,
    ) async {
      // The whole chain, from PCM bytes to the needle, with only the
      // microphone replaced.
      final input = _ScriptedAudioInput(
        frequencyHz: Tuning.standard.openStrings[1].frequencyHz(),
      );
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(input: input),
      );
      await tester.tap(find.text('START LISTENING'));
      await tester.pumpAndSettle();

      input.play();
      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
      expect(find.text('2'), findsWidgets);
      expect(find.textContaining('110.0'), findsOneWidget);
      expect(
        find.text('IN TUNE'),
        findsOneWidget,
        reason:
            'DESIGN.md §42 — the orange is never the only signal, so the '
            'words have to be there too',
      );
      expect(
        find.textContaining('TUNING TO'),
        findsNothing,
        reason:
            'the note sounding is the note being tuned to, so naming the '
            'destination would only repeat the glyph above it',
      );
    });

    testWidgets('a note that is not a string is named, and so is the target', (
      tester,
    ) async {
      // PRD.md §10.1 — note detection, not string detection. F2 is a
      // semitone above the low E and belongs to no string of standard
      // tuning, so the screen has to name it and then say what it is
      // measuring against.
      final input = _ScriptedAudioInput(frequencyHz: 87.31);
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(input: input),
      );
      await tester.tap(find.text('START LISTENING'));
      await tester.pumpAndSettle();

      input.play();
      await tester.pumpAndSettle();

      expect(find.text('F'), findsOneWidget);
      expect(find.text('TUNING TO E2'), findsOneWidget);
      expect(find.textContaining('CENTS SHARP'), findsOneWidget);
    });

    testWidgets('a string a long way off reads its distance in cents', (
      tester,
    ) async {
      final input = _ScriptedAudioInput(
        frequencyHz:
            Tuning.standard.openStrings[1].frequencyHz() * 1.0116, // +20 cents
      );
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(input: input),
      );
      await tester.tap(find.text('START LISTENING'));
      await tester.pumpAndSettle();

      input.play();
      await tester.pumpAndSettle();

      expect(find.textContaining('CENTS SHARP'), findsOneWidget);
      expect(find.text('IN TUNE'), findsNothing);
    });
  });

  group('TunerPage strings and tunings', () {
    testWidgets('every string of the tuning is offered, lowest first', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      for (final pitch in Tuning.standard.openStrings) {
        expect(
          find.text('${pitch.note.displayName}${pitch.octave}'),
          findsWidgets,
          reason: '${pitch.name} is missing from the string row',
        );
      }
    });

    testWidgets('a Premium-labelled tuning selects exactly like a free one', (
      tester,
    ) async {
      // CLAUDE.md §23 — the badge is a label and authorizes nothing. The
      // server decides entitlement, and it is not consulted to draw a row.
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LkPremiumBadge), findsWidgets);
      await tester.tap(find.text('Drop D'));
      await tester.pumpAndSettle();

      expect(find.text('D2'), findsWidgets);
    });

    testWidgets('chromatic mode belongs to no tuning, so no string is shown', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chromatic'));
      await tester.pumpAndSettle();

      expect(find.text('CHROMATIC'), findsWidgets);
    });
  });

  group('TunerPage accessibility', () {
    testWidgets('the meter tells a screen reader the note and the state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final input = _ScriptedAudioInput(
        frequencyHz: Tuning.standard.openStrings[1].frequencyHz(),
      );
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(input: input),
      );
      await tester.tap(find.text('START LISTENING'));
      await tester.pumpAndSettle();
      input.play();
      await tester.pumpAndSettle();

      expect(_meterSemantics(tester), contains('A2'));
      expect(_meterSemantics(tester), contains('In tune'));
      handle.dispose();
    });

    testWidgets('the string list counts the way a guitarist does', (
      tester,
    ) async {
      // The engine indexes lowest-sounding first, so the low E is string 0
      // internally and string 6 to a player. Announcing it as "String 1" was
      // the reverse of what anyone would say out loud.
      final handle = tester.ensureSemantics();
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('String 6, E2'), findsOneWidget);
      expect(find.bySemanticsLabel('String 1, E4'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the meter announces the note it heard, not the target', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final input = _ScriptedAudioInput(frequencyHz: 87.31);
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(input: input),
      );
      await tester.tap(find.text('START LISTENING'));
      await tester.pumpAndSettle();
      input.play();
      await tester.pumpAndSettle();

      expect(_meterSemantics(tester), contains('F2'));
      handle.dispose();
    });

    testWidgets('every control clears the minimum tap target', (tester) async {
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      final failures = <String>[];
      for (final element in find.byType(GestureDetector).evaluate()) {
        final size = tester.getSize(find.byWidget(element.widget));
        if (size.height < LkDimens.tapTarget) {
          failures.add('a control is only ${size.height}px tall');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    testWidgets('reduced motion lands the needle without animating it', (
      tester,
    ) async {
      final input = _ScriptedAudioInput(
        frequencyHz: Tuning.standard.openStrings[1].frequencyHz(),
      );
      await pumpLk(
        tester,
        child: const TunerPage(),
        disableAnimations: true,
        overrides: await _overrides(input: input),
      );
      await tester.tap(find.text('START LISTENING'));
      await tester.pumpAndSettle();
      input.play();
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('the whole screen survives Burmese', (tester) async {
      // DESIGN.md §36 — Burmese is a first-class language, not a layer.
      await pumpLk(
        tester,
        child: const TunerPage(),
        locale: const Locale('my'),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('TunerPage lifecycle', () {
    testWidgets('an interruption stops without blaming the player', (
      tester,
    ) async {
      // A phone call is not an error state.
      final input = _ScriptedAudioInput(frequencyHz: 110);
      await pumpLk(
        tester,
        child: const TunerPage(),
        overrides: await _overrides(input: input),
      );
      await tester.tap(find.text('START LISTENING'));
      await tester.pumpAndSettle();

      input.interrupt();
      await tester.pumpAndSettle();

      expect(find.text('START LISTENING'), findsOneWidget);
      expect(find.text('Something went wrong.'), findsNothing);
    });
  });

  group('layer boundaries', () {
    test('nothing above the seam knows which DSP is in use', () {
      // CLAUDE.md §14 — the algorithm must be replaceable without touching
      // the tuner, its state or the UI.
      const dsp = <String>[
        'MpmPitchDetector',
        'FrequencyAnalyzer',
        'Fft(',
        'Biquad',
      ];
      final failures = <String>[];
      for (final file in _tunerPresentation) {
        final source = file.readAsStringSync();
        for (final name in dsp) {
          if (source.contains(name)) {
            failures.add('${file.path} names $name');
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('the audio and tuner domains never import Flutter', () {
      final failures = <String>[];
      for (final file in _audioDomain) {
        if (file.readAsStringSync().contains("import 'package:flutter/")) {
          failures.add('${file.path} imports Flutter');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('the tuner domain never imports a subscription tier', () {
      // A string's frequency does not change with a subscription.
      final failures = <String>[];
      for (final file in _audioDomain) {
        if (file.readAsStringSync().contains('feature_tier.dart')) {
          failures.add('${file.path} imports a commercial concern');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('no clock appears anywhere the state machine can reach', () {
      // docs/adr/0013 — time arrives as a frame's timestamp, counted from
      // samples, which is the whole reason a session replays identically.
      // Doc comments are stripped first, because several of them explain
      // this very rule by naming what they forbid.
      final failures = <String>[];
      for (final file in _audioDomain) {
        final code = file
            .readAsLinesSync()
            .where((line) => !line.trimLeft().startsWith('//'))
            .join('\n');
        if (code.contains('DateTime.now()') || code.contains('Stopwatch(')) {
          failures.add('${file.path} reads a clock');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('each plugin is imported by exactly one file', () {
      // The seams are only worth having if nothing slips past them.
      final failures = <String>[];
      for (final (package, allowed) in <(String, String)>[
        ('package:record/', 'record_audio_input.dart'),
        (
          'package:permission_handler/',
          'permission_handler_microphone_permission.dart',
        ),
        ('package:flutter_pcm_sound/', 'pcm_sound_audio_output.dart'),
      ]) {
        for (final file in _allSources) {
          if (file.readAsStringSync().contains("import '$package") &&
              !file.path.endsWith(allowed)) {
            failures.add('${file.path} imports $package directly');
          }
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });
  });
}

/// Everything that must stay free of Flutter and of a commercial label.
Iterable<File> get _audioDomain => <String>[
  'lib/core/audio',
  'lib/core/permissions',
  'lib/features/tuner/domain',
].expand((path) => Directory(path).listSync().whereType<File>());

/// The tuner's widgets and controller.
Iterable<File> get _tunerPresentation => <String>[
  'lib/features/tuner/presentation',
  'lib/features/tuner/presentation/widgets',
].expand((path) => Directory(path).listSync().whereType<File>());

/// Every Dart source in the application.
Iterable<File> get _allSources =>
    Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
