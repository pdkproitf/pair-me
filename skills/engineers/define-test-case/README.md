# define-test-case

> Define integration/acceptance test cases in DSL format at confirmed public seams — comment-first, sequenced into a build order, leading with happy paths, errors, and authorization. Integration-first; unit cases only where integration cannot reach the behavior; edges kept thin and recorded; private helpers never tested directly.

---

## What it does

`define-test-case` generates structured test case definitions for one implementation phase, before that phase's code is written. It searches the codebase for existing DSL conventions and test patterns, then writes test cases as structured comments using those conventions — each anchored to a **seam** (the public interface under test) confirmed with the user before it's written.

**Integration-first.** The default seam is the outer entry of the phase — HTTP route, queue consumer, CLI command, or the public method of the owning service — with the real collaborators behind it and only true external boundaries stubbed (third-party APIs, providers, time, randomness). A unit case has to earn its place: branch-dense pure logic where the combinations run to dozens, or a branch that genuinely cannot be provoked from outside. Each unit case carries a `// Level: unit — <trigger>` line, and no behavior is covered at both levels. Most phases come out as several integration cases and zero or one unit case.

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

**Public surface only.** A case's seam is something a caller can reach — an exported function, a public method, a route. A class is tested through the methods it exposes; private and internal helpers are covered implicitly by the public method that calls them, never directly. A private helper holding behavior no public seam can reach is reported as a finding (dead code, or a missing public seam), not tested around with reflection or a visibility downgrade.

Cases are checked against a **coverage checklist**, not a quota — you can't test everything, so completeness is scoped to the seams already confirmed. The groups are weighted, not equal:
- **Happy paths** *(primary)* — the thing does what it promises with ordinary inputs
- **Error scenarios** *(primary)* — the failures a real caller hits: bad input, dependency down, timeout
- **Authorization** *(primary, when the seam is protected)* — always integration; a rule proven against a stubbed authorizer proves nothing
- **Edge cases & boundary conditions** *(secondary)* — deliberately thin: kept only when the code branches on the edge, or the edge is itself a promise to the caller. The rest are named on an **Edges known, not covered** line so the gap is recorded rather than swept.

They're then arranged into a **build order** — sequenced so the first case is independently implementable before the next is written, each one a tracer bullet rather than part of a bulk spec written up front.

---

## When to use

- Before writing the code for a phase or slice — write tests first as comments
- As a step within `implement` — it's invoked automatically at the start of each phase, seeded by the spec's **Behaviors to Cover**
- When onboarding a QA engineer to a new area of the codebase

**Scope it to a phase, not a whole feature.** Every case names a seam, so the interface has to be real (or about to be built) for the case to mean anything. That's why it runs during implementation rather than during planning — a spec written before any code exists can commit to *behaviors*, but not to the interfaces those behaviors are asserted through.

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
@define-test-case <phase or slice, and the behaviors it must satisfy>
```

---

## Output

Structured DSL test cases in comment format, each tagged with its seam and sequenced into a build order (next case to implement marked first), with a list of required DSL functions (setup, action, assertion) that need to be implemented. A case verifying more than one behavior is split before being handed off. The hand-off states the split — how many integration cases, how many unit cases and the trigger for each — plus any design gap found (a seam that is not injectable, an outer seam unreachable in the harness, or no integration harness in the project).
