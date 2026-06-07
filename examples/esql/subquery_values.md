## Simulate Subquery and Stats 

- Index template Create 
```
PUT currency_code
{
  "mappings": {
    "properties": {
      "COUNTRY_NAME": { "type": "keyword" },
      "CUR_CODE": { "type": "keyword" }
    }
  },
  "settings": {
    "index.mode": "lookup"
  }
}

PUT employee
{
  "mappings": {
    "properties": {
      "COUNTRY_NAME": { "type": "keyword" },
      "NAME": { "type": "keyword" },
      "ROLE": { "type": "keyword" }
    }
  }
}
```

- Verify 
```
# DELETE employee
# DELETE currency_code
GET employee
GET currency_code
```

- Data insert
```
POST currency_code/_bulk
{"index":{}}
{"CUR_CODE":"USD","COUNTRY_NAME":"US"}
{"index":{}}
{"CUR_CODE":"USN","COUNTRY_NAME":"US"}
{"index":{}}
{"CUR_CODE":"PEN","COUNTRY_NAME":"US"}
{"index":{}}
{"CUR_CODE":"GBP","COUNTRY_NAME":"UK"}
{"index":{}}
{"CUR_CODE":"UKP","COUNTRY_NAME":"UK"}
{"index":{}}
{"CUR_CODE":"EUR","COUNTRY_NAME":"DE"}
{"index":{}}
{"CUR_CODE":"DEM","COUNTRY_NAME":"DE"}


POST employee/_bulk
{"index":{}}
{"EMP_ID":1,"NAME":"Alice","COUNTRY_NAME":"US","ROLE":"Engineer"}
{"index":{}}
{"EMP_ID":2,"NAME":"Bob","COUNTRY_NAME":"US","ROLE":"Analyst"}
{"index":{}}
{"EMP_ID":3,"NAME":"Cara","COUNTRY_NAME":"US","ROLE":"Manager"}
{"index":{}}
{"EMP_ID":4,"NAME":"Dan","COUNTRY_NAME":"UK","ROLE":"Engineer"}
{"index":{}}
{"EMP_ID":5,"NAME":"Eve","COUNTRY_NAME":"DE","ROLE":"Designer"}
```

- Query
```
FROM employee,
(FROM currency_code
    | STATS COUNT(*) BY CUR_CODE, COUNTRY_NAME)
| STATS VALUES(ROLE), VALUES(NAME), VALUES(CUR_CODE) BY  COUNTRY_NAME
```
  
