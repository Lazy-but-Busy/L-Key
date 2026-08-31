# `songs` feature

Song library, viewer, transposer and capo assistant. Copyrighted lyrics may only ship where rights exist (CLAUDE.md §31).

**Specification:** PRD.md §19–22 · DESIGN.md §28–29

## Structure

```
songs/
├── data/           SongCatalog (bundled sample content), repository, favorites store
├── domain/         Song, ChordProParser, SongTranspose, SongSearch, SongRepository
└── presentation/   songs_page, song_detail_page, Riverpod providers
```

Music calculations live in `domain/` and import no Flutter (CLAUDE.md §10):
`SongTranspose` composes the existing `Chord.transpose`, and the one new music
engine this phase needed — capo position math — lives in `core/music/capo.dart`
rather than here, since it is not song-specific.

## Content

`SongCatalog` bundles a handful of public-domain traditionals and one
Myanmar-language sample built from the app's own tagline, standing in for the
Song CMS's bulk import (PRD.md §50) until Phase 09's content API exists. None
of it is real catalogue content — see the doc comment on `song_catalog.dart`
before adding anything real here.

## What exists

Library, search (English and Myanmar), favorites (`shared_preferences`,
mirroring `MetronomeSettingsStore`), song detail with chord-over-lyrics
rendering, transpose, capo display, tuning display, and font size. Auto-scroll
is state/hooks only — it does not move the page yet, and the UI says so
(CLAUDE.md §47).

Layer directories are created when there is code to put in them, because
empty folders are the "meaningless abstraction" CLAUDE.md §7 warns against.
