## Create an ephermal filebeat and connect to ES
```
filebeat setup --pipelines --modules fortinet -e 
```

## GET details of ingest pipelines
```
curl -o /tmp/ingest_pipeline.json http://localhost:9200/_ingest/pipeline
```

```
python3 ./json_extract.py

python3 ./json_extract.py | grep filebeat | while read i
do
echo "Deleting $i "
curl -X DELETE http://localhost:9200/_ingest/pipeline/$i
echo ""
done
```
