## Loading data from an index

```

data_folder=/tmp/elastic_data/my_index
# download data
# curl -O http://download.elasticsearch.org/demos/wanna_cry/snapshot_wanna_cry.tar.gz
index_name=my_index

curl -H "Content-Type: application/json" -XPUT 'http://localhost:9200/_snapshot/${index_name}' -d '{
    "type": "fs",
    "settings": {
        "location": "${data_folder}",
        "compress": true,
        "max_snapshot_bytes_per_sec": "1000mb",
        "max_restore_bytes_per_sec": "1000mb"
    }
}'
```

https://github.com/elastic/examples/tree/master/Security%20Analytics/malware_analysis
## Restore the index data
```
curl -XPOST "localhost:9200/_snapshot/wanna_cry/snapshot-wanna-cry/_restore"
```
