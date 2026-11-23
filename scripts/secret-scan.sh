#!/usr/bin/env bash
# Scan the staged changes for secrets.
# Uses gitleaks when installed; otherwise falls back to a short list of regexes and says so.
# Usage: secret-scan.sh            (scans what is staged)
#        secret-scan.sh --all      (scans every tracked and untracked, non-ignored file)
set -u

here="$(cd "$(dirname "$0")" && pwd)"
config="$here/../.gitleaks.toml"
mode="${1:-staged}"

if command -v gitleaks >/dev/null 2>&1; then
  args=()
  [ -f "$config" ] && args=(--config "$config")
  if [ "$mode" = "--all" ]; then
    gitleaks dir --redact --no-banner "${args[@]}" . 2>/dev/null \
      || gitleaks detect --no-git --redact "${args[@]}" --source .
  else
    gitleaks git --staged --redact --no-banner "${args[@]}" 2>/dev/null \
      || gitleaks protect --staged --redact "${args[@]}"
  fi
  exit $?
fi

echo "secret-scan: gitleaks is not installed, using the built-in regex fallback (weaker)." >&2

# One pattern per line. Written so that this file does not match its own patterns.
patterns='ghp_[A-Za-z0-9]{36}
github_pat_[A-Za-z0-9_]{22,}
sk-[A-Za-z0-9_-]{20,}
AKIA[0-9A-Z]{16}
-----BEGIN [A-Z ]*PRIVATE KEY-----
[Aa]uthorization["'"'"']?[:=][[:space:]]*["'"'"']?(Bearer|Basic|Token)[[:space:]]+[A-Za-z0-9._~+/=-]{8,}'

if [ "$mode" = "--all" ]; then
  text="$( { git ls-files; git ls-files --others --exclude-standard; } | sort -u \
    | grep -v -e '^\.gitleaks\.toml$' -e '^scripts/secret-scan\.sh$' \
    | while IFS= read -r file; do [ -f "$file" ] && sed "s|^|$file:|" "$file"; done)"
else
  text="$(git diff --cached --no-color -U0 --diff-filter=ACMR \
    -- . ':(exclude).gitleaks.toml' ':(exclude)scripts/secret-scan.sh' \
    | grep -E '^\+[^+]' | sed 's/^+//')"
fi

patfile="$(mktemp)"
trap 'rm -f "$patfile"' EXIT
printf '%s\n' "$patterns" > "$patfile"

hits="$(printf '%s\n' "$text" | grep -E -n -f "$patfile" \
  | grep -v -E '\$\{[A-Z_]+\}' | sed -E 's/^([^:]*:)(.{0,14}).*/\1\2.../')"

if [ -n "$hits" ]; then
  echo "secret-scan: possible secret found (value truncated):" >&2
  printf '%s\n' "$hits" >&2
  echo "Remove it, or bypass once with --no-verify if it is a false positive." >&2
  exit 1
fi
exit 0
