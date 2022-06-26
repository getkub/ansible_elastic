## Create an ephermal filebeat 
```
Put connection configs to ElasticSearch in filebeat.yml
```

## Setup Ingest pipelines in the ElasticSearch as follows
```
modulenames="fortinet,infoblox"
filebeat setup --pipelines --modules ${modulenames} -e 
```

## GET details of ingest pipelines into a JSON file
```
curl -o /tmp/ingest_pipeline.json http://localhost:9200/_ingest/pipeline
```

## To remove all ingest pipelines 
```
# Below is a simple script attached alongside
python3 ./json_extract.py

python3 ./json_extract.py | grep filebeat | while read i
do
echo "Deleting $i "
curl -X DELETE http://localhost:9200/_ingest/pipeline/$i
echo ""
done
```
