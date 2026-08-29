# DESIGN.md

# Guitar Companion — Design System

## 1. Design Vision

The Guitar Companion interface combines:

**Neo-Brutalism + Minimalism + Modern Music Technology.**

The visual identity is built around a contradiction:

> **Raw outside. Precise inside.**

The application should feel:

* confident
* musical
* technical
* tactile
* modern
* focused
* playful
* approachable
* premium without being luxurious

It should feel like a professional musician's tool that happens to have personality.

---

# 2. Core Design Principle

Every screen must prioritize:

```text
MUSIC
 ↓
FUNCTION
 ↓
CLARITY
 ↓
PERSONALITY
```

Do not sacrifice usability for visual style.

---

# 3. Brand Personality

The brand is:

### Confident

The product should feel reliable.

### Playful

Use subtle humor and satisfying interactions.

### Precise

Musical information must be visually exact.

### Raw

Use strong borders, shadows, and simple geometry.

### Human

Avoid making the product feel like laboratory software.

### Local

Myanmar language and local music culture should feel native.

---

# 4. Visual Style

Primary visual language:

* Neo-Brutalism
* Minimalism
* technical music interface
* tactile controls
* strong typography
* high contrast

Avoid:

* glassmorphism
* excessive gradients
* excessive rounded cards
* realistic guitar illustrations
* generic SaaS gradients
* neon cyberpunk styling
* excessive decorative music icons
* excessive shadows with blur

---

# 5. Color System

## Light Mode

### Background

```text
OFF_WHITE
#F0F0F0
```

### Primary

```text
BLACK
#000000
```

### Accent

```text
GUITAR_ORANGE
#FF4D00
```

### Secondary Greys

```text
GREY_100
#E5E5E5

GREY_200
#D0D0D0

GREY_300
#B5B5B5

GREY_400
#888888

GREY_500
#666666

GREY_600
#333333
```

---

# 6. Dark Mode

```text
BACKGROUND
#000000

SURFACE
#111111

SURFACE_2
#1C1C1C

PRIMARY_TEXT
#F0F0F0

SECONDARY_TEXT
#999999

BORDER
#F0F0F0

ACCENT
#FF4D00
```

---

# 7. Accent Usage

Orange represents:

* active
* playable
* important
* selected
* recording
* Premium
* progress
* energy

Do not use orange everywhere.

Orange loses meaning if every component uses it.

---

# 8. Typography

## Display

**Space Grotesk**

Use for:

* screen titles
* chord names
* tuner notes
* BPM
* large numbers
* hero headlines
* major section headings

---

## Body

**Hanken Grotesk**

Use for:

* descriptions
* explanations
* lessons
* song information
* settings
* onboarding

---

## Technical

**JetBrains Mono**

Use for:

* BPM
* Hz
* cents
* capo
* tuning
* timestamps
* fret numbers
* metadata
* technical labels

---

# 9. Typography Scale

Use a consistent scale.

Example:

```text
Display XL
48–64

Display
36–48

H1
32

H2
24

H3
20

Body Large
18

Body
16

Body Small
14

Label
12

Technical
12–16
```

Do not use typography size randomly.

---

# 10. Letter Spacing

Large display text should use tight spacing.

Technical labels can use slight tracking.

Example:

```text
STANDARD TUNING
```

Use uppercase + JetBrains Mono for compact technical labels.

---

# 11. Borders

Primary Neo-Brutalist border:

```text
2px solid BLACK
```

Important interactive components:

```text
3px solid BLACK
```

Dark mode:

```text
2px solid #F0F0F0
```

---

# 12. Border Radius

Default:

```text
0px
```

Allowed:

```text
4px
8px
```

Avoid excessive rounded cards.

Rounded corners should indicate a deliberate variation, not the default design language.

---

# 13. Shadows

Primary:

```text
4px 4px 0 #000000
```

Large interactive component:

```text
6px 6px 0 #000000
```

Small component:

```text
2px 2px 0 #000000
```

Never use blurred shadows as the primary design language.

---

# 14. Spacing

