import 'package:flutter/material.dart';
import 'package:l_key/app/localization/generated/app_localizations.dart';
import 'package:l_key/app/theme/app_colors.dart';
import 'package:l_key/app/theme/app_text.dart';
import 'package:l_key/app/theme/tokens.g.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/chords/domain/chord.dart';
import 'package:l_key/features/chords/domain/chord_engine.dart';
import 'package:l_key/features/chords/domain/chord_voicing.dart';

/// A chord shape drawn as a fretboard grid.
///
/// The widget lays out and nothing else (CLAUDE.md §8) — every fret, finger,
/// string state and barre arrives already decided by [ChordEngine].
///
/// Geometry follows DESIGN.md §24 and the design system's `ChordDiagram.jsx`:
/// thick strings, a hard nut, large finger markers, no rounding anywhere but
/// the markers themselves. Two things are added that the design system does
/// not draw, because PRD.md §11 asks for them and a movable shape is unusable
/// without the second: a bar across the barred strings, and the fret the grid
/// starts at.
///
/// The whole diagram is one semantics node describing every string in turn,
/// because a screen reader landing on twelve unlabelled dots learns nothing
/// (DESIGN.md §42).
class LkChordDiagram extends StatelessWidget {
  /// Creates a chord diagram.
  const LkChordDiagram({
    required this.chord,
    required this.voicing,
    required this.shapeLabel,
    super.key,
    this.tuning = Tuning.standard,
    this.fretCount = 4,
  });

  /// The chord being drawn. Supplies the spelling for each string's note.
  final Chord chord;

  /// The shape to draw.
  final ChordVoicing voicing;

  /// How this shape is named in the interface, e.g. `Open` or `5fr`.
  ///
  /// Localised copy, so it is passed in rather than derived here.
  final String shapeLabel;

  /// The tuning the strings sound in.
  final Tuning tuning;

  /// How many fret rows the grid draws.
  final int fretCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.lkColors;
    final notes = voicing.soundingNotes(tuning, spelling: chord.notes);

    return Semantics(
      label: l10n.chordDiagramLabel(chord.displaySymbol, shapeLabel),
      hint: _describe(l10n, notes),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(LkSpacing.s8),
        decoration: BoxDecoration(
          color: colors.surface,
          boxShadow: <BoxShadow>[LkShadows.regular(colors.border)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: LkSpacing.s6,
          children: <Widget>[
            _StringStates(voicing: voicing),
            _Grid(
              voicing: voicing,
              fretCount: fretCount,
              stringCount: tuning.stringCount,
              rootStrings: _rootStrings(notes),
            ),
            _NoteRow(notes: notes),
          ],
        ),
      ),
    );
  }

  /// Which strings sound the chord's root.
  ///
  /// DESIGN.md §25 puts the root in Guitar Orange. The marker still prints its
  /// finger number, so colour is never the only cue (DESIGN.md §42).
  Set<int> _rootStrings(List<Note?> notes) => <int>{
    for (var index = 0; index < notes.length; index++)
      if (notes[index]?.pitchClass == chord.root.pitchClass) index,
  };

  /// Reads the shape out string by string.
  ///
  /// DESIGN.md §42 — meaning is never carried by the picture alone.
  String _describe(AppLocalizations l10n, List<Note?> notes) {
    final parts = <String>[];
    if (voicing.baseFret > 0) {
      parts.add(l10n.chordBaseFretLabel(voicing.baseFret));
    }
    for (final string in voicing.strings) {
      // Guitarists count strings from the high E down, the opposite of the
      // engine's low-to-high indexing.
      final number = tuning.stringCount - string.stringIndex;
      final note = notes[string.stringIndex]?.displayName ?? '';
      parts.add(
        switch (string.state) {
          StringState.muted => l10n.chordStringMuted(number),
          StringState.open => l10n.chordStringOpen(number, note),
          StringState.fretted => l10n.chordStringFretted(
            number,
            string.fret!,
            string.finger?.toString() ?? l10n.chordFingerNone,
            note,
          ),
        },
      );
    }
    final barre = voicing.barre;
    if (barre != null) {
      parts.add(l10n.chordBarreLabel(barre.fret, barre.stringSpan));
    }
    return parts.join('. ');
  }
}

/// The `X` and `O` row above the nut.
class _StringStates extends StatelessWidget {
  const _StringStates({required this.voicing});

