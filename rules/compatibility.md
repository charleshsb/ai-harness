---
paths:
  - "**/controllers/**"
  - "**/api/**"
  - "**/graphql/**"
  - "**/routes.rb"
  - "**/routes/**"
  - "**/serializers/**"
  - "**/models/**"
  - "**/enums/**"
  - "**/types/**"
  - "**/jobs/**"
  - "**/workers/**"
  - "**/events/**"
  - "**/webhooks/**"
  - "**/consumers/**"
  - "**/migrate/*.rb"
  - "**/schema.rb"
---

# Not Breaking Other Consumers

Some code is read by software you do not deploy together with it: other repositories,
mobile apps already installed, queued jobs, stored data. Changing what they depend on
breaks them silently. Use this rule when a change touches such a contract. An internal
refactor that leaves every contract alone needs no broad investigation.

## Which changes count

| Contract changed | Who may break |
|---|---|
| API routes, fields, status codes, error shapes | Web and mobile clients, partner integrations |
| Events and webhooks | Subscribers expecting the old schema |
| Job arguments or payloads | Jobs already in the queue or about to be retried |
| Stored or serialized formats | Old rows and old readers |
| Shared ids and enum values | Anything keyed on the previous values |

## Known consumers

List the repositories that consume this one in the project's own instructions file (for
example a "consumers" section giving the local path of each). Where no list exists, ask.
A consumer that is unlisted, or whose path does not resolve, is an **evidence gap** and is
reported as one. A missing path is never proof that nobody depends on the contract.

## How to check

1. Name the contract that changes and which row of the table it falls under.
2. Look first inside this repository: serializers, other callers, tests asserting the old
   shape.
3. Open a consumer repository only to answer a specific question about this change, never to
   read it end to end.
4. Report each affected consumer with the evidence you found.
5. Propose a path that keeps old and new working side by side, or state the risk as open.

Keep the output short: contract, consumer, evidence or doubt, action. Other repositories
are read-only here; never modify them from this rule.

## Released clients lag

The newest mobile source is not the set of versions in users' hands. A change that suits the
latest source can still break an app that was released months ago. Without knowing which
versions must stay supported, say the change is unverified, not safe.

## API documentation first

Where the team keeps request documentation or an OpenAPI file for HTTP endpoints, the entry
for a changed endpoint should exist and match before or with the code change. Check the
method and URL match the route, and that the description reflects what actually changed
(new field, new status, new error). An entry whose route matches but whose description
ignores the change is stale and counts as missing. If the documentation location is
unknown, report that it was not verified; do not assume it is fine.

## Example

Good:

```text
Contract: PATCH /orders/:id now requires `reason`.
Consumer: web order-cancel form (src/api/orders.ts:41 sends no `reason`) -> would get 422.
Docs: api/orders.yaml still shows the old body: stale.
Action: tolerate a missing `reason` during one release, ship the form and docs update
  together with the change, and enforce it afterwards.
```

Bad:

```text
Renamed an enum value. Could affect other apps; consumers aren't configured, skipping.
An unknown consumer is a gap to report, not a reason to stop checking.
```
