---
name: init
description: Prime — load project context by reading docs, the docs_context layer, core docs, and TODO before starting any task
metadata:
  phase: "orient"
  input: "no arguments — invoke as-is"
  output: "summary of the codebase covering domain models, key workflows, and active work areas"
  dependencies: "central-workspace (invoked if no workspace file is bootstrapped yet), codebase-indexing (index refresh)"
---

# Prime

Execute the `Read`, `Research` and `Report` sections in order to build a complete understanding of the codebase.

## When to trigger

Use this skill when:
- this is a new session and project context has not yet been loaded
- the user asks to "prime" or "load context" before starting work
- another skill lists `init` as a dependency and context isn't loaded yet (invoke automatically)

## Workspace (bootstrap if needed)

Check whether a `# WORKSPACE` section is already loaded in context (the auto-load file every
tool loads at session start — `CLAUDE.md`, `.cursorrules`, etc. — would have pulled it in before
this skill ever runs). Do not re-derive tool detection or path conventions here — that logic
belongs solely to `central-workspace`.

- **`# WORKSPACE` present** — a workspace file already exists for this tool. Proceed to Index.
- **`# WORKSPACE` absent and the `central-workspace` skill is available** — this project hasn't
  been bootstrapped yet. Invoke `central-workspace` in full mode before continuing, so the config
  keys the rest of this skill relies on (`docs_context`, `system_context`, `docs_dictionary_file`,
  `todo_file`, etc.) resolve to real, project-specific paths instead of skill-level defaults.
- **`# WORKSPACE` absent and `central-workspace` is unavailable** — proceed with every config key
  at its documented default and note in the Report that no workspace is configured, recommending
  `central-workspace` be installed.

## Index (if available)

Invoke the **`codebase-indexing` skill** to ensure the code graph indexes are built and fresh
before the reading skills below run. That skill is the single writer — it checks status cheaply
and builds only if missing or stale, so this is safe and near-instant on a warm repo. Do not
call `index_repository` or `graphify reflect` directly here.

If neither index backend is available, `codebase-indexing` reports so and the downstream skills
fall back to manual search — proceed to Read either way. For a very large, unindexed repo, run
`codebase-indexing` as a background agent so the build doesn't block orientation.

Fresh indexes accelerate `locate-code`, `find-patterns`, `analyze-code`, and enrich the
`architecture` skill's output.

## Read

This skill **executes** the reading protocol; it doesn't define it. The protocol —
tiers, reader roles, matching and budget rules — lives in `# WORKSPACE` → **Context Loading**,
which is auto-loaded every session and is authoritative. Follow it rather than re-deriving it here.

1. Read `docs_dictionary_file` (default: `.docs/doc_dictionary.md`) — the map. Its `## Core Context`
   section lists what to load for this reader role; `## Features` is the keyword-matched layer.
2. Load **Tier 0** for the *in-repo agent* role, exactly as Context Loading defines it. Also read
   `README.md` for what/who — Tier 0 is authoritative where they disagree.
   - An older `.context/` directory layer, or a monolithic file with no `system_context` sibling,
     may still exist — read what's there and recommend re-running `architecture` to migrate.
3. Load **Tier 1** for the current task by matching the dictionary's `## Features` entries, honoring
   Context Loading's match rules and cap.
4. If `todo_file` doesn't exist, create it with a minimal template (a title and an empty task list) —
   a trivial write, not a scan, so it isn't gated behind Research below.

If the Tier 0 docs are absent but `README.md` or `docs_dictionary_file` already exist, don't generate
them here — note the gap in the Report and recommend running `architecture`. Only missing docs across
the board triggers Research below.

## Research

If both `README.md` and `docs_dictionary_file` do not exist, trigger Research; otherwise skip it.

Use these tools in sequence to build a full picture before doing any work. All of the following skills will use `codebase-memory-mcp` if indexed (see Index step above):

1. **`locate-code` skill** — map where key concepts live (models, services, jobs, controllers)
   - Run for the main domain concepts found in the README
   - Output: file paths grouped by layer — no content reading yet

2. **`analyze-code` skill** — understand architecture and how components fit together
   - Run for the overall system and any domain areas flagged in the docs
   - Output: big-picture understanding, data flow, component relationships

3. **`architecture` skill** — map the system into `docs_context` so future sessions don't repeat this research from scratch
   - Output: `docs_context` (business content) and its sibling `system.md` created

## Report

Keep this a compact orientation summary — reference what each doc said, don't restate it in full. Cover:
- What the app does and who uses it
- System structure — key layers and modules (from `system.md`, if loaded)
- Key domain models and their relationships
- Main workflows (e.g. how a video gets published)
- Active work areas (from `todo_file`)
