# 🎸 L Key

> **Everything Your Guitar Needs.**
>
> Tune. Learn. Practice. Play.

**L Key** is a modern, Myanmar-first guitar companion app for iOS and Android, built with Flutter.

It brings essential guitar tools, learning resources, songs, practice utilities, music theory, and intelligent assistance into one focused mobile experience.

The product is designed for guitarists of all levels — from someone learning their first three chords to experienced players working on scales, rhythm, improvisation, and songwriting.

---

## ✨ What is L Key?

L Key is more than a guitar tuner.

It is designed around four core actions:

```text
        TUNE
          ↓
        LEARN
          ↓
       PRACTICE
          ↓
         PLAY
```

The app combines:

* 🎸 Guitar tuner
* 🎼 Chord library
* 🪕 Interactive fretboard
* 🎵 Scales & modes
* 🥁 Metronome
* 🎯 Chord & rhythm trainers
* 🎶 Song library
* 🔄 Chord transposer
* 🎛️ Capo assistant
* 📚 Music theory
* 🧠 Ear training
* 📈 Practice tracking
* 🎧 Backing tracks
* 🎙️ Recording
* ✍️ Songwriting tools
* 🤖 AI Guitar Assistant
* 🧠 AI Practice Coach
* ⭐ L Key Pro

The initial focus is the **Myanmar guitar community**, with support for both **Myanmar and English**.

---

# 🚀 Product Vision

Our goal is to build the most useful guitar companion for guitarists in Myanmar while creating a platform that can eventually serve guitarists internationally.

L Key should feel like:

> **A precision musical instrument designed by a modern software company.**

It should be:

* Fast
* Simple
* Reliable
* Offline-friendly
* Accessible
* Fun
* Technically sophisticated
* Easy for beginners
* Powerful for advanced players

---

# 📱 Platforms

## Mobile

| Platform | Technology | Status            |
| -------- | ---------- | ----------------- |
| iOS      | Flutter    | 🚧 In Development |
| Android  | Flutter    | 🚧 In Development |

## Web

| Application     | Technology | Purpose                       |
| --------------- | ---------- | ----------------------------- |
| Admin Portal    | Next.js    | Content & business management |
| Landing Website | Next.js    | Marketing & SEO               |

---

# 🏗️ Architecture

L Key is organized as a multi-application repository.

```text
l-key/
│
├── PRD.md
├── CLAUDE.md
├── DESIGN.md
├── README.md
│
├── mobile/
│   └── Flutter application
│
├── backend/
│   └── Backend API
│
├── admin/
│   └── Next.js Admin Portal
│
└── website/
    └── Next.js Landing Website
```

### High-Level Architecture

```text
                         ┌──────────────────────┐
                         │   Landing Website    │
                         │       Next.js        │
                         └──────────┬───────────┘
                                    │
                                    │
                         ┌──────────▼───────────┐
                         │       Backend        │
                         │      REST API        │
                         └──────────┬───────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              │                     │                     │
      ┌───────▼────────┐   ┌────────▼────────┐   ┌──────▼──────┐
      │ Flutter Mobile │   │  Admin Portal    │   │ PostgreSQL  │
      │ iOS / Android  │   │    Next.js      │   │  Database   │
      └────────────────┘   └─────────────────┘   └─────────────┘
                                    │
                             ┌──────▼──────┐
                             │ MyanMyanPay │
                             │    MMQR     │
                             └─────────────┘
```

---

# 🛠️ Technology Stack

## Mobile

* Flutter
* Dart
* iOS
* Android

The mobile application follows a feature-oriented architecture with clear separation between:

* Presentation
* Domain
* Data

---

## Backend

The backend is responsible for:

* Authentication
* User management
* Song/content APIs
* Premium entitlements
* Payment processing
* Payment verification
* Synchronization
* Notifications
* AI services
* Admin APIs

Primary database:

**PostgreSQL**

---

## Admin Portal

Built with:

* Next.js
* React
* TypeScript

The Admin Portal manages:

* Users
* Songs
* Chords
* Scales
* Lessons
* Exercises
* Backing tracks
* Premium plans
* Payments
* Announcements
* Analytics

