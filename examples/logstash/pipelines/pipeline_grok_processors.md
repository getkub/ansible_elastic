## GROK processor

URL: https://streamsets.com/documentation/datacollector/latest/help/datacollector/UserGuide/Apx-GrokPatterns/GrokPatterns_title.html
```
POST _ingest/pipeline/_simulate
{
  "pipeline": {
    "processors": [
    {
      "grok": {
        "field": "my_message",
        "patterns": ["""%{TIMESTAMP_ISO8601:@timestamp} %{LOGLEVEL:loglevel} %{IP:client} %{URI:my_uri} \[%{WORD:status}\] %{NUMBER:duration}"""]
      }
    }
    ]
  },
  "docs": [
    {
      "_index": "test_docs",
      "_id": "id",
      "_source": {
        "my_message": "2020-05-08T22:30:00.912Z INFO 192.168.2.1 https://example.com/path/resource.txt#fragment [STATUS_OK] 10.42"
      }
    }
  ]
}
```
