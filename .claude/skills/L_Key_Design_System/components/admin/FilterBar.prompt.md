Filters and range toggles for admin list and analytics views.

```jsx
<FilterBar
  groups={[{key:"range",label:"Range",options:["7D","30D","All"]},{key:"status",label:"Status",options:["All","Published","Draft"]}]}
  activeValues={{range:"7D",status:"All"}} onChange={setFilter}
  trailing={<AppButton size="md">Add new song</AppButton>} />
```

Segments share one 2px ring; the active segment fills black with white mono type.
