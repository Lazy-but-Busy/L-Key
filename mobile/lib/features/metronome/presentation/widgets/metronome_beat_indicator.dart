import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/utils/reduced_motion.dart';
import 'package:l_key/features/metronome/domain/time_signature.dart';

/// DESIGN.md §27's beat indicator: `● ○ ○ ○`, with the accent stronger.
///
/// **It renders and computes nothing.** Which beat is sounding arrives already
/// decided from `metronome/domain`, advanced by the frames the audio device
/// reports it has played, so the dot cannot light before the click is heard
/// (CLAUDE.md §8, docs/adr/0016).
///
/// The emphasis is carried on three channels, never colour alone
/// (DESIGN.md §42): an accented beat is a larger dot, with a heavier ring,
/// over a bolder number. The rings stay drawn when a beat is silent so the
/// length of the bar is always readable.
class MetronomeBeatIndicator extends StatelessWidget {
  /// Creates a beat indicator.
  const MetronomeBeatIndicator({
    required this.accents,
    required this.beat,
    required this.isRunning,
    super.key,
  });

  /// The emphasis of each beat in the bar.
  final List<AccentLevel> accents;

  /// Which beat is sounding, counted from zero.
  final int beat;

  /// Whether the metronome is keeping time.
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.metronomeBeatIndicator,
      value: l10n.metronomeBeatOf(beat + 1, accents.length),
      excludeSemantics: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        // Wraps rather than a Row, because twelve dots in 12/8 do not fit a
        // narrow phone once the ring widths are counted (DESIGN.md §43).
        spacing: LkSpacing.s2,
        runSpacing: LkSpacing.s2,
        children: <Widget>[
          for (var i = 0; i < accents.length; i++)
            _Beat(
              level: accents[i],
              number: i + 1,
              isSounding: isRunning && i == beat,
            ),
        ],
      ),
    );
  }
}

class _Beat extends StatelessWidget {
  const _Beat({
    required this.level,
    required this.number,
    required this.isSounding,
  });

  final AccentLevel level;
  final int number;
  final bool isSounding;

  bool get _isAccented =>
      level == AccentLevel.strong || level == AccentLevel.accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    final size = _isAccented ? LkSpacing.s4 : LkSpacing.s3;
    final border = _isAccented ? LkBorders.strong : LkBorders.regular;
    final fill = switch (level) {
      AccentLevel.strong || AccentLevel.accent => colors.accent,
      AccentLevel.silent => Colors.transparent,
      _ => colors.textPrimary,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: LkSpacing.s5,
          height: LkSpacing.s5,
          child: Center(
            child: AnimatedContainer(
              // Only the fill animates, and under reduced motion it snaps.
              // Nothing is lost when it does: the number below says the same
              // thing (DESIGN.md §41, §42).
              duration: context.motion(LkMotion.durationFast),
              curve: LkMotion.easing,
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSounding ? fill : Colors.transparent,
                border: Border.all(
                  color: level == AccentLevel.silent
                      ? colors.textTertiary
                      : colors.border,
                  width: border,
                ),
              ),
            ),
          ),
        ),
        Text(
          '$number',
          style: context.lkType.technicalSm.copyWith(
            color: isSounding ? colors.textPrimary : colors.textTertiary,
            fontWeight: _isAccented ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
