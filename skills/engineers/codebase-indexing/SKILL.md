---
name: codebase-indexing
description: Build or refresh the codebase graph indexes (codebase-memory-mcp structural index + graphify semantic graph) that other skills read from. The single writer — idempotent, incremental, safe to call repeatedly.
metadata:
  phase: "orient"
  input: "no arguments — indexes the current codebase; optional `--force` to rebuild from scratch"
  output: "index status report — what was built, refreshed, skipped (already fresh), or unavailable"
  dependencies: "codebase-memory-mcp, graphify"
---

# Codebase Indexing

Build and keep fresh the graph indexes that `locate-code`, `find-patterns`, `analyze-code`,
and `architecture` read from. This is the **only** skill that triggers the expensive build
operations (`index_repository`, `graphify reflect`). Every other skill is a read-only consumer
that checks status cheaply and falls back to manual search when the index is missing — they
never block on a build.

**Contract:** idempotent and cheap on the happy path. Checking status is fast; a full build
happens only when the index is absent or stale. Safe to call at the start of any session and
before any skill that benefits from the graph.

## When to trigger

- At session start, invoked by `init` (the natural warm-up point)
- The user explicitly asks to "index", "reindex", or "refresh the code graph"
- Before `architecture` runs a full scan (it depends on fresh indexes)
- After a large code change (branch switch, big merge, bulk refactor) when a stale index would mislead
- Another skill reports the index is missing and asks the user to build it

For a very large repo where a cold build would stall the session, run this as a **background
agent** so indexing proceeds while other work continues; consumers keep using manual fallback
until it finishes.

## Two backends

| Backend | Produces | Powers | Cost |
|---|---|---|---|
| **codebase-memory-mcp** | structural graph (symbols, call chains, data flow, layers) | `locate-code`, `analyze-code`, `architecture` file/data-flow facts | index_repository: minutes cold, seconds incremental |
| **graphify** | semantic graph + `LESSONS.md` (god nodes, communities, patterns, decisions) | `find-patterns` clustering, `architecture` domain/topology facts | reflect: minutes cold |

Both are optional. If a backend's tool is unavailable, skip it and report so — never fail the
whole skill because one backend is missing.

## Output location

Every artifact a backend writes into the repo lives under **`{docs_dir}/indexing/{tool}/`**
(`docs_dir` default: `.docs`), one subdirectory per tool:

```
{docs_dir}/indexing/
├── codebase-memory-mcp/    # any repo-side exports we request (e.g. an architecture snapshot);
│                           #   the queryable graph itself is held by the MCP server, not here
└── graphify/               # graphify graph store + LESSONS.md
    └── LESSONS.md
```

Create the `{tool}/` directory before writing. Consumers look for graphify's graph and
`LESSONS.md` at `{docs_dir}/indexing/graphify/`. Point each backend's output flag at its
subdirectory rather than the repo root.

---

## Step 1 — Index with codebase-memory-mcp (structural)

1. **Detect** — try `index_status`. If the tool is unavailable, skip to Step 2 and note it.
2. **Decide from status** (cheap — no build yet):
   - **Not indexed** → run `index_repository` (cold build).
   - **Indexed and `--force`** → run `index_repository` to rebuild from scratch.
   - **Indexed, not forced** → run `detect_changes`:
     - Changes found → incremental re-index of just the changed set (fast).
     - No changes → **skip** — already fresh. Report "unchanged".
3. **Confirm** — re-check `index_status` shows a healthy, current index.

Never rebuild a fresh index. The `detect_changes` → incremental path is what keeps repeated
calls cheap.

---

## Step 2 — Build graphify semantic graph (optional)

Let `GDIR = {docs_dir}/indexing/graphify` (default `.docs/indexing/graphify`). Create it if missing.

1. **Detect** — check whether graphify is available (the skill/CLI and, for an existing graph,
   `GDIR/` or `GDIR/LESSONS.md`). If unavailable, skip to the Report.
2. **Decide** (cheap):
   - **No `GDIR/` graph** → build: `graphify reflect --out GDIR/LESSONS.md` (point graphify's
     graph-store output at `GDIR/` too, if it takes a separate flag).
   - **Exists and `--force`** → rebuild.
   - **Exists, not forced** → only rebuild if the code has changed materially since the graph's
     timestamp (compare `GDIR/` mtime against recent commits / changed files). Otherwise
     **skip** and report "unchanged".
3. **Confirm** — `GDIR/LESSONS.md` exists and contains god-node / community / pattern / decision
   sections.

`GDIR/LESSONS.md` is a generated artifact. Default to leaving it uncommitted (regenerated on
demand); commit it only if the project explicitly wants it version-controlled.

---

## Step 3 — Report

Report each backend as one of **built (cold) / refreshed (incremental) / unchanged (fresh) /
skipped (tool unavailable) / forced-rebuild**, plus:

- Which backends are now available for consumers to read
- For codebase-memory-mcp: rough symbol/file count from `index_status` if surfaced
- For graphify: path to `{docs_dir}/indexing/graphify/LESSONS.md` and whether it was regenerated
- Any errors, and what consumers should do meanwhile (fall back to manual search)

Keep it to a few lines. On the fully-warm path (both indexes fresh) this is just:
"Both indexes fresh — nothing to rebuild."

---

## For skill authors: the read-only contract

Consumer skills (`locate-code`, `find-patterns`, `analyze-code`, `architecture`) must:

- Call **only** read APIs: `index_status`, `search_graph`, `search_code`, `trace_path`,
  `get_code_snippet`, `get_architecture`, `query_graph`, and graphify queries.
- **Never** call `index_repository` or run `graphify reflect`.
- On "not indexed", fall back to manual grep/glob **immediately** — do not block — and may
  suggest the user run `codebase-indexing`.

This keeps one writer (this skill) and many readers, so no ordinary query ever pays the cold
build cost unexpectedly.
