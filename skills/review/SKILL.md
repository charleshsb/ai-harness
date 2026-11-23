---
name: review
description: Review the current diff in three read-only passes (code, performance, security), plus two more when the user supplies the requirement (conformance, tests), and return findings the user validates one by one. Use for "review my branch", "review this diff", "audit before the PR", or before opening a pull request. Never edits files.
allowed-tools: Read, Grep, Glob, Bash(git diff:*), Bash(git log:*), Bash(git status:*), Bash(git merge-base:*), Bash(git rev-parse:*), Bash(git show:*), Bash(git branch:*)
---

# Review

Review the change in front of you, one axis at a time, and hand back findings the user can
accept or reject individually. This skill reads; it does not write. No file is edited, no
git state is changed, nothing is staged, committed or pushed.

## 1. Fix the target

1. Use the argument if one was given: a base ref, a commit range, or a path list.
2. Otherwise compare the current branch against its base. Find the base with
   `git rev-parse --abbrev-ref origin/HEAD`; if that fails, try `main`, then `master`.
   Take the diff of `git merge-base <base> HEAD` to the working tree, so committed,
   staged and unstaged changes are all included.
3. Run `git diff --stat` and state the target in one line: base, number of files, number
   of changed lines. If the diff is empty, say so and stop.
4. If the diff is very large (more than about 1,500 changed lines), say so and ask whether to
   review everything or a subset of paths. Do not silently skim.

5. Note whether the user supplied a requirement: pasted ticket or brief text, a link you can
   read, or the path of an approved spec file. Passes D and E need one. Do not go looking for
   one on your own.

Read each changed file around its hunks, not just the hunk, before judging it. Findings
about code you did not read are not allowed.

## 2. Load the standards

Read, from the `standards/` directory next to this file:

- `review-findings.md`, the shape every finding must have;
- the method for each axis: `review-code.md`, `review-perf.md`, `review-security.md`, and,
  only when a requirement was supplied, `review-spec.md` and `review-tests.md`.

Then read, from the `rules/` directory of this harness (or wherever your tool's installer
linked them, such as `~/.claude/rules/`), the standards those methods audit, for the languages present in the diff:
`clean.md`, `error-handling.md`, `security.md`, plus `ruby.md`, `ruby-rails.md`,
`ruby-rails-perf.md`, `typescript.md`, `typescript-react.md`, `typescript-react-perf.md`
when they apply, and `compatibility.md` if a contract changes.

If a rule file cannot be found, say so and continue with general practice, marking the
affected findings accordingly.

## 3. The passes

Run the passes in this order. Each one looks only through its own lens and ignores the other
two, so that each stays sharp. When the environment can run read-only sub-agents, give each
pass to its own and merge the results; otherwise do them one after the other.

### Pass A: code

Correctness and structure, following `review-code.md`. Does the code do what the change
claims? Edge cases, bounds, comparisons, error paths, missing tests for new behavior.
Classify each point as bug, clean-code issue or preference.

### Pass B: performance

Following `review-perf.md`. Repeated queries, missing indexes, unbounded loads, wasteful
renders and refetches. State the size of the data involved and how the point was detected;
mark it as a suspicion when nothing was run.

### Pass C: security

Following `review-security.md`. Trace source to sink; check authorization on every touched
resource, injection, secrets, data exposure in logs and error bodies. Give each point one
verdict (exploitable, real risk, theoretical, bad practice).

### Pass D: requirement (only with a requirement)

Following `review-spec.md`. Split the requirement into asks and give each its own verdict.
With no requirement supplied, state that this pass was skipped and why; do not report zero
findings.

### Pass E: tests (only with a requirement)

Following `review-tests.md`. Check that each behavior the change touches is verified, against
the same requirement. Skipped, with the reason, when there is none.

## 4. Write the findings

Each finding follows `review-findings.md`:

- `id`: axis prefix and a number, such as `code-1`, `perf-2`, `sec-1`, `spec-1`, `test-1`.
  Stable for the run.
- `summary`: one sentence describing the defect.
- `quote`: the exact text from the code, copied character for character. If you cannot quote
  it, you have not found it.
- `absence: true` instead of a quote when the finding is about something missing (a test, a
  permission check, a migration); describe what is missing and do not invent a location.

Add, per this skill's own convention: `axis`, `path`, `kind` (bug, issue, preference, risk
verdict), `evidence` (`fact` if read or run in this session, `hypothesis` otherwise),
`impact`, and a `suggestion` limited to the smallest fix. Severity uses `high`, `medium`,
`low`, defined by the method rules.

Merge duplicates that two passes found, keeping the stronger framing. Drop anything that is
a pure preference unless the user asked for style remarks. Do not pad: five accurate
findings beat twenty doubtful ones. If a pass finds nothing, say that in one line.

## 5. Validate one by one

Present findings ordered by severity, one at a time:

```text
[sec-1] high - exploitable - app/controllers/documents_controller.rb
quote:   Document.find(params[:document_id])
summary: The lookup is not scoped to the caller, so any signed-in user can open any document.
fix:     current_user.documents.find(params[:document_id])
Keep, drop, or discuss?
```

Wait for the user's answer on each: **keep**, **drop**, or **discuss** (answer questions,
then ask again). A dropped finding is removed from the result and not argued. Do not batch
decisions or assume silence means yes.

## 6. Return

End with the kept findings as a list the user can paste into a pull request or hand to a fix
step, in the format above, followed by one line of counts per axis. Mention what the review
did not cover (files skipped, rules not found, things that need a running system to confirm).
Offer to proceed to the fixes, but do not start them.

## Limits

- Read-only. If a fix is requested afterwards, that is a separate task.
- It reviews the diff. Pre-existing problems in touched files are named once as context at
  most, never as blockers.
- It does not run the test suite or the application. Anything that needs execution to
  confirm is labelled `hypothesis`.
