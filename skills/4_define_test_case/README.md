# 4_define_test_case

> Define acceptance test cases in DSL format — comment-first, covering happy paths, edge cases, errors, and authorization.

---

## What it does

`4_define_test_case` generates structured test case definitions for a feature before any implementation begins. It searches the codebase for existing DSL conventions and test patterns, then writes test cases as structured comments using those conventions.

Each test case follows an implicit Given-When-Then structure separated by blank lines:

```javascript
// 1. Test Case Name Here

// setupFunction
// anotherSetupFunction
//
// actionThatTriggersLogic
//
// expectationFunction
// anotherExpectationFunction
```

Coverage includes:
- **Happy paths** — standard successful flows
- **Edge cases** — boundary conditions, unusual but valid inputs
- **Error scenarios** — invalid inputs, service failures, timeouts
- **Boundary conditions** — maximum/minimum values, empty states
- **Authorization** — access control scenarios

---

## When to use

- Before implementing a feature — write tests first as comments
- As a step within `2_feature` — it's invoked automatically to populate the Testing Strategy section
- When onboarding a QA engineer to a new area of the codebase

---

## Install

```bash
npx skills install 4_define_test_case
```

---

## Usage

**Claude Code:**
```
/4_define_test_case user checkout flow
/4_define_test_case API retry logic
```

**Other tools:**
```
@4_define_test_case <feature name or description>
```

---

## Output

Structured DSL test cases in comment format, organized by scenario type, with a list of required DSL functions (setup, action, assertion) that need to be implemented.
