This script has three parameters:

 - `transform`: the name of the transformation to apply. Currently supported
                options are:
                - `downcase`: replace uppercase letters with their lowercase counterparts
                - `underscore_whitespace`: replace whitespace with underscores
 - `source`:    if provided, only the value at the provided field reference will
                be estimated (default: entire event)
 - `recursive`: whether to recursively walk through child nodes to apply the
                field name transformations (default: false)

~~~
filter {
  ruby {
    path => "${PWD}/kv_space_to_underscore.rb"
    script_params => {
      transform => 'underscore_whitespace'
      source => '[path][to][source][field]'
      recursive => true
    }
  }
}
~~~
