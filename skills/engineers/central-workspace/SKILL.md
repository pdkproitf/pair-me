---
name: central-workspace
description: Bootstrap any project's AI workspace — detect the current tool, extract hardcoded paths from skill/command/agent files, write a central workspace.md, update all files to use config keys
metadata:
  phase: "orient"
  input: "optional — skill/file name (e.g. \"find-skills\", \"verify.md\") to check only that file; omit to check all files"
  output: "{tool-config-path} (workspace.md) written, skill/command/agent files updated to config key references, auto-load file wired with governance directive"
---

# central-workspace

## When to trigger

Use this skill when the user:
- asks to bootstrap or set up the AI workspace/config for this project
- wants hardcoded paths in skill/command/agent files replaced with config keys
- asks to onboard a new tool (Cursor, Copilot, Windsurf, etc.) to an existing skill setup

---

## Step 1 — Identify Current Tool

Read the system prompt — every tool injects its own identity (e.g. "You are Claude Code", "You are Cursor"). Name the tool from this alone.

Look up the tool in the reference table to get its file locations, `{tool-config-path}`, and auto-load file. Carry `{tool-config-path}` through all steps.

Print: `Tool detected: {tool name}`

---

## Step 2 — Discover Files

If a skill/file name was provided, find and verify that file exists (match by name or path pattern). If not found, report error and stop.

Otherwise, list all skill, command, and agent files using the tool's locations from the reference table.

Check if `{tool-config-path}` already exists — if so, note "config already present" and skip any keys it already defines.

---

## Step 3 — Extract Hardcoded Paths

Read every file from Step 2. Scan prose/instruction text only — skip bash code blocks and skip these directories: `lib/`, `test/`, `tests/`, `app/`, `assets/`, `node_modules/`, `.git/`

Look for:
- Backtick paths: `` `.docs/specs/` ``, `` `.docs/CONTEXT.md` ``
- Quoted paths: `".docs/specs/"`, `'.docs/'`
- Plain prose: "save to .docs/specs/", "read .docs/CONTEXT.md"

Build a deduplicated table mapping each path to its proposed config key (use Path → Config Key reference below). Unknown paths → ask the user to name the key in Step 4.

If a single file was specified and nothing is found, note: "No hardcoded paths found in {filename} — no updates needed" and stop here.

If no argument was given and nothing found → note "no paths extracted — will use defaults" and continue.

---

## Step 4 — Propose Changes

**If a single file was specified:**
- Show the extracted paths from that file only
- Show which config keys will replace the hardcoded paths
- Ask: `Update {filename} with config key references? [y/n]`
- Skip writing workspace.md — focus only on updating the single file

**If no argument was given (full mode):**
- Open [templates/workspace-schema.md](templates/workspace-schema.md) and compose the full `{tool-config-path}` content:
  - **Paths**: Start with all keys from the template (defaults). Override with any extracted paths from Step 3.
  - **All other sections**: standard defaults from the template
- Show the extraction summary and the full proposed file
- If `{tool-config-path}` already exists, show only the diff (new/changed keys). Do not overwrite keys already correctly defined.
- Ask: `Confirm? [y to proceed / n to cancel / e to edit paths]`

Stop and wait. Do not write any files before confirmation.

---

## Step 5 — Write workspace.md

**If a single file was specified:** Skip this step — only update the individual file.

**If full mode:** Write confirmed content to `{tool-config-path}`. Create the directory if needed.

If a legacy workspace file exists elsewhere, extract any content not already captured and append it under `## Project Notes`. Leave the old file in place until the user confirms migration.

---

## Step 5b — Seed the Context Dictionary

**If a single file was specified:** Skip this step.

The dictionary at `docs_dictionary_file` is the map agents read first. It has **two sections with
two writers** — this skill owns `## Core Context` (the role-gated layer, derived from the Paths
table above); the `document` skill owns `## Features` (the keyword-matched layer).

If `docs_dictionary_file` doesn't exist, create it with the skeleton below. If it exists, insert or
refresh **only** the `## Core Context` section — **never touch `## Features`**, and never delete
entries you didn't write.

```markdown
# Context Dictionary

The map of this project's documentation. Read this file first, then load only what the task
needs — see `# WORKSPACE` → Context Loading for tiers, reader roles, and rules.

## Core Context

Always-available docs, gated by reader role rather than keywords.

| File | Read by | When |
|---|---|---|
| `docs_context` | in-repo agent | session start — business orientation |
| `system_context` | in-repo agent | session start (engineering) — technical reference |
| `todo_file` | in-repo agent | session start — active work |
| `service_manifest` | orchestrator; dependent repos' agents | cross-repo aggregation / integration — **never** read by this repo's own agent |
| `docs_dir/indexing/graphify/LESSONS.md` | in-repo agent | architecture / pattern work (if graphify ran) |

## Features

