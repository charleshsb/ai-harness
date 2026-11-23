---
paths:
  - "**/db/migrate/*.rb"
  - "**/db/schema.rb"
  - "**/lib/tasks/*.rake"
  - "**/tasks/*.rake"
---

# Rails Migration Safety

How a migration is shaped is in `ruby-rails`, and where one-shot data code lives is in
`ruby-task-migration`. This rule is about the moment of running: will it lock, will it
finish, can it be resumed, can both versions of the application live with it.

## Scale the effort

A nullable column or an index on a small table needs a glance. Big tables, large backfills,
destructive data changes, and anything that old and new code must survive together deserve
the questions below. They apply as much to a rake task that rewrites data as to a migration
file: what matters is the run, not where the code sits.

## Questions to answer before running

1. **Lock.** What does the statement block, and for how long, on this engine and version?
   Do not reason from another database. A lock that lasts through a scan of a large table
   (adding `NOT NULL`, rewriting a column) is an outage in waiting. On PostgreSQL, index a
   live table with `algorithm: :concurrently`, which also needs `disable_ddl_transaction!`.
2. **Size.** How many rows are involved? Give the number or the way to get it. What is fine
   at five hundred rows can sink fifty million, so batch, throttle or split.
3. **Two versions at once.** During a rolling deploy the old and new code share one schema.
   Does each cope with the other's? Renaming, dropping or retyping a column fails this unless
   it is done in stages: expand first, contract later.
4. **Backfill apart.** Run the schema step (seconds) and the data fill (possibly hours)
   separately. Fused, they form one step that cannot be resumed.
5. **Second run.** If the backfill dies halfway, can it start again without doubling its
   effects? Show the guard in the code (a `WHERE` clause, an upsert, a flag) rather than
   asserting idempotence.
6. **Removal.** Drop a column, table or index only once nothing reads it, older deployed
   versions included. State what must be true (the deploy is complete, a flag is confirmed
   unused), not a number of days to wait.
7. **Undo.** `down` and `reversible` restore the structure and never the rows already
   deleted. A data-destroying change is not made safe by having a `down`.
8. **Proof.** Choose the observable that shows success before starting: a row count, a
   checksum or a sampled comparison. "The job finished" is not an observation.

## Expand and contract

For changes that need it: add the new structure, move readers and writers across, backfill,
and only then remove the old structure. A change that takes one step should not be dressed up
as four.

## Limits

- This rule prepares and reviews the migration and the commands for running it. Running
  anything against a production database is the person's decision and action: see
  `efficiency-guardrails`.
- When you do not know how a given engine version locks a given operation, write that down
  as something to check instead of assuming.

## Example

```ruby
# Expand step: column and index here, the backfill in its own task, the old column removed
# in a later release
class AddCurrencyToOrders < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :orders, :currency, :string
    add_index :orders, :currency, algorithm: :concurrently
  end
end

# lib/tasks/backfill_order_currency.rake: resumable, scoped to what is left
namespace :backfill_order_currency do
  task run: :environment do
    Order.where(currency: nil).find_each(batch_size: 1000) do |order|
      order.update_column(:currency, "EUR")
    end
  end
end
```

```ruby
# One migration: the rewrite holds a lock for the whole scan, and a timeout halfway leaves
# no way to resume
class BackfillOrderCurrency < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :currency, :string
    Order.update_all(currency: "EUR")   # full-table rewrite inside the migration
  end
end
```
