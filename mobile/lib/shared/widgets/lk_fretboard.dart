import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/music/fretboard.dart';
import 'package:l_key/core/music/tuning.dart';

/// A technical fretboard, drawn horizontally (DESIGN.md §25).
///
/// The widget lays out and nothing else (CLAUDE.md §8). Every marker arrives
/// already decided by `FretboardEngine` — which string, which fret, which
/// note, which degree, and whether it is the root. Nothing here calculates a
/// position, so a seven-string, an eight-string and a bass need no new code.
///
/// Geometry follows the design system's `components/music/Fretboard.jsx`:
/// a string-name column, thin string lines, a heavy nut, pill markers and
/// mono fret numbers underneath. Two things are added that the design system
/// does not draw, for the same kind of reason the chord diagram adds a barre:
///
/// * **An open-string column left of the nut.** `Fretboard.jsx` positions a
///   marker at `fret * fretWidth - fretWidth / 2`, so fret 0 has nowhere to
///   go — and a scale in open position is most of the scale.
/// * **A label inside every marker, root included.** DESIGN.md §25 puts the
///   root in Guitar Orange and DESIGN.md §42 forbids meaning by colour alone,
///   so the marker carries its note or degree as well as its fill.
///
/// The whole neck is one semantics node read string by string, because a
/// screen reader landing on forty unlabelled dots learns nothing.
class LkFretboard extends StatelessWidget {
  /// Creates a fretboard.
  const LkFretboard({
    required this.tuning,
    required this.range,
    required this.positions,
    required this.labelOf,
    required this.semanticsLabel,
    required this.describeString,
    super.key,
    this.compact = false,
  });

  /// The tuning the strings sound in. Supplies the string names and the count.
  final Tuning tuning;

  /// The frets drawn, inclusive.
  final FretRange range;

  /// The markers to draw. Positions outside [range] are ignored.
  final List<FretPosition> positions;

  /// What a marker prints — the note name or the degree.
  ///
  /// A callback rather than a flag, because notes-versus-intervals is the
  /// caller's decision and the localised copy lives up there too.
  final String Function(FretPosition position) labelOf;

  /// The accessible name of the whole neck.
  final String semanticsLabel;

  /// Reads one string out: given its index and its markers, in order.
  ///
  /// Localised, so it is passed in rather than built here.
  final String Function(int stringIndex, List<FretPosition> onString)
  describeString;

  /// Whether to draw at the narrower phone size (DESIGN.md §43).
  final bool compact;

  double get _fretWidth => compact
      ? LkDimens.fretboardFretWidthCompact
      : LkDimens.fretboardFretWidth;

  double get _rowHeight => compact
      ? LkDimens.fretboardRowHeightCompact
      : LkDimens.fretboardRowHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final columns = <int>[
      for (var fret = range.lowest; fret <= range.highest; fret++) fret,
    ];
    final gridWidth = columns.length * _fretWidth;
    final strings = tuning.stringCount;

    // Guitarists read a diagram with the highest string on top; the engine
    // indexes lowest-sounding first. The rows are drawn in reverse for that
    // reason, and nothing below this line reverses it again.
    final rows = <int>[for (var i = strings - 1; i >= 0; i--) i];

