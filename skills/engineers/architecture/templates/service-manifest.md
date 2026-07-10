# Template: Service Manifest

**Use this for every run.** The skill scans **one repo**, but this file is the portable,
agent-ready unit a **multi-repo orchestrator** aggregates — one manifest per repo becomes one
row in the platform service registry, and the `consumes`/`publishes` contracts let the
orchestrator wire the cross-repo dependency graph **without reading any repo's source**.

**This file is projected, not authored.** Every field except `repo.remote`/`repo.branch` and
hand-added `consumes` entries is a mechanical extract of `system.md` (see architecture
SKILL.md Step 3.3's field→source table). There is exactly one authored source of technical
truth (`system.md`); the manifest exists only so an orchestrator reads a ~40-line file per repo
instead of ingesting every repo's full `system.md`. Never fill a manifest field with information
that doesn't already exist in system.md — if it's missing there, add it to system.md first, then
re-project the manifest from it.

**Location:** `{docs_dir}/service-manifest.md` (default `.docs/service-manifest.md`) — a fixed,
predictable path so an orchestrator can `glob` `**/.docs/service-manifest.md` across many repo
checkouts.

**Design rules:**
- Self-contained and self-identifying — an orchestrator reads *only this file* per repo.
- Contracts are **summaries + pointers**, never inlined schemas or source. Point at the OpenAPI
  file / Avro schema / `system.md` section; don't paste it.
- Frontmatter is the machine-readable surface (agents parse it); the body is the human view.
- ≤ 150 lines.

---

## Template

```markdown
---
type: service-manifest
service: [service-kebab-case]
version: 1.0
updated: [today]
repo:
  path: [relative or absolute repo path, e.g. ../auth-svc]
  remote: [git remote URL, e.g. git@github.com:org/auth-svc.git]
  branch: [default branch, e.g. main]
owned_domain: [what data/responsibility this service owns — one line]
constraints:
  auth: [e.g. OAuth2 / mTLS / none]
  sla: [e.g. 99.9% uptime, 50ms p99 — or "none stated"]
  compliance: [e.g. GDPR, PCI-DSS — or "none"]
publishes:               # contracts OTHER services build against — summary + pointer, not schema
  api:
    - id: [METHOD /path]         # e.g. POST /auth/login
      purpose: [one line]
      spec: [pointer, e.g. .docs/indexing/… or openapi.yaml#/paths/~1auth~1login]
  events:
    - id: [event name / routing key]
      purpose: [one line]
      spec: [pointer to schema, e.g. src/main/avro/UserCreated.avsc]
consumes:                # what THIS service needs from others — lets orchestrator wire topology
  - service: [target-service-kebab-case]   # by name, resolved by orchestrator across repos
    contract: [METHOD /path or event id]
    purpose: [why this service calls it]
    spec: [pointer if known, else "unknown — resolve from target manifest"]
docs:
  context: .docs/CONTEXT.md
  system: .docs/system.md
  lessons: .docs/indexing/graphify/LESSONS.md   # omit if graphify unavailable
---

# [service] — Service Manifest

> Portable registry entry for multi-repo orchestration. Projected from this repo's system.md —
> see the field→source table below. Never hand-edit a field system.md already answers.

## Owned Domain
[2–3 lines: what this service is responsible for, what data it owns, what it must never do]

## Publishes (contracts others depend on)
- **[METHOD /path]** — [purpose]. Spec: [pointer]
- **[event id]** — [purpose]. Spec: [pointer]

## Consumes (dependencies on other services)
- **[target-service]** · [contract id] — [why]. Spec: [pointer or "resolve from target manifest"]

## Constraints
- [auth / SLA / compliance / data-ownership rules an integrator must honor]
```

---

## Field → source map (this is a projection, not free authorship)

| Manifest field | Source in `system.md` |
|---|---|
| `repo.remote` / `repo.branch` | `git remote get-url origin` + default branch — the one fact system.md doesn't hold |
| `publishes.api` | **API Surface** section, one entry per row |
| `publishes.events` | **Events → Outbound (produced)** table |
| `consumes` (event-triggered) | **Events → Inbound (consumed)** table |
| `consumes` (calls) | **External Dependencies** section — target named by system/service, not raw URL |
| `owned_domain` | **Key Domain Models**, condensed to one line |
| `constraints` | **Key Invariants** + any auth/SLA/compliance already surfaced there |
| `docs.*` | fixed relative paths, not derived |

## Authoring notes

- **`service`** — kebab-case, must match the `service` key in `CONTEXT.md` / `system.md` so the
  orchestrator can join the three files.
- **Do not re-query tools for this file.** system.md's authoring pass (Step 3.2) already mined
  everything above; Step 3.3 is a copy/condense pass over that output, not a new scan.
- **Pointers only.** If a spec file exists (OpenAPI, Avro), point at it. If not, point at the
  relevant `system.md` heading. Never inline a schema — that recreates the context-dilution the
  manifest exists to prevent.
- **The one hand-authored exception:** a dependency reached via a shared library or config (no
  direct HTTP client to grep, so it never lands in system.md's External Dependencies) can be
  added to `consumes` by hand. Preserve it across every re-projection — it's the one thing the
  mechanical extract can't see.
- **Re-projection, not reconciliation:** on re-run, if system.md changed, re-derive every
  mechanical field fresh from it (don't diff/merge them) and re-apply only the hand-added
  `consumes` exception. If system.md didn't change, skip re-projecting entirely.

---

## How the orchestrator uses it

An orchestrator skill/agent (running with access to multiple repo checkouts) does **not** re-scan
code. It:

1. Globs `**/.docs/service-manifest.md` across all repos.
2. Reads each frontmatter → one row in the Service Registry (`context-orchestrator.md`).
3. Joins `consumes[].service` → other manifests' `service` to build the dependency/topology graph.
4. Flags mismatches: a `consumes` entry with no matching published contract in the target manifest
   = a broken or undocumented contract.

This is the payoff of "one repo per run, multi-repo-ready output": the expensive per-repo scan
happens once per repo (producing one authored system.md), and cross-repo assembly is a cheap
frontmatter join over projections of it.
