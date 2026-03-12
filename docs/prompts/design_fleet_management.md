# Elastic Fleet Management — CSV Architecture Design

## Overview

This design manages Elastic Fleet agent policies and integration deployments across a large server estate using 3 CSV files. The core idea is to keep complexity away from non-technical users while giving admins full control over integration versions and rollouts.

The key challenge this solves: with 1000+ services, you cannot create one Elastic agent policy per service — that becomes unmanageable. Instead, all hosts share a small number of **default policies**, and **temporary migration policies** are created only when upgrading a specific service group. Once the migration is validated, the temporary policy is removed.

---

## Design Philosophy

- **Non-tech users** manage host assignments only (`hosts_policy_mapping.csv`) — they never touch versions or policy definitions
- **Admins** manage policy definitions (`agent_policies_config.csv`) and integration versions (`policy_integrations_config.csv`)
- **Default policies** (`linux_default`, `windows_default`) are permanent and cover all hosts at all times under normal conditions
- **Migration policies** are temporary — created only for the duration of an upgrade for one service group, then deleted
- **Policy count stays minimal** regardless of how many services exist — typically just 2 policies at any given time, plus 1 per active migration

---

## The 3 CSV Files

---

### 1. hosts_policy_mapping.csv — *Non-tech user managed*

This is the master list of all servers. Non-tech users add and maintain hostnames, assign them to a service, and add relevant tags. The `policy_id` column is normally left as `linux_default` or `windows_default` — admins update it temporarily during a migration and revert it once done.

This file is the **single source of truth** for what policy every host is currently assigned to.

> **Who manages what:**
> - Non-tech users → `hostname`, `service_short_name`, `tags`
> - Admins → `policy_id` (only updated during migrations)

```csv
hostname,service_short_name,policy_id,tags
web-server-01,online_billing,linux_default,"web|nginx|prod"
web-server-02,online_billing,linux_default,"web|nginx|prod"
db-server-01,online_billing,linux_default,"db|postgresql|prod"
app-server-01,payment_gateway,linux_default,"app|docker|prod"
app-server-02,payment_gateway,linux_default,"app|docker|prod"
windows-server-01,customer_portal,windows_default,"windows|prod"
windows-server-02,customer_portal,windows_default,"windows|prod"
app-server-03,payment_gateway,linux_default,"app|docker|prod"
```

**Column reference:**

| Column | Description | Managed by |
|---|---|---|
| `hostname` | Server hostname as registered in your estate | Non-tech user |
| `service_short_name` | The business service this server belongs to (e.g. `online_billing`) | Non-tech user |
| `policy_id` | The Elastic agent policy currently applied to this host. Defaults to `linux_default` or `windows_default`. Updated by admin during migration only | Admin |
| `tags` | Pipe-separated labels for filtering and grouping in Elastic (e.g. role, stack, environment) | Non-tech user |

---

### 2. agent_policies_config.csv — *Admin managed*

This file defines all Elastic agent policies that exist. Under normal operations it contains just 2 rows — the default Linux and Windows policies. When a migration is needed for a specific service group, the admin adds a temporary migration policy row here. Once migration is complete and validated, that row is removed.

```csv
policy_id,os_type,namespace,monitoring,description
linux_default,linux,default,"logs|metrics","Default policy applied to all Linux hosts under normal conditions"
windows_default,windows,default,"logs|metrics","Default policy applied to all Windows hosts under normal conditions"
online_billing_v2.2,linux,default,"logs|metrics","Temporary migration policy for online_billing service — nginx upgrade to v2.2"
```

**Column reference:**

| Column | Description |
|---|---|
| `policy_id` | Unique identifier for this policy. Default policies follow `{os_type}_default`. Migration policies follow `{service_short_name}_v{new_version}` |
| `os_type` | Target operating system: `linux` or `windows` |
| `namespace` | Elastic namespace for data routing — typically `default` |
| `monitoring` | Pipe-separated list of monitoring types to enable: `logs`, `metrics`, `apm`, `uptime` |
| `description` | Human-readable explanation of what this policy is for and why it exists |

**Rules:**
- Normally only 2 rows exist: `linux_default` and `windows_default`
- Add a migration policy row only when a migration starts — name it `{service_short_name}_v{version}` so its purpose is immediately clear
- Delete the migration policy row once the migration is complete and all affected hosts are back on a default policy

---

### 3. policy_integrations_config.csv — *Admin managed*

This file defines which integrations (Elastic packages) are installed on each policy, and at what version. The combination of `policy_id` + `package_name` uniquely identifies every row — no synthetic ID is needed.

All the detailed integration configuration (log paths, stream settings, input types) is handled in code — this CSV only declares **what to deploy and at what version**.

```csv
policy_id,package_name,package_version,enabled
linux_default,system,2.13,true
linux_default,nginx,2.1,true
linux_default,postgresql,1.8,true
linux_default,docker,1.5,true
windows_default,system,2.13,true
windows_default,winlog,1.2,true
online_billing_v2.2,system,2.13,true
online_billing_v2.2,nginx,2.2,true
online_billing_v2.2,postgresql,1.8,true
online_billing_v2.2,docker,1.5,true
```

**Column reference:**

| Column | Description |
|---|---|
| `policy_id` | References a policy defined in `agent_policies_config.csv` |
| `package_name` | Elastic integration package name (e.g. `nginx`, `postgresql`, `system`) |
| `package_version` | The specific version of the package to deploy to this policy |
| `enabled` | Whether this integration is active. Set to `false` to temporarily disable without removing the row |

**Rules:**
- `policy_id` + `package_name` is the composite key — each combination must be unique
- To upgrade an integration for a service group: create a migration policy and add rows here with the new version
- Once migration completes, bump the version on `linux_default` and remove the migration policy rows
- The `enabled` flag is useful for temporarily disabling an integration during troubleshooting without losing the configuration

