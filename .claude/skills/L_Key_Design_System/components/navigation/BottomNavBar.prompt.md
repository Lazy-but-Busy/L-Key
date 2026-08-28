Fixed 71px tab bar with the five app sections. The active tab becomes a 64px Guitar Orange block with a 2px hard shadow — no underline indicators, no icon-only tabs.

```jsx
<BottomNavBar activeIndex={0} onSelect={setTab} items={[
  {label:"Home", icon:<HomeGlyph/>}, {label:"Tools"}, {label:"Learn"}, {label:"Songs"}, {label:"Profile"}]} />
```
