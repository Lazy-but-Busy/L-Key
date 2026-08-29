/// The shape data the chord engine draws on.
///
/// Two tables. [movableShapes] holds fingering patterns that slide along the
/// neck, so one entry names a chord on every root. [openVoicings] holds the
/// open-position chords a guitarist actually learns first, which are not
/// transpositions of anything and have to be written down.
///
/// **Every entry in this file is checked at test time**, not trusted. The
/// engine's `validate` runs over all of it: no voicing may sound a note
/// outside its chord, leave out a tone it needs, span more than four frets or
/// ask for more than four fingers. A typo here fails the suite rather than
/// teaching someone the wrong shape.
///
/// Contains no Flutter. See docs/adr/0010.
library;

import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/features/chords/domain/chord_shape.dart';
import 'package:l_key/features/chords/domain/chord_voicing.dart';

/// A curated open-position voicing, keyed by the chord it spells.
///
/// Written as absolute frets because an open chord is not a transposition —
/// the open strings are what make it sound the way it does.
final class OpenVoicing {
  /// Creates a curated open voicing.
  const OpenVoicing({
    required this.root,
    required this.quality,
    required this.frets,
    required this.fingers,
  });

  /// The chord's root.
  final Note root;

  /// The chord's quality.
  final ChordQuality quality;

  /// Absolute fret per string, lowest-sounding first. [mutedOffset] is muted.
  final List<int> frets;

  /// Fretting finger per string, 0 where the string is open or muted.
  final List<int> fingers;