Use a consistent spacing system based on 4px.

```text
4
8
12
16
20
24
32
40
48
64
80
```

Mobile screen padding:

```text
16px
```

Large tablet/web layouts:

```text
24–40px
```

---

# 15. Buttons

Buttons should feel tactile.

Primary:

```text
Background: BLACK
Text: F0F0F0
Border: BLACK
Shadow: 4px 4px 0 BLACK
```

Accent:

```text
Background: #FF4D00
Text: BLACK
Border: BLACK
Shadow: 4px 4px 0 BLACK
```

Pressed:

Reduce shadow:

```text
1px 1px 0
```

and translate the button visually toward the shadow.

---

# 16. Inputs

Inputs should be:

* rectangular
* high contrast
* clearly labeled
* easy to tap

Example:

```text
┌─────────────────────────┐
│ SEARCH SONGS...         │
└─────────────────────────┘
```

Avoid floating-label complexity unless necessary.

---

# 17. Cards

Cards should represent meaningful units.

Examples:

* Song
* Chord
* Exercise
* Practice session
* Premium feature

Card structure:

```text
┌──────────────────────────┐
│ CATEGORY                 │
│                          │
│ TITLE                    │
│                          │
│ Metadata                 │
│                          │
│ ACTION                   │
└──────────────────────────┘
```

---

# 18. Icons

Use simple geometric icons.

Icons should not compete with typography.

Preferred:

* simple line icons
* consistent stroke width
* familiar symbols

Avoid decorative icon collections.

---

# 19. Mobile Navigation

Primary navigation:

```text
Home
Tools
Learn
Songs
Profile
```

Use a compact bottom navigation.

Active item:

* black or orange indicator
* stronger typography
* subtle tactile feedback

---

# 20. Home Screen

Hierarchy:

```text
Greeting
 ↓
Quick Tune
 ↓
Quick Tools
 ↓
Continue Practice
 ↓
Recent Songs
 ↓
Daily Challenge
```

The tuner should be one of the most prominent actions.

---

# 21. Tuner Screen

The tuner is one of the flagship screens.

Use an extremely focused layout.

Example:

```text
TUNER

          E

       82.41 Hz

   ───────●───────

     -02 cents

STANDARD
440 Hz
```

The detected note should be huge.

It is the note the microphone is **hearing**, not the string being tuned
towards. When the two differ — a string more than half a semitone out, or a
note that is not one of the six at all — the destination is named in words
beneath the meter rather than by a second cents figure:

```text
        F

      87.31 Hz

   ───────────●

     +100 cents

   TUNING TO E2
```

Beneath the meter, the tuning's strings are a list rather than a row, first
string on top, each carrying its number as well as its note:

```text
STRINGS

 1  E4
 2  B3
 3  G3
 4  D3
 5  A2
 6  E2      HEARING
```

Use:

**Space Grotesk**

Technical information:

**JetBrains Mono**

---

# 22. Tuner States

## Flat

Indicator moves left.

## Sharp

Indicator moves right.

## In Tune

Indicator locks centrally.

The in-tune state may introduce Guitar Orange.

Avoid using multiple unrelated colors.

---

# 23. Chord Screen

Chord detail should emphasize:

```text
C MAJOR
```

then:

* diagram
* finger positions
* notes
* alternative voicings
* play button

The chord name should be visually dominant.

---

# 24. Chord Diagram

Use:

* thick string lines
* clear fret lines
* large finger markers
* readable fret labels

Finger numbers should be clear.

Avoid overly decorative guitar illustrations.

---

# 25. Fretboard

The fretboard should look technical.

Use:

```text
E ───●──────●────
B ─────●─────────
G ───●──────●────
D ─────●─────────
A ───●───────────
E ───●──────●────
```

Each string carries its number as well as its note, counted the way a
guitarist counts — the first string is the highest-sounding:

```text
1 E ───●──────●────
2 B ─────●─────────
3 G ───●──────●────
4 D ─────●─────────
5 A ───●───────────
6 E ───●──────●────
```

Without it a six-string neck reads `E B G D A E` and the two Es are
indistinguishable.

