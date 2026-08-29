# PRD.md

# Guitar Companion — Product Requirements Document

**Version:** 1.0
**Status:** Product Foundation
**Platforms:** iOS, Android, Web Admin, Landing Website
**Mobile Framework:** Flutter
**Admin / Website:** Next.js + React + TypeScript
**Primary Market:** Myanmar
**Primary Languages:** Myanmar (Burmese), English

---

# 1. Product Overview

## 1.1 Product Name

Working product name: L Key

**Guitar Companion**

The final brand name may be changed independently of the technical architecture.

---

## 1.2 Product Vision

Build the best Myanmar-first mobile guitar companion that combines:

* guitar tuning
* chords
* songs
* fretboard visualization
* scales
* music theory
* practice tools
* ear training
* rhythm training
* recording
* backing tracks
* AI-powered guitar assistance
* personalized practice

into one modern, offline-friendly mobile experience.

The product should be useful to:

* complete beginners
* casual guitarists
* intermediate players
* advanced guitarists
* singers who accompany themselves
* worship musicians
* acoustic players
* electric guitarists
* bass players
* songwriters

---

# 2. Product Positioning

The product is not simply:

> "A guitar tuner."

It is:

> **A complete guitar companion for learning, practicing, playing, and discovering music.**

The four primary product pillars are:

1. **Tune**
2. **Learn**
3. **Practice**
4. **Play**

---

# 3. Goals

## 3.1 Primary Goals

* Provide a fast and accurate guitar tuner.
* Provide a comprehensive chord system.
* Provide a Myanmar-focused guitar song library.
* Make guitar learning approachable.
* Make daily practice easier.
* Provide professional-quality guitar utilities.
* Work offline for core functionality.
* Support Myanmar payment methods.
* Create a sustainable Premium product.
* Establish a content management system through an Admin Portal.
* Build a strong SEO/acquisition channel through the Landing Website.

---

# 4. Non-Goals for MVP

The following should NOT be required for the initial release:

* full DAW
* advanced guitar amp simulation
* professional multi-track recording
* social network
* live streaming
* real-time AI accompaniment
* complex community moderation
* automatic transcription of arbitrary copyrighted songs
* perfect real-time chord recognition
* advanced machine-learning music analysis

These can be evaluated for future releases.

---

# 5. Target Users

## 5.1 Beginner Guitarist

Needs:

* tuner
* basic chords
* chord diagrams
* songs
* transpose
* capo
* practice exercises
* beginner lessons

---

## 5.2 Intermediate Guitarist

Needs:

* advanced chords
* scales
* CAGED
* fretboard
* rhythm training
* practice analytics
* ear training
* backing tracks

---

## 5.3 Advanced Guitarist

Needs:

* custom tunings
* advanced fretboard
* modes
* arpeggios
* chord voicings
* advanced scales
* BPM training
* recording
* songwriting tools

---

## 5.4 Singer / Guitar Accompanist

Needs:

* songs
* chords
* transpose
* capo
* lyrics where appropriately licensed
* auto-scroll
* quick tuner

---

# 6. Platform Strategy

## 6.1 Mobile Application

Flutter application targeting:

* iOS
* Android

Mobile is the primary product.

---

## 6.2 Admin Portal

Web application for:

* content management
* user management
* Premium management
* payment management
* analytics
* song management
* lessons
* exercises
* backing tracks
* announcements

---

## 6.3 Landing Website

Public Next.js website for:

* product marketing
* SEO
* guitar education content
* song/chord discovery
* app acquisition
* Premium promotion
* FAQs
* legal pages

---

# 7. Mobile Information Architecture

Primary navigation:

1. Home
2. Tools
3. Learn
4. Songs
5. Profile

---

# 8. Home

## Requirements

The Home screen must provide immediate access to:

* tuner
* recently used tools
* continue practicing
* recent songs
* practice progress
* daily recommendation

Example sections:

* Greeting
* Quick Tune
* Quick Tools
* Continue Practice
* Recently Played
* Daily Challenge
* Premium recommendation

Home must not feel like a generic dashboard.

---

# 9. Authentication

Authentication is optional for basic usage.

## Guest User

Guests can use:

