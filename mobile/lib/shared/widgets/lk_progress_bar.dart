import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/tokens.g.dart';

/// A progress track with the system's 45° hatch over an orange fill.
///
/// The hatch is the one repeating pattern the design system allows, and it is
/// what keeps progress legible without relying on the orange alone — which is
/// only 2.92:1 on the light ground (ADR-0003). The fill always carries a
/// boundary for the same reason.
class LkProgressBar extends StatelessWidget {
  /// Creates a progress bar showing [value] of [max].
  const LkProgressBar({
    required this.value,
    required this.max,
    required this.semanticLabel,
    super.key,
    this.height = LkDimens.progressTrackHeight,
  });

  /// Completed amount. Clamped into range.
  final double value;

  /// Total amount. Values at or below zero render as empty.
  final double max;

  /// Announced together with the percentage.
  final String semanticLabel;

  /// Track height.
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final fraction = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);

    return Semantics(
      label: semanticLabel,
      value: '${(fraction * 100).round()}%',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          border: Border.all(color: colors.border, width: LkBorders.regular),
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: fraction,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accent,
                border: fraction == 0
                    ? null
                    : Border(
                        right: BorderSide(
                          color: colors.border,
                          width: LkBorders.regular,
                        ),
                      ),
              ),
              child: CustomPaint(
                painter: _HatchPainter(
                  color: colors.accentOn.withValues(alpha: LkOpacity.stripe),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws the 45° repeating stripe from the design system's `--lk-hatch`.
class _HatchPainter extends CustomPainter {
  const _HatchPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = LkSpacing.s1
      ..style = PaintingStyle.stroke;

    // 4px stripe on a 4px gap, matching the CSS gradient's 8px period.
    const period = LkSpacing.s2;
    canvas.clipRect(Offset.zero & size);
    for (var x = -size.height; x < size.width; x += period) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) => oldDelegate.color != color;
}
