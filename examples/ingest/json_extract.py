import json

f = open("/tmp/ingest_pipeline.json", "r")
jdata = json.load(f)

for i in jdata:
  print(i)

f.close()