---

## Landing Website

Built with:

* Next.js
* React
* TypeScript

The website provides:

* Product information
* Feature pages
* SEO content
* Pricing
* App download links
* FAQs
* Legal pages

---

# 🎨 Design System

L Key uses a hybrid:

> **Neo-Brutalism × Minimalism × Modern Music Technology**

The visual identity combines strong structural elements with a clean and focused interface.

### Core characteristics

* High contrast
* Strong typography
* Thick borders
* Hard shadows
* Minimal decoration
* Tactile interactions
* Monochrome foundation
* Orange accent

---

## 🎨 Color Palette

### Primary

```text
Black
#000000
```

### Background

```text
Off White
#F0F0F0
```

### Accent

```text
Guitar Orange
#FF4D00
```

Orange represents:

* Active states
* Important actions
* Progress
* Premium
* Recording
* Interactive music states

---

# 🔤 Typography

### Headings

**Space Grotesk**

Used for:

* Screen titles
* Large numbers
* Chord names
* BPM
* Tuner note
* Marketing headlines

### Body

**Hanken Grotesk**

Used for:

* Descriptions
* Lessons
* Song information
* Settings
* General content

### Technical

**JetBrains Mono**

Used for:

* BPM
* Hz
* Cents
* Fret numbers
* Tuning information
* Metadata
* Technical labels

---

# 🎸 Core Features

## Tuner

### Free

* Standard tuning
* Microphone pitch detection
* Note detection
* Frequency
* Cents deviation
* Visual tuning indicator

### L Key Pro

* Chromatic tuner
* Drop tunings
* Open tunings
* DADGAD
* Custom tunings
* 7-string tuning
* 8-string tuning
* Bass tuning
* Reference pitch
* Tuning presets

---

# 🎼 Chords

The chord system provides:

* Open chords
* Barre chords
* Major
* Minor
* Seventh chords
* Suspended chords
* Extended chords
* Diminished
* Augmented
* Slash chords
* Alternative voicings

Each chord can display:

* Chord diagram
* Finger positions
* Notes
* Intervals
* Fret positions
* Audio
* Alternative voicings

---

# 🪕 Interactive Fretboard

Supports:

* 6-string guitar
* 7-string guitar
* 8-string guitar
* Bass

The fretboard can display:

* Notes
* Intervals
* Chords
* Scales
* Modes
* Arpeggios
* CAGED positions

---

# 🎵 Scales

Basic scales:

* Major
* Minor
* Major Pentatonic
* Minor Pentatonic
* Blues

Advanced:

* Dorian
* Phrygian
* Lydian
* Mixolydian
* Aeolian
* Locrian
* Harmonic Minor
* Melodic Minor
* Whole Tone
* Diminished
* Chromatic

---

# 🥁 Metronome

Features:

* BPM
* Tap tempo
* Time signatures
* Subdivisions
* Accents
* Progressive BPM
* Multiple sounds

---

# 🎯 Training

L Key provides interactive training tools including:

* Chord trainer
* Chord switching
* Rhythm trainer
* Strumming trainer
* Scale trainer
* Ear training
* Interval recognition
* Chord recognition

---

# 🎶 Songs

Song functionality includes:

* Song library
* Search
* Categories
* Chords
* Key
* BPM
* Capo
* Tuning
* Difficulty
* Transpose
* Auto-scroll
* Font size
* Favorites

Myanmar and English content are supported.

> Copyrighted song lyrics and other protected content must only be included when the necessary rights or permissions exist.

---

# 🔄 Transposer

Transpose songs by semitone while preserving:

* Chord formatting
* Song structure
* Slash chords
* Original key
* Current key

---

# 🎛️ Capo Assistant

Calculate:

* Capo position
* Played key
* Sounding key
* Alternative capo positions

Example:

```text
Capo: 2

Play: C
Sounds: D
```

---

# 📚 Learning

Learning content can include:

* Guitar fundamentals
* Chords
* Scales
* Music theory
* CAGED system
* Rhythm
* Improvisation
* Songwriting

Learning is structured as:

