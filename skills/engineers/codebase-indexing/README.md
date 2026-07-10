# codebase-indexing

> Build and refresh the code graph indexes that the analysis skills read from — the single writer, idempotent and incremental.

---

## What it does

`codebase-indexing` is the one place that triggers the expensive index builds. It manages two backends:

- **codebase-memory-mcp** — structural graph (symbols, call chains, data flow, layers)
- **graphify** — semantic graph plus `LESSONS.md` (god nodes, communities, patterns, decisions)

All repo-side artifacts are written under `{docs_dir}/indexing/{tool}/` (default `.docs/indexing/…`), one subdirectory per tool.

It is **idempotent**: it checks status first (cheap), and only builds when the index is missing or stale. A repeat call on a warm repo returns almost immediately. Incremental refresh (`detect_changes`) avoids full rebuilds after small edits.

Every other skill — `locate-code`, `find-patterns`, `analyze-code`, `architecture` — is a **read-only consumer**. They query the index if it's fresh and fall back to manual grep the moment it isn't. They never trigger a build, so an ordinary "where is X?" never stalls on a cold index.

---

## Why it exists

Without a single writer, each analysis skill would check-and-build on its own. A trivial lookup could suddenly block for minutes on a cold `index_repository`, and multiple skills could race to build the same graph. This skill centralizes the build so:

- Indexing happens **once**, at a predictable point (session start via `init`, or explicit request)
- Consumers stay fast and predictable
- Refreshes are incremental, not full rebuilds

---

## When to use

- At session start (invoked automatically by `init`)
- Explicitly: "index the codebase", "reindex", "refresh the code graph"
- Before running `architecture` (it needs fresh indexes)
- After a branch switch, big merge, or bulk refactor

For very large repos, run it as a background agent so the build doesn't block the session. A
ready-to-install agent definition ships alongside this skill as [`agent.md`](agent.md) — copy it
to `.claude/agents/codebase-indexer.md`.

---

## Permissions

Skill frontmatter cannot grant tool permissions — the Claude Code runtime enforces them from
`.claude/settings.json`. Two separate mechanisms are involved:

- **Tool scope** — the agent's `tools:` list (in `agent.md`) restricts *which* tools it may call.
- **No-prompt grant** — to let indexing run unattended (especially in the background) without
  permission prompts, allow the specific tools/commands in `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "mcp__codebase-memory-mcp__index_repository",
      "mcp__codebase-memory-mcp__index_status",
      "mcp__codebase-memory-mcp__detect_changes",
      "Bash(graphify reflect:*)"
    ]
  }
}
```

Use the `update-config` skill to apply this, or add it by hand. Without it, indexing still works
but prompts on each build call.

---

## Install

```bash
npx skills add pdkproitf/skills@codebase-indexing
```

---

## Usage

**Claude Code:**
```
/codebase-indexing
/codebase-indexing --force     # rebuild both indexes from scratch
```

**Other tools:**
```
@codebase-indexing
```

---

## Output

A short status report, e.g.:

```
codebase-memory-mcp: refreshed (incremental) — 3 files changed
graphify: unchanged (fresh) — .docs/indexing/graphify/LESSONS.md
Both indexes available for locate-code / find-patterns / analyze-code / architecture.
```

Or on a fully warm repo:

```
Both indexes fresh — nothing to rebuild.
```
