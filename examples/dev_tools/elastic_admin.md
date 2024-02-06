## Kick the cluster
```
POST /_cluster/reroute?retry_failed=true
```


## Nodes & hot threads
```
GET _nodes/hot_threads
GET _nodes/my-node*/hot_threads

GET _cat/nodes?v&s=cpu:desc
GET _tasks?actions=*search&detailed
```