```text
Course
   ↓
Module
   ↓
Lesson
   ↓
Exercise
```

---

# 📈 Practice

Users can create and track practice sessions.

Track:

* Practice duration
* Exercises
* BPM
* Accuracy
* Streak
* Progress
* Notes

L Key Pro can provide advanced analytics:

* Daily practice
* Weekly practice
* Monthly practice
* Skill progression
* BPM progression
* Weak areas

---

# 🎧 Backing Tracks

Premium users can access backing tracks categorized by:

* Genre
* Key
* BPM
* Difficulty

Potential categories:

* Blues
* Rock
* Pop
* Funk
* Jazz
* Country
* Acoustic
* Ballad
* Worship

---

# 🎙️ Recording

Basic recording:

* Record
* Stop
* Playback

Pro:

* Unlimited recordings
* Folders
* Tags
* Favorites
* Export
* Sharing

Future:

* Multi-track recording

---

# ✍️ Songwriting

Songwriting tools allow users to create:

* Songs
* Chord progressions
* Lyrics/notes
* Sections
* BPM
* Key
* Recordings

Song sections can include:

```text
Intro
Verse
Pre-Chorus
Chorus
Bridge
Outro
```

---

# 🤖 AI Guitar Assistant

L Key Pro will provide an AI-powered guitar assistant.

Examples:

```text
"What scale works over Am7?"

"Give me a sad chord progression."

"How should I practice barre chords?"

"What chords belong to G major?"
```

The AI should use deterministic music-engine calculations whenever possible rather than independently calculating musical facts.

---

# 🧠 AI Practice Coach

The AI Practice Coach can analyze structured practice data and suggest:

* Daily practice plans
* Exercises
* Weak areas
* BPM progression
* Practice recommendations

The AI must never invent performance measurements.

---

# ⭐ L Key Pro

L Key follows a capability-based Premium model.

Free users retain access to useful core tools.

Premium unlocks advanced functionality.

### Pro Features

* Advanced tuner
* Custom tunings
* Advanced chord library
* Alternative voicings
* Chord Trainer
* CAGED System
* Advanced fretboard
* Advanced scales
* Scale Trainer
* Rhythm Trainer
* Strumming Trainer
* Advanced song tools
* Auto-scroll
* Offline premium content
* Ear Training
* Practice Analytics
* Backing Tracks
* Recording
* AI Guitar Assistant
* AI Practice Coach
* Advanced Music Theory
* Songwriting tools

---

# 💳 Payment

L Key is designed primarily for Myanmar users.

The planned local payment flow uses:

**MyanMyanPay + MMQR**

Users can pay through supported local mobile payment applications such as:

* KBZPay
* AYA Pay
* WavePay
* CB Pay
* other supported MMQR wallets

### Payment Architecture

```text
Flutter
   │
   ▼
Backend
   │
   ▼
MyanMyanPay
   │
   ▼
MMQR
   │
   ▼
User's Payment App
   │
   ▼
Payment Provider
   │
   ▼
Webhook
   │
   ▼
Backend Verification
   │
   ▼
Premium Entitlement
   │
   ▼
Flutter
```

The mobile application must never independently determine that a payment succeeded.

The backend is the source of truth for:

* Payment status
* Subscription status
* Premium entitlement

---

# 📦 Offline Support

L Key is designed to remain useful without an internet connection.

Core offline functionality should include:

* Tuner
* Metronome
* Chords
* Fretboard
* Scales
* Practice timer
* Saved songs
* Downloaded learning content

Internet is required for:

* AI
* Account synchronization
* Cloud backup
* Payment
* Remote content updates
* Server-side services

---

# 🌏 Localization

Initial languages:

```text
English
Myanmar
```

The application must support Myanmar Unicode correctly.

All user-facing strings should be localized.

Do not hardcode UI text directly into production widgets.

---

# 🔐 Security

Security principles:

* Never store secrets in Flutter.
* Never expose payment secrets to clients.
* Never trust client-side Premium status.
* Verify payment server-side.
* Verify webhooks.
* Use server-side authorization.
* Use role-based access control.
* Rate-limit sensitive endpoints.
* Never log credentials or tokens.

