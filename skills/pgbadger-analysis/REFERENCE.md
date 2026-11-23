# Reference for pgBadger Analysis

Rules of thumb, a catalogue of query-shape hints, search tips and a guide to the sections of
a report. The figures are starting points and may be tuned with evidence.

## What deserves a finding

Each entry gives what to look for, how far to trust it, and the check to run before acting.

- **Blind spot.** The latency floor is 10 ms or higher, so fast N+1 patterns cannot appear.
  Certain: it describes the report itself. To see them, log more statements for a limited
  period.
- **N+1 candidate.** An identical one-key lookup seen at least 3 times. Low trust: nothing
  links the runs to one request. Look for a request trace or run Bullet.
- **Count pagination.** `count(*)` averaging 500 ms or more. The cost is certain, the cause
  less so. Read the endpoint that returns a total.
- **Wide eager load.** Rails aliases (`t0_r0`) averaging a second or more with heavy columns
  being read. High trust. Read the `includes` or `eager_load` call.
- **Purge loop.** A `skip locked` delete repeated 100 times or more. High trust. Read the job
  and the table's indexes.
- **Slow query.** Any non-maintenance query averaging a second or more that no shape-specific
  entry already covers. Medium trust. Look at the existing indexes, then run `EXPLAIN`.
- **Frequent slow query.** A query run at least 5 times at an average of 100 ms or more.
  Medium trust. Same checks as above.
- **Latency outlier.** A maximum of 5 s or more that is also at least 10 times the average.
  Low trust, since the cause is not in the report. Compare with locks, deploys and vacuum at
  that hour.
- **Unranked slow run.** A run of a second or more in the slowest-queries section whose query
  is missing from the time-consuming ranking. Medium trust: the run happened, but its
  frequency is unknown. Find the caller, apply the hints, and run a plain `EXPLAIN` with that
  run's values.
- **Unobserved lock waits.** Every lock-wait section is empty. Certain, but it describes
  coverage and not a defect. Check `SHOW log_lock_waits` and read `pg_locks`.
- **Authentication failures.** 100 failed password logins or more. High trust. Identify the
  client.
- **TOAST or dead-tuple churn.** A million dead tuples or more removed from one table. Medium
  trust. Work out which table owns the TOAST relation.

## Query-shape hints

These attach to any query finding as leads, never as conclusions.

- `OFFSET ?`: each deeper page costs more. Consider keyset pagination, or cap the depth.
- `ORDER BY` with no `LIMIT`: does the caller need the order, or just one page of results?
- `lower(col)`, `date(col)` or `cast(col ...)` inside `WHERE`: an ordinary index cannot serve
  it. Build an index on the expression, or keep the normalized value in its own column.
- `NOT IN (SELECT ...)`: try `NOT EXISTS` or a left join, and think about what `NULL` does to
  the answer.
- `IN (?, ?, ...)` with 20 values or more: probably an association loaded by ids, where a
  join or `preload` may fit better.
- `"t".*`: wide `jsonb` or `text` columns are being read. Select only what the caller uses.
- A pattern starting with `%` (`LIKE` or `ILIKE`) in a logged run defeats btree indexes.
  Consider a trigram (`pg_trgm`) GIN index, anchoring the search, or searching a dedicated
  column.

For index candidates, write `table: [columns]` using the filter and join comparisons and the
sort keys of the query, with the table name as written there (the alias if one is used).
Check the result against `pg_indexes` and `db/schema.rb`; primary keys come indexed. A
multi-column index helps queries on its leading columns first, so the order of the columns
matters. An index that exists but is never scanned (`idx_scan = 0`) suggests the planner
prefers a scan: read the plan before adding another.

Apart from the leading wildcard, every pattern is inferred from query text in which literals
have been replaced, which hides how selective a filter is. The wildcard check relies on the
real values in logged runs, so a query whose slow runs went unlogged cannot show it.

A ranked query can be matched with its runs through a fingerprint (literals masked,
whitespace dropped). A run that matches no ranked query becomes an unranked slow run rather
than being lost.

## Where to look in the code

- **Purge loop:** the job or scheduled task that deletes in batches (search for
  `skip locked`, `in_batches` or `delete_all`). Run `EXPLAIN` on a copy to compare the
  table's indexes with its filter columns. If a dependency issues the purge, fix it at your
  own boundary.
- **Count pagination:** the paginated endpoint that reports a total (search for `total_count`
  or `total_entries`). You can drop the exact figure, cache it, or run the count without the
  joins and preloads.
- **Wide eager load:** the `includes` or `eager_load` call. A filter on the association makes
  `includes` behave as a join, and a join reads every column from both tables, the heavy ones
  included.
- **N+1 candidate:** an association touched inside a loop, or the serializer that traverses
  it.
- **Slow or frequent slow query:** the scope or query object that names those tables, and
  afterwards the indexes the model declares in `db/schema.rb`. A slow lookup that recurs may
  be an N+1 candidate and not a missing index.
- **Latency outlier:** not the query itself. Line the slow day up against deploys,
  long-running jobs and the vacuum activity reported for the same day.
- **TOAST churn:** find the owning table with the `reltoastrelid` query in the skill's
  verification step.
- **Authentication failures:** the report's main host and user are often "unknown", and one
  sampled log line proves nothing about the source of every failure. Find the client (role,
  host) in the log.

The wide-eager-load entry and the association heuristics rely on ActiveRecord aliases
(`t0_r0`). On other stacks, use only the generic entries.

## Reading the report sections

- **Time consuming queries:** the main ranking, giving the total cost of each normalized
  query.
- **Most frequent queries:** skip it; the queries are the same as in the ranking.
- **Slowest individual queries:** real executions, with day, hour, user and literal values.
  They feed slowest runs, leading-wildcard detection and unranked slow runs.
- **Queries that waited the most:** shows lock waits, and is blank unless `log_lock_waits` is
  on (then note the unobserved lock waits). Rows that do appear are not analysed.
- **Normalized slowest queries:** skip it; nothing shows that it holds queries missing from
  the sections above.
- **Histogram of query times:** gives the latency floor, which is what the report can see.
- **Most frequent errors and events:** authentication failures and connection resets.
- **Global statistics (removed tuples, vacuum CPU):** signals of TOAST churn and bloat.

Because queries are normalized, the same text with different parameters is a single row.
