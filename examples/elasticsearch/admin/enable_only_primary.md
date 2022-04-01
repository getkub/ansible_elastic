### Ensure routing allocation made to primary and afterwards: Delete the data node
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
