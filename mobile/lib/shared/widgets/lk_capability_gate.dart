import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l_key/core/access/entitlement.dart';
import 'package:l_key/core/access/feature_tier.dart';

/// The single call site a feature uses to gate on entitlement, instead of a
/// scattered `bool isPremium` check (CLAUDE.md §23).
///
/// Every screen in the app today shows Premium content and lets it open
/// regardless of tier — [FeatureTier] is a label, not a lock, and
/// entitlement enforcement is server-authoritative work Phase 09/11 has not
/// landed yet (CLAUDE.md §51). This widget is the seam a screen switches to
/// once that exists: build against it and only [entitlementProviderProvider]
/// needs to change, not every call site.
class LkCapabilityGate extends ConsumerWidget {
  /// Creates a capability gate for [tier].
  const LkCapabilityGate({
    required this.tier,
    required this.entitled,
    required this.locked,
    super.key,
  });

  /// The capability being gated.
  final FeatureTier tier;

  /// Built when the player may use the capability, or its status is still
  /// [EntitlementStatus.unknown] — an unknown status never blocks a player
  /// who may turn out to be entitled.
  final WidgetBuilder entitled;

  /// Built when the player is confirmed [EntitlementStatus.notEntitled].
  final WidgetBuilder locked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(entitlementProviderProvider).statusFor(tier);
    return status == EntitlementStatus.notEntitled
        ? locked(context)
        : entitled(context);
  }
}
