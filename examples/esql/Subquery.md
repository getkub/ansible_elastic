## Example of Subquery

```
FROM logs-*
| STATS COUNT(*) BY host.name,agent.type
| WHERE host.name IN (
    FROM logs-*
    | WHERE host.os.family == "redhat"
    | STATS COUNT(*) by host.name
    | KEEP host.name
  )
```
