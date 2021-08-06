```
POST _watcher/watch/_execute
{
  "watch" : {
    "trigger": {
      "schedule": {
        "daily": {
          "at": [
            "03:00"
          ]
        }
      }
    },
    "input": {
      "search": {
                "request": {
                  "search_type": "query_then_fetch",
                  "indices": [
                    "my_index"
                  ],
                  "rest_total_hits_as_int": true,
                  "body": {
                    "size": 0,
                    "query": {
                      "bool": {
                        "filter": [
                          {
                            "term": {
                                "event.dataset": "my_dataset"
                            }
                          },              
                          {
                            "range": {
                              "@timestamp": {
                                "gte": "now-2d/d",
                                "lte": "now-1d/d"
                              }
                            }
                          }
                        ]
                      }
                    },
             "aggs": {
              "host_name": {
              "terms": {
                "field": "my_host.keyword",
                "size": 1
              },
              "aggs": {
                "date": {
                "date_histogram": {
                  "field": "@timestamp",
                  "calendar_interval": "1d"
                }
                }
              }
              }
            }
          }
        }
      }
    },
    "actions": {
      "my-logging-action": {
        "logging": {
          "text": "{{ctx.payload}}"
        }
      }
    },
    "metadata": {
      "xpack": {
        "type": "json"
      },
      "name": "my_watcher"
    }
  }
}
```
