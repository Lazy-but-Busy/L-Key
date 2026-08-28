The structured editor panel behind every admin content type.

```jsx
<ContentEditor title="Song Information" status={<StatusBadge status="draft" />}
  sections={[{title:"Basic information", children:<><AppTextField label="Title" /><AppTextField label="Artist" /></>}]}
  actions={<><AppButton size="md" variant="secondary">Save draft</AppButton><AppButton size="md">Publish</AppButton></>} />
```

Sections are captioned in uppercase mono, separated by 2px black rules. Never auto-publish — publish is always its own button (DESIGN.md §50).