* tuner
* metronome
* basic chords
* basic fretboard
* basic scales
* basic practice timer

## Registered User

Registration enables:

* cloud synchronization
* profile
* favorites
* practice history
* recordings
* Premium
* multiple devices
* backup

Supported authentication may include:

* Email
* Google
* Apple

Authentication providers can be introduced incrementally.

---

# 10. Guitar Tuner

## 10.1 Free Features

* Standard tuning
* E A D G B E
* microphone input
* note detection — the note actually sounding, with its octave
* cents deviation
* frequency display
* visual tuning indicator

Note detection means the note the microphone hears, whatever it is, not the
nearest of the six open strings. A beginner has to be able to see that they
are playing an F when they meant an E, and a tuner that renamed it E would be
faking accuracy (CLAUDE.md §47). Frequency display moved here from §10.2 for
the same reason: it is the number the note is derived from, and hiding it
while showing the note it produced is arbitrary.

## 10.2 Premium Features

* Chromatic tuning mode — tuning *towards* any note rather than towards a
  string of the selected tuning
* Drop D
* Drop C
* Drop B
* Half-step down
* Full-step down
* DADGAD
* Open G
* Open D
* Open E
* Eb tuning
* 7-string tuning
* 8-string tuning
* Bass tuning
* custom tuning
* reference pitch
* tuning presets
* tuning history

## Technical Requirement

Audio processing must be isolated from UI code.

The tuner engine must expose structured data:

```text
DetectedNote
Frequency
TargetFrequency
Cents
Confidence
IsInTune
```

The UI must not implement pitch detection logic.

---

# 11. Chord Library

## Free

Include common open chords.

Examples:

* C
* D
* E
* F
* G
* A
* B
* Am
* Dm
* Em

## Premium

Support:

* Major
* Minor
* 7
* maj7
* m7
* 6
* 9
* maj9
* m9
* sus2
* sus4
* add9
* diminished
* augmented
* slash chords
* advanced voicings
* movable shapes
* barre chords
* alternative voicings

## Chord Detail

Each chord can display:

* chord name
* diagram
* string status
* fret positions
* finger positions
* barre indicator
* notes
* interval formula
* audio playback
* alternative voicings
* favorite

---

## Chord Analyzer

Free.

The chord library answers "what does Cmaj7 look like?". The analyzer answers
the opposite question, for a player who has a shape under their fingers and no
name for it.

The player builds a shape on a fretboard — a fret per string, or a muted
string — and L Key reports:

```text
the notes sounding
the bass note
the interval each string plays
the chord names the shape could go by, best first
```

Deterministic, from the same chord formulas the library draws from. It names
nothing it cannot spell from those formulas: a shape no supported quality
accounts for gets an honest "no chord matches this shape" rather than an
invented one.

Root and bass are separate, so a C major triad with an E lowest is `C/E`.

---

# 12. Chord Trainer

Modes:

## Identify Chord

Show diagram.

User chooses chord name.

## Build Chord

Show chord name.

User plays guitar.

Audio recognition evaluates the result where supported.

## Chord Switching

Example:

```text
C → G → Am → F
```

Measure:

* transition time
* accuracy
* mistakes
* BPM

## Progressive Difficulty

Beginner → Intermediate → Advanced.

---

# 13. Interactive Fretboard

The fretboard must support:

* 6-string
* 7-string
* 8-string
* bass

Users can select:

* note
* chord
* scale
* mode
* interval
* arpeggio

Display:

* string names
* fret numbers
* notes
* root note
* interval
* highlighted scale positions

Premium:

* CAGED
* advanced modes
* arpeggios
* chord tones
* custom tuning fretboard

---

# 14. Scales

## Free

* Major
* Minor
* Minor Pentatonic
* Major Pentatonic
* Blues

## Premium

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
* additional specialized scales

Each scale includes:

* formula
* notes
* fretboard
* positions
* audio
* practice mode

---

# 15. CAGED System

Premium learning module.

Teach:

* C shape
* A shape
* G shape
* E shape
* D shape

Provide:

* diagrams
* fretboard visualization
* exercises
* chord relationships
* practice challenges

---

# 16. Metronome

Free:

* BPM
* start/stop
* tap tempo
* 4/4