  /// The voicing as the engine hands it to the diagram.
  ChordVoicing toVoicing() {
    final strings = <FrettedString>[];
    for (var index = 0; index < frets.length; index++) {
      final fret = frets[index];
      if (fret == mutedOffset) {
        strings.add(FrettedString.muted(index));
      } else if (fret == 0) {
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
    return ChordVoicing(strings: strings, label: 'open');
  }
}

/// Fingering patterns that name a different chord at every fret.
///
/// Two families: the root on the sixth string (the "E shape", because at the
/// nut it is the open E chord) and on the fifth string (the "A shape"). Five
/// combinations are absent — there is no playable A-shape ninth, and no
/// E-shape sus2 inside a four-fret span — and that is fine, because the other
/// family covers every root for those qualities.
const List<MovableShape> movableShapes = <MovableShape>[
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.major,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 2, 2, 2, 0],
    fingers: <int>[0, 1, 3, 3, 3, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.major,
    rootString: 0,
    offsets: <int>[0, 2, 2, 1, 0, 0],
    fingers: <int>[1, 3, 4, 2, 1, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.minor,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 2, 2, 1, 0],
    fingers: <int>[0, 1, 3, 4, 2, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.minor,
    rootString: 0,
    offsets: <int>[0, 2, 2, 0, 0, 0],
    fingers: <int>[1, 3, 4, 1, 1, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.dominantSeventh,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 2, 0, 2, 0],
    fingers: <int>[0, 1, 3, 1, 4, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.dominantSeventh,
    rootString: 0,
    offsets: <int>[0, 2, 0, 1, 0, 0],
    fingers: <int>[1, 3, 1, 2, 1, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.majorSeventh,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 2, 1, 2, 0],
    fingers: <int>[0, 1, 3, 2, 4, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.majorSeventh,
    rootString: 0,
    offsets: <int>[0, 2, 1, 1, 0, 0],
    fingers: <int>[1, 4, 2, 3, 1, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.minorSeventh,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 2, 0, 1, 0],
    fingers: <int>[0, 1, 3, 1, 2, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.minorSeventh,
    rootString: 0,
    offsets: <int>[0, 2, 0, 0, 0, 0],
    fingers: <int>[1, 3, 1, 1, 1, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.sixth,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 2, 2, 2, 2],
    fingers: <int>[0, 1, 3, 3, 3, 3],
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.sixth,
    rootString: 0,
    offsets: <int>[0, 2, 2, 1, 2, 0],
    fingers: <int>[1, 3, 3, 2, 4, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.ninth,
    rootString: 0,
    offsets: <int>[0, 2, 0, 1, 0, 2],
    fingers: <int>[1, 3, 1, 2, 1, 4],
    barreToString: 4,
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.majorNinth,
    rootString: 0,
    offsets: <int>[0, 2, 1, 1, 0, 2],
    fingers: <int>[1, 3, 2, 2, 1, 4],
    barreToString: 4,
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.minorNinth,
    rootString: 0,
    offsets: <int>[0, 2, 0, 0, 0, 2],
    fingers: <int>[1, 2, 1, 1, 1, 3],
    barreToString: 4,
  ),
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.suspendedSecond,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 2, 2, 0, 0],
    fingers: <int>[0, 1, 3, 4, 1, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.suspendedFourth,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 0, 2, 3, 0],
    fingers: <int>[0, 1, 1, 2, 3, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.suspendedFourth,
    rootString: 0,
    offsets: <int>[0, 0, 2, 2, 0, 0],
    fingers: <int>[1, 1, 3, 4, 1, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.addedNinth,
    rootString: 0,
    offsets: <int>[0, 2, 2, 1, 0, 2],
    fingers: <int>[1, 3, 3, 2, 1, 4],
    barreToString: 4,
  ),
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.diminished,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 1, 2, 1, mutedOffset],
    fingers: <int>[0, 1, 2, 3, 2, 0],
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.diminished,
    rootString: 0,
    offsets: <int>[0, 1, 2, 0, mutedOffset, mutedOffset],
    fingers: <int>[1, 2, 3, 1, 0, 0],
    barreToString: 3,
  ),
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.augmented,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 3, 2, 2, 1],
    fingers: <int>[0, 1, 4, 3, 3, 2],
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.augmented,
    rootString: 0,
    offsets: <int>[0, 3, 2, 1, 1, 0],
    fingers: <int>[1, 4, 3, 2, 2, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.diminishedSeventh,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 1, 2, 1, 2],
    fingers: <int>[0, 1, 2, 3, 2, 4],
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.diminishedSeventh,
    rootString: 0,
    offsets: <int>[0, 1, 2, 0, 2, 0],
    fingers: <int>[1, 2, 3, 1, 4, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.halfDiminished,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 1, 0, 1, 3],
    fingers: <int>[0, 1, 2, 1, 3, 4],
    barreToString: 3,
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.halfDiminished,
    rootString: 0,
    offsets: <int>[0, 1, 0, 0, 3, 0],
    fingers: <int>[1, 2, 1, 1, 3, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.minorSixth,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 2, 2, 1, 2],
    fingers: <int>[0, 1, 3, 3, 2, 4],
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.minorSixth,
    rootString: 0,
    offsets: <int>[0, 2, 2, 0, 2, 0],
    fingers: <int>[1, 2, 2, 1, 3, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'A-shape',
    quality: ChordQuality.seventhSuspendedFourth,
    rootString: 1,
    offsets: <int>[mutedOffset, 0, 0, 0, 3, 0],
    fingers: <int>[0, 1, 1, 1, 2, 1],
    barreToString: 5,
  ),
  MovableShape(
    name: 'E-shape',
    quality: ChordQuality.seventhSuspendedFourth,
    rootString: 0,
    offsets: <int>[0, 0, 0, 2, 0, 0],
    fingers: <int>[1, 1, 1, 2, 1, 1],
    barreToString: 5,
  ),
];

/// The open-position chords, hand-written and hand-checked.
///
/// PRD.md §11 names C, D, E, F, G, A, B, Am, Dm and Em as the chords a free
/// user gets. F and B have no open form — they are barre chords, and the
/// movable shapes cover them at the first and second frets.
const List<OpenVoicing> openVoicings = <OpenVoicing>[
  OpenVoicing(
    root: Note(NoteLetter.c),
    quality: ChordQuality.major,
    frets: <int>[mutedOffset, 3, 2, 0, 1, 0],
    fingers: <int>[0, 3, 2, 0, 1, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.c),
    quality: ChordQuality.majorSeventh,
    frets: <int>[mutedOffset, 3, 2, 0, 0, 0],
    fingers: <int>[0, 3, 2, 0, 0, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.c),
    quality: ChordQuality.dominantSeventh,
    frets: <int>[mutedOffset, 3, 2, 3, 1, 0],
    fingers: <int>[0, 3, 2, 4, 1, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.c),
    quality: ChordQuality.addedNinth,
    frets: <int>[mutedOffset, 3, 2, 0, 3, 0],
    fingers: <int>[0, 2, 1, 0, 4, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.d),
    quality: ChordQuality.major,
    frets: <int>[mutedOffset, mutedOffset, 0, 2, 3, 2],
    fingers: <int>[0, 0, 0, 1, 3, 2],
  ),
  OpenVoicing(
    root: Note(NoteLetter.d),
    quality: ChordQuality.minor,
    frets: <int>[mutedOffset, mutedOffset, 0, 2, 3, 1],
    fingers: <int>[0, 0, 0, 2, 3, 1],
  ),
  OpenVoicing(
    root: Note(NoteLetter.d),
    quality: ChordQuality.dominantSeventh,
    frets: <int>[mutedOffset, mutedOffset, 0, 2, 1, 2],
    fingers: <int>[0, 0, 0, 2, 1, 3],
  ),
  OpenVoicing(
    root: Note(NoteLetter.d),
    quality: ChordQuality.majorSeventh,
    frets: <int>[mutedOffset, mutedOffset, 0, 2, 2, 2],
    fingers: <int>[0, 0, 0, 1, 1, 1],
  ),
  OpenVoicing(
    root: Note(NoteLetter.d),
    quality: ChordQuality.minorSeventh,
    frets: <int>[mutedOffset, mutedOffset, 0, 2, 1, 1],
    fingers: <int>[0, 0, 0, 2, 1, 1],
  ),
  OpenVoicing(
    root: Note(NoteLetter.d),
    quality: ChordQuality.suspendedSecond,
    frets: <int>[mutedOffset, mutedOffset, 0, 2, 3, 0],
    fingers: <int>[0, 0, 0, 1, 3, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.d),
    quality: ChordQuality.suspendedFourth,
    frets: <int>[mutedOffset, mutedOffset, 0, 2, 3, 3],
    fingers: <int>[0, 0, 0, 1, 2, 3],
  ),
  OpenVoicing(
    root: Note(NoteLetter.e),
    quality: ChordQuality.major,
    frets: <int>[0, 2, 2, 1, 0, 0],
    fingers: <int>[0, 2, 3, 1, 0, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.e),
    quality: ChordQuality.minor,
    frets: <int>[0, 2, 2, 0, 0, 0],
    fingers: <int>[0, 2, 3, 0, 0, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.e),
    quality: ChordQuality.dominantSeventh,
    frets: <int>[0, 2, 0, 1, 0, 0],
    fingers: <int>[0, 2, 0, 1, 0, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.e),
    quality: ChordQuality.minorSeventh,
    frets: <int>[0, 2, 0, 0, 0, 0],
    fingers: <int>[0, 2, 0, 0, 0, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.e),
    quality: ChordQuality.majorSeventh,
    frets: <int>[0, 2, 1, 1, 0, 0],
    fingers: <int>[0, 3, 1, 2, 0, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.e),
    quality: ChordQuality.suspendedFourth,
    frets: <int>[0, 2, 2, 2, 0, 0],
    fingers: <int>[0, 1, 2, 3, 0, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.f),
    quality: ChordQuality.majorSeventh,
    frets: <int>[mutedOffset, mutedOffset, 3, 2, 1, 0],
    fingers: <int>[0, 0, 3, 2, 1, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.g),
    quality: ChordQuality.major,
    frets: <int>[3, 2, 0, 0, 0, 3],
    fingers: <int>[2, 1, 0, 0, 0, 3],
  ),
  OpenVoicing(
    root: Note(NoteLetter.g),
    quality: ChordQuality.dominantSeventh,
    frets: <int>[3, 2, 0, 0, 0, 1],
    fingers: <int>[3, 2, 0, 0, 0, 1],
  ),
  OpenVoicing(
    root: Note(NoteLetter.g),
    quality: ChordQuality.majorSeventh,
    frets: <int>[3, 2, 0, 0, 0, 2],
    fingers: <int>[3, 1, 0, 0, 0, 2],
  ),
  OpenVoicing(
    root: Note(NoteLetter.a),
    quality: ChordQuality.major,
    frets: <int>[mutedOffset, 0, 2, 2, 2, 0],
    fingers: <int>[0, 0, 1, 2, 3, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.a),
    quality: ChordQuality.minor,
    frets: <int>[mutedOffset, 0, 2, 2, 1, 0],
    fingers: <int>[0, 0, 2, 3, 1, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.a),
    quality: ChordQuality.dominantSeventh,
    frets: <int>[mutedOffset, 0, 2, 0, 2, 0],
    fingers: <int>[0, 0, 2, 0, 3, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.a),
    quality: ChordQuality.minorSeventh,
    frets: <int>[mutedOffset, 0, 2, 0, 1, 0],
    fingers: <int>[0, 0, 2, 0, 1, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.a),
    quality: ChordQuality.majorSeventh,
    frets: <int>[mutedOffset, 0, 2, 1, 2, 0],
    fingers: <int>[0, 0, 2, 1, 3, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.a),
    quality: ChordQuality.suspendedSecond,
    frets: <int>[mutedOffset, 0, 2, 2, 0, 0],
    fingers: <int>[0, 0, 1, 2, 0, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.a),
    quality: ChordQuality.suspendedFourth,
    frets: <int>[mutedOffset, 0, 2, 2, 3, 0],
    fingers: <int>[0, 0, 1, 2, 3, 0],
  ),
  OpenVoicing(
    root: Note(NoteLetter.b),
    quality: ChordQuality.dominantSeventh,
    frets: <int>[mutedOffset, 2, 1, 2, 0, 2],
    fingers: <int>[0, 2, 1, 3, 0, 4],
  ),
];

/// A curated voicing for a chord with a named bass note.
///
/// Slash chords are not derived. Moving a bass into place mechanically —
/// muting strings until the right note is lowest, or reaching for a fret
/// outside the shape — produces fingerings no one would teach, and
/// CLAUDE.md §47 would rather the library say nothing than invent one. So the
/// common ones are written down, and a slash chord with no entry falls back to
/// any ordinary voicing that already happens to put the bass lowest.
final class SlashVoicing {
  /// Creates a curated slash-chord voicing.
  const SlashVoicing({
    required this.root,
    required this.quality,
    required this.bass,
    required this.frets,
    required this.fingers,
  });

  /// The chord's root.
  final Note root;

  /// The chord's quality.
  final ChordQuality quality;

  /// The note that must sound lowest.
  final Note bass;

  /// Absolute fret per string, lowest-sounding first. [mutedOffset] is muted.
  final List<int> frets;

  /// Fretting finger per string, 0 where the string is open or muted.
  final List<int> fingers;

  /// The voicing as the engine hands it to the diagram.
  ChordVoicing toVoicing() {
    final strings = <FrettedString>[];
    for (var index = 0; index < frets.length; index++) {
      final fret = frets[index];
      if (fret == mutedOffset) {
        strings.add(FrettedString.muted(index));
      } else if (fret == 0) {
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
    return ChordVoicing(strings: strings, label: 'slash');
  }
}

/// The slash chords worth writing down: inversions a player meets constantly
/// in the repertoire, and the descending bass lines they come from.
const List<SlashVoicing> slashVoicings = <SlashVoicing>[
  SlashVoicing(
    root: Note(NoteLetter.c),
    quality: ChordQuality.major,
    bass: Note(NoteLetter.g),
    frets: <int>[3, 3, 2, 0, 1, 0],
    fingers: <int>[3, 4, 2, 0, 1, 0],
  ),
  SlashVoicing(
    root: Note(NoteLetter.c),
    quality: ChordQuality.major,
    bass: Note(NoteLetter.e),
    frets: <int>[0, 3, 2, 0, 1, 0],
    fingers: <int>[0, 3, 2, 0, 1, 0],
  ),
  SlashVoicing(
    root: Note(NoteLetter.d),
    quality: ChordQuality.major,
    bass: Note(NoteLetter.f, Accidental.sharp),
    frets: <int>[2, 0, 0, 2, 3, 2],
    fingers: <int>[1, 0, 0, 2, 4, 3],
  ),
  SlashVoicing(
    root: Note(NoteLetter.d),
    quality: ChordQuality.major,
    bass: Note(NoteLetter.a),
    frets: <int>[mutedOffset, 0, 0, 2, 3, 2],
    fingers: <int>[0, 0, 0, 1, 3, 2],
  ),
  SlashVoicing(
    root: Note(NoteLetter.g),
    quality: ChordQuality.major,
    bass: Note(NoteLetter.b),
    frets: <int>[mutedOffset, 2, 0, 0, 0, 3],
    fingers: <int>[0, 1, 0, 0, 0, 2],
  ),
  SlashVoicing(
    root: Note(NoteLetter.a),
    quality: ChordQuality.minor,
    bass: Note(NoteLetter.g),
    frets: <int>[3, 0, 2, 2, 1, 0],
    fingers: <int>[4, 0, 2, 3, 1, 0],
  ),
  SlashVoicing(
    root: Note(NoteLetter.f),
    quality: ChordQuality.major,
    bass: Note(NoteLetter.c),
    frets: <int>[mutedOffset, 3, 3, 2, 1, 1],
    fingers: <int>[0, 3, 4, 2, 1, 1],
  ),
  SlashVoicing(
    root: Note(NoteLetter.e),
    quality: ChordQuality.minor,
    bass: Note(NoteLetter.b),
    frets: <int>[mutedOffset, 2, 2, 0, 0, 0],
    fingers: <int>[0, 2, 3, 0, 0, 0],
  ),
];
