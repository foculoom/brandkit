# brandkit — Copilot Instructions

Foculoom Copilot CLI plugin for brand asset pipeline, visual QA, compliance, and product-ops skills.
Install alongside [orqit](https://github.com/foculoom/orqit) for the full Foculoom product workflow.

Current version: see `plugin.json` → `version` field.

## Commands

```bash
# Install published release
copilot plugin install brandkit@foculoom

# Install from local source (for testing changes)
copilot plugin install --local .

# After install: link skills from foculoom-project
bash scripts/link-plugin-assets.sh

# Verify installed skills are linked
ls ~/.copilot/installed-plugins/foculoom/brandkit/skills/
```

## Repository structure

```
plugin.json          — plugin manifest
skills/              — one directory per skill, each with SKILL.md
  a11y-godot/        — Godot 4.x iOS accessibility checklist (VoiceOver, Reduce Motion, Dynamic Type)
  brand-asset-pipeline/ — PNG-first brand asset creation and compositing workflow
  brand-compliance/  — validate brand alignment for product surfaces
  llc-ops/           — California LLC compliance reminders, tax deadlines, invoice generation
  release-asset-fanout/ — generate canonical release asset slots from a hero PNG
  sprite-gen/        — AI sprite generation with reference-chain continuity (Domain 16)
.github/workflows/
  auto-release.yml   — creates a GitHub Release when version in plugin.json changes on master push
```

## Skill conventions

- `brand-asset-pipeline` enforces PNG-first output and routes all AI generation through rendit.
  Never call fal-ai or other AI image services directly from brandkit skills.
- `sprite-gen` enforces reference-chain continuity and Domain 16 (Foculoom Universe Visual Identity)
  vocabulary rules. Always check `docs/mentor-registry.md §16` before authoring or reviewing
  sprite-gen output.
- `llc-ops` uses California-specific LLC rules. Tax deadlines and form numbers are California SOS /
  FTB specific — do not generalize to other states.
- `a11y-godot` is scoped to Godot 4.x iOS exports only. For SwiftUI/UIKit accessibility, use
  separate Apple HIG guidance.

Per Domain 12 (AI Agent & Skill Authoring): do not embed full copies of workflow rules from
foculoom-project `copilot-instructions.md`. Keep skill files as concise procedure documents
with pointers to canonical sources.

## Release workflow

1. Make changes on a feature branch.
2. Bump `version` in `plugin.json` for any content change to skills/.
3. Open a PR. `auto-release.yml` creates a GitHub Release on merge when version changes.
4. Verify: `gh release list --repo foculoom/brandkit | head -5`
5. After release: `copilot plugin update` on all active machines.

---

## Foculoom Workflow

**This repo is part of the Foculoom product ecosystem.**

**At every session start, you must load the foculoom-project workflow policy
before any spec, plan, or implementation work:**

1. Locate the foculoom-project checkout root (`FP`):
   - Default: `~/foculoom/infra/foculoom-project`
   - Auto-discover: `find ~/foculoom -maxdepth 4 -name foculoom-project -type d 2>/dev/null | head -1`
   - **If not found: STOP — raise a founder gate before proceeding.**
2. Read `$FP/.github/copilot-instructions.md` via the `view` tool.
3. All relative paths in those instructions (`docs/mentor-registry.md`,
   `.github/skills/`, `docs/policy/strategy-fit-gate.md`, etc.) resolve
   from `$FP`, not from this repo's root.

All mandatory gates and workflow rules (strategy-fit, mentor domain check,
dev-session lifecycle, brand asset sourcing, PR-first workflow, and all others)
are defined in that file. Do not infer that any gate is optional because
it is not listed here.
