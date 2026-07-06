# Template: `docs_context`/implementation.md

≤150 lines · 8 required sections · every File Index path must resolve on disk.

```markdown
---
type: architecture-context
service: [service]
version: 1.0
updated: [today]
tags: [architecture, technical, load-first]
---

# [service] — Implementation Context

> LLM-agnostic. Read this before reading source code.

## Service Identity
[1–3 lines: what it does, owning team, region/domain]

## Tech Stack
- Runtime: [language+version, framework+version]
- Build: [tool] · DB: [db + migrations] · Cache/Lock: [if any]
- Messaging: [broker + direction] · API format: [REST/GraphQL, content type]
- External SDKs: [key SDKs] · Testing: [frameworks]

## Entry Points
```bash
[exact build / test / format / run commands]
```

## Architecture Map
| Layer | Responsibility | Key Classes |
|---|---|---|
[one row per top-level package/dir]

## Data Flow
[trigger → component → component → outcome, one line per representative flow]

## External Systems
| System | Purpose | Client |
|---|---|---|
[one row per external system — system-level only; endpoints live in `[docs_context]/interface.md`]

## Key Domain Models
- **[Model]** — [relationships + responsibilities]

## Key Invariants
- [non-obvious constraint a senior dev would miss reading code cold — max 5 bullets]

## File Index
```
[layer]: [glob]/**
```
```

**Authoring note:** Key Invariants is the one section that needs judgment (signing, ack
semantics, counters, coverage floors). Derive it from what the code actually enforces —
never leave a `<!-- fill in -->` placeholder behind.
