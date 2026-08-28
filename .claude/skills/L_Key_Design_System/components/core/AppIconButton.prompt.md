Icon-only control for top-bar actions, transpose steppers and inline play buttons.

```jsx
<AppIconButton label="Settings" variant="plain"><img src="assets/icons/settings.svg" width={20} height={20} alt="" /></AppIconButton>
<AppIconButton label="Play chord" variant="circle" size={48}>▶</AppIconButton>
<AppIconButton label="Transpose down" variant="solid" size={32}>–</AppIconButton>
```

`plain` carries the 4px hard shadow (mobile top bar); `ring`/`solid` are flat with an inset 2px black ring (admin, dense controls). Keep 44px minimum hit area on touch surfaces even when the visual box is smaller.
