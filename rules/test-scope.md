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

# Which Tests to Write

A suite is valuable in proportion to the behavior it protects, not the lines it executes.
Decide what deserves a test before writing one; how each test reads is in `test-structure`.

## Order of priority

1. The normal, successful path of each business behavior. One test per behavior.
2. An exceptional case only when it carries a stated business rule, for example "an order
   cannot be placed for an item that is out of stock".
3. Nothing else.

If you cannot state the rule behind an edge case in a single sentence, it is not worth a test.
One solid test of the main flow beats a pile of nil and type checks.

## What not to test

- What the framework or ORM already guarantees (presence validators, callbacks firing).
- What the language guarantees (nil propagation, implicit conversion).
- Private methods and internal state; test through the public behavior.
- Configuration: routes, env vars, migrations.
- Each side of a threshold, one test per value, when the rule is a single comparison.

## Tests do not change the code under test

When working on a test file, edit only test files. If a test fails, the first suspect is the
implementation. Rewriting production code so a test passes is a different task and needs a
separate decision.

## Example

Worth writing:

```ruby
it "charges the discounted price while a promotion is running"
it "refuses a booking when the room has no seats left"   # rule: no seat, no booking
```

Not worth writing:

```ruby
it "raises when the account is nil"
it "returns an empty string for an empty string"
it "does not discount at 99, at 100, or at 101"
```
