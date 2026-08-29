/// Which tier a piece of content belongs to.
///
/// **This grants nothing and authorizes nothing.** It is a label the UI can
/// show, and no more. CLAUDE.md §23 and §51 put entitlement on the server, so
/// a client-side tier can never be the thing that decides access — a
/// dedicated, server-authoritative entitlement system does that in a later
/// phase.
///
/// It lives in `core/access/` rather than in the music engines because the
/// music domain must stay independent of subscription state (CLAUDE.md §10):
/// a chord's notes do not change with a subscription.
library;

/// The commercial tier a piece of content is labelled with.
enum FeatureTier {
  /// Available to everyone, including guests (PRD.md §44).
  free,

  /// Labelled Premium in the interface (PRD.md §43).
  ///
  /// Nothing in this codebase enforces it yet, and nothing should: enforcement
  /// belongs to the server-authoritative entitlement system.
  premium,
}
