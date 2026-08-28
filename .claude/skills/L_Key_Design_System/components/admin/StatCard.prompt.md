Dashboard KPI tile. Four across on desktop; ornaments alternate circle / rotated square as in the source.

```jsx
<StatCard label="Total users" value="12,542" delta="+14.2%" icon={<img src="assets/icons/users.svg" width={22} height={16} alt="" />} />
<StatCard label="Songs" value="4,892" note="+24 this week" ornament="square" />
```

The delta arrow and text are the only orange on the dashboard — don't tint the whole card.