Root notes should use Guitar Orange.

Other selected notes can use monochrome variations.

---

# 26. Scale Screen

Display:

```text
A MINOR PENTATONIC

Formula
1 b3 4 5 b7

FRETBOARD

[Interactive fretboard]

PRACTICE
80 BPM
```

---

# 27. Metronome

Large BPM:

```text
120 BPM
```

Use strong typography.

Beat indicator:

```text
● ○ ○ ○
```

Accent beat should be visually stronger.

---

# 28. Song Viewer

Song screen must prioritize readability.

Structure:

```text
SONG TITLE
ARTIST

KEY G
CAPO 2
BPM 92

[Transpose] [Auto Scroll]

VERSE

G          D
Lyrics...

Em         C
Lyrics...
```

Chords should visually stand apart from lyrics.

---

# 29. Song Controls

Persistent or easily accessible controls:

* transpose
* capo
* font size
* auto-scroll
* favorite

Don't force users to navigate through multiple screens during performance.

---

# 30. Practice Screen

Example:

```text
TODAY'S PRACTICE

30:00

CHORD SWITCHING
10 min

PENTATONIC
10 min

STRUMMING
10 min

[ START ]
```

Use progress rather than excessive decoration.

---

# 31. Progress

Use:

* simple bars
* large numbers
* small charts
* streak indicators

Avoid dashboard overload.

---

# 32. Premium UI

Premium should remain within the design system.

Do not use:

* gold
* fake luxury gradients
* excessive glow
* glass cards

Use:

```text
PRO
```

and Guitar Orange.

Premium should communicate:

> **More power.**

---

# 33. Premium Paywall

Structure:

```text
GO PRO

Unlock your complete guitar toolkit.

✓ Advanced tuner
✓ Custom tunings
✓ Advanced chords
✓ CAGED
✓ Scale trainer
✓ Practice analytics
✓ AI Guitar Coach

MONTHLY
YEARLY ⭐

[ CONTINUE ]
```

Keep the payment explanation clear.

---

# 34. Payment UI

Payment screen:

```text
GUITAR PRO

Yearly
25,000 MMK

Select Payment

[ MMQR ]

Scan with
KBZPay / AYA Pay / WavePay / ...

[ SHOW QR ]
```

If dynamic QR is generated, clearly show:

* order amount
* expiration
* payment status
* cancel option

Never claim success before backend verification.

---

# 35. Payment Status

### Pending

```text
WAITING FOR PAYMENT

Complete payment in your
selected mobile wallet.
```

### Success

```text
PAYMENT COMPLETE

PRO IS ACTIVE.
```

### Failed

```text
PAYMENT FAILED

Try again.
```

---

# 36. Myanmar Localization

Myanmar text must receive equal design consideration.

Test:

* font size
* line wrapping
* button height
* navigation labels
* long song titles
* mixed Myanmar + English

Do not simply translate English and assume the layout remains correct.

---

# 37. Empty States

Empty states should have personality.

Examples:

```text
NO FAVORITES YET.

Save something for later.
```

Recordings:

```text
NO RECORDINGS YET.

Your first questionable solo
belongs here.
```

Keep humor subtle.

---

# 38. Error States

Be concise.

Example:

```text
COULDN'T LOAD SONGS.

Check your connection
and try again.

[ RETRY ]
```

---

# 39. Loading States

Prefer skeletons or meaningful motion.

For audio:

```text
LISTENING...

~~~~╱╲~~~~╱╲~~~~
```

Avoid generic infinite spinners when a more meaningful state is possible.

---

# 40. Haptics

Use haptics for:

* tuner lock
* metronome beat where appropriate
* button press
* successful action
* chord trainer answer

Do not overuse haptics.

---

# 41. Motion

Animations should be:

* short
* functional
* tactile
* predictable

Use motion to communicate:

* state
* progress
* interaction

Never animate merely because animation is possible.

---

# 42. Accessibility

All components must support:

* VoiceOver
* TalkBack
* Dynamic Type
* semantic labels
* large touch targets
* reduced motion

