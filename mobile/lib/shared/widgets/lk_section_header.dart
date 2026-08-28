import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// Separates the sections of a screen.
///
/// Titles are always uppercase; the optional trailing action is set in the
/// technical face, per the design system's `AppSectionHeader`.
class LkSectionHeader extends StatelessWidget {
  /// Creates a section header.
  const LkSectionHeader({
    required this.title,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  /// The already-localised section title.
  final String title;

  /// Optional localised label for the trailing action.
  final String? actionLabel;

  /// Called when the trailing action is tapped.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final label = actionLabel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: LkSpacing.s4,
      children: <Widget>[
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: LkTypeScale.h2.copyWith(color: colors.textPrimary),
          ),
        ),
        if (label != null)
          Semantics(
            button: true,
            label: label,
            child: GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: LkDimens.tapTarget,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: LkSpacing.s1,
                  children: <Widget>[
                    Text(
                      label.toUpperCase(),
                      style: LkTypeScale.technical.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: LkSpacing.s3,
                      color: colors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
