import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_theme.dart';
import 'package:l_key/app/theme/tokens.g.dart';

void main() {
  group('AppTheme', () {
    test('light theme resolves every semantic role', () {
      final theme = AppTheme.light;
      final ext = theme.extension<LkColorsExtension>();

      expect(ext, isNotNull, reason: 'semantic colours must reach ThemeData');
      expect(ext!.colors.background, LkPalette.offWhite);
      expect(ext.colors.textPrimary, LkPalette.black);
      expect(ext.colors.accent, LkPalette.orange);
      expect(theme.scaffoldBackgroundColor, LkPalette.offWhite);
    });

    test('dark theme keeps a black ground rather than inverting', () {
      // DESIGN.md §68 — dark mode is designed, not flipped.
      final theme = AppTheme.dark;
      final colors = theme.extension<LkColorsExtension>()!.colors;

      expect(colors.background, LkPalette.darkBackground);
      expect(colors.surface, LkPalette.darkSurface);
      expect(colors.textPrimary, LkPalette.darkText);
      expect(
        colors.accent,
        LkPalette.orange,
        reason: 'the accent is identical in both themes',
      );
    });

    test('both themes populate every mapped text slot', () {
      for (final theme in <ThemeData>[AppTheme.light, AppTheme.dark]) {
        final t = theme.textTheme;
        for (final style in <TextStyle?>[
          t.displayLarge,
          t.displayMedium,
          t.headlineLarge,
          t.headlineMedium,
          t.headlineSmall,
          t.bodyLarge,
          t.bodyMedium,
          t.bodySmall,
          t.labelLarge,
          t.labelMedium,
          t.labelSmall,
        ]) {
          expect(style, isNotNull);
          expect(style!.fontSize, isNotNull);
          expect(style.color, isNotNull);
        }
      }
    });

    testWidgets('context.lkColors reads the active theme', (tester) async {
      late LkSemanticColors seen;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Builder(
            builder: (context) {
              seen = context.lkColors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(seen.background, LkPalette.darkBackground);
    });
  });
}
