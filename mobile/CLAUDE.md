# CLAUDE.md — mobile/

Flutter engine and audio rules, moved out of the root `CLAUDE.md` so they load only
when working under `mobile/`. Section numbers are unchanged: an existing
`CLAUDE.md §14` citation still refers to §14 below.

# 11. Chord Engine

Create a reusable chord domain engine.

It should support:

* chord names
* notes
* intervals
* finger positions
* string states
* fret positions
* voicings
* transposition

Do not hardcode chord calculations inside widgets.

---

# 12. Scale Engine

Scale logic must support:

* formulas
* intervals
* notes
* keys
* fretboard positions

The scale engine should not depend on Flutter UI.

---

# 13. Fretboard Engine

The fretboard engine should calculate:

* strings
* frets
* tuning
* notes
* intervals
* highlighted positions

UI should only render the calculated result.

---

# 14. Tuner Architecture

Separate:

```text
Microphone
   ↓
Audio Input
   ↓
Audio Processing
   ↓
Pitch Detection
   ↓
Tuning Engine
   ↓
Tuner State
   ↓
Flutter UI
```

Do not place audio processing inside widgets.

Tuner implementation must support future replacement of the pitch-detection algorithm.

Use an abstraction such as:

```text
PitchDetector
```

The rest of the application should not depend directly on a specific DSP implementation.

---

# 15. Audio Rules

Audio features require extra care.

Always consider:

* microphone permissions
* audio session lifecycle
* interruption handling
* background/foreground transitions
* latency
* CPU usage
* battery
* sample rate
* device differences

Test on real iOS and Android devices.

Do not consider simulator-only testing sufficient for audio features.

---

# 16. Chord Recognition

Real-time chord recognition is an advanced feature.

Do not implement it as a fake keyword/rule system merely to satisfy a UI requirement.

Use a clear architecture:

```text
Audio
 ↓
Feature Extraction
 ↓
Pitch / Frequency Analysis
 ↓
Note Detection
 ↓
Chord Classification
 ↓
Confidence
 ↓
Practice Result
```

The algorithm must expose confidence.

Do not tell users a chord is definitely correct when confidence is low.

---

# 50. Battery

Audio tools must be particularly careful about battery consumption.

Stop microphone/audio processing when:

* tuner closes
* app goes background
* user explicitly stops audio feature

Handle lifecycle transitions correctly.
