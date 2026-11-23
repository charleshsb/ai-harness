---
paths:
  - "**/*.rb"
  - "**/*.rake"
  - "**/*.gemspec"
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
---

# SOLID, Minus What `clean` Already Says

`clean` covers single responsibility and dependency injection. The rest of SOLID is here:
open/closed, Liskov, interface segregation, and the part of dependency inversion that is
about abstractions.

## The gate: a second user

Inventing an abstraction early is the worse mistake, and `clean` forbids it, so that rule
outranks this one. Open/closed, interface segregation and dependency inversion come into play
only when the abstraction would already serve two users: two implementations, variants,
products or subscribers in the repository once the change lands, with a test double counting
as one. Until then, leave the code concrete. Liskov differs: it judges substitutes that
already exist and needs no gate.

## Open/closed

- Smell: every new kind of thing means touching the same `if`, `case` or `switch` in two or
  more places, and two kinds already exist.
- Move: when the next kind shows up, route the decision through one hook (polymorphism, a
  table, a registry).
- A two-branch conditional that nobody has had to extend stays as it is.

## Liskov

- Smell: a subtype that takes narrower input, throws what its parent does not, hands back
  less, turns an inherited method into a no-op or a `NotImplementedError`, or makes callers
  test its class (`is_a?`, `instanceof`).
- Move: restore the parent's promises, or drop inheritance in favour of composition.
- Use it to audit hierarchies. It never justifies building a new one.

## Interface segregation

- Smell: an interface with several implementers or callers, where some implementers stub out
  what they do not need, or callers use one corner of it.
- Move: split the interface along the lines the callers actually use.
- If every caller uses all of it, leave it alone.

## Dependency inversion

- Smell: domain logic constructs or imports a concrete detail (an HTTP client, a database
  driver, a payment gateway) while a second implementation, or a double for tests, exists or
  is being added.
- Move: have the domain depend on a small interface that it defines itself, and pass the real
  implementation in from the program's entry point. Injection technique is in `clean`.
- A lone concrete dependency (no second implementation, no double) is simply used directly.

## Example

```ruby
# A third notification channel arrives. Two exist, and every `case channel` is repeated in
# signup, reminders and reports: one extension point, added now.
CHANNELS = { email: EmailChannel, sms: SmsChannel, push: PushChannel }.freeze

def channel_for(name) = CHANNELS.fetch(name)
```

```ruby
# Premature: one implementation, one caller, no double
class Mailer; def deliver(message) = raise NotImplementedError; end
class SmtpMailer < Mailer; def deliver(message) = Smtp.send(message); end
# Call Smtp.send directly until a second mailer exists.
```

```ruby
# Liskov: the subtype refuses what its parent accepts
class ArchiveStore < Store
  def write(key, value) = raise NotImplementedError
end
```
