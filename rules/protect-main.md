# Protected Main Branch

Nothing is committed or pushed directly to `main` or `master`. Work happens on a branch and
reaches the main line through a reviewed pull request.

## What is enforced

Two git hooks live in this repository's `hooks/` directory:

- `pre-commit` refuses a commit while the current branch is `main` or `master`.
- `pre-push` refuses any push whose destination ref is `main` or `master`, force pushes
  included.

Both print a clear message saying what was blocked and what to do instead.

## Installing the hooks

Hooks are per clone. A repository without them has no protection, whatever this rule says.
Install them by symlinking both scripts into that repository's hooks directory. With Claude
Code, `adapters/claude/install.sh --git-hooks <path-to-repo>` does it and backs up any
existing hook first.

## When you are on the wrong branch

Create the branch where you stand, the work moves with you:

```bash
git switch -c feat/saved-search-filters
git commit -m "feat(search): remember the last used filters"
git push -u origin feat/saved-search-filters
```

## Exceptions

An emergency fix on the main line needs an explicit instruction from the person who owns the
repository, given in the conversation. The bypass is `git commit --no-verify` (or
`git push --no-verify`). It is never done silently: say you are bypassing the guard and
why, and mention it in the commit body.

## Not allowed

```bash
git switch main && git commit -m "quick fix"   # blocked by pre-commit
git push origin main                            # blocked by pre-push
git push --force origin HEAD:master             # blocked too
```
