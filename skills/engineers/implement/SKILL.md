---
name: implement
description: Implement an approved spec — reads plan from specs_dir, executes phase by phase, updates checkboxes, verifies after each phase, and commits completed work
metadata:
  phase: "implement"
  input: "path to the spec file (e.g. docs/specs/1234567-feature-name.md)"
  output: "implemented feature with updated spec checkboxes, verification results, and committed phases"
  dependencies: "onboard-project, define-test-case, design-patterns, commit"
---

# Implement Plan

Implement an approved spec from `specs_dir`. Execute every step in order, verify after each phase, update checkboxes as you go, and commit completed work.

## When to trigger

Use this skill when the user:
- asks to implement, build, or start coding an approved spec/plan
- says to continue, resume, or pick back up an in-progress implementation
- points to a spec file and asks what's next or to proceed with it
- asks to implement a specific phase or step from a spec

## Variables

spec_file: $ARGUMENTS — path to the spec (e.g. `docs/specs/feature-to-bootstrap-package.md`)

---

## Step 1 — Load Project Context

1. If this is a new session and project context is not yet loaded, invoke the `onboard-project` skill before continuing
   - onboard-project loads project context — including `docs/CONTEXT.md` and any matching `docs/core/*.md` — and `# WORKSPACE` rules automatically
2. Use context loaded by onboard-project for the steps below

---

## Step 2 — Read and Orient

