---
name: define_test_case
description: Define acceptance test cases in DSL format — happy paths, edge cases, error scenarios, and authorization
input: feature name or description to generate test cases for
output: structured DSL test cases in comment format covering all scenario types
phase: test
---

# Define Test Cases

You are helping define automated acceptance test cases using a Domain Specific Language (DSL) approach.

## Core Principles

1. **Comment-First Approach**: Always start by writing test cases as structured comments before any implementation.

2. **DSL at Every Layer**: All test code — setup, actions, assertions — must be written as readable DSL functions. No direct framework calls in test files.

3. **Implicit Given-When-Then**: Structure tests with blank lines separating setup, action, and assertion phases. Never use the words "Given", "When", or "Then" explicitly.

4. **Clear, Concise Language**: Function names should read like natural language and clearly convey intent.

5. **Follow Existing Patterns**: Study and follow existing test patterns, DSL conventions, and naming standards in the codebase.

## Test Case Structure

```javascript
// 1. Test Case Name Here
// Seam: <the public interface this case exercises, e.g. CheckoutService.checkout(), POST /api/checkout>

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
- **Seam line**: The public interface under test — confirmed with the user before the case is written (see Workflow Step 1)
- **Setup phase**: Functions that arrange test state (no blank line between them)
- **Blank line**: Separates setup from action
- **Action phase**: Function(s) that trigger the behavior under test
- **Blank line**: Separates action from assertions
- **Assertion phase**: Functions that verify expected outcomes (no blank line between them)

## Worked Example

```javascript
// 1. User can checkout with a valid cart
// Seam: CheckoutService.checkout()

// userIsLoggedIn
// cartHasItems([{ price: 10 }, { price: 5 }])
//
// userSubmitsCheckout()
//
// expectOrderConfirmed()
// expectOrderTotalEquals(15)

// 2. Checkout fails when payment is declined
// Seam: CheckoutService.checkout()

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
```

Note case 1: the expectation asserts a concrete literal (`15`), not a recomputation of the cart sum — see Anti-patterns below.

## Anti-patterns

- **Implementation-coupled assertions** — naming an assertion after an internal call or mock instead of an observable outcome (`expectPaymentServiceCalledWith`, not `expectOrderConfirmed`). The tell: the assertion would need to change on a refactor even though behavior didn't. Assert only through the seam declared for the case.
- **Tautological expectations** — the expected value restates how the code computes it (`expectOrderTotalEquals(sumOfCartItems(cart))`) instead of a concrete, independently-known literal (`expectOrderTotalEquals(15)`). A tautological expectation passes by construction and can never disagree with the code.
- **Upfront dumping** — writing every conceivable case in one giant pass with no build order. Sequence cases so the first is independently implementable before the next is written; each case is a tracer bullet, not part of a bulk spec.

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

## Test Coverage Requirements

Cover all of the following scenario types:
1. **Happy Paths** — standard successful flows
2. **Edge Cases & Boundary Conditions** — unusual but valid inputs, max/min values, empty states
3. **Error Scenarios** — invalid inputs, service failures, timeouts
4. **Permission/Authorization** — access control scenarios

## Workflow

### 1. Understand the Feature
Ask clarifying questions about:
- What functionality is being tested
- Which systems/services are involved
- Expected behaviors and outcomes
- Edge cases and error conditions
- **Which seams (public interfaces) will be tested — confirm before writing any case; no case is written against an unconfirmed seam**

### 2. Research Existing Test Patterns
**IMPORTANT**: Before writing any test cases, search for:
- Existing acceptance/integration test files
- Current DSL function naming conventions
- Test structure patterns used in this project
- Existing DSL functions that can be reused
- How tests are organized and grouped

### 3. Define Test Cases in Comments
Write each test case in the structured comment format, covering all scenario types above.

### 4. Identify Required DSL Functions
List all DSL functions needed:
- **Setup functions**: Functions that arrange test state
- **Action functions**: Functions that trigger the behavior under test
- **Assertion functions**: Functions that verify expected outcomes

### 5. Confirm with User
Present the test cases before any implementation and get confirmation.
