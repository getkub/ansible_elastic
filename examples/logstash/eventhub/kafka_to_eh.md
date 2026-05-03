## What works without OAuth

If your Azure Event Hub is not configured with Entra ID, you can still use:

SAS (Shared Access Signature) connection string
Kafka protocol over Event Hubs

Azure Event Hubs’ Kafka endpoint supports SAS authentication via username + password, where:

username → usually $ConnectionString
password → your full Event Hub connection string


Here’s a solid reusable prompt you can use in the future to generate or convert configurations like this:

---

Here’s a compact **copy/paste super prompt** you can reuse:

---

**Prompt:**

Convert my Logstash `azure_event_hubs` input configuration to a `kafka` input configuration for Azure Event Hubs Kafka-compatible endpoint.

Constraints:

* Do NOT use Entra ID / OAuth (use SASL/PLAIN with Event Hub connection string)
* Each Event Hub must become a separate Kafka input block
* Map `consumer_group` → `group_id`
* Map `initial_position` → `auto_offset_reset` (`beginning = earliest`, `end = latest`)
* Remove Azure Storage checkpointing (not supported in Kafka input)
* Use `bootstrap_servers = <namespace>.servicebus.windows.net:9093`
* Preserve threading/parallelism where possible
* Use correct Kafka SASL_SSL + PLAIN configuration for Azure Event Hubs

Also:

* Explain key behavioral differences (offsets, checkpointing, consumer behavior)
* Highlight any migration risks or limitations

Here is my config:

```ruby
[paste config here]
```

---

If you want, I can also make a **version that forces best-practice tuning (partitions, threads, retries, lag handling)** for production setups.
