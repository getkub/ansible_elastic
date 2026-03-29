## ILM Custom templates modification

```
GET _index_template/logs-system.system
PUT _component_template/logs-system.system@custom
{
  "template": {
    "settings": {
      "index.lifecycle.name": "ilm_dev_1h"
    }
  }
}
GET _component_template/logs-system.system@custom
GET .ds-logs-system.system-default-*/_ilm/explain
GET _data_stream/logs-system.system-default
```
