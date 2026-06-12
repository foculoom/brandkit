# brandkit

Foculoom Copilot CLI plugin — brand asset pipeline, visual QA, compliance, and product-ops skills.

Install alongside [orqit](https://github.com/foculoom/orqit) for the full Foculoom product workflow.

## Install

```bash
copilot plugin install brandkit@foculoom
```

Or for a specific version:

```bash
copilot plugin install foculoom/brandkit@v1.0.3
```

## Skills

| Skill | Purpose |
|-------|---------|
| `brand-asset-pipeline` | Create/update Foculoom brand assets — icons, OG images, manifests. PNG-first pipeline. |
| `brand-compliance` | Validate brand alignment for any product surface — colors, typography, logos, trust claims. |
| `release-asset-fanout` | Generate canonical release asset slots from a hero PNG (App Store screenshot, social preview, etc.). |
| `sprite-gen` | AI sprite generation — reference-chain continuity, art director review gate, generation parameters. |
| `a11y-godot` | Godot 4 iOS accessibility checklist for kids products (VoiceOver, Reduce Motion, Dynamic Type). **Status: preview/blocked (outline only).** |
| `llc-ops` | California single-member LLC compliance reminders, tax deadlines, and invoice template. |

## Usage with orqit

Install both plugins in any Foculoom product repo:

```bash
copilot plugin install orqit@foculoom    # workflow: conductor/planner/builder/reviewer + 16 skills
copilot plugin install brandkit@foculoom # brand: 6 brand/compliance/ops skills
```

## Version history

- **1.0.3** — Current release.
- **1.0.0** — Initial release. Extracted from `foculoom/foculoom-project`.

## Prerequisites and portability

Some skills require private repos/tools. Configure paths via environment variables
instead of machine-specific defaults:

- `FOCULOOMBRAND_PATH` — local checkout path to `foculoombrand`
- `BRANDKIT_OUTPUT_ROOT` — optional output override for generated assets

Before running a skill, verify whether it requires private repo access, MCP/router
setup, or local scripts described in that skill's prerequisites block.
