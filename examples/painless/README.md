## JSON format
- header_key_value.json => Provides a good format for mustache templating for email

```
{
  "headers": ["name", "email", "phone"],
  "data": [
    {"values": ["test3", "test3@gmail.com", "0123455"]},
    {"values": ["test4", "test4@gmail.com", "01234"]}
  ]
}
```

- painless
```
def mydoc = ['headers': ["name", "email", "phone"], 'data': []];
for (def b : ctx.payload.aggregations.groupby.buckets) {
    def values = [
        "test3",
        "test3@gmail.com",
        "0123455"
    ]; // Replace these values with your actual data
    mydoc.data.add(['values': values]);
}

return mydoc;

```

- mustache template

```
<table>
  <thead>
    <tr>
      {{#headers}}
        <td>{{.}}</td>
      {{/headers}}
    </tr>
  </thead>
  <tbody>
    {{#data}}
      <tr>
        {{#values}}
          <td>{{.}}</td>
        {{/values}}
      </tr>
    {{/data}}
  </tbody>
</table>

```