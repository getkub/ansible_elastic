### Snapshot an index

```
PUT /_snapshot/my-snapshot-repo/2022.12.20-my-index-2022-12-20-00001
{
    "indices": "my-index",
    "ignore_available": true,
    "include_global_state": false,
    "metadata": {
        "taken_by": "deveops.user",
        "taken_because": "Backup copy"
    }
}

```