---
paths:
  - "**/*.rb"
  - "**/*.rake"
  - "**/*.gemspec"
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
---

# Test-Driven Development

A test written after the code tends to describe what the code happens to do. A test written
first describes what it should do, and proves it can fail. Apply this where decisions live;
do not ritualize it where there is nothing to decide.

## Where it applies

Test first when the code makes a decision: services, domain objects, validators,
serializers, background jobs, pure functions with conditions or arithmetic, and React hooks
that hold state or effects.

Test first is optional for wiring: route tables, config, a CRUD controller with no branch,
a purely presentational component, framework boilerplate.

## Rules

- Write the failing test before the implementation, and run it.
- Read the failure. It must fail because the behavior is missing, not because of a typo, a
  missing require or a wrong import.
- Write the smallest change that turns it green. Anything more is untested code.
- Refactor only when the suite is green, never while a test is red.
- How a single test is laid out is covered in `test-structure`; which tests deserve to
  exist is covered in `test-scope`.

## Example

Good: the test comes first and pins the rule.

```ruby
RSpec.describe Subscription do
  context "when the trial has ended" do
    it "bills the full monthly price" do
      subscription = described_class.new(plan_price: 20, trial_ends_on: Date.new(2025, 1, 1))

      amount = subscription.amount_due(on: Date.new(2025, 1, 2))

      expect(amount).to eq(20)
    end
  end
end
# red: NoMethodError for amount_due -> now implement it
```

Bad: the implementation exists, and the test is bent around it.

```ruby
it "responds to amount_due" do
  expect(Subscription.new(plan_price: 20)).to respond_to(:amount_due)
end
# green on day one, fails on nothing, protects nothing
```
