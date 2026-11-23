---
name: worktree
description: Create a branch in its own worktree under .worktrees/<branch> and enter it, or enter the worktree that already holds a branch, instead of switching branches in the current tree. Use when the user asks to "create the branch in a worktree", "check out in a worktree" or "work in a worktree". Claude Code only, since it relies on EnterWorktree.
argument-hint: "branch [base] - with a base the branch is created, without one it is checked out"
---

# Branch in a Worktree

One place that knows how to put a branch in a worktree, so no other step has to redo it.

## Inputs

- `branch`: the name of the branch to create or check out.
- `base`: for creation only. Given means create; absent means check out.

## 1. Find the main tree and the path

```bash
ROOT=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")
```

The common git directory is the main clone's `.git`, so `ROOT` is the main working tree
wherever the session happens to sit. All the paths that follow are built from it, never from
the current directory.

The worktree lives at `"$ROOT/.worktrees/<branch>"`, with the branch name used as is:
`feat/search-filters` becomes `"$ROOT/.worktrees/feat/search-filters"`. A clone has a single
`.worktrees/` folder.

## 2. Keep `.worktrees/` out of git

Run this once, before any `git worktree add`:

```bash
git -C "$ROOT" check-ignore -q .worktrees \
  || echo ".worktrees/" >> "$(git -C "$ROOT" rev-parse --path-format=absolute --git-path info/exclude)"
```

Use `info/exclude` and not `.gitignore`, so that creating a worktree leaves nothing to
commit. Spell it as an absolute path: a redirect is resolved from where the shell stands,
and `-C` has no say in that.

## 3. Create (a base was given)

Do not disturb the tree you are in: no checkout, stash or commit.

- Look for a local branch of that name with `git show-ref --verify --quiet refs/heads/<branch>`.
  If it exists, stop and name it. Let the user choose between checking that branch out and
  creating a new one under another name. Never reuse a pre-existing branch to satisfy a
  request to create one.
- Otherwise:

  ```bash
  git -C "$ROOT" worktree add -b <branch> "$ROOT/.worktrees/<branch>" <base>
  ```

  Git creates the missing parent directories of a nested path.

- If `git worktree add` refuses (the path exists, or the branch is checked out elsewhere):
  stop and print the output of `git worktree list --porcelain`; remove nothing.

Then go to step 5.

## 4. Check out (no base)

Read `git worktree list --porcelain` once, then take the first case that applies:

0. **The main tree holds the branch** (the entry whose path is `ROOT` shows
   `branch refs/heads/<branch>`): stop and name the branch and the tree. There is nothing to
   extract, since git will not check a branch out twice and entering the main tree isolates
   nothing. Tell the user they can simply stay in the current tree.
1. **Another linked worktree holds it:** enter that path (step 5). Create nothing.
2. **The folder `"$ROOT/.worktrees/<branch>"` exists but no worktree is registered there:**
   stop and give the path along with the listing. Do not remove it: deleting is destructive
   and a decision of its own.
3. **Otherwise create it.** When a local branch exists:

   ```bash
   git -C "$ROOT" worktree add "$ROOT/.worktrees/<branch>" <branch>
   ```

   When only `origin/<branch>` exists:

   ```bash
   git -C "$ROOT" worktree add -b <branch> "$ROOT/.worktrees/<branch>" origin/<branch>
   ```

   The first form cannot resolve a name that exists only on the remote. The second gives the
   new branch the same upstream a plain checkout would, because both follow
   `branch.autoSetupMerge`. Nothing is stashed here either.

## 5. Enter the worktree

Call `EnterWorktree` with `path` set to the absolute path, never `name`. If the tool refuses
or is missing, continue with explicit paths and say that the session's directory did not
change.

## 6. Report

State four facts: that the mode was worktree, the absolute path, the branch, and whether the
session entered it (yes or no).

Do not rename or flatten the path to make entering succeed: a worktree outside the exact
`"$ROOT/.worktrees/<branch>"` shape escapes any cleanup that sweeps that folder, silently.

## Never

- Remove a worktree, pass `--force`, delete a branch, or push.
- Reuse a pre-existing branch to answer a request to create one.
- Delete a directory found in the way.
- Check out the base branch, stash, or commit.
