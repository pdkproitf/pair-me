# gather-dependency-context

> Learn a dependency repo's API surface without reading its code — from its service manifest.

---

## What it does

`gather-dependency-context` resolves a dependency repo by name or path, detects its documentation structure, and reads its service manifest (the portable registry entry `architecture` produces) to extract the API surface, event contracts, and constraints your project has to respect. It checks the manifest for staleness against the repo's recent history, presents a summary scoped to the task keywords you passed, and — only after you confirm — stores the entry in `CLAUDE.md` so the context reloads on later sessions instead of being re-derived.

Optionally scope it with a task description: only the parts of the manifest matching that task are loaded, keeping the context small.

---

## When to use

- Before integrating with, or calling into, another repo owned by your team
- When a cross-repo contract changed and your assumptions need refreshing
- Setting up a multi-repo workspace so each dependency's surface is captured once

---

## Install

```bash
npx skills add pdkproitf/skills@gather-dependency-context
```

---

## Usage

**Claude Code:**
```
/gather-dependency-context billing-service
/gather-dependency-context ../auth-service refresh token rotation
```

**Other tools:**
```
@gather-dependency-context <repo name or path> [task]
```

---

## Output

```
## <repo_name>

**Manifest**: path · last updated · staleness verdict

### API surface
- <endpoint / method> — contract

### Event contracts
- <event> — payload, producer, consumers

### Constraints
- <what callers must respect>
```

Plus, on confirmation, a matching dependency entry appended to `CLAUDE.md`.
