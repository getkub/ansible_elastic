
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
