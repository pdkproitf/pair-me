# Template: `docs_context`/business.md

≤100 lines · 4 required sections · no class/method names — PM-readable.

```markdown
---
type: business-context
service: [service]
version: 1.0
updated: [today]
tags: [business, product, user-journeys]
---

# [service] — Business Context

> Business-facing. Companion: `[docs_context]/implementation.md`.

## Service Purpose
[2–3 lines, PM-readable]

## User Journeys
- [end-to-end flow; prefix inferred ones with `[inferred]`]

## Domain Concepts
- **[Concept]** — [one line, business language]

## Owned Capabilities
- [what this service is responsible for]
```

**Authoring note:** derive User Journeys from endpoint groups, listener classes, and
integration-test method names (`whenX_thenY`) — prefix anything not confirmed by an
explicit spec/doc with `[inferred]`.
