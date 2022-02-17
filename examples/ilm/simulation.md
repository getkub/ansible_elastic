```
PUT _ilm/policy/testpolicy1
{
  "policy": {
    "phases": {
      "hot": {                                
        "actions": {
          "rollover": {
            "max_docs": "2", 
            "max_age": "1d"
          }
        }
      }
    }
  }
}

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

PUT %3Ctestindex-%7Bnow%2Fd%7Byyyy-MM-dd%7D%7D-000001%3E
{
  "aliases": {
    "testindex": {
      "is_write_index": true
    }
  }
}

```

```
POST testindex/_bulk
  {"index":{}}
  {"transaction.duration.us": 100000, "transaction.name": "POST /test1", "service.name": "dev", "@timestamp": "2022-02-16T06:00:00Z"}
  {"index":{}}
  {"transaction.duration.us": 100000, "transaction.name": "POST /test1", "service.name": "dev", "@timestamp": "2022-02-16T06:00:00Z"}
```

Auxiliary queries:
```
POST testindex/_refresh
GET _cat/indices/testindex*?v
GET _cat/aliases/testindex?v
GET testindex/_ilm/explain
```

This is the result:
```
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   testindex-000001 OxrSH9-wQFqv1xJ3v2-vog   1   0          6            0     15.5kb         15.5kb
green  open   testindex-000002 sT7NUVBYT3-yg27jnpCALA   1   0          0            0       226b           226b
```

Coz of 10 minutes delay, put 6 documents before the ILM kicked in.
