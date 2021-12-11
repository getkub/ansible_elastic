## GEOIP processors

URL: https://www.elastic.co/guide/en/elasticsearch/reference/current/geoip-processor.html
```
PUT _ingest/pipeline/geoip
{
  "description" : "Add geoip info",
  "processors" : [
    {
      "geoip" : {
        "field" : "ip"
      }
    }
  ]
}

PUT test_docs/_doc/my_id?pipeline=geoip
{
  "ip": "8.8.8.8"
}

GET test_docs/_doc/my_id
```
