/// Folding text for cross-locale search.
///
/// Search has to work in English and in Myanmar (CLAUDE.md §32), and every
/// music feature that offers it — chords today, songs from Phase 07 — needs
/// the same fold. Sharing it here keeps neither feature reaching into the
/// other's domain (docs/ARCHITECTURE.md: no feature domain imports a sibling
/// feature).
///
/// Contains no Flutter.
library;

/// Ranked-search text normalisation, shared across music features.
abstract final class SearchText {
  /// Folds a query or a name into the form both sides are compared in.
  ///
  /// Unicode accidentals become their ASCII equivalents so `C♯` and `C#` are
  /// one query, case is dropped, and every kind of space and separator goes —
  /// a player typing `c maj 7` means `Cmaj7`. Burmese text is left alone apart
  /// from case and spacing, which is all that is safe to do to it.
  static String normalise(String input) {
    final buffer = StringBuffer();
    for (final rune in input.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      switch (char) {
        case '♯':
          buffer.write('#');
        case '♭':
          buffer.write('b');
        case '°':
          buffer.write('dim');
        // The query is lower-cased before this loop, so a typed capital
        // delta arrives here already folded.
        case 'δ':
          buffer.write('maj');
        case ' ':
        case '\t':
        case ' ':
        case '-':
        case '_':
          break;
        default:
          buffer.write(char);
      }
    }
    return buffer.toString();
  }
}
