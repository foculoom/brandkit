---
name: sprite-gen
description: AI sprite generation pipeline for Foculoom universe characters. Enforces reference-chain continuity, art director review gate, Domain-16 vocabulary rules, and generation parameters. Use whenever generating or retrying any character sprite frame.
tier: standard
---

# Sprite Generation Pipeline

## Model

- **Preferred:** `claude-sonnet-4.6`
- **Cost-tier fallback:** `claude-haiku-4.5` — see `/fallback-mode`
- **Source of truth:** Model Routing Matrix in `.github/skills/dev-session/SKILL.md`
- **Art director review step:** `claude-opus-4.7` (Domain-14/15/16 judgment)

---

## Core Rules

### 1. Reference Chain Rule (MANDATORY)

Every frame after the first in a sequence MUST pass `reference_image_url` pointing to the prior approved frame. Never pass `reference_image_url: None` for any frame after frame 1 in a sequence.

| Frame | `reference_image_url` |
|---|---|
| `idle_01` | `None` (first/canonical frame — no prior frame exists) |
| `run_01` | approved `idle_01` (transitioning from rest to run) |
| `run_02` | approved `run_01` |
| `run_03` | approved `run_02` |
| `react_01` | approved `idle_01` (reaction from standing state) |

**Rationale:** Style features of `run_01` (proportions, glow treatment, shoe/costume rendering) must carry forward to `run_02` and `run_03` for animation continuity. Using `idle_01` as the reference for all run frames is a production error — it severs the motion continuity that makes a run cycle coherent.

**Local file upload rule:** Local files must be uploaded via `fal_client.upload_file(path)` to obtain an HTTP URL before passing to `reference_image_url`. The raw local path will be rejected by the fal API.

```python
# Correct pattern
reference_url = fal_client.upload_file("/path/to/run_01_approved.png")
result = generate_character_figure(..., reference_image_url=reference_url)

# Wrong — never do this
result = generate_character_figure(..., reference_image_url=None)   # for run_02/run_03
result = generate_character_figure(..., reference_image_url="/local/path.png")  # local path
```

### 2. Art Director Gate Rule (MANDATORY — never skip)

After every generation, REVIEWER runs Domain-16 triage + Domain-14/15 quality check BEFORE any founder gate fires.

- **Evaluator (structural PASS) is NOT sufficient for visual assets** — art director verdict required
- **Tier-A (FAIL hard block):** route back to BUILDER; do not surface to founder
- **Tier-B (WARN advisory):** surface to founder with advisory note attached
- **Tier-C (PASS):** surface to founder

Skipping this gate is a CONDUCTOR failure. See 5-whys postmortem #1429 comment 4551656644.

### 3. Vocabulary Rules

**NEVER use "traces" as positive vocabulary.** The term `traces` triggers circuit-mesh aesthetics in fal kontext (e.g., geometric grid overlays, tron-line body art).

| ❌ Prohibited | ✅ Correct replacement |
|---|---|
| `luminescent traces` | `subsurface biophotonic glow` |
| `teal traces through forearms` | `organic light bleed beneath skin surface` |

**Extended exclusion tokens (required in every prompt):**

```
no circuit traces, no tron-style lines, no tech suit panels, no segmented armor lines, no neon line art body overlay
```

These extend the base exclusion set and are mandatory for all frames generated after `run_01` (where vocabulary was updated post-approval).

### 4. Generation Parameters (DIFFREK Canonical)

| Parameter | Value | Notes |
|---|---|---|
| Model (text-only, no reference) | `fal-ai/flux-pro/kontext/max/text-to-image` | Use when no `reference_image_url` |
| Model (with reference) | `fal-ai/flux-pro/kontext/max` | kontext editing endpoint — rendit routes here automatically when `reference_image_url` is provided |
| Seed | `42847292` | **NEVER use `42847291`** — produces all-black output |
| `guidance_scale` | `13` | Anti-geometric constraint enforcement |
| `num_inference_steps` | `50` | |
| `image_size` / aspect ratio | `square_hd` / `1:1` | |
| `output_format` | `png` | |

**Pre-rembg rule:** Save the pre-rembg output for art director review. Applying rembg (background removal) before review obscures edge artifacts and glow treatment. rembg is production-only — apply only after Tier-C pass.

### 5. Domain-16 Triage Checklist

Run after every generation. Record verdict in PR before surfacing to founder.

#### Tier-A FAIL (hard block — return to BUILDER, do not surface)

- Circuit mesh overlay visible on body
- Repeating grid pattern on skin/costume surface
- Tron-style lines (geometric body art, neon line borders)
- Geometric lattice or wireframe structure on body
- Structural wireframe visible through or over character

#### Tier-B WARN (surface to founder with advisory note)

- Near-symmetric teal distribution across both arms (should be right-dominant)
- Surface-halo glow instead of subsurface glow (glow is on top of skin, not emanating from within)
- Subtle structural hints visible (borderline — note location and severity)

#### Tier-C PASS (surface to founder)

All of the following must hold:

- [ ] Cartoon-coherent style (clean outlines, graphic simplification)
- [ ] Organic biophotonic glow — light emanates from within, not as surface overlay
- [ ] Right arm carries noticeably more teal glow than left arm
- [ ] Deep indigo body with depth effect (not flat matte)
- [ ] Aperture-style eyes (circular, visible pupil)
- [ ] Coral streaming/elevated hair filaments (state appropriate to frame)
- [ ] Zero Tier-A indicators

### 6. When to Invoke This Skill

- Generating any Foculoom universe character sprite frame
- Retrying a failed frame (Tier-A rejection or identity checklist failure)
- Adding a new character's frames to the pipeline
- Reviewing whether a prior generation pass followed the reference chain

---

## Quick-Reference: DIFFREK Frame Chain

```
idle_01 (canonical)
    │
    ├─→ run_01  [ref: idle_01]
    │       │
    │       └─→ run_02  [ref: run_01]  ← run_02 MUST NOT use idle_01 or None
    │               │
    │               └─→ run_03  [ref: run_02]
    │
    └─→ react_01  [ref: idle_01]
```

---

## References

- Spec: `specs/2026-05-ai-sprite-pipeline-v1-spec.md`
- Prompt templates: `scripts/sprite-prompt-templates.md`
- 5-whys postmortem: foculoom/foculoom-project#1429 comment 4551656644
- Model Routing Matrix: `.github/skills/dev-session/SKILL.md` § Model Routing Matrix
