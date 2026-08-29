/// Reading and writing chord symbols.
///
/// Separated from `Chord` because parsing is where the messy real-world
/// spellings live — `CM7`, `CΔ`, `C-7`, `C°7`, `Cø` and `C♯m7♭5/G` all name
/// chords this app has to understand, and none of that belongs in the value
/// type.
///
/// Contains no Flutter. See docs/adr/0009.
library;

import 'package:l_key/core/music/chord_quality.dart';
import 'package:l_key/core/music/note.dart';
import 'package:l_key/features/chords/domain/chord.dart';

/// Parses chord symbols into [Chord]s.
abstract final class ChordSymbol {
  /// Parses a chord symbol such as `C`, `Am7`, `C#m7b5/G` or `CΔ9`.
  ///
  /// Returns null on anything it cannot read, rather than throwing: this
  /// parses content and player input, and CLAUDE.md §37 wants a handled
  /// outcome rather than an exception reaching a screen.
  static Chord? tryParse(String input) {
    final text = input.trim();
    if (text.isEmpty) return null;

    final slash = text.indexOf('/');
    final head = slash == -1 ? text : text.substring(0, slash);
    final tail = slash == -1 ? null : text.substring(slash + 1);

    if (slash != -1 && (tail == null || tail.isEmpty)) return null;

    final bass = tail == null ? null : Note.tryParse(tail);
    if (tail != null && bass == null) return null;

    final rootLength = _rootLength(head);
    if (rootLength == 0) return null;

    final root = Note.tryParse(head.substring(0, rootLength));
    if (root == null) return null;

    final quality = _quality(head.substring(rootLength));
    if (quality == null) return null;

    return Chord(root: root, quality: quality, bass: bass);
  }

  /// How many characters at the start of [symbol] form the root note.
  ///
  /// A letter plus any run of accidentals. `Bb` is a root of two characters;
  /// `Bm` is a root of one followed by a quality.
  static int _rootLength(String symbol) {
    if (symbol.isEmpty || NoteLetter.tryParse(symbol[0]) == null) return 0;

    var length = 1;
    while (length < symbol.length) {
      const accidentals = <String>{'#', '♯', '♭', 'b'};
      // A lone trailing `b` is an accidental only while more of the symbol
      // could still be a quality — but `Bb` and `Bbb` are both roots, so the
      // rule is simply: consume accidentals, and let the quality lookup
      // reject what is left.
      if (!accidentals.contains(symbol[length])) break;
      length += 1;
    }
    return length;
  }

  /// Resolves a quality suffix, checking longest spellings first.
  static ChordQuality? _quality(String suffix) {
    final normalised = suffix.replaceAll('♭', 'b').replaceAll('♯', '#');
    if (normalised.isEmpty) return ChordQuality.major;

    ChordQuality? best;
    var bestLength = -1;
    for (final quality in ChordQuality.values) {
      for (final spelling in <String>[quality.symbol, ...quality.aliases]) {
        if (spelling.isEmpty) continue;
        if (spelling == normalised && spelling.length > bestLength) {
          best = quality;
          bestLength = spelling.length;
        }
      }
    }
    return best;
  }
}
