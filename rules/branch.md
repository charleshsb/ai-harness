# Branch Names

Every branch is named the same way, whatever tool creates it, so that history and pull
request lists can be scanned at a glance.

## Shape

```text
<type>/<ticket>-<short-name>     # with a tracker reference
<type>/<short-name>              # without one
```

- `type` is one of `feat`, `fix`, `docs`, `test`, `chore`, `bump`, `refacto`.
- `ticket` is optional: a tracker key such as `ABC-123` (letters, dash, digits). Leave it
  out when there is no ticket; never invent one.
- `short-name` is lower-case kebab-case in English, three to five words.

## Choosing the type

| The branch mostly... | Type |
|---|---|
| adds behavior | `feat` |
| repairs behavior | `fix` |
| restructures without changing behavior | `refacto` |
| updates dependencies | `bump` |
| touches tooling, CI or configuration | `chore` |
| touches documentation only | `docs` |
| adds or changes tests only | `test` |

## Examples

Good:

```text
feat/ABC-210-saved-search-filters
fix/login-loop-on-expired-session
bump/axios
refacto/invoice-numbering
```

Bad:

```text
saved-filters                    # no type
ABC-210/saved-filters            # ticket before the type
fix/ABC-211_login_loop           # underscores
feat/ajout-des-filtres           # not English
Feat/Saved-Filters               # capitals
```
