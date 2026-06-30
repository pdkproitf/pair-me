---
skill: 1_locate-code
description: Locate where code lives for a feature or topic — returns grouped file paths only, no content analysis
input: feature name, topic, or concept to locate
output: file paths grouped by layer (implementation, tests, config, entry points)
phase: orient
---

# Locate Code

Find WHERE code lives in the codebase for a given feature or topic. Return file locations grouped by purpose — do NOT read or analyze file contents.

## Variables
topic: $ARGUMENTS

## Steps

### Step 1: Broad Search
- Grep for keywords related to the topic
- Glob for file patterns matching the topic name
- LS to explore relevant directories

### Step 2: Refine by Layer
- `app/` — controllers, models, jobs
- `lib/` — services, clients, utilities
- `spec/` — tests mirroring source paths
- `config/` — configuration files
- `docs/` — documentation

### Step 3: Categorize and Return

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
