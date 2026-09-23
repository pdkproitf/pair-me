---
name: define-test-case
description: Define integration/acceptance test cases in DSL format at confirmed public seams — sequenced into a build order, leading with happy paths, errors, and authorization. Integration-first; unit cases only where integration cannot reach the behavior; edges kept thin and recorded.
metadata:
  phase: "implement"
  input: "one implementation phase or slice, plus the behaviors it must satisfy"
  output: "sequenced DSL test cases in comment format — integration by default, each unit case justified, each seam public — plus the split, the edges left uncovered, and any design gap found"
---

# Define Test Cases

You are helping define automated acceptance test cases using a Domain Specific Language (DSL) approach.

**Integration-first, public surface only.** A case exercises the behavior through a real seam — a route, an exported function, a public method — with the real collaborators behind it, stubbing only true external boundaries. Prove the thing does its job before chasing edges. Expect most phases to produce a handful of integration cases and zero or one unit case.

## When to trigger

Use this skill when the user:
- asks to define or write acceptance test cases for a feature
- wants happy-path, error, and authorization scenarios drafted before writing the code that satisfies them
- is starting TDD/BDD-style work and needs test cases specified first

It is also invoked by the `implement` skill, once per phase, before that phase's code is written.

**Scope it to one phase or slice, never a whole feature.** Every case needs a confirmed seam — a real public interface — so this skill runs at implementation time, when the seam is being built and can still be changed. Running it against a whole feature plan before any code exists produces cases anchored to imagined interfaces, which is the upfront dumping the Anti-patterns section forbids. A feature plan should carry plain-language *behaviors to cover*; this skill turns one phase's worth of those into seam-anchored cases.

## Core Principles

1. **Comment-First Approach**: Always start by writing test cases as structured comments before any implementation.

2. **DSL at Every Layer**: All test code — setup, actions, assertions — must be written as readable DSL functions. No direct framework calls in test files.

3. **Implicit Given-When-Then**: Structure tests with blank lines separating setup, action, and assertion phases. Never use the words "Given", "When", or "Then" explicitly.

4. **Clear, Concise Language**: Function names should read like natural language and clearly convey intent.

5. **Follow Existing Patterns**: Study and follow existing test patterns, DSL conventions, and naming standards in the codebase.

6. **Design for Mockability**: If a case needs to stub a boundary (external API, payment/email provider, time, randomness) and that boundary isn't independently injectable in the current code (no dependency injection, no per-endpoint SDK-style function), flag this as a design gap before writing the case — don't write a setup function that pretends the seam is mockable when it isn't.

7. **Integration Over Unit** — see **Seam and Level**.

8. **Prove the Promise Before the Edges** — see **Coverage Checklist**.

9. **Public Surface Only** — see **Seam and Level**.

## Seam and Level — decide before writing

The level decides the seam, so settle both before the first case.

| Level | Seam | Behind the seam | Use it for |
|---|---|---|---|
| **Integration** (default, nearly all cases) | the outermost public entry of the phase — HTTP route, queue consumer, CLI command, or the public method of the service that owns the responsibility | real — real database, real internal services, real wiring; only true external boundaries stubbed | every behavior the feature promises: happy paths, rejections, permissions, error responses, persisted state, published events |
| **Unit** (exception, needs a reason) | one **exported** function, or one **public** method — never a private helper | collaborators stubbed | only what integration cannot reach — see the two triggers below |

### Public surface only

A case's seam is something a caller can reach: the methods a class exposes, the endpoint a route publishes, the function a module exports. Nothing else, at either level.

- **A class is tested through its public methods.** Private, protected, and internal helpers are not seams and get no cases of their own — they are covered *implicitly* by the public method that calls them. A private helper holding behavior no public method can reach is dead code or a missing public seam: report it as a finding, do not write a case for it.
- **Never reach past the visibility boundary** to make a case easier — no calling a private method directly, no renaming it public "for testing", no reflection, no `@ts-ignore`, no `_method` access. The tell: the case would not compile if the language enforced visibility.
- **A helper that deserves its own test deserves to be public** — on the class, or extracted to a module that exports it. Say that instead of testing around the visibility.

### A unit case is justified only when

1. **Combinatorics** — the behavior is pure, branch-dense logic (a pricing rule, a date/recurrence calculation, a parser, a state-transition table) where the interesting cases number in the dozens. Cover the *representative* path at integration level, and push the remaining combinations down to unit cases against that one function. This is the common legitimate case.
2. **Unreachable from outside** — the behavior genuinely cannot be provoked through the outer seam (a retry ceiling, a clock-dependent branch, a defensive guard on a state the outer API cannot construct). If it cannot be reached *and* is not combinatorial, first ask whether it should exist at all.

