# Writing a Specification

A specification records what an implementer cannot safely guess: observable behavior,
contracts, limits, risks and open choices. It may point to the repository for facts that
already exist, but it does not bury a real decision in implementation detail.

## State explicitly (as far as the change touches them)

- **Outcome and scope**: the result wanted, what is in, what is out, and existing behavior
  that must not move.
- **Behavior**: inputs, outputs, success and failure paths, side effects, states and allowed
  transitions, and the edge cases that matter.
- **Contracts**: request and response shapes, event payloads, stored formats, status values,
  error codes.
- **Invariants**: rules that must always hold (ownership, uniqueness, ordering).
- **Permissions**: who may do what, to which resources.
- **Compatibility**: clients, integrations and stored data that must keep working. If a
  stored artifact moves (a file, a table, a key), list every reader and every writer and
  check each one.
- **Reliability**: what happens on partial failure, retry, duplicate delivery, concurrency,
  timeout, cancellation.
- **Irreversible effects**: migrations, deletions, outgoing messages, payments, permission
  changes, with the safeguard and the recovery path.
- **Trade-offs** that impose a cost on someone else or on a later change.
- **Verification**: the observable results that prove it works, including failure results.
  A check on changed behavior, above all on something that must stop happening, has to fail
  against today's code; if it passes there already, it proves nothing.
- **Order of work** when the change has several steps or real risk: dependencies and the
  points where someone must decide before continuing.

Skip a dimension only when it truly does not apply; do not drop it quietly.

## Reference instead of copying

Point to directory layout, conventions, test commands, existing implementation, shared
schemas and prior decisions by path plus a section, symbol or endpoint. A reference
establishes what exists today. It cannot substitute for a new decision or a new obligation.
Never cite a file, symbol or test you did not read.

## Leave to the implementer

Names, internal decomposition, file placement, reversible technical choices, and the
internals of a milestone that can be verified on its own. Prescribe these only when they
change observable behavior.

## Label what you know

Mark important claims as one of:

- **Established**: backed by the request, the rules, or code read in this session.
- **Inference**: reasoned from established material, and labelled as such.
- **To verify**: an assumption the implementer must check first.
- **Open decision**: a choice that needs a human answer.

Something said only in conversation is not recorded until it is written into the spec or
into a source the implementer can reach.

## Open decisions

Never choose silently between options with different consequences. For each one write the
question, why it matters, the options with their costs, an optional recommendation marked
as not yet approved, and who decides and by when. An option that would undo something
already decided is labelled as such.

## Conflicting sources

When the request, the repository and the rules disagree, quote the conflicting statements,
name what depends on the outcome, and do not pick one on your own. Ask in interactive mode;
record it as an open decision otherwise. Keep specifying the parts that are not affected.

A specification can also disagree with itself: a requirement and an invariant that cannot
both be true, or two sections that give one responsibility to two owners. Quote both
statements and get an arbitration; do not quietly reconcile them.

## Coverage

For requirement-driven work, each requirement is either addressed, referenced precisely,
deferred as an open decision, or explicitly excluded, with the reason written down. Do not drop, soften or
reinterpret one. For free-form work, keep the stated intent and add no requirements.

## Before calling it done

Check: scope and non-goals are clear; every requirement is covered; behavior, contracts,
invariants and permissions are explicit; compatibility, failure handling and irreversible
effects have answers; verification is observable; open decisions are collected; references
are reachable.

## Example

Good:

```text
Scope: add an "out of stock" outcome to checkout. Successful orders are unchanged.
Contract: POST /orders answers 422 { "error": "OUT_OF_STOCK" } if any line is unavailable;
  nothing is stored.
Permissions: only the cart owner may place the order.
Compatibility: the web cart (src/cart/api.ts, parseError) reads `error`; keep that field.
Open decision: partial fulfilment. Rejecting the order matches today's behavior; shipping
  the available lines needs a new order state. Needs product input before work starts.
Verification: an unavailable line gives 422, stores no order, returns the documented code.
```

Bad:

```text
Add an OrderChecker class with a check() method, one test per branch.
Names the class and the tests, says nothing about the failure response, permissions or storage.
```
