# central-config

> One config file. Every AI tool. Any project.

> Time to manage your prompts

---

## The Problem

Your AI assistant is only as good as the prompts behind it — and right now, those prompts are a mess.

- Paths hardcoded across a dozen skill files
- Security rules missed or being copy-pasted into every command
- Output format defined three different ways in three different places
- Install a new prompt set and your default rules get quietly overwritten
- Switch from Claude Code to Cursor and start from scratch — again

It's not just about structure. It's **everything your AI needs to behave consistently** — how it handles secrets, when it asks for confirmation, how it formats responses, which conventions it follows, where it draws the security line. All of it scattered, duplicated, and slowly drifting out of sync.

---

## The Approach

A single `config.md` becomes the central brain for all your AI prompts — one place that defines:

- **Paths** — where specs, plans, docs, and context files live
- **Security rules** — what the AI must never touch, read, or expose
- **Output format** — how responses are structured, every time
- **Quality rules** — when to ask, when to proceed, how to verify
- **Conventions** — branch names, commit format, file naming, code style

Every skill, command, and agent reads from this one file. Change it once — every tool picks it up.

**One skill bootstraps the whole thing.** It scans your existing files, extracts every hardcoded value, proposes a config, and rewires everything — after you confirm.

---

## How it helps

- New developer clones → runs `/central-config` → AI behaves exactly the same
- Someone ships a new prompt set → your rules stay intact, nothing gets overwritten
- Switching AI tools → run `install.sh` → same config, different tool
- Adding a new skill → write it with config keys, the rules follow automatically

---

## The Result

After running `/central-config`, your project looks like this:

```
your-project/
├── CLAUDE.md                       ← auto-loads config on every session
├── .claude/
│   ├── config.md                   ← single source of truth for all AI rules
│   └── skills/
│       ├── feature-plan.md         ← uses config keys, no hardcoded paths
│       ├── implement.md
│       └── ...
└── docs/
    ├── CONTEXT.md
    ├── core/
    │   └── domain-a.md
    └── specs/
        └── feature-plan.md
```

Every session. Every tool. Every developer. Same rules, same behavior.

---

## What it does

`central-config` is a single-file skill that:

1. Detects which AI tool you're using from the current session
2. Scans your existing skills, commands, and agent files for hardcoded paths
3. Proposes a `config.md` with all paths extracted into named keys
4. After confirmation, writes `config.md` and updates all files to reference keys instead of hardcoded paths
5. Wires up the auto-load file for your tool (`CLAUDE.md`, `.cursorrules`, etc.) so config is available in every session

Run it once on a new project. Run it again after adding new skills — it's idempotent.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/pdkproitf/skills/main/skills/central-config/install.sh | bash
```

The installer will ask for your tool and whether to install globally or for a specific project.

### Install locations

| Tool | Global | Project |
|------|--------|---------|
| Claude Code | `~/.claude/skills/central-config.md` | `.claude/skills/central-config.md` |
| Cursor | `~/.cursor/rules/central-config.mdc` | `.cursor/rules/central-config.mdc` |
| GitHub Copilot | — (project only) | `.github/skills/central-config.md` |
| Windsurf | `~/.windsurf/rules/central-config.md` | `.windsurf/rules/central-config.md` |
| Cline | — (project only) | `.cline/skills/central-config.md` |
| OpenAI Codex | — (project only) | `.codex/skills/central-config.md` |


---

## Usage

**Claude Code (global install):**
```
/central-config
```

**Claude Code (project install) / all other tools:**
```
Run the central-config skill to bootstrap this project's config.
```

---

## What gets created

| File | Purpose |
|------|---------|
| `{tool-config-path}` | Universal config — paths, autonomy rules, quality rules, security rules, conventions |
| `CLAUDE.md` / `.cursorrules` / etc. | Auto-load file — imports or inlines the config so it's available every session |

Existing skill and command files are updated in-place: hardcoded paths in prose text are replaced with config key references. Bash code blocks are left unchanged.

---

## Updating

Re-run `install.sh` to pull the latest version. Re-run `central-config` in your project after adding new skills to keep config keys in sync.
