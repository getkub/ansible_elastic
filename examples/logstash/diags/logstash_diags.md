## Log4J properties
```
logger.elasticsearchoutput.name = logstash.outputs.elasticsearch
logger.elasticsearchoutput.level = debug
```

```
curl -L -O https://github.com/elastic/support-diagnostics/releases/download/v8.4.0/diagnostics-8.4.0-dist.zip
unzip diagnostics-8.4.0-dist.zip
cd diagnostics-8.4.0
sudo ./diagnostics.sh --host localhost --type logstash-local
```
