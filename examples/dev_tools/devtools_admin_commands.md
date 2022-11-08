
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
GET _cat/indices?v&s=index&h=index
GET my-index-alias/_stats/store
GET /_cat/shards/my-index-alias
```

## Node checks
```
GET _cat/nodes?v&s=name
GET _nodes/stats
GET _nodes/stats/fs
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
PUT my-index-2021-10-20-00001/_alias/my-alias

## Rollover
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
