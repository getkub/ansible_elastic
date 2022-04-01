```
PUT _cluster/settings
{
"persistent": {
"cluster.routing.allocation.enable": "primaries"
}
}
```


### and back to normal
```
PUT _cluster/settings
{
"persistent": {
"cluster.routing.allocation.enable": null
}
}
```
