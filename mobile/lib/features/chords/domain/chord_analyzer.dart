/// Naming a shape a player has built, rather than drawing one they asked for.
///
/// This is `chord_engine.dart` run backwards. The engine turns a named chord
/// into fingerings; the analyzer takes a fingering and works out what it
/// could be called. Both sit on the same eighteen formulas in
/// `core/music/chord_quality.dart`, because a library that draws C major one
/// way and names it another is two engines pretending to be one
/// (CLAUDE.md §4, §11).
///
/// Deterministic throughout. The same shape always produces the same list in
/// the same order, which is what keeps an AI feature out of a job that is
/// arithmetic (CLAUDE.md §17) and what makes the test suite meaningful.
///
/// Contains no Flutter. See docs/adr/0015.
library;

import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/interval.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/core/music/pitch.dart';
import 'package:l_key/core/music/tuning.dart';
import 'package:l_key/features/chords/domain/chord.dart';
import 'package:l_key/features/chords/domain/chord_engine.dart';
import 'package:l_key/features/chords/domain/chord_voicing.dart';
import 'package:meta/meta.dart';

/// One name a shape could go by, and how good a name it is.
@immutable
final class ChordCandidate {
  /// Creates a candidate.
  const ChordCandidate({
    required this.chord,
    required this.omitted,
    required this.score,
  });

  /// The chord, with its root, quality and — for a shape whose lowest note is
  /// not the root — its bass.
  final Chord chord;

  /// Chord tones the shape leaves out.
  ///
  /// Only ever intervals [ChordQuality.omittableIntervals] allows, so this is
  /// at most a perfect fifth today. It is carried rather than discarded so
  /// that printing `C(no5)` later is a copy change and not an engine change.
  final List<Interval> omitted;

  /// Higher is a better name. Only meaningful against other candidates for
  /// the same shape.
  final int score;

  /// Whether the shape sounds every tone the chord has.
  bool get isExact => omitted.isEmpty;

  @override
  String toString() => '${chord.symbol} ($score)';
}

/// What a shape turns out to be.
@immutable
final class ChordAnalysis {
  /// Creates an analysis.
  const ChordAnalysis({
    required this.pitches,
    required this.notes,
    required this.degrees,
    required this.candidates,
    this.bass,
  });

  /// Nothing is being played.
  const ChordAnalysis.silent()
    : pitches = const <Pitch>[],
      notes = const <Note?>[],
      degrees = const <Interval?>[],
      candidates = const <ChordCandidate>[],
      bass = null;

  /// The pitches the shape sounds, lowest first.
  final List<Pitch> pitches;

  /// The lowest sounding pitch, or null when nothing sounds.
  ///
  /// Distinct from the root, and deliberately so: `C/E` sounds an E lowest
  /// and is still a C chord (§13 of the brief, docs/adr/0015).
  final Pitch? bass;

  /// The note each string sounds, in string order, null where muted.
  ///
  /// Spelled by the best candidate, so the third of C♯ major reads E♯.
  final List<Note?> notes;

  /// The degree each string sounds above the best candidate's root.
  final List<Interval?> degrees;

  /// Every name the shape could go by, best first.
  final List<ChordCandidate> candidates;

  /// The best name, or null when nothing in the library fits.
  ChordCandidate? get best => candidates.isEmpty ? null : candidates.first;

  /// How many distinct pitch classes are sounding.
  int get toneCount =>
      pitches.map((pitch) => pitch.midiNumber % 12).toSet().length;

  /// Whether the shape sounds nothing at all.
  bool get isSilent => pitches.isEmpty;

  /// Whether the shape sounds exactly one note, which is not a chord.
  bool get isSingleNote => toneCount == 1;
}

/// Turns a shape into the names it could go by.
abstract final class ChordAnalyzer {
  /// How many names the analysis carries.
  ///
  /// An augmented triad and a diminished seventh are symmetrical and each
  /// genuinely has several equally correct names; past a handful the list
  /// stops informing anyone.
  static const int maxCandidates = 8;

  /// Names [voicing] as played in [tuning].
  static ChordAnalysis analyze(
    ChordVoicing voicing, {
    Tuning tuning = Tuning.standard,
  }) {
    final pitches = voicing.soundingPitches(tuning);
    if (pitches.isEmpty) return const ChordAnalysis.silent();

    final bass = pitches.first;
    final played = voicing.soundingPitchClasses(tuning);

    // One note is a note. Naming it a chord would be inventing the rest of
    // one (CLAUDE.md §47).
    final candidates = played.length < 2
        ? const <ChordCandidate>[]
        : _rank(played, bass.midiNumber % 12);

    final best = candidates.isEmpty ? null : candidates.first.chord;
    return ChordAnalysis(
      pitches: pitches,
      bass: bass,
      notes: voicing.soundingNotes(
        tuning,
        spelling: best?.notes ?? const <Note>[],
      ),
      degrees: best == null
          ? List<Interval?>.filled(voicing.strings.length, null)
          : ChordEngine.intervalsPerString(voicing, best, tuning),
      candidates: candidates,
    );
  }

