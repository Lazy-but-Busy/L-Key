import 'package:flutter/material.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// Carries the generated [LkSemanticColors] through [ThemeData] so widgets
/// resolve colours from the active theme rather than importing a palette.
///
/// DESIGN.md §66 forbids scattering raw colour values through widgets; this
/// extension is the supported way to reach them. Read it via
/// `context.lkColors`, never by importing [LkPalette] directly.
@immutable
class LkColorsExtension extends ThemeExtension<LkColorsExtension> {
  /// Wraps a resolved semantic colour set.
  const LkColorsExtension(this.colors);

  /// The semantic roles for the active theme.
  final LkSemanticColors colors;

  @override
  LkColorsExtension copyWith({LkSemanticColors? colors}) {
    return LkColorsExtension(colors ?? this.colors);
  }

  @override
  LkColorsExtension lerp(
    covariant ThemeExtension<LkColorsExtension>? other,
    double t,
  ) {
    if (other is! LkColorsExtension) return this;
    // The L Key palette is a hard monochrome system: DESIGN.md §13 and §41
    // describe instant, tactile state changes rather than colour cross-fades.
    // Snapping at the midpoint avoids inventing intermediate greys that are
    // not in the ramp and that no contrast pair has been verified against.
    return t < 0.5 ? this : other;
  }
}

/// Convenience access to the semantic colour roles for the active theme.
extension LkColorsContext on BuildContext {
  /// The semantic colours of the nearest [Theme].
  ///
  /// Falls back to the light set if the extension is missing, which can only
  /// happen inside a bare [MaterialApp] created in a test.
  LkSemanticColors get lkColors =>
      Theme.of(this).extension<LkColorsExtension>()?.colors ??
      LkSemanticColors.light;
}
