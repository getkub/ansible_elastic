
input {
    pipeline {
        address => github-webhook-project
    }
}


output {
  elasticsearch {
    hosts => "http://localhost:9200"
    user => "elastic"
    password => "changeme"
    index => "github-%{+YYYY.MM}"
  }
}
