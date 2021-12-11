### For complex issues in index and moving an index

```
# Make sure the source index is actually open
POST /source_index/_open
# Put the source index in read-only mode
PUT /source_index/_settings
{
  "settings": {
    "index.blocks.write": "true"
  }
}
# Clone the source index to the target name, and set the target to read-write mode
POST /source_index/_clone/target_index
{
  "settings": {
    "index.blocks.write": null 
  }
}
# Wait until the target index is green;
# it should usually be fast (assuming your filesystem supports hard links).
GET /_cluster/health/target_index?wait_for_status=green&timeout=30s
# If it appears to be taking too much time for the cluster to get back to green,
# the following requests might help you identify eventual outstanding issues (if any)
GET /_cat/indices/target_index
GET /_cat/recovery/target_index
GET /_cluster/allocation/explain
# Delete the source index
DELETE /source_index
```
