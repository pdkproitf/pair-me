# locate-code

> Find WHERE code lives for a feature or topic — fast, without reading file contents.

---

## What it does

`locate-code` maps the filesystem for a given concept and returns file paths grouped by layer. It deliberately stops at locations — no content analysis — so it runs fast and gives you a clean map to orient before diving deeper.

**When available**, it uses `codebase-memory-mcp` to search the code graph for precise, fast results. If MCP is unavailable, it falls back to filesystem search via grep and glob.

It searches across:
- `app/` — controllers, models, jobs
- `lib/` — services, clients, utilities
- `spec/` — test files mirroring source paths
- `config/` — configuration files
- `docs/` — documentation

Results are grouped by purpose so you know not just where something is, but what role each file plays.

---

## When to use

- Orienting in an unfamiliar codebase or feature area
- As the first step before running `analyze-code`
- When `init` invokes it during the Research phase
- Finding all files related to a concept before refactoring

---

## Install

```bash
npx skills add pdkproitf/skills@locate-code
```

---

## Usage

**Claude Code:**
```
/locate-code user authentication
/locate-code video publishing
/locate-code PaymentProcessor
```

**Other tools:**
```
@locate-code <feature name, topic, or concept>
```

---

## Output

```
## File Locations for [topic]

### Implementation Files
- `app/services/feature.rb` — one-line purpose

### Test Files
- `spec/services/feature_spec.rb` — what it tests

### Configuration
- `config/feature.yml` — what it configures

### Related Directories
- `lib/feature/` — contains X files

### Entry Points
- `app/controllers/feature_controller.rb` — where the topic is wired in
```
