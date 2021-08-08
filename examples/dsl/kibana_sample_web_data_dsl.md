```
GET kibana_sample_data_logs/_search
{
  "aggs": {
    "2": {
      "terms": {
        "field": "machine.os.keyword",
        "order": {
          "_count": "desc"
        },
        "size": 10
      }
    }
  },
  "size": 0,
  "query": {
    "bool": {
      "must": [],
      "filter": [
        {
          "range": {
            "timestamp": {
              "gte": "now-1d",
              "lte": "now"
            }
          }
        }
      ],
      "should": [],
      "must_not": []
    }
  }
  ```
