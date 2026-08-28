// L KEY DESIGN TOKENS — GENERATED FILE. DO NOT EDIT.
//
// Source:    packages/design-tokens/tokens.json
// Generator: packages/design-tokens/build.mjs
// Regenerate with `npm run tokens`. CI runs `npm run tokens:check`.

// Long lines come from token source citations; wrapping them would
// split the DESIGN.md references that make each value traceable.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Raw colour ramp from DESIGN.md §5-6.
///
/// Prefer [LkSemanticColors]; reach for the ramp only when defining a new
/// semantic role. Feature widgets must never reference this class directly.
abstract final class LkPalette {
  /// DESIGN.md §5 PRIMARY
  static const Color black = Color(0xFF000000);

  /// surface for cards on the off-white ground
  static const Color white = Color(0xFFFFFFFF);

  /// DESIGN.md §5 BACKGROUND / OFF_WHITE
  static const Color offWhite = Color(0xFFF0F0F0);

  /// DESIGN.md §5 ACCENT / GUITAR_ORANGE
  static const Color orange = Color(0xFFFF4D00);

  /// DESIGN.md §5
  static const Color grey100 = Color(0xFFE5E5E5);

  /// DESIGN.md §5
  static const Color grey200 = Color(0xFFD0D0D0);

  /// DESIGN.md §5
  static const Color grey300 = Color(0xFFB5B5B5);

  /// DESIGN.md §5 — decorative only, fails AA as text on any L Key ground
  static const Color grey400 = Color(0xFF888888);

  /// DESIGN.md §5
  static const Color grey500 = Color(0xFF666666);

  /// DESIGN.md §5
  static const Color grey600 = Color(0xFF333333);

  /// DESIGN.md §6 BACKGROUND
  static const Color darkBackground = Color(0xFF000000);

  /// DESIGN.md §6 SURFACE
  static const Color darkSurface = Color(0xFF111111);

  /// DESIGN.md §6 SURFACE_2
  static const Color darkSurface2 = Color(0xFF1C1C1C);

  /// DESIGN.md §6 PRIMARY_TEXT
  static const Color darkText = Color(0xFFF0F0F0);

  /// DESIGN.md §6 SECONDARY_TEXT
  static const Color darkTextSecondary = Color(0xFF999999);

  /// gap-fill — DESIGN.md §38 requires error states but names no colour
  static const Color danger = Color(0xFFBA1A1A);

  /// gap-fill — DESIGN.md §56 requires status display but names no colour
  static const Color success = Color(0xFF1E7A34);

  /// gap-fill — #BA1A1A is 2.92:1 on the dark surface; DESIGN.md §68 forbids simply inverting
  static const Color dangerDark = Color(0xFFF87171);

  /// gap-fill — #1E7A34 is 3.50:1 on the dark surface
  static const Color successDark = Color(0xFF3DD68C);
}

/// Theme-resolved colour roles. This is the layer feature code uses.
@immutable
final class LkSemanticColors {
  /// Creates a resolved set of semantic colour roles.
  const LkSemanticColors({
    required this.background,
    required this.surface,
    required this.surfaceSunken,
    required this.surfaceInverse,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.border,
    required this.divider,
    required this.accent,
    required this.accentOn,
    required this.focusRing,
    required this.danger,
    required this.success,
    required this.stringLine,
    required this.marker,
    required this.markerOn,
    required this.markerRoot,
    required this.markerRootOn,
  });

  /// The background role.
  final Color background;

  /// The surface role.
  final Color surface;

  /// The surface sunken role.
  final Color surfaceSunken;

  /// The surface inverse role.
  final Color surfaceInverse;

  /// The text primary role.
  final Color textPrimary;

  /// The text secondary role.
  final Color textSecondary;

  /// The text tertiary role.
  final Color textTertiary;

  /// The text inverse role.
  final Color textInverse;

  /// The border role.
  final Color border;

  /// The divider role.
  final Color divider;

  /// The accent role.
  final Color accent;

  /// The accent on role.
  final Color accentOn;

  /// The focus ring role.
  final Color focusRing;

  /// The danger role.
  final Color danger;

  /// The success role.
  final Color success;

  /// The string line role.
  final Color stringLine;

  /// The marker role.
  final Color marker;

  /// The marker on role.
  final Color markerOn;

  /// The marker root role.
  final Color markerRoot;

  /// The marker root on role.
  final Color markerRootOn;

