## When backslash and double quotes needs to be converted to double quotes
```
      mutate {
        gsub => [ "object", '\\"', '"' ]
      }

```
