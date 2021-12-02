### Find any hung nodes
```
GET _cat/thread_pool
```
### translog
```
GET /_cat/recovery/my-own-alias?format=json
```

### Exclude node from indexing
```
PUT _cluster/settings
{
  "transient":  {
      "cluster.routing.allocation.exclude._ip" : "10.10.20.30"
    }
}
```

### Data allocation details
`GET cat/allocation?explain`
