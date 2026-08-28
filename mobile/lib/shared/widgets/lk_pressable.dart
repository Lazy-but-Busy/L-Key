import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/utils/reduced_motion.dart';

/// The hard-offset shadow depths DESIGN.md §13 defines. Blur is always zero.
enum LkElevation {
  /// No shadow. The surface relies on its border for a boundary.
  none,

  /// 2px offset — small components.
  small,

  /// 4px offset — the default.
  regular,

  /// 6px offset — large interactive surfaces.
  large,
}

/// A tappable neo-brutalist surface.
///
/// This is the one place the DESIGN.md §15 press is implemented: the surface
/// translates 3px toward its shadow while the shadow drops to 1px, so the
/// control appears to be pushed into the page. Every pressable component in
/// the app composes this rather than repeating the behaviour, which is what
/// DESIGN.md §67 asks for.
///
/// An orange fill never establishes its own boundary — it is only 2.92:1 on
/// the light ground — so [bordered] defaults to true and callers using an
/// accent [background] must leave it that way. See ADR-0003.
class LkPressable extends StatefulWidget {
  /// Creates a pressable surface.
  const LkPressable({
    required this.child,
    super.key,
    this.onTap,
    this.background,
    this.bordered = true,
    this.elevation = LkElevation.regular,
    this.padding,
    this.minHeight,
    this.minWidth,
    this.semanticLabel,
    this.selected = false,
    this.enabled = true,
    this.borderRadius = LkRadii.none,
  });

  /// The surface content.
  final Widget child;

  /// Called on tap. A null callback renders the surface as non-interactive.
  final VoidCallback? onTap;

  /// Fill colour. Defaults to the theme's surface role.
  final Color? background;

  /// Whether to draw the 2px boundary from DESIGN.md §11.
  final bool bordered;

  /// Shadow depth.
  final LkElevation elevation;

  /// Inner padding.
  final EdgeInsetsGeometry? padding;

  /// Minimum height. Interactive surfaces are floored at the 44px tap target.
  final double? minHeight;

  /// Minimum width. Interactive surfaces are floored at the 44px tap target.
  final double? minWidth;

  /// Accessible label. Required by DESIGN.md §42 for anything interactive.
  final String? semanticLabel;

  /// Whether this surface represents a selected choice, for screen readers.
  final bool selected;

  /// Whether the control accepts input. Disabled controls render at 40%.
  final bool enabled;

  /// Corner radius. Zero is the design language (DESIGN.md §12); a pill is
  /// reserved for genuinely circular objects.
  final double borderRadius;

  @override
  State<LkPressable> createState() => _LkPressableState();
}

class _LkPressableState extends State<LkPressable> {
  bool _pressed = false;

  bool get _interactive => widget.onTap != null && widget.enabled;

  void _setPressed({required bool value}) {
    if (!_interactive || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final ink = colors.border;
    final shadow = _resolveShadow(ink);

    // Interactive surfaces must clear WCAG 2.5.5 even when the design calls
    // for a visually smaller box.
    final minHeight =
        widget.minHeight ?? (_interactive ? LkDimens.tapTarget : 0.0);
    final minWidth =
        widget.minWidth ?? (_interactive ? LkDimens.tapTarget : 0.0);

    final offset = _pressed ? LkMotion.pressTranslate : 0.0;

    final surface = AnimatedContainer(
      duration: context.motion(LkMotion.durationFast),
      curve: LkMotion.easing,
      transform: Matrix4.translationValues(offset, offset, 0),
      constraints: BoxConstraints(minHeight: minHeight, minWidth: minWidth),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.background ?? colors.surface,
        border: widget.bordered
            ? Border.all(color: ink, width: LkBorders.regular)
            : null,
        boxShadow: shadow == null ? null : <BoxShadow>[shadow],
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: widget.child,
    );

    final opaque = Opacity(
      opacity: widget.enabled ? 1.0 : LkOpacity.disabled,
      child: surface,
    );

    if (!_interactive) {
      return widget.semanticLabel == null
          ? opaque
          : Semantics(label: widget.semanticLabel, child: opaque);
    }

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(value: true),
        onTapUp: (_) => _setPressed(value: false),
        onTapCancel: () => _setPressed(value: false),
        behavior: HitTestBehavior.opaque,
        child: opaque,
      ),
    );
  }

  BoxShadow? _resolveShadow(Color ink) {
    if (widget.elevation == LkElevation.none) return null;
    if (_pressed) return LkShadows.pressed(ink);
    return switch (widget.elevation) {
      LkElevation.none => null,
      LkElevation.small => LkShadows.sm(ink),
      LkElevation.regular => LkShadows.regular(ink),
      LkElevation.large => LkShadows.lg(ink),
    };
  }
}
