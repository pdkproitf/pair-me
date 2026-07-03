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
2. Read `docs_context` (default: `docs/CONTEXT.md`)
3. Read all `core_docs_dir` `*.md` files (default: `docs/core/`)
4. Read `todo_file` (default: `docs/TODO.md`)

## Research

If both `README.md` and `core_docs_dir` do not exist, trigger Research; otherwise skip it.

Use these tools in sequence to build a full picture before doing any work:

1. **`locate-code` skill** — map where key concepts live (models, services, jobs, controllers)
   - Run for the main domain concepts found in the README
   - Output: file paths grouped by layer — no content reading yet

2. **`analyze-code` skill** — understand architecture and how components fit together
   - Run for the overall system and any domain areas flagged in the docs
   - Output: big-picture understanding, data flow, component relationships

## Report

Summarize understanding of the codebase covering:
- What the app does and who uses it
- Key domain models and their relationships
- Main workflows (e.g. how a video gets published)
- Active work areas (from `todo_file`)
