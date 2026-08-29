/// What the fretboard is currently showing.
///
/// A scale, a mode, an arpeggio and the plain note map are four different
/// things to a player and one thing to the engine: a root plus a list of
/// spelled degrees. This file is that translation and nothing else, which is
/// why `FretboardEngine.positions` needs no adapter and no second entry point.
///
/// Contains no Flutter. See docs/adr/0011.
library;

import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/interval.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/scale.dart';
import 'package:meta/meta.dart';

/// A root and the degrees the fretboard should light up.
@immutable
sealed class FretboardSelection {
  const FretboardSelection();

  /// The note every degree is measured from.
  Note get root;

  /// The degrees above [root] that belong to the selection.
  List<Interval> get intervals;

  /// A stable identifier, for analytics and for a future deep link.
  String get slug;

  /// Whether every degree can be spelled on [root].
  ///
  /// See [Scale.isSpellable] — A♯ whole tone is the case this exists for.
  bool get isSpellable =>
      intervals.every((i) => root.tryTransposeBy(i) != null);
}

/// A scale or a mode. The two are the same object; only the name differs.
@immutable
final class ScaleSelection extends FretboardSelection {
  /// Shows [scale] on the neck.
  const ScaleSelection(this.scale);

  /// The scale being shown.
  final Scale scale;

  @override
  Note get root => scale.root;

  @override
  List<Interval> get intervals => scale.intervals;

  @override
  String get slug => 'scale:${scale.type.slug}';

  @override
  bool operator ==(Object other) =>
      other is ScaleSelection && other.scale == scale;

  @override
  int get hashCode => scale.hashCode;
}

/// A chord's tones spread across the neck.
///
/// An arpeggio *is* a chord — the same formula, played one note at a time —
/// so it reads `ChordQuality` rather than repeating eighteen interval tables
/// (CLAUDE.md §4). That is why `ChordQuality` lives in `core/music/`.
@immutable
final class ArpeggioSelection extends FretboardSelection {
  /// Shows the arpeggio of [quality] on [root].
  const ArpeggioSelection(this.root, this.quality);

  @override
  final Note root;

  /// The chord the arpeggio spells out.
  final ChordQuality quality;

  @override
  List<Interval> get intervals => quality.intervals;

  @override
  String get slug => 'arpeggio:${quality.slug}';

  @override
  bool operator ==(Object other) =>
      other is ArpeggioSelection &&
      other.root == root &&
      other.quality == quality;

  @override
  int get hashCode => Object.hash(root, quality);
}
