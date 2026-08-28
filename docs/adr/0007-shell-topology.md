# 0007 — One shell, five branches, and where detail screens live

**Date:** 2026-08-28 · **Status:** Accepted

## Context

PRD.md §7 and DESIGN.md §19 both name five primary sections: Home, Tools,
Learn, Songs, Profile. Neither says anything about the screens below them —
the tuner, the metronome, a practice session, settings. `docs/ARCHITECTURE.md`
is silent on routing entirely, and no ADR covered it, so the shape of the
shell was the largest genuinely open decision in this phase.

Two questions had to be answered: whether each section keeps its own
navigation stack, and whether a detail screen sits inside a section or above
the whole shell.

## Decision

`StatefulShellRoute.indexedStack` with five branches, each holding its own
navigator so a section's stack survives switching away and back.

A screen belongs **inside a branch** when a player looking at it can answer
"which of the five sections am I in?". Otherwise it pushes on the **root
navigator**.

```
/                    Home
/tools               Tools
  /tools/tuner  /tools/metronome  /tools/chords  /tools/scales
/learn               Learn
  /learn/practice
/songs               Songs
/profile             Profile

/settings            above the shell
/foundation          above the shell, developer builds only
```

## Why

The design system already answered most of this and we nearly missed it.
`ui_kits/mobile_app/index.html` carries a `TAB_FOR` map assigning every detail
screen to an owning tab — practice to Learn, the tuner to Tools even though
Home links to it — and renders the bar on all thirteen screens. Following it
also means a deep link to `/tools/tuner` restores the right tab for free,
because go_router matches the branch by path.

Settings is the case that forced the exception. Its entry point is the top-bar
gear, which appears on all five sections. Nested under Profile, tapping it from
the tuner would silently switch the player to the Profile tab and leave them
there when they pressed back. No section owns it, so it sits above the shell.

Practice is reached from both Home and Learn. It is assigned to Learn rather
than duplicated, matching the design system, and entering it from Home moves
the selected tab to Learn — which is honest about where the player now is.

## Where the chrome goes

The wordmark bar belongs to the five sections and to `/settings`. Everything
else is full screen.

| Surface | Top bar | Bottom bar |
| --- | --- | --- |
| The five section roots | yes | yes |
| `/settings` | yes, with a back control | no |
| A screen inside a branch (tools, practice) | no | yes |
| `/foundation` | no | no |

A screen inside a branch keeps the bottom bar, so its section is one tap away
and tapping the active tab returns to that section's root. It therefore needs
no back control of its own, and repeating the wordmark above a screen that
already sets its own name as an H1 says nothing.

This also removed a real defect: those screens previously rendered the shell's
bar *and* their own, stacked.

## Consequences

- **Every key and route is constructed inside `createRouter()`.**
  `StatefulShellRoute` holds a private `GlobalKey`, so a hoisted route tree
  makes two live routers collide. It fails only in tests, never in the app,
  which makes it a trap worth stating.
- **The router is built once and never rebuilt.** Recreating it would recreate
  the branch navigator keys and discard every section's stack. When entitlement
  gating arrives it must use `refreshListenable`, not a provider that rebuilds
  the router.
- **Android back needed explicit handling.** go_router pops within a branch but
  exits the app from any branch root; a `PopScope` returns to Home first.
- A shell test is really a router test — `StatefulNavigationShell` can only be
  produced by a router, so it cannot be pumped alone.

## Rejected

**Every detail screen above the shell.** Consistent and simple, but it hides
the bar on screens the design system draws it on, and it throws away the tab
context a deep link would otherwise restore.

**Every detail screen inside a branch.** Would have forced settings under some
arbitrary section and broken its back stack.
