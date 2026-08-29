# 0012 — The pitch detector is a pure function, and the FFT is ours

**Date:** 2026-08-29 · **Status:** Accepted

## Context

Phase 05 had to make the tuner listen. Phase 01 had left `PitchDetector` as an
interface with no implementation and no DSP anywhere, so every question was
still open: what captures the audio, what finds the note, and where the line
between them falls.

`CLAUDE.md §14` mandates the chain — Microphone, Audio Input, Audio Processing,
Pitch Detection, Tuning Engine, Tuner State, UI — and says the rest of the
application must not depend on a specific DSP implementation. `§15` requires
real-device testing and says simulator-only is not sufficient. `§16` requires
that any algorithm expose confidence. `§47` forbids faking accuracy.

## Decision

- **`core/audio/pitch_detector.dart` becomes a pure synchronous analyzer.**
  `DetectedPitch? analyze(AudioFrame)` — no microphone, no stream, no memory
  between frames.
- **`core/audio/audio_input.dart` owns capture**, behind an interface, with
  `platform/record_audio_input.dart` as the only file importing `record`.
- **`core/audio/frequency_analyzer.dart` answers what is *in* a sound** —
  level, clipping, spectral flatness, interpolated peaks — as distinct from
  what pitch it has.
- **`core/audio/mpm_pitch_detector.dart` implements the McLeod pitch method**
  over the normalised square difference function.
- **`core/audio/fft.dart` is hand-written**, and `core/audio/biquad.dart`
  with it.
- **`core/audio/audio_pipeline.dart` composes them**: PCM bytes in,
  `AnalysisFrame`s out, no microphone.
- **`core/permissions/microphone_permission.dart`** is a four-state seam, with
  `platform/permission_handler_microphone_permission.dart` behind it.
- The DSP runs on the platform thread, not in an isolate.

## Why

**The detector is pure because that is what makes it testable.** A stateful
streaming detector can only be exercised through a fake audio stream, and a
fake audio stream proves almost nothing about an algorithm. A pure function of
one window can be swept across every semitone from A0 to E6, on five waveform
shapes, at five noise levels, against a missing fundamental, through vibrato
and decay and clipping — which is what `pitch_detector_test.dart` does. This
is also why capture had to move out into `AudioInput`: an object that owns a
microphone cannot be a pure function.

**`DetectedPitch.confidence` became `clarity`.** A detector can be completely
certain about the period of a signal that is far too quiet to act on, or that
is a refrigerator rather than a string. The number the tuner is willing to show
a player is that periodicity gated by how tone-like the window was, and giving
both the same name is exactly how the wrong one reaches the interface.

**The period, not the spectrum.** At a 4096-sample window one spectrum bin
spans 5.4 Hz, which at the low E's 82.41 Hz is a whole semitone. Worse, a
plucked low E through a phone microphone routinely arrives with its fundamental
fifteen decibels below its second harmonic, so the tallest peak in the spectrum
sits at 164.8 Hz — a spectral tuner reads an octave high by construction, on
the string players struggle with most. The repetition period does not care how
weak the first harmonic is. There is a test asserting that the spectrum
*cannot* resolve an octave, so nobody later reaches for the wrong tool.

**NSDF rather than YIN.** They are two normalisations of the same
autocorrelation and their accuracy is comparable. NSDF is bounded in −1…1 and
its peak height *is* a periodicity measure, which is the shape `§16` requires;
YIN's difference function is unbounded and needs an arbitrary mapping to get
there. YIN also leans on an absolute threshold that behaves worst where a
guitar is weakest.

**The FFT is hand-written.** `CLAUDE.md §42` asks whether a dependency is
actually necessary. `fftea` is the only credible pure-Dart option — 61 likes,
two years without a release — and it allocates a fresh output list per call,
forty-three times a second, forever, in an app that has to hold 60fps. Wrapping
it to recover buffer reuse is more code than the transform. Correctness is not
taken on trust either way: `fft_test.dart` checks ours against a naive DFT
written out longhand, which is a rare case of being able to fully verify a
third party's job in twenty lines. The repo already hand-writes its chord,
scale and fretboard engines and guards each with an invariant test; this is the
same trade made the same way.

**Two different windows, on purpose.** The analyzer applies Hann, because
leakage from a rectangular window would manufacture peaks that then get counted
as a second note. The detector applies none, because a taper multiplies the
autocorrelation by the window's own and biases the answer toward short lags —
which is an octave error. They want opposite things, which is part of why they
are separate objects.

