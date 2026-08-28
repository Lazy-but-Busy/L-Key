# 0008 — shared_preferences for settings

**Date:** 2026-08-28 · **Status:** Accepted

## Context

The settings screen offers language, appearance and reference pitch. Choices
that reset on every launch are not settings, so they have to persist — and
nothing in the app persisted anything before this. This is the first
dependency added to `mobile/` since Phase 01, so CLAUDE.md §42's checklist
applies.

Neither PRD.md nor DESIGN.md specifies a settings screen at all, so its
contents and its storage were both unprescribed.

## Decision

`shared_preferences: ^2.3.0`, read once in `main()` before the first frame and
supplied to the tree through an overridden provider.

## Why

Dart and Flutter offer no key-value store of their own, so something had to be
added. `shared_preferences` is maintained by the Flutter team, wraps the
platform stores each OS already provides (`NSUserDefaults`, Android
`SharedPreferences`), supports both our targets, is BSD-3-licensed, and adds
no native code of its own.

Reading it before `runApp` costs a few milliseconds and buys a synchronous
read afterwards, so the app never paints the wrong theme or language and then
corrects itself.

Writes are fire-and-forget. The in-memory state updates immediately so the
interface never waits on disk, and a failed write costs a preference rather
than data.

## Rejected

**A file in the documents directory.** No dependency, but it means writing and
versioning a serialisation format for three values, and handling partial
writes — more code and more failure modes than the thing it stores.

**`flutter_secure_storage`.** Necessary later for auth tokens (CLAUDE.md §22),
wrong here: none of these values are secret, and it is a heavier native
dependency.

**Deferring persistence.** Considered, and rejected because a settings screen
whose settings do not stick is the kind of half-feature CLAUDE.md §47 warns
against.

## Consequences

- `sharedPreferencesProvider` throws unless overridden, so a test that forgets
  to supply a store fails loudly instead of writing to the device. This matches
  the contract `appConfigProvider` already uses.
- An unrecognised stored value — written by a future build, or corrupted —
  falls back to the system default rather than throwing.
- The store is a synchronous snapshot. Anything larger or relational later
  belongs in a real database, not here.
