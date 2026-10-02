## Average Run by detection rule
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

## For a Specific rule on timeline basis

```
FROM .kibana-event-log-ds*
| WHERE event.provider == "alerting"
    AND event.action == "execute"
    AND rule.name == "MY_RULE"
    AND kibana.alert.rule.execution.metrics.total_run_duration_ms IS NOT NULL
| EVAL runtime_seconds =
    kibana.alert.rule.execution.metrics.total_run_duration_ms / 1000.0
| STATS
    avg_seconds = AVG(runtime_seconds)
  BY time_bucket = BUCKET(@timestamp, 5 minutes)
| KEEP time_bucket, avg_seconds
| SORT time_bucket ASC
| LIMIT 100
```
