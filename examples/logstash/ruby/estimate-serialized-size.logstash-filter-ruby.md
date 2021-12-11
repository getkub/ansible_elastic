This script has three parameters:

 - `source`: if provided, only the value at the provided field reference will
             be estimated (default: entire event)
 - `target`: where to place the size estimate. Because setting this field changes
             the size of the event, it is stored in a @metadata field by default
 - `metadata`: whether to include metadata in size estimate. Because most
               outputs do NOT include metadata, it is skipped by default.
               Option is not available when specifying `source`.

~~~
filter {
  ruby {
    path => "${PWD}/estimate-serialized-size.logstash-filter-ruby.rb"
    script_params => {
      source => '[path][to][source][field]'
      target => '[target][field]'
    }
  }
}
~~~
