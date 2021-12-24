## testing filebeat module
```
make python-env
source ./build/python-env/bin/activate
make filebeat.test
pytest tests/system/test_container.py
```
