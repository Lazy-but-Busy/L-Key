# `metronome` feature

Tempo, tap tempo, time signatures, subdivisions, accents, count-in and
selectable click voices. **Audio timing must not drift; scheduling belongs in
the domain layer, not a widget timer** — and it does.

**Specification:** PRD.md §16–18 · DESIGN.md §27 · docs/adr/0016

## Structure

```
metronome/
├── data/
│   ├── metronome_catalog.dart        tier labels, which authorize nothing
│   └── metronome_settings_store.dart shared_preferences, validated on read
├── domain/                           no Flutter, no clock, no tier
│   ├── time_signature.dart           meters, subdivisions, accent levels
│   ├── metronome_settings.dart       what is being played, always in range
│   ├── metronome_thresholds.dart     every number the behaviour turns on
│   ├── tap_tempo.dart                pure, over injected timestamps
│   ├── click_sound.dart              the four voices and their parameters
│   ├── click_synth.dart              voice → samples, rendered once
│   ├── click_schedule.dart           pulse → exact sample offset
│   ├── click_track_renderer.dart     schedule + synth → a block of PCM
│   ├── metronome_state.dart          what the screen renders from
│   └── metronome_transport.dart      owns the speaker and the playhead
└── presentation/
    ├── metronome_controller.dart     providers, lifecycle, the stopwatch
    ├── metronome_page.dart
    └── widgets/metronome_beat_indicator.dart
```

The chain, which is `CLAUDE.md §14`'s applied backwards:

```text
Settings → ClickSchedule → ClickSynth → ClickTrackRenderer
        → AudioOutput → playhead → MetronomeState → Flutter UI
```

## How it keeps time

**The sample index is the clock.** Nothing schedules a beat. The renderer is
asked for the audio covering a half-open sample range and computes which clicks
fall inside it; the device pulls those samples at its own rate. The nth pulse is
computed from `n`, never added to the last, which is what makes it exact
forever rather than 54 ms late after ten minutes.

**The picture follows the sound.** A beat reaches the screen only once the
device reports it has played the samples that beat sits in, so the indicator
can lag the click by one block and can never lead it.

**A change waits for a boundary.** Tempo adopts at the next pulse; meter and
subdivision at the next bar. Audio already handed to the device is never
rewritten.

## What the tempo counts

The note value in the signature's denominator, so 120 is 120 clicks in every
meter. The grouping lives in the accents instead: 6/8 accents in threes, 5/4 as
3+2, 7/8 as 2+2+3. docs/adr/0016 records why, and what the alternative was.

## Not here

- **Rhythm Trainer (PRD.md §17) and Strumming Trainer (§18)** — Phase 06.1.
  Both need practice-session persistence to score against. A strumming pattern
  is a per-pulse list of `AccentLevel`, which is why `AccentLevel.silent` and
  the accent editor exist already.
- **Practice sessions** — Phase 08. The practice screen reads this feature's
  tempo and can start it; it records nothing.
- **Entitlement** — Phase 11. Meters, subdivisions and voices carry tier
  labels and every one of them plays (CLAUDE.md §23, §51).

## Verified, and not

`flutter test` proves the arithmetic against synthetic buffers: no drift over
100 000 pulses, chunk-invariant rendering, exact accent placement in every
meter. **It proves nothing about a speaker.** docs/DEVICE-TESTING.md Part B is
the procedure, it has not been run, and until it has, no timing-accuracy claim
belongs anywhere (CLAUDE.md §47).
