```
filter {
  ruby {
    path => "${PWD}/precision-timestamp-parse.logstash-filter-ruby.rb"
    script_params => {
      source => "precise-timestamp-field"
      format => ["ISO8601", "%Y-%m-%d"]
      target => "your-target-field"
    }
  }
}
```
