- https://discuss.elastic.co/t/solved-split-filter-question-a-k-a-flatten-json-sub-array/130481/12
- https://discuss.elastic.co/t/logstash-parsing-aws-waf-log/195925/3

```
  ruby {
    code => '
      event.get("[Request][Headers]").each { |a|
        name = a["Name"]
        value = a["Value"]
        event.set( "[Request][HeadersFlattened]#{name}", value)
      }
    '
  }
  ```