Anything else — "the service deserves its own test", "coverage on this class", "one test file per file" — is not a justification. Say so and write the integration case instead.

### Rules that keep the ratio honest

- **One behavior, one level.** A behavior covered by an integration case gets no mirror unit case. Two copies means two maintenance costs, and the unit copy breaks on refactors that changed no behavior.
- **Stub only true external boundaries** at either level: third-party APIs, payment/email providers, time, randomness. An internal collaborator you own stays real (see Naming Conventions).
- **Label every unit case.** Write `// Level: unit — <which trigger, in one clause>`. An unlabelled case is an integration case. No label, no reason, no unit case.
- **A phase whose cases are mostly unit is a structure signal, not a testing choice.** It usually means the outer seam is not reachable in a test harness. Surface that as a design gap to `implement` (its Step 4.1) rather than working around it with mocks.

## Test Case Structure

```javascript
// 1. Test Case Name Here
// Seam: <the public interface this case exercises, e.g. POST /api/checkout, CheckoutService.checkout()>
// Level: unit — <trigger>   ← only on a unit case; omit it and the case is integration

// setupFunction
// anotherSetupFunction
//
// actionThatTriggersLogic
//
// expectationFunction
// anotherExpectationFunction
```

### Structure Rules:
- **First line**: Test case name with number
- **Seam line**: The public interface under test — confirmed with the user before the case is written (see Workflow Step 2)
- **Level line**: Present **only** on a unit case, naming the trigger that justifies it. Absent means integration, which is the default.
- **Setup phase**: Functions that arrange test state (no blank line between them)
- **Blank line**: Separates setup from action
- **Action phase**: Function(s) that trigger the behavior under test
- **Blank line**: Separates action from assertions
- **Assertion phase**: Functions that verify expected outcomes (no blank line between them)

## Worked Example

One outer seam — `POST /api/checkout` — carries every integration case for the phase.

```javascript
// 1. User can checkout with a valid cart
// Seam: POST /api/checkout

// userIsLoggedIn
// cartHasItems([{ price: 10 }, { price: 5 }])
// regionTaxRateIs('DE', 0.19)
//
// userSubmitsCheckout()
//
// expectOrderConfirmed()
// expectOrderTotalEquals(17.85)

// 2. Checkout fails when payment is declined
// Seam: POST /api/checkout

// userIsLoggedIn
// cartHasItems([{ price: 20 }])
// paymentWillBeDeclined()
//
// userSubmitsCheckout()
//
// expectCheckoutFailed()
// expectOrderNotCreated()

// 3. Checkout is blocked for unauthenticated users
// Seam: POST /api/checkout

// userIsLoggedOut
// cartHasItems([{ price: 10 }])
//
// userSubmitsCheckout()
//
// expectResponseStatus(401)
// expectOrderNotCreated()

// 4. Tax is 0 for a zero-rated region with a business buyer
// Seam: calculateTax()
// Level: unit — combinatorics; 14 region × buyer-type combinations, case 1 covers the wiring

// buyerIsBusinessIn('EU-ZERO-RATED')
//
// calculateTax({ subtotal: 100 })
//
// expectTaxEquals(0)
```

Split: 3 integration, 1 unit. Case 1 proves the route wires tax into the order total (15 + 19% = 17.85), so the remaining 13 region/buyer combinations do not need 13 slow route cases — they belong at `calculateTax()`, and case 4 is the first of them.

Note case 1: the expectation asserts a concrete literal (`17.85`), not a recomputation of subtotal × rate — see Anti-patterns below.

## One Case, One Behavior

A case may call **multiple assertion functions** as long as they all verify **one behavior**. Case 1 above does this correctly: `expectOrderConfirmed()` and `expectOrderTotalEquals(17.85)` are two facts about the same outcome — the checkout succeeded, with the right total. That's one logical assertion, expressed as two calls.

Two assertions verifying **two different behaviors** means two cases, not one:

```javascript
// BAD — one case asserting two unrelated behaviors
// 1. User can checkout with a valid cart

// userIsLoggedIn
// cartHasItems([{ price: 10 }])
//
// userSubmitsCheckout()
//
// expectOrderConfirmed()
// expectConfirmationEmailSent()   // a second behavior smuggled into case 1
```

```javascript
// GOOD — split into two cases, each independently implementable
// 1. User can checkout with a valid cart

// userIsLoggedIn
// cartHasItems([{ price: 10 }])
//
// userSubmitsCheckout()
//
// expectOrderConfirmed()

// 2. Checkout sends a confirmation email

// userIsLoggedIn
// cartHasItems([{ price: 10 }])
//
// userSubmitsCheckout()
//
// expectConfirmationEmailSent()
```

Ask: "is this a second fact about the same outcome, or a second outcome?" If the second assertion could fail for a reason unrelated to the first, split the case.

