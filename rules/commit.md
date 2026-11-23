# Commit Messages

A commit message is read months later by someone who has only the log. It says what kind
of change this is and, when it is not obvious, why.

## Shape

```text
<type>(<scope>): <summary>

<optional body: the reason for the change>

<optional footer>
```

- `type`: one of the work types defined in `branch`, same table, same meaning.
- `scope`: optional, the module or area, in kebab-case (`auth`, `search`, `ci`).
- `summary`: English, imperative mood ("add", not "added"), lower-case first letter, no
  trailing period, 72 characters at most.
- `body`: separated by a blank line. Explain motivation and trade-offs, not the diff.
- `footer`: an issue reference such as `Closes ABC-123` or `Ref ABC-123` when a ticket
  exists. Optional.

## Breaking changes

Put `!` after the type or scope (`feat(api)!: drop the v1 search endpoint`), or start a
footer paragraph with `BREAKING CHANGE:` followed by what consumers must do.

## Hygiene

- One logical change per commit. Unrelated edits go in their own commit.
- Do not commit generated output, logs, local configuration or secrets.
- Nothing like "wip", "fix stuff" or "update".

## Examples

Good:

```text
feat(search): remember the last used filters
fix(session): redirect to sign-in when the token has expired
bump: upgrade axios to 1.7.2
chore(ci): cache bundler gems between runs
refacto(billing): split invoice totals from tax lines
```

Bad:

```text
Fixed the thing.                 # no type, past tense, period, vague
Feat: Added filters              # capital letter, past tense
feat(search): remember the last used filters and also bump rubocop and rename the helper   # three changes, too long
wip
```
