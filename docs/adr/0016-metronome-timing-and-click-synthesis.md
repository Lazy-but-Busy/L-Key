# 0016 — The metronome's clock is the sample counter, and the click is ours

**Date:** 2026-08-31 · **Status:** Accepted

## Context

Phase 06 had to make the metronome keep time. Phase 02 had drawn the screen and
left it saying so — "Audio timing arrives with the audio phase" — because a
metronome that looked like it was running without keeping time is exactly the
faked functionality `CLAUDE.md §47` forbids.

The hard part is not the arithmetic. It is that the only clock in a phone that
keeps musical time is the one clocking the digital-to-analogue converter, and
every clock a UI framework offers is locked to the display instead. Flutter's
frame callback is a ±16 ms sawtooth tied to the refresh rate, and it stops
entirely when the app is backgrounded — which is precisely when a practising
guitarist wants the click to carry on.

`core/audio/` also had nothing that could make a sound. Everything in it —
`record`, the hand-written FFT, the McLeod detector — points inward from the
microphone. `ChordAudioPlayer` was a seam whose only implementation admits it
cannot play.

## Decision

- **`core/audio/audio_output.dart` is the playback seam**, mirroring
  `audio_input.dart` role for role, with `UnavailableAudioOutput` as the
  default the providers hand out.
- **It is pull-driven.** The platform asks for the next block when its own
  buffer runs low; nothing above the seam decides *when* audio is consumed.
- **`flutter_pcm_sound` is the implementation**, behind
  `platform/pcm_sound_audio_output.dart`, the only file that imports it.
- **A beat is an integer sample offset, computed from its index.** For pulse
  `n`, with `d = bpm × pulsesPerBeat`:

  ```text
  sample(n) = origin + (n × 60 × rate + d ÷ 2) ÷ d
  ```

  Integer arithmetic throughout, rounded half up, never accumulated.
- **`ClickSchedule` keeps two origins.** A timing origin, which moves wherever
  the player nudged the tempo, and a bar origin, which moves only when the
  meter does.
- **The clicks are synthesised**, four sounds across four accent levels, from a
  band-passed noise burst and a sine body under one envelope. `Biquad` gained a
  band-pass for it.
- **The played-frame count drives the picture.** A beat reaches the screen only
  once the device reports it has played the samples that beat sits in.
- **Changes are staged and adopted at a boundary**: tempo at the next pulse,
  meter and subdivision at the next bar.
- **The tempo counts the note value in the signature's denominator**, so 120 is
  120 clicks in every meter, and the grouping is carried by the accents.
- **`TapTempo` takes its timestamps as arguments.** The stopwatch lives in the
  controller.
- **The metronome plays in the background on both platforms**: iOS on
  `UIBackgroundModes: audio` plus the playback session category, Android on a
  foreground service behind `core/audio/background_audio_service.dart`.
- **`metronomeProvider` is app-scoped, not auto-disposing.**

## Why

**Computing from the index is the whole design.** At 240 BPM in sixteenths at
44.1 kHz a pulse is 2756.25 samples. Rounding that period to 2756 and adding it
up loses a quarter of a sample every pulse — 2 400 samples, **54 milliseconds
over ten minutes**, which is audibly behind a drummer by the end of a song.
Computing the nth offset from the origin is wrong by at most half a sample,
forever, and it is self-correcting *inside* a beat: at 120 BPM the sixteenths
land on 0, 5513, 11025, 16538 and the beat itself on exactly 22050. A metronome
whose subdivisions walked its own downbeat off the grid would be worse than one
with no subdivisions at all.

**Two origins, because they answer different questions.** The first version had
one, and a tempo nudge mid-bar re-anchored the counting as well as the timing —
putting a downbeat on beat three of the next bar. The timing origin follows the
player's thumb; the bar origin follows the meter. There is a test for it, named
after the bug.

**The picture follows the sound, never the other way round.** Audio is rendered
up to about 70 ms ahead of the playhead. If the indicator advanced when a block
was *rendered*, it would lead the click by that much, which reads as the app
being out of time with itself. Publishing on frames the device says it has
consumed costs at most one block of lag — about 12 ms — and cannot ever lead.
That is why the block is 512 frames and not 4096: the block length is also the
visual quantisation.

