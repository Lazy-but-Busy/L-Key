The primary tactile action button — use for any committed action; `accent` only when the action is *the* action on screen (DESIGN.md §7: orange loses meaning if everything is orange).

```jsx
<AppButton variant="accent" size="hero" icon={<img src="assets/icons/stack-pin.svg" width={11} height={14} alt="" />}>Play Chord</AppButton>
<AppButton variant="primary" size="lg" block iconPosition="right">Resume</AppButton>
<AppButton variant="secondary" size="sm">30D</AppButton>
```

Variants: `primary` (black / white text), `accent` (Guitar Orange / black text), `secondary` (white / black text), `ghost` (inset ring only).
Sizes map to real heights in the file: `sm` 26px mono, `md` 48px mono tracked, `lg` 52px Space Grotesk 18, `xl` 56px marketing CTA, `hero` 61px Space Grotesk 24.
Pressed state translates 3px toward the shadow and drops it to 1px — never add a blurred shadow or a hover lift.
