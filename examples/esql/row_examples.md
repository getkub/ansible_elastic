## Some examples which are not documented, but useful

```
ROW raw= ["{UK, Europe, G7}", "{US, Americas, G7}"]
| MV_EXPAND raw
| keep raw
```

```
ROW raw= ["country = UK, continent = Europe, group = G7", "country = US, continent = Americas, group = G7", "country = SG, continent = Asia, group = G20"]
| MV_EXPAND raw
| GROK raw "country%{SPACE}=%{SPACE}%{WORD:country},%{SPACE}continent%{SPACE}=%{SPACE}%{WORD:continent},%{SPACE}group%{SPACE}=%{SPACE}%{WORD:group}"
| keep raw, country, continent, group
```
