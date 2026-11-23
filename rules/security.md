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

# Secure Coding

What to keep in mind while writing code that takes input, knows who the caller is, reads
data, holds a secret or sends local facts somewhere else. How to audit for the same defects is described in
the security pass of the `review` skill.

## Input

- Validate on the server: type, format, size, allowed values. Browser-side checks are a
  convenience, not a control.
- Refuse bad input explicitly. Quietly coercing it hides the bug and keeps the hole.

## Injection

- Queries are parameterized or built by the ORM. Never glue user input into SQL.
- Do not build shell commands from user input; pass arguments as an array, or avoid the shell.
- Escape output in templates. Treat raw-HTML helpers as sinks.
- A path derived from input is normalized and checked to stay inside the intended directory.

## Identity and permissions

- Authenticate before any sensitive action.
- Authorize against the specific resource, not only the route. Being logged in does not mean
  being allowed to open someone else's record.
- Logout invalidates the session or token server-side.
- Passwords are hashed with a slow algorithm (bcrypt, argon2). Repeated failures are
  throttled.

## Secrets

- Keys, tokens and passwords come from the environment or a secret manager. They do not
  appear in source, fixtures, logs or error messages.
- A secret that was committed is compromised: rotate it, do not merely delete the line.

## Data access

- Scope every query by owner or tenant. An unscoped lookup by id is an
  insecure-direct-object-reference waiting for its first caller.
- Before a destructive action, confirm the target belongs to the caller.

## Local data that leaves the machine

- When code gathers facts about the local machine (project, repository or client names,
  identifiers, counters keyed by them) and publishes them (to a shared remote, on a branch
  others can fetch, in a pull request), what goes out is chosen from an explicit allowlist
  of publishable items.
- Do not filter by shape (a prefix, a regular expression) or with a list of forbidden names:
  a private name that fits the shape, or that nobody remembered to forbid, goes out with
  the rest.
- Anything not positively known to be publishable stays local.

## Surface

- Remove endpoints nobody uses. Keep CORS origins explicit.
- Do not ship a dependency with a known vulnerability on a path you actually call. Adding,
  auditing and patching dependencies is covered in `dependency`.

## Example

```ruby
# Good: the record is looked up through the caller
invoice = current_account.invoices.find(params[:id])

# Good: input stays data
Customer.where(email: params[:email])
```

```ruby
# Bad: any signed-in user can fetch any invoice
invoice = Invoice.find(params[:id])

# Bad: input becomes part of the query
Customer.where("email = '#{params[:email]}'")
```

```ts
// Bad: user text injected as HTML
element.innerHTML = comment.body
// Good
element.textContent = comment.body
```

```python
# Good: only names from the published catalogue are sent
payload = {name: count for name, count in usage.items() if name in PUBLISHABLE_NAMES}

# Bad: a project name nobody listed is sent along with the rest
payload = {name: count for name, count in usage.items() if name not in SECRET_NAMES}
```
