/// The ad-consent seam.
///
/// Consent must be resolved **before** any ad SDK initializes — showing an
/// ad, even a house ad, before knowing whether the player needs to be asked
/// is the ordering mistake this seam exists to make impossible to skip.
/// [ConsentStatus.unknown] is the only safe starting state; nothing may treat
/// it as "not required."
///
/// No platform implementation exists yet — see docs/adr/0018, the same
/// reasoning `ad_provider.dart` documents for the ad SDK itself.
///
/// Contains no Flutter.
library;

/// What is currently known about a player's ad-personalisation consent.
enum ConsentStatus {
  /// Not yet determined. Treat exactly like [required] until resolved.
  unknown,

  /// The player must be asked before any personalised ad request.
  required,

  /// No consent flow applies — a jurisdiction where none is required.
  notRequired,

  /// The player was asked and agreed.
  obtained,

  /// The player was asked and declined.
  denied,
}

/// Resolves whether, and how, to ask the player for ad consent.
abstract interface class ConsentManager {
  /// Fetches the current consent requirement from the consent platform.
  Future<ConsentStatus> requestConsentInfoUpdate();

  /// Shows the consent form if [requestConsentInfoUpdate] said one is
  /// needed, and returns the status afterwards.
  Future<ConsentStatus> showConsentFormIfRequired();
}

/// The consent manager for when no consent SDK is wired up.
///
/// Answers [ConsentStatus.unknown] rather than [ConsentStatus.notRequired] —
/// the safe default is to assume consent is needed until a real platform
/// says otherwise (CLAUDE.md §47), never to assume it away.
final class UnavailableConsentManager implements ConsentManager {
  /// Creates the unavailable manager.
  const UnavailableConsentManager();

  @override
  Future<ConsentStatus> requestConsentInfoUpdate() async =>
      ConsentStatus.unknown;

  @override
  Future<ConsentStatus> showConsentFormIfRequired() async =>
      ConsentStatus.unknown;
}
