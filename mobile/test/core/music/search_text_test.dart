import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/music/search_text.dart';

void main() {
  group('SearchText.normalise', () {
    test('folds the two ways an accidental is written into one', () {
      expect(SearchText.normalise('C♯'), SearchText.normalise('C#'));
      expect(SearchText.normalise('B♭'), SearchText.normalise('Bb'));
    });

    test('ignores case, spacing and separators', () {
      expect(SearchText.normalise('c maj 7'), 'cmaj7');
      expect(SearchText.normalise('C-Maj_7'), 'cmaj7');
    });

    test('leaves Myanmar text intact apart from spacing', () {
      expect(SearchText.normalise('ဂစ်တာ ချုံ'), 'ဂစ်တာချုံ');
    });
  });
}
