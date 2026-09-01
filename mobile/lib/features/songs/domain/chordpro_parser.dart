/// Reading ChordPro: metadata directives, sections, and inline chords.
///
/// ChordPro writes a chord immediately before the syllable it lands on —
/// `[G]Amazing [G7]grace` — rather than in a separate row, which is what lets
/// this parser stay a single pass over the text with no layout knowledge at
/// all. Rendering chords above lyrics is a presentation concern; this only
/// produces the segments a renderer needs.
///
/// Malformed input degrades gracefully rather than throwing (CLAUDE.md §37):
/// an unterminated `[` keeps the rest of the line as literal text, and a
/// bracket whose contents are not a chord this app understands is kept
/// literally too, rather than silently dropped.
///
/// Contains no Flutter.
library;

import 'package:l_key/features/chords/domain/chord.dart';
import 'package:l_key/features/chords/domain/chord_symbol.dart';
import 'package:meta/meta.dart';

/// One run of lyric text, with the chord that starts sounding at it.
@immutable
final class ChordProSegment {
  /// Creates a segment.
  const ChordProSegment({required this.lyric, this.chord});

  /// The lyric text from this point up to the next chord, or the end of the
  /// line. May be empty, when two chords sit back to back.
  final String lyric;

  /// The chord that begins sounding here, or null when no chord precedes it
  /// (the start of a line before its first bracket, or a line with none).
  final Chord? chord;

  @override
  bool operator ==(Object other) =>
      other is ChordProSegment && other.lyric == lyric && other.chord == chord;

  @override
  int get hashCode => Object.hash(lyric, chord);
}

/// One line of a song: its segments, and the section it opens, if any.
@immutable
final class ChordProLine {
  /// Creates a line.
  const ChordProLine({required this.segments, this.sectionLabel});

  /// The line's chord/lyric segments. Empty for a blank line, kept so the
  /// renderer can reproduce the song's own spacing.
  final List<ChordProSegment> segments;

  /// The section this line begins, such as `Verse` or `Chorus` — set only on
  /// the first line after a `{start_of_...}` directive, never repeated on
  /// every line inside it.
  final String? sectionLabel;

  @override
  bool operator ==(Object other) =>
      other is ChordProLine &&
      other.sectionLabel == sectionLabel &&
      _sameSegments(other.segments, segments);

  @override
  int get hashCode => Object.hash(sectionLabel, Object.hashAll(segments));

  static bool _sameSegments(List<ChordProSegment> a, List<ChordProSegment> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// A parsed ChordPro document: its metadata directives and its lines.
@immutable
final class ChordProSong {
  /// Creates a parsed document.
  const ChordProSong({required this.metadata, required this.lines});

  /// Every `{directive: value}` seen, keyed by directive name, lower-cased.
  /// Common aliases (`t` for `title`, `st`/`subtitle` for `artist`) are
  /// folded onto one key.
  final Map<String, String> metadata;

  /// The song's lines, in order.
  final List<ChordProLine> lines;
}

/// Parses ChordPro source text.
abstract final class ChordProParser {
  /// Parses [source] into metadata and lines.
  ///
  /// Never throws — a malformed directive, an unterminated bracket, or a
  /// chord this app cannot spell are all kept as harmlessly as possible
  /// rather than aborting the rest of the song.
  static ChordProSong parse(String source) {
    final metadata = <String, String>{};
    final lines = <ChordProLine>[];
    String? pendingSection;

    for (final rawLine in source.split('\n')) {
      final line = rawLine.trimRight();
      final directive = _tryParseDirective(line);

      if (directive != null) {
        final key = directive.key;
        final value = directive.value;
        switch (key) {
          case 'start_of_verse':
          case 'sov':
            pendingSection = 'Verse';
          case 'start_of_chorus':
          case 'soc':
            pendingSection = 'Chorus';
          case 'start_of_bridge':
          case 'sob':
            pendingSection = 'Bridge';
          case 'end_of_verse':
          case 'eov':
          case 'end_of_chorus':
          case 'eoc':
          case 'end_of_bridge':
          case 'eob':
            break;
          case 'comment':
          case 'c':
            break;
          case 't':
          case 'title':
            metadata['title'] = value;
          case 'st':
          case 'subtitle':
          case 'artist':
            metadata['artist'] = value;
          default:
            metadata[key] = value;
        }
        continue;
      }

      if (line.trim().isEmpty) {
        lines.add(const ChordProLine(segments: <ChordProSegment>[]));
        continue;
      }

      lines.add(_parseLyricLine(line, sectionLabel: pendingSection));
      pendingSection = null;
    }

    return ChordProSong(
      metadata: Map<String, String>.unmodifiable(metadata),
      lines: List<ChordProLine>.unmodifiable(lines),
    );
  }

  /// A `{key}` or `{key: value}` line, or null when [line] is not a
  /// directive at all — including an unterminated `{` with no closing `}`,
  /// which is treated as ordinary lyric text instead of thrown away.
  static MapEntry<String, String>? _tryParseDirective(String line) {
    final trimmed = line.trim();
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) return null;

    final inner = trimmed.substring(1, trimmed.length - 1);
    final colon = inner.indexOf(':');
    final key = (colon == -1 ? inner : inner.substring(0, colon))
        .trim()
        .toLowerCase();
    if (key.isEmpty) return null;

    final value = colon == -1 ? '' : inner.substring(colon + 1).trim();
    return MapEntry<String, String>(key, value);
  }

  /// Splits [line] into chord/lyric segments, keeping malformed brackets
  /// literal rather than dropping them.
  static ChordProLine _parseLyricLine(String line, {String? sectionLabel}) {
    final segments = <ChordProSegment>[];
    final buffer = StringBuffer();
    Chord? pendingChord;
    var i = 0;

    while (i < line.length) {
      if (line[i] != '[') {
        buffer.write(line[i]);
        i += 1;
        continue;
      }

      final close = line.indexOf(']', i);
      if (close == -1) {
        // No closing bracket for the rest of the line: keep it as text.
        buffer.write(line.substring(i));
        break;
      }

      final chord = ChordSymbol.tryParse(line.substring(i + 1, close));
      if (chord == null) {
        // Not a chord this app can spell: keep the brackets literally so
        // nothing silently disappears.
        buffer.write(line.substring(i, close + 1));
      } else {
        segments.add(
          ChordProSegment(lyric: buffer.toString(), chord: pendingChord),
        );
        buffer.clear();
        pendingChord = chord;
      }
      i = close + 1;
    }

    segments.add(
      ChordProSegment(lyric: buffer.toString(), chord: pendingChord),
    );
    return ChordProLine(segments: segments, sectionLabel: sectionLabel);
  }
}
