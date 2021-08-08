```
sudo su - elasticsearch
kb_config_path="/opt/custom/config/"
kb_install_path="/opt/kibana/"

# Assuming all setup for Elasticsearch is done
KBN_PATH_CONF=${kb_config_path} nohup ${kb_install_path}/bin/kibana &
```
