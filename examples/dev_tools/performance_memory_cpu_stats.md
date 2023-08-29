### Memory Heap
```
GET _cat/nodes?v=true&h=name,node*,heap*&s=heap.percent:desc
```


## HOT threads

```
GET /_nodes/hot_threads
```