Header row for every Admin Portal view.

```jsx
<AdminHeader size="lg" title="Song Database" subtitle="Manage library, metadata, and publication status."
  actions={<><AppTextField placeholder="Search ID, Title, Artist..." /><AppButton size="md">Add new song</AppButton></>} />
```

Title uppercase, subtitle mono in `--lk-grey-500`, actions aligned to the title baseline.
