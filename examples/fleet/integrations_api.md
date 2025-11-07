# Elastic Fleet API Reference - Dev Tools

A comprehensive guide to Elastic Fleet Agent APIs for use in Kibana Dev Tools Console.

## 📋 Table of Contents
- [Getting Started](#getting-started)
- [Agent Policies](#agent-policies)
- [Package Policies (Integrations)](#package-policies-integrations)
- [Packages (EPM)](#packages-epm)
- [Agents](#agents)
- [Enrollment Tokens](#enrollment-tokens)
- [Query Parameters](#query-parameters)

---

## 🚀 Getting Started

### Using Dev Tools Console
In Kibana Dev Tools, prepend all Fleet API endpoints with `kbn:`

```
GET kbn:/api/fleet/agent_policies
```

### Headers Required for cURL
```bash
--header 'Authorization: ApiKey yourbase64encodedkey'
--header 'Content-Type: application/json'
--header 'kbn-xsrf: xx'
```

---

## 🏛️ Agent Policies

Agent policies define what data agents collect and how they behave.

### List All Agent Policies
```
GET kbn:/api/fleet/agent_policies
```

**Query Parameters:**
- `page` - Page number (default: 1)
- `perPage` - Results per page (default: 20, max: 10000)
- `sortField` - Field to sort by (e.g., `name`, `updated_at`)
- `sortOrder` - `asc` or `desc`
- `kuery` - KQL filter query
- `full` - Include full policy details (default: false)
- `format` - `simplified` or `legacy`

**Example with parameters:**
```
GET kbn:/api/fleet/agent_policies?perPage=50&sortField=name&sortOrder=asc
```

### Get Single Agent Policy
```
GET kbn:/api/fleet/agent_policies/{policy_id}
```

### Create Agent Policy
```
POST kbn:/api/fleet/agent_policies

{
  "name": "My Agent Policy",
  "namespace": "default",
  "description": "Policy description",
  "monitoring_enabled": ["logs", "metrics"]
}
```

**Optional Parameters:**
- `sys_monitoring=true` - Enable system monitoring on creation

### Update Agent Policy
```
PUT kbn:/api/fleet/agent_policies/{policy_id}

{
  "name": "Updated Policy Name",
  "description": "Updated description",
  "namespace": "production"
}
```

### Delete Agent Policy
```
POST kbn:/api/fleet/agent_policies/delete

{
  "agentPolicyId": "policy-id-here"
}
```

### Copy Agent Policy
```
POST kbn:/api/fleet/agent_policies/{policy_id}/copy

{
  "name": "Copy of Agent Policy",
  "description": "Copied policy"
}
```

---

## 📦 Package Policies (Integrations)

Package policies (also called integrations) are configurations added to agent policies.

### List All Package Policies
```
GET kbn:/api/fleet/package_policies
```

**Query Parameters:**
- `page` - Page number
- `perPage` - Results per page (max: 10000)
- `kuery` - KQL filter
- `format` - `simplified` or `legacy`
- `withAgentCount` - Include agent count (boolean)

**Example:**
```
GET kbn:/api/fleet/package_policies?perPage=100&withAgentCount=true
```

### Get Single Package Policy
```
GET kbn:/api/fleet/package_policies/{package_policy_id}
```

### Create Package Policy
```
POST kbn:/api/fleet/package_policies

{
  "name": "nginx-integration-1",
  "policy_id": "agent-policy-id-here",
  "package": {
    "name": "nginx",
    "version": "1.5.0"
  },
  "inputs": {
    "nginx-logfile": {
      "enabled": true,
      "streams": {
        "nginx.access": {
          "enabled": true,
          "vars": {
            "paths": ["/var/log/nginx/access.log*"],
            "tags": ["production"]
          }
        },
        "nginx.error": {
          "enabled": true,
          "vars": {
            "paths": ["/var/log/nginx/error.log*"]
          }
        }
      }
    }
  }
}
```

### Update Package Policy
```
PUT kbn:/api/fleet/package_policies/{package_policy_id}

{
  "name": "updated-integration-name",
  "policy_ids": ["agent-policy-id"],
  "package": {
    "name": "nginx",
    "version": "1.5.0"
  },
  "inputs": {
    "nginx-logfile": {
      "enabled": true,
      "streams": {
        "nginx.access": {
          "enabled": true,
          "vars": {
            "paths": ["/var/log/nginx/access.log*"]
          }
        }
      }
    }
  }
}
```

### Delete Package Policies (Bulk)
```
POST kbn:/api/fleet/package_policies/delete

{
  "packagePolicyIds": [
    "package-policy-id-1",
    "package-policy-id-2"
  ],
  "force": true
}
```

**Note:** `force: true` bypasses certain safety checks.

### Get Package Policy by Agent Policy
Filter package policies by their parent agent policy:
```
GET kbn:/api/fleet/package_policies?kuery=policy_id:"agent-policy-id-here"
```

---

## 📚 Packages (EPM - Elastic Package Manager)

Manage integration packages from the Elastic Package Registry.

### List All Available Packages
```
GET kbn:/api/fleet/epm/packages
```

**Query Parameters:**
- `category` - Filter by category (e.g., `security`, `observability`)
- `prerelease` - Include prerelease packages

### Get Package Details
```
GET kbn:/api/fleet/epm/packages/{package_name}/{version}
```

**Example:**
```
GET kbn:/api/fleet/epm/packages/nginx/1.5.0
```

### Install Package
```
POST kbn:/api/fleet/epm/packages/{package_name}/{version}

{
  "force": false,
  "ignore_constraints": false
}
```

**Example:**
```
POST kbn:/api/fleet/epm/packages/nginx/1.5.0

{
  "force": false
}
```

### Update Package Settings
```
PUT kbn:/api/fleet/epm/packages/{package_name}/{version}

{
  "keepPoliciesUpToDate": true
}
```

**Note:** `keepPoliciesUpToDate` automatically upgrades integration policies when new package versions are available.

### Delete/Uninstall Package
```
DELETE kbn:/api/fleet/epm/packages/{package_name}/{version}
```

**Example:**
```
DELETE kbn:/api/fleet/epm/packages/nginx/1.5.0
```

### Get Latest Package Version
To get the latest version, first list packages and filter:
```
GET kbn:/api/fleet/epm/packages?category=observability
```

Look for the `latestVersion` field in the response for each package.

### List Installed Packages
```
GET kbn:/api/fleet/epm/packages?installed=true
```

---

## 🤖 Agents

Manage individual Elastic Agents enrolled in Fleet.

### List All Agents
```
GET kbn:/api/fleet/agents
```

**Query Parameters:**
- `page` - Page number
- `perPage` - Results per page (max: 10000)
- `kuery` - KQL filter
- `showInactive` - Include inactive agents (boolean)
- `showUpgradeable` - Show only agents that can be upgraded (boolean)
- `sortField` - Field to sort by
- `sortOrder` - `asc` or `desc`

**Pagination example for large fleets:**
```
GET kbn:/api/fleet/agents?perPage=10000&searchAfter={nextSearchAfter}&pitId={pitId}
```

### Get Single Agent
```
GET kbn:/api/fleet/agents/{agent_id}
```

### Get Agent Status
```
GET kbn:/api/fleet/agent_status
```

Returns counts by status: online, offline, updating, etc.

### Upgrade Agent
```
POST kbn:/api/fleet/agents/{agent_id}/upgrade

{
  "version": "9.0.0",
  "source_uri": "https://artifacts.elastic.co/downloads/beats/elastic-agent/"
}
```

### Unenroll Agent
```
POST kbn:/api/fleet/agents/{agent_id}/unenroll

{
  "revoke": false
}
```

**Note:** `revoke: true` immediately removes the agent without waiting for acknowledgment.

### Reassign Agent Policy
```
PUT kbn:/api/fleet/agents/{agent_id}/reassign

{
  "policy_id": "new-policy-id"
}
```

---

## 🎫 Enrollment Tokens

Tokens used to enroll new agents into specific policies.

### List Enrollment Tokens
```
GET kbn:/api/fleet/enrollment_api_keys
```

### Get Single Enrollment Token
```
GET kbn:/api/fleet/enrollment_api_keys/{key_id}
```

### Create Enrollment Token
```
POST kbn:/api/fleet/enrollment_api_keys

{
  "name": "Production Servers Token",
  "policy_id": "agent-policy-id-here"
}
```

### Delete Enrollment Token
```
DELETE kbn:/api/fleet/enrollment_api_keys/{key_id}
```

---

## 🔍 Query Parameters

### Common Query Parameters

#### KQL Filtering
Use `kuery` parameter for complex filtering:
```
GET kbn:/api/fleet/agents?kuery=status:online AND policy_id:"my-policy-id"
```

#### Pagination
```
?page=2&perPage=50
```

#### Sorting
```
?sortField=updated_at&sortOrder=desc
```

#### Full Response
For agent policies, get complete policy configuration:
```
GET kbn:/api/fleet/agent_policies?full=true
```

---

## 💡 Common Use Cases

### Get All Active Policies with Their Integrations
```
GET kbn:/api/fleet/agent_policies?full=true
```

### Find All Agents Using a Specific Policy
```
GET kbn:/api/fleet/agents?kuery=policy_id:"your-policy-id"
```

### List All Package Policies for a Specific Integration
```
GET kbn:/api/fleet/package_policies?kuery=package.name:"nginx"
```

### Get Integration Status and Latest Version
```
GET kbn:/api/fleet/epm/packages/nginx/1.5.0
```

Check the response for:
- `status`: `installed`, `installing`, or `install_failed`
- `installationInfo`: Installation details and version
- `latestVersion`: Most recent available version

### Get All Integrations with Versions and Policy IDs (CSV Format)

To extract integration name, version, and policy ID in CSV format:

**Step 1: Get All Package Policies**
```
GET kbn:/api/fleet/package_policies?perPage=10000
```

**Step 2: Parse the Response**

The response will contain items with the following structure. Extract these fields:
- `package.name` - Integration name
- `package.version` - Integration version
- `policy_id` - Agent policy ID
- `enabled` - enabled status

**Example Response Structure:**
```json
{
  "items": [
    {
      "id": "package-policy-uuid",
      "name": "nginx-integration-1",
      "package": {
        "name": "nginx",
        "version": "1.5.0"
      },
      "policy_id": "agent-policy-id-123",
      ...
    },
    {
      "id": "package-policy-uuid-2",
      "name": "system-integration",
      "package": {
        "name": "system",
        "version": "1.20.4"
      },
      "policy_id": "agent-policy-id-456",
      ...
    }
  ]
}
```

**Step 3: Format as CSV**

Parse the JSON and format as:
```
integration,version,policy_id,enabled
nginx,1.5.0,agent-policy-id-123,true
system,1.20.4,agent-policy-id-456,true
elastic_agent,8.11.0,agent-policy-id-123,true
apm,8.5.0,agent-policy-id-789,true
```

**Using JavaScript in Browser Console or Node.js:**
```javascript
// After fetching the response
const response = await fetch('/mycluster/api/fleet/package_policies?perPage=10000', {
  headers: {
    'kbn-xsrf': 'true',
    'Content-Type': 'application/json'
  }
}).then(r => r.json());

// Generate CSV format
const csv = ['integration,version,policy_id,enabled'];
response.items.forEach(item => {
  csv.push(`${item.package.name},${item.package.version},${item.policy_id},${item.enabled}`);
});

console.log(csv.join('\n'));
```

**Using jq (Command Line):**
```bash
curl -X GET "https://your-kibana-host:5601/api/fleet/package_policies?perPage=10000" \
  -H "Authorization: ApiKey yourkey" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: application/json" \
  | jq -r '["integration,version,policy_id"], (.items[] | [.package.name, .package.version, .policy_id] | @csv) | @csv'
```

**Using Python:**
```python
import requests
import csv
from io import StringIO

response = requests.get(
    'https://your-kibana-host:5601/api/fleet/package_policies?perPage=10000',
    headers={
        'Authorization': 'ApiKey yourkey',
        'kbn-xsrf': 'true',
        'Content-Type': 'application/json'
    }
)

data = response.json()

# Create CSV
output = StringIO()
writer = csv.writer(output)
writer.writerow(['integration', 'version', 'policy_id'])

for item in data['items']:
    writer.writerow([
        item['package']['name'],
        item['package']['version'],
        item['policy_id']
    ])

print(output.getvalue())
```

### Get Policy IDs Only (List)

To get just the policy IDs:
```
GET kbn:/api/fleet/agent_policies?perPage=10000
```

**Extract IDs with jq:**
```bash
curl -X GET "https://your-kibana-host:5601/api/fleet/agent_policies?perPage=10000" \
  -H "Authorization: ApiKey yourkey" \
  -H "kbn-xsrf: true" \
  | jq -r '.items[].id'
```

**Output:**
```
policy-id-1
policy-id-2
policy-id-3
```

### Get Policy IDs with Names (CSV Format)

```
GET kbn:/api/fleet/agent_policies?perPage=10000
```

**Extract with jq:**
```bash
curl -X GET "https://your-kibana-host:5601/api/fleet/agent_policies?perPage=10000" \
  -H "Authorization: ApiKey yourkey" \
  -H "kbn-xsrf: true" \
  | jq -r '["policy_name,policy_id"], (.items[] | [.name, .id] | @csv) | @csv'
```

**Output:**
```
policy_name,policy_id
"Production Servers",policy-id-123
"Development Servers",policy-id-456
"Security Monitoring",policy-id-789
```

### Create Complete Agent Policy with Integration

**Step 1: Create Agent Policy**
```
POST kbn:/api/fleet/agent_policies

{
  "name": "Web Servers Policy",
  "namespace": "production",
  "monitoring_enabled": ["logs", "metrics"]
}
```

**Step 2: Add Integration to Policy**
```
POST kbn:/api/fleet/package_policies

{
  "name": "nginx-web-servers",
  "policy_id": "{policy_id_from_step_1}",
  "package": {
    "name": "nginx",
    "version": "1.5.0"
  },
  "inputs": {
    "nginx-logfile": {
      "enabled": true,
      "streams": {
        "nginx.access": {
          "enabled": true,
          "vars": {
            "paths": ["/var/log/nginx/access.log*"]
          }
        }
      }
    }
  }
}
```

---

## ⚠️ Important Notes

1. **Dev Tools Prefix**: Always use `kbn:` prefix in Dev Tools Console
2. **Authentication**: Automatic in Dev Tools; requires API keys for cURL
3. **Required Header**: `kbn-xsrf: true` required for POST/PUT/DELETE operations
4. **Rate Limits**: Some operations may be rate-limited
5. **Managed Policies**: Some policies (marked as `is_managed: true`) cannot be modified via API
6. **Package Versions**: Always specify exact package versions
7. **Breaking Changes**: Check release notes when upgrading packages as they may have breaking changes

---

## 📖 Additional Resources

- [Official Kibana API Documentation](https://www.elastic.co/docs/api/doc/kibana)
- [Fleet and Elastic Agent Guide](https://www.elastic.co/guide/en/fleet/current/index.html)
- [Elastic Package Registry](https://epr.elastic.co)

---

**Last Updated:** November 2025  
**Elastic Version:** 8.x - 9.x compatible