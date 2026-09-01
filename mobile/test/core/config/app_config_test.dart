import 'package:flutter_test/flutter_test.dart';
import 'package:l_key/core/config/app_config.dart';

void main() {
  group('AppConfig.fromEnvironment', () {
    test("AdMob fields default to Google's published test identifiers", () {
      // No --dart-define for any ADMOB_* value is set for this test run, so
      // these come from AppConfig's own defaults — which must never be a
      // real, production ad unit id (docs/adr/0018).
      final config = AppConfig.fromEnvironment();
      expect(
        config.admobAppIdAndroid,
        'ca-app-pub-3940256099942544~3347511713',
      );
      expect(config.admobAppIdIos, 'ca-app-pub-3940256099942544~1458002511');
      expect(
        config.admobBannerUnitId,
        'ca-app-pub-3940256099942544/6300978111',
      );
      expect(
        config.admobNativeUnitId,
        'ca-app-pub-3940256099942544/2247696110',
      );
      expect(
        config.admobRewardedUnitId,
        'ca-app-pub-3940256099942544/5224354917',
      );
    });
  });
}