**Synthesis over recordings.** Four sounds across four levels is sixteen
files, a decoder, an asset budget and a resampling path to reason about. Each
of these is a handful of numbers that renders to the same samples on every
device — which is also what lets a test assert a waveform rather than trust
one, the same trade ADR-0012 made when it hand-wrote the FFT. The voices are
rendered once when the sound changes, so the callback that must not miss its
deadline only copies.

**The mean for tap tempo, where the tuner takes a median.** This looks like an
inconsistency and is not. The tuner medians because it has no way to identify
which reading is the wrong one. Here the outlier is identified first — an
interval more than 1.5× or less than 0.67× the running median is a double tap
or a missed tap — so averaging what survives uses all the remaining evidence
instead of discarding four fifths of it. The reset gap is derived rather than
chosen: one beat at 30 BPM is two seconds, and a gap longer than the slowest
beat the product offers cannot be part of a tempo.

**The denominator, not the dotted quarter.** Counting 6/8 in dotted quarters is
how a conductor reads it, and several metronomes do it. Counting the
denominator means "the number on the screen is the number of clicks you hear"
holds in every meter with no exception to learn, and the grouping is not lost —
it moves to `defaultAccents`, which is where a listener actually hears it. A
metronome that clicks seven even beats in 7/8 is not counting 7/8; the accents
are what make it 2+2+3.

**Background play, and why it does not contradict §50.** `mobile/CLAUDE.md §50`
wants audio stopped when the tool closes, the app backgrounds, or the player
stops. Its *purpose* is battery and surprise: audio nobody asked for. A click
the player pressed start on, while practising with the phone face down, is
audio they asked for. The rule the metronome follows instead: it stops on an
explicit stop, on interruption and on dispose; it keeps playing when the screen
is left or the app is backgrounded; and nothing ever starts it implicitly. What
makes that honest is the Android notification — always visible, always
stoppable from the shade — and on iOS the system's own now-playing indication.
An idle metronome holds no audio device at all, which is the battery cost §50 is
actually about.

**A synchronous state stream, unlike the tuner's.** A tuner's state arrives
from a microphone and nobody is waiting on a particular frame. A transport
button is pressed by a finger, and it must not sit on STOP after the player has
already pressed it. A stop therefore publishes before releasing the speaker,
not after: stopping cannot meaningfully fail.

**±1 on the stepper, not the ±4 the Phase 02 layout drew.** Four cannot land on
92, and a metronome that cannot be set to 92 is not a metronome.

## The numbers, and how far to trust them

| Value | Setting | Confidence |
| --- | --- | --- |
| `blockFrames` | 512 (11.6 ms) | **Low** — the most likely constant to be wrong on a cheap Android |
| `feedThresholdFrames` | 1536 | Low |
| `targetBufferFrames` | 3072 (70 ms) | Low |
| `tapWindow` | 5 intervals | Medium |
| `tapResetGap` | 2500 ms | **High** — derived from the 30 BPM floor |
| `tapOutlierFactor` | 1.5 | Medium |
| `dropoutsBeforeWarning` | 3 in 10 s | Low |
| click `decayMs` | 8–55 by voice | Medium — a matter of feel |
| BPM range | 30–240 | Medium |

`docs/DEVICE-TESTING.md` Part B is the procedure that confirms or replaces the
low-confidence ones, and `metronome_thresholds.dart` exists as one object so
that changing them afterwards is a small diff.

## Rejected

**A `Ticker` or `Timer.periodic` scheduling the beats.** The obvious approach,
and the one the feature README warned against from Phase 02. Rejected because
the two clocks are unrelated: the display's refresh does not divide the audio
device's sample rate, so every beat would be quantised to a frame boundary and
the error would be a sawtooth rather than a constant. It also stops dead when
the app is backgrounded.

**Accumulating the period.** Simpler, and wrong by 54 ms in ten minutes at the
fastest supported subdivision. See above.

