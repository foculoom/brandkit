#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 -m json.tool plugin.json >/dev/null
python3 -m json.tool hooks.json >/dev/null

python3 - <<'PY'
import json, pathlib

root = pathlib.Path(".")
plugin = json.loads(root.joinpath("plugin.json").read_text())

def parse_frontmatter(path: pathlib.Path):
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    out = {}
    for line in lines[1:]:
        if line.strip() == "---":
            return out
        if ":" in line:
            k, v = line.split(":", 1)
            out[k.strip()] = v.strip()
    return None

for rel in plugin.get("skills", []):
    d = root / rel
    if not d.exists():
        raise SystemExit(f"Missing skill dir: {rel}")
    md = d / "SKILL.md"
    if not md.exists():
        raise SystemExit(f"Missing SKILL.md: {md}")
    fm = parse_frontmatter(md)
    if fm is None:
        raise SystemExit(f"Missing frontmatter: {md}")
    if not fm.get("name"):
        raise SystemExit(f"Missing name in frontmatter: {md}")
    if not fm.get("description"):
        raise SystemExit(f"Missing description in frontmatter: {md}")
    if fm["name"] != d.name:
        raise SystemExit(f"Dir/frontmatter mismatch: {d.name} vs {fm['name']}")
print("skills/frontmatter checks: ok")
PY

grep -q "foculoom/brandkit@v1.0.3" README.md
! grep -q "foculoom/brandkit@v1.0.0" README.md
grep -q "preview/blocked" README.md
! grep -R -n "/Users/hello/" skills README.md >/dev/null

echo "validate-plugin: ok"
