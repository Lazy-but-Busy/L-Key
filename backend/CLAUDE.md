# CLAUDE.md — backend/

Payment-order and database rules, moved out of the root `CLAUDE.md` so they load only
when working under `backend/`. Section numbers are unchanged: an existing
`CLAUDE.md §26` citation still refers to §26 below.

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
