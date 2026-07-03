---
name: init
description: Prime — load project context by reading docs, CONTEXT.md, core docs, and TODO before starting any task
input: no arguments — invoke as-is
output: summary of the codebase covering domain models, key workflows, and active work areas
phase: orient
dependencies: [.claude/workspace.md] # this is just a note but it doesn't actually load or search for this file
---

# Prime

Execute the `Read`, `Research` and `Report` sections in order to build a complete understanding of the codebase.

## Read

1. Read `README.md`
2. Read `docs_context` (default: `docs/CONTEXT.md`) if it exists. This is the single agent-context artifact for the repo — domain models, key workflows, layers, patterns, and dependencies, maintained by the `architecture` and `document` skills. If it doesn't exist but `README.md` or `docs_dictionary_dir` already do, don't generate it here — just note its absence in the Report and recommend running the `architecture` skill. Only missing docs across the board triggers Research below.
3. Read `docs_dictionary_dir` (default: `docs/context_dictionary.md`). For each entry, check its `Keywords` against the current task; read only the matching `core_docs_dir` files, not the whole directory
4. Read `todo_file` (default: `docs/TODO.md`). If it doesn't exist, create it with a minimal template (a title and an empty task list) — this is a trivial write, not a scan, so it isn't gated behind Research below

## Research

If both `README.md` and `docs_dictionary_dir` do not exist, trigger Research; otherwise skip it.

Use these tools in sequence to build a full picture before doing any work:

1. **`locate-code` skill** — map where key concepts live (models, services, jobs, controllers)
   - Run for the main domain concepts found in the README
   - Output: file paths grouped by layer — no content reading yet

2. **`analyze-code` skill** — understand architecture and how components fit together
   - Run for the overall system and any domain areas flagged in the docs
   - Output: big-picture understanding, data flow, component relationships

3. **`architecture` skill** — map the system into `docs_context` so future sessions don't repeat this research from scratch
   - Output: `docs/CONTEXT.md` created

## Report

Keep this a compact orientation summary — reference what each doc said, don't restate it in full. Cover:
- What the app does and who uses it
- System structure — key layers and modules (from `docs_context`, if loaded)
- Key domain models and their relationships
- Main workflows (e.g. how a video gets published)
- Active work areas (from `todo_file`)
