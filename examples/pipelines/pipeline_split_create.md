## Create a new split pipeline for messages

```
PUT _ingest/pipeline/my-split-pipeline
{
  "description": "Splits message fields - Space delimited",
  "version" : 123,
  "processors": [
    {
      "split": {
        "field": "message",
        "separator": " "
      }
    }
  ]
}
```

### Verify it
```
GET _ingest/pipeline/my-split-pipeline
```
