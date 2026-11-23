---
paths:
  - "**/app/*.rb"
  - "**/app/**/*.rb"
  - "**/config/*.rb"
  - "**/config/**/*.rb"
  - "**/db/migrate/*.rb"
  - "**/spec/*.rb"
  - "**/*.gemspec"
---

# Rails Structure

Where code belongs in a Rails application. Query cost is handled in `ruby-rails-perf`;
language style in `ruby`.

## Models

- A model describes data: associations, validations, scopes, and small domain methods.
- Multi-step business operations belong in a service object, not in the model.
- Scopes are named, chainable and return a relation. Avoid `default_scope`: it adds
  conditions to queries nobody wrote.
- Declare integrity rules (presence, uniqueness, inclusion) at model level, backed by
  database constraints.
- A paginated list ends its ordering with a unique key (the id), including when the client
  chooses the sort column. Without it, rows with equal values can repeat or vanish between
  pages.
- Give `enum` an explicit hash of values. Declaring it from an array ties meaning to
  position, so reordering the list silently reinterprets stored rows.

## Controllers

- A controller reads params, authenticates and authorizes, calls one service, and renders.
- Strong parameters live in a private `<action>_params` method; never `permit!`.
- Use `before_action` for authentication and authorization, not for loading data other
  actions might not need.
- Handle shared failures with `rescue_from` in the base controller, producing a structured
  body. What may appear in that body is set by `error-handling`.
- An action over about ten lines is a hint that logic wants to move out.

## Callbacks

- Normalizing data (`before_validation`) and guard checks (`before_destroy`) are fine.
- Do not send mail, enqueue jobs or call remote services from `after_save`-style callbacks;
  call them explicitly from the service that owns the operation.
- `after_commit` is the right hook only when something must not run if the transaction
  rolls back.

## Services

- One service, one use case, named with a verb phrase and namespaced by domain
  (`Orders::Cancel`, `Billing::IssueRefund`).
- Inputs go through `initialize` as keyword arguments; the only public method is `call`.
- Return a result object or raise. Never return a bare `nil` to signal failure, and do not
  rescue `StandardError` wholesale: a dropped connection is not a business outcome.
- Introduce one when an action spans models, has an external effect, or has several callers.

## Migrations

- A migration that has run anywhere is immutable; add a new one.
- Every change can be reversed (`change` that Rails can invert, or explicit `up`/`down`).
  A destructive schema change gets an explicit `down` or a `reversible` block; it restores
  the structure, never the data that was lost.
- The version of a new migration is the actual UTC time, to the second, as stamped by the
  Rails generator (`bin/rails generate migration`). Let the generator create the file rather than
  typing a timestamp: a rounded, hand-typed value (`20260101120000`) can be invented by two
  branches at once and raises `ActiveRecord::DuplicateMigrationVersionError`.
- Create the index in the same migration as the column or reference.
- Keep data backfills out of schema migrations; run them as a task. Where such a task lives
  is in `ruby-task-migration`, and whether running it is safe is in
  `ruby-rails-migration-safety`.
- Naming: `is_` prefix for booleans, `_at` for timestamps, `<model>_id` for references.

## Routes

- Prefer resourceful routes; model a custom verb as its own nested resource when that reads
  more clearly.
- No catch-all route in production. Group with `namespace` or `scope`.
- A route or payload shape consumed by another codebase falls under `compatibility`.

## Jobs

- Safe to run twice. Arguments are ids and primitives, never records.
- The job delegates to a service; it holds no logic of its own.

## Specs

- Services, validators and jobs follow `tdd`; layout follows `test-structure`.
- Prefer `build_stubbed` to `create` when persistence is not the point.
- Controller specs check status and rendering; rules are verified in service specs.
- Reserve system specs for a few critical user journeys.

## Example

```ruby
class SubscriptionsController < ApplicationController
  def create
    outcome = Subscriptions::Start.new(account: current_account, plan_id: params[:plan_id]).call

    if outcome.success?
      render json: outcome.subscription, status: :created
    else
      render json: { error: outcome.code }, status: :unprocessable_entity
    end
  end
end

class Subscription < ApplicationRecord
  belongs_to :account
  enum :state, { trialing: 0, active: 1, cancelled: 2 }
  scope :active, -> { where(state: :active) }
end
```

```ruby
class Subscription < ApplicationRecord
  after_create :email_welcome              # side effect hidden in a callback
  after_save   :push_to_crm                # network call inside the save

  def self.start_and_bill(params)          # a use case living in the model
    subscription = create!(params)
    Billing.charge(subscription)
    subscription
  end
end
```
