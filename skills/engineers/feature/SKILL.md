---
name: feature
description: Feature & chore planning — research codebase, design options, write a structured spec/implementation plan to the project specs directory
metadata:
  phase: "plan"
  input: "[adw_id] <prompt> — adw_id is optional; prompt is a plain-language description of the feature"
  output: "path to the written spec file in specs_dir"
  dependencies: "onboard-project, design-patterns"
---


## When to trigger

Use this skill when the user:
- asks to plan a feature or chore, or write an implementation plan
- suggests implementing or fixing something and no spec exists yet

# Feature & Chore Planning

Generate a structured implementation plan — for a new feature or a chore (fix, refactor, maintenance work with no new user-facing capability) — and save it as a markdown file in the project's specs directory.

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

1. If this is a new session and project context is not yet loaded, invoke the `onboard-project` skill before continuing
   - onboard-project loads project context and `# WORKSPACE` rules automatically
2. Use context loaded by onboard-project for the research phase

### Step 2: Research & Design

1. Load context per `# WORKSPACE` → **Context Loading**, matching Tier 1 on `Keywords` against this feature request — an existing doc may already cover a related or overlapping feature.
2. Create a checklist of everything that needs to be explored.
3. Run sub-tasks in parallel where possible.
4. Wait for **all** sub-tasks to finish before writing anything.
5. Collect the architectural conventions that bear on this feature — from `CLAUDE.md`, `docs_context`, matched `core_docs_dir` files, and feedback memory (e.g. thin-model, jobs-orchestrate-only). These populate the plan's **Conventions to Follow** section.
6. Present findings with 2–3 design options, each with clear pros and cons. Note if a matched dictionary entry overlaps with this feature. Get confirmation on the chosen approach before moving to Step 3.

### Step 3: Design the Code Structure (High Level)

**Always run this step.** The plan's job is to settle *what parts exist and how they fit* before anyone writes a line. Implementation decides the inside of each part; planning decides the parts.

1. **Invoke the `design-patterns` skill in `design` mode** on the chosen option. This is not conditional — even an option that adds no new abstraction gets the pass, because "no pattern; extend the existing service" is the answer that keeps the next step honest, and `design-patterns` reports rejected candidates for exactly that reason.
   - Feed it the chosen option, the conventions collected in Step 2.5, and the `find-patterns` result it asks for. A structure this codebase already uses beats a textbook-correct one.
2. **Name the components** the feature needs — each with one responsibility, in one sentence. A component is a layer participant (route, service, repository, job, adapter, client, consumer), not a method.
3. **Name the boundaries between them** — who calls whom, in which direction, and what crosses (a DTO, an ID, an event, a row). A boundary that is going to be stubbed in a test is a **seam**: say so, and say what gets injected there. This is the input `implement` needs before it can draft a single test case.
4. **Say for each component whether it is new or existing.** Existing wins by default: reuse or extend before creating. A new file needs a one-line reason why no existing component owns the responsibility.
5. **State the extension point** if the structure has one — how the next variant gets added ("a new provider implements the provider interface and registers in the provider map"). No extension point for a hypothetical second variant; one implementation needs no abstraction.
6. Record the result in the plan's **Code Structure** section, and record every surviving pattern in **Conventions to Follow** as a rule to validate against ("payment providers are selected through a strategy interface, not a conditional"), never as a class to create.

**Stay above the method line.** Components, responsibilities, boundaries, seams, and direction of dependency are in scope. Method names, method signatures, method length, helper extraction, and the internal shape of any component are **not** — those are decided against real code by `implement`, per Constraint 2.

### Step 4: Write the Plan

Use `specs_dir` (default: `docs/specs/`).

Determine `{type}`:
- `feature` — new user-facing capability
- `chore` — fix, refactor, or maintenance work with no new user-facing capability

