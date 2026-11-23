# Review Against the Requirement

This pass asks one question: does the change do what was requested? The other passes judge
quality. A tidy, secure, fast implementation of the wrong thing still earns a finding here.

## Locate the requirement

There are two possible sources: what the user pasted or linked (a ticket, a brief), and a
spec file they named as approved. Either is enough, and with both you use both.

If you cannot read either, do not run this pass. Say it was skipped and why, because "no
findings" would be untrue. If only one source is out of reach, go on with the other and
mention the gap.

## One ask at a time

Split the description and its acceptance criteria into separate asks and judge each on its
own. A change is seldom entirely done or entirely missing.

## Verdicts

| Verdict | Meaning | Outcome |
|---|---|---|
| Fully addressed | The change delivers it | No finding |
| Partly addressed | Some is delivered, some is not | `medium` finding, or `high` if the missing part matters in itself |
| Not addressed | It was requested and nothing in the change covers it | `high` finding |
| Dropped on purpose | A source or comment removes it in writing | No finding, and only if you can quote that line |

An ask that is met produces nothing: an empty review is a legitimate result. "Dropped on
purpose" holds only with a quotable line. Without one, the gap counts as not addressed, and
you do not assume a requirement was dropped when nobody wrote that down.

## Findings with no code to quote

A missing or partial ask usually has no line in the change to point at, only the requirement
saying what is absent. Mark the finding `absence: true` as `review-findings.md` describes,
put the requirement's own words in the summary, and do not invent a file to fill a format.

## Example

```text
spec-1 - not addressed (high)
  absence: true
  requirement: "show the expected delivery date on the order page"
  The change updates the orders API only; no page or component displays the date.
  fix: render the new field on the order page
```

```text
The ticket is not fully done.
No ask named and no verdict: nothing the author can check.
```

```text
I left out the delivery date, it seems optional.
A descoping made up without any quoted source.
```
