---
name: architecture
description: Map the overall system architecture from a full codebase scan — creates or reconciles docs/CONTEXT.md
input: no arguments — scans the current codebase
output: path to docs/CONTEXT.md, created or reconciled
phase: orient
---

# Map Architecture

Scan the codebase as a whole — not a git diff — to produce a structural overview: layers, key modules, domain models, and how they connect. Unlike `document`, which documents one implemented feature from its diff, this skill maps the system broadly and is meant to be re-run periodically so the doc doesn't drift from reality.

The output lives in `docs_context` (default: `docs/CONTEXT.md`) — the same file `init` reads every session — not a separate file, so there's one agent-context artifact per repo, not two that can drift apart.

## Step 1 — Check for Existing Doc

Check `docs_context` (default: `docs/CONTEXT.md`).

- If it exists, read it fully. This is a reconciliation, not a rewrite: keep sections that still match reality, update sections that have drifted, add sections for structure that didn't exist before. If it has hand-written content that doesn't fit the template below, preserve it — fold it into the closest matching section rather than discarding it.
- If it doesn't exist, this is a fresh creation.

---

## Step 2 — Map the System

1. Identify the top-level layout — main directories, entry points, config
2. Identify major layers/domains (e.g. models, services, jobs, controllers, workers) and what lives in each
3. Identify key domain models and how they relate to each other
4. Trace 2–3 representative end-to-end flows (e.g. "how a request becomes a response", "how a job gets processed") to capture real data flow rather than assumed structure
5. Note major external dependencies and integration points (databases, queues, third-party APIs)
6. Note recurring code patterns, naming conventions, and idioms used across the system

Use the `locate-code` and `analyze-code` skills for this rather than grepping ad hoc — they already do this job.

---

## Step 3 — Write docs/CONTEXT.md

```markdown
# Context

**Last updated:** <date>

## Overview

<2-4 sentence summary of what the system is, who uses it, and how it's organized>

## Domain Models

- **<Model>** — <relationships and responsibilities>

## Key Workflows

### <Workflow name>
<Step> → <Step> → <Step>, with `file:line` references

## Layers

### <Layer name>
- **Location:** `path/`
- **Responsibility:** <what it does>
- **Key files:** `path/to/file`

## Code Patterns & Conventions

<Naming, structural, and testing conventions used across the system, with references to where they're implemented>

## External Dependencies

- **<service/library>** — <what it's used for>
```

---

## Step 4 — Check README Accuracy (flag only)

Compare `README.md`'s claims against what this scan actually found:
- Does README mention capabilities, integrations, or behavior that no longer exist in the codebase?
- Did the scan turn up significant, user-visible capabilities that README doesn't mention?

List any mismatches. **Never edit `README.md`.** It's human-voiced prose — wording, ordering, and what's worth mentioning are editorial calls for its author, not this skill.

---

## Report

Return the path to `docs_context`. State whether this was a fresh creation or a reconciliation, and if reconciling, summarize what changed (sections added, updated, or removed as stale).

If Step 4 found mismatches, list them under a `README.md may be stale:` heading — as suggestions for a human to act on, not changes already made.
