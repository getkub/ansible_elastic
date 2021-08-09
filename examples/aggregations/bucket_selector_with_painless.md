```
{
    "aggs": {
      "os_aggs": {
        "terms": {
          "field": "machine.os.keyword"
        },
        "aggs": {
          "time_aggs": {
            "date_histogram": {
              "field": "timestamp",
              "calendar_interval": "1d"
            }
          },
          "time_max": {
            "max": {
              "field": "@timestamp"
            }
          },
          "ios_ratio": {
            "bucket_selector": {
              "buckets_path": {
                "time_max": "time_max"
              },
              "script": """
              long timestampNow = new Date().getTime();
              Instant instant = Instant.ofEpochMilli(timestampNow);
              ZonedDateTime zdt = ZonedDateTime.ofInstant(instant, ZoneId.of('Z'));
              long yesterday = zdt.minusDays(1).with(LocalTime.MIN).toEpochMilli();
              params.time_max > yesterday
                
              """
            }
          }
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
                "gte": "now-2d/d",
                "lte": "now/d"
              }
            }
          }
        ],
        "should": [],
        "must_not": []
      }
    }
  }
  ```