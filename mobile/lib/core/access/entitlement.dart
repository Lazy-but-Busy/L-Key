/// Whether the player is currently entitled to a [FeatureTier].
///
/// This is the single call site a widget should use instead of a scattered
/// `bool isPremium` field (CLAUDE.md §23) — exactly the pattern the deleted
/// `practice_page.dart`/`learn_page.dart` got wrong, checking their own local
/// mock flag directly.
///
/// **[UnavailableEntitlementProvider] always answers `notEntitled` for
/// Premium today.** Real entitlement is server-authoritative (CLAUDE.md §23,
/// §51) and the backend does not exist yet (Phase 09/11) — this is the
/// explicit, honest stub CLAUDE.md §47 requires rather than a fake "yes".
/// When a real client exists it is overridden at the root and no call site
/// changes, the same seam `chordAudioPlayerProvider`/`appConfigProvider` use.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/core/access/feature_tier.dart';

/// What is currently known about entitlement to a tier.
enum EntitlementStatus {
  /// The player may use this capability.
  entitled,

  /// The player may not use this capability.
  notEntitled,

  /// Not yet known — the server hasn't answered, or hasn't been asked.
  unknown,
}

/// Answers whether the player is entitled to a [FeatureTier].
///
// A one-method interface is exactly what this seam is for: it is the place a
// server-backed client replaces the honest default, and a top-level function
// cannot be overridden in a provider or faked in a test.
// ignore: one_member_abstracts
abstract interface class EntitlementProvider {
  /// The current entitlement status for [tier].
  EntitlementStatus statusFor(FeatureTier tier);
}

/// The honest default: nothing is entitled because nothing has asked the
/// server yet. Free content is always entitled — it never needed asking.
final class UnavailableEntitlementProvider implements EntitlementProvider {
  /// Creates the unavailable provider.
  const UnavailableEntitlementProvider();

  @override
  EntitlementStatus statusFor(FeatureTier tier) => switch (tier) {
    FeatureTier.free => EntitlementStatus.entitled,
    FeatureTier.premium => EntitlementStatus.notEntitled,
  };
}

/// Provides the app's [EntitlementProvider].
///
/// Overridden at the root once a real, server-backed client exists — no
/// screen that reads [entitlementProviderProvider] needs to change when it
/// is.
final entitlementProviderProvider = Provider<EntitlementProvider>(
  (ref) => const UnavailableEntitlementProvider(),
);
