https://www.elastic.co/guide/en/elasticsearch/reference/7.16/match-enrich-policy-type.html

## Put Enrichment/lookup data
```
PUT /users/_doc/1?refresh=wait_for
{
  "email": "mardy.brown@asciidocsmith.com",
  "first_name": "Mardy",
  "last_name": "Brown",
  "city": "New Orleans",
  "county": "Orleans",
  "state": "LA",
  "zip": 70116,
  "web": "mardy.asciidocsmith.com"
}
```

## Put the policy
```
PUT /_enrich/policy/users-policy
{
  "match": {
    "indices": "users",
    "match_field": "email",
    "enrich_fields": ["first_name", "last_name", "city", "zip", "state"]
  }
}

POST /_enrich/policy/users-policy/_execute
```

## Create an ingest pipeline and attach policy_name
```
PUT /_ingest/pipeline/user_lookup
{
  "processors" : [
    {
      "enrich" : {
        "description": "Add 'user' data based on 'email'",
        "policy_name": "users-policy",
        "field" : "email",
        "target_field": "user",
        "max_matches": "1"
      }
    }
  ]
}
```

## Add Data and see the output
```
PUT /my-index-000001/_doc/my_id?pipeline=user_lookup
{
  "email": "mardy.brown@asciidocsmith.com"
}

GET /my-index-000001/_doc/my_id

```

