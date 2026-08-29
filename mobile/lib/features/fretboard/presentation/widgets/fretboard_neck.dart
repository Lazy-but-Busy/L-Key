import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/core/music/fretboard.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/fretboard/presentation/fretboard_controller.dart';
import 'package:l_key/shared/widgets/lk_fretboard.dart';

/// The neck, scrolled horizontally and wired to the localised copy.
///
/// [LkFretboard] is the design-system component and knows nothing about
/// localisation or Riverpod. This is the thin layer between: it decides what a
/// marker prints and what a screen reader hears, and both screens use it so
/// the fretboard reads the same on the scales page as on the fretboard tool.
class FretboardNeck extends StatelessWidget {
  /// Creates a neck.
  const FretboardNeck({
    required this.tuning,
    required this.range,
    required this.positions,
    required this.labels,
    required this.title,
    super.key,
    this.compact = true,
  });

  /// The tuning being drawn.
  final Tuning tuning;

  /// The frets in view.
  final FretRange range;

  /// The markers.
  final List<FretPosition> positions;

  /// Whether markers print note names or degrees.
  final FretboardLabels labels;

  /// What is being shown, already localised — used in the accessible name.
  final String title;

  /// Whether to draw at the narrower phone size.
  final bool compact;

  /// What one marker is called, in both the picture and the description.
  String _label(FretPosition position) => switch (labels) {
    FretboardLabels.notes => position.note.displayName,
    FretboardLabels.intervals => position.degree.degree,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Scrolls rather than clipping: a full neck is wider than any phone, and
    // DESIGN.md §43 forbids hardcoding a screen width to avoid it.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: LkFretboard(
        tuning: tuning,
        range: range,
        positions: positions,
        compact: compact,
        labelOf: _label,
        semanticsLabel: l10n.fretboardSemanticsLabel(
          title,
          tuning.stringCount,
          range.lowest,
          range.highest,
        ),
        describeString: (stringIndex, onString) {
          // Guitarists count strings from the high E down, the opposite of
          // the engine's low-to-high indexing.
          final number = tuning.stringCount - stringIndex;
          if (onString.isEmpty) {
            return l10n.fretboardSemanticsEmptyString(number);
          }
          // The description says what the marker says. Switching the picture
          // to degrees and leaving the spoken version on note names would
          // give a screen-reader user a different fretboard.
          return l10n.fretboardSemanticsString(
            number,
            onString
                .map(
                  (p) => p.fret == 0
                      ? l10n.fretboardSemanticsOpen(_label(p))
                      : l10n.fretboardSemanticsFretted(p.fret, _label(p)),
                )
                .join(', '),
          );
        },
      ),
    );
  }
}
