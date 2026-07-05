# Migration from install.sh to npx skills

As of v2.0.0, the PDK skills repository has migrated from individual `install.sh` scripts to the unified `npx skills` package manager ecosystem.

---

## What Changed

| Aspect | Before | After |
|--------|--------|-------|
| **Installation** | `curl ... \| bash` with interactive prompts | `npx skills add pdkproitf/skills` — automatic |
| **Tool selection** | Manual (choose 1-6) | Automatic detection |
| **Scope choice** | Manual (global or project) | Flag-based: `--global` or `--project` |
| **Versioning** | None | Full semantic versioning |
| **Discovery** | Manual repository browsing | Centralized registry: `npx skills find` |
| **Updates** | Manual reinstall | One command: `npx skills update` |

---

## How to Migrate

### 1. Uninstall Old Version (Optional)

If you previously installed via `install.sh`, the old skill file is still in place. You can leave it, or manually remove it:

**Claude Code (global):**
```bash
rm ~/.claude/skills/central-config/SKILL.md
```

**Claude Code (project):**
```bash
rm .claude/skills/central-config/SKILL.md
```

**Cursor (global):**
```bash
rm ~/.cursor/rules/central-config.mdc
```

**Other tools:** Similar pattern in `~/.{tool}/` or `.{tool}/`

### 2. Install via npx skills

**Install all skills (recommended):**
```bash
npx skills add pdkproitf/skills
```

**Install a specific skill:**
```bash
npx skills add pdkproitf/skills@central-workspace
```

This automatically detects your AI tool and installs to the correct location.

**Global installation (available for all projects):**
```bash
npx skills add pdkproitf/skills --global
```

### 3. Verify Installation

After installation, the skill should be available:

**Claude Code:**
```
/central-workspace
```

**Cursor, Windsurf, etc.:**
```
@central-workspace
```

### 4. What to Expect

The skill behavior is identical to v1.x. When you run it:

1. Your project's skills are scanned
2. Hardcoded paths are extracted
3. A `workspace.md` is created (renamed from `config.md` in v2.0)
4. All files are updated with config key references
5. Auto-load files are wired up with governance directives

---

## Why Migrate?

### Unified Experience
- Same installation command works for Claude Code, Cursor, Windsurf, Cline, GitHub Copilot, OpenAI Codex
- No more tool-specific `install.sh` variations

### Automatic Tool Detection
- npx skills automatically identifies your AI tool
- No interactive prompts or manual selection needed

### Version Management
- Update easily: `npx skills update`
- Pin to a specific ref: `npx skills add pdkproitf/skills#v1.2.0@central-workspace`

### Centralized Discovery
- Search for skills: `npx skills find`
- List installed: `npx skills list`

### Future-Proof
- As more skills are added, npx skills provides a single ecosystem
- Dependencies between skills can be managed automatically
- Shared versioning and updates across your skill library

---

## Troubleshooting

### npx skills command not found

Ensure you have Node.js and npm installed:
```bash
node --version
npm --version
```

If not, install from https://nodejs.org/. Then retry:
```bash
npx skills add pdkproitf/skills
```

### Skill installed to wrong location

Run the skill in the context where you want it (project directory for project install, anywhere for global with `--global` flag):

```bash
# Project install (run in your project directory)
npx skills add pdkproitf/skills

# Global install
npx skills add pdkproitf/skills --global
```

### Old install.sh location conflicts

If you have both old and new installations, they won't conflict — but you may want to remove the old one to avoid confusion. See "Uninstall Old Version" above.

### Reverting to an older version

To pin to a specific commit or tag:

```bash
npx skills add pdkproitf/skills#v1.2.0@central-workspace
```

Or check GitHub releases: https://github.com/pdkproitf/skills/releases

---

## Getting Help

- **npx skills docs:** `npx skills --help`
- **Skill documentation:** See [skills/engineers/central-workspace/README.md](skills/engineers/central-workspace/README.md)
- **Issues:** Report problems at https://github.com/pdkproitf/skills/issues

---

## Timeline

- **v2.0.0** (current): npx skills as primary installation method; `install.sh` deprecated
- **v2.1.0**: `install.sh` scripts removed
- **v2.x+**: Continued npx skills ecosystem development
