# define-test-case

> Define acceptance test cases in DSL format at confirmed seams — comment-first, sequenced into a build order, covering happy paths, edge cases, errors, and authorization.

---

## What it does

`define-test-case` generates structured test case definitions for a feature before any implementation begins. It searches the codebase for existing DSL conventions and test patterns, then writes test cases as structured comments using those conventions — each anchored to a **seam** (the public interface under test) confirmed with the user before it's written.

Each test case follows an implicit Given-When-Then structure separated by blank lines:

```javascript
// 1. Test Case Name Here
// Seam: <the public interface this case exercises>

// setupFunction
// anotherSetupFunction
//
// actionThatTriggersLogic
//
// expectationFunction
// anotherExpectationFunction
```

Cases are checked against a **coverage checklist**, not a quota — you can't test everything, so completeness is scoped to the seams already confirmed:
- **Happy paths** — standard successful flows
- **Edge cases** — boundary conditions, unusual but valid inputs
- **Error scenarios** — invalid inputs, service failures, timeouts
- **Boundary conditions** — maximum/minimum values, empty states
- **Authorization** — access control scenarios

They're then arranged into a **build order** — sequenced so the first case is independently implementable before the next is written, each one a tracer bullet rather than part of a bulk spec written up front.

---

## When to use

- Before implementing a feature — write tests first as comments
- As a step within `feature` — it's invoked automatically to populate the Testing Strategy section
- When onboarding a QA engineer to a new area of the codebase

---

## Install

```bash
npx skills add pdkproitf/skills@define-test-case
```

---

## Usage

**Claude Code:**
```
/define-test-case user checkout flow
/define-test-case API retry logic
```

**Other tools:**
```
@define-test-case <feature name or description>
```

---

## Output

Structured DSL test cases in comment format, each tagged with its seam and sequenced into a build order (next case to implement marked first), with a list of required DSL functions (setup, action, assertion) that need to be implemented. A case verifying more than one behavior is split before being handed off.
