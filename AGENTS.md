# Working Habits

Personal preferences for how work is carried out with an AI coding assistant. They apply to
every project unless a project's own instructions say otherwise.

## Commits are reviewed before they exist

- Never commit or push on your own initiative. Both need an explicit "go" from me, and a
  push needs its own go even on a branch with an open pull request.
- When a task has several points, make one commit per point. Finish a point, run its tests
  and linter, show what changed, and wait for approval before committing it.
- Asking for the work to be made reviewable ("put it on a branch I can look at") is not a
  go to commit. It means: leave the changes uncommitted where I can read them.

## Do not touch my index while I review

While I go through a change, I stage files by hand to mark what I have already read. Do not
run `git add` after you edit; leave modified files unstaged and tell me which ones changed
so I can look again. Stage only at commit time, after the go, and only the files of that
commit. Before committing, check `git diff --cached --name-only`: a file I staged while
reviewing may belong to a different commit.

## Spec wording

- Put the conditions in a `context "when ..."` block (or the equivalent in other
  frameworks), and let the `it` say only what is expected.
- Setup lives in the `context`, in `let` or `before`, or in the first block of the example.
- Inside each example follow Arrange, Act, Assert, in that order, separated by blank lines.
  Details are in `rules/test-structure.md`.

## Method names say what they do

- Name a method with a verb and its object: `generate_number`, `build_payload`,
  `find_matching_package`. A bare preposition such as `for` hides both the action and what
  it needs, because dynamic languages do not show argument types at the call site.
- If no descriptive name emerges, `call` is the accepted fallback, not a clever noun.
- Reread public method names before proposing a diff: if the call site does not explain
  itself, rename.

## Private methods in call order

Declare private methods in the order they are first called, walking depth first from the
public method, so the file reads top to bottom like the execution. After extracting methods,
check the order before showing the diff.

## Review locally before a pull request

Before opening a pull request, offer a local review of the whole branch diff against the
base branch, not just the last commit (the `review` skill in this repository does it).
Offer, then wait for my answer: I decide whether to run it. Fix what it finds before the
pull request is opened, not after.

## Read the code rules before creating a code file

Rules scoped to file paths load when a matching file is read. Creating a new file reads
nothing, so none of them load. Before writing a new source file, read `rules/clean.md`,
`rules/error-handling.md`, `rules/security.md` and `rules/tdd.md`, plus the rule of the
file's language (`rules/ruby.md`, `rules/typescript.md` or `rules/python.md`); for a new
test file also read `rules/test-scope.md` and `rules/test-structure.md`. Do not assume they
were in context just because the folder is installed.
