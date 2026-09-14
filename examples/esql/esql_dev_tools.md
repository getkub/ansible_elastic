
## Query using Filter and query
```
POST /_query?format=txt
{
  "filter": {
    "range": {
      "@timestamp": {
        "gte": "now-30m"
      }
    }
  },
  "query": """
    FROM filebeat-*
    | STATS count(*)
  """
}
```

## To reduce Timeout problem

```
POST /_query/async?format=csv
{
  "wait_for_completion_timeout": "240s",
  "filter": {
    "range": {
      "@timestamp": {
        "gte": "now-1M"
      }
    }
  },
  "query": """
    FROM *:filebeat-*
    | STATS count=COUNT(*) BY host.name
    | SORT count DESC
    | LIMIT 100
  """
}

```
