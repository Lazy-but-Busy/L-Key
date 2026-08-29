# 0014 — Every detail screen is a tool, above the shell

**Date:** 2026-08-30 · **Status:** Accepted ·
**Supersedes:** the chrome table in [ADR-0007](0007-shell-topology.md)

## Context

ADR-0007 put every detail screen inside the branch that owns it and kept the
bottom bar on all of them. The reasoning was the design system's own
`TAB_FOR` map, which assigns each screen an owning tab and draws the bar on
all thirteen. A screen inside a branch therefore needed no back control: its
section was one tap away on the bar, and tapping the active tab returned to
that section's root.

In use it did not read that way. The tuner, the metronome, the chord library,
the fretboard and a practice session are things a player *enters* and
*leaves*, and the only way out was a tab that did not look like a way out.
`/settings` — the one screen that already pushed above the shell, with a back
arrow — is what the rest were being compared against, and it won.

## Decision

Every screen below the five section roots pushes on the **root navigator** and
wears `LkDetailScaffold`: its own bar, a back control, no bottom bar.

```
AppShell, with both bars
  /  ·  /tools  ·  /learn  ·  /songs  ·  /profile

Above the shell, back control, no bottom bar
  /tools/tuner         /tools/chords
  /tools/metronome     /tools/chords/analyzer
  /tools/scales        /tools/chords/:chordId
  /tools/fretboard     /learn/practice
  /settings
```

The **paths do not change**. Each route keeps its place in the hierarchy and
gains `parentNavigatorKey: rootNavigatorKey`.

## Why

**The paths stay nested, and that is the whole trick.** go_router still
matches `/tools/chords/c-major` inside the Tools branch, so it builds the
Tools page, then the chord library, then the chord — the first inside the
shell, the other two above it. A cold deep link therefore arrives with a real
stack underneath it: back goes to the chord library, then to Tools with the
bar lit. Hoisting the routes to top-level siblings of the shell, the way
`/settings` is written, would have produced the same screen and thrown that
away, leaving `fallbackRoute` to guess.

This was the one part of the change a compiler cannot check, so it was
verified on `/tools/tuner` alone, against the shell tests, before the other
seven moved.

**`go` became `push` at every call site.** `goNamed` replaces the branch's
stack, which is exactly why there was nothing to pop. Only the two links to
Songs still use `go`, because Songs is a section and going there should move
the tab.

**Entering practice from Home no longer moves the player to Learn.** ADR-0007
accepted that as the price of nesting and called it "honest about where the
player now is". Pushing above the shell removes the choice: Home stays
selected underneath, and back returns there.

**The microphone is released by construction.** `tunerProvider` is
auto-disposing, and a route pushed over the tuner unmounts its subtree, so
leaving the tuner — by back, or by opening something on top of it — tears the
pipeline down. Previously the tuner stayed mounted in the Tools branch and
`TickerMode` was what told the controller to suspend. That path still works
and is still tested; it simply no longer has a case that reaches it, because
a tab switch can no longer happen while the tuner is open (CLAUDE.md §50).

**The back control now says where it is.** `LkDetailScaffold` has always taken
a `title` and documented that it was announced with the back control. It was
not: the label was a bare "Back". With one such screen that was survivable;
with nine it tells a screen-reader user nothing. `commonBackFrom` fixes the
mismatch in the direction the doc comment already claimed.

## Consequences

- **`AppShell` only ever builds a branch root.** Its `_branchRoots` set is
  now always true. It stays, as the explicit statement of the rule: a screen
  added *inside* a branch later would not silently inherit the wordmark.
- **Flutter removes an obscured route's subtree**, so a test asserting
  `find.byType(LkBottomNavBar), findsNothing` on a tool screen is asserting
  something real rather than something merely off-screen.
- **Three shell tests encoded the old contract and were rewritten**, not
  loosened: the one that proved a branch keeps its stack no longer has a
  subject, because no branch has a stack deeper than one page any more.
- **The per-branch navigators do less than they were built for.**
  `StatefulShellRoute.indexedStack` is kept anyway: it is what makes a deep
  link light the right tab, and what keeps each section's scroll position.
- `/tools/chords/analyzer` is declared **before** `/tools/chords/:chordId`,
  which would otherwise swallow it. Every catalogue id is `<root>-<quality>`
  and so contains a hyphen; a test asserts no id could collide, because a
  future one-word slug would break the route silently.

## Rejected

**Top-level sibling routes**, `/tuner` and `/chords` beside `/settings`.
Simpler to read in the router and identical on screen. Rejected because it
discards the stack a deep link would otherwise build, and because two
parallel naming schemes for the same screens is a worse trade than one
`parentNavigatorKey` per route.

**Leaving practice inside the Learn branch.** It is a session rather than a
tool, and an argument can be made. Rejected for consistency: the player asked
for every screen reachable from Home, Tools, Learn and Songs to behave the
same way, and a single exception is harder to remember than no exceptions.

**Removing the bottom bar globally.** It is what the request could have been
read as, and it would have broken the five sections.
