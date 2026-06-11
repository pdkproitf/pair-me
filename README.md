# Pair Me

> Portable AI skills for any tool. Drop one in. Your AI levels up.

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

### [central-workspace](skills/central-workspace/)

> One workspace file. Every AI tool. Any project.

Stop hardcoding paths and copy-pasting rules across every skill file. `central-workspace` scans your existing prompts, extracts every hardcoded value, and wires them into a single `workspace.md` that every tool loads automatically.

**Solves:** scattered paths · duplicated security rules · new prompt sets overwriting your defaults · starting over every time you switch tools

```bash
npx skills install central-workspace
```

---

## Install any skill

Skills are published to the `npx skills` registry. Install any skill with:

```bash
npx skills install <skill-name>
```

For project-level installation:
```bash
npx skills install <skill-name> --project
```

For global installation (all projects):
```bash
npx skills install <skill-name> --global
```

> **Deprecated:** The old `install.sh` scripts are no longer maintained. See [MIGRATION.md](MIGRATION.md) for upgrading.

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

Open a PR with your skill in `skills/{your-skill-name}/` alongside a `README.md`. The skill file (`.md`) and metadata are all that's needed — npx skills handles installation for all tools.