Premium:

* 3/4
* 6/8
* 5/4
* 7/8
* custom time signatures
* subdivisions
* accents
* sound selection
* progressive BPM

---

# 17. Rhythm Trainer

Support:

* rhythm patterns
* strumming patterns
* visual timing
* BPM progression
* practice scoring

Premium may include microphone-assisted timing analysis.

---

# 18. Strumming Trainer

Display:

```text
↓ ↓ ↑ ↑ ↓ ↑
1 & 2 & 3 & 4 &
```

Features:

* animation
* audio
* slow mode
* normal mode
* BPM control
* progressive difficulty
* custom patterns

---

# 19. Song Library

Song metadata:

* title
* artist
* language
* genre
* key
* BPM
* capo
* difficulty
* tuning
* chords
* content status

Categories:

* Myanmar
* English
* Pop
* Rock
* Acoustic
* Worship
* Country
* Blues
* Indie
* Classic

Copyrighted lyrics/chords must only be included when the required rights or permissions exist.

---

# 20. Song Player / Viewer

Features:

* chords
* lyrics where licensed
* chord diagrams
* transpose
* capo
* alternative chords
* font size
* auto-scroll
* scroll speed
* favorite
* offline save for permitted content

---

# 21. Transposer

Users can transpose a song by semitone.

Requirements:

* preserve chord formatting
* preserve slash chords
* preserve song structure
* display original key
* display current key

---

# 22. Capo Assistant

Calculate:

* played key
* sounding key
* capo position
* alternative capo positions

Example:

```text
Capo 2
Play C
Sounds D
```

---

# 23. BPM Detector

Support:

* tap tempo
* manual BPM
* audio analysis where technically supported

---

# 24. Practice System

Users can:

* start session
* select exercises
* set duration
* set BPM
* complete session
* review performance

Track:

* duration
* exercises
* BPM
* accuracy
* date
* notes

---

# 25. Practice Analytics

Premium:

* daily practice
* weekly practice
* monthly practice
* total practice
* practice streak
* skill progression
* BPM progression
* weak areas
* most practiced skills

---

# 26. Practice Streak

Track consecutive practice days.

Show:

* current streak
* longest streak
* weekly calendar
* monthly calendar

---

# 27. Guitar Collection

Users can create guitars:

```text
Name
Type
Brand
Tuning
String Count
Notes
```

Types:

* Acoustic
* Electric
* Classical
* Bass
* 7-string
* 8-string

Selected guitar can influence:

* tuner
* fretboard
* tuning
* practice

---

# 28. Ear Training

Modules:

* note recognition
* interval recognition
* chord recognition
* progression recognition
* scale recognition

Track:

* score
* accuracy
* attempts
* progression

---

# 29. Music Theory

Lessons:

* notes
* intervals
* major scale
* minor scale
* triads
* seventh chords
* keys
* chord construction
* modes
* circle of fifths
* Roman numerals
* Nashville numbers

---

# 30. Circle of Fifths

Interactive visualization showing:

* major keys
* relative minors
* key relationships
* sharps
* flats

---

# 31. Backing Tracks

Premium feature.

Metadata:

* genre
* key
* BPM
* duration
* difficulty

Categories:

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

# 32. Recording

Free:

* basic recording

Premium:

* unlimited recordings
* playback
* rename
* folders
* tags
* favorites
* export
* sharing

Future:

* multi-track recording

---

# 33. Songwriting

Users can create:

* songs
* chord progressions
* lyrics/notes
* keys
* BPM
* sections
* recordings

Sections:

* Intro
* Verse
* Pre-Chorus
* Chorus
* Bridge
* Outro

---

# 34. Chord Progression Generator

Input:

* key
* genre
* mood
* difficulty
* length

Output:

* progression
* Roman numerals
* chord diagrams
* audio playback

---

# 35. AI Guitar Assistant

Premium.

Use cases:

* chord questions
* scale recommendations
* theory questions
* practice suggestions
* songwriting help
* progression generation

Examples:

```text
"What scale works over Am7?"

"Give me a sad progression."

"How can I practice barre chords?"

"What chords belong to G major?"
```

AI responses must be treated as assistance, not authoritative musical truth.

---

