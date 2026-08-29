/// A chord as it is actually played: which string is stopped where, by which
/// finger, and which strings are silent.
///
/// This is the structure the diagram renders and the audio placeholder would
/// eventually sound. It is deliberately dumb — it records a fingering and can
/// describe itself, but it does not decide whether a fingering is good. That
/// is `chord_engine.dart`.
///
/// Contains no Flutter. See docs/adr/0009.
library;

import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/pitch.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:meta/meta.dart';

/// What is happening to one string.
enum StringState {
  /// Not sounded. Drawn `X` above the nut (DESIGN.md §24).
  muted,

  /// Sounded unstopped. Drawn `O` above the nut.
  open,

  /// Stopped at a fret.
  fretted,
}

/// One string of a voicing.
@immutable
final class FrettedString {
  /// Creates a fretted string. Prefer the named constructors.
  const FrettedString({
    required this.stringIndex,
    required this.state,
    this.fret,
    this.finger,
  });

  /// A string that is not played.
  const FrettedString.muted(this.stringIndex)
    : state = StringState.muted,
      fret = null,
      finger = null;

  /// A string played unstopped.
  const FrettedString.open(this.stringIndex)
    : state = StringState.open,
      fret = null,
      finger = null;

  /// A string stopped at [fret], optionally by a named [finger].
  const FrettedString.at(this.stringIndex, this.fret, {this.finger})
    : state = StringState.fretted;

  /// Which string, counted lowest-sounding first to match [Tuning].
  final int stringIndex;

  /// Whether the string is muted, open or stopped.
  final StringState state;

  /// Absolute fret number when [state] is [StringState.fretted].
  final int? fret;

  /// Fretting finger 1–4, or null when the shape does not name one.
  ///
  /// Never set for an open or muted string.
  final int? finger;

  /// Whether this string makes a sound.
  bool get sounds => state != StringState.muted;

  /// The absolute fret this string sounds at: 0 when open, [fret] when
  /// stopped, and null when muted.
  int? get soundingFret => switch (state) {
    StringState.muted => null,
    StringState.open => 0,
    StringState.fretted => fret,
  };

  @override
  bool operator ==(Object other) =>
      other is FrettedString &&
      other.stringIndex == stringIndex &&
      other.state == state &&
      other.fret == fret &&
      other.finger == finger;

  @override
  int get hashCode => Object.hash(stringIndex, state, fret, finger);

  @override
  String toString() => switch (state) {
    StringState.muted => 'x',
    StringState.open => '0',
    StringState.fretted => '$fret',
  };
}

/// One finger laid flat across several strings at the same fret.
///
/// PRD.md §11 requires a barre indicator, and the diagram cannot infer one:
/// three strings at fret 5 might be a barre or might be three fingers.
@immutable
final class Barre {
  /// Creates a barre at [fret] spanning [lowString] to [highString] inclusive.
  const Barre({
    required this.fret,
    required this.lowString,
    required this.highString,
    this.finger = 1,
  });

  /// The fret the finger lies across.
  final int fret;

  /// Lowest string covered, counted lowest-sounding first.
  final int lowString;

  /// Highest string covered, inclusive.
  final int highString;

  /// The finger doing the barring. Almost always the index finger.
  final int finger;

  /// How many strings the barre covers.
  int get stringSpan => highString - lowString + 1;

  /// Whether the barre covers [stringIndex].
  bool covers(int stringIndex) =>
      stringIndex >= lowString && stringIndex <= highString;

  @override
  bool operator ==(Object other) =>
      other is Barre &&
      other.fret == fret &&
      other.lowString == lowString &&
      other.highString == highString &&
      other.finger == finger;

  @override
  int get hashCode => Object.hash(fret, lowString, highString, finger);

  @override
  String toString() => 'Barre(fret $fret, strings $lowString-$highString)';
}

/// A complete, playable chord shape.
@immutable
final class ChordVoicing {
  /// Creates a voicing from one entry per string, lowest-sounding first.
  const ChordVoicing({required this.strings, this.barre, this.label});

  /// One entry per string of the tuning, lowest-sounding first.
  final List<FrettedString> strings;

  /// The barre, when the shape has one.
  final Barre? barre;

  /// A stable identifier for the shape this came from, for diagnostics.
  ///
  /// Not display copy — the interface labels a voicing by its position.
  final String? label;

  /// The strings that sound.
  Iterable<FrettedString> get soundingStrings =>
      strings.where((string) => string.sounds);

