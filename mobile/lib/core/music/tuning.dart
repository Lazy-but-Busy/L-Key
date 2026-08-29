/// Guitar tunings, and the fret arithmetic that hangs off them.
///
/// A tuning is the ordered list of open-string pitches. Everything the
/// fretboard and the chord diagram need — which note a fret produces, how many
/// strings there are — is derived from it rather than hardcoded, so a custom
/// or seven-string tuning (PRD.md §10, §13) needs no new code.
///
/// Contains no Flutter. See docs/adr/0009.
library;

import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/pitch.dart';
import 'package:meta/meta.dart';

/// An ordered set of open-string pitches.
///
/// Strings are indexed **low to high**: index 0 is the lowest-sounding string,
/// the one drawn leftmost in a chord diagram and written first in a fret
/// array. This is the opposite of the guitarist's "sixth string" naming, and
/// it is stated here because getting it backwards silently mirrors every
/// diagram.
@immutable
final class Tuning {
  /// Creates a tuning from [openStrings], ordered lowest-sounding first.
  /// [openStrings] must not be empty; [pitchAt] range-checks every access.
  const Tuning({required this.name, required this.openStrings});

  /// Standard six-string tuning, E2 A2 D3 G3 B3 E4.
  static const Tuning standard = Tuning(
    name: 'standard',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.e), 2),
      Pitch(Note(NoteLetter.a), 2),
      Pitch(Note(NoteLetter.d), 3),
      Pitch(Note(NoteLetter.g), 3),
      Pitch(Note(NoteLetter.b), 3),
      Pitch(Note(NoteLetter.e), 4),
    ],
  );

  /// Drop D — the sixth string down a tone, D2 A2 D3 G3 B3 E4.
  static const Tuning dropD = Tuning(
    name: 'drop-d',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.d), 2),
      Pitch(Note(NoteLetter.a), 2),
      Pitch(Note(NoteLetter.d), 3),
      Pitch(Note(NoteLetter.g), 3),
      Pitch(Note(NoteLetter.b), 3),
      Pitch(Note(NoteLetter.e), 4),
    ],
  );

  /// Drop C — drop D with everything a further tone down, C2 G2 C3 F3 A3 D4.
  static const Tuning dropC = Tuning(
    name: 'drop-c',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.c), 2),
      Pitch(Note(NoteLetter.g), 2),
      Pitch(Note(NoteLetter.c), 3),
      Pitch(Note(NoteLetter.f), 3),
      Pitch(Note(NoteLetter.a), 3),
      Pitch(Note(NoteLetter.d), 4),
    ],
  );

  /// Drop B — B1 F♯2 B2 E3 G♯3 C♯4.
  static const Tuning dropB = Tuning(
    name: 'drop-b',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.b), 1),
      Pitch(Note(NoteLetter.f, Accidental.sharp), 2),
      Pitch(Note(NoteLetter.b), 2),
      Pitch(Note(NoteLetter.e), 3),
      Pitch(Note(NoteLetter.g, Accidental.sharp), 3),
      Pitch(Note(NoteLetter.c, Accidental.sharp), 4),
    ],
  );

  /// Half a step down — E♭2 A♭2 D♭3 G♭3 B♭3 E♭4.
  ///
  /// Spelled with flats because that is how the tuning is written and heard:
  /// players call it "E flat", not "D sharp".
  static const Tuning halfStepDown = Tuning(
    name: 'half-step-down',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.e, Accidental.flat), 2),
      Pitch(Note(NoteLetter.a, Accidental.flat), 2),
      Pitch(Note(NoteLetter.d, Accidental.flat), 3),
      Pitch(Note(NoteLetter.g, Accidental.flat), 3),
      Pitch(Note(NoteLetter.b, Accidental.flat), 3),
      Pitch(Note(NoteLetter.e, Accidental.flat), 4),
    ],
  );

  /// A whole step down — D2 G2 C3 F3 A3 D4.
  static const Tuning fullStepDown = Tuning(
    name: 'full-step-down',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.d), 2),
      Pitch(Note(NoteLetter.g), 2),
      Pitch(Note(NoteLetter.c), 3),
      Pitch(Note(NoteLetter.f), 3),
      Pitch(Note(NoteLetter.a), 3),
      Pitch(Note(NoteLetter.d), 4),
    ],
  );

  /// DADGAD — D2 A2 D3 G3 A3 D4.
  static const Tuning dadgad = Tuning(
    name: 'dadgad',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.d), 2),
      Pitch(Note(NoteLetter.a), 2),
      Pitch(Note(NoteLetter.d), 3),
      Pitch(Note(NoteLetter.g), 3),
      Pitch(Note(NoteLetter.a), 3),
      Pitch(Note(NoteLetter.d), 4),
    ],
  );

  /// Open G — D2 G2 D3 G3 B3 D4. The open strings sound a G major chord.
  static const Tuning openG = Tuning(
    name: 'open-g',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.d), 2),
      Pitch(Note(NoteLetter.g), 2),
      Pitch(Note(NoteLetter.d), 3),
      Pitch(Note(NoteLetter.g), 3),
      Pitch(Note(NoteLetter.b), 3),
      Pitch(Note(NoteLetter.d), 4),
    ],
  );

  /// Open D — D2 A2 D3 F♯3 A3 D4.
  static const Tuning openD = Tuning(
    name: 'open-d',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.d), 2),
      Pitch(Note(NoteLetter.a), 2),
      Pitch(Note(NoteLetter.d), 3),
      Pitch(Note(NoteLetter.f, Accidental.sharp), 3),
      Pitch(Note(NoteLetter.a), 3),
      Pitch(Note(NoteLetter.d), 4),
    ],
  );

  /// Open E — E2 B2 E3 G♯3 B3 E4.
  static const Tuning openE = Tuning(
    name: 'open-e',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.e), 2),
      Pitch(Note(NoteLetter.b), 2),
      Pitch(Note(NoteLetter.e), 3),
      Pitch(Note(NoteLetter.g, Accidental.sharp), 3),
      Pitch(Note(NoteLetter.b), 3),
      Pitch(Note(NoteLetter.e), 4),
    ],
  );

  /// Seven-string standard — a low B below the six-string set.
  static const Tuning sevenString = Tuning(
    name: 'seven-string',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.b), 1),
      Pitch(Note(NoteLetter.e), 2),
      Pitch(Note(NoteLetter.a), 2),
      Pitch(Note(NoteLetter.d), 3),
      Pitch(Note(NoteLetter.g), 3),
      Pitch(Note(NoteLetter.b), 3),
      Pitch(Note(NoteLetter.e), 4),
    ],
  );

  /// Eight-string standard — a low F♯ below the seven-string set.
  static const Tuning eightString = Tuning(
    name: 'eight-string',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.f, Accidental.sharp), 1),
      Pitch(Note(NoteLetter.b), 1),
      Pitch(Note(NoteLetter.e), 2),
      Pitch(Note(NoteLetter.a), 2),
      Pitch(Note(NoteLetter.d), 3),
      Pitch(Note(NoteLetter.g), 3),
      Pitch(Note(NoteLetter.b), 3),
      Pitch(Note(NoteLetter.e), 4),
    ],
  );

  /// Four-string bass — E1 A1 D2 G2, an octave below the guitar's lower four.
  static const Tuning bassFour = Tuning(
    name: 'bass-four',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.e), 1),
      Pitch(Note(NoteLetter.a), 1),
      Pitch(Note(NoteLetter.d), 2),
      Pitch(Note(NoteLetter.g), 2),
    ],
  );

  /// Five-string bass — a low B below the four-string set.
  static const Tuning bassFive = Tuning(
    name: 'bass-five',
    openStrings: <Pitch>[
      Pitch(Note(NoteLetter.b), 0),
      Pitch(Note(NoteLetter.e), 1),
      Pitch(Note(NoteLetter.a), 1),
      Pitch(Note(NoteLetter.d), 2),
      Pitch(Note(NoteLetter.g), 2),
    ],
  );

  /// Every tuning the app ships, standard first.
  ///
  /// Ordering is deliberate: standard, then the six-string alternatives a
  /// guitarist reaches for most often, then the extended-range instruments.
  /// Which of these cost money is not decided here — a tuning's notes do not
  /// change with a subscription, so `FeatureTier` is attached in a feature's
  /// `data/` layer (docs/ARCHITECTURE.md).
  static const List<Tuning> catalogue = <Tuning>[
    standard,
    dropD,
    dropC,
    dropB,
    halfStepDown,
    fullStepDown,
    dadgad,
    openG,
    openD,
    openE,
    sevenString,
    eightString,
    bassFour,
    bassFive,
  ];

  /// A stable identifier, not display copy. UI names come from the ARB files.
  final String name;

  /// Open-string pitches, lowest-sounding first.
  final List<Pitch> openStrings;

  /// How many strings the tuning has.
  int get stringCount => openStrings.length;

  /// The pitch sounded by [fret] on [stringIndex], counting the open string as
  /// fret 0.
  ///
  /// Throws [RangeError] for a string the tuning does not have, and
  /// [ArgumentError] for a negative fret.
  Pitch pitchAt({required int stringIndex, required int fret}) {
    if (stringIndex < 0 || stringIndex >= stringCount) {
      throw RangeError.index(stringIndex, openStrings, 'stringIndex');
    }
    if (fret < 0) {
      throw ArgumentError.value(fret, 'fret', 'must not be negative');
    }
    return openStrings[stringIndex].transposeChromatically(fret);
  }

  @override
  bool operator ==(Object other) =>
      other is Tuning &&
      other.name == name &&
      _sameStrings(other.openStrings, openStrings);

  @override
  int get hashCode => Object.hash(name, Object.hashAll(openStrings));

  static bool _sameStrings(List<Pitch> a, List<Pitch> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'Tuning($name: ${openStrings.map((p) => p.name).join(" ")})';
}
