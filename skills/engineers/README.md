# Engineering Skills

> Portable AI skills for software engineering workflows — planning, implementing, documenting, and committing code.

A growing collection of plug-and-play skills for Claude Code, Cursor, GitHub Copilot, Windsurf, Cline, and OpenAI Codex. Each skill is a single markdown file — no dependencies, no frameworks, no lock-in. Just copy it in and go.

---

## Why this exists

AI tools are powerful. But the prompts behind them are usually scattered, duplicated, and written once then forgotten. These skills are built to be **reusable, portable, and consistent** — the same behavior whether you're on Claude Code today or Cursor tomorrow.

Every skill follows the same format:
- Pure imperative prose — no tool-specific syntax
- Portable frontmatter (`skill`, `description`, `input`, `output`, `phase`)
- Works standalone — paste into any AI tool and it runs

---

## Skills

### [central-workspace](central-workspace/)

> One workspace file. Every AI tool. Any project.

Stop hardcoding paths and copy-pasting rules across every skill file. `central-workspace` scans your existing prompts, extracts every hardcoded value, and wires them into a single `workspace.md` that every tool loads automatically.

**Solves:** scattered paths · duplicated security rules · new prompt sets overwriting your defaults · starting over every time you switch tools

```bash
npx skills add pdkproitf/skills@central-workspace
```

---

### [init](init/)

> Load project context before starting any task.

Reads docs, domain models, and active TODOs to build a complete mental model of the codebase. Other skills invoke it automatically as a dependency.

```bash
npx skills add pdkproitf/skills@init
```

---

### [architecture](architecture/)

> Map the overall system architecture from a full codebase scan.

Scans the codebase as a whole (not a diff) and writes into `docs/CONTEXT.md` — domain models, key workflows, layers, patterns, external dependencies. Re-running it reconciles rather than rewrites, so it stays accurate as the system evolves.

```bash
npx skills add pdkproitf/skills@architecture
```

---

### [analyze-code](analyze-code/)

> Trace how a feature or component actually works — data flow, logic, and dependencies with file paths and line numbers.

Deep-reads a target file, class, or feature and produces a structured analysis: entry points, core logic flow, key methods, data flow, dependencies, and error handling.

```bash
npx skills add pdkproitf/skills@analyze-code
```

---

### [find-patterns](find-patterns/)

> Find copy-ready examples and conventions in the codebase before building something new.

Searches for existing implementations, extracts complete working snippets, and documents naming conventions, file organization, and testing patterns in use.

```bash
npx skills add pdkproitf/skills@find-patterns
```

---

### [locate-code](locate-code/)

> Find WHERE code lives for a feature or topic — fast, without reading file contents.

Returns file paths grouped by layer (implementation, tests, config, entry points) so you can orient quickly before diving deeper.

```bash
npx skills add pdkproitf/skills@locate-code
```

---

### [feature](feature/)

> Research the codebase, design options, and write a structured implementation plan ready to execute.

Produces a complete spec file in `docs/specs/` covering design options, phased tasks, testing strategy (via `define_test_case`), and acceptance criteria.

```bash
npx skills add pdkproitf/skills@feature
```

---

### [implement](implement/)

> Execute an approved spec — phase by phase, with verification and commits after each phase.

Reads a spec from `feature`, implements it step by step, updates checkboxes, runs validation commands, and commits each completed phase via `commit`.

```bash
npx skills add pdkproitf/skills@implement
```

---

### [define_test_case](define_test_case/)

> Define acceptance test cases in DSL format — comment-first, covering happy paths, edge cases, errors, and authorization.

Generates structured test case definitions using your project's existing DSL conventions, before any implementation begins.

```bash
npx skills add pdkproitf/skills@define_test_case
```

---

### [save_progress](save_progress/)

> Checkpoint your work — commit WIP, update the plan, and write a session summary you can resume from later.

Creates a complete handoff artifact: a WIP commit, an updated spec with progress notes, and a numbered session file in `docs/sessions/`.

```bash
npx skills add pdkproitf/skills@save_progress
```

---

### [resume_work](resume_work/)

> Restore a saved session and continue implementation from the last checkpoint.

Re-reads the session file, plan, research doc, and recent git history to rebuild full context, then picks up from the first unchecked step.

```bash
npx skills add pdkproitf/skills@resume_work
```

---

### [commit](commit/)

> Group changed files by logical concern and generate a Conventional Commits message for each group.

Analyzes git diff, groups changes by logical concern, and produces correctly formatted commit messages. Executes commits after confirmation if asked.

```bash
npx skills add pdkproitf/skills@commit
```

---

### [document](document/)

> Generate feature documentation from code changes and specs — creates a markdown doc and registers it in the conditional context index.

Analyzes `git diff origin/main`, writes structured docs to `docs/core/`, and updates `context_dictionary.md` so docs surface automatically when relevant.

```bash
npx skills add pdkproitf/skills@document
```

---

## Install skills

Install all skills at once:

```bash
npx skills add pdkproitf/skills
```

Install a specific skill:
```bash
npx skills add pdkproitf/skills@<skill-name>
```

For global installation (all projects):
```bash
npx skills add pdkproitf/skills --global
```

---

## Skill format

Every skill in this repo follows the same portable format:

```markdown
---
skill: skill-name
description: one line — what this skill does
input: what the caller passes in
output: what this skill produces
phase: orient | research | plan | implement | validate | commit
---

# skill-name

## Step 1 — ...
## Step 2 — ...
```

No `$ARGUMENTS`. No tool names. No slash command cross-references. Just instructions any AI can follow.

---

## Contributing

Skills should be:
- **Self-contained** — no external dependencies or imports
- **Tool-agnostic** — no Claude-specific syntax, tool names, or slash commands
- **Focused** — one clear job, one clear output
- **Idempotent** — safe to run more than once

Open a PR with your skill in `skills/engineers/{your-skill-name}/` alongside a `README.md`. The skill file (`.md`) and metadata are all that's needed — npx skills handles installation for all tools.
