import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// A row of mutually exclusive choices sharing one boundary.
///
/// The selected segment fills with the inverse surface and the rest stay on
/// the surface colour, so the choice is carried by fill and by the selected
/// semantics — never by colour alone (DESIGN.md §42).
class LkSegmentedControl<T> extends StatelessWidget {
  /// Creates a segmented control.
  const LkSegmentedControl({
    required this.segments,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  /// The choices, in display order, keyed by value.
  final Map<T, String> segments;

  /// The currently selected value.
  final T selected;

  /// Called with the newly selected value.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final entries = segments.entries.toList();

    // Scrolls rather than clipping: DESIGN.md §43 covers small phones through
    // tablets, and a four-segment group does not fit a narrow device once
    // Burmese labels are longer than their English equivalents.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.border, width: LkBorders.regular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (var i = 0; i < entries.length; i++)
              _Segment<T>(
                label: entries[i].value,
                isSelected: entries[i].key == selected,
                showDivider: i > 0,
                onTap: () => onChanged(entries[i].key),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.showDivider,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: LkDimens.tapTarget),
          padding: const EdgeInsets.symmetric(horizontal: LkSpacing.s3),
          decoration: BoxDecoration(
            color: isSelected ? colors.surfaceInverse : colors.surface,
            border: showDivider
                ? Border(
                    left: BorderSide(
                      color: colors.border,
                      width: LkBorders.regular,
                    ),
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label.toUpperCase(),
            style: LkTypeScale.label.copyWith(
              color: isSelected ? colors.textInverse : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
