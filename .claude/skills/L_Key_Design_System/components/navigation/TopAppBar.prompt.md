Every L Key mobile screen starts with this bar: menu left, wordmark centre, settings right.

```jsx
<TopAppBar
  leading={<AppIconButton label="Menu" variant="plain" size={34}>…</AppIconButton>}
  trailing={<AppIconButton label="Settings" variant="plain"><img src="assets/icons/settings.svg" width={20} height={20} alt="" /></AppIconButton>} />
```

There is no logo file in the source — the wordmark is always set in type (Space Grotesk 36 / -1.8px tracking).
