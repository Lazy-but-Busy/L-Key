import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/shared/widgets/lk_pressable.dart';

/// The button ladder from the design system's `AppButton`.
enum LkButtonSize {
  /// 28px — compact, for dense rows. Its hit area is still 44px.
  small,

  /// 48px — mono uppercase label.
  medium,

  /// 52px — the default mobile button.
  large,

  /// 64px — hero calls to action.
  hero,
}

/// The four button roles from DESIGN.md §15.
enum LkButtonVariant {
  /// Black fill, inverse text. The default.
  primary,

  /// Guitar Orange fill, black text. Reserved for the one important action.
  accent,

  /// Surface fill, primary text.
  secondary,

  /// No fill. Boundary only.
  ghost,
}

/// The L Key button.
///
/// One visual definition, extended by [variant] and [size] rather than forked
/// into per-screen subclasses (DESIGN.md §67). Every size clears the 44px tap
/// target because [LkPressable] floors interactive surfaces there — the
/// design system's own 26px small button does not, which would fail
/// WCAG 2.5.5.
class LkButton extends StatelessWidget {
  /// Creates a button.
  const LkButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = LkButtonVariant.primary,
    this.size = LkButtonSize.large,
    this.icon,
    this.iconAtEnd = false,
    this.block = false,
    this.semanticLabel,
  });

  /// The visible, already-localised label.
  final String label;

  /// Tap handler. Null disables the button.
  final VoidCallback? onPressed;

  /// Colour role.
  final LkButtonVariant variant;

  /// Height and typography step.
  final LkButtonSize size;

  /// Optional leading glyph.
  final Widget? icon;

  /// Whether [icon] sits after the label instead of before it.
  final bool iconAtEnd;

  /// Whether the button fills the width available to it.
  final bool block;

  /// Overrides the label for screen readers when the visible text is terse.
  final String? semanticLabel;

  double get _height => switch (size) {
    LkButtonSize.small => LkDimens.buttonHeightSm,
    LkButtonSize.medium => LkDimens.buttonHeightMd,
    LkButtonSize.large => LkDimens.buttonHeightLg,
    LkButtonSize.hero => LkDimens.buttonHeightHero,
  };

  TextStyle _textStyle(BuildContext context) => switch (size) {
    LkButtonSize.small => context.lkType.label,
    LkButtonSize.medium => context.lkType.technical,
    LkButtonSize.large => context.lkType.h4,
    LkButtonSize.hero => context.lkType.h2,
  };

  /// DESIGN.md §10 — uppercase is how a technical label reads. The hero size
  /// is a sentence, not a legend, so it keeps its casing.
  bool get _uppercase => size != LkButtonSize.hero;

  EdgeInsets get _padding => switch (size) {
    LkButtonSize.small => const EdgeInsets.symmetric(
      horizontal: LkSpacing.s3,
    ),
    LkButtonSize.medium => const EdgeInsets.symmetric(
      horizontal: LkSpacing.s6,
    ),
    LkButtonSize.large => const EdgeInsets.symmetric(
      horizontal: LkSpacing.s4,
      vertical: LkSpacing.s3,
    ),
    LkButtonSize.hero => const EdgeInsets.symmetric(
      horizontal: LkSpacing.s6,
      vertical: LkSpacing.s4,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    final (Color? background, Color foreground) = switch (variant) {
      LkButtonVariant.primary => (colors.surfaceInverse, colors.textInverse),
      LkButtonVariant.accent => (colors.accent, colors.accentOn),
      LkButtonVariant.secondary => (colors.surface, colors.textPrimary),
      LkButtonVariant.ghost => (null, colors.textPrimary),
    };

    // The small size carries only a boundary; the rest carry the hard shadow.
    final elevation = size == LkButtonSize.small
        ? LkElevation.none
        : LkElevation.regular;

    final text = Text(
      _uppercase ? label.toUpperCase() : label,
      style: _textStyle(context).copyWith(color: foreground),
      textAlign: TextAlign.center,
    );

    final glyph = icon;
    final content = glyph == null
        ? text
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: LkSpacing.s2,
            children: iconAtEnd
                ? <Widget>[Flexible(child: text), glyph]
                : <Widget>[glyph, Flexible(child: text)],
          );

    return LkPressable(
      onTap: onPressed,
      enabled: onPressed != null,
      background: background,
      elevation: elevation,
      minHeight: _height,
      padding: _padding,
      semanticLabel: semanticLabel ?? label,
      child: Align(
        widthFactor: block ? null : 1.0,
        child: IconTheme.merge(
          data: IconThemeData(color: foreground),
          child: content,
        ),
      ),
    );
  }
}
