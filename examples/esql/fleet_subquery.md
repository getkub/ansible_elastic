# Elasticsearch / ESQL Setup & Query

## Overview

* Creates a `fleet-index` with host metadata mappings
* Ingests Windows security logs into `logs-windows.security-default`
* Ingests fleet metadata into `fleet-index`
* Runs an ESQL query to correlate security events with host metadata

---
## Raw Commands and Data

```json
PUT fleet-index
{
  "mappings": {
    "properties": {
      "host.name": { "type": "keyword" },
      "tags": { "type": "keyword" },
      "os.version": { "type": "keyword" },
      "department": { "type": "keyword" }
    }
  }
}

GET logs-windows.security-default

POST logs-windows.security-default/_bulk
{"create":{}}
{"host.name":"pc-01","agent.version":"8.10.2","event.code":"4624","event.action":"logon","@timestamp":"2026-06-07T10:00:01Z"}
{"create":{}}
{"host.name":"pc-01","agent.version":"8.10.2","event.code":"4625","event.action":"failed_logon","@timestamp":"2026-06-07T10:00:02Z"}
{"create":{}}
{"host.name":"pc-02","agent.version":"8.9.1","event.code":"4688","event.action":"process_create","@timestamp":"2026-06-07T10:00:03Z"}
{"create":{}}
{"host.name":"pc-03","agent.version":"8.10.2","event.code":"4624","event.action":"logon","@timestamp":"2026-06-07T10:00:04Z"}

POST fleet-index/_bulk
{"index":{}}
{"host.name":"pc-01","tags":["finance","windows","prod"],"os.version":"windows-11","department":"finance"}
{"index":{}}
{"host.name":"pc-02","tags":["hr","windows","test"],"os.version":"windows-10","department":"hr"}
{"index":{}}
{"host.name":"pc-03","tags":["engineering","windows","prod"],"os.version":"windows-11","department":"engineering"}
{"index":{}}
{"host.name":"pc-04","tags":["security","windows","prod"],"os.version":"windows-11","department":"security"}
{"index":{}}
{"host.name":"pc-05","tags":["finance","mac","dev"],"os.version":"macos-14","department":"finance"}

```

- ESQL Query then

```
FROM logs-windows.security*, (
  FROM fleet-index
  | STATS tag_values = VALUES(tags) BY host.name, department
)
| STATS tags = VALUES(tag_values), department = VALUES(department), agent.version = VALUES(agent.version) BY host.name
| KEEP host.name, department, agent.version, tags
```