**`flutter_soloud`.** Far more popular, MIT, actively maintained, with
`playScheduled` on its own audio thread — which would have removed the
Dart-event-loop dependency entirely. Rejected because it is a whole C++ audio
engine for what is fundamentally a click, and because the authoritative
schedule would then live inside a third-party engine rather than in a domain we
can test to the sample. Worth revisiting if device testing shows the feed loop
starving.

**`just_audio` or `audioplayers` with WAV assets.** File playback, scheduled
from the Dart event loop — the drifting timer this phase exists to avoid.

**`audio_service`.** A large dependency for a notification that is forty lines
of Kotlin (`CLAUDE.md §42`).

**A hand-written platform channel for the audio itself.** ADR-0012's instinct,
and the reason `record` was chosen there was the same: the alternative was two
native audio paths to write, debug and device-test. The seam means the decision
can be revisited without anything above it moving.

**Interpolating the playhead between callbacks with a `Stopwatch`.** It would
smooth the indicator, and it would reintroduce a wall clock into the beat path
for a benefit nobody can see at 12 ms of quantisation.

**A swinging pendulum.** Decoration, costing frame budget at up to sixteen
pulses a second, and under reduced motion it would have to vanish entirely —
which would mean information living in motion alone (DESIGN.md §41, §42).

**Per-subdivision haptics.** Sixteen buzzes a second at 240 BPM is precisely
the overuse DESIGN.md §40 warns about. The cue fires on beats, and the setting
is off by default.

**Re-phasing the beat on a tap.** It would make every tap a re-anchor and a
running click audibly stutter under the player's finger. A tap sets the tempo.

**Stopping the click on background.** See above.

## Consequences

- **iOS is back on CocoaPods for one plugin.** `flutter_pcm_sound` 3.3.3 ships
  only a podspec, so Flutter regenerates a `Podfile` and warns that the lack of
  Swift Package Manager support "will become an error in a future version of
  Flutter". This partly reverses ADR-0012's "iOS needs no `Podfile`", and the
  difference matters: that Podfile was gratuitous and broke the build, this one
  is required and the build passes. The other plugins still resolve as Swift
  Packages, so `permission_handler_apple` still reads the app's own
  `Info.plist` and the macro ADR-0012 worried about is still unnecessary. The
  privacy invariant was re-checked on a simulator build: Contacts, Photos,
  CoreLocation, EventKit, Speech and CoreBluetooth are not linked.
- **The root Gradle file raises plugin `compileSdk` to 34.**
  `flutter_pcm_sound` declares 33 in its own module, which fails its own AAR
  metadata check against the AndroidX the Flutter embedding resolves. This is
  the plugin's problem; the block is one place and should be removed when it
  catches up. Together with the SPM gap, this is the maintenance cost of the
  dependency, and it is the thing to weigh if `flutter_soloud` is reconsidered.
- `androidx.core` is a new Android dependency, for `NotificationCompat` only.
- `Biquad` gained a band-pass, used only for click synthesis.
- `metronomePending` is deleted from both ARBs, because it is now false.
- The layer test's `_audioDomain` covers `features/metronome/domain`, so the
  no-Flutter, no-tier and no-clock rules apply to it, and the plugin allow-list
  covers `flutter_pcm_sound`.
- `PracticePage` gained a tempo row and nothing else. Sessions are Phase 08.
- The Rhythm Trainer (PRD.md §17) and Strumming Trainer (§18) move to Phase
  06.1. Both need practice-session persistence to score against and an authored
  pattern model, and both are V2 in PRD.md §66. What they inherit is not
  nothing: a strumming pattern *is* a per-pulse list of `AccentLevel`, and
  `AccentLevel.silent`, the schedule and the renderer were all shaped to
  receive one.
- **Nothing here has been verified on a device.** The suite proves the
  arithmetic against synthetic buffers and proves nothing about a speaker, a
  real audio session, a locked phone, or a foreground service surviving Doze.
  `docs/DEVICE-TESTING.md` Part B is what would let anyone claim this keeps
  time, and until it is filled in nobody should.
