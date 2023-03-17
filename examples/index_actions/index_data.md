### Bulk Index
```
DELETE my-index-name

POST my-index-name/_bulk
{ "index" : {}}
{ "os": "windows", "hostname": "win123"}
{ "index" : {}}
{ "os": "linux", "hostname": "linux123"}
{ "index" : {}}
{ "os": "linux", "hostname": "linux124"}
```