  /// DESIGN.md §5 — light theme.
  static const LkSemanticColors light = LkSemanticColors(
    background: LkPalette.offWhite,
    surface: LkPalette.white,
    surfaceSunken: LkPalette.grey100,
    surfaceInverse: LkPalette.black,
    textPrimary: LkPalette.black,
    textSecondary: LkPalette.grey600,
    textTertiary: LkPalette.grey500,
    textInverse: LkPalette.offWhite,
    border: LkPalette.black,
    divider: LkPalette.black,
    accent: LkPalette.orange,
    accentOn: LkPalette.black,
    focusRing: LkPalette.black,
    danger: LkPalette.danger,
    success: LkPalette.success,
    stringLine: LkPalette.black,
    marker: LkPalette.black,
    markerOn: LkPalette.white,
    markerRoot: LkPalette.orange,
    markerRootOn: LkPalette.black,
  );

  /// DESIGN.md §6 — dark theme.
  static const LkSemanticColors dark = LkSemanticColors(
    background: LkPalette.darkBackground,
    surface: LkPalette.darkSurface,
    surfaceSunken: LkPalette.darkSurface2,
    surfaceInverse: LkPalette.darkText,
    textPrimary: LkPalette.darkText,
    textSecondary: LkPalette.darkTextSecondary,
    textTertiary: LkPalette.darkTextSecondary,
    textInverse: LkPalette.darkBackground,
    border: LkPalette.darkText,
    divider: LkPalette.darkText,
    accent: LkPalette.orange,
    accentOn: LkPalette.black,
    focusRing: LkPalette.orange,
    danger: LkPalette.dangerDark,
    success: LkPalette.successDark,
    stringLine: LkPalette.darkText,
    marker: LkPalette.darkText,
    markerOn: LkPalette.darkBackground,
    markerRoot: LkPalette.orange,
    markerRootOn: LkPalette.black,
  );
}

/// 4px spacing scale from DESIGN.md §14.
abstract final class LkSpacing {
  /// 4px.
  static const double s1 = 4;

  /// 8px.
  static const double s2 = 8;

  /// 12px.
  static const double s3 = 12;

  /// 16px.
  static const double s4 = 16;

  /// 20px.
  static const double s5 = 20;

  /// 24px.
  static const double s6 = 24;

  /// 32px.
  static const double s8 = 32;

  /// 40px.
  static const double s10 = 40;

  /// 48px.
  static const double s12 = 48;

  /// 64px.
  static const double s16 = 64;

  /// 80px.
  static const double s20 = 80;
}

/// Border widths from DESIGN.md §11.
abstract final class LkBorders {
  /// 1px — table grid lines.
  static const double hairline = 1;

  /// 2px — DESIGN.md §11 primary neo-brutalist border.
  static const double regular = 2;

  /// 3px — DESIGN.md §11 important interactive components.
  static const double strong = 3;
}

/// Corner radii from DESIGN.md §12. Zero is the default.
abstract final class LkRadii {
  /// 0px.
  static const double none = 0;

  /// 4px.
  static const double sm = 4;

  /// 8px.
  static const double md = 8;

  /// 9999px — circular avatars and play buttons only.
  static const double pill = 9999;
}

/// Hard offset shadows from DESIGN.md §13. Blur is always zero.
///
/// The colour is theme-dependent, so these are builders rather than
/// constants — pass [LkSemanticColors.border].
abstract final class LkShadows {
  /// 2px offset, no blur — DESIGN.md §13 small component.
  static BoxShadow sm(Color color) =>
      BoxShadow(color: color, offset: const Offset(2, 2));

  /// 4px offset, no blur — DESIGN.md §13 primary.
  static BoxShadow regular(Color color) =>
      BoxShadow(color: color, offset: const Offset(4, 4));

  /// 6px offset, no blur — DESIGN.md §13 large interactive.
  static BoxShadow lg(Color color) =>
      BoxShadow(color: color, offset: const Offset(6, 6));

  /// 1px offset, no blur — DESIGN.md §15 pressed state.
  static BoxShadow pressed(Color color) =>
      BoxShadow(color: color, offset: const Offset(1, 1));
}

/// Motion tokens. DESIGN.md §41 requires short, functional, predictable
/// motion but names no values; these come from the committed design system.
abstract final class LkMotion {
  /// 90ms — press feedback and other immediate responses.
  static const Duration durationFast = Duration(milliseconds: 90);

  /// 140ms — the default transition.
  static const Duration durationBase = Duration(milliseconds: 140);

  /// Standard easing curve for every L Key transition.
  static const Cubic easing = Cubic(0.2, 0, 0, 1);

