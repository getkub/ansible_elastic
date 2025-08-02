## Quick setup for logstash

- Ensure vault is updated
```
# example
echo $(kubectl get secret quickstart-es-elastic-user -n elastic-system -o go-template='{{.data.elastic | base64decode}}') | ${logstash_dir}/bin/logstash-keystore add es_password
```

```
${logstash_dir}/bin/logstash -f ${confpath}/fortinet.fortigate.conf --config.reload.automatic


## More advanced
jq -c . ./fortinet.fortigate.sample.json > /tmp/fortinet.fortigate.sample.min.json # Convert to single line json
${logstash_dir}/bin/logstash -f ${confpath}/fortinet.fortigate.ruby.conf --config.reload.automatic
```