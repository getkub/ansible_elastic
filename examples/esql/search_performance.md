## 
```
FROM .kibana-event-log-ds*
| WHERE event.provider == "alerting"
    AND event.action == "execute"
    AND kibana.alert.rule.execution.metrics.total_run_duration_ms IS NOT NULL
| EVAL runtime_seconds =
    kibana.alert.rule.execution.metrics.total_run_duration_ms / 1000.0
| STATS
    avg_seconds = ROUND(AVG(runtime_seconds), 2)
  BY @timestamp, rule.name
| KEEP @timestamp, rule.name, avg_seconds
| SORT @timestamp DESC, rule.name ASC
| LIMIT 100
```