# 36. AI Practice Coach

Premium.

Input:

* practice history
* completed exercises
* performance metrics

Output:

* daily practice plan
* weak area recommendations
* exercise recommendations
* motivational feedback

The AI should not invent performance measurements. It must consume structured measurements from the practice/audio engines.

---

# 37. AI Backing Track

Future feature.

Input:

* key
* genre
* mood
* BPM
* duration

Output:

* generated backing track

This requires separate audio generation infrastructure and should not block MVP.

---

# 38. Guitar Maintenance

Future utility module:

* string replacement reminder
* string gauge reference
* setup information
* action guide
* neck relief guide
* intonation guide

---

# 39. Favorites

Users can favorite:

* songs
* chords
* scales
* tunings
* exercises
* backing tracks
* recordings

---

# 40. Search

Global search across:

* songs
* chords
* scales
* lessons
* exercises
* tunings

Search must support Myanmar and English text.

---

# 41. Localization

Initial languages:

* English
* Myanmar

All user-facing strings must use localization files.

Never hardcode UI strings.

---

# 42. Offline Architecture

Core features should work without internet.

Offline:

* tuner
* metronome
* chord library
* fretboard
* scales
* saved songs
* practice timer
* downloaded content

Online required:

* account synchronization
* Premium verification
* AI
* cloud backup
* remote content updates
* payment

---

# 43. Premium Product

Premium should provide advanced capability rather than cosmetic decoration.

## Premium Features

1. Advanced tuner
2. Custom tunings
3. Advanced chord library
4. Alternative chord voicings
5. Chord Trainer
6. CAGED System
7. Advanced fretboard
8. Advanced scales
9. Scale Trainer
10. Rhythm Trainer
11. Strumming Trainer
12. Premium song library
13. Advanced song tools
14. Auto-scroll
15. Offline premium content
16. Ear Training
17. Practice Analytics
18. Backing Tracks
19. Recording
20. AI Guitar Assistant
21. AI Practice Coach
22. Advanced Music Theory
23. Songwriting tools

---

# 44. Free vs Premium Philosophy

Free users must be able to understand the value of the product.

Do not paywall:

* basic tuner
* basic chords
* basic metronome
* basic fretboard
* basic practice timer

Premium unlocks:

> depth, personalization, advanced tools, intelligence, and content.

---

# 45. Payment

Primary local payment system:

**MyanMyanPay / MMQR**

Potential payment networks include:

* KBZPay
* WavePay
* AYA Pay
* CB Pay
* other supported MMQR networks

Payment flow:

```text
Flutter
  ↓
Create Order
  ↓
Backend
  ↓
MyanMyanPay
  ↓
Dynamic MMQR
  ↓
User Payment App
  ↓
Payment Provider
  ↓
MyanMyanPay
  ↓
Webhook
  ↓
Backend
  ↓
Verify Payment
  ↓
Activate Entitlement
  ↓
Flutter
```

The Flutter client must never determine payment success by itself.

The backend is the source of truth.

---

# 46. Subscription Entitlement

Database should maintain:

```text
user_id
plan
status
started_at
expires_at
payment_provider
payment_reference
```

Statuses:

* pending
* active
* expired
* cancelled
* refunded

Premium access must be determined by server-side entitlement.

---

# 47. Subscription Options

Initial commercial model may support:

* Monthly
* 3 Months
* Yearly
* Lifetime

Exact pricing should be configurable through the Admin Portal rather than hardcoded.

---

# 48. Admin Portal

## Dashboard

Display:

* total users
* active users
* Premium users
* songs **[IMPORTANT]** Bulk songs upload support with chords and lyrics for both Myanmar and English songs to end-users(mobile) via Admin portal.
* lessons
* exercises
* revenue
* successful payments
* failed payments
* daily active users

---

# 49. Admin User Management

Actions:

* search
* view profile
* view subscription
* view activity
* suspend
* restore
* change role

Roles:

* Super Admin
* Admin
* Editor
* Support

---

# 50. Song CMS

Admin can:

* create
* edit
* preview
* publish
* unpublish
* archive

Fields:

* title
* artist
* language
* genre
* key
* BPM
* capo
* tuning
* difficulty
* chord content
* lyric content where licensed
* cover image
* status

