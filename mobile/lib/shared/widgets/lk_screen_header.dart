import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// The uppercase title and technical subtitle every section screen opens with.
class LkScreenHeader extends StatelessWidget {
  /// Creates a screen header.
  const LkScreenHeader({required this.title, super.key, this.subtitle});

  /// The already-localised screen title.
  final String title;

  /// Optional technical subtitle beneath it.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final sub = subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: LkSpacing.s2,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            title.toUpperCase(),
            style: LkTypeScale.h1.copyWith(color: colors.textPrimary),
          ),
        ),
        if (sub != null)
          Text(
            sub.toUpperCase(),
            style: LkTypeScale.technical.copyWith(
              color: colors.textTertiary,
            ),
          ),
      ],
    );
  }
}

/// A short, honest note that a surface is intentionally not built yet.
///
/// CLAUDE.md §47 forbids faking functionality. Where a screen shows a static
/// layout because its engine has not been written, it says so here rather
/// than letting mock values read as real measurements.
class LkPendingNote extends StatelessWidget {
  /// Creates a pending note.
  const LkPendingNote({required this.message, super.key});

  /// The already-localised explanation.
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(LkSpacing.s4),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        border: Border.all(color: colors.border),
      ),
      child: Text(
        message,
        style: LkTypeScale.bodySmall.copyWith(color: colors.textSecondary),
      ),
    );
  }
}
