# CLAUDE.md

# Guitar Companion — Claude Code Development Instructions

## 1. Role

When working in this repository, act as a:

**Senior Flutter Engineer + Senior Backend Engineer + Senior Next.js Engineer + Product-minded Software Architect.**

Prioritize:

* maintainability
* correctness
* testability
* accessibility
* performance
* offline capability
* clean architecture
* modularity
* security
* small incremental changes

Do not optimize for generating the largest amount of code.

Optimize for producing code that can be maintained for years.

---

# 2. Source of Truth

Before implementing any feature, read:

```text
PRD.md
DESIGN.md
CLAUDE.md
```

These documents define:

* product requirements
* architecture expectations
* UI/UX rules
* design system
* coding rules
* Premium behavior
* Admin requirements

If a request conflicts with these documents, explain the conflict before making a large architectural change.

---

# 3. Development Philosophy

Follow:

> **Understand → Plan → Implement → Test → Review**

Do not immediately modify files without first understanding the existing architecture.

Before implementing a significant feature:

1. Inspect related files.
2. Identify the existing architecture.
3. Identify reusable components.
4. Identify existing domain models.
5. Identify existing services.
6. Create a short implementation plan.
7. Implement the smallest coherent change.
8. Run formatting.
9. Run static analysis.
10. Run tests.
11. Review the diff.

---

# 4. Never Rewrite Working Architecture Without Reason

Do not:

* replace the architecture unnecessarily
* introduce a new state-management system without justification
* rewrite entire screens for small changes
* duplicate existing services
* create duplicate models
* create duplicate repositories
* introduce dependencies without need

Prefer extending existing abstractions.

---

# 5. Mobile Technology

Primary mobile framework:

**Flutter**

Target:

* iOS
* Android

Use Dart null safety.

Prefer stable Flutter/Dart APIs.

Avoid deprecated APIs.

---

# 6. Flutter Architecture

Use feature-oriented Clean Architecture.

Recommended:

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   ├── theme/
│   └── localization/
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── network/
│   ├── storage/
│   ├── audio/
│   ├── permissions/
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
│   ├── profile/
│   └── premium/
│
└── main.dart
```

Each feature should be independently understandable.

---

# 7. Feature Structure

Prefer:

```text
feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
└── presentation/
    ├── pages/
    ├── widgets/
    └── state/
```

Do not force every tiny utility into a use case if it adds meaningless abstraction.

Use judgment.

---

# 8. UI Rules

Widgets must primarily handle:

* layout
* presentation
* user interaction

Widgets must NOT contain:

* payment logic
* API authentication
* database queries
* complex music calculations
* entitlement rules
* tuner DSP algorithms

Move those responsibilities into appropriate layers.

---

# 9. State Management

Use one consistent state-management approach throughout the application.

Do not mix multiple state-management frameworks without an explicit architectural reason.

State should represent:

* loading
* success
* empty
* error

Avoid deeply nested mutable state.

---

# 10. Domain Logic

Music logic must be independent of Flutter UI.

Examples:

```text
Chord transposition
Capo calculations
Scale calculations
Fretboard calculations
Note calculations
Interval calculations
Tuning calculations
BPM calculations
```

These should be testable without Flutter widgets.

---

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

# 17. AI Features

AI should not replace deterministic music engines.

Use:

```text
Music Engine
     ↓
Structured Facts
     ↓
AI
     ↓
Explanation / Recommendation
```

Example:

The music engine determines:

```text
Key = A minor
Chord = Am7
```

The AI explains what scale may work over it.

Do not ask the LLM to perform calculations that should be deterministic.

---

# 18. AI Safety / Reliability

AI-generated musical advice must be treated as advisory.

Avoid claims such as:

> "This is definitely the correct chord."

unless the deterministic engine has established it.

AI output should not directly mutate important application state without validation.

---

# 19. Offline First

The following should work offline:

* tuner
* metronome
* chord library
* fretboard
* scales
* saved content
* practice timer

Use local persistence for appropriate data.

Synchronize when connectivity returns.

Never make basic guitar utilities dependent on an API call.

---

# 20. Networking

All network communication must go through a dedicated networking layer.

Do not make arbitrary HTTP requests directly from UI widgets.

Handle:

* timeout
* retry
* authentication expiration
* network unavailable
* server errors
* decoding errors

---

# 21. API Models

Separate:

```text
API DTO
Domain Entity
UI Model
```

when their responsibilities differ.

Do not expose raw backend models throughout the application.

---

# 22. Authentication

Authentication tokens must be securely stored.

Never:

* log access tokens
* commit secrets
* hardcode credentials
* store payment secrets in Flutter

---

# 23. Premium Entitlements

Premium state must ultimately come from the backend.

The client may cache entitlement state for UX, but must not be the authoritative source.

Never implement:

```text
if localStorage.isPremium
```

as the sole authorization mechanism.

---

# 24. MyanMyanPay

Payment architecture:

```text
Flutter
 ↓
