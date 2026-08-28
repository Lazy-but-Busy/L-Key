import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// The empty state: nothing is wrong, there is simply nothing here yet.
///
/// DESIGN.md §37 asks for personality without decoration — an uppercase
/// headline and one quiet line beneath it. No illustration, no emoji.
///
/// Empty is a fact about the data, not about the request, which is why it is
/// a plain widget rather than a branch of `AsyncValue` (ADR-0002).
class LkEmptyState extends StatelessWidget {
  /// Creates an empty state.
  const LkEmptyState({
    required this.headline,
    super.key,
    this.body,
    this.action,
    this.centered = true,
  });

  /// Short localised headline, rendered uppercase.
  final String headline;

  /// Optional localised sentence beneath the headline.
  final String? body;

  /// Optional call to action.
  final Widget? action;

  /// Whether the content centres or aligns to the start.
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final text = body;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border, width: LkBorders.regular),
      ),
      child: Padding(
        padding: const EdgeInsets.all(LkSpacing.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: centered
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          spacing: LkSpacing.s3,
          children: <Widget>[
            Text(
              headline.toUpperCase(),
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: context.lkType.h2.copyWith(color: colors.textPrimary),
            ),
            if (text != null)
              Text(
                text,
                textAlign: centered ? TextAlign.center : TextAlign.start,
                style: context.lkType.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ?action,
          ],
        ),
      ),
    );
  }
}
