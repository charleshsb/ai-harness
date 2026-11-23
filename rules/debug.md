# Debugging From the Root Cause

Whenever a bug is investigated or fixed, these hold. A patch that makes the symptom go away
without explaining it leaves the defect in place and hides it.

## Principles

- Find the cause before touching code. A fix without an explanation is a bug postponed.
- Do not apply a "most likely" fix. Point at the line, the data or the log that proves it.
- If a serious investigation does not find the cause, say so plainly and stop short of a
  speculative change.
- Reproduce first, then fix. The proof that the fix works depends on the kind of failure:

| Failure | Proof |
|---|---|
| Application logic | A test that reproduces it fails before the change and passes after |
| CI, build, tooling | The pipeline goes from red to green on the same commit range |
| Third-party integration | The contract is observed to hold (request and response captured) and written down |
| Data or migration | It runs forward and backward on a copy, and the outcome is recorded |

- If no such proof can be produced, the cause is not yet understood. Say that instead of
  announcing a fix.

## Check what is really running

- Before reporting a defect, look at the live thing itself: ask the API, query the database,
  inspect the process. A pretty-printed view, a serializer's output or a single log line is
  one rendering of the state. If a field is missing from it, that says nothing about the
  field.
- Filtered or cut-off output (`grep`, `head`) cannot show that something is absent or that
  two things are equal, here or in another codebase. Write "not seen in this output", not
  "does not exist".
- Before saying what production runs, or comparing behavior before and after a change, find
  out which code is deployed and when the change went live. Merging does not deploy, and an
  older diff may not be what runs today.
- When the diagnosis sorts things into classes (real incident or routine restart, genuine or
  generated traffic), give the observable test that separates them. Without one, the label is
  an opinion nobody can check.

## When the cause is in a dependency

Do not debug or patch the library. Fix on your side of the boundary, taking the first option
that works:

1. Upgrade to a fixed version.
2. Pin to a version that does not have the problem.
3. Guard or wrap the call in your own code.
4. Fork and send the change upstream.

Reopening the dependency's classes at runtime (monkey patching) is a last resort: every
alternative above must be ruled out with a stated reason, and the user must agree. It
carries a comment with the upstream issue and the version after which it can be removed.
When nothing works, reporting "external cause: library, version, issue" is a legitimate
result.

## Example

```text
Symptom: exported CSV shows duplicate rows for some customers
Hypothesis: the join on addresses multiplies rows when a customer has two addresses
Evidence: exporter.rb joins addresses without restricting to the primary one
Reproduction: spec with a customer owning two addresses -> 2 rows, expected 1 (fails)
Fix: restrict the join to primary: true
Result: the spec passes
```

```text
Symptom: same
"Probably a caching problem" -> clear the cache, add a uniq on the output
No evidence, no reproduction, the cause is still there
```

```text
Claim: "the export has no currency column"
Evidence: head -5 export.csv | grep currency  -> no output
Five lines and a filter prove nothing. Read the whole header, or query the table.
```

```ruby
# Wrap at the call site, library untouched
# Cause: report_kit 1.4.2 raises when the title is nil (upstream issue pending)
def render_report(report)
  raise MissingTitleError, "report #{report.id} has no title" if report.title.nil?

  ReportKit.render(report)
end
```
