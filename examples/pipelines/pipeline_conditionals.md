
input {
    pipeline {
        address => os_nix_syslog_pipeline
    }
}

filter {
  grok {
    match => {
        message => "%{SYSLOG5424LINE}"
      }
  }

  if "syslog5424_app" == 'dhcpd' {
    mutate {
      add_field => { "[@metadata][index_prefix]" => "dhcpd" }
    }
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
