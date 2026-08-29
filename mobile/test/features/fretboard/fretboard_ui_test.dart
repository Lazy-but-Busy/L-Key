import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/app/theme/app_theme.dart';
import 'package:l_key/core/access/tiered_entry.dart';
import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/scale.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/fretboard/data/local_fretboard_repository.dart';
import 'package:l_key/features/fretboard/domain/fretboard_repository.dart';
import 'package:l_key/features/fretboard/presentation/fretboard_controller.dart';
import 'package:l_key/features/fretboard/presentation/fretboard_page.dart';
import 'package:l_key/shared/widgets/lk_empty_state.dart';
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

/// A repository with nothing in it.
class _EmptyRepository implements FretboardRepository {
  @override
  Future<FretboardOptions> load() async => const FretboardOptions(
    tunings: <TieredEntry<Tuning>>[],
    scales: <TieredEntry<ScaleType>>[],
    arpeggios: <TieredEntry<ChordQuality>>[],
  );
}

List<Override> _using(FretboardRepository repository) => <Override>[
  fretboardRepositoryProvider.overrideWithValue(repository),
];

/// What a screen reader hears when it lands on the neck.
///
/// Asserted against rather than against the painted dots, because it is the
/// same information and it is the half DESIGN.md §42 says must exist.
String _neck(WidgetTester tester) =>
    tester.getSemantics(find.byType(LkFretboard)).hint;

/// Taps a segmented-control option by its localised label.
///
/// The control sets its copy in uppercase (DESIGN.md §10), so the finder
/// does too — the argument stays readable as the string in the ARB file.
Future<void> _choose(WidgetTester tester, String label) async {
  await tester.tap(find.text(label.toUpperCase()).first);
  await tester.pumpAndSettle();
}

/// Whether a segmented-control option is on offer at all.
Finder _option(String label) => find.text(label.toUpperCase());

