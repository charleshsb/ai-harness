# Guardrails for Concise Work

Being brief is good. These are the four things brevity must never cost.

## Keep exact things exact

Short prose around precise material is fine; shortening the material itself is not.
Identifiers, numbers, flags, paths and code stay literally as they are. Do not turn a
measured figure into "about a fifth", and do not abbreviate a name into something nobody can
search for.

## Ask before the irreversible

Confirm first before deleting, overwriting, pushing, or rewriting git history. No need to ask
for reading, for local edits, for creating new local files, or for undoable symlink work.
Remote machines are different: any write there, even creating a file, needs approval, and
production is never touched by the assistant.

## Run one thing at a time on fragile ground

Work sequentially by default. Never parallelize edits to configuration files, shell
startup files, git state or symlink layouts: one actor, one step, check, continue. Parallel
work is for independent reads and searches.

## Quote what the shell would expand

In shell commands, quote globs and any word that starts with `=`: `find . -name '*.tmp'`,
`echo '=== done ==='`. zsh, the macOS default, aborts the whole command when a glob matches nothing
("no matches found") or when `=word` is read as a command lookup. bash lets both through,
so a command that worked in one shell can fail in the other.

## Example

Good:

```text
Queue tried: p95 went from 210 ms to 340 ms, reverted.
`parse_manifest` in `lib/manifest.rb`, 3 retries, timeout 15 s.
```

Bad:

```text
Queue made it slower, reverted.        # the measurement became a vague word
`parse_manifest` -> `pm`               # identifier shortened into something unsearchable
```
