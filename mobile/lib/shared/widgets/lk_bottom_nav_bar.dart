import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// One destination in [LkBottomNavBar].
@immutable
class LkNavDestination {
  /// Creates a destination.
  const LkNavDestination({required this.icon, required this.label});

  /// The glyph.
  ///
  /// The design system's own tab art (settings-alt, graduation-cap,
  /// library-music, users) ships as SVG only, and its readme says to replace
  /// those assignments once the Flutter build has real art. Material glyphs
  /// stand in until then rather than adding an SVG dependency for five icons.
  final IconData icon;

  /// The already-localised label.
  final String label;
}

/// The five-section bottom navigation from DESIGN.md §19.
///
/// The active tab is a Guitar Orange block with a hard shadow — no underline
/// indicator, and never icon-only. Because orange is only 2.92:1 on the light
/// ground it can never carry the state alone, so the block also takes a
/// boundary and the item reports itself as selected (ADR-0003).
class LkBottomNavBar extends StatelessWidget {
  /// Creates the navigation bar.
  const LkBottomNavBar({
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  /// The five destinations.
  final List<LkNavDestination> destinations;

  /// Index of the active destination.
  final int currentIndex;

  /// Called with the index of the tapped destination.
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Container(
      height: LkDimens.bottomNavHeight,
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(color: colors.border, width: LkBorders.regular),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: LkSpacing.s2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          for (var i = 0; i < destinations.length; i++)
            _NavItem(
              destination: destinations[i],
              isSelected: i == currentIndex,
              onTap: () => onSelected(i),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final LkNavDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final foreground = isSelected ? colors.accentOn : colors.textPrimary;

    return Semantics(
      button: true,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      label: destination.label,
      // The icon and caption are decorative once the item is labelled;
      // without this a screen reader announces the label twice.
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(
            minWidth: LkDimens.tapTarget,
            minHeight: LkDimens.tapTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: LkSpacing.s2,
            vertical: LkSpacing.s1,
          ),
          decoration: isSelected
              ? BoxDecoration(
                  color: colors.accent,
                  border: Border.all(
                    color: colors.border,
                    width: LkBorders.regular,
                  ),
                  boxShadow: <BoxShadow>[LkShadows.sm(colors.border)],
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: LkSpacing.s1,
            children: <Widget>[
              Icon(
                destination.icon,
                size: LkDimens.navIconSlot,
                color: foreground,
              ),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LkTypeScale.label.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
