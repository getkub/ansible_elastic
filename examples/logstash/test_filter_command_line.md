### Simple run using external file
```
./bin/logstash -f /tmp/logstash/csv/sample.conf
```

### Running with filter directly
https://www.elastic.co/guide/en/logstash/current/plugins-filters-ruby.html
```
bin/logstash -e "filter { ruby { path => '/etc/logstash/drop_percentage.rb' script_params => { 'drop_percentage' => 0.5 } } }" -t
```
