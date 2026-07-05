# central-workspace

> One workspace file. Every AI tool. Any project.

> Unified configuration for AI rules and paths

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

- New developer clones → runs `/central-workspace` → AI behaves exactly the same
- Someone ships a new prompt set → your rules stay intact, nothing gets overwritten
- Switching AI tools → run `npx skills add pdkproitf/skills@central-workspace` → same workspace, different tool
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
└── .docs/
    ├── CONTEXT.md
    ├── TODO.md
    ├── core/
    │   └── domain-a.md
    └── specs/
        └── feature-plan.md
```

Every session. Every tool. Every developer. Same rules, same behavior.

---

## What it does

`central-workspace` is a single-file skill that:

1. Detects which AI tool you're using from the current session
2. Scans your existing skills, commands, and agent files for hardcoded paths
3. Proposes a `workspace.md` with all paths extracted into named keys
4. After confirmation, writes `workspace.md` and updates all files to reference keys instead of hardcoded paths
5. Wires up the auto-load file for your tool (`CLAUDE.md`, `.cursorrules`, etc.) so workspace is available in every session
6. Injects a governance directive ensuring all tasks and skills operate under workspace authority

Run it once on a new project. Run it again after adding new skills — it's idempotent.

---

## Install

```bash
npx skills add pdkproitf/skills@central-workspace
```

This automatically detects your AI tool (Claude Code, Cursor, Windsurf, etc.) and installs to the correct location.

**Global installation:**
```bash
npx skills add pdkproitf/skills@central-workspace --global
```

See [migration guide](../../MIGRATION.md) if upgrading from the old `install.sh` method.

---

## Usage

After installation, invoke the skill:

**Claude Code:**
```
/central-workspace
```

**Other tools:**
Reference the skill through your tool's chat interface:
```
@central-workspace
```

The skill will guide you through bootstrapping your project's workspace configuration.

---

## What gets created

| File | Purpose |
|------|---------|
| `{tool-config-path}` | Universal config — paths, autonomy rules, quality rules, security rules, conventions |
| `CLAUDE.md` / `.cursorrules` / etc. | Auto-load file — imports or inlines the config so it's available every session |

Existing skill and command files are updated in-place: hardcoded paths in prose text are replaced with config key references. Bash code blocks are left unchanged.

---

## Updating

Re-run `npx skills add pdkproitf/skills@central-workspace` to pull the latest version. Re-run `central-config` in your project after adding new skills to keep config keys in sync.
