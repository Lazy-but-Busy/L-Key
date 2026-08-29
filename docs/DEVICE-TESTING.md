# Device testing — audio

`npm run verify` proves the tuner's arithmetic. It proves nothing at all about
a microphone.

Everything in the automated suite runs against signals generated in the test:
sines, sawtooths, square waves, tones with their fundamental removed, noise at
known ratios. That is genuine evidence about the algorithm — it catches octave
errors, it holds accuracy to a cent, it shows where confidence collapses. It is
not evidence about a phone's microphone, its gain, its low-frequency response,
or what the operating system does to the signal before it reaches us.

`mobile/CLAUDE.md §15` is explicit: **do not consider simulator-only testing
sufficient for audio features.** This document is what has to happen before
anyone says the tuner is accurate.

> **Status: not yet run.** No result table below has been filled in. Until one
> has, the tuner is *implemented and unverified*, and no accuracy claim belongs
> in the app, the store listing or the marketing site (`CLAUDE.md §47`).

---

## What you need

- An **iPhone**, iOS 15 or later.
- **Two Android phones** if possible: one on API 24–26, one on API 34 or later.
  Cheap and old is the point — the low end is where the audio path is worst and
  where the frame budget is tightest.
- A **guitar**, and a **bass** if one is available.
- A **reference tuner** you trust: a clip-on that reads the string by vibration,
  or a strobe. It must not be another phone app.
- A **quiet room** and a **noisy one**.

## Setup

```sh
cd mobile
flutter run --release \
  --dart-define=ENABLE_TUNER_DIAGNOSTICS=true \
  -d <device>
```

Release, not debug: debug builds run Dart without ahead-of-time compilation and
the frame timings mean nothing. The diagnostics panel appears at the foot of
the tuner screen and shows the raw measurements every threshold is set against.

---

## 1. Session facts

Open the tuner, press listen, play any string, and read the panel.

| | iPhone | Android (old) | Android (new) |
| --- | --- | --- | --- |
| `rate` | | | |
| `window` / hop | | | |
| `fps` | | | |

**Expected:** 44100 Hz, 4096 / 1024, about 43 frames per second.

**If the rate is not 44100, stop and read it carefully.** The pipeline derives
every bound from the granted rate, so a substitution should be harmless — but
that is the single most dangerous failure mode in the feature, because a rate
that was wrong *and* unnoticed would put every reading about a tone and a half
out with nothing on screen looking wrong. Section 3 is what actually proves it
did not happen.

## 2. Level calibration

This is what sets `silenceFloorDbfs` and `signalOnsetDbfs` in
`mobile/lib/features/tuner/domain/tuner_thresholds.dart`. The shipped values
are estimates from typical behaviour; decibels relative to full scale are not
comparable between devices, because input gain is not.

| `level` (dBFS) | iPhone | Android (old) | Android (new) |
| --- | --- | --- | --- |
| Silent room | | | |
| Normal room, no playing | | | |
| Low E plucked softly, 30 cm | | | |
| Low E plucked hard, 30 cm | | | |
| Low E at arm's length | | | |

**Outcome:** the floor should sit above the quiet room and below the softest
pluck at arm's length. If it does not, change the two constants and say so in
the pull request.

Also record `clipped` while playing hard and close. Anything above about 0.01
means the input is overloading.

## 3. Accuracy — the section that licenses a claim

For each open string: tune it with the **reference tuner** until the reference
says it is right. Then read L Key's cents figure ten times, plucking again each
time. Record the median and the spread.

| String | Median cents | Spread | Notes |
| --- | --- | --- | --- |
| E2 | | | |
| A2 | | | |
| D3 | | | |
| G3 | | | |
| B3 | | | |
| E4 | | | |

**Pass:** median within ±5 cents and spread within 6 cents, on every device.

A consistent offset on all six strings on one device is a sample-rate or
calibration problem, not a tuning one. A large error on the low E alone is
microphone roll-off — see section 9.

## 4. Octave errors

The failure that makes a tuner useless rather than imprecise. For each string,
ten plucks hard near the bridge and ten soft over the neck.

| String | Wrong-octave readings (of 20) |
| --- | --- |
| E2 | |
| A2 | |
| D3 | |
| G3 | |
| B3 | |
| E4 | |

