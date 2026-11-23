#!/usr/bin/env bash
# Minimal Claude Code status line: directory, git branch (+ dirty marker), model, context use.
# Claude Code feeds a JSON document on stdin; requires jq.
input=$(cat)

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')

out="$(basename "${cwd:-.}")"

if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short -q HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=""
    [ -n "$(git -C "$cwd" -c gc.auto=0 status --porcelain 2>/dev/null)" ] && dirty="*"
    out="$out ($branch$dirty)"
  fi
fi

[ -n "$model" ] && out="$out | $model"
[ -n "$used" ] && out="$out | ctx ${used%.*}%"

printf '%s' "$out"
