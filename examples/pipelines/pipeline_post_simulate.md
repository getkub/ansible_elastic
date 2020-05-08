## Post using simulate to pipeline

URL: https://www.elastic.co/guide/en/elasticsearch/reference/current/simulate-pipeline-api.html

```
POST _ingest/pipeline/my-split-pipeline/_simulate
{

  "docs": [
    {
      "_source": {
        "message": "2020-05-08T22:30:00.912Z TestServer STATUS_OK"
      }
    }
  ]
}
```
