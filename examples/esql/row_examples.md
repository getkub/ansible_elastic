## Some examples which are not documented, but useful

```
ROW raw= ["{UK, Europe, G7}", "{US, Americas, G7}"]
| MV_EXPAND raw
| keep raw
```

```
ROW raw= ["country = UK, continent = Europe, group = G7", "country = US, continent = Americas, group = G7", "country = SG, continent = Asia, group = G20", "country = CA, continent = Americas, group = G20", "country = IN, continent = Asia, group = G20", "country = CN, continent = Asia, group = G7"]
| MV_EXPAND raw
| GROK raw "country%{SPACE}=%{SPACE}%{WORD:country},%{SPACE}continent%{SPACE}=%{SPACE}%{WORD:continent},%{SPACE}group%{SPACE}=%{SPACE}%{WORD:group}"
| where (continent == "Americas" AND group == "G20" ) OR (continent == "Asia" AND group == "G7" )
| keep raw, country, continent, group
```
