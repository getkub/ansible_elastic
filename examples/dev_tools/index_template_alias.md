
## Create template first
```
PUT _index_template/testindextemplate
{
  "index_patterns": ["testindex-*"],                 
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0,
      "index.lifecycle.name": "testpolicy1",      
      "index.lifecycle.rollover_alias": "testindex"    
    }
  }
}
```

## then associate alias
```
PUT %3Ctestindex-%7Bnow%2Fd%7Byyyy-MM-dd%7D%7D-000001%3E
{
  "aliases": {
    "testindex": {
      "is_write_index": true
    }
  }
}
```
