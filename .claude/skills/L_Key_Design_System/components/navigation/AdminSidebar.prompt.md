The Admin Portal's persistent rail: wordmark, admin identity card, section list, logout.

```jsx
<AdminSidebar user={{name:"Admin User", role:"Super Admin", avatar:"assets/images/admin-avatar.jpg"}}
  items={[{label:"Dashboard"},{label:"Songs"},{label:"Chords"},{label:"Users"},{label:"Payments"}]}
  activeIndex={0}
  footer={<AppButton variant="primary" size="md" block style={{boxShadow:"var(--lk-ring),var(--lk-shadow-accent)"}}>System Logout</AppButton>} />
```

Active row: Guitar Orange with a 2px ring plus a 4px hard shadow. Labels are Hanken Grotesk 700 16 — the one place body type is used for navigation.
