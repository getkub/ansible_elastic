```
GET my_index/_search
{
  "runtime_mappings": {
    "day_of_week": {
      "type": "keyword",
      "script": """
        emit(doc['@timestamp'].value.dayOfWeekEnum
          .getDisplayName(TextStyle.FULL, Locale.ROOT))
      """
    }
  },
  "size": 0,
  "aggs": {
    "my_buckets": {
      "composite": {
        "sources": [
          {"dow": {"terms": { "field": "day_of_week" }}},
          {"hostname": {"terms": { "field": "host.hostname" }}}
        ]
      }
    }
  }
}
```