---

## File Relationships

```
hosts_policy_mapping.csv       agent_policies_config.csv      policy_integrations_config.csv
────────────────────────       ─────────────────────────      ──────────────────────────────
hostname                       policy_id ◄─────────────────── policy_id
service_short_name             os_type                        package_name
policy_id ────────────────────► namespace                     package_version
tags                           monitoring                     enabled
                               description
```

- `hosts_policy_mapping.policy_id` → references `agent_policies_config.policy_id`
- `policy_integrations_config.policy_id` → references `agent_policies_config.policy_id`
- The processing layer reads all 3 files and translates them into Elastic Fleet API calls

---

## Migration Lifecycle

### Scenario: Upgrade `online_billing` service from nginx v2.1 → v2.2

The goal is to migrate only the `online_billing` servers to the new nginx version first, validate they are healthy, then roll the new version out to all remaining servers via `linux_default`. At no point are other services impacted.

---

#### Step 1 — Normal state (before migration)

All Linux hosts are on `linux_default` running nginx v2.1. Everything is stable.

```
web-server-01  (online_billing)  →  linux_default  (nginx 2.1)
db-server-01   (online_billing)  →  linux_default  (nginx 2.1)
app-server-01  (payment_gateway) →  linux_default  (nginx 2.1)
```

---

#### Step 2 — Admin prepares the migration policy

Admin adds `online_billing_v2.2` to `agent_policies_config.csv`:
```csv
online_billing_v2.2,linux,default,"logs|metrics","Temporary migration policy for online_billing — nginx upgrade to v2.2"
```

Admin adds its integrations to `policy_integrations_config.csv` — identical to `linux_default` but with nginx `2.2`:
```csv
online_billing_v2.2,system,2.13,true
online_billing_v2.2,nginx,2.2,true
online_billing_v2.2,postgresql,1.8,true
online_billing_v2.2,docker,1.5,true
```

---

#### Step 3 — Admin moves online_billing hosts to the migration policy

Admin updates `policy_id` for all `online_billing` rows in `hosts_policy_mapping.csv`:
```csv
web-server-01,online_billing,online_billing_v2.2,"web|nginx|prod"
web-server-02,online_billing,online_billing_v2.2,"web|nginx|prod"
db-server-01,online_billing,online_billing_v2.2,"db|postgresql|prod"
```

The processing layer detects the change and re-assigns those hosts in Elastic Fleet.

```
web-server-01  (online_billing)  →  online_billing_v2.2  (nginx 2.2)  ← migrating
db-server-01   (online_billing)  →  online_billing_v2.2  (nginx 2.2)  ← migrating
app-server-01  (payment_gateway) →  linux_default         (nginx 2.1)  ← untouched
```

---

#### Step 4 — Validate

Monitor `online_billing` hosts in Elastic. Confirm nginx v2.2 is running correctly and no errors are reported.

---

#### Step 5 — Migration complete, clean up

Admin performs 3 actions:

1. **Bump version on `linux_default`** in `policy_integrations_config.csv`:
```csv
linux_default,nginx,2.2,true   ← updated from 2.1
```

2. **Revert `online_billing` hosts** in `hosts_policy_mapping.csv` back to `linux_default`:
```csv
web-server-01,online_billing,linux_default,"web|nginx|prod"
web-server-02,online_billing,linux_default,"web|nginx|prod"
db-server-01,online_billing,linux_default,"db|postgresql|prod"
```

3. **Remove the temporary migration policy** from `agent_policies_config.csv` and `policy_integrations_config.csv`.

Final state — all hosts now on nginx v2.2 via `linux_default`:
```
web-server-01  (online_billing)  →  linux_default  (nginx 2.2)  ← migration done
db-server-01   (online_billing)  →  linux_default  (nginx 2.2)  ← migration done
app-server-01  (payment_gateway) →  linux_default  (nginx 2.2)  ← auto-upgraded
```

---

## Rollback

If something goes wrong during migration, rollback is a single admin action — revert `policy_id` back to `linux_default` for the affected rows in `hosts_policy_mapping.csv`. No other files need to change.

```csv
# Revert online_billing hosts back to default
web-server-01,online_billing,linux_default,"web|nginx|prod"
web-server-02,online_billing,linux_default,"web|nginx|prod"
db-server-01,online_billing,linux_default,"db|postgresql|prod"
```

The processing layer detects the change and moves those hosts back to `linux_default` in Elastic Fleet immediately.

---

## Policy Count at Scale

No matter how many services exist, the number of policies stays small.

| State | Policy count |
|---|---|
| Normal — any number of services | 2 (`linux_default`, `windows_default`) |
| 1 migration in progress | 3 |
| 5 concurrent migrations | 7 |
| 600 services, no active migration | 2 |

---

## Summary

| Goal | How it's met |
|---|---|
| Migrate one service group at a time | Admin updates `policy_id` for only that service's rows in `hosts_policy_mapping.csv` |
| Keep policy count minimal | Permanent default policies for all hosts; temporary migration policies only when needed |
| Non-tech users never touch versions | `hosts_policy_mapping.csv` contains no version info at all |
| Single source of truth for host assignments | `hosts_policy_mapping.csv` always reflects the current policy state of every host |
| Easy rollback | Revert `policy_id` for affected rows — one change, immediate effect |
| Onboard a new service | Non-tech user adds host rows to `hosts_policy_mapping.csv` — picks up `linux_default` automatically |
| Add a new host to existing service | Add 1 row to `hosts_policy_mapping.csv` — no other changes needed |
| Concurrent migrations for multiple services | Each gets its own temporary migration policy — fully isolated |
