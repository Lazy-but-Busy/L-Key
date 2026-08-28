import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/shared/widgets/lk_pressable.dart';

/// How a card establishes its boundary.
enum LkCardVariant {
  /// Hard shadow only. The mobile default — the Figma frames draw app cards
  /// this way, without a ring.
  shadow,

  /// 2px boundary plus the hard shadow.
  ring,

  /// Neither. For a card nested inside another bounded surface.
  flat,
}

/// The card fill roles.
enum LkCardTone {
  /// White in light, `#111111` in dark.
  surface,

  /// One step back from [surface].
  sunken,

  /// Guitar Orange. Reserved for the single most important card on a screen.
  accent,

  /// Inverted — black in light.
  inverse,
}

/// A content card following the DESIGN.md §17 anatomy:
/// category → title → metadata → action.
///
/// Passing [onTap] makes the whole card pressable, which is how the Quick
/// Tune and song cards behave.
class LkCard extends StatelessWidget {
  /// Creates a card.
  const LkCard({
    required this.child,
    super.key,
    this.label,
    this.title,
    this.action,
    this.variant = LkCardVariant.shadow,
    this.tone = LkCardTone.surface,
    this.padding,
    this.onTap,
    this.semanticLabel,
  });

  /// The card body.
  final Widget child;

  /// Optional uppercase category line above the title.
  final String? label;

  /// Optional title.
  final String? title;

  /// Optional trailing control on the title row.
  final Widget? action;

  /// Boundary treatment.
  final LkCardVariant variant;

  /// Fill role.
  final LkCardTone tone;

  /// Inner padding. Defaults to the 24px mobile card padding.
  final EdgeInsetsGeometry? padding;

  /// Makes the entire card a single tap target.
  final VoidCallback? onTap;

  /// Accessible label used when [onTap] is set.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    final background = switch (tone) {
      LkCardTone.surface => colors.surface,
      LkCardTone.sunken => colors.surfaceSunken,
      LkCardTone.accent => colors.accent,
      LkCardTone.inverse => colors.surfaceInverse,
    };
    final foreground = switch (tone) {
      LkCardTone.accent => colors.accentOn,
      LkCardTone.inverse => colors.textInverse,
      _ => colors.textPrimary,
    };
    final muted = switch (tone) {
      LkCardTone.accent => colors.accentOn,
      LkCardTone.inverse => colors.textInverse,
      _ => colors.textSecondary,
    };

    final header = <Widget>[
      if (label != null)
        Text(
          label!.toUpperCase(),
          style: context.lkType.label.copyWith(color: muted),
        ),
      if (title != null || action != null)
        Row(
          children: <Widget>[
            Expanded(
              child: title == null
                  ? const SizedBox.shrink()
                  : Text(
                      title!,
                      style: context.lkType.h2.copyWith(color: foreground),
                    ),
            ),
            ?action,
          ],
        ),
    ];

    return LkPressable(
      onTap: onTap,
      background: background,
      bordered: variant == LkCardVariant.ring,
      elevation: variant == LkCardVariant.flat
          ? LkElevation.none
          : LkElevation.regular,
      padding: padding ?? const EdgeInsets.all(LkSpacing.s6),
      minHeight: 0,
      minWidth: 0,
      semanticLabel: semanticLabel,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: LkSpacing.s4,
          children: <Widget>[
            if (header.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: LkSpacing.s2,
                children: header,
              ),
            child,
          ],
        ),
      ),
    );
  }
}
