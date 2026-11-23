---
paths:
  - "**/*.py"
  - "**/*.pyi"
---

# Python Style

What is particular to Python, layered on top of `clean`.

## Names

- Functions, methods, variables and modules take `snake_case`; classes and type aliases take
  `PascalCase`; constants take `UPPER_SNAKE_CASE`.
- A boolean's name asks a question: `is_active`, `has_permission`, `can_retry`,
  `should_render`.
- Spell words out. A single letter is acceptable only for a loop counter or a type
  parameter.

## Private means one underscore

- `_name` tells other modules to stay away. Importing someone else's `_helper` binds you to
  something its owner may rewrite at will. Make it public with a stable signature, or move
  the code next to the caller that needs it.
- `__name` is name mangling (`_Class__name`), designed to avoid clashes between a class and
  its subclasses. It protects nothing, so use `_name` to express intent.
- `__all__` defines what a re-exporting module offers. A name missing from it is private
  however it is spelled.

## Function signatures

- Past three positional parameters, bundle them in a `dataclass` or a `TypedDict`.
- When two arguments share a type and could be swapped by mistake, force keywords with a
  bare `*`: `def move(*, origin, target, count)`.
- A default such as `[]`, `{}` or `set()` is created once, when the `def` runs, and then
  shared by every call. Default to `None` and create the value inside the body.

## Truthiness

- Test for `None` with `is None` or `is not None`. `== None` can be fooled by a class that
  redefines equality.
- When the value in hand is itself a boolean or a count, do not compare it with `True`,
  `False` or `0`: use it directly, negate it, or write the comparison you actually mean.
- `if not items:` asks whether a container is empty, and `if items is None:` asks whether it
  is missing. These are separate questions, so do not trade one for the other.

## Modules and imports

- Use absolute imports. Group them as standard library, third-party, then your own package,
  with a blank line between groups.
- Avoid `from module import *`: it makes dependencies invisible and can overwrite names that
  already exist.

## Errors

- Name the exception you expect. A bare `except:` also catches `KeyboardInterrupt` and
  `SystemExit`.
- Chain with `raise NewError(...) from exc` so the original cause stays visible. Use
  `from None` only when hiding it is intended.
- Keep each `try` block as small as the code that can actually raise.

## Resources and builtins

- Manage files, sockets, locks and cursors with `with` (or `contextlib.ExitStack` for
  several), not an `open()` whose `close()` comes somewhere later.
- Do not reuse a builtin's name (`id`, `type`, `list`, `dict`, `object`, `next`, `format`,
  `input`) for your own variable. Nothing flags it where you define it, and it breaks the
  later call that expected the builtin.

## Example

```python
from dataclasses import dataclass


@dataclass(slots=True, frozen=True)
class Move:
    origin: str
    target: str
    count: int


def apply_move(move: Move, *, dry_run: bool = False) -> None:
    if move.count <= 0:
        raise ValueError(f"count must be positive, got {move.count}")
    if dry_run:
        return
    stock.record(move)
```

```python
def apply_move(origin, target, count, dry_run=False, seen=[]):   # flag, mutable default
    try:
        if count == 0 or origin == None:                          # == None
            return
        stock.record(origin, target, count)
    except:                                                       # bare except
        pass
```

```python
def read_settings(path: Path) -> Settings:
    try:
        return Settings.parse(path.read_text(encoding="utf-8"))
    except tomllib.TOMLDecodeError as exc:
        raise SettingsError(f"invalid TOML in {path}") from exc
```

```python
def read_settings(path):
    try:
        return Settings.parse(path.read_text())
    except Exception:
        raise SettingsError("invalid settings")   # the cause is lost
```