## Anti-patterns

- **Implementation-coupled assertions** — naming an assertion after an internal call or mock instead of an observable outcome (`expectPaymentServiceCalledWith`, not `expectOrderConfirmed`). The tell: the assertion would need to change on a refactor even though behavior didn't. Assert only through the seam declared for the case.
- **Tautological expectations** — the expected value restates how the code computes it (`expectOrderTotalEquals(subtotal * (1 + rate))`) instead of a concrete, independently-known literal (`expectOrderTotalEquals(17.85)`). A tautological expectation passes by construction and can never disagree with the code.
- **Side-channel verification** — bypassing *your own* public interface to inspect *your own* internal state, e.g. querying the database directly instead of calling `getOrder()` (`expectRow('orders', { id })` instead of `expectOrderRetrievable(id)`). The tell: the assertion reaches around the seam instead of through it.
  - **Not the same as an external-system effect.** Verifying that *another* system was affected — `expectOrderInSage`, `expectCustomerBecamePartnerInExigo` — is a legitimate observable outcome for an acceptance test; that external system's state *is* the behavior being promised. The distinction is whose internals you're peeking at: yours (forbidden) vs. a downstream system's (the point of the test).
- **Private-surface cases** — a case whose seam is a private, protected, or internal function (`_calculateTax`, `#validate`, an unexported helper). It pins the case to an implementation detail that is free to change, so it breaks on refactors that changed no behavior. Test through the public method that calls it; if nothing public reaches it, report that instead.
- **Pyramid padding** — a unit case written because a class exists rather than because a behavior needs it: one test file per source file, a test per public method, "coverage on the new service", or a unit copy of a promise an integration case already covers. The tell: no trigger from **Seam and Level** applies. Delete it and keep the integration case. Its worst form stubs three internal collaborators to make the subject reachable — that is not isolation, it is a copy of the wiring, and it passes even when the real wiring is broken.
- **Edge-case sprawl** — a dozen boundary cases before the main behavior is proven, or one case per value in a range. Cover the promise first; keep only edges the code branches on, and record the rest as known-uncovered.
- **Upfront dumping** — writing every conceivable case in one giant pass with no build order. Sequence cases so the first is independently implementable before the next is written; each case is a tracer bullet, not part of a bulk spec.
- **Mechanism-named cases** — a case name that describes HOW instead of WHAT (`"Checkout calls paymentService.process"` instead of `"User can checkout with a valid cart"`). The case name is a capability statement — read it without the body and it should still describe a promise the system keeps, not a step it performs internally.

## Naming Conventions

### Setup Functions (Arrange)
- Describe state being created: `userIsLoggedIn`, `cartHasThreeItems`, `databaseIsEmpty`
- Use present tense verbs: `createUser`, `seedDatabase`, `mockExternalAPI`
- **Mock only true external boundaries** — third-party APIs, payment/email providers, time, randomness. Never design a setup function that mocks an internal collaborator or module you own (e.g. `mockOrderValidator` is a red flag) — that bakes implementation-coupling into the case before any code exists.

### Action Functions (Act)
- Describe the event/action: `userClicksCheckout`, `orderIsSubmitted`, `apiReceivesRequest`
- Use active voice: `submitForm`, `sendRequest`, `processPayment`

### Assertion Functions (Assert)
- Start with `expect`: `expectOrderProcessed`, `expectUserRedirected`, `expectEmailSent`
- Be specific: `expectOrderInSage`, `expectCustomerBecamePartnerInExigo`
- Include negative cases: `expectNoEmailSent`, `expectOrderNotCreated`

## Coverage Checklist

A **prompt for completeness of thinking, not a quota**. Within the confirmed seams, check whether each category applies; skip one with a one-line reason rather than inventing a case to fill it. It asks whether a *behavior* is covered, never whether a *class* is. The first question is always **does the thing do its job**, so the categories carry different weight:

1. **Happy Paths** *(primary)* — the function or endpoint does what it promises, with the ordinary inputs a real caller sends. Every phase has these, and they come first.
2. **Error Scenarios** *(primary)* — the failures a caller will actually hit: invalid input it can send, a dependency that is down, a timeout. Part of "works as intended", not a separate concern.
3. **Permission/Authorization** *(primary, when the seam is protected)* — always integration; an authorization rule proven against a stubbed authorizer proves nothing.
4. **Edge Cases & Boundary Conditions** *(secondary — see below)* — unusual but valid inputs, max/min values, empty states.

### Edge cases — do not chase them, do not drop them

Deliberately deprioritized, not excluded. Cover the main behavior first, then add an edge case only when it clears one of these bars:

