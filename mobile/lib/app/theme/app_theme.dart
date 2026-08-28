import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// Builds the light and dark [ThemeData] for L Key entirely from generated
/// tokens.
///
/// Every value here traces back to `packages/design-tokens/tokens.json`.
/// Nothing in this file may introduce a literal colour, size or duration —
/// if a value is missing, add it to the token source and regenerate.
abstract final class AppTheme {
  /// DESIGN.md §5 — light theme.
  static ThemeData get light => _build(
    colors: LkSemanticColors.light,
    brightness: Brightness.light,
  );

  /// DESIGN.md §6 — dark theme. Not an inversion: it keeps a black ground,
  /// dark surfaces, light type and the same orange (DESIGN.md §68).
  static ThemeData get dark => _build(
    colors: LkSemanticColors.dark,
    brightness: Brightness.dark,
  );

  static ThemeData _build({
    required LkSemanticColors colors,
    required Brightness brightness,
  }) {
    final textTheme = _textTheme(colors);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      fontFamily: LkFonts.body,
      fontFamilyFallback: LkFonts.fallback,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[LkColorsExtension(colors)],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.textPrimary,
        onPrimary: colors.textInverse,
        secondary: colors.accent,
        onSecondary: colors.accentOn,
        error: colors.danger,
        onError: colors.textInverse,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        outline: colors.border,
      ),
      // DESIGN.md §12 — zero radius is the default across the system.
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colors.border, width: LkBorders.regular),
          borderRadius: BorderRadius.circular(LkRadii.none),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: LkBorders.regular,
        space: LkBorders.regular,
      ),
      // DESIGN.md §41 — short, functional, predictable.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      // Every control clears the WCAG 2.5.5 target size (DESIGN.md §42).
      materialTapTargetSize: MaterialTapTargetSize.padded,
      splashFactory: NoSplash.splashFactory,
    );
  }

  /// Maps the generated type scale onto Material's slots.
  ///
  /// DESIGN.md §9 defines ten steps; Material defines fifteen. Only the slots
  /// that correspond to a real L Key step are populated, so an unmapped widget
  /// fails visibly in review rather than silently inheriting a Material size.
  static TextTheme _textTheme(LkSemanticColors colors) {
    Color ink(TextStyle s) => s.color ?? colors.textPrimary;
    TextStyle on(TextStyle s) => s.copyWith(color: ink(s));

    return TextTheme(
      displayLarge: on(LkTypeScale.displayXl),
      displayMedium: on(LkTypeScale.display),
      headlineLarge: on(LkTypeScale.h1),
      headlineMedium: on(LkTypeScale.h2),
      headlineSmall: on(LkTypeScale.h3),
      bodyLarge: on(LkTypeScale.bodyLarge),
      bodyMedium: on(LkTypeScale.body),
      bodySmall: on(LkTypeScale.bodySmall),
      labelLarge: on(LkTypeScale.technicalLg),
      labelMedium: on(LkTypeScale.technical),
      labelSmall: on(LkTypeScale.label),
    ).apply(
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
    );
  }
}
