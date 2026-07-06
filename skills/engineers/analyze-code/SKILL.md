---
name: analyze-code
description: Analyze and explain how a specific file, class, or feature works — trace data flow, logic, and dependencies with file paths and line numbers
input: file path, class name, or feature name
output: structured analysis covering entry points, core logic flow, key methods, data flow, dependencies, and error handling
phase: orient
---

# Analyze Code

Analyze HOW a component or feature works — trace data flow, explain logic, and map dependencies. Read code thoroughly before explaining.

## When to trigger

Use this skill when the user:
- asks how a specific file, class, or feature works
- asks to trace data flow, logic, or dependencies through existing code
- asks to "explain this component" or "walk me through this implementation"

## Variables
target: $ARGUMENTS — file path, class name, or feature name

## Steps

### Step 0: Check Existing Documentation
Check `docs_dictionary_dir` (default: `docs/doc_dictionary.md`) for entries whose `Files` overlap with `target` (or whose `Keywords` match it, if `target` is a class/feature name). Read any matching `core_docs_dir` files first — they may already answer part of the analysis and save re-deriving it from scratch.

### Step 1: Entry Point Analysis
- Find main entry points (routes, jobs, initializers)
- Trace initialization sequence
- Identify configuration loading

### Step 2: Core Logic Deep Dive
- Read implementation files thoroughly
- Follow function call chains
- Map data transformations
- Understand business rules

### Step 3: Integration Points
- External service calls
- Database interactions
- Job enqueuing
- API endpoints

### Step 4: Error & Edge Cases
- Error handling patterns
- Validation logic
- Fallback mechanisms

## Output Format

```
## Analysis: [Component/Feature Name]

### Overview
High-level description of what this component does and its role in the system.

### Entry Points
- `path/to/file.rb:45` — description

### Core Logic Flow
1. Step one at `file.rb:12`
2. Step two at `file.rb:34`
3. ...

### Key Methods
- `method_name` (`file.rb:56`) — what it does

### Data Flow
Input → Step → Step → Output

### Dependencies
- External: gem names, APIs
- Internal: other lib/app classes

### Error Handling
- What raises, what rescues, what gets logged
```

## Guidelines
- Include file paths and line numbers for every reference
- Follow data through the full call chain — don't stop at the surface
- Note side effects (DB writes, job enqueues, HTTP calls)
- Be specific — avoid vague descriptions
