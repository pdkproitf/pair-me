---
name: feature
description: Feature planning — research codebase, design options, write a structured spec/implementation plan to the project specs directory
input: "[adw_id] <prompt> — adw_id is optional; prompt is a plain-language description of the feature"
output: path to the written spec file in specs_dir
phase: plan
dependencies: [init]
---


## When to Use This Skill

Use this skill when the user:
- plan for X
- suggest to implement this feature

# Feature Planning

Generate a structured implementation plan for a feature and save it as a markdown file in the project's specs directory.

## Input Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| `adw_id` | (optional) Unique identifier for the AI Developer Workflow | `adw-42` |
| `prompt` | A plain-language description of the feature to plan | `"Add retry logic to the API client"` |

> **If `prompt` is missing or unclear, stop immediately and ask the user to provide it before doing anything else. `adw_id` is optional — if not provided, omit it from the filename and metadata.**

---

## Before You Start

### Check Argument Validity
- Confirm `prompt` describes a concrete feature (not a question or vague idea)
- If `prompt` fails this check, ask the user to clarify before continuing
- `adw_id` is optional; if not provided, proceed without it

---

## Process

Follow these steps **in order**. Do not skip ahead.

### Step 1: Load Project Context

1. If this is a new session and project context is not yet loaded, invoke the `init` skill before continuing
   - init loads project context and `# WORKSPACE` rules automatically
2. Use context loaded by init for the research phase

### Step 2: Research & Design

1. Create a checklist of everything that needs to be explored.
2. Run sub-tasks in parallel where possible.
3. Wait for **all** sub-tasks to finish before writing anything.
4. Present findings with 2–3 design options, each with clear pros and cons. Get confirmation on the chosen approach before moving to Step 3.
5. Follow the code quality rules from `# WORKSPACE` to generate implementation details.

### Step 3: Write the Plan

Use `specs_dir` (default: `docs/specs/`).

Save the file using this naming pattern:
```
{specs_dir}{unix_timestamp}-feature-{descriptive-name}.md
```
If `adw_id` was provided:
```
{specs_dir}{unix_timestamp}-feature-{adw_id}-{descriptive-name}.md
```

Replace `{descriptive-name}` with a short, hyphenated name derived from the feature (e.g., `add-retry-logic`, `create-workflow-api`, `implement-agent-logging`).

### Step 4: Define Test Cases

Invoke the `define_test_case` skill with the feature name to draft acceptance test cases in DSL format covering happy paths, edge cases, error scenarios, and auth.

Paste the output into the **Testing Strategy** section of the plan.

---

## Plan Format

```md
# Feature: <feature name>

## Metadata
- **adw_id:** `{adw_id if provided, otherwise omit this line}`
- **prompt:** `{prompt}`
- **created:** `{timestamp}`

---

## Feature Description
<What this feature does and why it matters. 2–4 sentences.>

## User Story
As a <type of user>,
I want to <action or goal>,
So that <the benefit or outcome>.

## Problem Statement
<The specific problem or gap this feature addresses. Be concrete — avoid vague language like "improve performance".>

## Solution Statement
<The chosen approach and why it solves the problem. Reference the design option selected in Step 2.>

---

## Relevant Files

<List every file relevant to this feature. For each, explain in one sentence why it matters.>

- `path/to/file` — <reason>

### New Files to Create

- `path/to/new_file` — <purpose>

---

## Implementation Plan

### Phase 1: Foundation
<Scaffolding, config changes, or prerequisite work needed before the main feature can be built.>

### Phase 2: Core Implementation
<The primary feature work — the logic, functions, classes, or APIs being added.>

### Phase 3: Integration
<Wiring the new code into the existing system — imports, registrations, config flags, etc.>

---

## Step-by-Step Tasks

> Execute every task in order, top to bottom. Do not skip steps.

### 1. <Task Name>
- <Specific, concrete action>

### 2. <Task Name>
- <Specific, concrete action>

---

## Testing Strategy

### Unit Tests
<What units of logic need tests, and what each test should verify.>

### Edge Cases
<Specific edge cases — not generic ones. Be precise about what could go wrong.>

---

## Acceptance Criteria

- [ ] <Criterion 1>
- [ ] <Criterion 2>

---

## Validation Commands

```bash
# <What this checks>
<command>
```

---

## Notes
<Optional: future considerations, known limitations, required libraries, or dependencies on other features.>
```

---

## Output

Return the full file path of the created plan, e.g.:
```
docs/specs/1711234567-feature-add-retry-logic.md
docs/specs/1711234567-feature-adw-42-add-retry-logic.md
```

---

## Constraints

1. **Resolve everything before writing** — No open questions in the final plan.
2. **Match existing conventions** — Mirror the naming, structure, and style found in the codebase.
3. **Incremental and testable** — Each phase should be shippable and verifiable on its own.
4. **Be specific** — Avoid vague tasks like "update the config". Write exactly what changes and where.
5. **Fail loudly** — If a required tool is missing or an argument is invalid, stop and say so clearly.
