
##  This should list you all the alerts [aggregated numbers]
```
POST kbn:/api/detection_engine/signals/search
{
    "query": {
      "bool": {
        "filter": [
          { "range": { "@timestamp": { "gte": "now-24h", "lte": "now" } } }
        ]
      }
    },
    "aggs": {
      "by_status": { "terms": { "field": "kibana.alert.status", "size": 10 } }
    },
    "size": 10,
    "track_total_hits": false
}
```

##  Find the alert's uuid based on their status as per output of last api
```
POST kbn:/api/detection_engine/signals/search
{
    "query": {
      "bool": {
        "filter": [
          { "terms": { "kibana.alert.status": ["active","acknowledged"] } },
          { "range": { "@timestamp": { "gte": "now-24h" } } }
        ]
      }
    },
    "_source": false,
    "fields": ["kibana.alert.uuid","kibana.alert.rule.name","@timestamp"],
    "size": 100
  }
```
