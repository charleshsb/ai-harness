# Reviewing for Correctness and Structure

How to review the logic and shape of a change. The standards being checked live in `clean`
and the language rules; this rule is about the reviewing, and it does not repeat them.

## What a reviewer adds

A linter finds formatting. A reviewer checks that the code actually does what it claims:

- Trace the behavior against the stated intent, not against the code's own comments.
- Walk the awkward inputs: nil, empty, zero, negative, very large, concurrent callers.
- Look closely at bounds, comparison direction and operator choice (`>` versus `>=`).

## Classify every remark

Say which kind it is:

- **bug**: behavior that is wrong.
- **clean-code issue**: right behavior, harder to maintain than it needs to be.
- **preference**: another reasonable way to write it.

A preference is never presented as a bug. Doing so teaches authors to ignore the review.

## Ground every remark

- Read the surrounding code before raising a point. A remark with no quoted line is not a
  finding.
- Keep apart the observation, the evidence and the proposal. Mark evidence as **fact**
  (read in a file or in command output during this review) or **hypothesis** (inferred,
  not directly checked). Never call something a fact that was not read.
- Re-run a command or re-read a file before asserting how something currently behaves.
- Propose the smallest fix that resolves the issue, not your preferred rewrite.

## Scope

Review what the change touches. A pre-existing problem in the same file may be mentioned
once as context; it does not block this change. If the author cannot act on a point inside
this change, it belongs in a follow-up issue, not in the review.

## Example

Good:

```text
bug (fact) - Discount#applies?
  quote: `order.total > MINIMUM_FOR_DISCOUNT`
  The spec says "from 100 up"; an order of exactly 100 is rejected.
  Fix: use `>=`.
```

Bad:

```text
This class feels big and some names could be clearer.
No quote, no category, no fix: a preference passing for a finding.
```
