## Clean “agents overview” table

```
FROM .fleet-agents
| EVAL hostname = local_metadata.host.hostname
| EVAL os = local_metadata.os.name
| KEEP hostname, os, policy_id, agent.version, active, last_checkin, last_checkin_status, tags
| SORT last_checkin DESC
| LIMIT 1000

```

## Daily View Query
```
FROM .fleet-agents
| WHERE active == true
| EVAL 
    hostname = local_metadata.host.hostname,
    os = local_metadata.os.name
| KEEP hostname, os, agent.version, last_checkin_status, last_checkin, tags
| SORT last_checkin DESC
```
