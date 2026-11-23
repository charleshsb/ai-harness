# Shape of a Review Finding

Reviews produce findings, and something downstream (a person, a script, a fix step) acts on
them. This rule defines the minimum every finding must carry so that later rounds can refer
to it and a consumer can locate it, whatever produced it.

## Required fields

Every finding has:

- **`id`**: unique within one review run and never renumbered. Later rounds refer to a
  finding by this id, so it keeps its meaning for the whole run.
- **`summary`**: one sentence stating the defect. It describes the problem, not the cure.
- **`quote`**: the exact text the finding is about, copied verbatim from the reviewed
  material. A line number alone is not an anchor: it moves after the next rebase or edit,
  whereas the quoted text can be searched for.
- **`absence`** (only for something missing): a flag saying the finding is about what is not
  there, such as a test never written or a requirement left unaddressed. In that case do
  not invent a place to point at; the finding says plainly that there is nothing to quote.

Field names are a consumer's choice; the obligation is what counts.

## Optional extras

A tool may add fields (a severity, a suggested fix, evidence labels). It describes them
in its own format document and marks which fields come from this common core. Severity scales
are intentionally not specified here: two consumers read two different scales, and each
owns the meaning of its levels.

## Example

Good:

```json
{
  "id": "sec-1",
  "quote": "invoice = Invoice.find(params[:id])",
  "summary": "The lookup is not scoped to the caller, so any signed-in user can read any invoice."
}
```

```json
{
  "id": "test-2",
  "absence": true,
  "summary": "No test covers the case where the discount code has expired."
}
```

Bad:

```json
{
  "id": 3,
  "line": 41,
  "summary": "Security problem in the invoices controller."
}
```

The line number alone will drift, and the summary names no defect.
