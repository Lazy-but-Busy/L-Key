import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/app/theme/app_theme.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/features/chords/data/chord_catalog.dart';
import 'package:l_key/features/chords/data/local_chord_repository.dart';
import 'package:l_key/features/chords/domain/chord_repository.dart';
import 'package:l_key/features/chords/presentation/chord_detail_page.dart';
import 'package:l_key/features/chords/presentation/chords_controller.dart';
import 'package:l_key/features/chords/presentation/chords_page.dart';
import 'package:l_key/features/chords/presentation/widgets/chord_diagram.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_empty_state.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';
import 'package:l_key/shared/widgets/lk_pressable.dart';
import 'package:l_key/shared/widgets/lk_segmented_control.dart';
import 'package:l_key/shared/widgets/lk_skeleton.dart';

import '../../helpers/pump.dart';

/// A repository that never answers, so the loading state can be seen.
class _PendingRepository implements ChordRepository {
  @override
  Future<List<ChordCatalogEntry>> browse() =>
      Completer<List<ChordCatalogEntry>>().future;

  @override
  Future<ChordDetail?> detail(String id) => Completer<ChordDetail?>().future;
}

/// A repository that fails, so the error state is reachable.
class _FailingRepository implements ChordRepository {
  @override
  Future<List<ChordCatalogEntry>> browse() async =>
      throw const NetworkFailure(technicalDetail: 'SocketException: boom');

  @override
  Future<ChordDetail?> detail(String id) async =>
      throw const NetworkFailure(technicalDetail: 'SocketException: boom');
}

/// A repository with nothing in it.
class _EmptyRepository implements ChordRepository {
  @override
  Future<List<ChordCatalogEntry>> browse() async => <ChordCatalogEntry>[];

  @override
  Future<ChordDetail?> detail(String id) async => null;
}

List<Override> _using(ChordRepository repository) => <Override>[
  chordRepositoryProvider.overrideWithValue(repository),
];

