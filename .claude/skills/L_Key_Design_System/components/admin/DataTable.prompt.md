The admin list view. Header band is `--lk-fill-thead`; the container carries a 4px hard shadow, never a rounded corner.

```jsx
<DataTable
  columns={[{key:"id",label:"ID",width:96,strong:true},{key:"title",label:"Title",font:"body"},{key:"status",label:"Status",width:136}]}
  rows={[{id:"#8021",title:"Neon Skyline",status:<StatusBadge status="published" />}]}
  footerNote="Showing 1 to 4 of 42 entries"
  pagination={<><AppButton size="sm" variant="secondary">1</AppButton><AppButton size="sm" variant="secondary">Next ›</AppButton></>} />
```

Use `dense gridded` for the dashboard's Recent Payments panel.
