---
paths:
  - "**/app/*.rb"
  - "**/app/**/*.rb"
---

# Rails Query Cost

What a line of ActiveRecord costs at the volume it will see in production. For finding and
ranking such problems in a diff, see the performance pass of the `review` skill; for structure, `ruby-rails`.

## Fetch less, fetch once

- Need one column? `pluck(:column)`. `map(&:column)` builds every object just to drop it.
- Need only ids or counts? Ask for them; do not materialize records.
- On wide tables, `select` the columns you use.
- Associations that will be read later are loaded up front with `includes`, `preload` or
  `eager_load`. When the association only filters, `joins` is enough.

## Nothing hidden in a loop

- No `count`, `exists?` or query per iteration. Aggregate once, with `group(...).count` or
  a single indexed lookup into a hash.
- Do not enqueue a job per element; enqueue in bulk, or enqueue one job that iterates.
- Parse or serialize shared data once, before the loop.

## Bounded memory

- Large tables are walked with `find_each` or `in_batches`, never `all.each`.
- Big files are streamed. Do not load a whole file to read it line by line.

## Indexes

- Index foreign keys.
- Index columns that appear in `where`, `order` or `group` on tables that will grow, and
  the columns backing a uniqueness validation.

## Say only what you measured

Report a speed-up only when you measured it or followed the code path that produces it. Take
"the second lookup is served from the query cache": it stops being true as soon as a
`reload`, a `reset` or a write happens between the two lookups, at any depth of the call
chain. With neither a measurement nor a trace, write "not measured" and leave it there.

## Example

```ruby
# Good
author_ids = Article.published.pluck(:author_id)
comment_counts = Comment.where(article_id: article_ids).group(:article_id).count
Article.includes(:author).find_each(batch_size: 500) { |article| render_card(article) }
```

```ruby
# Bad
author_ids = Article.published.map(&:author_id)           # loads every article
articles.each { |a| puts a.comments.count }               # one query per article
Article.all.each { |a| ReindexJob.perform_later(a.id) }   # whole table, one job per row
```
