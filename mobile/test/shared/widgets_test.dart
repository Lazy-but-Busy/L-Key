import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/app/theme/app_theme.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/errors/failure.dart';
import 'package:l_key/shared/widgets/lk_async_view.dart';
import 'package:l_key/shared/widgets/lk_bottom_nav_bar.dart';
import 'package:l_key/shared/widgets/lk_button.dart';
import 'package:l_key/shared/widgets/lk_empty_state.dart';
import 'package:l_key/shared/widgets/lk_error_state.dart';
import 'package:l_key/shared/widgets/lk_premium_badge.dart';
import 'package:l_key/shared/widgets/lk_pressable.dart';
import 'package:l_key/shared/widgets/lk_segmented_control.dart';
import 'package:l_key/shared/widgets/lk_skeleton.dart';

import '../helpers/pump.dart';

void main() {
  group('LkButton', () {
    testWidgets('every size clears the 44px tap target', (tester) async {
      // The design system's own small button is 26px, which fails WCAG 2.5.5.
      for (final size in LkButtonSize.values) {
        await pumpLk(
          tester,
          child: Center(
            child: LkButton(label: 'Go', size: size, onPressed: () {}),
          ),
        );
        final box = tester.getSize(find.byType(LkButton));
        expect(
          box.height,
          greaterThanOrEqualTo(LkDimens.tapTarget),
          reason: '$size must remain tappable',
        );
      }
    });

    testWidgets('a null handler disables the button', (tester) async {
      var taps = 0;
      await pumpLk(tester, child: const LkButton(label: 'Go'));
      await tester.tap(find.byType(LkButton));
      expect(taps, 0);

      await pumpLk(
        tester,
        child: LkButton(label: 'Go', onPressed: () => taps++),
      );
      await tester.tap(find.byType(LkButton));
      expect(taps, 1);
    });

    testWidgets('renders in both themes', (tester) async {
      for (final theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
        await pumpLk(
          tester,
          theme: theme,
          child: LkButton(label: 'Go', onPressed: () {}),
        );
        expect(find.text('GO'), findsOneWidget);
      }
    });
  });

  group('reduced motion', () {
    testWidgets('the press animation collapses when the OS asks', (
      tester,
    ) async {
      // DESIGN.md §42 requires reduced-motion support and had no
      // implementation anywhere in the app before this phase.
      for (final disabled in <bool>[false, true]) {
        await pumpLk(
          tester,
          disableAnimations: disabled,
          child: LkPressable(onTap: () {}, child: const Text('Press')),
        );

        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Press')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1));

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        expect(
          container.duration,
          disabled ? Duration.zero : LkMotion.durationFast,
          reason: disabled
              ? 'the state change is instant, never absent'
              : 'the press animates normally by default',
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }
    });
  });

  group('LkAsyncView', () {
    Widget view(AsyncValue<List<String>> value) => LkAsyncView<List<String>>(
      value: value,
      isEmpty: (data) => data.isEmpty,
      empty: (_) => const LkEmptyState(headline: 'Nothing yet'),
      data: (_, data) => Text(data.first),
    );

    testWidgets('loading renders a skeleton, not a spinner', (tester) async {
      // DESIGN.md §39 prefers a skeleton to a generic spinner.
      await pumpLk(tester, child: view(const AsyncLoading()));
      expect(find.byType(LkSkeletonList), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('success renders the data branch', (tester) async {
      await pumpLk(tester, child: view(const AsyncData(<String>['Riff'])));
      expect(find.text('Riff'), findsOneWidget);
    });

    testWidgets('loaded-but-empty renders the empty branch', (tester) async {
      await pumpLk(tester, child: view(const AsyncData(<String>[])));
      expect(find.text('NOTHING YET'), findsOneWidget);
    });

    testWidgets('error renders localised copy, never the exception', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: view(
          const AsyncError<List<String>>(
            NetworkFailure(technicalDetail: 'SocketException: boom'),
            StackTrace.empty,
          ),
        ),
      );
      expect(find.text("COULDN'T CONNECT."), findsOneWidget);
      expect(find.textContaining('SocketException'), findsNothing);
    });

    testWidgets('an error still shows while a retry is pending', (
      tester,
    ) async {
      // Riverpod retries a failed provider on its own, and until it gives up
      // the state is AsyncLoading *carrying* an error. Taking the loading
      // branch there would leave the player watching a skeleton forever
      // instead of being told what went wrong (CLAUDE.md §37). This builds the
      // situation the way the app meets it rather than synthesising the state.
      final failing = FutureProvider<List<String>>(
        (ref) async =>
            throw const NetworkFailure(technicalDetail: 'SocketException'),
      );

      await pumpLk(
        tester,
        child: Consumer(
          builder: (context, ref, _) => view(ref.watch(failing)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("COULDN'T CONNECT."), findsOneWidget);
      expect(find.byType(LkSkeletonList), findsNothing);
      expect(find.textContaining('SocketException'), findsNothing);
    });

    testWidgets('a non-Failure error still shows safe copy', (tester) async {
      await pumpLk(
        tester,
        child: view(
          AsyncError<List<String>>(
            StateError('internal detail'),
            StackTrace.empty,
          ),
        ),
      );
      expect(find.text('SOMETHING WENT WRONG.'), findsOneWidget);
      expect(find.textContaining('internal detail'), findsNothing);
    });
  });

  group('LkErrorState', () {
    testWidgets('offers retry only when there is something to retry', (
      tester,
    ) async {
      await pumpLk(
        tester,
        child: const LkErrorState(failure: NetworkFailure()),
      );
      expect(find.byType(LkButton), findsNothing);

      var retried = 0;
      await pumpLk(
        tester,
        child: LkErrorState(
          failure: const NetworkFailure(),
          onRetry: () => retried++,
        ),
      );
      await tester.tap(find.byType(LkButton));
      expect(retried, 1);
    });
  });

  group('LkBottomNavBar', () {
    const destinations = <LkNavDestination>[
      LkNavDestination(icon: Icons.home_outlined, label: 'Home'),
      LkNavDestination(icon: Icons.tune, label: 'Tools'),
    ];

    testWidgets('marks the active destination as selected', (tester) async {
      await pumpLk(
        tester,
        child: LkBottomNavBar(
          destinations: destinations,
          currentIndex: 1,
          onSelected: (_) {},
        ),
      );

      final handle = tester.ensureSemantics();
      final active = tester.getSemantics(find.text('Tools'));
      expect(active.flagsCollection.isSelected, Tristate.isTrue);
      expect(active.flagsCollection.isButton, isTrue);
      expect(active.label, 'Tools');

      final idle = tester.getSemantics(find.text('Home'));
      expect(idle.flagsCollection.isSelected, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('reports the tapped index', (tester) async {
      int? tapped;
      await pumpLk(
        tester,
        child: LkBottomNavBar(
          destinations: destinations,
          currentIndex: 0,
          onSelected: (i) => tapped = i,
        ),
      );
      await tester.tap(find.text('Tools'));
      expect(tapped, 1);
    });
  });

  group('LkSegmentedControl', () {
    testWidgets('selecting reports the value', (tester) async {
      String? picked;
      await pumpLk(
        tester,
        child: LkSegmentedControl<String>(
          segments: const <String, String>{'all': 'All', 'fav': 'Favorites'},
          selected: 'all',
          onChanged: (v) => picked = v,
        ),
      );
      await tester.tap(find.text('FAVORITES'));
      expect(picked, 'fav');
    });
  });

  group('LkPremiumBadge', () {
    testWidgets('always carries the word, never colour alone', (tester) async {
      // DESIGN.md §42 — meaning is never encoded through colour alone.
      await pumpLk(tester, child: const LkPremiumBadge(label: 'PRO'));
      expect(find.text('PRO'), findsOneWidget);
    });
  });
}
