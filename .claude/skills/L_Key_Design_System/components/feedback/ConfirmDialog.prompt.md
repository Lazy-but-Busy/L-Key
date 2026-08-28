Confirms destructive admin actions. 6px hard shadow, no blur, no rounded corners.

```jsx
<ConfirmDialog open={open} title="Delete song?" body="“Neon Skyline” and its chord content will be removed from the library."
  confirmLabel="Delete" onConfirm={remove} onCancel={close} />
```

Destructive actions read in `--lk-danger` (#BA1A1A) — the same red the file uses for muted strings and delete icons.
