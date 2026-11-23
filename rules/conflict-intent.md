# Resolving Conflicts by Intent

When git stops on a conflict, say what you want to keep, never which flag to pass. The words
`ours` and `theirs` mean opposite things depending on the operation, and getting them wrong
throws away the work you meant to protect.

## Vocabulary

Only three intents exist:

| Intent | Keeps |
|---|---|
| `keep-mine` | The commits of the branch you are developing |
| `keep-incoming` | The other side: the branch being merged, or the base you are rebasing onto |
| `interactive` | Neither by default; decide file by file |

## One place translates intent into a flag

1. Detect the operation in progress from the repository state: `MERGE_HEAD`,
   `rebase-merge/` or `rebase-apply/`, `CHERRY_PICK_HEAD`, `REVERT_HEAD`.
2. Map the intent:

| Intent | merge, cherry-pick, revert | rebase |
|---|---|---|
| `keep-mine` | `--ours` | `--theirs` |
| `keep-incoming` | `--theirs` | `--ours` |

3. If the operation cannot be determined, stop. Do not resolve on a guess.

A caller that hands over a bare `ours` or `theirs` is passing a flag, not an intent. Do not
translate it again; flag it as a mistake and ask for the intent.

## Why the table is not symmetrical

A rebase checks out the new base and replays your commits on it one at a time. During that
replay, "ours" is the base you are building on and "theirs" is your own commit being
applied. Mapping "keep my changes" to `--ours` therefore discards your work, with no
warning, in the most common case. This is a data-loss rule, not a style preference.

## Announce the translation

Before running anything, print the line that names the flag and the scope:

```text
Operation: rebase. Intent keep-mine becomes --theirs, applied to 3 files.
```

If the line is missing, nobody can tell afterwards which side was kept.

## Example

```bash
# Good: state detected first, intent translated, then applied
test -d .git/rebase-merge && echo "rebase" # -> keep-mine == --theirs
git checkout --theirs -- app/models/invoice.rb

# Bad: flag chosen by habit during a rebase
git checkout --ours -- app/models/invoice.rb   # silently drops your commit's version
```
