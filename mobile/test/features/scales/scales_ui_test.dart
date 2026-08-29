import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/app/theme/app_theme.dart';
import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/features/fretboard/data/local_fretboard_repository.dart';
import 'package:l_key/features/fretboard/domain/fretboard_repository.dart';
import 'package:l_key/features/fretboard/presentation/fretboard_controller.dart';
import 'package:l_key/features/scales/presentation/scales_page.dart';
import 'package:l_key/shared/widgets/lk_error_state.dart';
import 'package:l_key/shared/widgets/lk_fretboard.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';
import 'package:l_key/shared/widgets/lk_skeleton.dart';

import '../../helpers/pump.dart';

/// A repository that never answers, so the loading state can be seen.
class _PendingRepository implements FretboardRepository {
  @override
  Future<FretboardOptions> load() => Completer<FretboardOptions>().future;
}

/// A repository that fails, so the error state is reachable.
class _FailingRepository implements FretboardRepository {
  @override
  Future<FretboardOptions> load() async =>
      throw const NetworkFailure(technicalDetail: 'SocketException: boom');
}

List<Override> _using(FretboardRepository repository) => <Override>[
  fretboardRepositoryProvider.overrideWithValue(repository),
];

Future<void> _pump(WidgetTester tester, {ThemeData? theme, Locale? locale}) =>
    pumpLk(
      tester,
      child: const ScalesPage(),
      theme: theme,
      locale: locale ?? const Locale('en'),
      overrides: _using(const LocalFretboardRepository()),
    );

Future<void> _choose(WidgetTester tester, String label) async {
  await tester.tap(find.text(label.toUpperCase()).first);
  await tester.pumpAndSettle();
}

void main() {
  setUp(openWideTestSurface);
  tearDown(resetTestSurface);

  group('ScalesPage', () {
    testWidgets('loading shows a skeleton, never a spinner', (tester) async {
      await pumpLk(
        tester,
        child: const ScalesPage(),
        overrides: _using(_PendingRepository()),
      );
      await tester.pump();
      expect(find.byType(LkSkeletonList), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('a failing catalogue shows safe copy', (tester) async {
      await pumpLk(
        tester,
        child: const ScalesPage(),
        overrides: _using(_FailingRepository()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LkErrorState), findsOneWidget);
      expect(find.textContaining('SocketException'), findsNothing);
    });

    testWidgets('the formula and the notes are computed, not placeholders', (
      tester,
    ) async {
      // The screen used to print a hardcoded '1 b3 4 5 b7' and a hardcoded
      // 'A'. Both now come from the scale engine, which is what makes
      // changing the scale change them.
      await _pump(tester);
      await tester.pumpAndSettle();

      expect(find.text('1 b3 4 5 b7'), findsOneWidget);
      expect(find.text('A C D E G'), findsOneWidget);
      expect(find.textContaining('next phase'), findsNothing);

      await _choose(tester, 'Major');
      expect(find.text('1 2 3 4 5 6 7'), findsOneWidget);
      expect(find.text('A B C♯ D E F♯ G♯'), findsOneWidget);
    });

    testWidgets('changing the root respells the scale', (tester) async {
      await _pump(tester);
      await tester.pumpAndSettle();

      await _choose(tester, 'E♭');
      expect(find.text('E♭ G♭ A♭ B♭ D♭'), findsOneWidget);
    });

    testWidgets('a box narrows the neck and names itself in the subtitle', (
      tester,
    ) async {
      await _pump(tester);
      await tester.pumpAndSettle();
      expect(find.text('POSITIONS AND FORMULAS'), findsOneWidget);

      await _choose(tester, 'Box 1');

      // The header sets its subtitle in uppercase (DESIGN.md §10).
      expect(find.text('BOX 1 · FRETS 5–8'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(LkFretboard)).hint,
        contains('String 6, fret 5 A, fret 8 C'),
      );
    });

    testWidgets('a Premium-labelled scale is marked and still opens', (
      tester,
    ) async {
      // CLAUDE.md §23 — the label describes; it authorizes nothing.
      await _pump(tester);
      await tester.pumpAndSettle();
      expect(find.byType(LkPremiumBadge), findsNothing);

      await _choose(tester, 'Harmonic Minor');

      expect(find.byType(LkPremiumBadge), findsOneWidget);
      expect(find.text('1 2 b3 4 5 b6 7'), findsOneWidget);
      expect(find.byType(LkFretboard), findsOneWidget);
    });

    testWidgets('playback is absent and says so rather than doing nothing', (
      tester,
    ) async {
      // CLAUDE.md §47 — no audio engine exists, so no play control is drawn.
      await _pump(tester);
      await tester.pumpAndSettle();
      expect(
        find.text('Scale playback arrives with the audio engine.'),
        findsOneWidget,
      );
    });

    testWidgets('a scale screen always shows a scale, never an arpeggio', (
      tester,
    ) async {
      // The two screens share their state. Leaving the fretboard tool on
      // Arpeggios must not make this screen print a scale's formula over a
      // chord's notes.
      await _pump(tester);
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ScalesPage)),
      );
      container
          .read(fretboardProvider.notifier)
          .selectKind(
            FretboardKind.arpeggio,
          );
      await tester.pumpAndSettle();

      expect(find.text('1 b3 4 5 b7'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(LkFretboard)).hint,
        contains('fret 5 A'),
      );
      // The fourth is a pentatonic note and not a chord tone of Am7.
      expect(
        tester.getSemantics(find.byType(LkFretboard)).hint,
        contains('D'),
      );
    });

    testWidgets('renders in both themes and in Burmese', (tester) async {
      for (final theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
        await _pump(tester, theme: theme);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await _pump(tester, locale: const Locale('my'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(LkFretboard), findsOneWidget);
    });
  });
}