  /// Indices of the muted strings.
  List<int> get mutedStrings => strings
      .where((string) => string.state == StringState.muted)
      .map((string) => string.stringIndex)
      .toList(growable: false);

  /// Indices of the open strings.
  List<int> get openStrings => strings
      .where((string) => string.state == StringState.open)
      .map((string) => string.stringIndex)
      .toList(growable: false);

  /// Every stopped fret in the shape, unsorted.
  Iterable<int> get frettedFrets => strings
      .where((string) => string.state == StringState.fretted)
      .map((string) => string.fret!);

  /// The lowest stopped fret, or 0 when nothing is stopped.
  int get lowestFret =>
      frettedFrets.isEmpty ? 0 : frettedFrets.reduce((a, b) => a < b ? a : b);

  /// The highest stopped fret, or 0 when nothing is stopped.
  int get highestFret =>
      frettedFrets.isEmpty ? 0 : frettedFrets.reduce((a, b) => a > b ? a : b);

  /// How many frets the hand has to cover.
  int get fretSpan => frettedFrets.isEmpty ? 0 : highestFret - lowestFret + 1;

  /// How many fingers the shape asks for.
  ///
  /// Counted as *distinct fingers named*, not as stopped strings. One finger
  /// laid across four strings is one finger — that is the whole point of
  /// barring, and it is not only the index that does it: the A-shape sixth
  /// chord is an index finger plus a ring finger flat across four strings.
  /// Counting strings instead would reject shapes a hand plays comfortably.
  int get fingerCount {
    final named = <int>{};
    var unnamed = 0;
    for (final string in strings) {
      if (string.state != StringState.fretted) continue;
      final finger = string.finger;
      if (finger == null) {
        unnamed += 1;
      } else {
        named.add(finger);
      }
    }
    return named.length + unnamed;
  }

  /// Whether the shape leaves any string ringing open.
  bool get isOpenPosition => openStrings.isNotEmpty;

  /// Whether the diagram draws the nut rather than a fret number.
  ///
  /// Any open string puts the nut in the picture, and so does a shape sitting
  /// at the first fret — an F barre is drawn against the nut.
  bool get includesNut =>
      openStrings.isNotEmpty || frettedFrets.isEmpty || lowestFret <= 1;

  /// The fret the diagram's grid starts at.
  ///
  /// Zero means the nut is drawn. Anything else is a movable shape, and the
  /// diagram prints the number beside the grid — a barre chord without its
  /// fret number is unreadable.
  int get baseFret => includesNut ? 0 : lowestFret;

  /// The pitches this voicing sounds, lowest first.
  List<Pitch> soundingPitches(Tuning tuning) {
    final pitches = <Pitch>[
      for (final string in soundingStrings)
        tuning.pitchAt(
          stringIndex: string.stringIndex,
          fret: string.soundingFret!,
        ),
    ]..sort();
    return pitches;
  }

  /// The distinct pitch classes this voicing sounds.
  Set<int> soundingPitchClasses(Tuning tuning) => <int>{
    for (final pitch in soundingPitches(tuning)) pitch.midiNumber % 12,
  };

  /// The note sounded by each string, in string order, null where muted.
  ///
  /// Spelled against [spelling] so a chord's own notes read correctly: the
  /// third of C♯ major prints as E♯, not F.
  List<Note?> soundingNotes(Tuning tuning, {List<Note> spelling = const []}) {
    return <Note?>[
      for (final string in strings)
        if (!string.sounds)
          null
        else
          _spell(
            tuning
                    .pitchAt(
                      stringIndex: string.stringIndex,
                      fret: string.soundingFret!,
                    )
                    .midiNumber %
                12,
            spelling,
          ),
    ];
  }

  static Note _spell(int pitchClass, List<Note> spelling) {
    for (final note in spelling) {
      if (note.pitchClass == pitchClass) return note;
    }
    return Note.fromPitchClass(pitchClass);
  }

  /// The shape written the way a chord chart writes it, e.g. `x32010`.
  ///
  /// Frets above nine are separated so `10` cannot read as `1` then `0`.
  String get fretString {
    final needsSeparator = highestFret > 9;
    final parts = strings.map((string) => string.toString());
    return needsSeparator ? parts.join(' ') : parts.join();
  }

  @override
  bool operator ==(Object other) =>
      other is ChordVoicing &&
      other.barre == barre &&
      _sameStrings(other.strings, strings);

  @override
  int get hashCode => Object.hash(Object.hashAll(strings), barre);

  static bool _sameStrings(List<FrettedString> a, List<FrettedString> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() => 'ChordVoicing($fretString)';
}
