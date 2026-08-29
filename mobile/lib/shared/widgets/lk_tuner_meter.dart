import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/utils/reduced_motion.dart';

/// The tuner's meter: a huge note, a frequency, and a needle.
///
/// DESIGN.md §65 names this component `TunerMeter`; the `Lk` prefix matches
/// `LkFretboard` and `LkChordDiagram`. Every measurement comes from the design
/// system's own TunerMeter, which ADR-0003 makes authoritative where DESIGN.md
/// §21 is silent about numbers.
///
/// **It renders and computes nothing.** No cents arithmetic, no tolerance
/// decision, no note naming: all of that arrives already decided from
/// `tuner/domain` (CLAUDE.md §8, PRD.md §10).
class LkTunerMeter extends StatelessWidget {
  /// Creates a meter.
  ///
  /// With no [note] it draws at rest, which is what the tuner shows before it
  /// is listening and while it hears nothing worth naming.
  const LkTunerMeter({
    required this.tuningLabel,
    required this.referencePitchLabel,
    required this.statusLabel,
    super.key,
    this.note,
    this.octave,
    this.frequencyHz,
    this.cents,
    this.isInTune = false,
    this.semanticsLabel,
  });

  /// The note being tuned, typographically spelled. Null draws the rest state.
  final String? note;

  /// Its octave, shown small beside the note.
  final int? octave;

  /// What is actually sounding, printed to two decimal places.
  final double? frequencyHz;

  /// How far from the target, positive being sharp (DESIGN.md §22).
  final double? cents;

  /// Whether the string is within tolerance.
  ///
  /// Decided by the engine, not here — the meter must not be able to disagree
  /// with the reading it was handed.
  final bool isInTune;

  /// The uppercase tuning name at the foot.
  final String tuningLabel;

  /// The reference pitch at the foot.
  final String referencePitchLabel;

  /// The centre readout: "IN TUNE", a cents figure, or a state.
  ///
  /// DESIGN.md §42 forbids meaning carried by colour alone, so this text says
  /// in words what the orange says in colour.
  final String statusLabel;

  /// What a screen reader announces for the whole meter.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final type = context.lkType;
    final noteColour = isInTune ? colors.accent : colors.textPrimary;

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(LkSpacing.s6),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border, width: LkBorders.regular),
          boxShadow: <BoxShadow>[LkShadows.regular(colors.border)],
        ),
        child: Column(
          spacing: LkSpacing.s6,
          children: <Widget>[
            _Note(note: note, octave: octave, colour: noteColour),
            Text(
              frequencyHz == null
                  ? '—'
                  : '${frequencyHz!.toStringAsFixed(2)} Hz',
              style: type.technical.copyWith(color: colors.textSecondary),
            ),
            _Needle(cents: cents, isInTune: isInTune),
            _Scale(statusLabel: statusLabel, isInTune: isInTune),
            _Footer(
              tuningLabel: tuningLabel,
              referencePitchLabel: referencePitchLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.note, required this.octave, required this.colour});

  final String? note;
  final int? octave;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final type = context.lkType;

    // The note is 96px, which no phone survives at the largest text sizes.
    // DESIGN.md §42 requires Dynamic Type, and the design system's reference
    // does not consider it, so it is scaled down rather than clipped.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        spacing: LkSpacing.s1,
        children: <Widget>[
          Text(
            note ?? '—',
            style: type.hero.copyWith(
              color: note == null ? colors.textTertiary : colour,
            ),
          ),
          if (octave != null)
            Text(
              '$octave',
              style: type.h2.copyWith(color: colors.textTertiary),
            ),
        ],
      ),
    );
  }
}

class _Needle extends StatelessWidget {
  const _Needle({required this.cents, required this.isInTune});

  final double? cents;
  final bool isInTune;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    // Clamped, because a string being tuned from an A up to an E is thousands
    // of cents away and the needle has to stay on the track. The readout
    // still prints the true figure.
    final clamped = (cents ?? 0).clamp(
      -LkDimens.tunerCentsRange,
      LkDimens.tunerCentsRange,
    );
    // Alignment runs -1 at the left edge to +1 at the right, which keeps the
    // needle wholly inside the track at either extreme.
    final position = clamped / LkDimens.tunerCentsRange;

    return SizedBox(
      height: LkDimens.tunerMeterHeight + LkDimens.tunerNeedleOverhang * 2,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: LkDimens.tunerMeterHeight,
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              border: Border.all(
                color: colors.border,
                width: LkBorders.regular,
              ),
            ),
            child: Center(
              child: Container(
                width: LkDimens.tunerCentreLineWidth,
                height: LkDimens.tunerMeterHeight,
                color: colors.border,
              ),
            ),
          ),
          if (cents != null)
            AnimatedAlign(
              // Only the position animates. The colour does not: the theme
              // extension snaps its lerp at the midpoint rather than
              // blending, so an animated colour would jump anyway, and
              // DESIGN.md §41 says never animate merely because it is
              // possible.
              duration: context.motion(LkMotion.durationBase),
              curve: LkMotion.easing,
              alignment: Alignment(position, 0),
              child: Container(
                width: LkDimens.tunerNeedleWidth,
                height: LkDimens.tunerNeedleHeight,
                decoration: BoxDecoration(
                  color: isInTune ? colors.accent : colors.textPrimary,
                  // Guitar Orange is 2.64:1 on the sunken track, below the
                  // three-to-one floor for a non-text mark, so the shape is
                  // outlined and never relies on its fill to be visible
                  // (DESIGN.md §42, and the token package's contrast gate).
                  border: Border.all(color: colors.border),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Scale extends StatelessWidget {
  const _Scale({required this.statusLabel, required this.isInTune});

  final String statusLabel;
  final bool isInTune;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final type = context.lkType;
    final range = LkDimens.tunerCentsRange.round();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          '-$range',
          style: type.technicalSm.copyWith(color: colors.textTertiary),
        ),
        Flexible(
          child: Text(
            statusLabel.toUpperCase(),
            textAlign: TextAlign.center,
            style: type.technical.copyWith(
              color: isInTune ? colors.accent : colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '+$range',
          style: type.technicalSm.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.tuningLabel,
    required this.referencePitchLabel,
  });

  final String tuningLabel;
  final String referencePitchLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final type = context.lkType;

    return Container(
      padding: const EdgeInsets.only(top: LkSpacing.s3),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.divider, width: LkBorders.regular),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              tuningLabel.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: type.technical.copyWith(color: colors.textPrimary),
            ),
          ),
          Text(
            referencePitchLabel,
            style: type.technical.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
