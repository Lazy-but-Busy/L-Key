import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// A placeholder block standing in for content that is still loading.
///
/// DESIGN.md §39 prefers a skeleton to a spinner. It is deliberately static:
/// §41 forbids animating merely because animation is possible, and a shimmer
/// would need a gradient, which the system bans outright. The blocks read as
/// structure rather than as content because they carry no text.
class LkSkeleton extends StatelessWidget {
  /// Creates a single placeholder block.
  const LkSkeleton({super.key, this.height = LkSpacing.s4, this.width});

  /// Block height. Defaults to one line of body text.
  final double height;

  /// Block width. Defaults to filling the available width.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Semantics(
      excludeSemantics: true,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          border: Border.all(color: colors.divider),
        ),
      ),
    );
  }
}

/// A column of [LkSkeleton] cards approximating a list of content.
class LkSkeletonList extends StatelessWidget {
  /// Creates a placeholder list of [itemCount] rows.
  const LkSkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = LkDimens.buttonHeightHero,
    this.semanticLabel,
  });

  /// How many placeholder rows to draw.
  final int itemCount;

  /// Height of each row.
  final double itemHeight;

  /// Announced to screen readers so the wait is not silent.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      liveRegion: semanticLabel != null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: LkSpacing.s4,
        children: <Widget>[
          for (var i = 0; i < itemCount; i++) LkSkeleton(height: itemHeight),
        ],
      ),
    );
  }
}