    return Semantics(
      label: semanticsLabel,
      hint: <String>[
        for (final string in rows)
          describeString(
            string,
            positions
                .where((p) => p.stringIndex == string && range.contains(p.fret))
                .toList(),
          ),
      ].join('. '),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(LkSpacing.s4),
        color: colors.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: LkSpacing.s2,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _StringNames(tuning: tuning, rows: rows, rowHeight: _rowHeight),
                SizedBox(
                  width: gridWidth,
                  height: strings * _rowHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      for (var row = 0; row < strings; row++)
                        Positioned(
                          left: 0,
                          top:
                              row * _rowHeight +
                              _rowHeight / 2 -
                              LkDimens.fretboardStringWidth / 2,
                          width: gridWidth,
                          height: LkDimens.fretboardStringWidth,
                          child: ColoredBox(color: colors.stringLine),
                        ),
                      for (var i = 0; i < columns.length; i++)
                        Positioned(
                          left:
                              (i + 1) * _fretWidth -
                              LkDimens.fretboardFretLineWidth / 2,
                          top: 0,
                          bottom: 0,
                          width: LkDimens.fretboardFretLineWidth,
                          child: ColoredBox(color: colors.border),
                        ),
                      // The nut closes the open-string column. Start the view
                      // up the neck and there is no nut to draw, exactly as
                      // the chord diagram opens on a plain fret line above the
                      // twelfth fret.
                      if (range.includesNut)
                        Positioned(
                          left: _fretWidth - LkDimens.fretboardNutWidth / 2,
                          top: 0,
                          bottom: 0,
                          width: LkDimens.fretboardNutWidth,
                          child: ColoredBox(color: colors.border),
                        ),
                      for (final position in positions)
                        if (range.contains(position.fret))
                          _Marker(
                            position: position,
                            label: labelOf(position),
                            left:
                                (position.fret - range.lowest + 0.5) *
                                _fretWidth,
                            top:
                                (strings - 1 - position.stringIndex) *
                                    _rowHeight +
                                _rowHeight / 2,
                          ),
                    ],
                  ),
                ),
              ],
            ),
            _FretNumbers(columns: columns, fretWidth: _fretWidth),
          ],
        ),
      ),
    );
  }
}

/// The string numbers and names down the left-hand edge.
///
/// The number is the guitarist's, counted from the high string down, which is
/// the opposite of the engine's low-first indexing and the same arithmetic
/// the spoken description already uses. Without it a six-string neck reads
/// `E B G D A E` and the two Es are indistinguishable.
class _StringNames extends StatelessWidget {
  const _StringNames({
    required this.tuning,
    required this.rows,
    required this.rowHeight,
  });

  final Tuning tuning;
  final List<int> rows;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return SizedBox(
      width: LkDimens.fretboardLabelColumn,
      child: Column(
        children: <Widget>[
          for (final string in rows)
            SizedBox(
              height: rowHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: LkSpacing.s2,
                children: <Widget>[
                  Text(
                    '${tuning.stringCount - string}',
                    style: context.lkType.technicalSm.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  Text(
                    tuning.openStrings[string].note.displayName,
                    style: context.lkType.technicalSm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The fret numbers under the grid. Fret 0 labels the open-string column.
class _FretNumbers extends StatelessWidget {
  const _FretNumbers({required this.columns, required this.fretWidth});

  final List<int> columns;
  final double fretWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Padding(
      padding: const EdgeInsets.only(left: LkDimens.fretboardLabelColumn),
      child: Row(
        children: <Widget>[
          for (final fret in columns)
            SizedBox(
              width: fretWidth,
              child: Text(
                '$fret',
                textAlign: TextAlign.center,
                style: context.lkType.technicalSm.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One marker on the neck.
class _Marker extends StatelessWidget {
  const _Marker({
    required this.position,
    required this.label,
    required this.left,
    required this.top,
  });

  final FretPosition position;
  final String label;
  final double left;
  final double top;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final isRoot = position.isRoot;

    return Positioned(
      left: left - LkDimens.fretboardMarkerSize / 2,
      top: top - LkDimens.fretboardMarkerSize / 2,
      width: LkDimens.fretboardMarkerSize,
      height: LkDimens.fretboardMarkerSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isRoot ? colors.markerRoot : colors.marker,
          borderRadius: BorderRadius.circular(LkRadii.pill),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            style: context.lkType.technicalSm.copyWith(
              fontWeight: FontWeight.w700,
              color: isRoot ? colors.markerRootOn : colors.markerOn,
            ),
          ),
        ),
      ),
    );
  }
}
