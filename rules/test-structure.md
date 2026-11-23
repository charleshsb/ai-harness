---
paths:
  - "**/*_spec.rb"
  - "**/*_test.rb"
  - "**/*.spec.ts"
  - "**/*.test.ts"
  - "**/*.spec.tsx"
  - "**/*.test.tsx"
  - "**/__tests__/**"
  - "**/spec/**"
  - "**/test/**"
  - "**/tests/**"
  - "**/test_*.py"
  - "**/*_test.py"
---

# How a Test Reads

Applies to any test, whether it was written first or later. Which tests exist is decided in
`test-scope`; when they are written is `tdd`.

## One behavior, named plainly

- A test checks a single behavior. Unrelated assertions belong in another test.
- Its name states the outcome in domain terms ("issues a credit note for a returned item"),
  never the method it calls ("test_refund").
- Every test has a real assertion; a test that cannot fail is worse than none.

## Failures, variants and the environment

- A test of a failure path checks what is specific to that failure: its code or message, and
  that nothing was written. A bare status that other errors also return lets the wrong
  failure pass.
- Code that picks between variants (a per-flag column, a per-role branch) gets fixtures with
  a different value for each variant. With equal values, picking the wrong one still passes.
- A test whose outcome depends on the developer's own setup, because it reads machine
  settings itself or runs a command that does, sets `HOME` and every config-path variable
  to a temporary directory. Otherwise the result depends on whose machine runs it.
- A regression test for an exception that was removed also asserts the outcome: the result
  exists and is right. A bare `not_to raise_error` is satisfied even if the fix now returns
  `nil`.

## Conditions and outcome

In RSpec-style suites, put the situation in a `context "when ..."` (or `describe`) block and
keep the `it` for the expected result. The `it` should not carry setup in its description.
Together they read as "when this holds, that happens".

## Arrange, Act, Assert

Each test body has three blocks in this order, separated by a blank line:

1. **Arrange**: build inputs and state.
2. **Act**: run the one behavior under test.
3. **Assert**: check the outcome.

Details:

- A single Act per test. A second Act means a second test.
- The Act sits on its own line and its result is stored in a variable, so the assertion does
  not secretly perform the call.
- No assertion before the Act, and no setup after it.
- Setup shared between tests (`let`, `before`, `beforeEach`, fixtures) counts as Arrange;
  only what is specific to the case stays in the body.
- One allowed shortcut: when the behavior under test is "this raises", the framework's own
  construct for it (RSpec's block form, `pytest.raises`, Jest's `toThrow`) joins Act and
  Assert in one statement.

## Example

```ruby
RSpec.describe Cart do
  context "when the coupon is expired" do
    let(:cart) { build(:cart, subtotal: 80, coupon: build(:coupon, expires_on: Date.yesterday)) }

    it "charges the full subtotal" do
      total = cart.total

      expect(total).to eq(80)
    end
  end
end
```

```ts
it("keeps the draft when saving fails", async () => {
  const store = createStore({ draft: "hello" })
  server.use(failingSave())

  await store.save()

  expect(store.draft).toBe("hello")
})
```

```ruby
# Good: identifies the failure and checks that nothing was stored
it "rejects a duplicate email with EMAIL_TAKEN" do
  create(:user, email: "ada@example.com")

  response = post_signup(email: "ada@example.com")

  expect(response.body).to include("EMAIL_TAKEN")
  expect(User.where(email: "ada@example.com").count).to eq(1)
end
```

```ruby
# Bad: conditions in the description, two Acts, the Act hidden inside the expectation
it "handles an expired coupon and then a valid one" do
  cart = build(:cart, subtotal: 80, coupon: expired_coupon)
  expect(cart.total).to eq(80)
  cart.coupon = valid_coupon
  expect(cart.total).to eq(60)
end
```
