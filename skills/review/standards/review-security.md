# Reviewing for Security

How to audit a change for security defects. What the code should do is in `security`; this
rule covers how to review it.

## Follow the data

- Trace from where input enters (source), through each transformation, to where it does
  something dangerous (sink).
- A finding needs both ends, and a path between them that you can show in the code you read.
  A risky operation that no input can reach is not yet a vulnerability.
- Name the source and the sink explicitly. "Possible injection somewhere in billing" is noise.

## Give an honest verdict

Pick exactly one:

| Verdict | Meaning |
|---|---|
| Exploitable | The path is reachable and a crafted input reaches the sink |
| Real risk | The path exists, but exploiting it needs a condition that is not true today |
| Theoretical | The pattern is unsafe, but nothing reaches it in this code |
| Bad practice | Neither reachable nor harmful now, yet unwise to write |

Inflating a bad practice into a critical issue spends credibility the next real finding
needs. Downgrading a reachable path costs more than that.

## Evidence

- Cite the code line where the defect sits, verbatim.
- Before stating how a tool, library or endpoint behaves right now, check it. Versions and
  fixes move faster than memory.
- Say what an attacker gets (read another user's data, run a command, skip a check), not just
  which pattern was matched.

## Example

Good:

```text
Exploitable - missing ownership check
  source: params[:document_id] (DocumentsController#show)
  sink:   `Document.find(params[:document_id])` with no scope
  impact: any signed-in user can open any document
  fix:    `current_user.documents.find(params[:document_id])`
```

Bad:

```text
Possible security issue in the documents module.
No source, no sink, no quote: the author cannot verify or fix it.
```
