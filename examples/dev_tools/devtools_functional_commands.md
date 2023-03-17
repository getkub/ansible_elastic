### Tasks
```
GET _tasks/xx:1480130881?human
POST _tasks/yyyyyyyy:97978050/_cancel
GET _tasks?detailed
```


### Reindex
```
POST _reindex?wait_for_completion=false
{
    "source": {
        "index": "source-index"
    },
    "dest": {
        "index": "dest-index"
    },
    "script": {
        "source": "ctx._id = ctx._source.host.name"
    }
}
```


### Enrich Policy
```
PUT _enrich/policy/my-policy-name/_execute
```