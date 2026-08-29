/// Movable chord shapes: a fingering expressed relative to a base fret.
///
/// A shape is the guitarist's actual mental model. The E-shape major is one
/// pattern; slide it up the neck and it names every major chord in turn. That
/// is why the library stores shapes rather than 306 separate fingerings — and
/// why the barre falls out of the shape instead of being inferred from three
/// strings that happen to share a fret.
///
/// Contains no Flutter. See docs/adr/0010.
library;

import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/features/chords/domain/chord_voicing.dart';
import 'package:meta/meta.dart';

/// Sentinel offset marking a string this shape does not play.
const int mutedOffset = -1;

/// A fingering pattern that can be slid along the neck.
///
/// [offsets] holds one entry per string, lowest-sounding first: [mutedOffset]
/// for a muted string, or a fret offset from the shape's base. An offset of 0
/// is the base fret itself, which is where the barre sits.
@immutable
final class MovableShape {
  /// Creates a movable shape.
  const MovableShape({
    required this.name,
    required this.quality,
    required this.rootString,
    required this.offsets,
    required this.fingers,
    this.barreToString,
  });

  /// A stable identifier such as `E-shape` or `A-shape`. Not display copy.
  final String name;

  /// The quality this shape realises.
  final ChordQuality quality;

  /// Which string carries the root, lowest-sounding first.
  ///
  /// Used to work out the base fret for a given root note.
  final int rootString;

  /// Fret offsets from the base fret, or [mutedOffset], one per string.
  final List<int> offsets;

  /// Fretting finger per string, 0 where the string is open or muted.
  final List<int> fingers;

  /// Highest string the index finger barres, or null when the shape has no
  /// barre.
  ///
  /// The barre always starts at [rootString] and always sits at offset 0.
  final int? barreToString;

  /// The offset that would be the root's own fret. Always 0 by construction.
  int get rootOffset => offsets[rootString];

  /// Realises the shape with its base at [baseFret].
  ///
  /// At base fret 0 the barre becomes the nut, so its strings come back open
  /// and the shape has no barre — which is exactly how the E-shape at the nut
  /// *is* the open E chord.
  ChordVoicing at(int baseFret) {
    final strings = <FrettedString>[];
    for (var index = 0; index < offsets.length; index++) {
      final offset = offsets[index];
      if (offset == mutedOffset) {
        strings.add(FrettedString.muted(index));
        continue;
      }
      final fret = baseFret + offset;
      if (fret == 0) {
        strings.add(FrettedString.open(index));
      } else {
        strings.add(
          FrettedString.at(
            index,
            fret,
            finger: fingers[index] == 0 ? null : fingers[index],
          ),
        );
      }
    }

    final barred = barreToString;
    return ChordVoicing(
      strings: strings,
      barre: (barred == null || baseFret == 0)
          ? null
          : Barre(
              fret: baseFret,
              lowString: rootString,
              highString: barred,
            ),
      label: '$name@$baseFret',
    );
  }
}
