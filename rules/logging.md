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

# Logging Fields

What to put on log lines so the logs answer real questions without leaking data or inflating
the bill. Secrets, and the error text shown to callers, are covered in `security` and
`error-handling`.

## Enrich the line that already exists

When the logging setup carries a per-request or per-job context (a structured logger with a
request id, a job wrapper), add your field to that context so it lands on the line being
written anyway. Do not emit a separate line for something the context could carry: separate
lines are harder to join with the request and cost more to store.

## What may appear

Technical identifiers, status codes, counts, durations, internal ids. Never a name, an email,
an address, a phone number, a token, or any text a user typed freely.

## How much

Log volume is paid for, so a field earns its place only if it answers a question the existing
logs cannot. Favour fields that appear only when something happens (an error, an unusual
path) rather than on all traffic. Never dump a whole object, a request body, a response body
or a payload.

## Names

Use `snake_case` and prefix the name with its domain (`refund_gateway_code`, not `code`). Such
names are easy to search for, easy to group by in a log tool, and unlikely to clash with a
field the framework already writes.

## Collisions

If a helper merges your fields into a line that the framework also fills, a clash must fail
loudly. Letting one side quietly overwrite the other corrupts both. Keep the list of
framework-owned names in one place, and extend it in the same change that makes the framework
write a new field.

## Example

```ruby
# Set only on failure, technical, prefixed by its domain, on the line already being written
request_log[:refund_gateway_code] = response.code unless response.ok?
```

```ruby
request_log[:phone] = user.phone                 # personal data
request_log[:path] = "/refunds"                  # clashes with a field the framework writes
request_log[:payload] = params.to_json           # a payload dump on every request
logger.info("refund gateway returned 504")       # a new line for what the context could carry
```
