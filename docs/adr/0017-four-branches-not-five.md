# 0017 — Four branches, not five

**Date:** 2026-09-01 · **Status:** Accepted

## Context

Learn and Practice are cut from the product (see the conflict table this
change was flagged against — PRD.md §2, §7, §5.1–5.4, §24–26, §29–30, §53, §65
and CLAUDE.md §54 all describe them as required scope, and none of those
documents are edited by this decision). Both features were two-file
presentation-only stubs: mock course/session data, no persistence, no real
behaviour behind either screen.

ADR-0007 fixed the shell at five branches — Home, Tools, Learn, Songs,
Profile — with Practice nested under Learn. Removing Learn removes Practice
with it, since Practice had no independent section of its own.

## Decision

The shell drops to four branches: **Home, Tools, Songs, Profile**, in that
order. `AppRoutes.learn`/`learnName`/`practice`/`practiceName` are deleted.
Home's "Continue Practice" card, which deep-linked to `/learn/practice`, is
removed rather than repointed — it has nowhere left to send the player.

## Why

A tab with nothing behind it is the interface faking functionality (CLAUDE.md
§47) — keeping Learn as an empty placeholder would be worse than removing it.
ADR-0007's own reachability rule (a screen sits inside the branch a player
would name if asked "which section am I in?") no longer has an answer for
Practice once Learn is gone, so it cannot simply move under Home instead.

## Consequences

- `AppShell`'s `_branchRoots` set and inline `destinations` list, and
  `app_router.dart`'s branch list, are index-aligned by construction
  (`navigationShell.goBranch(index)` is purely positional). All three were
  edited together; a future change to branch order must keep them in lockstep.
- `PopScope.canPop`'s `navigationShell.currentIndex == 0` is unaffected — Home
  stays index 0.
- Fifteen localisation keys (12 `learn*`/`practice*` keys, `navLearn`, and two
  keys — `homeDailySession`, `commonResume` — that were only reachable through
  the now-deleted Home card) are removed from both `app_en.arb` and
  `app_my.arb`, keeping ADR-0006 parity.
- Two further Profile-screen localisation keys (`practiceStatStreak`,
  `practiceStreakDays`, and `profileStatPractice`) were caught by `flutter
  analyze` after the arb edit — Profile displayed a hardcoded "practice
  streak" and "practice hours" stat pair with no feature behind either number.
  Both were removed along with their stat chips, leaving Profile's stat row
  as a single real figure (saved songs).

## Rejected

**Keeping Learn as an empty placeholder tab.** Rejected per CLAUDE.md §47 — a
tab with nothing behind it fakes functionality rather than honestly reflecting
scope.

**Keeping Practice reachable only from Home, above the shell.** Rejected —
this creates a route reachable from exactly one place with no section
claiming it, which breaks ADR-0007's own reachability rule rather than
resolving it.
