## List Watches

```
GET .watches*/_search

GET .watches*/_search
{
                  "query": {
                    "bool": {
                      "filter": [
                        {
                            "match": {
                              "_id": "MY_ID_OF_WATCH"
                            }
                        }
                      ]
                    }
                  }
}

```
