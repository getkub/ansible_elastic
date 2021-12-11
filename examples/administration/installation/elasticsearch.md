```
# ------------------------- #
es_data_dirs=/tmp/elasticsearch/data
es_log_dir=/tmp/elasticsearch/var/log/elasticsearch
mkdir -p $es_data_dirs $es_log_dir
# ------------------------- #

es_config_path="/opt/custom/config/"
es_install_path="/opt/elasticsearch/"
chown -R elasticsearch:elasticsearch $es_install_path $es_config_path $es_data_dirs $es_log_dir

# copy jvm options from latest version
cp ${es_install_path}/config/jvm.options ${es_config_path}/

ES_PATH_CONF=${es_config_path} nohup ${es_install_path}/bin/elasticsearch &
```
