---
name: brand-asset-pipeline
description: Procedure for creating or updating Foculoom brand assets. Use this when generating icons, compositing OG images, or working with the brand asset manifest. Enforces PNG-first pipeline and canonical asset rules.
tier: standard
---

# Brand Asset Pipeline

## Model

- **Preferred:** `claude-sonnet-4.6`
- **Cost-tier fallback:** `/model auto` → `claude-sonnet-4.5` — see `/fallback-mode` (foculoom/foculoom-project#463)
- **Source of truth:** Model Routing Matrix in `.github/skills/dev-session/SKILL.md`

## Pipeline hierarchy — rendit first, stochastic second

**`rendit` (foculoom/rendit) is the canonical pipeline for all net-new brand assets.** The stochastic pipeline (fal.ai / gpt-image-1) is a fallback used only when the asset requires imagery that rendit cannot yet produce.

> **Status:** rendit v0.1 shipped 2026-05-23 (foculoom/foculoom-project#1228 closed). The old "blocked until media-forge ships" gate is lifted. The hierarchy below replaces it.

### Decision rule — mandatory before every asset generation

```
1. Can rendit produce this asset within its current element support?
   → YES: write a rendit recipe YAML. Do not use fal.ai or gpt-image-1.
   → NO: identify the missing element types.
         Option A — extend rendit first (preferred), then use rendit.
         Option B — use stochastic fallback with explicit founder approval
                    and a written rationale in the tracking issue.
```

**BUILDER/CONDUCTOR:** defaulting to fal.ai or gpt-image-1 without first checking rendit is a policy violation. It will be caught at REVIEWER and routed back.

**rendit element support (v0.1, foculoom/rendit master 2026-05-23):**
- `rect` — filled/stroked rectangles
- `text` — positioned text with brand fonts
- `circle`, `ellipse` — pending foculoom/foculoom-project#1296

**Not yet in rendit — stochastic fallback permitted with approval:**
- `path` (bezier curves, organic shapes) — planned v0.2 (#1295)
- `group` / `transform` — planned v0.2 (#1295)
- Photorealistic imagery, mascot characters, photography-based assets

**Existing canonical assets** (Play Owl icon, BloomPlay font, palette tokens) may be composited with Pillow — compositing is deterministic. Re-generating or updating an existing canonical asset requires explicit founder approval with a written rationale in the tracking issue.

## Critical rules — never deviate

- **Router-first.** All image generation goes through the tiered router in
  `scripts/image-gen/backend.py`. Do not call `openai-image-create-image` or
  `fal-ai-*` MCP tools directly for brand assets — pass through `route()` so
  asset_type, palette, and alpha requirements pick the right backend. See
  the routing table below.
- **PNG-first raster, Recraft-for-SVG.** All raster brand assets are PNGs
  (typically 1024×1024). Native SVG only comes from Recraft V3 and must be
  hand-cleaned (Recraft emits ~160 anchors/letter; target ≤8). Never
  hand-code SVG paths or have LLMs emit SVG path data directly.
- **Palette snap is mandatory** for every raster route
  (`scripts/image-gen/palette_snap.py`). Both gpt-image-1 and fal.ai
  models drift without it. The only exception is the `VECTOR_LOGO`
  route (SVG output).
- **Never regenerate existing canonical assets.** Use existing files for
  compositing:
  - Play Owl icon: `foculoombrand/assets/branding/foculoom-icon.png` (1024×1024)
  - Bloom Play Bold font: `foculoombrand/assets/fonts/bloom-play/BloomPlay-Bold.ttf`
- **Palette compliance** — Fizzy Rainbow v2.0 only. See `brand-kit.md`.
  The snap step enforces this automatically.

## ⛔ Pre-Plan-Approval Gate — REVIEWER Art Direction Pass (mandatory — ALL AGENTS, no exceptions)

**Added 2026-05-27 (5-whys foculoom/foculoom-project#1456).**

> This gate fires **before plan approval** for ANY visual asset spec (icons, OG images, social cards, mascots, banners). It is a HARD STOP — not a reminder.

**Rule:** Before submitting a plan for approval (calling `exit_plan_mode`) on any visual asset task, ALL of the following must be true:

| Check | Required evidence |
|---|---|
| REVIEWER art direction pass requested | A `task(agent_type="reviewer", ...)` call with art direction brief included |
| REVIEWER returned explicit Domain 2 + Domain 3 verdict | PASS or FAIL verdict visible in this session |
| Verdict is PASS | If FAIL, revise the brief and re-run before proceeding |

**How to comply:**

```
1. Draft the art direction brief (style, palette, mood, reference assets).
2. Run: task(agent_type="reviewer", prompt="Art direction pass: [brief]")
3. Wait for verdict with explicit PASS/FAIL on Domain 2 (visual quality) and Domain 3 (brand identity).
4. If PASS → proceed to plan approval (exit_plan_mode).
5. If FAIL → revise brief → re-run REVIEWER → loop until PASS.
```

**CONDUCTOR:** Include this gate in every BUILDER spawn prompt for brand asset PRs. The Pre-BUILDER Source Compliance Check (§Step 2 below) also references it, but that check is too late — run art direction BEFORE plan approval, not BEFORE BUILDER dispatch.

**Non-CONDUCTOR (solo BUILDER/PLANNER):** This gate applies equally. The absence of CONDUCTOR orchestration does not exempt any session from this requirement. Memories alone are insufficient enforcement — this skill file is the canonical source of truth.

---

## Pre-PR Asset Scope Filter (mandatory — BUILDER and REVIEWER, no exceptions)

**Every file included in a brand asset PR must pass ALL four filters. One FAIL = remove from PR scope immediately.**

| Filter | PASS | FAIL → action |
|---|---|---|
| **Archive check** | File path does NOT contain `archive/` anywhere | Contains `archive/` → remove from PR, do not update |
| **Product status** | File is for Foculoom parent brand OR a confirmed active product | File is for a deprecated, dormant, or discontinued product → remove from PR |
| **Refresh scope** | File was newly generated as part of the current brand refresh (lives in `website/` or was produced by the brand refresh pipeline) | File predates the brand refresh OR is in `web/` (legacy PWA icons — pre-refresh owl design) → remove from PR |
| **Design identity** | For icon files: center pixel matches the canonical brand-refresh reference (see below). For OG/wordmark images: confirms current wordmark colors. | Center pixel diverges from canonical reference by mean diff > 10 → file is the wrong design generation → remove from PR |

**Design identity check (mandatory for all icon-format files — 16px, 32px, 192px, 512px, 1024px):**
```python
from PIL import Image
import numpy as np
# Canonical brand-refresh reference: foculoom-app-icon-v2.png (F letterform on Void bg)
# center pixel = (43, 50, 144) = Threadways Spectrum indigo
# top-left 10×10 avg ≈ (13, 11, 26) = Void background
ref = Image.open('foculoombrand/assets/branding/foculoom-app-icon-v2.png').convert('RGB').resize((512,512))
candidate = Image.open(path).convert('RGB').resize((512,512))
diff = np.abs(np.array(ref, dtype=float) - np.array(candidate, dtype=float)).mean()
# diff > 10 → different design generation → FAIL scope filter
assert diff <= 10, f"Design identity FAIL: mean diff={diff:.1f} — file is not the brand-refresh icon design"
```
A mean diff > 10 vs `foculoom-app-icon-v2.png` indicates the file is a different design (e.g., old owl mascot, diff ≈ 78). Such files must NOT be included in a brand refresh PR — they require full regeneration in a separate PWA/icon refresh issue.

**Known failing assets (do not include in brand refresh PRs):**
- `assets/branding/web/icon-512.png` — owl design, mean diff ≈ 78 (5-whys 2026-05-24, foculoom/foculoom-project#1358)
- `assets/branding/web/icon-192.png` — owl design, mean diff ≈ 78
- `assets/branding/web/apple-touch-icon.png` — owl design, mean diff ≈ 78
- Any file in `assets/branding/web/` — this folder contains pre-refresh PWA icons; treat all as legacy until explicitly regenerated via a PWA icon refresh issue

**How to determine product status:** Check `assets/branding/<product>/marketing/product.json`. If the declared palette does not match the Foculoom brand refresh palette, treat the product as deprecated and exclude its assets. When in doubt, ask founder — do not assume active.

**How to apply:** BUILDER must run this filter for every file before staging. CONDUCTOR must include this filter table in every BUILDER and REVIEWER spawn prompt for brand asset PRs.

---

## Pre-BUILDER Character Reference Check (mandatory — CONDUCTOR and BUILDER)

**Added 2026-05-28 (5-whys foculoom/foculoom-project#1332):** When a BUILDER deliverable involves **character artwork, visual reference SVGs, or CSS/SVG character art**, CONDUCTOR must run this check BEFORE dispatch. Absent this check, a BUILDER will create character art from scratch that contradicts approved designs — introducing rework.

### Step 0A — Check for approved character references
```bash
ls foculoombrand/assets/generated/sprites/<character-name>/
# Look for files ending in *_approved_reference.png
# If ANY exist → they MUST be included in the BUILDER prompt as required visual anchors
```

**If approved references exist:**
- Include the full path(s) in the BUILDER prompt explicitly: `"Visual reference: foculoombrand/assets/generated/sprites/diffrek/run_02_approved_reference.png — your visual work MUST be anchored to this design"`
- Hand-authored visual work from lore bible text alone is NOT sufficient when approved sprites exist
- The approved sprite is the canonical visual authority, not the lore bible color/anatomy table

**If no approved references exist:** proceed with lore bible text as the visual spec.

**Scope:** fires for any issue where BUILDER creates a visual reference file, character illustration, CSS character art, or SVG anatomy diagram. It does NOT require that the issue be an asset-copy operation.

### Generation method rule (mandatory — added 2026-05-28, 5-whys foculoom/foculoom-project#1332 comment 4565303284)

Visual reference documents (`docs/*-visual-reference.*`, character anatomy sheets, CSS art guides) are **brand assets** — they must be generated via rendit, not hand-authored.

- **CONDUCTOR dispatch rule:** when BUILDER scope includes a visual reference document OR CSS character art, the dispatch prompt MUST specify `rendit generate_character_figure()` (or the relevant rendit API surface) as the generation method. Specifying Pillow pixel analysis, hand-authored SVG, or any non-rendit method is a policy violation.
- **Constraint:** `generate_character_figure(reference_image_url=...)` requires an HTTP/HTTPS URL. For approved sprites in the private foculoombrand repo, obtain an authenticated URL via `gh api /repos/foculoom/foculoombrand/contents/<path> --jq .download_url` before calling rendit.
- **If rendit cannot produce the required asset:** file a rendit capability request (`[rendit] capability request` issue label) and defer — do NOT bypass with hand-authored SVG or any other tool.

---

## Pre-BUILDER Source Compliance Check (mandatory — CONDUCTOR and BUILDER)

**Added 2026-05-27 (5-whys foculoom/foculoom-project#1456):** Before any BUILDER deploys a foculoombrand asset, CONDUCTOR must confirm ALL THREE of the following. Absent any check, block dispatch and route to REVIEWER.

### Step 1 — Pull foculoombrand to HEAD
```bash
git -C /path/to/foculoombrand pull --ff-only origin main
# If diverged: stop, surface to founder. Do NOT use stale local files.
```

### Step 2 — Verify art direction gate was cleared
Search the source PR and its tracking issue for a REVIEWER PASS comment:
```bash
gh pr view <foculoombrand-PR-number> --repo foculoom/foculoombrand --json comments \
  --jq '.comments[].body' | grep -i "VERDICT.*PASS\|art direction.*PASS\|approved"
# Zero matches → gate NOT cleared → block BUILDER dispatch, run REVIEWER art direction pass first
```

### Step 3 — Identify the correct source file version
If a PR added versioned files (e.g., `orqit-icon-v2.png`), BUILDER must copy from the **versioned file**, not the legacy unversioned file (`orqit-icon.png`).
```bash
# Check what's in the source directory
ls foculoombrand/assets/products/<product>/
# If both orqit-icon.png AND orqit-icon-v2.png exist, use orqit-icon-v2.png (the PR-added version).
```

**Failure of any step = BUILDER dispatch blocked.** Surface finding to founder.

---

## REVIEWER Visual Inspection — Pixel-Grounded (mandatory)

Qualitative visual descriptions are **not sufficient**. REVIEWER hallucinating "teal owl mascot" for an F-letterform icon is a known failure mode (5-whys, 2026-05-24, foculoom/foculoom-project#1358).

**For every modified PNG in a brand asset PR, REVIEWER must:**

1. **Sample at least one pixel** using Pillow — description must be anchored to pixel evidence:
   ```python
   from PIL import Image
   img = Image.open(path)
   cx, cy = img.size[0]//2, img.size[1]//2
   print(img.convert('RGB').getpixel((cx, cy)))  # center pixel
   ```
   A description with no pixel sample is non-compliant and will be rejected.

2. **Explicitly state per file:**
   - What the image actually shows (based on pixel sampling + view)
   - Which product it belongs to (Foculoom parent or named product)
   - Whether that product is active or deprecated (per product.json)
   - Whether the path contains `archive/`

3. **Apply the scope filter verdict per file:**
   - Archive path → REVISE (remove file from PR)
   - Deprecated product → REVISE (remove file from PR)
   - Both PASS → proceed

**A SHIP verdict is only valid if every file explicitly passed the scope filter with evidence.**

---

## Router — source of truth

**Tier 1 (rendit — deterministic, preferred):**

| Asset type | Element types needed | rendit support | Action |
|---|---|---|---|
| `FLAT_ICON`, `BADGE` (geometric/typographic) | rect, text, circle, ellipse | ✅ v0.1 / v0.1.x | Write recipe YAML |
| `POSTER_TEXT`, `OG_IMAGE` (text-dominant) | rect, text | ✅ v0.1 | Write recipe YAML |
| Any asset needing curves, organic shapes | path, group | ⏳ v0.2 (#1295) | Extend rendit first |

**Tier 2 (stochastic fallback — requires founder approval comment on tracking issue):**

`scripts/image-gen/backend.py` encodes this table; edit the code, then
reflect here. A/B evidence is under
`scripts/image-gen/validation/` (see that README for receipts).

| Asset type | Palette / gate | Backend | Model | Post-process |
|---|---|---|---|---|
| `FLAT_ICON`, `BADGE`, `EDIT_EXISTING` | brand palette | fal.ai | Flux Kontext Max | `palette_snap` (+ `alpha_recover` if transparent needed) |
| `FLAT_ICON`, `BADGE` | `pure_primary` (Lime/Sunny/Sky) | OpenAI | `gpt-image-1` high | `palette_snap` |
| any | `alpha_required=True` | OpenAI | `gpt-image-1` high | `palette_snap` |
| `MASCOT_HERO` | brand / photo | fal.ai | Seedream 4 | `palette_snap` |
| `POSTER_TEXT`, `OG_IMAGE` | any | **OpenAI** | `gpt-image-1` high | `palette_snap` |
| `VECTOR_LOGO` | any | fal.ai | Recraft V3 (SVG) | manual anchor cleanup |
| any | `draft=True` | fal.ai | SDXL (fastest/cheapest) | `palette_snap` |

Route flipped from Ideogram V3 → gpt-image-1 for text-in-image after
the 2026-04-18 A/B (results/ideogram_vs_gptimage_og/): Ideogram misspelled
the FOCULOOM wordmark; gpt-image-1 rendered it correctly. See
`scripts/image-gen/validation/README.md`.

## MASCOT_HERO generation guidance

### Canvas margin rule (mandatory for all MASCOT_HERO generations)

Character art generated for hero/mascot use must leave compositing headroom. A character
that fills the canvas edge-to-edge cannot be composited without cropping or halos.

**Prompt requirement — include in every MASCOT_HERO generation prompt:**
> "Character body should occupy no more than 70% of image width.
> Leave at least 15% transparent margin on all four sides of the character.
> Do not fill the canvas edge-to-edge."

**BUILDER self-check gate:** after generation, measure the character bounding box:

    import numpy as np
    from PIL import Image
    arr = np.array(Image.open(path).convert("RGBA"))
    alpha = arr[:, :, 3]
    cols_any = np.any(alpha > 128, axis=0)
    left = int(np.argmax(cols_any))
    right = w - int(np.argmax(cols_any[::-1]))
    char_pct = 100 * (right - left) / w
    assert 65 <= char_pct <= 82, f"Character width {char_pct:.1f}% outside 65-82% spec range"

If this assertion fails, add the explicit margin phrase above to the prompt and regenerate — do not scale down as the primary fix (scale-down is a last resort that degrades edge quality).

### Assertion thresholds for MASCOT_HERO (1024×1024 canvas)

| Assertion | Threshold | Notes |
|---|---|---|
| Dimensions | exactly 1024×1024 | Per AC |
| Mode | RGBA | alpha_required=True route |
| Transparent corners | alpha == 0 in all four 10×10 corners | Background fill catch |
| Character width | 65–82% of canvas | 70% target, ±7pp tolerance |
| Fill coverage | 30–65% opaque pixels | 72% canvas char ≈ 38% fill; ≥50% incorrectly assumes full-canvas character |

### Spec file required

Every MASCOT_HERO generation must have a companion spec file in `specs/` committed
alongside the asset PR. The spec must document:
- Asset type and canvas dimensions
- Color spec with Fizzy Rainbow palette deviation rationale (if any)
- Generation prompt (exact text used)
- Post-processing steps
- Assertion thresholds with expected values
- REVIEWER sign-off checklist (enumerated, not vague)

**Rationale:** Without a committed spec, each generation must re-derive prompt guidance
from scratch, causing regressions (5-whys #1052, 2026-05-14).

## Costs

- fal.ai Flux Kontext Max: ~$0.08/image
- fal.ai Seedream 4: ~$0.03–0.04/image
- fal.ai Ideogram V3: ~$0.05/image
- fal.ai Recraft V3: ~$0.05/image
- fal.ai SDXL (drafts): ~$0.003/image
- OpenAI gpt-image-1 low/medium/high: $0.011 / $0.042 / $0.167

## Calling the router from Python

```python
from scripts.image_gen.backend import (
    AssetType, Request, route, FLUX_BRAND_NEGATIVES,
)
from scripts.image_gen.palette_snap import snap
from scripts.image_gen.alpha_recover import recover, MARSHMALLOW
from scripts.image_gen.clients.fal_client import text_to_image
from scripts.image_gen.clients.openai_client import create_image

r = route(Request(AssetType.FLAT_ICON))   # → Flux Kontext Max route
# ... call the backend indicated by r.backend with r.model, appending
#     r.negative_prompt to your prompt if non-empty, then run snap()
#     and (if needed) recover() on the output.
```

The Python package on disk lives at `scripts/image-gen/` (dashes); import
via a `sys.path.insert` hop — see any validation script for the pattern.

## OG image compositing (Pillow)

### Text safe-zone rule — mandatory for all OG image generation

Text content (wordmarks, product names, taglines) embedded in OG images
**must** stay within a safe zone. Truncation at any edge is a hard failure.

**Prompt requirement:** include explicit margin language in every OG image
generation prompt, e.g.:
> "All text and characters must be entirely within a safe zone: minimum 8%
> of image width/height from all four edges. The first letter of any wordmark
> must have at least 10% of image width of clear space to its left."

**Crop-math check (before committing):** when downsampling a generated image
(e.g. 1536×1024 → 1200×630 via scale-to-height + center-crop), verify:
1. Compute the horizontal crop offset: `left = (new_w - 1200) // 2`.
2. Confirm all text bounding boxes clear both crop boundaries by ≥ 120 px
   (10% of 1200 px) on each side.
3. If visual preview is unavailable, your commit message must state:
   "Wordmark first letter is fully visible with N px of clear space to its left."

**BUILDER self-check gate:** before staging the image, explicitly state whether
every character in the wordmark is unclipped and clear of the frame. Any doubt
→ regenerate, don't commit.

**Zero-risk fallback:** generate without embedded text. The `og:title` and
`og:description` meta tags carry the brand name — text-free images cannot be
truncated by cropping.

---

For OG images that combine Play Owl + wordmark + background, generate
either:
1. the full composition via the router
   (`AssetType.OG_IMAGE` → gpt-image-1 high), or
2. the background/panel via the router and composite canonical assets
   on top with Pillow (preferred when the Play Owl icon must appear
   exactly as shipped):

```python
from PIL import Image, ImageFont, ImageDraw

# Load canonical assets — never regenerate these
icon = Image.open('foculoombrand/assets/branding/foculoom-icon.png')
font = ImageFont.truetype(
    'foculoombrand/assets/fonts/bloom-play/BloomPlay-Bold.ttf', size=72,
)
canvas = Image.new('RGB', (1200, 630), '#FFF8F0')  # Marshmallow
canvas.paste(icon.resize((200, 200)), (50, 215), icon.resize((200, 200)))
draw = ImageDraw.Draw(canvas)
draw.text((280, 260), 'FOCULOOM', font=font, fill='#2B2F86')
```

## Asset manifest

Consumer asset manifest: `foculoombrand/assets/branding/consumer-asset-manifest.json`
- Maps source files to destination exports
- Format: `{id, appearance, source_relative_path, destination_relative_path, width}`
- `render_mode="copy"` for non-raster passthrough (SVG, ICO)
- `sync_reference_assets.py` uses macOS `sips` for PNG rendering

## SVG rules

- Native SVG only from Recraft V3 (`VECTOR_LOGO` route).
- Recraft output has high anchor density — manual cleanup required.
- Target: ≤8 anchor points per letter in a wordmark.
- Never have LLMs emit SVG path `d` data directly — produces
  "computer-generated" look.

## Wordmark construction

The FOCULOOM wordmark uses custom outlined vector paths (SVG `<path>`
elements), NOT text:
- FOCU = fill `#2B2F86`
- LOOM = fill `#4CD2CF`

## Font onboarding

When a new font needs to be added to the Foculoom brand:

1. **Verify license** — must be OFL 1.1 or equivalent permissive license
2. **Download from official source** — never from third-party CDNs
3. **Add to foculoombrand:**
   - Create directory: `foculoombrand/assets/fonts/<font-name>/`
   - Include: TTF, WOFF2, and license file (OFL.txt or LICENSE)
   - For variable fonts: include the variable WOFF2
   - For static fonts: include only the weights listed in brand-kit.md
4. **Update brand-kit.md** — add the font to the Typography table
5. **Update BRAND-MAP.md** — add the font directory to the foculoombrand section
6. **Update consumer-asset-manifest.json** — add font entries with `"type": "font"`
7. **PR to foculoombrand** — font onboarding is a brand change requiring founder review
8. **Only after merge** — products may consume the font from foculoombrand
