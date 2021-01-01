###  Run like below to reload the config 
eg: https://discuss.elastic.co/t/how-to-test-logstash-conf-file-easily-without-logstash-shutting-down-everytime/260004/3

/opt/logstash/bin/logstash -f /tmp/tempJson.conf --config.reload.automatic
