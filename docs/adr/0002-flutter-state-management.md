# 0002 — Riverpod for Flutter state

**Date:** 2026-08-28 · **Status:** Accepted

## Context

`CLAUDE.md` §9 requires one consistent state-management approach and forbids
mixing frameworks without an explicit architectural reason — but never names
one. §10 separately requires music logic to be testable without Flutter
widgets. This is among the hardest decisions to reverse later.

## Decision

Riverpod (`flutter_riverpod ^3.0.0`) throughout.

## Why

- **Providers test without a widget tree.** A `ProviderContainer` exercises
  state directly, which is what keeps §10 honest: the engines stay plain Dart
  and their consumers stay testable.
- **Compile-time safety.** Dependencies are resolved by type rather than by
  runtime lookup, so a missing dependency is a build error.
- **State shape matches the requirement.** §9 asks for loading, success, empty
  and error. `AsyncValue` models three natively; empty is a domain state on
  top, which is the correct place for it — "no favourites yet" is a fact about
  the data, not about the request.

## Rejected

**Bloc/Cubit.** Explicit event→state transitions would suit the payment state
machine (§25) well. Rejected because the ceremony is disproportionate for the
many simple tool screens — a metronome does not need an event class per tap —
and mixing Bloc for payments with something lighter elsewhere would violate §9.

**Provider + ChangeNotifier.** Lightest, but `ChangeNotifier` is mutable
state, which sits badly with §9's warning against deeply nested mutable state,
and it offers the weakest compile-time guarantees.

## Consequences

- Every feature exposes its state through providers; widgets read, never own.
- `appConfigProvider` is deliberately unimplemented and overridden at the root,
  so a test that forgets to supply configuration fails loudly.