Backend
 ↓
MyanMyanPay
 ↓
MMQR
 ↓
Payment App
 ↓
MyanMyanPay
 ↓
Webhook
 ↓
Backend Verification
 ↓
Entitlement
```

Never place:

* secret keys
* signing keys
* webhook secrets

in Flutter.

Never trust a client-side "payment successful" response as proof of payment.

---

# 25. Payment Orders

Every payment should have a unique internal order ID.

Maintain:

```text
order_id
user_id
plan_id
amount
currency
provider
provider_reference
status
created_at
updated_at
```

Payment state must be idempotent.

Repeated webhook delivery must not create duplicate Premium entitlements.

---

# 26. Database

Primary backend database:

**PostgreSQL**

Suggested conceptual entities:

```text
User
UserProfile
Role
Song
SongVersion
Chord
ChordVoicing
Scale
ScalePosition
Lesson
Exercise
PracticeSession
PracticeResult
Guitar
Recording
BackingTrack
PremiumPlan
Subscription
PaymentOrder
PaymentEvent
Favorite
Notification
Announcement
AIConversation
```

Do not create every table before the feature needs it.

---

# 27. Admin Security

Admin APIs must enforce authorization server-side.

Roles:

```text
SUPER_ADMIN
ADMIN
EDITOR
SUPPORT
```

Never rely on frontend route hiding for security.

---

# 28. Admin Portal

Admin application:

**Next.js + React + TypeScript**

The Admin Portal is a separate application.

It must not contain business-critical authorization logic that exists only in the browser.

---

# 29. Admin CMS

Content management must support:

* draft
* review
* published
* unpublished
* archived

Do not immediately expose newly created content to production users unless explicitly published.

---

# 30. Content Versioning

Song, lesson, chord, and exercise content should be designed to support future revisions.

Avoid destructive editing where historical information may matter.

---

# 31. Copyright

Do not scrape or redistribute copyrighted song lyrics/chord sheets without appropriate permission or licensing.

Content imported into the CMS must have a known legal source or permission status where required.

Admin should be able to record content rights metadata.

---

# 32. Search

Search must support:

* English
* Myanmar Unicode

Do not assume ASCII-only text.

Normalize text appropriately before search.

---

# 33. Localization

Never write:

```dart
Text("Open Tuner")
```

for production UI.

Use localization.

Example conceptual key:

```text
tuner.open
```

Both English and Myanmar translations must be supported.

---

# 34. Design System

Follow `DESIGN.md`.

Do not invent random:

* colors
* typography
* corner radii
* shadows
* button styles

when a design token already exists.

---

# 35. Brand

Core visual identity:

* Neo-Brutalism
* Minimalism
* precision
* monochrome
* Guitar Orange accent
* tactile interactions

Do not turn the application into a generic SaaS dashboard.

---

# 36. Accessibility

Every interactive control must have:

* semantic meaning
* sufficient touch target
* accessible label
* appropriate contrast

Support:

* VoiceOver
* TalkBack
* Dynamic Type
* reduced motion

---

# 37. Error Handling

Never silently swallow errors.

Use meaningful user-facing messages.

Technical details should go to logs, not user-facing messages.

Example:

Bad:

```text
Exception: SocketException...
```

Good:

```text
Couldn't connect.
Check your internet connection and try again.
```

---

# 38. Logging

Logs must never contain:

* passwords
* access tokens
* secret keys
* payment secrets
* sensitive personal data

Use structured logging.

Remove verbose debugging logs before release.

---

# 39. Testing

Every important domain calculation must have unit tests.

Examples:

* chord transpose
* capo calculation
* scale generation
* fretboard positions
* tuning calculations
* BPM
* Premium entitlement
* payment state transitions

---

# 40. Widget Testing

Test:

* loading
* success
* empty
* error
* Premium locked
* Premium unlocked
* localization
* accessibility labels

---

# 41. Integration Testing

Critical flows:

```text
Launch
 → Home
 → Tuner
 → Chord
 → Song
 → Practice
 → Premium
 → Payment
 → Entitlement
