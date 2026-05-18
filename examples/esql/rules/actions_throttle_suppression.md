###  Suppressions
- https://www.elastic.co/docs/solutions/security/detect-and-alert/alert-suppression#when-to-use-alert-suppression
- https://www.elastic.co/docs/api/doc/kibana/v9/operation/operation-createrule#operation-createrule-body-application-json-alert_suppression


## Throttle
- You cannot specify the throttle interval at both the rule and action level.
- The recommended method is to set it for each action.

```bash
curl -X POST "https://<KIBANA_HOST>:5601/api/detection_engine/rules" \
-H "kbn-xsrf: true" \
-H "Content-Type: application/json" \
-H "Authorization: ApiKey <API_KEY>" \
-d '
{
  "name": "Test Rule - 5 Minute Throttle",
  "rule_id": "test_rule_5m",
  "enabled": true,
  "type": "query",
  "index": ["logs-*"],
  "language": "kuery",
  "query": "*",
  "from": "now-5m",
  "interval": "5m",
  "severity": "low",
  "risk_score": 21,
  "actions": [
    {
      "group": "default",
      "id": "12345678-abcd-1234-abcd-1234567890ab",
      "action_type_id": ".slack",
      "params": {
        "message": "Test alert"
      },
      "frequency": {
        "summary": false,
        "notifyWhen": "onThrottleInterval",
        "throttle": "5m"
      }
    }
  ]
}

```
