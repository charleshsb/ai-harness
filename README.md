# ai-harness

A small, opinionated working environment for an AI coding assistant: rules that keep
generated code reviewable, a read-only review skill, git hooks that protect the main branch
and catch secrets.

It is built as a portable core plus adapters. The core is plain Markdown and shell, and
depends on no tool. An adapter wires the core into one tool; one adapter is included, for
Claude Code. If you stop using that tool, the core still works with the next one.

Everything here is plain text. You read it, you symlink it, you change it.

## What it is for

- Give the assistant consistent standards (testing, naming, error handling, security,
  dependencies, and Ruby/Rails, TypeScript/React and Python conventions) that load only for
  the files they concern.
- Keep a human in the loop: the working habits in `AGENTS.md` make every commit and push an
  explicit decision.
- Review a branch before anyone else has to, one axis at a time.
- Make the safe path the default: no direct commits to `main`, no secrets in history.

## Layout

```text
ai-harness/
├── README.md
├── AGENTS.md                  working habits (commits, staging, spec wording, naming, review)
├── CLAUDE.md                  one line importing AGENTS.md, for Claude Code
├── rules/                     core: 28 rules, one Markdown file each
├── skills/                    core: skills, each a SKILL.md and its supporting files
│   ├── review/                read-only review: code, performance, security, and
│   │                          requirement and tests when given a spec
│   ├── spec-design/           read-only design dialogue before a plan or a spec
│   └── pgbadger-analysis/     pgBadger reports into ranked, evidence-backed findings
├── hooks/                     core: plain git hooks
│   ├── pre-commit             blocks commits on main/master, then scans for secrets
│   └── pre-push               blocks pushes to main/master
├── scripts/
│   └── secret-scan.sh         gitleaks if installed, regex fallback otherwise
├── .gitleaks.toml             scanner configuration
└── adapters/
    └── claude/                everything specific to Claude Code
        ├── install.sh         idempotent symlinks into ~/.claude
        ├── merge-settings.py  merges settings.template.json into ~/.claude/settings.json
        ├── settings.template.json   hooks, status line, plugins, marketplaces
        ├── mcp.template.json  MCP servers; every credential is a ${VARIABLE}
        ├── statusline.sh      minimal status line (needs jq)
        ├── rules/             rules that only make sense in Claude Code (worktree)
        └── skills/            skills that only make sense in Claude Code (worktree)
```

## The core

### Rules

Rules in `rules/` have an optional `paths:` front matter that scopes them to matching
files, so a Ruby rule does not load while you edit TypeScript. A tool that ignores the
front matter simply loads them everywhere.

| Group | Rules |
|---|---|
| Core | `tdd`, `clean`, `solid`, `error-handling`, `security`, `logging`, `debug`, `dependency` |
| Git | `branch`, `commit`, `protect-main`, `conflict-intent` |
| Ruby, Rails, tests | `ruby`, `ruby-rails`, `ruby-rails-perf`, `ruby-rails-migration-safety`, `ruby-task-migration`, `test-scope`, `test-structure` |
| TypeScript, React | `typescript`, `typescript-react`, `typescript-react-perf` |
| Python | `python` |
| Method | `spec`, `doc`, `compatibility`, `efficiency-guardrails`, `mermaid-syntax` |

Ticket references are optional everywhere: branch names and commit footers work the same
with or without a tracker key.

### Skills

`skills/review` compares the current branch with its base and runs three read-only passes
(code, performance, security). When you give it the requirement (ticket text or a spec
file), it adds two more: whether the change does what was asked, and whether that behavior
is tested. Findings follow `skills/review/standards/review-findings.md`
(id, one-sentence summary, exact quote, explicit "absence" when something is missing) and are
shown one at a time for you to keep or drop. It never edits files or touches git state. The
skill reads its method from `standards/` next to its `SKILL.md`, and the language rules from
`rules/`.

`skills/spec-design` is a read-only dialogue for a request that is not framed yet: it
restates the problem, compares a few approaches, asks one question at a time, and ends with a
summary. It writes nothing and drafts no spec.

`skills/pgbadger-analysis` reads pgBadger reports of a PostgreSQL database and returns a
ranked list of performance findings, each tied to the code that issues the query and marked
confirmed or to verify. It never changes code and never connects to production.

