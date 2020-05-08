## Sample of "painless" processor script

```
POST _ingest/pipeline/_simulate
{
  "pipeline": {
    "processors": [
    {
      "script": {
        "lang": "painless",
        "source": "ctx['new_value'] = ctx['current_value'] + 1"
      }
    }
    ]
  },
  "docs": [
    {
      "_source": {
        "current_value": 2
      }
    }
  ]
}
```

## To call the script in modular fashion
```
POST _scripts/my_script
{
  "script" : {
    "lang" : "painless",
    "source": "ctx['new_value'] = ctx['current_value'] + params.value"    
  }
}
```

## To call the script pipeline
```
PUT _ingest/pipeline/my_script_pipeline
{
    "processors": [
    {
      "script": {
        "id" : "my_script",
        "params" : {
          "value": 1
        }
      }
    }
    ]
}
```

## Some sample data
```
DELETE test_docs

POST test_docs/_doc/
{
  "current_value" : 23
}

GET test_docs/_search
```

## Trigger script
```
POST test_docs/_update_by_query?pipeline=my_script_pipeline
{
  "query" : {
    "range" : {
      "current_value" : {
        "gt": 25
      }
    }
  }
}

GET test_docs/_search
```
