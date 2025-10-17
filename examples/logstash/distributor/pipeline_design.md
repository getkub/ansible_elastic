# Logstash Ingress Pipeline Architecture - Design

## Architecture Layers

```
INPUT LAYER
  ├─ input-agents
  ├─ input-syslog
  └─ input-api
         ↓
DISTRIBUTOR LAYER
  ├─ distributor-agents
  ├─ distributor-syslog
  └─ distributor-api
         ↓
FILTER LAYER (collector-specific)
  ├─ filter-collector_01-agents
  ├─ filter-collector_01-syslog
  ├─ filter-collector_01-api
  ├─ filter-collector_02-agents
  ├─ filter-collector_02-syslog
  ├─ filter-collector_02-api
  └─ [add more collectors as needed]
         ↓
ROUTER LAYER
  ├─ router-agents
  ├─ router-syslog
  └─ router-api
         ↓
OUTPUT LAYER
  ├─ output-kafka
  ├─ output-elasticsearch
  └─ output-splunk
```

```mermaid
graph TD
    subgraph INPUT["INPUT LAYER"]
        IA["input-agents"]
        IS["input-syslog"]
        IAP["input-api"]
    end

    subgraph DISTRIBUTOR["DISTRIBUTOR LAYER"]
        DA["distributor-agents"]
        DS["distributor-syslog"]
        DAP["distributor-api"]
    end

    subgraph FILTER["FILTER LAYER"]
        FC1A["filter-collector_01-agents"]
        FC1S["filter-collector_01-syslog"]
        FC1AP["filter-collector_01-api"]
        FC2A["filter-collector_02-agents"]
        FC2S["filter-collector_02-syslog"]
        FC2AP["filter-collector_02-api"]
    end

    subgraph ROUTER["ROUTER LAYER"]
        RA["router-agents"]
        RS["router-syslog"]
        RAP["router-api"]
    end

    subgraph OUTPUT["OUTPUT LAYER"]
        OK["output-kafka"]
        OE["output-elasticsearch"]
        OS["output-splunk"]
    end

    IA --> DA
    IS --> DS
    IAP --> DAP

    DA --> FC1A
    DA --> FC2A
    DS --> FC1S
    DS --> FC2S
    DAP --> FC1AP
    DAP --> FC2AP

    FC1A --> RA
    FC2A --> RA
    FC1S --> RS
    FC2S --> RS
    FC1AP --> RAP
    FC2AP --> RAP

    RA --> OK
    RA --> OE
    RA --> OS
    RS --> OK
    RS --> OE
    RS --> OS
    RAP --> OK
    RAP --> OE
    RAP --> OS

    style INPUT fill:#e1f5ff
    style DISTRIBUTOR fill:#f3e5f5
    style FILTER fill:#fff3e0
    style ROUTER fill:#f1f8e9
    style OUTPUT fill:#fce4ec


```


## Layer Responsibilities

| Layer | Role | Example |
|-------|------|---------|
| **INPUT** | Receive from sources | Listen on ports, protocols |
| **DISTRIBUTOR** | Tag metadata, route to collector filters | Add collector_id, source_type |
| **FILTER** | Collector-specific parsing/enrichment | Windows vs Linux logic |
| **ROUTER** | Route to outputs based on metadata | Which events go where |
| **OUTPUT** | Send to destinations | Kafka, ES, Splunk |

## Total Pipeline Count

- **Inputs:** 3
- **Distributors:** 3
- **Filters:** 6+ (scales with collectors)
- **Routers:** 3
- **Outputs:** 3

**Minimum: 18 pipelines** (for 2 collectors)
