## Move shards from one node to another
```
POST /_cluster/reroute?metric=none
{
    "commands": [
        {
            "move": {
                "index": "my-index",
                "shard": 0,
                "from_node": "hot_1",
                "to_node": "hot_2"
            }
        }
    ]
}

```