```

Payment integration should have a test environment.

Never use production payment credentials during development.

---

# 42. Dependency Management

Before adding a package:

1. Determine whether Flutter/Dart already provides the capability.
2. Check package maturity.
3. Check platform support.
4. Check maintenance activity.
5. Check license.
6. Check iOS/Android compatibility.
7. Consider package size.
8. Consider whether the dependency is actually necessary.

Do not add packages simply to save a few lines of code.

---

# 43. File Size

Avoid enormous files.

If a file becomes difficult to understand, split it by responsibility.

Especially avoid:

```text
home.dart
```

containing hundreds/thousands of lines.

---

# 44. Naming

Use clear names.

Prefer:

```text
ChordRepository
TunerEngine
PracticeSession
PremiumEntitlement
SongRepository
```

Avoid:

```text
DataManager
Helper
Utils2
CommonManager
ThingService
```

unless the abstraction is genuinely generic.

---

# 45. Git Discipline

Make focused changes.

Prefer commits such as:

```text
feat(tuner): add standard tuning engine
feat(chords): add chord domain model
feat(songs): add song transpose support
feat(premium): add entitlement service
fix(tuner): handle audio interruption
```

Avoid giant commits containing unrelated changes.

---

# 46. Claude Task Execution

When given a task:

## Step 1

Inspect the repository.

## Step 2

Read relevant documentation.

## Step 3

Identify impacted modules.

## Step 4

Explain the implementation plan briefly.

## Step 5

Implement.

## Step 6

Run:

```text
dart format
flutter analyze
flutter test
```

when applicable.

## Step 7

Review changed files.

## Step 8

Report:

* what changed
* files changed
* tests run
* remaining limitations

---

# 47. Do Not Fake Functionality

Never implement fake:

* payment success
* tuner accuracy
* chord recognition
* AI responses
* Premium entitlement
* backend authentication

If a feature is not fully implemented, create an explicit interface/stub and clearly mark the limitation.

---

# 48. Feature Flags

Use feature flags for unfinished high-risk features.

Examples:

```text
enable_ai_assistant
enable_chord_recognition
enable_backing_tracks
enable_recording
enable_community
```

Do not expose experimental functionality accidentally in production.

---

# 49. Performance

Avoid unnecessary:

* rebuilds
* network calls
* database queries
* audio processing
* animations

Use appropriate caching.

Do not optimize prematurely, but do not introduce obviously expensive architecture.

---

# 50. Battery

Audio tools must be particularly careful about battery consumption.

Stop microphone/audio processing when:

* tuner closes
* app goes background
* user explicitly stops audio feature

Handle lifecycle transitions correctly.

---

# 51. Security Principle

Assume:

> **The mobile client is untrusted.**

Therefore:

* validate server requests
* authorize every protected operation
* verify payments server-side
* verify Premium server-side
* never trust client-provided prices
* never trust client-provided roles

---

# 52. Admin Principle

Assume:

> **Admin actions are powerful and must be auditable.**

Log important actions:

* user suspension
* Premium changes
* song publication
* song deletion
* price changes
* content changes
* refunds/manual adjustments

---

# 53. No Premature Complexity

Do not implement:

* microservices
* event buses
* complex CQRS
* Kubernetes
* distributed caching

unless scale or requirements justify them.

Start modular.

Scale architecture when necessary.

---

# 54. MVP Priority

Always prioritize:

1. Tuner
2. Chords
3. Songs
4. Fretboard
5. Metronome
6. Practice
7. Basic Learning
8. Accounts
9. Admin CMS
10. Premium
11. Payment

Advanced AI/audio comes later.

---

# 55. Definition of Done

A feature is not complete merely because the UI exists.

A feature is complete when appropriate:

* UI
* domain logic
* persistence
* API
* loading state
* error state
* empty state
* localization
* accessibility
* tests
* analytics
* offline behavior

have been considered.

---

# 56. Final Rule

When uncertain, prefer:

**simple architecture + strong boundaries + testable domain logic + excellent UX**

over:

**large abstractions + excessive dependencies + clever code.**

