
## Cluster health and fixing yellow clusters
```
GET _cluster/health/
GET _cat/shards/my-index-*
GET _cluster/allocation/explain?pretty
GET _cat/allocation?v&s=shards
GET _cat/shards?v&s=node:asc,store:desc
GET _tasks

# https://stackoverflow.com/questions/34578596/including-and-excluding-indexes-in-elasticsearch-query
GET /%2Bindex1,-index2/type1,type2/_search?q=programming
GET _cat/nodes?v&h=name,ram*,heap.percent,heap.max,cpu&s=ram.percent:desc

```

## Indices checks, stats, size
```
GET _cat/indices?v&s=index&h=index,status,docs.count,store.size&s=store.size:desc
GET my-index-alias/_stats/store
GET /_cat/shards/my-index-alias
GET _cat/snapshots
GET _snapshot/my_snapshot_mount/*snapshot_name*/

# Data move between tiers
GET _cat/recovery?active_only=true&v&h=index,shard,source_node,target_node,bytes_percent,time
```

## Node checks
```
GET _cat/nodes?v&s=name
GET _nodes/stats
GET _nodes/stats/fs

# https://www.elastic.co/guide/en/elasticsearch/reference/current/common-options.html#common-options-response-filtering
GET /_nodes/stats?filter_path=es-hot*
```

## Alias checks and deletion
```
GET _cat/aliases
GET _alias
GET _alias/my-index-alias*

GET my-index-alias/_alias
GET my-index-alias/_search
DELETE my-index-2021-10-20-00001/_alias/my-index-alias

## Add index to alias

## PUT my-index-2021-10-20-00001/_alias/my-alias
## Better way is
POST _aliases
{
  "actions": [
    {
      "add": {
        "index": "my-index-2022-10-15-000001",
        "alias": "my-index-alias",
        "is_write_index": "false"
      }
    }
  ]
}

## Check if ALL is OK
GET my-index-2022-10-15-000001/_alias

## Remove any OLD indices in case it shows duplicate
POST _aliases
{
  "actions": [
    {
      "remove": {
        "index": "my-index-2022-10-15-000001",
        "alias": "my-index-2022-10-15-000001"
      }
    }
  ]
}
```

## Rollover
```
POST /my-index-alias/_rollover/
```

## Template checks
```
GET _cat/templates
GET _index_template
GET my-index/_mapping
```

## Rollup Jobs
```
GET _rollup/job/my-rollup-job
```
