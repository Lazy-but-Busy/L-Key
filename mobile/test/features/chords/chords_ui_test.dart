import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/app/theme/app_theme.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/features/chords/data/chord_catalog.dart';
import 'package:l_key/features/chords/data/local_chord_repository.dart';
import 'package:l_key/features/chords/domain/chord_repository.dart';
import 'package:l_key/features/chords/presentation/chord_analyzer_controller.dart';
import 'package:l_key/features/chords/presentation/chord_analyzer_page.dart';
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

/// The chord rows in the library list.
///
/// Found by key rather than by type: `LkButton` is an `LkPressable` too, and
/// the screen carries one that opens the analyzer, so counting every
/// pressable would count a control that is not a chord.
Finder get _chordRows => find.byWidgetPredicate(
  (widget) =>
      widget.key is ValueKey<String> &&
      (widget.key! as ValueKey<String>).value.startsWith('chord-'),
  description: 'chord row',
);

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
      expect(_chordRows, findsWidgets);
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
      expect(_chordRows, findsNothing);
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
      expect(_chordRows, findsOneWidget);
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
      expect(_chordRows, findsWidgets);
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

      final row = tester.getSize(_chordRows.first);
      expect(row.height, greaterThanOrEqualTo(LkDimens.tapTarget));
    });
  });

  group('ChordsPage search state', () {
    testWidgets('an empty query shows the library, not an empty state', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const ChordsPage(),
        overrides: _using(const LocalChordRepository()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LkEmptyState), findsNothing);
      expect(_chordRows, findsWidgets);
    });

    testWidgets('clearing the text brings the whole library back', (
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
      expect(_chordRows, findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(_chordRows, findsWidgets);
      expect(find.byType(LkEmptyState), findsNothing);
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
      final row = tester.widget<LkPressable>(_chordRows.first);
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

      final first = _chordRows.first;
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

  group('ChordAnalyzerPage', () {
    setUp(openWideTestSurface);
    tearDown(resetTestSurface);

    /// Builds A minor on the neck, one cell at a time.
    Future<void> buildAMinor(WidgetTester tester) async {
      for (final label in <String>[
        'String 5, open, A',
        'String 4, fret 2, E',
        'String 3, fret 2, A',
        'String 2, fret 1, C',
        'String 1, open, E',
      ]) {
        await tester.tap(find.bySemanticsLabel(label));
        await tester.pumpAndSettle();
      }
    }

    /// What the analyzer currently thinks the shape is.
    String? namedChord(WidgetTester tester) => ProviderScope.containerOf(
      tester.element(find.byType(ChordAnalyzerPage)),
    ).read(chordAnalysisProvider).best?.chord.symbol;

    testWidgets('it opens on an empty neck and says so', (tester) async {
      await pumpLk(tester, child: const ChordAnalyzerPage());
      await tester.pumpAndSettle();

      expect(find.text('NOTHING SELECTED'), findsOneWidget);
      expect(find.text('Tap the neck to build a shape.'), findsOneWidget);
      expect(namedChord(tester), isNull);
    });

    testWidgets('a shape built on the neck is named', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpLk(tester, child: const ChordAnalyzerPage());
      await tester.pumpAndSettle();

      await buildAMinor(tester);

      expect(namedChord(tester), 'Am');
      expect(find.text('Am'), findsOneWidget);
      expect(find.text('POSSIBLE CHORDS'), findsOneWidget);
      expect(find.text('NOTES'), findsOneWidget);
      expect(find.text('INTERVALS'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a name that leaves a tone out says which one', (tester) async {
      // C6 with no fifth is a true reading of A C E and the screen has to be
      // honest that it is missing a note, not quietly offer it as an equal.
      final handle = tester.ensureSemantics();
      await pumpLk(tester, child: const ChordAnalyzerPage());
      await tester.pumpAndSettle();
      await buildAMinor(tester);

      expect(find.text('C6/E'), findsNothing);
      expect(find.textContaining('omits'), findsWidgets);
      handle.dispose();
    });

    testWidgets('tapping a marker again takes the string out', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpLk(tester, child: const ChordAnalyzerPage());
      await tester.pumpAndSettle();
      await buildAMinor(tester);

      await tester.tap(find.bySemanticsLabel('String 2, fret 1, C'));
      await tester.pumpAndSettle();

      expect(
        namedChord(tester),
        isNot('Am'),
        reason: 'A and E without the C is no longer A minor',
      );
      handle.dispose();
    });

    testWidgets('the gutter control mutes a string and brings it back', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpLk(tester, child: const ChordAnalyzerPage());
      await tester.pumpAndSettle();
      await buildAMinor(tester);

      await tester.tap(find.bySemanticsLabel('Mute string 5'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Play string 5 open'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Play string 5 open'));
      await tester.pumpAndSettle();
      expect(namedChord(tester), 'Am');
      handle.dispose();
    });

    testWidgets('Clear returns every string to muted', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpLk(tester, child: const ChordAnalyzerPage());
      await tester.pumpAndSettle();
      await buildAMinor(tester);

      await tester.tap(find.text('CLEAR'));
      await tester.pumpAndSettle();

      expect(find.text('NOTHING SELECTED'), findsOneWidget);
      expect(namedChord(tester), isNull);
      handle.dispose();
    });

    testWidgets('one note is not offered as a chord', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpLk(tester, child: const ChordAnalyzerPage());
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('String 5, fret 3, C'));
      await tester.pumpAndSettle();

      expect(find.text('C ON ITS OWN'), findsOneWidget);
      expect(find.text('POSSIBLE CHORDS'), findsNothing);
      handle.dispose();
    });

    testWidgets('play is disabled, and the reason is written down', (
      tester,
    ) async {
      // CLAUDE.md §47 — no audio engine exists, so the control admits it
      // rather than pretending.
      await pumpLk(tester, child: const ChordAnalyzerPage());
      await tester.pumpAndSettle();

      expect(find.text("Chord audio isn't built yet."), findsOneWidget);
      final play = tester.widget<LkButton>(
        find.widgetWithText(LkButton, 'PLAY CHORD'),
      );
      expect(play.onPressed, isNull);
    });

    testWidgets('the neck and every cell have accessible names', (
      tester,
    ) async {
      // DESIGN.md §42 — a screen reader landing on seventy-eight unlabelled
      // taps learns nothing, and a shape cannot be built without them.
      final handle = tester.ensureSemantics();
      await pumpLk(tester, child: const ChordAnalyzerPage());
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Chord shape editor, 6-string neck'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('String 6, open, E'), findsOneWidget);
      expect(find.bySemanticsLabel('String 6, fret 12, E'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('changing the tuning empties the shape', (tester) async {
      // Carrying frets across a retune would rename the chord under the
      // player's hands, and a seven-string neck has a string the old shape
      // has no entry for.
      final handle = tester.ensureSemantics();
      await pumpLk(tester, child: const ChordAnalyzerPage());
      await tester.pumpAndSettle();
      await buildAMinor(tester);

      // The segmented control prints its labels uppercase (DESIGN.md §10).
      await tester.tap(find.text('DROP D'));
      await tester.pumpAndSettle();

      expect(namedChord(tester), isNull);
      expect(find.text('NOTHING SELECTED'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('it renders in both themes and in Burmese', (tester) async {
      for (final theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
        await pumpLk(tester, child: const ChordAnalyzerPage(), theme: theme);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await pumpLk(
        tester,
        child: const ChordAnalyzerPage(),
        locale: const Locale('my'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
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
