import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/app/theme/app_theme.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/audio/audio_output.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';
import 'package:l_key/features/metronome/presentation/metronome_controller.dart';
import 'package:l_key/features/metronome/presentation/metronome_page.dart';
import 'package:l_key/features/metronome/presentation/widgets/metronome_beat_indicator.dart';
import 'package:l_key/features/settings/presentation/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/pump.dart';

/// An output that plays nothing but says it could.
class _SilentAudioOutput implements AudioOutput {
  final StreamController<AudioOutputStop> _stops =
      StreamController<AudioOutputStop>.broadcast();
  AudioOutputFeed? _onFeed;
  bool _running = false;

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
    // One demand, so the transport renders and publishes its downbeat, and
    // then silence — nothing here pretends time is passing.
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

Future<List<Override>> _overrides({
  AudioOutput? output,
  VoidCallback? haptics,
  Duration Function()? clock,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final preferences = await SharedPreferences.getInstance();
  return <Override>[
    sharedPreferencesProvider.overrideWithValue(preferences),
    audioOutputProvider.overrideWithValue(output ?? _SilentAudioOutput()),
    if (haptics != null) metronomeHapticsProvider.overrideWithValue(haptics),
    if (clock != null) metronomeClockProvider.overrideWithValue(clock),
  ];
}

void main() {
  setUp(openWideTestSurface);
  tearDown(resetTestSurface);

  group('MetronomePage', () {
    testWidgets('it shows the tempo and offers to start', (tester) async {
      await pumpLk(
        tester,
        child: const MetronomePage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('120'), findsOneWidget);
      expect(find.text('BPM'), findsOneWidget);
      expect(find.text('START'), findsOneWidget);
      expect(find.text('STOP'), findsNothing);
    });

    testWidgets('starting swaps the transport button', (tester) async {
      await pumpLk(
        tester,
        child: const MetronomePage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('START'));
      await tester.pumpAndSettle();

      expect(find.text('STOP'), findsOneWidget);
      expect(find.text('START'), findsNothing);

      await tester.tap(find.text('STOP'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('START'), findsOneWidget);
    });

    testWidgets('the steppers move the tempo one at a time', (tester) async {
      // Four cannot land on 92, and a metronome that cannot be set to 92 is
      // not a metronome.
      await pumpLk(
        tester,
        child: const MetronomePage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Faster'));
      await tester.pumpAndSettle();
      expect(find.text('121'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Slower'));
      await tester.tap(find.bySemanticsLabel('Slower'));
      await tester.pumpAndSettle();
      expect(find.text('119'), findsOneWidget);
    });

    testWidgets('the tempo cannot be pushed past what it will play', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const MetronomePage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 125; i++) {
        await tester.tap(find.bySemanticsLabel('Faster'));
      }
      await tester.pumpAndSettle();
      expect(find.text('240'), findsOneWidget);
    });

    testWidgets('tapping four times sets the tempo', (tester) async {
      // The clock is injected, so the taps are a script rather than a race.
      var now = Duration.zero;
      await pumpLk(
        tester,
        child: const MetronomePage(),
        overrides: await _overrides(clock: () => now),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 5; i++) {
        now = Duration(milliseconds: i * 1000);
        await tester.tap(find.textContaining('TAP'));
        await tester.pumpAndSettle();
      }

      expect(find.text('60'), findsOneWidget);
    });

    testWidgets('changing the meter changes the bar', (tester) async {
      await pumpLk(
        tester,
        child: const MetronomePage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      expect(_beatCount(tester), 4);

      await tester.tap(find.text('7/8'));
      await tester.pumpAndSettle();

      expect(_beatCount(tester), 7);
    });

    testWidgets('a Premium-labelled meter still selects', (tester) async {
      // The label authorizes nothing — entitlement is the server's decision
      // (CLAUDE.md §23, §51). Every row here opens.
      await pumpLk(
        tester,
        child: const MetronomePage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('PRO'), findsWidgets);

      await tester.tap(find.text('6/8'));
      await tester.pumpAndSettle();
      expect(_beatCount(tester), 6);

      await tester.tap(find.text('TRIPLETS'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('an accent can be cycled and silenced', (tester) async {
      await pumpLk(
        tester,
        child: const MetronomePage(),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Beat 2, Normal'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Beat 2, Normal'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Beat 2, Silent'), findsOneWidget);
    });
  });

  group('MetronomePage states', () {
    testWidgets('a device that cannot play says so', (tester) async {
      final output = _SilentAudioOutput()..isAvailable = false;
      await pumpLk(
        tester,
        child: const MetronomePage(),
        overrides: await _overrides(output: output),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('START'));
      await tester.pumpAndSettle();

      expect(
        find.text("This device can't play the metronome."),
        findsOneWidget,
      );
    });
  });

  group('MetronomeBeatIndicator', () {
    testWidgets('the accent is stronger by more than its colour', (
      tester,
    ) async {
      // DESIGN.md §42 — meaning must never be carried by colour alone. The
      // accented beat is a larger dot with a heavier ring over a bolder
      // number, so it survives a monochrome screen.
      await pumpLk(
        tester,
        child: const MetronomeBeatIndicator(
          accents: <AccentLevel>[
            AccentLevel.strong,
            AccentLevel.normal,
            AccentLevel.normal,
            AccentLevel.normal,
          ],
          beat: 0,
          isRunning: true,
        ),
      );
      await tester.pumpAndSettle();

      final dots = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .toList();
      expect(dots, hasLength(4));

      final accented = dots.first.constraints!;
      final ordinary = dots[1].constraints!;
      expect(
        accented.maxWidth,
        greaterThan(ordinary.maxWidth),
        reason: 'the accent must be visibly larger, not merely orange',
      );

      final accentBorder =
          (dots.first.decoration! as BoxDecoration).border! as Border;
      final ordinaryBorder =
          (dots[1].decoration! as BoxDecoration).border! as Border;
      expect(
        accentBorder.top.width,
        greaterThan(ordinaryBorder.top.width),
      );
    });

    testWidgets('the bar is readable when nothing is sounding', (tester) async {
      // The rings stay drawn, so the length of the bar can always be read.
      await pumpLk(
        tester,
        child: const MetronomeBeatIndicator(
          accents: <AccentLevel>[
            AccentLevel.strong,
            AccentLevel.normal,
            AccentLevel.normal,
          ],
          beat: 0,
          isRunning: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('it names the beat for a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpLk(
        tester,
        child: const MetronomeBeatIndicator(
          accents: <AccentLevel>[
            AccentLevel.strong,
            AccentLevel.normal,
            AccentLevel.normal,
            AccentLevel.normal,
          ],
          beat: 2,
          isRunning: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Beat indicator'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('twelve beats fit a narrow phone', (tester) async {
      // DESIGN.md §43 — 12/8 is twelve dots, and a Row would overflow.
      resetTestSurface();
      await pumpLk(
        tester,
        child: MetronomeBeatIndicator(
          accents: TimeSignature.twelveEight.defaultAccents,
          beat: 0,
          isRunning: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('MetronomePage accessibility', () {
    testWidgets('every control clears the minimum tap target', (tester) async {
      await pumpLk(
        tester,
        child: const MetronomePage(),
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

    testWidgets('the whole screen survives Burmese', (tester) async {
      // DESIGN.md §36 — Burmese is a first-class language, not a layer.
      await pumpLk(
        tester,
        child: const MetronomePage(),
        locale: const Locale('my'),
        overrides: await _overrides(),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('it renders in both themes', (tester) async {
      for (final theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
        await pumpLk(
          tester,
          child: const MetronomePage(),
          theme: theme,
          overrides: await _overrides(),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('reduced motion loses no meaning', (tester) async {
      await pumpLk(
        tester,
        child: const MetronomePage(),
        overrides: await _overrides(),
        disableAnimations: true,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('START'));
      await tester.pumpAndSettle();

      // The beat number is still there, so the state never lived in the
      // animation (DESIGN.md §41, §42).
      expect(find.text('1'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('metronome layer boundaries', () {
    test('the screen never names the scheduler or the synth', () {
      // CLAUDE.md §14 — the timing must be replaceable without touching the
      // screen, exactly as the tuner's DSP is.
      // The transport is not on this list: the controller composes it, the
      // same way `TunerController` composes `TunerPipeline`. What must not
      // leak upward is *how* the beats are placed and voiced.
      const internals = <String>[
        'ClickSynth',
        'ClickTrackRenderer',
        'ClickSchedule',
        'Biquad',
      ];
      final failures = <String>[];
      for (final file in _metronomePresentation) {
        final source = file.readAsStringSync();
        for (final name in internals) {
          if (source.contains(name)) failures.add('${file.path} names $name');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });

    test('the metronome domain never imports a subscription tier', () {
      // A beat's position does not change with a subscription.
      final failures = <String>[];
      for (final file in _metronomeDomain) {
        if (file.readAsStringSync().contains('feature_tier.dart')) {
          failures.add('${file.path} imports a commercial concern');
        }
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    });
  });
}

/// How many beats the indicator is drawing.
int _beatCount(WidgetTester tester) => tester
    .widget<MetronomeBeatIndicator>(find.byType(MetronomeBeatIndicator))
    .accents
    .length;

Iterable<File> get _metronomeDomain =>
    Directory('lib/features/metronome/domain').listSync().whereType<File>();

Iterable<File> get _metronomePresentation => <String>[
  'lib/features/metronome/presentation',
  'lib/features/metronome/presentation/widgets',
].expand((path) => Directory(path).listSync().whereType<File>());