void main() {
  setUp(openWideTestSurface);
  tearDown(resetTestSurface);

  group('FretboardPage states', () {
    testWidgets('loading shows a skeleton, never a spinner', (tester) async {
      // DESIGN.md §39 prefers a skeleton to a generic spinner.
      await pumpLk(
        tester,
        child: const FretboardPage(),
        overrides: _using(_PendingRepository()),
      );
      await tester.pump();
      expect(find.byType(LkSkeletonList), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('a failing catalogue shows safe copy, never the exception', (
      tester,
    ) async {
      // CLAUDE.md §37 — the SocketException goes to the log, not the screen.
      await pumpLk(
        tester,
        child: const FretboardPage(),
        overrides: _using(_FailingRepository()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LkErrorState), findsOneWidget);
      expect(find.textContaining('SocketException'), findsNothing);
    });

    testWidgets('an empty catalogue shows the empty state', (tester) async {
      await pumpLk(
        tester,
        child: const FretboardPage(),
        overrides: _using(_EmptyRepository()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LkEmptyState), findsOneWidget);
    });

    testWidgets('success draws a neck', (tester) async {
      await pumpLk(
        tester,
        child: const FretboardPage(),
        overrides: _using(const LocalFretboardRepository()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LkFretboard), findsOneWidget);
      // A minor pentatonic is the default: A C D E G and nothing else.
      expect(_neck(tester), contains('fret 5 A'));
      expect(_neck(tester), contains('fret 8 C'));
      expect(_neck(tester), isNot(contains('F♯')));
    });
  });

  group('FretboardPage controls', () {
    Future<void> pumpBoard(WidgetTester tester) async {
      await pumpLk(
        tester,
        child: const FretboardPage(),
        overrides: _using(const LocalFretboardRepository()),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('changing the root changes the notes on the neck', (
      tester,
    ) async {
      await pumpBoard(tester);
      expect(_neck(tester), contains('fret 5 A'));
      expect(_neck(tester), isNot(contains('B♭')));

      await _choose(tester, 'B♭');

      // B♭ minor pentatonic is B♭ D♭ E♭ F A♭ — no A natural anywhere.
      expect(_neck(tester), contains('fret 6 B♭'));
      expect(_neck(tester), contains('D♭'));
      expect(_neck(tester), isNot(contains(' A,')));
    });

    testWidgets('interval labels replace note names', (tester) async {
      await pumpBoard(tester);
      expect(_neck(tester), contains('fret 5 A'));

      await _choose(tester, 'Intervals');

      // The minor pentatonic's degrees, in place of its note names.
      expect(_neck(tester), contains('fret 5 1'));
      expect(_neck(tester), contains('fret 8 b3'));
      expect(_neck(tester), isNot(contains('fret 5 A')));
    });

    testWidgets('choosing a box narrows the neck to that window', (
      tester,
    ) async {
      await pumpBoard(tester);
      final wide = ','.allMatches(_neck(tester)).length;

      await _choose(tester, 'Box 1');

      // Box 1 of A minor pentatonic is two notes on each of the six strings,
      // frets 5 to 8 — the shape the design system draws.
      final narrow = _neck(tester);
      expect(','.allMatches(narrow).length, lessThan(wide));
      expect(narrow, contains('String 6, fret 5 A, fret 8 C'));
      expect(narrow, contains('String 1, fret 5 A, fret 8 C'));
      expect(find.text('0–15'), findsNothing);
    });

    testWidgets('switching to modes offers the modes and not the pentatonics', (
      tester,
    ) async {
      await pumpBoard(tester);
      expect(_option('Dorian'), findsNothing);

      await _choose(tester, 'Modes');

      expect(_option('Dorian'), findsWidgets);
      expect(_option('Minor Pentatonic'), findsNothing);
    });

    testWidgets('an arpeggio draws chord tones, not a scale', (tester) async {
      await pumpBoard(tester);
      await _choose(tester, 'Arpeggios');
      // The scale's D is a chord tone of nothing in Am7 and disappears.
      expect(_neck(tester), isNot(contains('D')));

      await _choose(tester, 'Intervals');

      // The default arpeggio is Am7 — A C E G. The fourth the minor
      // pentatonic has, D, is not a chord tone and is gone.
      final neck = _neck(tester);
      expect(neck, contains('fret 5 1'));
      expect(neck, contains('fret 8 b3'));
      expect(neck, contains('fret 12 5'));
      expect(neck, contains('fret 3 b7'));
      // Four degrees and no others: an arpeggio is the chord, not the scale.
      expect(
        RegExp(r'fret \d+ (\S+?)[,.]')
            .allMatches(neck)
            .map((m) => m.group(1))
            .toSet(),
        <String>{'1', 'b3', '5', 'b7'},
      );
    });

    testWidgets('a seven-string tuning grows the neck by a string', (
      tester,
    ) async {
      await pumpBoard(tester);
      final six = tester.widget<LkFretboard>(find.byType(LkFretboard));
      expect(six.tuning.stringCount, 6);

      await _choose(tester, '7-string');

      final seven = tester.widget<LkFretboard>(find.byType(LkFretboard));
      expect(seven.tuning.stringCount, 7);
      // CAGED is a six-string, standard-tuning claim, so it says so and the
      // shape options disappear rather than being invented (CLAUDE.md §47).
      expect(
        find.text('CAGED is a six-string, standard-tuning system.'),
        findsOneWidget,
      );
      expect(_option('E shape'), findsNothing);
    });

    testWidgets('the fret control widens and slides the window', (
      tester,
    ) async {
      await pumpBoard(tester);
      expect(find.text('0–15'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Show more frets'));
      await tester.pumpAndSettle();
      expect(find.text('0–16'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Move up the neck'));
      await tester.pumpAndSettle();
      expect(find.text('1–17'), findsOneWidget);
      expect(_neck(tester), isNot(contains('open')));
    });
  });

  group('FretboardPage labelling and access', () {
    testWidgets('a Premium-labelled scale selects exactly like a free one', (
      tester,
    ) async {
      // CLAUDE.md §23 and §51 — the badge describes, it does not authorize.
      await pumpLk(
        tester,
        child: const FretboardPage(),
        overrides: _using(const LocalFretboardRepository()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LkPremiumBadge), findsNothing);

      await _choose(tester, 'Whole Tone');

      expect(find.byType(LkPremiumBadge), findsWidgets);
      expect(find.byType(LkFretboard), findsOneWidget);
      // A whole-tone scale on A: A B C♯ D♯ E♯ F♯♯ — six notes, all drawn.
      expect(_neck(tester), contains('fret 5 A'));
    });

    testWidgets('the neck is read out string by string', (tester) async {
      // DESIGN.md §42 — meaning is never carried by the picture alone.
      await pumpLk(
        tester,
        child: const FretboardPage(),
        overrides: _using(const LocalFretboardRepository()),
      );
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(LkFretboard));
      expect(
        semantics.label,
        contains('A Minor Pentatonic on a 6-string neck'),
      );
      expect(semantics.hint, contains('String 6'));
      expect(semantics.hint, contains('String 1'));
      expect(semantics.hint, contains('fret 5 A'));
      expect(semantics.hint, contains('open E'));
    });

    testWidgets('renders in both themes and in Burmese', (tester) async {
      for (final theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
        await pumpLk(
          tester,
          child: const FretboardPage(),
          theme: theme,
          overrides: _using(const LocalFretboardRepository()),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await pumpLk(
        tester,
        child: const FretboardPage(),
        locale: const Locale('my'),
        overrides: _using(const LocalFretboardRepository()),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(LkFretboard), findsOneWidget);
    });
  });
}
