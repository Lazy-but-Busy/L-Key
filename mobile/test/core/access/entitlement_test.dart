import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/access/entitlement.dart';
import 'package:l_key/core/access/feature_tier.dart';

void main() {
  group('UnavailableEntitlementProvider', () {
    const provider = UnavailableEntitlementProvider();

    test('free content is always entitled', () {
      expect(provider.statusFor(FeatureTier.free), EntitlementStatus.entitled);
    });

    test('premium content is never entitled — no server has answered', () {
      // CLAUDE.md §47 — this is the honest stub, not a fake "yes".
      expect(
        provider.statusFor(FeatureTier.premium),
        EntitlementStatus.notEntitled,
      );
    });
  });
}
