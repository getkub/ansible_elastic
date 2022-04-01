### Ensure routing allocation made to primary 
```
PUT _cluster/settings
{
"persistent": {
"cluster.routing.allocation.enable": "primaries"
}
}
```
## Delete the data node

### and back to normal
```
PUT _cluster/settings
{
"persistent": {
"cluster.routing.allocation.enable": null
}
}
```
