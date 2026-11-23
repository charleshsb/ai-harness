---
paths:
  - "**/lib/tasks/*.rake"
  - "**/tasks/*.rake"
---

# One-Shot Data Fixes Live in Rake Tasks

Temporary data work (a backfill, a format cleanup, a one-time restructuring) deserves a home
that says "this ran once". It does not belong next to the permanent services.

## Where it goes

- Put the logic directly inside the rake task that runs it, in the same `.rake` file. Do not
  add a class under `app/services/` or any other autoloaded directory for it.
- A service class tells every later reader that the behavior recurs. A rake task tells them
  it ran once, for a reason, around a certain date.
- If the repository already keeps one-shot tasks under `lib/tasks/` and permanent logic under
  `app/services/`, follow that split instead of parking temporary code with the "real"
  services.

## Load order

- Rake files are read before the application's autoloader is ready. Any class you define in
  one must not inherit from an autoloaded base (`ApplicationService`, a model relying on
  `class_attribute`): the base cannot be resolved yet, and `rake -T` then fails to list
  anything at all, not just your task.
- After adding a class to a rake file, run `bundle exec rake -T`. A load-order mistake shows
  up there before it shows up when the task runs.

## Signs that it is one-shot

- Its name describes the single job, not a general capability (`RemoveLegacyPlanCodes`
  rather than `PlanMigrator`).
- It exposes nothing beyond what the rake task calls.
- When it has run in every environment, delete the file: it has no reason left to exist.

## Example

```ruby
# lib/tasks/remove_legacy_plan_codes.rake
namespace :remove_legacy_plan_codes do
  task run: :environment do
    Plan.where(code: "pro-2019").find_each { |plan| plan.update_columns(code: "pro") }
  end
end
```

```ruby
# app/services/remove_legacy_plan_codes/code_migrator.rb
# Looks permanent, is not, and the base class is not loaded yet when rake parses the file
class RemoveLegacyPlanCodes::CodeMigrator < ApplicationService
  def call
    # ...
  end
end
```

Whether running such a task is safe (volume, locking, resuming) is covered in
`ruby-rails-migration-safety`.
