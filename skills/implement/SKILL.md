---
name: implement
description: Implement an approved spec — reads plan from specs_dir, executes phase by phase, updates checkboxes, verifies after each phase, and commits completed work
input: path to the spec file (e.g. docs/specs/1234567-feature-name.md)
output: implemented feature with updated spec checkboxes, verification results, and committed phases
phase: implement
dependencies: [init]
---

# Implement Plan

Implement an approved spec from `specs_dir`. Execute every step in order, verify after each phase, update checkboxes as you go, and commit completed work.

## Variables

spec_file: $ARGUMENTS — path to the spec (e.g. `docs/specs/feature-to-bootstrap-package.md`)

---

## Step 1 — Load Project Context

1. If this is a new session and project context is not yet loaded, invoke the `init` skill before continuing
   - init loads project context — including `docs/CONTEXT.md` and any matching `docs/core/*.md` — and `# WORKSPACE` rules automatically
2. Use context loaded by init for the steps below

---

## Step 2 — Read and Orient

1. Read the spec file completely
2. Read all files listed under **Relevant Files** to understand the existing codebase before touching anything
3. Check `docs_dictionary_dir` (default: `docs/context_dictionary.md`) for entries whose `Files` or `Keywords` overlap with the spec's **Relevant Files** or feature description; read any matching `core_docs_dir` files — they may document conventions this implementation should follow
4. Identify:
   - Which phases exist and which steps are already checked off (`- [x]`)
   - The first unchecked step — that is your starting point
   - The **Validation Commands** section — you will run these after each phase

If no spec path is provided, ask for one before proceeding.

---

## Step 3 — Branch Setup

Use the `branch` convention from `# WORKSPACE` (default: `feat-{short-description}` or `feat-{adw_id}-{short-description}`).

If not already on a feature branch, create one. Skip if the branch already exists.

**Always ask before creating a branch unless the spec or user explicitly says to proceed automatically.**

---

## Step 4 — Implement Phase by Phase

For each phase in the spec's **Step by Step Tasks** section:

1. **Implement all steps in the phase** — follow the spec exactly; adapt only when the codebase has evolved since the spec was written
2. **Run verification** — execute the relevant commands from the spec's **Validation Commands** section; fix any failures before marking the phase complete
3. **Update the spec** — check off completed items (`- [ ]` → `- [x]`) and mark the phase header `✅` when fully done
4. **Pause and confirm** — report what was done and ask the user to confirm before moving to the next phase
5. **Commit the phase** — invoke the `commit` skill to generate the commit message; ask for confirmation before committing

### When the plan doesn't match reality

Surface mismatches immediately — never silently deviate:

```
Issue in Phase [N] — Step [X]:
Expected: <what the spec says>
Found:    <actual situation>
Impact:   <why this matters>
Proposed: <how you suggest proceeding>
```

### Code quality rules

Key code quality rules (override with `# WORKSPACE` Quality section):

- **Keep functions small** — aim for 10–30 lines per method; if a method grows beyond that, it is doing too much
- **Single responsibility** — each class and method should have one clear concern; name it to reflect exactly what it does
- **Function composition** — a function may call multiple other functions as long as they all belong to the same logical concern; preferred over inlining everything into one long method
- **Thin model** — avoid adding business logic to models; create a service instead; research design patterns to apply to the logic
- **Group related steps** — steps that are tightly coupled (e.g. building objects only to immediately pass them to the next call) should be grouped into a single method rather than exposed as individual steps in the orchestrator
- **Clean orchestrators** — top-level service methods should read as a sequence of high-level calls; implementation details live in helpers, not in the orchestrator
- **No over-engineering** — only extract a helper if the logic is reused or if keeping it inline would make the method exceed the size guideline; do not create helpers for one-liners
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