**The platform thread, for now.** Each window costs roughly a megaflop: three
transforms of 8192 points, an O(n) normalisation, a peak scan and a bounded
refinement, about forty-three times a second. Every large buffer is allocated
once and reused, so the steady state produces almost no garbage — which is the
larger jank risk of the two. An isolate would add spawn latency on every screen
open, a second copy of the tables, transfer plumbing for every chunk, and a
teardown path to get wrong on every lifecycle transition. Both analysis stages
are pure functions of a frame, so moving them later is a change to
`TunerPipeline` and nothing above it. The diagnostics view reports per-frame
milliseconds so the decision can be made on a measurement rather than this
paragraph.

**`permission_handler` earns its place where `record` cannot.** `record` can
answer whether there is permission; it cannot distinguish "ask again" from
"only the system settings can undo this" from "this device forbids it". Those
are three screens with three different next steps, and `CLAUDE.md §37` wants
every error to carry one.

## What the capture settings mean

Four values in `RecordAudioInput` are not defaults, and each is deliberate:

- **`AndroidAudioSource.unprocessed`**, because every other source applies
  speech tuning that reshapes the harmonics the detector reads and rolls off
  exactly where a low E lives.
- **`autoGain`, `noiseSuppress` and `echoCancel` all false**, for the same
  reason, and because automatic gain fights the silence gate and flattens a
  plucked note's decay.
- **`allowHapticsAndSystemSoundsDuringRecording`**, without which iOS silences
  the buzz that tells a player a string has locked (DESIGN.md §40).
- **`AudioInterruptionMode.pauseResume`**, so a call does not end the session.

`setOnConfigChanged` is registered so the *granted* rate is used rather than the
requested one. A device that quietly substitutes 48000 for 44100 would put
every reading a tone and a half sharp with nothing on screen looking wrong.
Every bound in the pipeline derives from `AudioFrame.sampleRate` for the same
reason.

## Rejected

**Keeping the streaming `PitchDetector`.** It matched the committed docs
exactly, and it would have made `AudioInput` an implementation detail rather
than the abstraction the chain calls for. Rejected because the algorithm could
then only be tested through a fake stream, which is the difference between two
hundred assertions and a handful.

**Adding an FFT dependency.** Smaller diff, one less thing to be wrong.
Rejected on `§42`: a stale, lightly-adopted package whose allocation behaviour
is wrong for the hot path, replacing code we can prove correct in a test.

**Decimating before analysis.** Halving the rate halves the work, and the
guitar's whole range fits under 1.4 kHz. Rejected because the entire accuracy
budget is lag resolution: at 44.1 kHz the top string's period is 134 samples,
and a tenth of a sample is already three cents. Decimation spends the one thing
we cannot afford to buy CPU we do not need.

**A DSP isolate.** See above; the door is left open and the measurement that
would open it is specified.

**Snapping the detected octave to the expected string.** It would make every
octave test pass and it would make the tuner lie: a genuinely octave-off string
would read in tune. That is `§47` exactly.

**Committed WAV fixtures.** They would look more like real audio. Rejected
because the sweeps cover a couple of hundred frequencies across five waveform
shapes and five noise levels, which no practical set of recordings covers, and
a failing test should read as "a sawtooth at 82.41 Hz, 10 dB SNR, seed 42"
rather than pointing at an opaque binary. Recordings arrive from
docs/DEVICE-TESTING.md §10, where they are evidence about a microphone rather
than about arithmetic.

## Consequences

- `docs/ARCHITECTURE.md`'s description of the `PitchDetector` seam is updated:
  it is still the seam, and it is now a pure function.
- `TieredEntry` moved from `features/fretboard/data/` to `core/access/`,
  because the tuner needs it too. Same move ADR-0011 made for `ChordQuality`,
  and it removes a domain-to-data import the fretboard had.
- The plugins are asserted to be imported by exactly one file each, alongside
  the existing Flutter and tier assertions.
- Android pins `compileSdk 37` — above Flutter's default 36, because
  `permission_handler_android` compiles against it — and `minSdk 24` explicitly
  rather than inheriting, so a Flutter version change cannot silently drop
  below what the plugins need.
- iOS gains its first `Podfile`. Its `post_install` block defines
  `PERMISSION_MICROPHONE=1`; without it `permission_handler_apple` compiles
  every permission it supports into the binary, and App Store review reasonably
  asks why a guitar tuner declares Contacts.
- **Nothing here is evidence about a real microphone.** The suite proves the
  algorithm on synthetic signals. `docs/DEVICE-TESTING.md` is what would let
  anyone claim the product is accurate, and until it is filled in nobody should.
