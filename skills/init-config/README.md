# skills

A portable AI skill for bootstrapping any project's AI tooling config — works with Claude Code, Cursor, GitHub Copilot, Windsurf, Cline, and OpenAI Codex.

---

## What it does

`init-config` is a single-file skill that:

1. Detects which AI tool you're using from the current session
2. Scans your existing skills, commands, and agent files for hardcoded paths
3. Proposes a `config.md` with all paths extracted into named keys
4. After confirmation, writes `config.md` and updates all files to reference keys instead of hardcoded paths
5. Wires up the auto-load file for your tool (`CLAUDE.md`, `.cursorrules`, etc.) so config is available in every session

Run it once on a new project. Run it again after adding new skills — it's idempotent.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/{owner}/skills/main/install.sh | bash
```

The installer will ask for your tool and whether to install globally or for a specific project.

### Install locations

| Tool | Global | Project |
|------|--------|---------|
| Claude Code | `~/.claude/commands/init-config.md` | `.claude/skills/init-config.md` |
| Cursor | `~/.cursor/rules/init-config.mdc` | `.cursor/rules/init-config.mdc` |
| GitHub Copilot | — (project only) | `.github/skills/init-config.md` |
| Windsurf | `~/.windsurf/rules/init-config.md` | `.windsurf/rules/init-config.md` |
| Cline | — (project only) | `.cline/skills/init-config.md` |
| OpenAI Codex | — (project only) | `.codex/skills/init-config.md` |

> **Claude Code note:** global install goes to `commands/` so `/init-config` works as a slash command across all projects. Project-level install goes to `skills/` — invoke by asking your AI to run the init-config skill.

---

## Usage

**Claude Code (global install):**
```
/init-config
```

**Claude Code (project install) / all other tools:**
```
Run the init-config skill to bootstrap this project's config.
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

Re-run `install.sh` to pull the latest version. Re-run `init-config` in your project after adding new skills to keep config keys in sync.
