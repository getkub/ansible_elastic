## Initial variables
```
idx="firewall"
idx_stream="${idx}-ds"
```

## Find All Indices for the Data Stream:
Use the _cat/indices API to list all indices associated with the data stream. You can filter indices by name pattern if needed.
```
GET _cat/indices/${idx_stream}*?h=index
```

## Filter Indices with the Old ILM Policy:
Use the _ilm/explain API to check the ILM policy attached to each index.
```
GET ${idx_stream}/_ilm/explain
```
- Output the above into a file (eg `ilm-output.json`)

## Now get the indices in order

- put below into a jq file (eg sort-alt.jq)
```
.indices | to_entries | 
sort_by(
  (.value.index | split("-") | .[(-2)] // "0000.00.00")
) |
.[] | {index: .value.index, policy: .value.policy}
```

- Now run the jq and output the file to new to ensure the list is ordered by date
```
jq -f sort-alt.jq ilm-output.json > mod2.ilm-output.json
```

## Update ILM Policy for Filtered Indices:
Use the _settings API to update the ILM policy for each filtered index to ilm_365days.

```
PUT /<index_name>/_settings
{
  "index.lifecycle.name": "ilm_new_policy"
}
```

## Verify the ILM Policy Change:
Use the _ilm/explain API again to verify that the ILM policy

```
GET ${idx_stream}/_ilm/explain
```
