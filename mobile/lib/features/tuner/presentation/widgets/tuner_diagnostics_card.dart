import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/features/tuner/domain/tuner_state.dart';

/// The tuner's raw measurements, for a developer holding a real guitar.
///
/// Behind `FeatureFlags.tunerDiagnostics` and never shown to a player:
/// decibels, clarity and spectral flatness mean nothing to a guitarist. It
/// exists so docs/DEVICE-TESTING.md produces numbers, because the thresholds
/// in `TunerThresholds` cannot be calibrated against an impression.
class TunerDiagnosticsCard extends StatelessWidget {
  /// Creates the card.
  const TunerDiagnosticsCard({required this.diagnostics, super.key});

  /// The measurements behind the last window.
  final TunerDiagnostics diagnostics;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final l10n = AppLocalizations.of(context);

    final rows = <(String, String)>[
      ('rate', '${diagnostics.sampleRate} Hz'),
      ('window', '${diagnostics.windowSize} / ${diagnostics.hopSize}'),
      ('fps', diagnostics.framesPerSecond.toStringAsFixed(1)),
      ('level', '${diagnostics.rmsDbfs.toStringAsFixed(1)} dBFS'),
      ('clipped', diagnostics.clippedRatio.toStringAsFixed(3)),
      ('clarity', diagnostics.clarity.toStringAsFixed(3)),
      ('confidence', diagnostics.confidence.toStringAsFixed(3)),
      ('flatness', diagnostics.spectralFlatness.toStringAsFixed(3)),
      ('peaks', '${diagnostics.peakCount}'),
      ('residual', diagnostics.residualRatio.toStringAsFixed(3)),
      ('partials', '${diagnostics.residualPartialCount}'),
      (
        'raw',
        diagnostics.rawFrequencyHz == null
            ? '—'
            : '${diagnostics.rawFrequencyHz!.toStringAsFixed(2)} Hz',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(LkSpacing.s4),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: LkSpacing.s2,
        children: <Widget>[
          Text(
            l10n.tunerDiagnostics.toUpperCase(),
            style: context.lkType.label.copyWith(color: colors.textSecondary),
          ),
          for (final (label, value) in rows)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  label,
                  style: context.lkType.technicalSm.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                Text(
                  value,
                  style: context.lkType.technicalSm.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
