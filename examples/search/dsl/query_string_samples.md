```
{
  "query": {
    "bool": {
      "filter": [ 
        { "query_string":  { "query": "(test)", "default_field": "host.hostname" }},
        { "query_string":  { "query": "(new york city) OR (big apple)", "default_field": "site" }},
        { "range": { "@timestamp": { "gte": "2022-03-18T00:50:20" }}}
      ]
    }
  }
}

```
