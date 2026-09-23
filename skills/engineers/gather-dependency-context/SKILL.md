---
name: gather-dependency-context
description: Discover a dependency repo's API surface and constraints from its service manifest, check for staleness, present a summary, and store the entry to CLAUDE.md on confirmation.
metadata:
  phase: "context"
  input: "[repo] [task] — repo name or path required; task optional for keyword-scoped loading"
  output: "printed dependency summary; CLAUDE.md updated on user confirmation"
---

# Gather Dependency Context

Load the right context from a dependency repo for the current task. No source reads, no bulk loads.

## When to trigger

Use this skill when the user:
- says "gather context of [repo]", "load [repo] context", "add [repo] as dependency", "understand [repo]"
- pastes a repo name or path and asks to integrate or understand it

Do NOT auto-trigger on session start. Explicit call only.

## Variables

- `repo`: repo name or absolute path. Required. Ask if not provided before proceeding.
- `task`: free-text task description (optional). Used for keyword-scoped Tier 1 loading.

---

## Step 1 — Resolve repo location

Check if `repo` is an absolute path that exists on disk.

**Path exists** — use it directly, skip search.

**Name only** — run:
```bash
find ~/projects -maxdepth 2 -type d -name "{repo}" 2>/dev/null
```

- One result: confirm with user, then proceed.
- Multiple results: list them, ask user to pick one.
- No results: ask user to provide the full path. Stop until resolved.

---

## Step 2 — Detect doc structure

Read `{path}/CLAUDE.md`. It will reference any workspace config file (e.g. via `@.claude/workspace.md`) — follow that reference to load it too.

Extract these keys from the `## Paths` table in the workspace config:
- `service_manifest` — path to the contract card
- `system_context` — path to the technical context file
- `docs_dictionary_file` — path to the context dictionary

If `CLAUDE.md` does not exist or defines no path keys, assume defaults: `.docs/service-manifest.md`, `.docs/system.md`, `.docs/doc_dictionary.md`.

Confirm each resolved path exists on disk before proceeding. Note which are missing — missing files are not errors, proceed with what exists.

---

## Step 3 — Read manifest

Read the file at the `service_manifest` path resolved in Step 2.

Extract:
- `updated:` date from YAML frontmatter
- `owned_domain:` field
- All entries under `publishes:` — id + purpose for each
- All entries under `consumes:` — service + contract + purpose for each
- Any `constraints:` entries

---

## Step 4 — Check staleness

```bash
git -C {path} log --since="{manifest.updated}" --oneline | head -10
```

- **No output** — manifest is current. Source of truth: manifest.
- **Commits present** — manifest is stale. Read the file at the `system_context` path resolved in Step 2 for the authoritative API surface. Use it in place of (not in addition to) the manifest for API detail.

If `task` was provided and `system_context` is loaded: scan the file at `docs_dictionary_file` for any `## Features` entry whose `Keywords` or `Files` overlap with `task`. Load at most 1 matching core doc.

---

## Step 5 — Present gathered context

Print the summary to session:

```
=== Dependency: {repo_name} ===
Path:     {absolute_path}
Manifest: {manifest_path}
Updated:  {date}  [CURRENT | STALE — {N} commits since {date}]
Loaded:   manifest | system.md [+ {core_doc} if Tier 1 match]

Owned domain:
  {owned_domain}

Publishes:
  {method} {endpoint} — {purpose}
  ...

Consumes:
  {service} · {contract} — {purpose}
  ...

Constraints:
  {constraint entries or "none documented"}
```

Then ask:

> Store this dependency to CLAUDE.md? (y/n)

Wait for confirmation before Step 6.

---

## Step 6 — Store to CLAUDE.md on confirmation

If user confirms:

1. Read `CLAUDE.md` in the current working repo.

2. Check for `# Dependency Context` section:
   - **Exists** — check for an existing `## {repo_name}` subsection.
     - **Subsection exists** — update it in place (do not duplicate).
     - **No subsection** — append a new `## {repo_name}` block inside the section.
   - **Missing** — insert a new `# Dependency Context` section immediately above `# Service restart commands` (or at the end of the file if that heading is absent).

3. Entry format:
```markdown
## {repo_name}
- path: {absolute_path}
- manifest: {resolved service_manifest path}
- system:   {resolved system_context path}
- dictionary: {resolved docs_dictionary_file path}
- **Trigger:** {2-6 distinctive keywords derived from owned_domain and publishes entries}
- **Owned domain:** {owned_domain summary — one sentence}
- **Publishes:**
  - `{METHOD /path}` — {purpose}
  - ...
- **Consumes:**
  - {service} — {purpose}
  - ...
- **Constraints:**
  - {constraint}
  - ...
```

4. If `# Dependency Context` section header is new, prepend this protocol block before the first `##` entry:

```markdown
# Dependency Context

Agent role here is **cross-repo integrator**. Read the dependency's `service_manifest` first.
If `manifest.updated` predates recent commits on the topic, read `system.md` next.
Use `doc_dictionary.md` only when `system.md` references a specific core doc you need.
Never read the dependency's source or `docs_context` / `system_context` wholesale.

```

---

## Rules

- Never read source files (`.py`, `.ts`, etc.) from the dependency repo.
- Never load more than 1 core doc per dependency per run.
- Never write to CLAUDE.md without explicit user confirmation in Step 5.
- If `service-manifest.md` does not exist and `system.md` does not exist, report what was found and stop — do not attempt to derive a manifest from source.