1. Read the spec file completely
2. Read all files listed under **Relevant Files** to understand the existing codebase before touching anything
3. Load context per `# WORKSPACE` → **Context Loading**, matching Tier 1 on `Files` (the spec's **Relevant Files**) or `Keywords` (its feature description) — matched docs may carry conventions this implementation must follow
4. Identify:
   - Which phases exist and which steps are already checked off (`- [x]`)
   - The first unchecked step — that is your starting point
   - The **Code Structure (High Level)** section — components, boundaries, seams, and recorded patterns. This is the structure Step 4.1 locks onto real files **before** any code is written; the phases below build the inside of those components, not a structure of your own choosing.
   - The **Validation Commands** section — you will run these after each phase

If the spec has no **Code Structure** section (written before that format existed), say so now — do not guess silently. Step 4.1 derives the structure instead, and reports it before implementing.

If no spec path is provided, ask for one before proceeding.

---

## Step 3 — Branch Setup

Use the `branch` convention from `# WORKSPACE` (default: `feat-{short-description}` or `feat-{adw_id}-{short-description}`).

If not already on a feature branch, create one. Skip if the branch already exists.

**Always ask before creating a branch unless the spec or user explicitly says to proceed automatically.**

---

## Step 4 — Implement Phase by Phase

For each phase in the spec's **Step by Step Tasks** section, work **structure first, detail second**. Nothing is written until 4.1 has settled where it goes.

1. **Lock the structure for this phase** — no code yet.

   1. Take the components and boundaries this phase touches from the spec's **Code Structure (High Level)** section, and map each one onto a **real path on disk**. A component the plan called existing must actually be there; a path that moved is structure drift (see below).
   2. **Reuse or extend before creating.** Before accepting any "New" component, check whether an existing file already owns that responsibility. If one does, extend it and follow its conventions. If nothing does, and the responsibility recurs, consider whether a new convention or reusable pattern is worth proposing — say so rather than inventing one silently.
   3. **Confirm every seam is genuinely injectable.** For each seam the plan named, point at the injection point in current code. A seam that cannot be stubbed independently is a design gap to fix **now**, while it is still cheap — not after the implementation has grown around it.
   4. **Invoke `design-patterns` in `apply` mode** when this phase realizes a pattern the spec recorded, or when a boundary turns out different on disk than the plan assumed. It maps pattern roles onto real units before any edit, and transforms one role at a time. Take its answer including "no pattern".
   5. If the spec carries no **Code Structure** section, derive components + boundaries + seams here from the phase's tasks and the codebase.
   6. **Report the mapping** — component → path, seam → injection point, patterns applied or rejected — and only then continue.

   The output of 4.1 is what the rest of the phase is measured against. Implementation detail may not move a responsibility across one of these boundaries; that is structure drift, not a detail decision.

2. **Draft the phase's test cases** — the seams are now confirmed (4.1.3), which is what `define-test-case` requires; invoke it for this phase only, seeded by the matching entries from the spec's **Testing Strategy** → **Behaviors to Cover** and the outer seam from **Test Level**. It returns seam-anchored DSL cases in build order; implement them one at a time, in that order, rather than writing every case for the phase upfront.

   **Integration by default, few unit cases.** Cases run through the outer seam of the phase with the real collaborators behind it; only true external boundaries are stubbed. A unit case needs a stated trigger (branch-dense pure logic, or a branch unreachable from outside) — `define-test-case` enforces the split and reports it. Do not add a unit case because a component is new, and never cover one behavior at both levels.

   **Prove the promise, keep edges thin, stay on the public surface.** Happy paths, real error scenarios, and authorization come first — they are what "works as intended" means. Edge cases are kept only where the code branches on them or the edge is itself a promise; the rest are recorded on an *Edges known, not covered* line, not written. Every seam is public: a class is tested through the methods it exposes, and a private helper is never a seam. If a case can only be written against a private helper, that is a missing public seam — report it as structure drift (4.1) rather than reaching past visibility.

   Draft per phase, never once for the whole spec — batching all phases here just relocates the upfront-dumping the skill warns against. Skip this step for a phase that introduces no testable behavior (pure config, scaffolding, a rename) and say so when you report the phase.

   If `define-test-case` still flags a design gap that 4.1.3 missed, resolve it before implementing, not after.

3. **Implement the detail** — now write the inside of each component locked in 4.1: methods, guards, error handling, wiring. Follow the spec's *intent* (the behavior it describes). Follow a step verbatim only when its structure is also consistent with 4.1, the codebase, and the conventions. Adapt when the codebase has evolved since the spec was written, or when a step's prescribed structure conflicts with the **Code Structure** section, the **Conventions to Follow** section, the **Code quality rules** below, `# WORKSPACE` conventions, or feedback memory — surface the conflict first (see "When the plan doesn't match reality"). A spec that names a specific class or method placement is expressing intent, not a mandate to violate the thin-model / jobs-orchestrate rules.
4. **Run verification** — execute the relevant commands from the spec's **Validation Commands** section, plus the cases drafted in step 2; fix any failures before marking the phase complete
5. **Update the spec** — check off completed items (`- [ ]` → `- [x]`) and mark the phase header `✅` when fully done
6. **Pause and confirm** — report what was done and ask the user to confirm before moving to the next phase
7. **Commit the phase** — invoke the `commit` skill to generate the commit message; ask for confirmation before committing

### When the plan doesn't match reality — or its own conventions

Surface mismatches immediately — never silently deviate, and never silently comply with a step that violates a convention. Three triggers:

- **Reality drift** — the codebase has changed since the spec was written (files moved, APIs differ).
- **Structure drift** — a component or boundary from the spec's **Code Structure** section does not exist on disk as described: a service that turned out to be a package, a seam that is not independently injectable, or an existing component that already owns a responsibility the plan gave to a new file. Found in Step 4.1; report it there, before writing code.
- **Convention conflict** — a step prescribes structure (a class boundary, a method on a model, logic in a job) that contradicts the spec's **Code Structure** or **Conventions to Follow** sections, the **Code quality rules** below, `# WORKSPACE`, or feedback memory. Example: spec says "add `cancel_siblings` class method on the model" but the thin-model rule says business logic belongs in a service.

Report either as:

```
Issue in Phase [N] — Step [X]:
Expected: <what the spec says>
Found:    <the reality drift, or the convention it conflicts with>
Impact:   <why this matters>
Proposed: <how you suggest proceeding — e.g. implement the behavior as a service instead>
```

### Code quality rules

`# WORKSPACE` → **Code** governs whether code should exist and how much of it (YAGNI, reuse, no unrequested abstractions). Step 4.1 governs *where* it goes. The rules below govern how the code that must exist is shaped — apply all three:

- **Respect the planned structure** — implementation detail stays inside the component 4.1 gave the responsibility to. Moving a responsibility across one of those boundaries is structure drift, to be surfaced, not a detail decision to be made quietly.
- **Keep functions small** — aim for 10–30 lines per method; if a method grows beyond that, it is doing too much
- **Single responsibility** — each class and method should have one clear concern; name it to reflect exactly what it does
- **Function composition** — a function may call multiple other functions as long as they all belong to the same logical concern; preferred over inlining everything into one long method
- **Thin model** — avoid adding business logic to models; create a service instead. The shape of that service is a Step 4.1 decision, not a detail one — `design-patterns` in `apply` mode is invoked there, once, and its answer (including "no pattern") is binding here.
- **Group related steps** — steps that are tightly coupled (e.g. building objects only to immediately pass them to the next call) should be grouped into a single method rather than exposed as individual steps in the orchestrator
- **Clean orchestrators** — top-level service methods should read as a sequence of high-level calls; implementation details live in helpers, not in the orchestrator
- **Naming convention** — use clear action verbs: `validate*()`, `extract*()`, `build*()`, `verify*()`, `check*()`, `process*()`, `persist*()`

---

## Step 5 — Resuming Interrupted Work

If the spec already has checkmarks when you start:
- Trust that checked items are done — do not re-implement them
- Pick up from the first unchecked `- [ ]` item
- If something looks wrong with prior work, flag it rather than silently redoing it

---

## Step 6 — Final Verification

After all phases are complete, run the full **Validation Commands** block from the spec. Every command must pass before reporting done. Fix any failures first.

Ask whether the user wants to run the project's full test suite (not just the spec's targeted commands). If yes, run it directly and fix any regressions before reporting done.

<!-- TODO: no dedicated test-runner skill exists yet — replace the manual run above with an invocation once one is built -->
<!-- TODO: no dedicated review skill exists yet — consider invoking one here, after verification and before reporting done, once one is built -->

---

## Report

While implementing, list all steps as they complete.

When all phases are complete:
- One bullet per phase summarising what was implemented
- Files created or modified
- Verification results (commands run and their outcomes)
- Output of `git diff --stat`
