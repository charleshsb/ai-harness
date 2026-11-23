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

# Error Handling

A failure that disappears is worse than one that crashes: it comes back later as bad data
and nobody knows where it started. Every error ends in one of two places: handled on
purpose, or passed up to someone who can.

## Rules

- Never swallow. No empty `catch`, no `rescue nil`, no `.catch(() => {})`.
- Logging is not handling. A caught error that is only logged must still be re-raised or
  turned into an explicit failure result.
- Use a distinct exception type per category below, and do not reuse one for another.
- Anything that leaves the system (HTTP body, UI message, webhook reply) carries a short
  code. The full detail goes to the logs, tagged with a correlation id.
- Input that cannot be read, or is missing, is never treated as an empty collection when
  that collection decides what gets deleted, purged or overwritten. Raise a named error and
  stop before the destructive step.
- Put the irreversible step last. Run every local, repeatable build and check first, then
  the outside write (creating a remote repository, charging a card, sending a notification),
  so a later local failure cannot leave a stray remote object behind.

## Categories

| Category | Means | Typical response |
|---|---|---|
| Technical | The runtime or infrastructure broke (lost connection, disk full) | Let it propagate to the top-level handler; wrap only to add context |
| Business | A domain rule said no (order already shipped, balance too low) | Named exception, translated to a code at the boundary |
| Validation | Input does not meet the contract | Check at the boundary, report every problem at once, in one consistent shape |
| External | A third party failed (timeout, 5xx) | Named exception, raised immediately; the caller decides about retries |

Do not retry or degrade silently inside the code that detected an external failure. A
retry policy is a decision owned by the caller or the job runner, visible and bounded.

## What never goes out

Stack traces, class or file names, SQL or table names, upstream error text, and anything
hinting at the architecture. A caller gets `{ "error": "CARD_DECLINED" }`; the logs get
the story.

## Example

```ruby
# Good: named error, context added, translated once at the edge
def refund(payment)
  response = Gateway.refund(payment.reference)
  raise GatewayRefundError, "refund rejected (#{response.code})" unless response.ok?
end

rescue_from GatewayRefundError do |error|
  Rails.logger.error("[#{request.request_id}] #{error.message}")
  render json: { error: "REFUND_FAILED" }, status: :bad_gateway
end
```

```ts
// Good: fail immediately, caller decides
async function fetchRates(): Promise<Rates> {
  const res = await fetch(RATES_URL)
  if (!res.ok) throw new RatesProviderError(`rates provider answered ${res.status}`)
  return res.json()
}
```

```ruby
# Bad: the failure vanishes and the caller believes it worked
begin
  Gateway.refund(payment.reference)
rescue StandardError
  nil
end

# Bad: internals handed to the client
render json: { error: e.message, trace: e.backtrace.first(5) }
```

```ruby
# Good: an unreadable manifest stops the purge
def purge_orphans
  keep = read_manifest.fetch(:keep)   # raises ManifestUnreadableError
  Storage.delete_except(keep)
end

# Bad: an unreadable file becomes [], so everything is deleted
keep = (JSON.parse(File.read(path)) rescue [])
Storage.delete_except(keep)
```