The mobile client must be treated as untrusted.

---

# 🛡️ Admin Portal

The Admin Portal is responsible for operating the L Key platform.

### Dashboard

* Total users
* Active users
* Premium users
* Songs
* Lessons
* Revenue
* Successful payments
* Failed payments
* Popular features

### User Management

* Search users
* View users
* View subscriptions
* View activity
* Suspend users
* Restore users
* Manage roles

### Content Management

* Songs
* Chords
* Scales
* Lessons
* Exercises
* Backing tracks

### Business

* Premium plans
* Payments
* Orders
* Entitlements

### Analytics

* DAU
* MAU
* Retention
* Practice activity
* Song usage
* Premium conversion
* Revenue

---

# 🌐 Landing Website

The public website is intended to be the primary marketing and SEO surface.

Potential pages:

```text
/
 /features
 /guitar-tuner
 /guitar-chords
 /guitar-scales
 /songs
 /pricing
 /about
 /faq
 /privacy
 /terms
```

The website should drive users toward:

* App Store
* Google Play
* Premium
* Educational content

---

# 📂 Repository Structure

```text
l-key/
│
├── README.md
├── PRD.md
├── CLAUDE.md
├── DESIGN.md
│
├── mobile/
│   ├── android/
│   ├── ios/
│   ├── lib/
│   │   ├── app/
│   │   ├── core/
│   │   ├── features/
│   │   └── main.dart
│   ├── test/
│   └── pubspec.yaml
│
├── backend/
│   ├── cmd/
│   ├── internal/
│   ├── migrations/
│   └── ...
│
├── admin/
│   ├── app/
│   ├── components/
│   ├── lib/
│   └── ...
│
└── website/
    ├── app/
    ├── components/
    ├── lib/
    └── ...
```

The exact backend structure may change as implementation progresses.

---

# 🧱 Mobile Architecture

Recommended Flutter structure:

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   ├── theme/
│   └── localization/
│
├── core/
│   ├── audio/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── permissions/
│   ├── storage/
│   └── utils/
│
├── features/
│   ├── home/
│   ├── tuner/
│   ├── chords/
│   ├── fretboard/
│   ├── scales/
│   ├── metronome/
│   ├── songs/
│   ├── practice/
│   ├── learning/
│   ├── recording/
│   ├── backing_tracks/
│   ├── ai/
│   ├── premium/
│   └── profile/
│
└── main.dart
```

---

# 🧠 Domain Architecture

Music calculations must remain independent from Flutter UI.

Examples:

```text
Chord Engine
Scale Engine
Fretboard Engine
Tuning Engine
Transpose Engine
Capo Engine
Practice Engine
```

Conceptually:

```text
UI
 ↓
State
 ↓
Use Case
 ↓
Domain Engine
 ↓
Result
```

This makes music functionality easier to:

* test
* reuse
* extend
* run offline
* use from AI services

---

# 🎛️ Audio Architecture

Audio functionality follows:

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
Application State
    ↓
UI
```

Audio processing must not live inside Flutter widgets.

Real-device testing is required for audio functionality.

---

# 🧪 Testing

Testing should cover:

### Unit Tests

* Chord calculations
* Chord transposition
* Capo calculations
* Scale calculations
* Fretboard calculations
* Tuning calculations
* Premium entitlement
* Payment state transitions

### Widget Tests

* Loading states
* Empty states
* Error states
* Premium locked states
* Premium unlocked states
* Localization
* Accessibility

### Integration Tests

Critical flows:

```text
Launch
 ↓
Home
 ↓
Tuner
 ↓
Chord
 ↓
Song
 ↓
Practice
 ↓
Premium
 ↓
Payment
 ↓
Entitlement
```

---

# 🚧 Development Status

L Key is currently in the **early development / foundation phase**.

## Phase 1 — Foundation

* [ ] Repository setup
* [ ] Flutter project
* [ ] Design tokens
* [ ] Theme
* [ ] Localization
* [ ] Navigation
* [ ] Architecture

## Phase 2 — Core Guitar Tools