  /// Every (root, quality) pair that could account for [played], ranked.
  ///
  /// Roots come from [Note.spellings] rather than from the twelve pitch
  /// classes, so C♯ major and D♭ major are both considered and each keeps its
  /// own spelling (docs/adr/0009).
  static List<ChordCandidate> _rank(Set<int> played, int bassPitchClass) {
    // The root's index is carried alongside so the sort key can be complete
    // without smuggling a tie-breaker into the score, where it would look
    // like a musical judgement.
    final found = <(ChordCandidate, int)>[];

    for (var rootIndex = 0; rootIndex < Note.spellings.length; rootIndex++) {
      final root = Note.spellings[rootIndex];
      for (final quality in ChordQuality.values) {
        final chord = Chord(root: root, quality: quality);
        final tones = _tonesOf(chord);
        if (tones == null) continue;

        // Every note the player is sounding has to belong to the chord. The
        // analyzer never invents an alteration or an added tone for a
        // formula the library does not have (CLAUDE.md §17, §47).
        if (!played.every(tones.containsKey)) continue;

        final omitted = <Interval>[
          for (final entry in tones.entries)
            if (!played.contains(entry.key)) entry.value,
        ];
        // The one omission rule in the codebase, reused rather than repeated:
        // the perfect fifth may go from a chord of four or more tones, an
        // altered fifth never may (docs/adr/0010).
        final omittable = quality.omittableIntervals;
        if (!omitted.every(omittable.contains)) continue;

        found.add((
          ChordCandidate(
            chord: _withBass(chord, bassPitchClass),
            omitted: omitted,
            score: _score(
              quality: quality,
              rootPitchClass: root.pitchClass,
              bassPitchClass: bassPitchClass,
              played: played,
              omittedCount: omitted.length,
              accidentals: _accidentalWeight(chord),
            ),
          ),
          rootIndex,
        ));
      }
    }

    // Score first, then the quality's own order, then the root's. Exhaustive,
    // so two runs over the same shape can never disagree.
    found.sort((a, b) {
      final byScore = b.$1.score.compareTo(a.$1.score);
      if (byScore != 0) return byScore;
      final byQuality = a.$1.chord.quality.index.compareTo(
        b.$1.chord.quality.index,
      );
      return byQuality != 0 ? byQuality : a.$2.compareTo(b.$2);
    });
    return List<ChordCandidate>.unmodifiable(
      found.take(maxCandidates).map((entry) => entry.$1),
    );
  }

  /// The chord's pitch classes mapped to the interval that produced each, or
  /// null when the chord cannot be spelled at all.
  static Map<int, Interval>? _tonesOf(Chord chord) {
    final tones = <int, Interval>{};
    for (final interval in chord.quality.intervals) {
      final note = chord.root.tryTransposeBy(interval);
      // A root needing a triple accidental is not a chord anyone writes.
      if (note == null) return null;
      tones[note.pitchClass] = interval;
    }
    return tones;
  }

  /// Names the bass when it is not the root, which is what makes `C/E`.
  static Chord _withBass(Chord chord, int bassPitchClass) {
    if (bassPitchClass == chord.root.pitchClass) return chord;
    final spelled = chord.notes.firstWhere(
      (note) => note.pitchClass == bassPitchClass,
      // Unreachable: a foreign bass was rejected before this point. Spelled
      // defensively rather than with a `!`, so a future relaxation of the
      // foreign-note rule fails visibly instead of throwing here.
      orElse: () => Note.fromPitchClass(bassPitchClass),
    );
    return Chord(root: chord.root, quality: chord.quality, bass: spelled);
  }

  /// How much a spelling costs in accidentals, double accidentals counting
  /// double. It is what separates C augmented from G♯ augmented, which are
  /// the same three sounds and not the same thing to read.
  static int _accidentalWeight(Chord chord) {
    var total = 0;
    for (final note in chord.notes) {
      total += note.accidental.offset.abs();
    }
    return total;
  }

  /// The ranking, in one place.
  ///
  /// Every term is an integer and the tie-breakers are exhaustive, so the
  /// order is total and a test can pin it. See docs/adr/0015 for why each
  /// term is worth what it is.
  static int _score({
    required ChordQuality quality,
    required int rootPitchClass,
    required int bassPitchClass,
    required Set<int> played,
    required int omittedCount,
    required int accidentals,
  }) {
    var score = 0;
    if (omittedCount == 0) score += 1000;
    if (played.contains(rootPitchClass)) score += 500;
    if (bassPitchClass == rootPitchClass) score += 300;
    // ChordQuality is declared simplest-first, so its own order is the
    // "common naming" preference and no second table is needed.
    score += 200 - 10 * quality.index;
    score -= 150 * omittedCount;
    score -= 5 * accidentals;
    return score;
  }
}
