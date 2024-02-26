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
    def values = [];
    
    // Assuming b.key has the required fields like "name", "email", "phone"
    values.add(b.key.name);
    values.add(b.key.email);
    values.add(b.key.phone);

    mydoc.data.add(['values': values]);
}

return mydoc;

```

- mustache template

```
<table>
  <thead>
    <tr>
      {{#ctx.payload._doc.headers}}
        <td>{{.}}</td>
      {{/ctx.payload._doc.headers}}
    </tr>
  </thead>
  <tbody>
    {{#ctx.payload._doc.data}}
      <tr>
        {{#values}}
          <td>{{.}}</td>
        {{/values}}
      </tr>
    {{/ctx.payload._doc.data}}
  </tbody>
</table>

```