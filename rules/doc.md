# Code Comments as Memory of Decisions

A comment is worth its place when it keeps something the code, the type checker, grep and
git history cannot tell a future reader: why a thing is the way it is. Anything else is
noise that goes out of date.

## When a comment is allowed

Both conditions must hold.

**1. The reason has a source outside the code.** You can name the moment: something the
user said, an alternative that was tried and dropped, a bug or incident that happened, a
constraint found in an outside system, a decision recorded in a spec. A decision that was
only planned or assumed does not count, and a reason reverse-engineered from the code is
guesswork.

**2. It passes four checks:**

1. It will still help in six months.
2. A careful reading of the code would not reveal it.
3. Without it, a developer could plausibly repeat the mistake.
4. No better home exists for it (commit message, test name, type).

If any check fails, write no comment. In particular, never write a comment that says what
the next line does.

## Kinds worth keeping

| Kind | Example |
|---|---|
| Invariant | `# Must run in a transaction: callers assume all-or-nothing.` |
| Rejected alternative | `# A cache layer was tried: no gain at this size, more moving parts. Kept simple.` |
| Performance trade-off | `# Quadratic on purpose: lists here never exceed 15 entries.` |
| Bug history | `# Guard added after a crash on blank titles in the PDF export.` |
| Outside constraint | `# The bank API rejects the call unless the idempotency key is set first.` |

## Decisions that span several places

If the same decision explains code in two or more places, state it once with a tag and
point to it elsewhere:

```ruby
# DECISION(rounding): amounts are rounded half-even to match the bank statement format.
def to_statement_amount(cents) ...

# see DECISION(rounding)
def to_invoice_line(cents) ...
```

The slug is lower-case kebab-case. Each `see DECISION(x)` must resolve to exactly one
`DECISION(x)` definition in the repository.

## Decisions with nothing to attach to

If the choice is a working convention ("we use pnpm") it belongs in the project's agent
instructions. If it is something enforceable, it belongs in a rule. Do not invent a code
location just to hang a comment on.

## Upkeep

- Delete a comment the moment it stops being true; a false reason is worse than none.
- Write comments in English, whatever language the team speaks.

## Example

```ruby
# Must stay inside the transaction: the webhook can be delivered twice, and the second
# delivery would otherwise double-credit the account.
def apply_credit(account, event) ...
```

```ruby
# increments the counter
counter += 1   # restates the code, adds nothing
```
