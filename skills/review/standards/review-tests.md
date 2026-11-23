# Review That the Behavior Is Tested

This pass checks that what a change adds or alters is actually verified by tests.
`review-spec.md` asks whether the requirement is implemented; this one asks whether that
implementation is covered. A change can be complete and untested, or heavily tested and
still miss the single case that matters.

## It needs a requirement

Behavior can only be judged against what it was meant to do. This pass therefore uses the
same sources as `review-spec.md` (the user's ticket or brief, or an approved spec file) and
does not run without one. Report it as skipped and give the reason; do not present it as a
clean result. There is no mode that works from the diff alone.

## Method

1. List the behaviors that the requirement and the change touch.
2. Locate the tests covering each, whether unit, integration, end-to-end or contract.
3. For each behavior look for the normal case, the failing case, the boundaries, and any
   case an earlier bug makes relevant.
4. Confirm the assertions demonstrate the behavior and do not merely execute the code. A
   test without a meaningful assertion proves nothing.
5. For every finding, state how you searched and which test files you read.

## Two accepted reasons for "no test"

1. The change is the kind of wiring `tdd` lists as optional: routes, configuration,
   migrations, a CRUD controller with no branches, a presentational component with no state
   or handlers, framework boilerplate.
2. The requirement source says so itself (for example "manual QA only").

A behavior that fits neither is a finding, with a severity set by how much it matters and
never by how awkward it is to test. This is what keeps two reviewers from disagreeing about
the same gap.

## No coverage targets

- Do not ask for 100% line coverage, and do not ask for tests on a change with no functional
  effect (documentation, comments, formatting, a rename that alters nothing).
- Severity follows materiality: an untested critical path is `high`; a gap around a minor
  edge case rates `medium` or `low`.

## Findings with no code to quote

A coverage gap names a behavior, not a wrong line. Mark it `absence: true` as
`review-findings.md` describes, and name the behavior in the summary. Do not make up a
location.

## Example

```text
test-1 - high
  absence: true
  behavior: resetting a password now invalidates existing sessions (change touches sessions.rb)
  No test exercises that path; searching spec/ for `invalidate` finds nothing.
  fix: add a spec asserting that old session tokens stop working after a reset
```

```text
Needs more tests.
Vague: no behavior, no weight, nothing the author can do with it.
```

```text
Nothing covers the retry logic, but timers are awkward to unit test.
A subjective excuse that matches neither accepted reason.
```
