## To Increase threshold from 65536

```
PUT _cluster/settings
{
    "persistent":
    {
        "search.max_buckets": 128000
    }
}
```