<!-- Auto-generated by the `document` skill — one entry per feature. Do not hand-edit. -->
```

Resolve each `key` to its configured path when writing. Omit a row whose target doesn't exist and
won't be generated (e.g. `service_manifest` in a repo that will never be part of a multi-repo
platform, or LESSONS.md when graphify is unavailable).

---

## Step 6 — Update Files

Replace hardcoded paths in **prose text** with config key references. Leave bash code blocks unchanged.

| Before | After |
|--------|-------|
| `"save to .docs/specs/"` | `"save to specs_dir"` |
| `"read .docs/CONTEXT.md"` | `"read docs_context"` |
| `"read .docs/system.md"` | `"read system_context"` |
| `` `docs_dictionary_dir` `` | `` `docs_dictionary_file` `` *(renamed key — see migration note)* |
| `"Read workspace.md first to load..."` | *(remove line — workspace loads via auto-load file)* |

**If a single file was specified:**
- Update only that file with replacements
- Report: `{filename}: {N} replacements made`
- Skip auto-load file update

**If full mode:**
- Replace hardcoded paths in every file from Step 2
- Report files updated and replacement count after each batch
- **Update the auto-load file for the detected tool.** Always use the `{tool-config-path}`
  resolved in Step 1 — never hardcode a literal path here, since it differs per tool:

  - **Claude Code** (`CLAUDE.md`): this tool supports `@path` markdown imports. Prepend an
    import line, then the governance directive on the next line — don't inline the file's
    content:
    ```
    @{tool-config-path}
    All tasks and skills operate under `# WORKSPACE`. Its rules and path keys are authoritative — skill-level defaults apply only when a key is not defined there.
    ```
  - **Cursor** (`.cursorrules`), **GitHub Copilot** (`.github/copilot-instructions.md`),
    **Windsurf** (`.windsurfrules`), **Cline** (`.clinerules`), **OpenAI Codex** (`AGENTS.md`):
    none of these support file imports, so prepend the **full content** of `{tool-config-path}`
    directly into the auto-load file, with a sync header:
    ```
    <!-- central-workspace: keep in sync with {tool-config-path} — re-run to update -->
    ```
  - Skip if already present, for any tool.

---

## Step 7 — Report

**If a single file was specified:**
```
central-workspace: single-file check complete.

File:            {filename}
Paths extracted: {key} → {path} ({N} occurrences) ...
Replacements:    {N}

Next step:
  Review {filename} — changes are ready to commit
```

**If full mode:**
```
central-workspace complete.

Tool:            {detected tool}
Files analyzed:  {N}
Paths extracted: {key} → {path} ({N} files, {N} occurrences) ...
Files updated:   {N} ({total} replacements)
Auto-load file:  {file}  {created|updated|skipped}
Dictionary:      {docs_dictionary_file}  {created|Core Context refreshed|unchanged}
Key migrations:  {docs_dictionary_dir → docs_dictionary_file | none}

Next steps:
  1. Review {tool-config-path} — fill in any {placeholder} values
  2. Commit the auto-load file ({tool-dir}/ is typically gitignored)
  3. Other developers: clone → run central-workspace → done
```

---

## Reference: Tool Detection and File Locations

| Tool | Detection | Skill/Command/Agent files | Workspace path | Auto-load file |
|------|-----------|--------------------------|-------------|----------------|
| Claude Code | system prompt / `CLAUDE_CODE_VERSION` | `.claude/commands/*.md`, `.claude/agents/*.md`, `.claude/skills/*.md` | `.claude/workspace.md` | `CLAUDE.md` |
| Cursor | system prompt / `CURSOR_*` env | `.cursor/rules/*.mdc` | `.cursor/workspace.md` | `.cursorrules` |
| GitHub Copilot | system prompt | `.github/copilot-instructions.md` | `.github/workspace.md` | `.github/copilot-instructions.md` |
| Windsurf | system prompt | `.windsurf/rules/*.md` | `.windsurf/workspace.md` | `.windsurfrules` |
| Cline | system prompt | `.clinerules` | `.cline/workspace.md` | `.clinerules` |
| OpenAI Codex | system prompt | `AGENTS.md` | `.codex/workspace.md` | `AGENTS.md` |

---

## Reference: Path → Config Key Map

| Path pattern | Config key |
|---|---|
| `.docs/`, `docs/` | `docs_dir` |
| `.docs/doc_dictionary.md`, `docs/doc_dictionary.md` | `docs_dictionary_file` |
| `.docs/CONTEXT.md`, `README.md` | `docs_context` |
| `.docs/system.md`, `docs/system.md` | `system_context` |
| `.docs/service-manifest.md` | `service_manifest` |
| `.docs/specs/`, `docs/specs/`, `specs/` | `specs_dir` |
| `.docs/sessions/`, `docs/sessions/` | `sessions_dir` |
| `.docs/research/`, `docs/research/` | `research_dir` |
| `.docs/core/`, `docs/core/` | `core_docs_dir` |
| `.docs/TODO.md`, `TODO.md` | `todo_file` |
| `.rubocop.yml`, `pyproject.toml`, `eslint.config.*` | `lint_config` |

**Renamed key — migration:** `docs_dictionary_dir` was renamed to `docs_dictionary_file` (it always
pointed at a file, never a directory). If an existing `{tool-config-path}` still defines
`docs_dictionary_dir`, treat it as `docs_dictionary_file`, rewrite the key in place, and note the
migration in the Step 7 report. Never leave both keys defined.

Ignored directories (never extracted): `lib/`, `test/`, `tests/`, `app/`, `assets/`, `src/`, `config/`

Unknown paths → ask the user to name the key in Step 4.

---

## Reference: Config Schema Template

The full `workspace.md` content lives in [templates/workspace-schema.md](templates/workspace-schema.md) — open it when composing or diffing `{tool-config-path}` in Step 4.
