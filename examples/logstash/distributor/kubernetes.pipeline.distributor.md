# Logstash Distributor Pattern with Centralized Pipeline Management

## Architecture Overview

No ConfigMaps or pipelines.yml needed! Pipelines are stored in Elasticsearch and fetched dynamically.

```
Elasticsearch (.logstash index) stores all pipeline definitions
        ↓
Logstash Pods fetch and register pipelines via xpack.management
        ↓
Kibana UI for managing/editing pipelines (optional)
        ↓
Data Flow: Beats → beats-server → Windows/Linux routers → Filter pipelines → Outputs
```

## Kubernetes Deployment (Minimal Config Only)

```yaml
---
# Only ONE ConfigMap: Just the basic logstash.yml pointing to Elasticsearch
apiVersion: v1
kind: ConfigMap
metadata:
  name: logstash-config
  namespace: logstash
data:
  logstash.yml: |
    http.host: "0.0.0.0"
    log.level: info
    
    # Enable centralized pipeline management
    xpack.management.enabled: true
    xpack.management.elasticsearch.hosts: ["https://elasticsearch:9200"]
    xpack.management.elasticsearch.ssl.verification_mode: certificate
    xpack.management.elasticsearch.api_key: "${ELASTICSEARCH_API_KEY}"
    xpack.management.logstash.poll_interval: 5s
    
    # Register all pipelines to be centrally managed
    xpack.management.pipeline.id: ["beats-server", "windows-processing", "windows-filter", "linux-processing", "linux-filter"]

---
# Secret for API key (Elasticsearch API key with logstash_admin role)
apiVersion: v1
kind: Secret
metadata:
  name: logstash-secrets
  namespace: logstash
type: Opaque
data:
  # Base64 encoded: your-elasticsearch-api-key:
  ELASTICSEARCH_API_KEY: Zm9vOmJhcg==

---
# Minimal Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: logstash
  namespace: logstash
spec:
  replicas: 1
  selector:
    matchLabels:
      app: logstash
  template:
    metadata:
      labels:
        app: logstash
    spec:
      containers:
      - name: logstash
        image: docker.elastic.co/logstash/logstash:8.11.0
        ports:
        - containerPort: 5044
          name: beats
        - containerPort: 9600
          name: metrics
        
        # Mount ONLY the minimal config
        volumeMounts:
        - name: config
          mountPath: /usr/share/logstash/config/logstash.yml
          subPath: logstash.yml
        
        # Import API key as env var
        envFrom:
        - secretRef:
            name: logstash-secrets
        
        env:
        - name: LS_JAVA_OPTS
          value: "-Xmx1g -Xms1g"
        
        resources:
          requests:
            memory: "1.5Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        
        livenessProbe:
          httpGet:
            path: /
            port: 9600
          initialDelaySeconds: 60
          periodSeconds: 10
        
        readinessProbe:
          httpGet:
            path: /
            port: 9600
          initialDelaySeconds: 30
          periodSeconds: 5
      
      volumes:
      - name: config
        configMap:
          name: logstash-config

---
apiVersion: v1
kind: Service
metadata:
  name: logstash
  namespace: logstash
spec:
  selector:
    app: logstash
  ports:
  - name: beats
    port: 5044
    targetPort: 5044
  - name: metrics
    port: 9600
    targetPort: 9600
```

## Step 1: Create Elasticsearch API Key

```bash
# In Kibana Dev Tools Console, run:
POST /_security/api_key
{
  "name": "logstash-management",
  "role_descriptors": {
    "logstash_admin_role": {
      "cluster": [
        "monitor",
        "manage_logstash_pipelines",
        "read_ilm",
        "manage_ilm"
      ],
      "indices": [
        {
          "names": [".logstash*"],
          "privileges": ["manage", "read", "write"]
        }
      ]
    }
  }
}
```

Copy the `encoded` value (not the `id`). This is your API key.

## Step 2: Create Kubernetes Secret

```bash
kubectl create secret generic logstash-secrets \
  -n logstash \
  --from-literal=ELASTICSEARCH_API_KEY='<your-encoded-api-key>' \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Step 3: Deploy Logstash

```bash
# Apply the minimal K8s manifests above
kubectl apply -f logstash-deployment.yaml

# Verify it's running and connected
kubectl logs -f deployment/logstash -n logstash
```

## Step 4: Define Pipelines via Kibana API

Once Logstash is running and registered, use Kibana API to create pipelines:

```bash
# beats-server pipeline (distributor)
curl -X PUT "https://your-kibana:5601/api/logstash/pipeline/beats-server" \
  -H "Authorization: ApiKey <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Distributor pipeline - routes by OS type",
    "pipeline": "input { beats { port => 5044 } } output { if [agent.os.name] == \"windows\" { pipeline { send_to => [\"windows-processing\"] } } else if [agent.os.name] == \"linux\" { pipeline { send_to => [\"linux-processing\"] } } else { pipeline { send_to => [\"fallback\"] } } }",
    "settings": {
      "pipeline.workers": 4,
      "pipeline.batch.size": 125
    }
  }'

# windows-processing pipeline
curl -X PUT "https://your-kibana:5601/api/logstash/pipeline/windows-processing" \
  -H "Authorization: ApiKey <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Windows events processing",
    "pipeline": "input { pipeline { address => \"windows-processing\" } } filter { mutate { add_field => { \"environment\" => \"windows\" } } } output { pipeline { send_to => [\"windows-filter\"] } }",
    "settings": {
      "pipeline.workers": 2
    }
  }'

