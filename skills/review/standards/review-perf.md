# Reviewing for Performance

How to find performance defects in a change and decide which matter. The coding standards are
in `ruby-rails-perf` and `typescript-react-perf`. What follows is the procedure, which does
not depend on the stack.

## Measure or trace, do not guess

A performance finding comes with the way it was detected. Reading a diff can raise a
suspicion, and it should say so.

| Suspicion | How to check |
|---|---|
| Repeated queries (N+1) | Count the queries a request issues, or read the query log; in a diff, look for a loop that touches an association |
| Missing index | Compare columns used in `where`, `order`, `group` with the schema |
| Slow query | Run `EXPLAIN` on the real statement with realistic data |
| Needless re-renders | The React Profiler, or a temporary render counter |
| Heavy bundle | A bundle analyzer on the build output |

If none of these has been run, label the point as a suspicion, not a measurement.

## Rank by impact

Impact depends on volume. The same repeated query is severe over thousands of rows and
harmless over three, so always state the size of the collection.

| Level | Meaning |
|---|---|
| High | Timeouts, blocked requests, memory exhaustion, or growth that will hit them soon |
| Medium | Noticeable slowdown at current volumes |
| Low | A real but small gain |

Rank by what it costs the user or the system, not by how easy it is to fix.

## Evidence and restraint

- Quote the line and say what work it causes ("one query for each order in the page").
- Do not suggest a micro-optimization that harms readability. `clean` wins over a gain no
  one can observe.

## Example

Good:

```text
High (traced) - ReportsController#index
  quote: `reports.each { |report| report.owner.name }`
  About 2,000 rows per page produce 2,001 queries (query log, one request).
  Fix: `reports.includes(:owner)`.
```

Bad:

```text
The reports page could be faster.
No line, no measurement, no size: nothing to act on or check.
```