Save the file using this naming pattern:
```
{specs_dir}{unix_timestamp}-{type}-{descriptive-name}.md
```
If `adw_id` was provided:
```
{specs_dir}{unix_timestamp}-{type}-{adw_id}-{descriptive-name}.md
```

Replace `{descriptive-name}` with a short, hyphenated name derived from the request (e.g., `add-retry-logic`, `create-workflow-api`, `fix-nil-publish-job-args`).

### Step 5: Enumerate Behaviors to Cover

List the behaviors this feature must be tested against — one line each, in plain language. Lead with **happy paths, error scenarios, and permission/authorization**: those prove the feature does its job and fails sanely, and they are the deliverable. Skip a category with a one-line reason rather than inventing an entry to fill it.

**Keep edge cases thin, but do not drop them.** List an edge only when the code branches on it, or when the edge itself is a promise to the caller (an empty list returns empty, not an error). Everything else goes on one **Edges known, not covered** line so the gap is recorded instead of forgotten. Chasing edges before the main behavior is proven is the failure mode this step exists to prevent.

Write these into the **Testing Strategy** → **Behaviors to Cover** section of the plan.

**These are proven by integration cases by default** — through the outer seam of the phase (route, consumer, CLI, or the public method of the owning service), with the real collaborators behind it. Record the outer seam and the external boundaries to stub under **Test Level**, and list a behavior as needing a unit case only when an integration case cannot reach it: branch-dense pure logic with dozens of combinations, or a branch not provokable from outside. "None" is the expected answer for most features — do not list a unit case because a component exists.

**Do not write DSL test cases here.** A DSL case requires a confirmed seam (the specific public interface under test). Step 3 names *which boundaries are seams*, but not the interface signature at each one — that is method-level, deliberately left to implementation time (see Constraint 4). Seam-anchored cases are drafted by the `implement` skill, per phase, once the seam exists. What belongs in the plan is *what must hold true*, not *where it is asserted*.

---

## Plan Format

```md
# {Feature|Chore}: <name>

## Metadata
- **adw_id:** `{adw_id if provided, otherwise omit this line}`
- **prompt:** `{prompt}`
- **created:** `{timestamp}`

---

## Feature Description
- **Context:** <one bullet — relevant background or current state>
- **Problem:** <one bullet — what's wrong or missing>
- **Solution:** <one bullet — what this plan does about it>

## User Story
As a <type of user>,
I want to <action or goal>,
So that <the benefit or outcome>.

## Problem Statement

**Where**
- `path/to/file:line` — <short code snippet or reference showing the issue>

**Why**
- <root-cause bullet — be concrete, avoid vague language like "improve performance">

**What happens**
- <consequence bullet — the observable effect of the problem>

## Solution Statement

1. <step of the chosen approach — reference the design option selected in Step 2>
2. <step of the chosen approach>

---

## Relevant Files

<List every file relevant to this feature. For each, explain in one sentence why it matters.>

- `path/to/file` — <reason>

### New Files to Create

- `path/to/new_file` — <purpose>

---

## Conventions to Follow

<Architectural rules this feature must respect, pulled from `CLAUDE.md`, `docs_context`, matched `core_docs_dir` files, and feedback memory. These are a checklist to validate the implementation against — NOT step prescriptions. Do not restate structure the codebase already enforces; list only rules that plausibly bear on this feature and could be gotten wrong.>
<Pattern: `for new service, logic let think whether existing conventions apply or code that could solve the problem, and if so, try to follow them, use them. else think about new conventions and code patterns that could be useful for this feature, which are reusable, and if so, propose them to the team.`>`>
- <e.g. Thin model — business logic (validation, cancellation, orchestration) belongs in a service, not a model method>
- <e.g. Jobs orchestrate only — load, guard, call service, handle result; no business logic in the job>
- <convention> — <where it applies in this feature>

---

## Code Structure (High Level)

<Components, boundaries, and seams settled in Step 3. Responsibilities and connections
only — no method names, no signatures, no internal shape. `implement` maps this onto
real files per phase and decides the inside of each component against real code.>

