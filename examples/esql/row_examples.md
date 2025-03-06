## Some examples which are not documented, but useful

```
ROW raw= ["{UK, Europe, G7}", "{US, Americas, G7}"]
| MV_EXPAND raw
| keep raw
```

```
ROW raw= ["country = UK, continent = Europe, group = G7", "country = US, continent = Americas, group = G7", "country = SG, continent = Asia, group = G20", "country = CA, continent = Americas, group = G20", "country = IN, continent = Asia, group = G20", "country = CN, continent = Asia, group = G7", "country = SA, continent = Africa, group = G20", "country = DE, continent = Europe, group = G7"]
| MV_EXPAND raw
| GROK raw "country%{SPACE}=%{SPACE}%{WORD:country},%{SPACE}continent%{SPACE}=%{SPACE}%{WORD:continent},%{SPACE}group%{SPACE}=%{SPACE}%{WORD:group}"
| where ((continent == "Americas" AND group == "G20" ) OR (continent == "Asia" AND group == "G7" )) OR (continent == "Europe")
| keep raw, country, continent, group
```

```
ROW sample = ["apple", "mango", "pear"]
| EVAL sample_string = MV_CONCAT(sample, ", ")
| where sample_string RLIKE ".*app.*"
```

## JSON format
```
ROW sample = [
  "{\"country\":\"UK\",\"continent\":\"Europe\",\"group\":[\"G7\",\"G20\"]}",
  "{\"country\":\"US\",\"continent\":\"Americas\",\"group\":[\"G7\",\"G20\"]}",
  "{\"country\":\"IN\",\"continent\":\"Asia\",\"group\":\"G20\"}",
  "{\"country\":\"DE\",\"continent\":\"Europe\",\"group\":\"G7\"}"
]
| MV_EXPAND sample
| DISSECT sample "{\"country\":\"%{country}\",\"continent\":\"%{continent}\",\"group\":%{group}}"
//| MV_EXPAND group
| where group RLIKE ".*G2.*"
```