Do not encode meaning through color alone.

---

# 43. Responsive Mobile Design

Support:

* small phones
* standard phones
* large phones
* tablets

Do not hardcode screen dimensions.

---

# 44. Admin Portal Design

The Admin Portal uses the same visual language but is more information-dense.

The mobile app is:

> **Tool-first**

The Admin Portal is:

> **Data-first**

---

# 45. Admin Layout

Desktop:

```text
┌────────────┬──────────────────────────────┐
│            │                              │
│ Sidebar    │ Header                       │
│            │                              │
│ Dashboard  │ Content                      │
│ Users      │                              │
│ Songs      │                              │
│ Chords     │                              │
│ Scales     │                              │
│ Lessons    │                              │
│ Exercises  │                              │
│ Payments   │                              │
│ Premium    │                              │
│ Analytics  │                              │
│ Settings   │                              │
│            │                              │
└────────────┴──────────────────────────────┘
```

---

# 46. Admin Sidebar

Sections:

```text
Dashboard

CONTENT
Songs
Chords
Scales
Lessons
Exercises
Backing Tracks

USERS
Users
Subscriptions

BUSINESS
Payments
Premium Plans

ANALYTICS
Analytics

SYSTEM
Announcements
Settings
```

---

# 47. Admin Dashboard

Display:

```text
TOTAL USERS
12,542

ACTIVE TODAY
2,341

PREMIUM
1,203

SONGS
4,892
```

Then:

* user growth
* Premium growth
* revenue
* popular songs
* popular tools
* recent payments

---

# 48. Admin Tables

Tables should prioritize:

* readability
* sorting
* filtering
* pagination
* bulk actions

Use strong black borders.

Example:

```text
┌────┬────────────┬─────────┬────────┐
│ ID │ USER       │ PLAN    │ STATUS │
├────┼────────────┼─────────┼────────┤
│ 01 │ User       │ PRO     │ ACTIVE │
└────┴────────────┴─────────┴────────┘
```

---

# 49. Admin Forms

Forms should be structured.

Example:

```text
SONG INFORMATION

Title
[________________]

Artist
[________________]

Language
[ Myanmar ▼ ]

Genre
[ Pop ▼ ]

Key
[ G ▼ ]

Capo
[ 2 ]

Difficulty
[ Beginner ▼ ]
```

---

# 50. Content Editor

Content editors need:

* draft
* preview
* save
* publish
* unpublish
* archive

Publishing should require explicit action.

---

# 51. Admin Song Editor

Sections:

```text
Basic Information
Music Information
Chord Content
Lyrics
Media
SEO
Rights
Publishing
```

Rights section:

```text
Content Rights
[________________]

Source
[________________]

Permission Status
[ Licensed / Owned / Permission Required ]
```

---

# 52. Admin Chord Editor

Show:

```text
Chord Name
Formula
Notes
Voicing
Fretboard Preview
Audio
```

Provide live preview.

---

# 53. Admin Scale Editor

Show:

```text
Scale Name
Formula
Intervals
Notes
Fretboard Positions
Difficulty
Premium
```

---

# 54. Admin Lesson Editor

Use:

```text
Course
 ↓
Module
 ↓
Lesson
 ↓
Exercise
```

Allow preview before publishing.

---

# 55. Admin Premium Management

Display plans:

```text
MONTHLY
3 MONTHS
YEARLY
LIFETIME
```

Admin can change:

* name
* price
* duration
* description
* features
* availability

All pricing changes should be audited.

---

# 56. Admin Payment Screen

Display:

* order ID
* user
* plan
* amount
* payment provider
* provider reference
* status
* created time
* completed time
* webhook state

Statuses use typography and icons in addition to color.

---

# 57. Admin Analytics

Charts should be minimal.

Primary metrics:

* DAU
* MAU
* retention
* practice minutes
* tuner sessions
* song views
* Premium conversions
* revenue

Do not overload dashboards with decorative charts.

---

# 58. Admin Responsive Design

Primary target:

**Desktop**

Minimum supported layout should remain usable on tablets.

