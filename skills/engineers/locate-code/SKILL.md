---
name: locate-code
description: Locate where code lives for a feature or topic — returns grouped file paths only, no content analysis
metadata:
  phase: "orient"
  input: "feature name, topic, or concept to locate"
  output: "file paths grouped by layer (implementation, tests, config, entry points)"
  dependencies: "codebase-memory-mcp, graphify"
---

# Locate Code

Find WHERE code lives in the codebase for a given feature or topic. Return file locations grouped by purpose — do NOT read or analyze file contents.

## When to trigger

Use this skill when the user:
- asks "where does X live" or "where is Y implemented"
- wants file paths grouped by layer without content analysis
- needs a quick location lookup, not an explanation of how the code works

## Variables
topic: $ARGUMENTS

## Steps

### Step 0: Decide Which Tool to Use (read-only)

This skill only **reads** indexes — it never builds them. Building is the `codebase-indexing`
skill's job. If an index is missing, fall back immediately; don't block on a build.

**Try codebase-memory-mcp first:**
1. Call `index_status`, then `search_graph(name_pattern=topic, ...)`
2. **If indexed and fresh**: Proceed to Step 1 (MCP search)
3. **If not indexed / unavailable**: Try Step 0b (do not trigger `index_repository`; optionally suggest the user run `codebase-indexing`)

**Step 0b: Try graphify as fallback:**
1. Check if `.docs/indexing/graphify/` exists and try a graphify query
2. **If succeeds**: Use graphify to find semantic matches (Step 2b)
3. **If unavailable**: Proceed to Step 2 (manual filesystem search)

### Step 1: Search via codebase-memory-mcp (Preferred)
- Use `search_graph(name_pattern, label_pattern, qn_pattern)` to find functions, classes, and routes matching topic
- Use `search_code(pattern)` for text-based search with graph augmentation
- Use `get_architecture()` to understand project layers and organization
- **Proceed to Step 3 to categorize and return**

### Step 2b: Search via graphify (Fallback)
- Use graphify's graph query to find semantically related nodes (entities, classes, workflows)
- Look for nodes that match or relate to the topic
- Extract file paths from node information
- **Proceed to Step 3 to categorize and return**

### Step 2: Manual Filesystem Search (Last Resort)
- Grep for keywords related to the topic
- Glob for file patterns matching the topic name
- LS to explore relevant directories
- **Proceed to Step 3 to categorize and return**

### Step 3: Categorize by Layer and Return
- `app/` — controllers, models, jobs
- `lib/` — services, clients, utilities
- `spec/` — tests mirroring source paths
- `config/` — configuration files
- `docs/` — documentation

## Output Format

```
## File Locations for [topic]

### Implementation Files
- `path/to/file.rb` — one-line purpose

### Test Files
- `spec/path/to/file_spec.rb` — what it tests

### Configuration
- `config/...` — what it configures

### Related Directories
- `lib/feature/` — contains X files

### Entry Points
- `app/controllers/...` — where the topic is wired in
```

## Guidelines
- Report locations only — do not read file contents
- Check multiple naming patterns (singular/plural, snake_case)
- Include file counts for directories
- Note naming conventions observed
