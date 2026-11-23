---
paths:
  - "**/*.rb"
  - "**/*.rake"
  - "**/*.gemspec"
---

# Ruby Style

Ruby-specific habits, on top of `clean`. Generic advice is not repeated here.

## Naming

- `snake_case` for methods and variables, `PascalCase` for classes and modules,
  `SCREAMING_SNAKE_CASE` for constants.
- A method ending in `?` returns a boolean; one ending in `!` is the dangerous sibling of a
  safer method (it raises, or mutates in place). Do not use `!` as emphasis.
- A method name must say what the call does at the call site. Do not name a method `for`,
  `of`, `from` or another bare preposition: `Invoice.for(order)` hides the verb. Prefer
  `build_invoice(order)`. When no verb fits, `call` is the fallback.

## Idioms

- Prefer `map`, `select`, `reject`, `find`, `sum`, `each_with_object` to index loops.
- Safe navigation (`&.`) for optional receivers, `dig` for nested hashes.
- Symbols as hash keys; keyword arguments when a method takes three or more parameters.
- `||=` memoizes values that are never `false` or `nil` on purpose.
- Start files with `# frozen_string_literal: true`.

## Methods

- About 10 lines is comfortable; stop at 20.
- Early `return` is for guard clauses only, at the top.

## Exceptions

- Rescue `StandardError` or something narrower, never `Exception`.
- Always name the class in `rescue`. A bare `rescue` or `rescue nil` is not allowed.
- Rescue around the single statement that can fail, not the whole method body.

## Avoid

- `unless` with an `else` branch.
- `!!value` to coerce to a boolean; write the comparison.
- A multi-line statement followed by a trailing `if`; use the block form.

## Example

```ruby
# frozen_string_literal: true

def reserve_seat(booking:, venue:, held_for:)
  return Result.failure(:already_reserved) if booking.reserved?

  venue.hold(booking.seat, minutes: held_for)
rescue Venue::UnavailableError => error
  Result.failure(:venue_unavailable, error.message)
end
```

```ruby
def reserve_seat(booking, venue, minutes, notify = true)   # 4 positional args, boolean flag
  begin
    unless booking.reserved?
      venue.hold(booking.seat, minutes)
    else
      false
    end
  rescue                                                    # catches everything, tells nothing
    false
  end
end
```