### Components

| Component | Responsibility (one sentence) | New / Existing |
|---|---|---|
| `<layer participant>` | <single responsibility> | Existing — `path/to/file` |
| `<layer participant>` | <single responsibility> | New — <why no existing component owns this> |

### Boundaries

- `<caller>` → `<callee>` — <what crosses: DTO / ID / event / row> · <transport if it leaves the process>

### Seams (to be stubbed in tests)

- `<boundary>` — <what gets injected, and why this boundary must be independently injectable>

### Extension Point

- <how the next variant is added — or "none; one implementation, no abstraction">

### Patterns

- <pattern> — <problem it solves> · confidence: HIGH | MEDIUM | LOW
- Rejected: <pattern> — <disqualifying reason>

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

### Behaviors to Cover

<One line per behavior that must hold, in plain language — no seams, no DSL, no assertion function names. These become seam-anchored DSL cases during implementation, via the `define-test-case` skill. Note any category that does not apply, with a one-line reason. The first three groups are the deliverable; edges are deliberately thin.>

**Happy paths** *(primary — the feature does its job)*
- <e.g. A user with a valid cart can complete checkout and gets a confirmed order>

**Error scenarios** *(primary — the failures a real caller hits)*
- <e.g. The payment provider declines>

**Permission / authorization** *(primary, if the seam is protected)*
- <e.g. An unauthenticated user cannot check out>

**Edge cases & boundary conditions** *(secondary — only edges the code branches on, or an edge the caller was promised)*
- <e.g. Checkout with an empty cart is rejected — the code has an explicit guard for it>

**Edges known, not covered**
- <one line naming the edges deliberately left out, so the gap is recorded — or "none">

### Test Level

<Integration is the default: each behavior above is proven through the outer seam named in **Code Structure** → **Seams**, with the real collaborators behind it and only true external boundaries stubbed. Name the outer seam here.>

- **Outer seam:** `<HTTP route / queue consumer / CLI command / public service method>` — must be public; private helpers are covered through it, never directly
- **External boundaries to stub:** `<third-party API, provider, clock, randomness>` — or "none"

<Unit cases are the exception and need a reason. List only behaviors that an integration case cannot reach — branch-dense pure logic where the combinations run to dozens, or a branch not provokable from outside. One line each with the reason. Write "none" when there are none; that is the expected answer for most features.>

- <behavior> — unit, because <combinatorics: N combinations of X × Y | not reachable through the outer seam>

<No behavior appears both here and above. `implement` drafts the actual cases per phase via `define-test-case`, which enforces this split.>

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
docs/specs/1711234567-chore-fix-nil-publish-job-args.md
```

---

## Constraints

1. **Resolve everything before writing** — No open questions in the final plan.
2. **Match existing conventions** — Mirror the naming, file organization, and API patterns found in the codebase. Prescribe **component-level** structure in Step 3 (which components exist, what each is responsible for, how they connect, which boundaries are seams). Do not prescribe **method-level** structure (method names, signatures, method length, helper extraction, the inside of any component) — that is decided against real code at implementation time, not planning time.
3. **Incremental and testable** — Each phase should be shippable and verifiable on its own.
4. **Be specific — about *what* and *where*, not *how*** — Avoid vague tasks like "update the config". Name the file and the behavior that changes. "Where" now includes the **owning component** settled in Step 3 — which participant holds the responsibility, and which boundary it sits behind. It stops there: do not invent a specific method to add, or decide how the component splits internally — that is method-level (see constraint 2), validated against the **Conventions to Follow** section at implementation time. Write "cancel sibling jobs when one fails — owned by the clip publishing service" (behavior + component), not "add `PublishClipJob.cancel_siblings` class method" (method-level).
5. **Fail loudly** — If a required tool is missing or an argument is invalid, stop and say so clearly.
