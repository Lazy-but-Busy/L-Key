import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/ads/consent_status.dart';

void main() {
  group('UnavailableConsentManager', () {
    const manager = UnavailableConsentManager();

    test('answers unknown rather than assuming consent is not required', () {
      // CLAUDE.md §47 — the safe default is "ask", not "skip".
      expect(
        manager.requestConsentInfoUpdate(),
        completion(ConsentStatus.unknown),
      );
    });

    test('showing the form still answers unknown with no real SDK', () {
      expect(
        manager.showConsentFormIfRequired(),
        completion(ConsentStatus.unknown),
      );
    });
  });
}
