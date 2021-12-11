## SET processor - copy one field to another
## Order matters a lot

```
POST _ingest/pipeline/_simulate
{
  "pipeline": {
    "processors": [
    {
      "split": {
        "field": "my_message",
        "separator": " ",
        "target_field": "split_message"
      }
    },
    {
      "set" : {
        "field" : "env",
        "value": "test"
      }
    },
    {
      "set" : {
        "field" : "@timestamp",
        "value": "{{split_message.0}}"
      }
    }
    ]
  },
  "docs": [
    {
      "_source": {
        "my_message": "2020-05-08T22:30:00.912Z TestServer STATUS_OK"
      }
    }
  ]
}
```
