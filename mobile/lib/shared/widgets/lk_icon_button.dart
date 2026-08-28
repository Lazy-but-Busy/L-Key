import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/shared/widgets/lk_pressable.dart';

/// The icon-button fill roles.
enum LkIconButtonVariant {
  /// Surface fill with a hard shadow.
  plain,

  /// Surface fill, boundary only.
  ring,

  /// Inverted fill.
  solid,

  /// Guitar Orange fill.
  accent,

  /// No fill and no boundary — for a bare overflow glyph.
  bare,
}

/// A square icon control.
///
/// The painted box may be smaller than the 44px minimum, but the gesture box
/// never is: [LkPressable] floors interactive surfaces at the tap target and
/// the painted box is centred inside it. That is how the design system keeps
/// a 28px glyph accessible.
class LkIconButton extends StatelessWidget {
  /// Creates an icon button.
  const LkIconButton({
    required this.icon,
    required this.semanticLabel,
    super.key,
    this.onPressed,
    this.variant = LkIconButtonVariant.plain,
    this.size = LkDimens.iconBoxMd,
    this.circular = false,
  });

  /// The glyph.
  final IconData icon;

  /// Accessible label. Required — an icon alone says nothing to a screen
  /// reader (DESIGN.md §42).
  final String semanticLabel;

  /// Tap handler. Null disables the control.
  final VoidCallback? onPressed;

  /// Fill role.
  final LkIconButtonVariant variant;

  /// Painted box size. The hit area stays at 44px regardless.
  final double size;

  /// Whether the painted box is a circle. Reserved for genuinely circular
  /// objects such as the play control (DESIGN.md §12).
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    final (Color background, Color foreground) = switch (variant) {
      LkIconButtonVariant.plain => (colors.surface, colors.textPrimary),
      LkIconButtonVariant.ring => (colors.surface, colors.textPrimary),
      LkIconButtonVariant.solid => (
        colors.surfaceInverse,
        colors.textInverse,
      ),
      LkIconButtonVariant.accent => (colors.accent, colors.accentOn),
      // Transparent, not null: a null background falls back to the surface
      // colour and would paint a box around a glyph meant to sit bare.
      LkIconButtonVariant.bare => (Colors.transparent, colors.textPrimary),
    };

    final elevation = switch (variant) {
      LkIconButtonVariant.plain => LkElevation.small,
      LkIconButtonVariant.bare => LkElevation.none,
      _ => LkElevation.none,
    };

    final box = SizedBox.square(
      dimension: size,
      child: Center(
        child: Icon(icon, size: LkSpacing.s5, color: foreground),
      ),
    );

    return LkPressable(
      onTap: onPressed,
      enabled: onPressed != null,
      background: background,
      bordered: variant != LkIconButtonVariant.bare,
      elevation: elevation,
      borderRadius: circular ? LkRadii.pill : LkRadii.none,
      semanticLabel: semanticLabel,
      child: Center(child: box),
    );
  }
}