- The edge is a **behavior the caller was promised** — an empty list returns `[]` rather than erroring, a zero quantity is rejected. That is a happy path or an error scenario wearing an edge-case label; keep it, and file it under 1 or 2.
- The edge is a **boundary the code branches on** — there is an explicit `if` for it, so the branch either works or it doesn't. One case at the boundary, not a sweep either side of it.

Everything else — combinations for their own sake, exotic inputs no caller can produce, one case per value in a range — is not written. **Name it and move on**: one line in the hand-off, so the gap is recorded rather than forgotten.

```
Edges known, not covered: unicode in the product name · quantity above int32 · concurrent
checkout on the same cart. None of these has a branch in the code today.
```

A boundary with dozens of genuinely interesting combinations is the combinatorics trigger in **Seam and Level**, never a reason for dozens of integration cases.

## Build Order

List cases in the order they'll be implemented, not by category. Each case must be independently implementable before the next is written — one seam, one case, one minimal implementation, repeat. This is what makes each case a **tracer bullet** that informs the next, instead of a bulk spec written against imagined behavior.

Weight (Coverage Checklist) decides *what gets written*; dependency decides *what gets implemented first*. Usually they agree — the happy path is both the highest-weight case and the prerequisite for the rest. When they disagree, **dependency wins**: a case whose prerequisite is not built yet cannot go first.

Mark the next case to implement:

```
1. User can checkout with a valid cart          ← Next
2. Checkout fails when payment is declined
3. Checkout is blocked for unauthenticated users
```

Re-order or insert cases as understanding changes between cycles — the list is a working backlog, not a fixed plan committed to upfront.

## Workflow

### 1. Load Context
Load context per `# WORKSPACE` → **Context Loading** (Tier 0 + Tier 1 for this feature) if that convention is present in this project; otherwise proceed directly to Step 2. Reading `docs_context`/`system_context` first keeps case names and DSL vocabulary in the project's domain language, and keeps documented invariants from being contradicted by a new case.

### 2. Understand the Slice
If a spec exists, start from its **Testing Strategy** → **Behaviors to Cover**, taking only the entries this phase is responsible for — those are the agreed behaviors, but they carry no seams, so you still confirm the seams below. Add behaviors the plan missed; drop any this phase does not touch.

**Name the outer seam first** — the route, consumer, CLI command, or public service method that owns the responsibility. One outer seam carries the phase's integration cases; the exception is a guard that only exists one layer further out (authorization enforced at the route above the service), which is tested where it lives. When the spec has a **Code Structure (High Level)** section, its **Seams** list is the input: those boundaries get stubbed, everything inside them stays real.

Then ask clarifying questions about:
- What functionality is being tested, and which systems/services are involved
- Expected behaviors and outcomes, and the failures a real caller will hit
- **Which seams will be tested — confirm before writing any case; no case is written against an unconfirmed seam, and no seam is private**
- Whether any behavior needs a unit case, and against which trigger

### 3. Research Existing Test Patterns
**IMPORTANT**: Before writing any test cases, search for:
- Existing acceptance/integration test files
- **The integration harness** — how a test boots the app, gets a database, authenticates a request, and stubs an external provider. This is what makes integration the cheap default; find it before deciding a behavior is "too hard to test end to end"
- Current DSL function naming conventions, and existing DSL functions that can be reused
- Test structure patterns, how tests are organized, and where unit tests live versus integration tests

If no integration harness exists in this project, say so plainly: building one is a real cost and the user decides whether this phase pays it or falls back to unit cases. Do not silently default to unit cases because the harness is missing.

### 4. Define Test Cases in Comments
Write each case in the structured comment format, then sequence per Build Order. Split any case that verifies more than one behavior (see One Case, One Behavior). Work in this order:

1. Happy-path cases — the thing does its job with ordinary inputs.
2. Error scenarios a real caller will hit.
3. Authorization cases, if the seam is protected.
4. An edge case **only** if it clears one of the two bars in the Coverage Checklist; list the rest as known-uncovered in one line.
5. A unit case for any behavior still uncovered, with its `// Level: unit — <trigger>` line.

Every seam must be public. If a case wants a private helper, stop and report it (see **Seam and Level**).

### 5. Identify Required DSL Functions
List all DSL functions needed:
- **Setup functions**: Functions that arrange test state
- **Action functions**: Functions that trigger the behavior under test
- **Assertion functions**: Functions that verify expected outcomes

### 6. Confirm with User
Present the sequenced test cases before any implementation and get confirmation — including the Build Order, so the user agrees on what gets implemented first. State with it:

- **The split** — how many integration cases, how many unit, and the trigger for each unit case
- **Edges known, not covered** — one line, so the gap is recorded rather than lost
- Any category skipped, and why
- Any design gap found — a seam that is not injectable, an outer seam not reachable in the harness, a missing harness, or a private helper holding behavior no public seam can reach
