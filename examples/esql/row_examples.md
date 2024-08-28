## Some examples which are not documented, but useful

```
ROW raw= ["{UK, Europe, G7}", "{US, Americas, G7}"]
| MV_EXPAND raw
| keep raw
```
