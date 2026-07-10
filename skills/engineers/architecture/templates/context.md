# Template: `docs_context` (CONTEXT.md)

≤150 lines · 4 required sections · no class/method names — PM-readable. This is the entry-point
file — its path *is* the `docs_context` key. Its companion `system.md` lives in the same
directory and is linked, not embedded.

```markdown
---
type: business-context
service: [service]
version: 1.0
updated: [today]
tags: [business, product, user-journeys]
---

# [service] — Business Context

> Business-facing. Technical/interface details: [system.md](system.md).

## Service Purpose
[2–3 lines, PM-readable]

## User Journeys
- [end-to-end flow; prefix inferred ones with `[inferred]`]

## Domain Concepts
- **[Concept]** — [one line, business language]

## Owned Capabilities
- [what this service is responsible for]
```

**Authoring notes:**
- Derive User Journeys from endpoint groups, listener classes, and integration-test method
  names (`whenX_thenY`) — prefix anything not confirmed by an explicit spec/doc with
  `[inferred]`.
- The companion link is a relative path (`system.md`) — it resolves correctly regardless of
  where `docs_context` itself is configured, as long as both files sit in the same directory.
