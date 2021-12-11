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
        "patterns": ["""%{TIMESTAMP_ISO8601:@timestamp} %{LOGLEVEL:loglevel} %{IP:client} \[%{WORD:status}\] %{NUMBER:duration} %{CUSTOM_SECOND_LINE:mysecondline}"""],
        "pattern_definitions" : {
          "CUSTOM_SECOND_LINE" : "(.|\n)*"
        }
      }
    }
    ]
  },
  "docs": [
    {
      "_index": "test_docs",
      "_id": "id",
      "_source": {
        "my_message": "2020-05-08T22:30:00.912Z INFO 192.168.2.1 [STATUS_OK] 10.42 \n second line"
      }
    }
  ]
}
```
