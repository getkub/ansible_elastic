## Create a new dissect pipeline for messages

```
POST _ingest/pipeline/_simulate
{
  "pipeline": {
    "processors": [
    {
      "dissect": {
        "field": "my_message",
        "pattern": "%{@timestamp} [%{loglevel}] %{status}"
      }
    }
    ]
  },
  "docs": [
    {
      "_source": {
        "my_message": "2020-05-08T22:30:00.912Z [TestServer] STATUS_OK"
      }
    }
  ]
}
```

## key-value field example
```
POST _ingest/pipeline/_simulate
{
  "pipeline": {
    "processors": [
    {
      "dissect": {
        "field": "my_message",
        "pattern": "%{@timestamp} %{*field1}=%{&field1} %{*field2}=%{&field2}"
      }
    }
    ]
  },
  "docs": [
    {
      "_source": {
        "my_message": "2020-05-08T22:30:00.912Z host=host123 status=OK"
      }
    }
  ]
}
```
