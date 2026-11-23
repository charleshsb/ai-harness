#!/usr/bin/env python3
"""Merge settings.template.json into a Claude Code settings.json without overriding anything.

    merge-settings.py <template> <settings> [--dry-run]

- No settings file yet: the template is copied as is.
- Otherwise only what is missing is added. A value you already have is never replaced.
  Objects are merged key by key; a list (such as a hook event) that already exists is
  left alone and reported, so a hook is never run twice.
- A changed file is first copied to <settings>.bak (.bak.1, .bak.2, ... if taken).
"""
import json
import shutil
import sys
from pathlib import Path


def merge(template, current, path, added, skipped):
    for key, value in template.items():
        where = f"{path}.{key}" if path else key
        if key not in current:
            current[key] = value
            added.append(where)
        elif isinstance(value, dict) and isinstance(current[key], dict):
            merge(value, current[key], where, added, skipped)
        elif isinstance(value, list) and current[key] != value:
            skipped.append(where)


def main(argv):
    args = [a for a in argv if not a.startswith("--")]
    dry_run = "--dry-run" in argv
    if len(args) != 2:
        print(__doc__, file=sys.stderr)
        return 2
    template_path, settings_path = Path(args[0]), Path(args[1])
    template = json.loads(template_path.read_text())
    prefix = "[dry-run] " if dry_run else ""

    if not settings_path.exists():
        print(f"{prefix}create {settings_path} from the template")
        if not dry_run:
            settings_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(template_path, settings_path)
        return 0

    current = json.loads(settings_path.read_text())
    added, skipped = [], []
    merge(template, current, "", added, skipped)

    for where in skipped:
        print(f"{prefix}kept   {where} (already set differently, merge by hand if wanted)")
    if not added:
        print(f"{prefix}ok     {settings_path} already has everything")
        return 0

    for where in added:
        print(f"{prefix}add    {where}")
    if not dry_run:
        backup = settings_path.with_name(settings_path.name + ".bak")
        n = 0
        while backup.exists():
            n += 1
            backup = settings_path.with_name(f"{settings_path.name}.bak.{n}")
        shutil.copyfile(settings_path, backup)
        print(f"backup {settings_path} -> {backup}")
        settings_path.write_text(json.dumps(current, indent=2) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
