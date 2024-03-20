## Setting Auditing

```
xpack.security.audit.enabled: true
```

PUT _cluster/settings

```
{
  "persistent": {
    "xpack.security.audit.logfile.events.include": "access_granted",
    "xpack.security.audit.logfile.events.ignore_filters.realm_ignore.realms": [
      "_service_account"
    ],
    "xpack.security.audit.logfile.events.ignore_filters.action_ignore.actions": [
      "_service_account"
    ]
  }
}
```

### Other ideas
- https://www.elastic.co/guide/en/elasticsearch/reference/current/enable-audit-logging.html 
```
PUT _cluster/settings
{
  "transient": {
    "xpack.security.audit.enabled": true,
    "xpack.security.audit.logfile.events.include": [
      "access_denied",
      "authentication_failed",
      "run_as"  // Include "run_as" events
    ],
    "xpack.security.audit.logfile.events.exclude": [
      "successful_authentication"  // Exclude successful logins
    ]
  }
}
```