  /// 3px — DESIGN.md §15 press displacement.
  static const double pressTranslate = 3;
}

/// Component dimensions. DESIGN.md names none of these; values come from
/// the committed design system and WCAG 2.5.5 for the tap target.
abstract final class LkDimens {
  /// 44px — WCAG 2.5.5 / design system --lk-tap-target.
  static const double tapTarget = 44;

  /// 16px — DESIGN.md §14 mobile screen padding.
  static const double screenPadding = 16;

  /// 24px — DESIGN.md §14 tablet/web 24-40, lower bound.
  static const double screenPaddingWide = 24;

  /// 32px — design system --lk-admin-padding.
  static const double adminPadding = 32;

  /// 71px — design system --lk-bottomnav-height.
  static const double bottomNavHeight = 71;

  /// 76px — design system --lk-topbar-height.
  static const double topBarHeight = 76;

  /// 320px — design system --lk-sidebar-width.
  static const double sidebarWidth = 320;

  /// 1232px — design system --lk-content-max.
  static const double contentMaxWidth = 1232;

  /// 28px — design system components/core/AppButton.prompt.md "sm 26px"; measured 26.39 rounded up to the DESIGN.md §14 4px grid so the control clears its line box.
  static const double buttonHeightSm = 28;

  /// 48px — design system components/core/AppButton.jsx sm/md/lg/xl/hero ladder, md.
  static const double buttonHeightMd = 48;

  /// 52px — design system components/core/AppButton.jsx ladder, lg — the default mobile button.
  static const double buttonHeightLg = 52;

  /// 64px — design system components/core/AppButton.prompt.md "hero 61px"; measured 60.8 rounded up to the 4px grid.
  static const double buttonHeightHero = 64;

  /// 32px — design system components/core/AppIconButton.jsx painted box, small.
  static const double iconBoxSm = 32;

  /// 36px — design system components/core/AppIconButton.jsx default size.
  static const double iconBoxMd = 36;

  /// 48px — design system components/core/AppIconButton.jsx large, used for the Quick Tune play control.
  static const double iconBoxLg = 48;

  /// 64px — design system ui_kits/mobile_app/HomeScreen.jsx Import Tab circular mark.
  static const double iconBoxCircle = 64;

  /// 48px — design system components/core/AppTextField.jsx minHeight 45.59 rounded up to the 4px grid and to WCAG 2.5.5.
  static const double textFieldMinHeight = 48;

  /// 64px — design system components/navigation/BottomNavBar.prompt.md "active tab becomes a 64px Guitar Orange block".
  static const double navItemMinWidth = 64;

  /// 20px — design system components/navigation/BottomNavBar.jsx icon slot height 18, rounded up to the 4px grid.
  static const double navIconSlot = 20;

  /// 128px — design system components/music/SongCard.jsx artwork height.
  static const double songArtworkHeight = 128;

  /// 32px — design system components/music/PracticeProgress.jsx track height.
  static const double progressTrackHeight = 32;

  /// 3px — design system --lk-focus-width.
  static const double focusRingWidth = 3;

  /// 2px — design system --lk-focus-offset.
  static const double focusRingOffset = 2;

  /// 278px — design system components/music/ChordDiagram.jsx default width — the 342px card minus 32px padding either side.
  static const double chordDiagramWidth = 278;

  /// 256px — design system components/music/ChordDiagram.jsx gridH.
  static const double chordDiagramGridHeight = 256;

  /// 16px — design system components/music/ChordDiagram.jsx nut bar height.
  static const double chordNutHeight = 16;

  /// 4px — design system components/music/ChordDiagram.jsx string line width.
  static const double chordStringWidth = 4;

  /// 2px — design system components/music/ChordDiagram.jsx fret line height.
  static const double chordFretLineWidth = 2;

  /// 36px — design system components/music/ChordDiagram.jsx finger marker box.
  static const double chordMarkerSize = 36;
}

/// Unitless opacity values. Separate from [LkDimens] because these
/// carry no unit; a dimension would render as `0.4px` on the web.
abstract final class LkOpacity {
  /// 0.4 — design system guidelines/brand-press.card.html "Disabled is 40% opacity, never a grey re-tint".
  static const double disabled = 0.4;

  /// 0.2 — design system --lk-stripe; the 45° hatch over an orange progress fill.
  static const double stripe = 0.2;
}

/// Font families from DESIGN.md §8.
abstract final class LkFonts {
  /// DESIGN.md §8 Display
  static const String display = 'Space Grotesk';