* [ ] Tuner
* [ ] Chord Engine
* [ ] Chord UI
* [ ] Fretboard
* [ ] Scale Engine
* [ ] Metronome
* [ ] Capo
* [ ] Transposer

## Phase 3 — Songs & Learning

* [ ] Song model
* [ ] Song API
* [ ] Song viewer
* [ ] Search
* [ ] Favorites
* [ ] Lessons
* [ ] Exercises

## Phase 4 — Practice

* [ ] Practice sessions
* [ ] Practice history
* [ ] Streaks
* [ ] Progress
* [ ] Basic analytics

## Phase 5 — Backend

* [ ] Authentication
* [ ] User profiles
* [ ] Content API
* [ ] Synchronization
* [ ] Notifications

## Phase 6 — Admin Portal

* [ ] Admin authentication
* [ ] Dashboard
* [ ] User management
* [ ] Song CMS
* [ ] Chord CMS
* [ ] Scale CMS
* [ ] Lesson CMS
* [ ] Exercise CMS
* [ ] Premium management
* [ ] Payment management
* [ ] Analytics

## Phase 7 — Premium

* [ ] Premium plans
* [ ] Entitlements
* [ ] Premium UI
* [ ] MyanMyanPay integration
* [ ] MMQR
* [ ] Payment verification
* [ ] Webhooks

## Phase 8 — Advanced Tools

* [ ] Rhythm trainer
* [ ] Strumming trainer
* [ ] Ear training
* [ ] Backing tracks
* [ ] Recording
* [ ] CAGED system
* [ ] Advanced fretboard

## Phase 9 — AI

* [ ] AI Guitar Assistant
* [ ] AI Practice Coach
* [ ] AI songwriting assistance

## Phase 10 — Advanced Audio

* [ ] Chord recognition
* [ ] Advanced pitch analysis
* [ ] Practice audio analysis
* [ ] Advanced guitar recognition

---

# 🤖 AI-Assisted Development

L Key is being developed with AI-assisted software development, primarily using **Claude Code**.

AI is used to assist with:

* architecture
* implementation
* refactoring
* testing
* documentation
* UI development
* debugging
* code review

However:

> **AI-generated code must still follow the project's architecture, security requirements, design system, and testing standards.**

Claude must read:

```text
CLAUDE.md
PRD.md
DESIGN.md
```

before implementing significant features.

---

# 📖 Documentation

| Document    | Purpose                                        |
| ----------- | ---------------------------------------------- |
| `README.md` | Project overview and developer onboarding      |
| `PRD.md`    | Product requirements and feature specification |
| `CLAUDE.md` | AI development and engineering rules           |
| `DESIGN.md` | Mobile, Admin, and Website design system       |

These documents form the project's initial source of truth.

---

# 🧭 Development Principles

L Key follows several core principles.

### 1. Build for guitarists first

Every feature should help users:

> Tune → Learn → Practice → Play.

### 2. Offline-first for core tools

A guitarist should not need an internet connection just to tune their guitar.

### 3. Deterministic music logic

Musical calculations should be handled by reliable domain engines rather than AI.

### 4. Server-authoritative Premium

The client must never be the source of truth for payment or Premium access.

### 5. Simple architecture

Avoid unnecessary:

* microservices
* abstraction
* dependencies
* infrastructure complexity

### 6. Accessibility is a feature

The app must work for as many guitarists as possible.

### 7. Myanmar-first

Myanmar language, payment methods, connectivity realities, and local guitar culture should be considered from the beginning.

---

# 🎯 Long-Term Vision

L Key can eventually evolve from a guitar utility application into a complete guitar learning and practice platform.

Potential future capabilities include:

```text
Guitar Tools
     ↓
Learning
     ↓
Practice
     ↓
Performance
     ↓
Songwriting
     ↓
AI Coaching
     ↓
Guitar Community
```

The long-term goal is not to build the largest number of features.

It is to build the **most useful guitar companion**.

---

# 📜 License

License information will be added before public distribution.

---

# ❤️ Built for Guitarists

L Key is being built with one simple idea:

> **Spend less time configuring your tools. Spend more time playing guitar.**

🎸 **Tune. Learn. Practice. Play.**

