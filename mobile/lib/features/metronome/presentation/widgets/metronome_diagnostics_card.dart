import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/features/metronome/domain/metronome_state.dart';

/// The metronome's buffer and timing measurements, for a developer with a
/// phone and a recorder.
///
/// Behind `FeatureFlags.metronomeDiagnostics` and never shown to a player:
/// fed frames and dropout counts mean nothing to a guitarist. It exists so
/// docs/DEVICE-TESTING.md Part B produces numbers, because the buffer sizes in
/// `AudioOutputConfig` cannot be calibrated against an impression.
///
/// Deliberately untranslated. It is a developer tool, and the strings here are
/// the field names from the code rather than product copy — putting them
/// through localisation would imply a player might read them.
class MetronomeDiagnosticsCard extends StatelessWidget {
  /// Creates the card.
  const MetronomeDiagnosticsCard({required this.diagnostics, super.key});

  /// The measurements behind the last feed.
  final MetronomeDiagnostics diagnostics;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final nextMs = diagnostics.nextClickInMs;

    final bufferedMs =
        diagnostics.bufferedFrames * 1000 / diagnostics.sampleRate;

    final rows = <(String, String)>[
      ('rate', '${diagnostics.sampleRate} Hz'),
      (
        'block / target',
        '${diagnostics.blockFrames} / ${diagnostics.targetBufferFrames}',
      ),
      (
        'buffered',
        '${diagnostics.bufferedFrames} fr '
            '(${bufferedMs.toStringAsFixed(1)} ms)',
      ),
      ('fed', '${diagnostics.fedFrames}'),
      ('played', '${diagnostics.playedFrames}'),
      ('dropouts', '${diagnostics.dropouts}'),
      (
        'next click',
        nextMs == null ? '—' : '${nextMs.toStringAsFixed(1)} ms',
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
            'METRONOME DIAGNOSTICS',
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
