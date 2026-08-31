/// The ad-serving seam.
///
/// Mirrors `AudioInput`/`PitchDetector` (docs/adr/0012): a Flutter-free
/// interface behind which exactly one `platform/` file will eventually
/// import a real ad SDK, so nothing above it depends on a specific
/// implementation and every outcome can be exercised in a test without a
/// device.
///
/// **No platform implementation exists yet.** See docs/adr/0018 for why:
/// native project configuration (an AdMob app id in the Android manifest and
/// iOS Info.plist) has to exist before any ad SDK may even initialize, and
/// that cannot be verified without a device build — the same reasoning
/// docs/DEVICE-TESTING.md already applies to the tuner and metronome.
/// [UnavailableAdProvider] is the only implementation, and it is the
/// interface's honest default (CLAUDE.md §47), not a placeholder for
/// something claimed to work.
///
/// Contains no Flutter.
library;

/// The outcome of asking an ad network to load an ad.
///
/// Four states rather than a boolean, mirroring `MicrophoneAccess`'s
/// reasoning: a caller needs to tell "nothing to show right now" apart from
/// "something is actually broken."
enum AdLoadResult {
  /// An ad is ready to show.
  loaded,

  /// The network had nothing to serve this request. Not an error.
  noFill,

  /// The request could not reach the network at all.
  networkError,

  /// Asked for before the provider was ready to serve anything.
  notReady,
}

/// The outcome of asking to show an already-loaded ad.
enum AdShowResult {
  /// The ad was displayed.
  shown,

  /// The player dismissed it.
  dismissed,

  /// The SDK refused or failed to display it.
  failedToShow,

  /// Nothing had been loaded to show.
  notLoaded,
}

/// The outcome of offering a rewarded ad.
enum RewardedOutcome {
  /// The player watched it to completion and should receive the reward.
  earned,

  /// The player left before completion. No reward.
  skipped,

  /// The ad could not be shown at all.
  failedToShow,
}

/// An opaque handle to a loaded banner, so this seam never has to name a
/// Flutter `Widget` type. The presentation layer turns it into one.
// A one-purpose interface is exactly what a replaceable, disposable resource
// handle looks like — a top-level function could not be implemented
// differently per platform.
// ignore: one_member_abstracts
abstract interface class BannerAdHandle {
  /// Releases whatever platform resource backs this banner.
  void dispose();
}

/// Loads and shows ads. Never called directly by a feature widget — every
/// call site should go through the consent and entitlement seams first (an
/// entitled Premium player should never reach this at all, once
/// `EntitlementProvider` is real).
abstract interface class AdProvider {
  /// Loads a banner for [unitId].
  Future<AdLoadResult> loadBanner(String unitId);

  /// The banner handle, once [loadBanner] has completed with
  /// [AdLoadResult.loaded]. Null otherwise.
  BannerAdHandle? get banner;

  /// Loads a native ad for [unitId].
  Future<AdLoadResult> loadNative(String unitId);

  /// Loads a rewarded ad for [unitId].
  Future<AdLoadResult> loadRewarded(String unitId);

  /// Shows the rewarded ad most recently loaded by [loadRewarded].
  Future<RewardedOutcome> showRewarded();

  /// Releases every ad this provider is holding.
  Future<void> dispose();
}

/// The ad provider for when no ad SDK is wired up.
///
/// Follows `UnavailableAudioInput` and `UnavailableChordAudioPlayer`: it
/// admits it cannot do the job rather than pretending (CLAUDE.md §47), and
/// it is what every provider hands out until a real implementation exists.
final class UnavailableAdProvider implements AdProvider {
  /// Creates the unavailable provider.
  const UnavailableAdProvider();

  @override
  BannerAdHandle? get banner => null;

  @override
  Future<AdLoadResult> loadBanner(String unitId) async => AdLoadResult.notReady;

  @override
  Future<AdLoadResult> loadNative(String unitId) async => AdLoadResult.notReady;

  @override
  Future<AdLoadResult> loadRewarded(String unitId) async =>
      AdLoadResult.notReady;

  @override
  Future<RewardedOutcome> showRewarded() async => RewardedOutcome.failedToShow;

  @override
  Future<void> dispose() async {}
}
