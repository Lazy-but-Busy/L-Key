Zero-radius surface with a hard offset shadow — the base container for songs, chords, sessions and stats.

```jsx
<AppCard label="FOCUS: PENTATONIC SPEED" title="Daily Session">…</AppCard>
<AppCard variant="ring" tone="accent" padding={24}>…</AppCard>
```

Mobile cards use `variant="shadow"`; admin and song-viewer cards use `variant="ring"` (inset 2px ring + 4px shadow). `tone="accent"` is reserved for the single most important card on a screen (Quick Tune on Home).