Mobile Admin is not the primary experience.

---

# 59. Landing Website

The landing website should use the same brand system.

Hero:

```text
YOUR GUITAR.
YOUR MUSIC.
ANYWHERE.

Tune. Learn. Practice. Play.

[ DOWNLOAD APP ]
[ EXPLORE FEATURES ]
```

---

# 60. Website Sections

Recommended:

1. Hero
2. Tuner
3. Chords
4. Songs
5. Fretboard
6. Practice
7. Learning
8. Premium
9. Myanmar-first positioning
10. Screenshots
11. FAQ
12. Download CTA
13. Footer

---

# 61. Website SEO

Use clean content pages such as:

```text
/guitar-tuner
/guitar-chords
/guitar-scales
/guitar-chord/c
/guitar-chord/am
/guitar-scales/a-minor
/myanmar-guitar-chords
```

Only publish song/lyric content where legally permitted.

---

# 62. Image Direction

Avoid generic stock photography.

Prefer:

* close guitar details
* hands playing guitar
* fretboard photography
* abstract instrument textures
* monochrome photography
* orange accent overlays

Images should support the product rather than dominate it.

---

# 63. Mobile UI Generation Rules for Claude

When Claude generates Flutter UI:

1. Read `PRD.md`.
2. Read this `DESIGN.md`.
3. Reuse design tokens.
4. Build reusable components.
5. Support light/dark mode.
6. Support Myanmar text.
7. Support accessibility.
8. Support loading/error/empty states.
9. Do not hardcode screen sizes.
10. Do not invent new visual styles.

---

# 64. Admin UI Generation Rules for Claude

When Claude generates Admin UI:

1. Use the same typography.
2. Use the same monochrome/orange palette.
3. Use stronger information density.
4. Use tables where appropriate.
5. Use cards only for meaningful summaries.
6. Use clear forms.
7. Support filtering and pagination.
8. Provide loading/error/empty states.
9. Keep destructive actions visually clear.
10. Never rely on color alone for status.

---

# 65. Component Naming

Mobile:

```text
AppButton
AppCard
AppTextField
AppChip
AppSectionHeader
AppIconButton
ChordDiagram
Fretboard
TunerMeter
BpmDisplay
PracticeProgress
SongCard
PremiumBadge
```

Admin:

```text
AdminSidebar
AdminHeader
StatCard
DataTable
FilterBar
ContentEditor
StatusBadge
ConfirmDialog
EmptyState
```

---

# 66. Design Tokens

All colors, typography, spacing, radius, borders, and shadows should be represented as reusable design tokens.

Do not scatter:

```text
Color(0xFFFF4D00)
```

throughout hundreds of widgets.

Create centralized tokens.

---

# 67. Design Consistency

A component should have one visual definition.

Do not create:

```text
PrimaryButton
PrimaryButton2
OrangeButton
SpecialButton
NewButton
```

because each screen has slightly different requirements.

Extend the component API instead.

---

# 68. Dark Mode Rules

Dark mode should not simply invert the entire UI.

Maintain:

* black background
* dark surfaces
* light typography
* controlled borders
* orange action color

Test every major screen independently.

---

# 69. Premium Visual Rule

Premium is not:

> Gold + gradient + glow.

Premium is:

> More capability + more depth + better tools.

Keep the same design language.

---

# 70. Final Visual Principle

The application should look like:

> **A precision musical instrument designed by a modern software company.**

Not:

> A generic SaaS application with guitar icons.

Not:

> An old-school guitar lesson website.

Not:

> A flashy music production application.

The desired visual balance is:

```text
70% Minimal / Precise
20% Neo-Brutalist / Raw
10% Playful / Musical
```

---

# 71. Final Design Rule

Before adding any UI element ask:

1. Does it help the guitarist?
2. Is it immediately understandable?
3. Does it follow the design system?
4. Does it work in Myanmar?
5. Does it work in dark mode?
6. Does it remain accessible?
7. Does it feel tactile?
8. Is the orange accent actually necessary?

If the answer is no, remove it.

