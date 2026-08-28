import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// A rectangular, high-contrast text input.
///
/// DESIGN.md §16 asks for a clearly labelled rectangle and warns off floating
/// labels, so the caption sits above the field and stays there.
class LkTextField extends StatelessWidget {
  /// Creates a text field.
  const LkTextField({
    required this.label,
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.icon,
    this.hideLabel = false,
  });

  /// Localised caption. Always announced, even when [hideLabel] is set.
  final String label;

  /// Localised placeholder.
  final String? hint;

  /// Optional external controller.
  final TextEditingController? controller;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Optional leading glyph.
  final IconData? icon;

  /// Hides the visible caption when the placeholder already carries it.
  /// The label still reaches screen readers.
  final bool hideLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final glyph = icon;

    final field = Container(
      constraints: const BoxConstraints(
        minHeight: LkDimens.textFieldMinHeight,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border, width: LkBorders.regular),
        boxShadow: <BoxShadow>[LkShadows.sm(colors.border)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: LkSpacing.s3),
      child: Row(
        spacing: LkSpacing.s3,
        children: <Widget>[
          if (glyph != null)
            Icon(glyph, size: LkSpacing.s5, color: colors.textSecondary),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: LkTypeScale.technical.copyWith(
                color: colors.textPrimary,
              ),
              cursorColor: colors.textPrimary,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: hint,
                hintStyle: LkTypeScale.technical.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      textField: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: LkSpacing.s1,
        children: <Widget>[
          if (!hideLabel)
            Text(
              label.toUpperCase(),
              style: LkTypeScale.label.copyWith(color: colors.textSecondary),
            ),
          field,
        ],
      ),
    );
  }
}
