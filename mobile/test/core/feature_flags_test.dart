import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/config/environment.dart';
import 'package:l_key/core/config/feature_flags.dart';

void main() {
  group('FeatureFlags', () {
    test('every flag defaults to off', () {
      // CLAUDE.md §48 — experimental work must never reach production by
      // accident, so an unset dart-define is always false.
      FeatureFlags.all.forEach((name, enabled) {
        expect(enabled, isFalse, reason: '$name defaults on');
      });
    });

    test('all six documented flags are present', () {
      expect(
        FeatureFlags.all.keys,
        containsAll(<String>[
          'aiAssistant',
          'chordRecognition',
          'backingTracks',
          'recording',
          'community',
          'ads',
        ]),
      );
    });
  });

  group('Environment', () {
    test('parses known names and falls back to local', () {
      expect(Environment.parse('production'), Environment.production);
      expect(Environment.parse('staging'), Environment.staging);
      expect(Environment.parse('nonsense'), Environment.local);
    });

    test('developer tools are unavailable in production', () {
      expect(Environment.production.allowsDeveloperTools, isFalse);
      expect(Environment.local.allowsDeveloperTools, isTrue);
    });
  });
}
