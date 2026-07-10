# Template: Platform-Level `docs_context` (CONTEXT.md)

**Use this template when:** You're documenting a multi-service platform or microservices system.

**Purpose:** Staff-engineer, cross-service view. Lightweight, no deep code. Orchestrator node.

**Constraints:**
- ≤ 150 lines (aggressive — focus on essentials)
- Service Registry table (one row per service)
- No class/method names, no file paths
- Pointers to specs, not inline specs
- Updated quarterly, not per-commit

---

## Template

```markdown
---
type: orchestrator-context
service: [platform-name]
version: 1.0
updated: [today]
tags: [business, architecture, orchestration, staff-engineer]
---

# [Platform Name] — Orchestrator Context

> Staff-engineer view across all services. Per-service technical details: [system.md](system.md).
> Per-service business context: see each service's `.docs/CONTEXT.md`.

## Service Registry

| Service | Purpose | Owned Domain | API Surface | Constraints | Repo |
|---------|---------|--------------|-------------|-------------|------|
| [service-kebab-case] | [one-line purpose] | [what data does it own] | [endpoint groups or link to spec] | [auth, SLAs, rules] | [relative repo path] |

**Example row:**
```
| auth-svc | User authentication & session mgmt | User identity, auth tokens | `/auth/*` [spec](auth-svc/.docs/api.md) | OAuth2, 15s timeout, GDPR | [auth-svc](../../auth-svc) |
```

## Known Topology & Dependency Rules

### Routing & Access
- [how do clients reach services — e.g., "FE only calls API Gateway"]
- [which services call which other services — e.g., "Billing only reads, never writes User data"]

### Authentication & Security
- [inter-service auth — e.g., "All service-to-service calls use mTLS"]
- [API authentication — e.g., "Gateway validates JWT before routing"]

### Data Ownership
- [who owns what data — e.g., "Auth service owns all user identity"]
- [read vs. write rules — e.g., "Services may READ but not WRITE other services' data"]

### SLA & Performance Commitments
- [service-level SLAs — e.g., "API Gateway: 99.9% uptime, 50ms p99"]
- [timeouts and retry rules]

## Architecture Decisions

Key decisions that constrain how services are built. See [ADRs](docs/adr/) for full context.

- **[ADR-NNN]**: [Decision title and why]
  - Example: ADR-001 — Event-driven order processing (eventual consistency trade-off)

## Business Context

### Platform Purpose
[2–3 lines: what the entire platform does, who uses it, core value]

### User Journeys
[main end-to-end flows across services]
- [journey 1, may span multiple services]
- [journey 2]

### Domain Concepts (Platform-Wide)
- **[Concept]** — [definition in business terms, may be owned by a specific service]

### Owned Capabilities
[what the platform as a whole is responsible for, at platform level]
```

---

## Authoring Notes

### Service Registry Table

**Purpose column:** One-line business purpose. Examples:
- ✅ "User authentication & session management"
- ✅ "Payment processing & billing"
- ✅ "Request routing & rate limiting"
- ❌ "JwtAuthFilter, OAuthConfig" (too technical)

**Owned Domain column:** What data/responsibility does this service own? Examples:
- ✅ "User identity, auth tokens"
- ✅ "Invoices, subscriptions, billing state"
- ✅ "Gateway rules, rate limits"
- ❌ "User table, AuthToken table" (too technical)

**API Surface column:** Summary of endpoints/events. Options:
- Link to OpenAPI spec: `[/auth/*](auth-svc/.docs/api.md)` or `[spec](auth-svc/.docs/api-openapi.json)`
- List endpoint groups: `/auth/login, /auth/logout, /auth/refresh`
- Link to topology doc: `[routes](docs/gateway-routes.md)`
- DO NOT inline full OpenAPI spec — that's what system.md and external specs are for

