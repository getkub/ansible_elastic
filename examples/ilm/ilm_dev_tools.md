### ILM admin api commands
```
GET _cat/snapshots/
GET _snapshot/my-cold-bucket/*
GET _snapshot/my-cold-bucket/*my-index*
GET _snapshot/my-cold-bucket/*my-ilm-policy*
```

```
GET _ilm/policy/my-ilm-policy
```

```
POST _ilm/move/.ds-my-datastream-name-2023.11.10-000001
```