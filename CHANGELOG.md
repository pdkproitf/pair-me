# Changelog

All notable changes to the PDK skills repository are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2026-06-11

### Breaking Changes

- **Removed:** `install.sh` scripts — use `npx skills install <skill>` instead
- **Renamed:** Skill `central-config` → `central-workspace` for clarity
- **Changed:** Config file name from `config.md` → `workspace.md` to reflect governance model
- **Changed:** Auto-load file now includes governance directive ensuring workspace authority

### New Features

- **npx skills integration:** Skills now published to the `npx skills` ecosystem for unified discovery and installation
- **Automatic tool detection:** `npx skills install` automatically detects Claude Code, Cursor, Windsurf, Cline, GitHub Copilot, OpenAI Codex
- **Version management:** Install specific versions: `npx skills install central-workspace@2.0.0`
- **Upgrade support:** One-command updates: `npx skills upgrade central-workspace`
- **Workspace governance:** New governance directive in auto-load files makes workspace authority explicit to all skills
- **Enhanced metadata:** Skill frontmatter now compatible with npx skills registry for better discovery

### Improvements

- **Documentation:** Complete rewrite for npx skills ecosystem
- **Migration guide:** New `MIGRATION.md` for users upgrading from v1.x
- **Installation:** Simplified from interactive multi-step process to single command
- **Scope handling:** Global vs project installation via flags (`--global`, `--project`)

### Migration Guide

See [MIGRATION.md](MIGRATION.md) for detailed upgrade instructions from v1.x.

**Quick start for existing users:**
```bash
npx skills install central-workspace
```

---

## [1.2.0] - 2026-06-10

### Added

- `docs_dictionary_dir` configuration key for context dictionary support
- Schema template now includes all documented path keys with defaults

### Fixed

- Removed environment variable reading from Step 1 (security improvement)
- Install path updated to respect `.claude/skills/` directory structure

---

## [1.1.0] - 2026-06-05

### Added

- Single-file mode: `central-config <filename>` to check individual skills
- Optional argument support for targeted configuration checks
- Clearer error messages for missing files

### Changed

- Step descriptions reorganized for clarity
- Config defaults always populated from schema template (not just on empty extraction)
- Improved governance directive in CLAUDE.md

---

## [1.0.0] - 2026-05-28

### Initial Release

**central-config skill:** Bootstrap AI workspace configuration across tools

- Detect current AI tool from system prompt
- Scan skill/command/agent files for hardcoded paths
- Extract paths into centralized `config.md`
- Update all files to use config key references
- Wire up auto-load files for cross-tool consistency

**Supported tools:**
- Claude Code
- Cursor
- GitHub Copilot
- Windsurf
- Cline
- OpenAI Codex

**Installation methods:**
- Global: `curl | bash` with interactive prompts
- Project: `curl | bash` with interactive prompts

**Features:**
- Tool detection from system prompt
- Global and project-level installation
- Idempotent (safe to run multiple times)
- 7-step process for configuration extraction and application
- Auto-load file management per tool
- Security rule definitions
- Quality and autonomy guidelines
- Code conventions tracking
