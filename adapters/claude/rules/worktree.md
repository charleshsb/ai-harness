# Working in a Worktree

Claude Code specifics for sessions that use git worktrees.

- To work inside an existing worktree, call `EnterWorktree` with `path`. Never pass `name`:
  it would make a new folder in `.claude/worktrees/` rather than enter the one you prepared.
- Leave with `ExitWorktree` set to keep, before anything removes the directory.
- From inside one, the Write and Edit tools will not touch any other worktree of the same
  repository.
- The main working tree cannot be entered. If the tool refuses or is missing, carry on with
  explicit paths.
- In a session isolated to a worktree, run each git command on its own. A pipe, a subshell, a
  redirection or a launcher wrapped around git is refused; inspect repository state with its
  own read-only command.
- Proxy launchers like `rtk proxy` do not work in that setting. Push with a plain `git push`
  and confirm with a separate `git ls-remote`.

## Example

```text
EnterWorktree path=.worktrees/fix/search-timeout   ...work...   ExitWorktree keep
git worktree remove .worktrees/fix/search-timeout

EnterWorktree name=search-timeout     # a new directory elsewhere, not the prepared one
```
