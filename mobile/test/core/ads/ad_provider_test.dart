import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/ads/ad_provider.dart';

void main() {
  group('UnavailableAdProvider', () {
    const provider = UnavailableAdProvider();

    test('every load request answers notReady, never a fake success', () {
      // CLAUDE.md §47 — no ad SDK is wired up yet, so nothing here may claim
      // an ad is ready.
      expect(provider.loadBanner('unit'), completion(AdLoadResult.notReady));
      expect(provider.loadNative('unit'), completion(AdLoadResult.notReady));
      expect(provider.loadRewarded('unit'), completion(AdLoadResult.notReady));
    });

    test('there is never a banner handle to hand back', () {
      expect(provider.banner, isNull);
    });

    test('showing a rewarded ad always fails to show', () {
      expect(
        provider.showRewarded(),
        completion(RewardedOutcome.failedToShow),
      );
    });

    test('dispose completes without needing anything to release', () {
      expect(provider.dispose(), completes);
    });
  });
}