  /// DESIGN.md §8 Body
  static const String body = 'Hanken Grotesk';

  /// DESIGN.md §8 Technical
  static const String mono = 'JetBrains Mono';

  /// gap-fill — the three brand faces carry no Burmese glyphs; see docs/adr/0006-myanmar-font-fallback.md
  static const String myanmar = 'Noto Sans Myanmar';

  /// Appended to every text style so Burmese renders instead of tofu.
  static const List<String> fallback = <String>[myanmar];

  /// DESIGN.md §36 requires Burmese font size and line wrapping be tested rather than assumed; Burmese stacked diacritics clip at the Latin line heights, which are as tight as 0.95
  static const double myanmarLineHeight = 1.5;
}

/// Type scale from DESIGN.md §9-10.
///
/// `letterSpacing` is stored in em in tokens.json and resolved to logical
/// pixels here, because Flutter expects an absolute value.
abstract final class LkTypeScale {
  /// DESIGN.md §9 Display XL 48-64, upper bound
  static const TextStyle displayXl = TextStyle(
    fontFamily: 'Space Grotesk',
    fontFamilyFallback: LkFonts.fallback,
    fontSize: 64,
    height: 0.95,
    letterSpacing: -3.2,
    fontWeight: FontWeight.w700,
  );

  /// DESIGN.md §9 Display 36-48, upper bound
  static const TextStyle display = TextStyle(
    fontFamily: 'Space Grotesk',
    fontFamilyFallback: LkFonts.fallback,
    fontSize: 48,
    height: 1.1,
    letterSpacing: -0.96,
    fontWeight: FontWeight.w700,
  );

  /// DESIGN.md §9 H1
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Space Grotesk',
    fontFamilyFallback: LkFonts.fallback,
    fontSize: 32,
    height: 1.1,
    letterSpacing: -1.6,
    fontWeight: FontWeight.w700,
  );

  /// DESIGN.md §9 H2
  static const TextStyle h2 = TextStyle(
    fontFamily: 'Space Grotesk',
    fontFamilyFallback: LkFonts.fallback,
    fontSize: 24,
    height: 1.2,
    letterSpacing: -1.2,
    fontWeight: FontWeight.w700,
  );

  /// DESIGN.md §9 H3
  static const TextStyle h3 = TextStyle(
    fontFamily: 'Space Grotesk',
    fontFamilyFallback: LkFonts.fallback,
    fontSize: 20,
    height: 1.5,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
  );

  /// design system --lk-size-h4 18 / --lk-lh-h4 28; DESIGN.md §9 names no display step at 18
  static const TextStyle h4 = TextStyle(
    fontFamily: 'Space Grotesk',
    fontFamilyFallback: LkFonts.fallback,
    fontSize: 18,
    height: 1.5556,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
  );

  /// DESIGN.md §9 Body Large
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Hanken Grotesk',
    fontFamilyFallback: LkFonts.fallback,
    fontSize: 18,
    height: 1.6,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
  );

  /// DESIGN.md §9 Body
  static const TextStyle body = TextStyle(
    fontFamily: 'Hanken Grotesk',
    fontFamilyFallback: LkFonts.fallback,
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
  );

  /// DESIGN.md §9 Body Small
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Hanken Grotesk',
    fontFamilyFallback: LkFonts.fallback,
    fontSize: 14,
    height: 1.5,
    letterSpacing: 0,
    fontWeight: FontWeight.w400,
  );

  /// DESIGN.md §9 Label
  static const TextStyle label = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontFamilyFallback: LkFonts.fallback,
    fontSize: 12,
    height: 1.2,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
  );

  /// DESIGN.md §9 Technical 12-16, upper bound
  static const TextStyle technicalLg = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontFamilyFallback: LkFonts.fallback,
    fontSize: 16,
    height: 1.5,
    letterSpacing: 0.8,
    fontWeight: FontWeight.w500,
  );

  /// DESIGN.md §9-10 Technical with tracking
  static const TextStyle technical = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontFamilyFallback: LkFonts.fallback,
    fontSize: 14,
    height: 1.4,
    letterSpacing: 0.7,
    fontWeight: FontWeight.w500,
  );

  /// DESIGN.md §9 Technical 12-16, lower bound
  static const TextStyle technicalSm = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontFamilyFallback: LkFonts.fallback,
    fontSize: 12,
    height: 1.2,
    letterSpacing: 0.6,
    fontWeight: FontWeight.w500,
  );
}
