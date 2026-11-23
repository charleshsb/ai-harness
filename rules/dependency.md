---
paths:
  - "**/Gemfile"
  - "**/Gemfile.lock"
  - "**/*.gemspec"
  - "**/package.json"
  - "**/package-lock.json"
  - "**/yarn.lock"
  - "**/pnpm-lock.yaml"
  - "**/requirements*.txt"
  - "**/pyproject.toml"
  - "**/poetry.lock"
  - "**/Cargo.toml"
  - "**/Cargo.lock"
  - "**/pom.xml"
  - "**/build.gradle"
  - "**/build.gradle.kts"
---

# Dependencies

For any change that adds, upgrades or removes a dependency, whatever the package manager.
The figures below (50 lines, 12 months, 72 hours) are defaults for a small team; edit them in
your copy if your policy differs.

## Before adding one

Ask these in order and stop at the first yes:

1. Does the standard library already do it?
2. Does something already in the dependency tree do it?
3. Could it be written in roughly 50 lines of ordinary project code, correctly and safely?

Only when all three answers are no do candidates come into view. A candidate qualifies when
it is maintained (a release in the last 12 months, issues that get answers), widely used
rather than an abandoned fork or one person's experiment, focused on a single purpose, with
a transitive tree sized to the problem, and licensed under MIT, Apache 2.0 or BSD.

In browser code, every visitor downloads what you ship. Bring in only the piece you need
(`import debounce from "lodash/debounce"` instead of all of `lodash`), and weigh a large
addition against the bundle growth it causes.

## Versions and lockfiles

- Pin an exact version or a tight range. Open-ended specifiers (`>=`, `*`, `latest`) have no
  place in production dependencies.
- Commit the lockfile, and keep it consistent with the manifest.

## Known vulnerabilities

- Before adding or upgrading, audit the whole tree, transitive packages included. Use
  `bundle audit check --update` for Bundler, `npm audit` or `yarn audit` for JavaScript,
  `pip-audit` for Python, `cargo audit` for Rust, and OWASP `dependency-check` on the JVM.
- Do not add a package with an open advisory, even when the vulnerable function is not
  called today: the next change might call it.
- Run the audit in CI as a blocking step, so a pull request that brings in a known
  vulnerability cannot merge.
- An advisory in a dependency you already use is fixed by severity: critical or high within
  72 hours, medium within two weeks, low at the next maintenance window. Exposure orders the
  work inside a level; it never decides whether to fix.

## Licenses

Look at the full tree, not just direct dependencies. GPL, AGPL, LGPL, SSPL, source-available
and proprietary licenses are out unless the project's owner decides otherwise in writing.
Helpful tools: `license_finder` for Ruby, `license-checker` for npm, `pip-licenses` for
Python, `cargo-license` for Rust.

## Removing one

- Delete a dependency as soon as nothing uses it. Keeping it for a hypothetical future need
  is not a reason.
- Then confirm the lockfile changed and CI passes. `bundle clean`, `depcheck` and
  `pip-autoremove` help find leftovers.

## Example

```text
Need: parse iCalendar recurrence rules in Ruby
Standard library: no support. Hand-written: about 80 lines plus calendar edge cases.
Over the threshold -> pick a maintained, permissively licensed gem,
run `bundle audit check --update` and `license_finder`, then add it.
```

```text
Need: capitalise the first letter of a string in JavaScript
-> npm install a string-utilities package
One line of code does it: below the threshold, and a new package is new supply-chain risk.
```

```text
gem "some-gpl-tool" added without reading its license
A copyleft license can bind the whole codebase: a legal blocker found too late.
```
