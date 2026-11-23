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

# Clean Code

Code is read far more often than it is written. These constraints keep a change cheap to
review and cheap to revisit. They apply when writing, changing or reviewing source files.

## Before writing

- Read the neighbouring code first and follow its naming, layout, error style and logging.
- Search for an existing helper before adding one.
- Do not add an abstraction, pattern or dependency for a need that does not exist today.
- Do not optimize without a measurement pointing at the bottleneck. A speed-up nobody can
  observe, paid for in readability, is a loss.

## Naming

- A name says what the thing is for, not how it is built.
- Avoid `data`, `info`, `tmp`, `obj`, `handle`, `process`, `manage` as whole names.
- Functions are verb phrases (`parseInvoiceLines`); booleans read as questions
  (`isExpired`, `hasAccess`, `canRetry`, `shouldNotify`).
- If the right name will not come, the unit probably does two jobs.

## Functions

- One job each. If the summary needs "and", split it.
- Keep them short: past about 20 lines justify it, past 40 split it.
- Up to three parameters; beyond that pass a named structure.
- A boolean parameter is two functions in disguise.
- Hidden side effects are out. If a function mutates something, its name says so.

## Order of private methods

Lay private methods out by first call, walking depth first from the public entry point.
The file then reads like the execution. A helper used in several places
sits at its first use. When adding one, insert it where it is first called, not at the
bottom. Do not reorder an untouched file just to satisfy this.

## Flow and structure

- Flatten with guard clauses; no `else` after a `return` or `raise`.
- Give a complex condition a name instead of a comment.
- Keep business decisions apart from I/O, persistence, transport and formatting.
- Duplicated in two places: extract and name. Similar in three: consider an abstraction, but
  only if it is easier to follow than the repetition.

## Comments

Comment the reason, never the mechanics: a business constraint, an external quirk, a
rejected alternative. Delete comments that have gone stale. Never explain confusing code
with a comment when a rewrite would do.

## Refactoring safely

- Touch only what the task needs; leave unrelated code alone.
- Small steps, tests green between them.
- Rename or restructure, not both in one step. Never change behavior inside a refactor.
- No tests and non-trivial logic? Add a characterization test first.

## Example

Good:

```ts
function canRefund(order: Order, now: Date): boolean {
  if (order.status !== "delivered") return false
  if (order.refundedAt) return false

  return differenceInDays(now, order.deliveredAt) <= REFUND_WINDOW_DAYS
}
```

Bad:

```ts
function check(o: any, f: boolean, d: Date) {
  let r = false
  if (o.status === "delivered") {
    if (!o.refundedAt) {
      if (f || differenceInDays(d, o.deliveredAt) <= 14) {
        r = true
      }
    }
  }
  return r
}
```

```ruby
# Good: private methods follow call order
def call
  validate_cart
  charge_card
end

private

def validate_cart; end   # first call
def charge_card; end     # second call
```
