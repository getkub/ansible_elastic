
## Cluster health and fixing yellow clusters
```
GET _cluster/health/
GET _cat/shards/my-index-*
GET _cluster/allocation/explain?pretty
GET _cat/allocation?v&s=shards
GET _cat/shards?v&s=node:asc,store:desc
GET _tasks
```

## Indices checks
```
GET _cat/indices?v&s=index&h=index
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