**Pass: zero.** Any reading more than 50 cents from the correct octave is a
failure, and the raw frequency in the diagnostics panel says which way it went.

## 5. The states that are not a note

| Situation | Expected | Actual |
| --- | --- | --- |
| Strum a full chord | "More than one string is ringing" | |
| Let two strings ring together | same | |
| Play an octave double-stop (E2 + E3) | **Not** flagged — a documented limit | |
| Talk at conversational volume near the phone | "Too much background noise" | |
| A television at conversational volume | same | |
| Let a note decay to nothing | Returns cleanly to "Listening", no flicker | |
| Knock the body of the guitar | No note claimed | |

Record `flatness`, `residual` and `partials` for each. Those three are what the
polyphony and noise decisions are made from, and they are the numbers to change
the thresholds against if any row misbehaves.

## 6. Lifecycle and the microphone indicator

Both platforms show an indicator while the microphone is live. Watch it.

| Action | Expected | Actual |
| --- | --- | --- |
| Press listen | Indicator on | |
| Press stop | Indicator **off** | |
| Background the app while listening | Indicator off | |
| Return to the app | Listening resumes | |
| Switch to another tab | Indicator off | |
| Return to the Tools tab | Listening resumes | |
| Navigate back off the tuner | Indicator off | |
| Take an incoming call | Stops; **no error screen** | |
| Trigger Siri or Google Assistant | Same | |
| Lock the screen | Indicator off | |
| Connect Bluetooth headphones mid-session | Note what happens | |

An indicator that stays on after any "off" row is a `CLAUDE.md §50` violation
and blocks the phase.

## 7. Permissions

On a **fresh install** each time — a granted permission cannot be un-granted
from inside the app.

| Step | Expected | Actual |
| --- | --- | --- |
| First press of listen | System prompt, with our usage text | |
| Decline | "The tuner needs your microphone", with Allow | |
| Press Allow, decline again | iOS: blocked screen. Android: prompt again | |
| Reach the blocked screen | "Open settings" offered, no retry | |
| Press Open settings, grant, return | Tuner works | |

Check the wording of the system prompt itself. It comes from
`NSMicrophoneUsageDescription` on iOS, and it should read as an explanation
rather than a demand.

## 8. Performance

Ten minutes of continuous listening, release build, screen on.

| | iPhone | Android (old) | Android (new) |
| --- | --- | --- | --- |
| Battery % at start / end | | | |
| Device warm to the touch? | | | |
| Jank with the performance overlay on | | | |
| `fps` still ~43 after ten minutes | | | |

**If the old Android janks**, the fix is already designed for: both analysis
stages are pure functions of a frame, so moving them into a worker isolate is a
change to `TunerPipeline` and nothing above it (docs/adr/0012).

## 9. Low strings and extended range

The most likely thing to be genuinely wrong in the real world. Phone
microphones roll off hard below about 100 Hz — some by 20 dB at the low E.

| | iPhone | Android (old) | Android (new) |
| --- | --- | --- | --- |
| E2 (82.41 Hz), `clarity` | | | |
| Drop D's D2 (73.42 Hz), `clarity` | | | |
| Seven-string B1 (61.74 Hz), `clarity` | | | |
| Bass E1 (41.20 Hz), `clarity` | | | |
| Five-string bass B0 (30.87 Hz), `clarity` | | | |

If clarity collapses at the bottom, the options are raising `minimumHz`, adding
a pre-emphasis stage before the detector, or saying plainly in the interface
that the lowest bass strings are unreliable on some phones. Guessing between
those without these numbers is exactly what this document exists to prevent.

## 10. Capture recordings for a regression suite

The diagnostics panel is the place to add a dump control if it is not there
yet. Record five seconds of each open string, on each device, in a quiet room.

Those recordings are the one thing the synthetic suite cannot produce: evidence
about a real microphone. Committed as fixtures they turn every finding above
into a test that cannot silently regress, which is the natural next phase for
this work.

---

## Reporting

Paste the filled tables into the pull request. Where a threshold had to change,
say which and why — `tuner_thresholds.dart` exists as one object precisely so
that this is a small, reviewable diff.

Then, and only then, `README.md`'s tuner entry can say the accuracy has been
verified, and on what.
