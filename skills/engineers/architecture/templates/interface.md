# Template: `docs_context`/interface.md

≤200 lines · 3 sections, each independently skippable if the service has nothing for it.
Skip the whole file only if all three are empty.

```markdown
---
type: interface-contract
service: [service]
version: 1.0
updated: [today]
tags: [interface, api, dependencies, events]
---

# [service] — Interface Contract

> What this service exposes, calls, and consumes/produces. Companion: `[docs_context]/implementation.md`.

## API Surface
[version note]. Format: `METHOD /path — purpose`. No auth/field details.

### [Resource Group]
- `METHOD /path` — one-line purpose

## Dependencies
Outbound calls grouped by target system.

### [System]
> Base URL via `[ENV_VAR]`   (or: "Accessed via [SDK], not raw HTTP.")

| Method | Path | Purpose |
|---|---|---|
| GET | /path | one-line purpose |

## Events
> Exchange: [name if applicable]

### Inbound (consumed)
| Event | Queue | Routing Key | Notes |
|---|---|---|---|

### Outbound (produced)
| Event | Routing Key | Trigger |
|---|---|---|
```

**Authoring notes:**
- Record the exact `##`/`###` headings you use — a reconcile pass must match them.
- If the service exposes no HTTP surface, omit `## API Surface` entirely (don't leave an
  empty table).
- If the service makes no outbound calls, omit `## Dependencies` entirely.
- If the service has no event bus, omit `## Events` entirely.
- If all three are missing, skip `docs_context`/interface.md altogether — a service with no
  interface surface doesn't need this file.