**Constraints column:** Non-obvious rules this service must follow. Examples:
- ✅ "OAuth2, 15s timeout, GDPR-compliant"
- ✅ "PCI-DSS, real-time settlement, no batch delays"
- ✅ "Read-only except billing team, 1M req/s QPS"
- ❌ "Uses Spring Boot, Postgres, RabbitMQ" (that's in system.md)

**Repo column:** Relative path to the service's repository. Make it clickable:
```
[auth-svc](../../auth-svc)
```

---

### Topology & Dependency Rules

Focus on **cross-service constraints**, not implementation details.

**What to include:**
- Who can call whom (routing rules, gateways)
- Data ownership boundaries (read-only access rules)
- Authentication between services (mTLS, API keys, etc.)
- Eventual consistency rules (what takes how long to propagate)
- Failover or degradation rules ("if Billing is down, accept orders anyway but bill later")

**What NOT to include:**
- How JWT tokens are encoded (that's in auth-svc's system.md)
- Message queue technology (RabbitMQ, Kafka — that's in system.md)
- Database schemas (that's in system.md)
- Internal service architecture (layers, packages — that's in system.md)

**Format:** Plain prose, not tables. Examples:

✅ "Frontend only calls API Gateway — never calls services directly."

✅ "Services may READ but not WRITE owned data of other services; writes go through each service's API."

✅ "All service-to-service calls use mutual TLS (mTLS); certificate rotation quarterly via [process](docs/certificate-rotation.md)."

❌ "Auth service uses Spring Security + JWT + BCrypt" (too implementation-specific)

---

### Architecture Decisions

List key ADRs that have shaped the platform design. This is what keeps a staff engineer consistent across features — it answers "why do we do X this way" without re-reading code.

**Format:** Brief list with links.
```
- **ADR-001**: Why event-driven for order processing (eventual consistency trade-off)
- **ADR-003**: Why services use mTLS instead of API keys (auditability and rotation)
- **ADR-007**: Why auth service owns user identity (single source of truth)
```

If ADRs don't exist yet, skip this section (it's optional). But as they accumulate, add them here.

---

### Business Context

This section is the same as in single-service CONTEXT.md, just at platform scope.

**Platform Purpose:** What does the entire platform do? Who uses it? What's the core value?  
Example: "E-commerce platform serving millions of merchants. We provide payment processing, inventory management, and order fulfillment."

**User Journeys:** End-to-end flows that touch multiple services.  
Example: "Merchant lists product → Customer buys → Payment processes → Order fulfills → Invoice generated"

**Domain Concepts:** Platform-wide business terms, with ownership noted.  
Example: "Order (owned by Order service), Invoice (owned by Billing service), User (owned by Auth service)"

**Owned Capabilities:** What is the platform responsible for?  
Example: "Processing payments securely, managing user identity, fulfilling orders within 24 hours"

---

## Line Count Check

✓ Service Registry table: 3–20 rows (5–20 lines)  
✓ Topology & Dependency Rules: 10–30 lines  
✓ Architecture Decisions: 5–15 lines  
✓ Business Context: 30–50 lines  
**Total: 50–125 lines** (target ≤ 150)

If you're over 150 lines:
- Move detailed topology rules to `docs/topology.md`
- Move detailed architecture decisions to `docs/adr/`
- Move detailed business workflows to `docs/user-journeys.md`
- Keep CONTEXT.md as the index pointing to these files

---

## Reconcile (Updating Existing CONTEXT.md)

When updating an existing platform CONTEXT.md:

1. **Service Registry table**: Update as services are added/removed; update Purpose/Constraints as they drift
2. **Topology & Dependency Rules**: Update when new rules emerge; mark with date if controversial
3. **Architecture Decisions**: Only add new; never delete old (for historical context)
4. **Business Context**: Update when platform mission shifts; minor updates OK
5. **Preserve:** Hand-written prose in each section; fold new info into existing prose rather than duplicating

---

## Migration from Single-Service CONTEXT.md

If you're promoting a single-service context to a platform orchestrator context:

1. **Copy existing CONTEXT.md** to `docs/adr/context-v0.md` (archive)
2. **Create new CONTEXT.md** using this orchestrator template
3. **Service Registry**: List each service (even if just one to start)
4. **Topology & Rules**: Extract from README and prior decisions
5. **Architecture Decisions**: Migrate from old CONTEXT.md's "Why" sections
6. **Business Context**: Reuse existing sections (Platform Purpose, User Journeys, Domain Concepts, Owned Capabilities)

---

## Examples

### Minimal Platform (SaaS with 3 services)

```markdown
---
type: orchestrator-context
service: billing-platform
version: 1.0
updated: 2026-07-10
tags: [business, architecture, orchestration]
---

# Billing Platform — Orchestrator Context

> Cross-service view. Service technical details: [system.md](system.md).

## Service Registry

| Service | Purpose | Owned Domain | API Surface | Constraints | Repo |
|---------|---------|--------------|-------------|-------------|------|
| auth-svc | User authentication | User accounts, sessions | `/auth/*` [spec](auth-svc/.docs/api.md) | OAuth2, 15s timeout, GDPR | [auth-svc](../../services/auth-svc) |
| billing-svc | Invoice generation & payment processing | Invoices, subscriptions | `/billing/*` [spec](billing-svc/.docs/api.md) | PCI-DSS, real-time | [billing-svc](../../services/billing-svc) |
| gateway | Request routing & rate limiting | Quotas, routing rules | Proxies `/api/*` [routes](docs/gateway-routes.md) | All requests, 50ms p99 | [gateway](../../services/gateway) |

## Known Topology & Dependency Rules

- Clients (web, mobile) only call API Gateway
- Gateway routes to auth-svc and billing-svc based on path
- billing-svc reads user data from auth-svc but never writes it
- All service-to-service calls use mTLS

## Business Context

### Platform Purpose
Billing platform for SaaS companies. Handles invoicing, subscription management, and payment processing.

### User Journeys
- Customer upgrades plan → Billing generates new invoice → Payment processes
- Subscription expires → Renewal reminder sent → Customer re-pays

### Domain Concepts
- **User**: Account and identity (owned by auth-svc)
- **Subscription**: Billing plan and renewal cycle (owned by billing-svc)
- **Invoice**: Generated charges (owned by billing-svc)

### Owned Capabilities
- Secure user authentication
- Real-time invoice generation
- Payment processing
```

**Count:** ~80 lines ✓

---

## Template Metadata

- **Template version:** 1.0
- **Last updated:** 2026-07-10
- **Line limit:** ≤ 150
- **Required sections:** Service Registry, Known Topology, Business Context
- **Skippable sections:** Architecture Decisions (if no ADRs yet)
- **Paired with:** `system.md` (platform technical details)
