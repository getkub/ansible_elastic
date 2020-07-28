
input {
    file {
        path => "/tmp/csv/employees_it.csv"
        tags => ["employees_it"]
    }
    file {
        path => "/tmp/csv/employees_field.csv"
        tags => ["employees_field"]
    }
}

filter {

  if "it_employees" in [tags] {
    mutate {
      add_field => { "[@metadata][index_prefix]" => "employees_it" }
    }
  } else if "field_employees" in [tags] {
    mutate {
      add_field => { "[@metadata][index_prefix]" => "employees_field" }
    }
  } else {
    mutate {
      add_field => { "[@metadata][index_prefix]" => "employees_unknown" }
    }
  }

  csv {
      separator => ","
    }

}

output {
  elasticsearch {
    hosts => "http://localhost:9200"
    user => "elastic"
    password => "changeme"
    index => "%{[@metadata][index_prefix]}-%{+YYYY.MM}"
  }
}