void main() {
  group('ChordsPage states', () {
    testWidgets('loading shows a skeleton, never a spinner', (tester) async {
      // DESIGN.md §39 prefers a skeleton to a generic spinner.
      await pumpLk(
        tester,
        child: const ChordsPage(),
        overrides: _using(_PendingRepository()),
      );
      await tester.pump();
      expect(find.byType(LkSkeletonList), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('success lists chords from the catalogue', (tester) async {
      await pumpLk(
        tester,
        child: const ChordsPage(),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();
      expect(find.text('C'), findsWidgets);
      expect(find.byType(LkPressable), findsWidgets);
    });

    testWidgets('an empty library shows the empty state', (tester) async {
      await pumpLk(
        tester,
        child: const ChordsPage(),
        overrides: _using(_EmptyRepository()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LkEmptyState), findsOneWidget);
    });

    testWidgets('a failure shows localised copy, never the exception', (
      tester,
    ) async {
      // CLAUDE.md §37 — technical detail goes to logs, not to the player.
      await pumpLk(
        tester,
        child: const ChordsPage(),
        overrides: _using(_FailingRepository()),
      );
      await tester.pumpAndSettle();
      expect(find.text("COULDN'T CONNECT."), findsOneWidget);
      expect(find.textContaining('SocketException'), findsNothing);
    });

    testWidgets('a search that matches nothing is an empty state', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const ChordsPage(),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.byType(LkEmptyState), findsOneWidget);
      expect(find.byType(LkPressable), findsNothing);
    });

    testWidgets('searching narrows the list to the chord asked for', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const ChordsPage(),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'C#m7b5');
      await tester.pumpAndSettle();
      expect(find.text('C♯m7♭5'), findsOneWidget);
      expect(find.byType(LkPressable), findsOneWidget);
    });

    testWidgets('a Myanmar query finds chords', (tester) async {
      // CLAUDE.md §32 — search is not ASCII-only.
      await pumpLk(
        tester,
        locale: const Locale('my'),
        child: const ChordsPage(),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'မိုင်နာ');
      await tester.pumpAndSettle();
      expect(find.byType(LkEmptyState), findsNothing);
      expect(find.byType(LkPressable), findsWidgets);
    });

    testWidgets('the filter narrows by chord shape', (tester) async {
      await pumpLk(
        tester,
        child: const ChordsPage(),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LkSegmentedControl<ChordFilter>), findsOneWidget);
      await tester.tap(find.text('EXTENDED'));
      await tester.pumpAndSettle();
      expect(find.byType(LkEmptyState), findsNothing);
    });

    testWidgets('every row clears the 44px tap target', (tester) async {
      await pumpLk(
        tester,
        child: const ChordsPage(),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      final row = tester.getSize(find.byType(LkPressable).first);
      expect(row.height, greaterThanOrEqualTo(LkDimens.tapTarget));
    });
  });

  group('ChordsPage premium labelling', () {
    testWidgets('a Premium chord is labelled and still opens', (tester) async {
      // CLAUDE.md §23 — the label is descriptive. Nothing here enforces it,
      // and the row is tappable exactly like a free one.
      await pumpLk(
        tester,
        child: const ChordsPage(),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Cmaj7');
      await tester.pumpAndSettle();

      expect(find.byType(LkPremiumBadge), findsOneWidget);
      final row = tester.widget<LkPressable>(find.byType(LkPressable).first);
      expect(row.onTap, isNotNull, reason: 'a PRO label must not lock a row');
      expect(row.enabled, isTrue);
    });

    testWidgets('a free chord carries no badge', (tester) async {
      await pumpLk(
        tester,
        child: const ChordsPage(),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      // "Am" also prefix-matches Am7, Am9 and the rest, which are Premium.
      // The exact match ranks first and is one of PRD.md §11's free chords.
      await tester.enterText(find.byType(TextField), 'Am');
      await tester.pumpAndSettle();

      final first = find.byType(LkPressable).first;
      expect(
        find.descendant(of: first, matching: find.byType(LkPremiumBadge)),
        findsNothing,
      );
    });
  });

  group('ChordDetailPage', () {
    testWidgets('renders the chord, its diagram and its facts', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const ChordDetailPage(chordId: 'c-major'),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LkChordDiagram), findsOneWidget);
      expect(find.text('1 3 5'), findsOneWidget);
      expect(find.text('C E G'), findsOneWidget);
    });

    testWidgets('an unknown chord shows the empty state, not an error', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const ChordDetailPage(chordId: 'h-flat-wobble'),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LkEmptyState), findsOneWidget);
      expect(find.byType(LkChordDiagram), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a failing repository shows safe copy', (tester) async {
      await pumpLk(
        tester,
        child: const ChordDetailPage(chordId: 'c-major'),
        overrides: _using(_FailingRepository()),
      );
      await tester.pumpAndSettle();

      expect(find.text("COULDN'T CONNECT."), findsOneWidget);
      expect(find.textContaining('SocketException'), findsNothing);
    });

    testWidgets('the play control is disabled and says why', (tester) async {
      // CLAUDE.md §47 — no fake playback, and no button that does nothing
      // silently.
      await pumpLk(
        tester,
        child: const ChordDetailPage(chordId: 'c-major'),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      final play = tester.widget<LkButton>(find.byType(LkButton));
      expect(play.onPressed, isNull, reason: 'nothing can sound a chord yet');
      expect(find.textContaining("isn't built yet"), findsOneWidget);
    });

    testWidgets('the voicing selector switches shapes', (tester) async {
      await pumpLk(
        tester,
        child: const ChordDetailPage(chordId: 'g-major'),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      final selector = find.byType(LkSegmentedControl<int>);
      expect(selector, findsOneWidget);

      final before = tester.widget<LkChordDiagram>(
        find.byType(LkChordDiagram),
      );
      expect(before.voicing.baseFret, 0, reason: 'G opens on the open shape');

      // The selector sits below the fold; the segmented control has its own
      // scrollable, so ensureVisible is the one that picks the right ancestor.
      await tester.ensureVisible(find.text('3FR'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3FR'));
      await tester.pumpAndSettle();

      final after = tester.widget<LkChordDiagram>(find.byType(LkChordDiagram));
      expect(after.voicing.baseFret, 3);
      expect(after.voicing.barre, isNotNull);
    });

    testWidgets('renders in both themes and in Burmese', (tester) async {
      for (final theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
        for (final locale in <Locale>[
          const Locale('en'),
          const Locale('my'),
        ]) {
          await pumpLk(
            tester,
            theme: theme,
            locale: locale,
            child: const ChordDetailPage(chordId: 'f-major'),
            overrides: _using(const LocalChordRepository()),
          );
          await tester.pumpAndSettle();
          expect(find.byType(LkChordDiagram), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    });
  });

  group('LkChordDiagram accessibility', () {
    testWidgets('reads out every string rather than drawing silent dots', (
      tester,
    ) async {
      // DESIGN.md §42 — a screen reader landing on six dots learns nothing.
      await pumpLk(
        tester,
        child: const ChordDetailPage(chordId: 'c-major'),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      final node = tester.getSemantics(find.byType(LkChordDiagram));

      expect(node.label, contains('C'));
      expect(node.hint, contains('String 6 muted'));
      expect(node.hint, contains('String 3 open'));
      expect(node.hint, contains('finger 3'));
      handle.dispose();
    });

    testWidgets('a barre is described, not left to the picture', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const ChordDetailPage(chordId: 'f-major'),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      final node = tester.getSemantics(find.byType(LkChordDiagram));
      expect(node.hint, contains('Barre at fret 1 across 6 strings'));
      handle.dispose();
    });

    testWidgets('a movable shape announces the fret it starts at', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const ChordDetailPage(chordId: 'g-major'),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      // The selector sits below the fold; the segmented control has its own
      // scrollable, so ensureVisible is the one that picks the right ancestor.
      await tester.ensureVisible(find.text('3FR'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3FR'));
      await tester.pumpAndSettle();

      final handle = tester.ensureSemantics();
      final node = tester.getSemantics(find.byType(LkChordDiagram));
      expect(node.hint, contains('Grid starts at fret 3'));
      handle.dispose();
    });
  });

  group('layer boundaries', () {
    test('the music domain never imports a subscription tier', () {
      // CLAUDE.md §10 — a chord's notes do not change with a subscription, so
      // FeatureTier belongs to the data layer and nowhere below it. This is
      // the kind of rule that erodes silently, so it is asserted.
      for (final file in _musicDomain) {
        expect(
          file.readAsStringSync(),
          isNot(contains('feature_tier.dart')),
          reason: '${file.path} imports a commercial concern',
        );
      }
    });

    test('the music domain never imports Flutter', () {
      // docs/ARCHITECTURE.md — this is what makes the engine testable without
      // a widget tree and reusable from the backend.
      for (final file in _musicDomain) {
        expect(
          file.readAsStringSync(),
          isNot(contains("import 'package:flutter/")),
          reason: '${file.path} imports Flutter',
        );
      }
    });

    test('no feature domain imports a sibling feature', () {
      // docs/adr/0009 put the shared primitives in core/music so that scales
      // and the fretboard never have to reach into chords. ChordQuality moved
      // there in Phase 04 for exactly this reason (docs/adr/0011).
      const features = <String>['chords', 'fretboard'];
      for (final feature in features) {
        final directory = Directory('lib/features/$feature/domain');
        if (!directory.existsSync()) continue;
        for (final file in directory.listSync().whereType<File>()) {
          final source = file.readAsStringSync();
          for (final other in features.where((f) => f != feature)) {
            expect(
              source,
              isNot(contains('package:l_key/features/$other/')),
              reason: '${file.path} imports the $other feature',
            );
          }
        }
      }
    });
  });
}

/// Every file that must stay free of Flutter and of a commercial label.
Iterable<File> get _musicDomain => <String>[
  'lib/core/music',
  'lib/features/chords/domain',
  'lib/features/fretboard/domain',
].expand((path) => Directory(path).listSync().whereType<File>());
