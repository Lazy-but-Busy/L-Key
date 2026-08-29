import 'package:flutter/material.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/chords/domain/chord_voicing.dart';

/// A neck the player builds a shape on.
///
/// The read-only counterpart is `shared/widgets/lk_fretboard.dart`, and the
/// geometry here is deliberately the same — string-name column, thin string
/// lines, a heavy nut, an open-string column left of it, pill markers, mono
/// fret numbers underneath — so the two read as one component. It is a
/// separate widget rather than a flag on that one because `LkFretboard` is
/// driven by `List<FretPosition>`, and a `FretPosition` requires the degree
/// it sounds, which does not exist until a chord has been named. Here the
/// shape comes first and the name second.
///
/// It lives in the chords feature, not in `shared/`, because it speaks
/// `FrettedString` — a `features/chords/domain` type that `shared/widgets`
/// may not import (docs/adr/0009).
///
/// The widget lays out and nothing else (CLAUDE.md §8). Which note a cell
/// sounds, whether it is the root, and every word on screen arrive through
/// callbacks.
class ChordShapeEditor extends StatelessWidget {
  /// Creates a shape editor.
  const ChordShapeEditor({
    required this.tuning,
    required this.strings,
    required this.labelOf,
    required this.isRootAt,
    required this.describeCell,
    required this.describeToggle,
    required this.onSelect,
    required this.onToggle,
    super.key,
    this.highestFret = defaultHighestFret,
  });

  /// How far up the neck the editor reaches.
  ///
  /// Twelve, because past it a shape repeats an octave lower and there is
  /// nothing new to build — the same bound `ChordEngine.highestBaseFret`
  /// puts on a movable shape.
  static const int defaultHighestFret = 12;

  /// The tuning the strings sound in. Supplies the names and the count.
  final Tuning tuning;

  /// One entry per string, lowest-sounding first.
  final List<FrettedString> strings;

  /// What a marker prints — the note the cell sounds.
  final String Function(int stringIndex, int fret) labelOf;

  /// Whether a cell sounds the root of whatever the shape currently is.
  final bool Function(int stringIndex, int fret) isRootAt;

  /// The accessible name of one cell, e.g. "String 6, fret 3, C".
  final String Function(int stringIndex, int fret) describeCell;

  /// The accessible name of one string's mute-or-open control, which the
  /// caller words differently depending on which way it will go.
  final String Function(int stringIndex) describeToggle;

  /// Called when a cell is chosen.
  final void Function(int stringIndex, int fret) onSelect;

  /// Called when a string's gutter control is tapped.
  final void Function(int stringIndex) onToggle;

  /// The highest fret drawn, inclusive.
  final int highestFret;

  static const double _rowHeight = LkDimens.tapTarget;
  static const double _fretWidth = LkDimens.fretboardFretWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final count = tuning.stringCount;
    // Guitarists read a diagram with the highest string on top; the engine
    // indexes lowest-sounding first. The rows are drawn in reverse for that
    // reason, and nothing below this line reverses it again.
    final rows = <int>[for (var i = count - 1; i >= 0; i--) i];
    final columns = <int>[for (var fret = 0; fret <= highestFret; fret++) fret];
    final gridWidth = columns.length * _fretWidth;

    return Container(
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
              _Gutter(
                tuning: tuning,
                strings: strings,
                rows: rows,
                rowHeight: _rowHeight,
                describeToggle: describeToggle,
                onToggle: onToggle,
              ),
              SizedBox(
                width: gridWidth,
                height: count * _rowHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    for (var row = 0; row < count; row++)
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
                    // The nut closes the open-string column.
                    Positioned(
                      left: _fretWidth - LkDimens.fretboardNutWidth / 2,
                      top: 0,
                      bottom: 0,
                      width: LkDimens.fretboardNutWidth,
                      child: ColoredBox(color: colors.border),
                    ),
                    for (var row = 0; row < count; row++)
                      for (final fret in columns)
                        Positioned(
                          left: fret * _fretWidth,
                          top: row * _rowHeight,
                          width: _fretWidth,
                          height: _rowHeight,
                          child: _Cell(
                            label: labelOf(rows[row], fret),
                            semanticLabel: describeCell(rows[row], fret),
                            isSelected: strings[rows[row]].soundingFret == fret,
                            isRoot: isRootAt(rows[row], fret),
                            onTap: () => onSelect(rows[row], fret),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
          _FretNumbers(columns: columns, fretWidth: _fretWidth),
        ],
      ),
    );
  }
}

/// The string numbers, names and mute controls down the left-hand edge.
class _Gutter extends StatelessWidget {
  const _Gutter({
    required this.tuning,
    required this.strings,
    required this.rows,
    required this.rowHeight,
    required this.describeToggle,
    required this.onToggle,
  });

  final Tuning tuning;
  final List<FrettedString> strings;
  final List<int> rows;
  final double rowHeight;
  final String Function(int stringIndex) describeToggle;
  final void Function(int stringIndex) onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Column(
      children: <Widget>[
        for (final string in rows)
          SizedBox(
            height: rowHeight,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: LkDimens.fretboardLabelColumn,
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
                Semantics(
                  button: true,
                  label: describeToggle(string),
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () => onToggle(string),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: LkDimens.tapTarget,
                      height: rowHeight,
                      child: Center(
                        child: Text(
                          // The same glyphs the chord diagram prints above
                          // its nut (DESIGN.md §24).
                          strings[string].sounds ? '○' : '×',
                          style: context.lkType.technical.copyWith(
                            fontWeight: FontWeight.w700,
                            color: strings[string].sounds
                                ? colors.textTertiary
                                : colors.danger,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// One string-and-fret cell, carrying its marker when it is chosen.
class _Cell extends StatelessWidget {
  const _Cell({
    required this.label,
    required this.semanticLabel,
    required this.isSelected,
    required this.isRoot,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool isSelected;
  final bool isRoot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: isSelected
              ? Container(
                  width: LkDimens.fretboardMarkerSize,
                  height: LkDimens.fretboardMarkerSize,
                  decoration: BoxDecoration(
                    color: isRoot ? colors.markerRoot : colors.marker,
                    borderRadius: BorderRadius.circular(LkRadii.pill),
                  ),
                  // The marker always carries its note, so the orange that
                  // marks a root is never the only thing saying so
                  // (DESIGN.md §42).
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
                )
              : const SizedBox.shrink(),
        ),
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
      padding: const EdgeInsets.only(
        left: LkDimens.fretboardLabelColumn + LkDimens.tapTarget,
      ),
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