### Git hooks and secret scan

Hooks work per clone, so they are installed per repository. `pre-commit` refuses a commit
while on `main` or `master` and then runs `scripts/secret-scan.sh` on the staged changes.
`pre-push` refuses any push that updates `main` or `master`. If `gitleaks` is installed it is
used with `.gitleaks.toml`; if not, a shorter regex scan runs and says so. Install gitleaks
yourself if you want the full ruleset.

They are plain git hooks and need no adapter: symlink them into a repository by hand.

```bash
ln -s "$PWD/hooks/pre-commit" ~/Code/some-project/.git/hooks/pre-commit
ln -s "$PWD/hooks/pre-push"   ~/Code/some-project/.git/hooks/pre-push
```

### Tool conventions in the core

Two details follow Claude Code conventions and are harmless elsewhere: the `paths:` front
matter in rules and the `allowed-tools` line in `SKILL.md`. The working habits live in
`AGENTS.md`, the name most AI tools read; `CLAUDE.md` is a one-line file that imports it for
Claude Code.

## Use with Claude Code

```bash
git clone <this repository> ~/Code/ai-harness
cd ~/Code/ai-harness

adapters/claude/install.sh --dry-run    # see what would happen
adapters/claude/install.sh              # link into ~/.claude
```

The installer links `AGENTS.md` as `~/.claude/CLAUDE.md` (an import from the repository's own
`CLAUDE.md` would not be followed from there), each file in `rules/` and each folder in
`skills/` (the core's and the adapter's own), and the status line script. A file already
present at a target path is moved to `<path>.bak` (`.bak.1`, `.bak.2`, ... if a backup
exists). Running it twice changes nothing the second time.

It also merges `adapters/claude/settings.template.json` into `~/.claude/settings.json` with
`adapters/claude/merge-settings.py`: the file is created if absent; otherwise only missing
keys are added, your values are kept, an existing hook list is left alone, and the old file
is saved as `settings.json.bak` first. For MCP servers, copy the entries you want from
`adapters/claude/mcp.template.json`, and export the variables they mention in your shell
profile or your secret manager; no value is stored in this repository.

To install the git hooks into a repository with the same backup behavior:

```bash
adapters/claude/install.sh --git-hooks ~/Code/some-project
```

### Optional tools

- **rtk** (token-saving command proxy). `settings.template.json` registers its hook, guarded
  by `command -v rtk`: without the binary the hook does nothing. Install it with
  `brew install rtk` if you want it.

## Writing another adapter

An adapter makes the core visible to one tool. Put it in `adapters/<tool>/` and keep
anything specific to that tool there; the core stays untouched.

1. Find where the tool reads instructions and skills, and link or copy `rules/` and
   `skills/` there. A symlink keeps edits live; a copy needs a re-run.
2. Map what the tool calls things. If it has no per-path scoping, the `paths:` front matter
   is ignored and the rules load everywhere. Most tools read `AGENTS.md` as it is; for one
   that wants another file name, link or import it.
3. Make the installer idempotent and non-destructive: skip a link that already points at
   this checkout, move anything else to a `.bak`, offer `--dry-run`, never overwrite a
   settings file (merge, keep the user's values, back up first).
4. Keep credentials out: templates use `${VARIABLE}` placeholders only.
5. Reuse `hooks/` and `scripts/secret-scan.sh` as they are; they need git only.

## What is not included

- **Plugins.** `settings.template.json` lists plugins (ruby-lsp, superpowers, ponytail,
  claude-mem, claude-mem-cowork) and their marketplaces, and Claude Code installs them from
  there. Their code is never copied into this repository.
- **Secrets and credentials.** No tokens, no headers with values, no account
  identifiers. Templates use `${VARIABLE}` placeholders.
- **Personal state.** Session history, memory databases and `~/.claude.json` are not part
  of the harness.
- **Organization-specific tooling.** Pull request templates tied to a tracker, server access
  policies and company integrations are left out on purpose.

## Customizing

Edit a rule in place: the symlink means the change is live in every project. Project-specific
rules go in that project's own `.claude/rules/`, next to these.
