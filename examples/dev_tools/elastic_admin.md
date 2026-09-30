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

Here it is formatted as clean Markdown with headings, descriptions, and fenced code blocks:

 Elasticsearch Cluster Troubleshooting Commands

# Elasticsearch Cluster Troubleshooting Commands

 ## 1\. Cluster Overview — Start Here

 ### Overall cluster status

 Check overall cluster health, unassigned shards, and pending tasks.

```
GET _cluster/health
```

 ### Disk and shard count per node

 Sorted by node role to spot uneven allocation or full disks.

```
GET _cat/allocation?v&human&s=node.role
```

 ### Node resources and load

 Node list with CPU, load averages, and roles. Useful for quickly identifying hot tiers/nodes.

```
GET _cat/nodes?v=true&h=name,ip,cpu,load_1m,load_5m,load_15m,node.role&s=node.role
```

 ### Heap and RAM pressure

 Check JVM heap and system RAM usage per node. Consistently high heap usage (roughly \>75–85%) can indicate memory pressure.

```
GET _cat/nodes?v&h=name,heap.percent,heap.current,heap.max,ram.percent,cpu&s=node.role
```

---

 ## 2\. Node Resources — CPU / Memory / Disk / JVM

 ### Focused node statistics

 OS, process, JVM, and filesystem statistics. Useful for CPU, GC pressure, open file descriptors, and disk space.

```
GET _nodes/stats/os,process,jvm,fs
```

 ### Broad node statistics

 Indices, thread pools, JVM, filesystem, OS, and process statistics. Useful for taking a full snapshot and comparing it over time.

```
GET _nodes/stats/indices,thread_pool,jvm,fs,os,process
```

 ### All node statistics

 Everything reported by the nodes. This produces the largest output, so use it sparingly.

```
GET _nodes/stats
```

---

 ## 3\. Indexing & Merge Activity

 ### Indexing statistics

 Check index rate, throttling, failures, and time spent indexing.

```
GET _nodes/stats/indices/indexing
```

 ### Merge statistics

 Filtered to keep the output small. Long-running or heavy merges can drive CPU and disk I/O.

```
GET _nodes/stats/indices?filter_path=nodes.*.indices.merges
```

---

 ## 4\. Thread Pools — Queues & Rejections

 ### All thread pools

 Sorted by queue size. Large queues or increasing rejections can indicate thread-pool saturation.

```
GET _cat/thread_pool?v&s=queue:desc
```

 ### ES|QL worker pool

 Check active threads, queue size, and rejected tasks specifically for ES|QL.

```
GET _cat/thread_pool/esql_worker?v
```

---

 ## 5\. Hot Threads — What Is Actually Burning CPU?

 ### Default hot threads

 Shows the top three hot threads per node.

```
GET _nodes/hot_threads
```

 ### All CPU-busy threads

 Shows CPU-busy threads across every node. `threads=999` is effectively unlimited and can produce verbose output.

```
GET _nodes/hot_threads?threads=999&type=cpu
```

---

 ## 6\. Shard Layout

 ### All shards by node

 Grouped by node and sorted by dataset size descending. Useful for finding nodes holding disproportionately large shards.

```
GET _cat/shards?s=node,dataset:desc&v
```

 ### Partially mounted/restored shards

 Shows shards from partially mounted or restored indices (searchable snapshots), sorted by dataset size ascending.

```
GET _cat/shards/partial-restored*?v&s=dataset:asc
```

 ### `.entities*` shards

 Shows `.entities*` shards sorted by node to help identify distribution issues or hot spots.

```
GET _cat/shards/.entities*?v&s=node:desc
```

 ### `.entities*` indices by creation date

 Sorted by creation date to identify the newest/oldest indices and detect potentially runaway index creation.

```
GET _cat/indices/.entities*?v&s=creation.date
```

---

 ## 7\. Running Tasks — Who Is Causing the Load?

 ### In-flight search tasks

 Shows active search tasks with details such as query body, running time, and parent task.

```
GET _tasks?detailed=true&actions=*search*
```

 ### In-flight ES|QL tasks — human-readable

 Shows ES|QL tasks with human-readable durations.

```
GET _tasks?detailed=true&actions=*esql*&human=true
```

 ### In-flight ES|QL tasks — raw durations

 Same as above, but without human-readable formatting. Raw nanosecond values can be easier to sort or parse programmatically.

```
GET _tasks?detailed=true&actions=*esql*
```

 ### Compact ES|QL task list

 Shows a compact list of running ES|QL tasks without detailed query information.

```
GET _tasks?actions=*esql*&human=true
```

---

 ## 8\. Kibana Background Jobs

 ### Kibana Task Manager documents

 Inspect Kibana Task Manager documents for stuck, failed, or long-running tasks such as alerting rules, Fleet, and Security tasks that may be contributing to cluster load.

```
GET .kibana_task_manager*/_search
```
