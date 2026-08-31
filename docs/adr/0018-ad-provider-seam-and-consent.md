# 0018 — The ad provider is a seam, and no plugin sits behind it yet

**Date:** 2026-09-01 · **Status:** Accepted

## Context

Monetization needs a third-party ad SDK (AdMob) and a consent flow ahead of
it, but PRD.md says nothing about ads today, and neither the backend
entitlement API nor the admin ad-config CMS this would eventually connect to
exist yet (Phase 09/10 — see README.md's Development Status). Building
against a real ad SDK now also means native project configuration — an AdMob
application id in `AndroidManifest.xml` and `Info.plist`, without which the
SDK crashes or silently no-ops depending on platform — that cannot be
verified without a device build, the same constraint `docs/DEVICE-TESTING.md`
already documents for the tuner and metronome.

## Decision

`core/ads/` mirrors `core/audio/`'s seam exactly (ADR-0012):

- **`ad_provider.dart`** — `AdProvider`, a Flutter-free interface for
  loading/showing banner, native and rewarded ads. Outcomes are explicit
  enums (`AdLoadResult`, `AdShowResult`, `RewardedOutcome`), not booleans,
  mirroring `MicrophoneAccess`'s reasoning: a caller needs "no fill" told
  apart from "broken." A banner is handed back as an opaque
  `BannerAdHandle`, never a `Widget`, so the interface itself stays as
  Flutter-free as `AudioInput`.
- **`consent_status.dart`** — `ConsentManager`, resolving `ConsentStatus`
  before any ad SDK may initialize. `ConsentStatus.unknown` is the only safe
  starting state.
- **`UnavailableAdProvider`/`UnavailableConsentManager`** — the only
  implementations that exist today, mirroring `UnavailableAudioInput`: they
  admit they cannot do the job (CLAUDE.md §47) rather than returning a fake
  success, and they are what every provider hands out.
- **No `platform/` file exists yet.** The `google_mobile_ads` package is not
  added to `pubspec.yaml`. Running the CLAUDE.md §42 checklist against it now
  (Flutter provides no ad-serving API; Google-maintained and mature; iOS and
  Android supported; actively maintained; BSD/proprietary-SDK-terms hybrid —
  verify the exact current license before adding; moderate size impact,
  acceptable given monetization is a stated product direction; no first-party
  alternative) concludes it should be added — but adding it without also
  doing the native manifest configuration it requires would ship a
  dependency nothing correctly initializes, and that configuration cannot be
  verified without a device build. The dependency, the platform wrapper, and
  the native manifest entries are one unit of future work, not three
  separable steps.
- **Capability gate, separately.** `core/access/entitlement.dart` adds
  `EntitlementProvider`/`EntitlementStatus`, extending `FeatureTier` rather
  than duplicating it. `UnavailableEntitlementProvider` always answers
  `notEntitled` for Premium — server entitlement doesn't exist (CLAUDE.md
  §23, §51). `LkCapabilityGate` in `shared/widgets/` is the single call site
  a feature should use instead of a scattered `bool isPremium` field, which
  is exactly what the deleted `practice_page.dart`/`learn_page.dart` did
  wrong (ADR-0017).
- **Config plumbing (ADR-0005 pattern).** `FeatureFlags.ads`
  (`ENABLE_ADS`), and `AppConfig` gains `admobAppIdAndroid`, `admobAppIdIos`,
  `admobBannerUnitId`, `admobNativeUnitId`, `admobRewardedUnitId`, all read
  via `String.fromEnvironment` and defaulting to Google's own published test
  identifiers — safe to commit, never real inventory.
  `mobile/config/local.json` carries the same test ids; `production.json`
  must carry real ones and must never be committed with them, the same rule
  `API_BASE_URL` already follows.

## Why

**A seam that admits what's missing is worth more than a plugin that can't
be verified.** CLAUDE.md §47 forbids faking payment success, tuner accuracy,
or entitlement — the same principle applies to claiming an ad SDK works when
nothing here can confirm it does. Building the seam now means every future
step (adding the dependency, writing the platform wrapper, wiring native
config, connecting real entitlement) changes exactly one file each, and nothing
above the seam has to be rewritten when they land.

**Consent before initialization is a hard rule, not a preference.** An ad
SDK that initializes before consent is resolved has already made the request
consent was supposed to gate. Modeling `ConsentStatus` as its own seam, with
`unknown` as the default, makes skipping that ordering a type error rather
than a code-review catch.

## Consequences

- **`EntitlementProvider` always says `notEntitled` for Premium, so once a
  real `AdProvider` exists, ads would show to every player — including a
  future Premium subscriber — until Phase 09/11 wires real entitlement.**
  This is a known gap, not a silent one: nothing in this codebase may call a
  real `AdProvider` in a shipped build until that entitlement wiring exists,
  and this ADR is where that constraint is written down.
- The next concrete step is one unit of work: add `google_mobile_ads` to
  `pubspec.yaml`, write `platform/google_mobile_ads_provider.dart` and
  `platform/ump_consent_manager.dart` against its real API, add the AdMob
  application id to `AndroidManifest.xml` and `Info.plist`, and run
  `docs/DEVICE-TESTING.md`-style verification before switching
  `adProviderProvider`/`consentManagerProvider` away from the `Unavailable*`
  defaults.
- PRD.md gains a monetization section (banner/native/rewarded placements,
  `remove_ads`, the analytics metrics a future backend will report) so this
  scope exists in the product document, not only in code — it did not exist
  there before this ADR.

## Rejected

**Calling `google_mobile_ads` directly from presentation code, skipping the
seam.** Untestable without a device, and it would make the plugin
irreplaceable — the same reasoning ADR-0012 already rejected for the tuner.

**Putting ad-eligibility behind `FeatureTier` directly**, e.g.
`FeatureTier.premium` meaning "ads hidden." Rejected — `FeatureTier` is a
commercial label attached in a data layer (docs/ARCHITECTURE.md); conflating
it with a runtime capability decision is the same mistake `TieredEntry`
exists to avoid elsewhere.

**Adding the `google_mobile_ads` dependency now, without the platform
wrapper or native config.** Rejected — a dependency nothing correctly
initializes is dead weight at best and a crash at ad-request time at worst,
and CLAUDE.md §42's checklist is meant to precede real use, not sit ahead of
an indefinite gap.