---

# 51. Chord CMS

Manage:

* chord names
* formulas
* diagrams
* finger positions
* voicings
* audio

---

# 52. Scale CMS

Manage:

* scale name
* formula
* intervals
* notes
* fretboard patterns
* category
* difficulty

---

# 53. Lesson CMS

Hierarchy:

```text
Course
 └── Module
      └── Lesson
           └── Exercise
```

---

# 54. Exercise CMS

Manage:

* title
* type
* difficulty
* duration
* BPM
* instructions
* audio
* video
* premium status

---

# 55. Backing Track CMS

Manage:

* audio
* genre
* key
* BPM
* duration
* difficulty
* Premium status

---

# 56. Premium Management

Admin can configure:

* plans
* prices
* duration
* features
* promotional offers
* activation status

---

# 57. Payment Management

Admin can view:

* orders
* payment references
* status
* amount
* user
* timestamps
* provider
* webhook state

Admins must not manually mark payments as successful without an auditable administrative action.

---

# 58. Analytics

Track:

* DAU
* MAU
* retention
* sessions
* tuner usage
* chord usage
* song views
* searches
* practice sessions
* Premium conversion
* payment conversion
* churn

Do not collect unnecessary personal data.

---

# 59. Notifications

Support:

* practice reminders
* new songs
* new lessons
* announcements
* Premium promotions
* challenges

Users must be able to control notification preferences.

---

# 60. Landing Website

Purpose:

1. Explain product.
2. Demonstrate tools.
3. Promote Premium.
4. Capture search traffic.
5. Drive App Store / Google Play downloads.

Pages:

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

SEO content can include public educational resources where content rights permit.

---

# 61. Analytics Events

Example events:

```text
app_opened
tuner_opened
tuning_completed
chord_viewed
chord_favorited
song_opened
song_transposed
capo_used
metronome_started
practice_started
practice_completed
lesson_started
lesson_completed
premium_viewed
payment_started
payment_success
payment_failed
ai_assistant_used
```

---

# 62. Security Requirements

* Never expose payment secrets in Flutter.
* Never expose backend secrets in the mobile application.
* Verify payment webhooks.
* Validate all server requests.
* Enforce authorization server-side.
* Use role-based access control for Admin.
* Rate-limit sensitive APIs.
* Do not trust client-side Premium state.
* Encrypt sensitive data where appropriate.
* Keep audit logs for administrative actions.

---

# 63. Performance Requirements

Mobile:

* fast cold start
* smooth scrolling
* 60fps target
* low battery consumption
* minimal unnecessary network requests

Audio:

* low latency
* stable microphone session
* avoid unnecessary audio processing when tuner is inactive

Offline:

* core tools should launch without network access.

---

# 64. Accessibility

Support:

* VoiceOver
* TalkBack
* Dynamic Type
* large touch targets
* semantic labels
* reduced motion
* high contrast

---

# 65. MVP Definition

MVP must contain:

### Tools

* Standard tuner
* Metronome
* Chord library
* Basic fretboard
* Basic scales
* Capo
* Transposer

### Songs

* Song library
* Myanmar/English metadata
* chords
* favorites

### Learning

* Basic chord trainer
* basic lessons
* practice timer

### User

* guest mode
* optional account
* favorites
* practice history

### Backend

* authentication
* content API
* user API
* Premium entitlement foundation

### Admin

* dashboard
* users
* songs
* chords
* scales
* lessons
* Premium/content status

### Website

* landing page
* features
* pricing
* download CTA
* legal pages

---

# 66. V2

* custom tuning
* advanced tuner
* CAGED
* scale trainer
* rhythm trainer
* strumming trainer
* ear training
* practice analytics
* backing tracks
* recording
* MyanMyanPay Premium
* advanced Admin analytics
* push notifications

---

# 67. V3

* AI Guitar Assistant
* AI Practice Coach
* chord recognition
* advanced audio analysis
* songwriting studio
* AI backing tracks
* community
* multi-track recording
* advanced music analysis

---

# 68. Product Principle

The application should always answer one question:

> **"Does this help the guitarist tune, learn, practice, or play?"**

If not, it should not be added merely for feature count.