  final ChordVoicing voicing;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (final string in voicing.strings)
          SizedBox(
            width: LkDimens.chordMarkerSize,
            child: Text(
              switch (string.state) {
                StringState.muted => '×',
                StringState.open => '○',
                StringState.fretted => '',
              },
              textAlign: TextAlign.center,
              style: context.lkType.technical.copyWith(
                fontWeight: FontWeight.w700,
                color: string.state == StringState.muted
                    ? colors.danger
                    : colors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

/// The notes each string sounds, under the grid.
class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.notes});

  final List<Note?> notes;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (final note in notes)
          SizedBox(
            width: LkDimens.chordMarkerSize,
            child: Text(
              note?.displayName ?? '',
              textAlign: TextAlign.center,
              style: context.lkType.technical.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

/// The grid itself: nut, strings, frets, barre and finger markers.
class _Grid extends StatelessWidget {
  const _Grid({
    required this.voicing,
    required this.fretCount,
    required this.stringCount,
    required this.rootStrings,
  });

  final ChordVoicing voicing;
  final int fretCount;
  final int stringCount;
  final Set<int> rootStrings;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Never wider than the design width, but free to shrink on a small
        // phone rather than overflow (DESIGN.md §43).
        final width = constraints.maxWidth.clamp(
          0.0,
          LkDimens.chordDiagramWidth,
        );
        // The right-hand gutter carries a movable shape's fret number.
        final gridWidth = width - LkDimens.chordMarkerSize;
        final columnGap = stringCount > 1 ? gridWidth / (stringCount - 1) : 0.0;
        final rowHeight = LkDimens.chordDiagramGridHeight / fretCount;

        return SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // The nut is a heavy bar; above the twelfth fret there is no nut
              // to draw, so the grid opens with an ordinary fret line.
              Container(
                width: gridWidth,
                height: voicing.includesNut
                    ? LkDimens.chordNutHeight
                    : LkDimens.chordFretLineWidth,
                color: colors.border,
              ),
              SizedBox(
                height: LkDimens.chordDiagramGridHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    for (var index = 0; index < stringCount; index++)
                      Positioned(
                        left: index * columnGap - LkDimens.chordStringWidth / 2,
                        top: 0,
                        bottom: 0,
                        width: LkDimens.chordStringWidth,
                        child: ColoredBox(color: colors.stringLine),
                      ),
                    for (var row = 0; row < fretCount; row++)
                      Positioned(
                        left: 0,
                        top: (row + 1) * rowHeight,
                        width: gridWidth,
                        height: LkDimens.chordFretLineWidth,
                        child: ColoredBox(color: colors.border),
                      ),
                    if (voicing.barre != null)
                      _BarreBar(
                        barre: voicing.barre!,
                        baseFret: voicing.baseFret,
                        columnGap: columnGap,
                        rowHeight: rowHeight,
                      ),
                    for (final string in voicing.strings)
                      if (string.state == StringState.fretted)
                        _Marker(
                          string: string,
                          baseFret: voicing.baseFret,
                          columnGap: columnGap,
                          rowHeight: rowHeight,
                          isRoot: rootStrings.contains(string.stringIndex),
                        ),
                    // A movable shape is unreadable without the fret it starts
                    // at, and the design system's diagram does not draw one.
                    if (voicing.baseFret > 0)
                      Positioned(
                        left: gridWidth + LkSpacing.s2,
                        top: rowHeight / 2 - LkSpacing.s3,
                        child: Text(
                          '${voicing.baseFret}',
                          style: context.lkType.technical.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Where a fret sits in the grid, as a one-based row.
int _rowFor(int fret, int baseFret) =>
    fret - (baseFret == 0 ? 0 : baseFret - 1);

/// The bar drawn across the strings one finger holds down.
///
/// PRD.md §11 asks for a barre indicator. Without it three markers in a row
/// look like three fingers, which is a different chord to play.
class _BarreBar extends StatelessWidget {
  const _BarreBar({
    required this.barre,
    required this.baseFret,
    required this.columnGap,
    required this.rowHeight,
  });

  final Barre barre;
  final int baseFret;
  final double columnGap;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final row = _rowFor(barre.fret, baseFret);

    return Positioned(
      left: barre.lowString * columnGap - LkDimens.chordMarkerSize / 2,
      width:
          (barre.highString - barre.lowString) * columnGap +
          LkDimens.chordMarkerSize,
      top: (row - 1) * rowHeight + rowHeight / 2 - LkDimens.chordMarkerSize / 2,
      height: LkDimens.chordMarkerSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.marker,
          borderRadius: BorderRadius.circular(LkRadii.pill),
        ),
        child: Center(
          child: Text(
            '${barre.finger}',
            style: context.lkType.technical.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.markerOn,
            ),
          ),
        ),
      ),
    );
  }
}

/// One finger marker.
class _Marker extends StatelessWidget {
  const _Marker({
    required this.string,
    required this.baseFret,
    required this.columnGap,
    required this.rowHeight,
    required this.isRoot,
  });

  final FrettedString string;
  final int baseFret;
  final double columnGap;
  final double rowHeight;
  final bool isRoot;

  @override
  Widget build(BuildContext context) {
    final colors = context.lkColors;
    final row = _rowFor(string.fret!, baseFret);

    return Positioned(
      left: string.stringIndex * columnGap - LkDimens.chordMarkerSize / 2,
      top: (row - 1) * rowHeight + rowHeight / 2 - LkDimens.chordMarkerSize / 2,
      width: LkDimens.chordMarkerSize,
      height: LkDimens.chordMarkerSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isRoot ? colors.markerRoot : colors.marker,
          borderRadius: BorderRadius.circular(LkRadii.pill),
        ),
        child: Center(
          child: Text(
            string.finger?.toString() ?? '',
            style: context.lkType.technical.copyWith(
              fontWeight: FontWeight.w700,
              color: isRoot ? colors.markerRootOn : colors.markerOn,
            ),
          ),
        ),
      ),
    );
  }
}
