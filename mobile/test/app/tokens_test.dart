import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// WCAG 2.1 relative luminance.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('design tokens', () {
    test('spacing follows the 4px scale from DESIGN.md §14', () {
      for (final v in <double>[
        LkSpacing.s1,
        LkSpacing.s2,
        LkSpacing.s3,
        LkSpacing.s4,
        LkSpacing.s5,
        LkSpacing.s6,
        LkSpacing.s8,
        LkSpacing.s10,
        LkSpacing.s12,
        LkSpacing.s16,
        LkSpacing.s20,
      ]) {
        expect(v % 4, 0, reason: '$v is not a multiple of 4');
      }
    });

    test('shadows are hard — blur is always zero (DESIGN.md §13)', () {
      for (final s in <BoxShadow>[
        LkShadows.sm(LkPalette.black),
        LkShadows.regular(LkPalette.black),
        LkShadows.lg(LkPalette.black),
        LkShadows.pressed(LkPalette.black),
      ]) {
        expect(s.blurRadius, 0);
      }
    });

    test('default radius is zero (DESIGN.md §12)', () {
      expect(LkRadii.none, 0);
    });

    test('the tap target meets WCAG 2.5.5', () {
      expect(LkDimens.tapTarget, greaterThanOrEqualTo(44));
    });

    test('every type style carries the Myanmar fallback', () {
      // Without this, Burmese renders as tofu in every brand face.
      for (final s in <TextStyle>[
        LkTypeScale.displayXl,
        LkTypeScale.display,
        LkTypeScale.h1,
        LkTypeScale.h2,
        LkTypeScale.h3,
        LkTypeScale.bodyLarge,
        LkTypeScale.body,
        LkTypeScale.bodySmall,
        LkTypeScale.label,
        LkTypeScale.technicalLg,
        LkTypeScale.technical,
        LkTypeScale.technicalSm,
      ]) {
        expect(
          s.fontFamilyFallback,
          contains(LkFonts.myanmar),
          reason: '${s.fontFamily} is missing the Burmese fallback',
        );
      }
    });

    test('text roles meet WCAG AA in both themes', () {
      for (final c in <LkSemanticColors>[
        LkSemanticColors.light,
        LkSemanticColors.dark,
      ]) {
        for (final pair in <List<Color>>[
          <Color>[c.textPrimary, c.background],
          <Color>[c.textSecondary, c.background],
          <Color>[c.textTertiary, c.background],
          <Color>[c.textPrimary, c.surface],
          <Color>[c.textTertiary, c.surface],
          <Color>[c.accentOn, c.accent],
          <Color>[c.danger, c.surface],
          <Color>[c.success, c.surface],
        ]) {
          expect(
            _contrast(pair[0], pair[1]),
            greaterThanOrEqualTo(4.5),
            reason: 'contrast below AA for ${pair[0]} on ${pair[1]}',
          );
        }
      }
    });
  });
}
