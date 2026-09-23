# implement

> Execute an approved spec — phase by phase, with verification and commits after each phase.

---

## What it does

`implement` reads a spec file produced by `feature` and executes it end to end. It follows the plan exactly, adapts only when the codebase has evolved since the spec was written, and surfaces mismatches rather than silently deviating.

For each phase it works structure first, detail second:
1. Locks the planned structure onto real files — components mapped to paths, seams confirmed injectable, `design-patterns` in `apply` mode where a pattern is being realized
2. Drafts seam-anchored test cases via `define-test-case`
3. Implements the detail inside those components
4. Runs the spec's validation commands and fixes failures
5. Updates checkboxes in the spec (`- [ ]` → `- [x]`)
6. Reports what was done and waits for confirmation before moving on
7. Commits the phase using the `commit` skill

If the spec has checkmarks from a prior session, it picks up from the first unchecked step.

---

## When to use

- Executing a plan created by `feature`
- Resuming interrupted implementation (works from checkboxes)
- When `resume-work` identifies the next unchecked spec step

---

## Install

```bash
npx skills add pdkproitf/skills@implement
```

---

## Usage

**Claude Code:**
```
/implement docs/specs/1711234567-feature-add-retry-logic.md
```

**Other tools:**
```
@implement <path to spec file>
```

If no path is provided, the skill will ask for one before proceeding.

---

## Output

After all phases complete:
- One bullet per phase summarising what was implemented
- Files created or modified
- Verification results (commands run and their outcomes)
- Output of `git diff --stat`

---

## Dependencies

- Invokes `onboard-project` automatically if project context hasn't been loaded yet in the current session
- Reads spec files written by `feature`
- Invokes `commit` for each completed phase
- Optionally runs the project's full test suite at the end (no dedicated test-runner or review skill exists yet — see TODOs in `SKILL.md`)
