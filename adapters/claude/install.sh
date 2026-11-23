#!/usr/bin/env bash
# Claude Code adapter: install ai-harness into ~/.claude by symlink.
#
#   adapters/claude/install.sh                     link AGENTS.md as CLAUDE.md, rules, skills, status line
#   adapters/claude/install.sh --dry-run           print what would change, change nothing
#   adapters/claude/install.sh --git-hooks <repo>  link the pre-commit and pre-push hooks into a repository
#
# Idempotent: a link that already points at this checkout is left alone. Anything else
# found at a target path is moved to <path>.bak (or .bak.1, .bak.2, ...) before linking.
# settings.json is merged, never replaced: see merge-settings.py in this directory (adds what
# is missing, keeps your values, backs the file up first). MCP configuration is never touched:
# see mcp.template.json in this directory and merge by hand.
set -eu

here="$(cd "$(dirname "$0")" && pwd)"
root="$(cd "$here/../.." && pwd)"
claude_dir="${HOME}/.claude"
dry_run=0
hooks_repo=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) dry_run=1 ;;
    --git-hooks)
      shift
      [ $# -gt 0 ] || { echo "install: --git-hooks needs a repository path" >&2; exit 2; }
      hooks_repo="$1"
      ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "install: unknown option '$1'" >&2; exit 2 ;;
  esac
  shift
done

changed=0
unchanged=0

say() { if [ "$dry_run" -eq 1 ]; then echo "[dry-run] $*"; else echo "$*"; fi; }

# link <source> <destination>
link() {
  src="$1"
  dest="$2"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    unchanged=$((unchanged + 1))
    return 0
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup="$dest.bak"
    n=0
    while [ -e "$backup" ] || [ -L "$backup" ]; do
      n=$((n + 1))
      backup="$dest.bak.$n"
    done
    say "backup  $dest -> $backup"
    [ "$dry_run" -eq 1 ] || mv "$dest" "$backup"
  fi

  say "link    $dest -> $src"
  if [ "$dry_run" -eq 0 ]; then
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
  fi
  changed=$((changed + 1))
}

if [ -n "$hooks_repo" ]; then
  hooks_dir="$(git -C "$hooks_repo" rev-parse --git-path hooks 2>/dev/null)" \
    || { echo "install: '$hooks_repo' is not a git repository" >&2; exit 1; }
  case "$hooks_dir" in /*) ;; *) hooks_dir="$hooks_repo/$hooks_dir" ;; esac
  for hook in pre-commit pre-push; do
    link "$root/hooks/$hook" "$hooks_dir/$hook"
  done
else
  # Claude Code reads the name CLAUDE.md. Linking the repo's own CLAUDE.md here would break
  # its `@AGENTS.md` import: tested 2026-11-23, an import is resolved from the real file's
  # directory, and a target outside the project was not loaded.
  link "$root/AGENTS.md" "$claude_dir/CLAUDE.md"

  for rule in "$root"/rules/*.md "$here"/rules/*.md; do
    [ -e "$rule" ] || continue
    link "$rule" "$claude_dir/rules/$(basename "$rule")"
  done

  for skill in "$root"/skills/*/ "$here"/skills/*/; do
    [ -d "$skill" ] || continue
    skill="${skill%/}"
    link "$skill" "$claude_dir/skills/$(basename "$skill")"
  done

  link "$here/statusline.sh" "$claude_dir/statusline.sh"

  merge_args=("$here/settings.template.json" "$claude_dir/settings.json")
  [ "$dry_run" -eq 1 ] && merge_args+=(--dry-run)
  python3 -I "$here/merge-settings.py" "${merge_args[@]}"
fi

say "done: $changed changed, $unchanged already up to date"
if [ -z "$hooks_repo" ] && [ "$dry_run" -eq 0 ]; then
  echo "Next: copy adapters/claude/mcp.template.json entries you want into ~/.claude.json, with your own secrets."
fi