# windows-filter pipeline
curl -X PUT "https://your-kibana:5601/api/logstash/pipeline/windows-filter" \
  -H "Authorization: ApiKey <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Windows final processing and output",
    "pipeline": "input { pipeline { address => \"windows-filter\" } } filter { mutate { add_field => { \"processed_by\" => \"windows-filter\" } } } output { elasticsearch { hosts => [\"https://elasticsearch:9200\"] index => \"windows-logs-%{+YYYY.MM.dd}\" } }",
    "settings": {}
  }'

# linux-processing pipeline
curl -X PUT "https://your-kibana:5601/api/logstash/pipeline/linux-processing" \
  -H "Authorization: ApiKey <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Linux events processing",
    "pipeline": "input { pipeline { address => \"linux-processing\" } } filter { mutate { add_field => { \"environment\" => \"linux\" } } } output { pipeline { send_to => [\"linux-filter\"] } }",
    "settings": {
      "pipeline.workers": 2
    }
  }'

# linux-filter pipeline
curl -X PUT "https://your-kibana:5601/api/logstash/pipeline/linux-filter" \
  -H "Authorization: ApiKey <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Linux final processing and output",
    "pipeline": "input { pipeline { address => \"linux-filter\" } } filter { mutate { add_field => { \"processed_by\" => \"linux-filter\" } } } output { elasticsearch { hosts => [\"https://elasticsearch:9200\"] index => \"linux-logs-%{+YYYY.MM.dd}\" } }",
    "settings": {}
  }'

# fallback pipeline
curl -X PUT "https://your-kibana:5601/api/logstash/pipeline/fallback" \
  -H "Authorization: ApiKey <your-api-key>" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Fallback for unknown OS types",
    "pipeline": "input { pipeline { address => \"fallback\" } } output { elasticsearch { hosts => [\"https://elasticsearch:9200\"] index => \"unknown-logs-%{+YYYY.MM.dd}\" } }",
    "settings": {}
  }'
```

## Or Use a Script

Create `deploy-pipelines.sh`:

```bash
#!/bin/bash

KIBANA_URL="https://your-kibana:5601"
API_KEY="your-kibana-api-key"

declare -A pipelines=(
  ["beats-server"]='input { beats { port => 5044 } } output { if [agent.os.name] == "windows" { pipeline { send_to => ["windows-processing"] } } else if [agent.os.name] == "linux" { pipeline { send_to => ["linux-processing"] } } else { pipeline { send_to => ["fallback"] } } }'
  ["windows-processing"]='input { pipeline { address => "windows-processing" } } filter { mutate { add_field => { "environment" => "windows" } } } output { pipeline { send_to => ["windows-filter"] } }'
  ["windows-filter"]='input { pipeline { address => "windows-filter" } } filter { mutate { add_field => { "processed_by" => "windows-filter" } } } output { elasticsearch { hosts => ["https://elasticsearch:9200"] index => "windows-logs-%{+YYYY.MM.dd}" } }'
  ["linux-processing"]='input { pipeline { address => "linux-processing" } } filter { mutate { add_field => { "environment" => "linux" } } } output { pipeline { send_to => ["linux-filter"] } }'
  ["linux-filter"]='input { pipeline { address => "linux-filter" } } filter { mutate { add_field => { "processed_by" => "linux-filter" } } } output { elasticsearch { hosts => ["https://elasticsearch:9200"] index => "linux-logs-%{+YYYY.MM.dd}" } }'
)

for pipeline_id in "${!pipelines[@]}"; do
  echo "Creating pipeline: $pipeline_id"
  curl -X PUT "$KIBANA_URL/api/logstash/pipeline/$pipeline_id" \
    -H "Authorization: ApiKey $API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"pipeline\": \"${pipelines[$pipeline_id]}\"}"
done
```

Run:
```bash
chmod +x deploy-pipelines.sh
./deploy-pipelines.sh
```

## Data Flow

```
Beats Agents (Windows/Linux)
         ↓ (port 5044)
beats-server pipeline (distributor)
         ├→ windows-processing
         │  ↓
         │  windows-filter
         │  ↓ (indexed to Elasticsearch)
         │
         └→ linux-processing
            ↓
            linux-filter
            ↓ (indexed to Elasticsearch)
```

## Key Benefits

- **No file-based configs**: Everything lives in Elasticsearch
- **Zero ConfigMaps for pipelines**: Only basic logstash.yml config
- **Hot updates**: Edit pipelines in Kibana, changes apply instantly to all Logstash pods
- **Scalable**: Add more Logstash replicas, they auto-fetch all pipelines
- **Distributed logic**: Each pipeline handles its own type-specific logic
- **Easy to manage**: Kibana UI for non-technical users

## Verify It's Working

```bash
# Check pipeline status in Logstash metrics
kubectl port-forward svc/logstash 9600:9600 -n logstash
curl http://localhost:9600/_node/stats/pipelines | jq

# View logs
kubectl logs -f deployment/logstash -n logstash | grep -i pipeline

# In Kibana: Management → Stack Management → Logstash Pipelines
# You'll see all 5 pipelines running
```

## Notes

- Centralized pipeline management is a subscription feature requiring a valid Elasticsearch license
- Pipeline configurations are stored in Elasticsearch under the `.logstash` index
- Logstash polls Elasticsearch periodically (configurable via `xpack.management.logstash.poll_interval`) for pipeline changes
