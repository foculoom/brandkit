---
name: release-asset-fanout
description: Generate canonical release asset slots (App Store screenshot frame, social-share preview, release-post hero, square card) from a founder-supplied hero PNG. Writes output PNGs and a manifest.json to foculoombrand/assets/release/{product}/{version}/.
tier: basic
---

# Release Asset Fanout

## Model

- **Preferred:** `claude-haiku-4.5` — pure Python script orchestration (Pillow resize + manifest JSON write); zero judgment required
- **Cost-tier fallback:** `claude-haiku-4.5` (already cheap) — see `/fallback-mode` (foculoom/foculoom-project#463)
- **Source of truth:** Model Routing Matrix in `.github/skills/dev-session/SKILL.md`

## When to use

Invoke this skill whenever a new product version is being prepared for release and canonical-dimension assets are needed for:

- App Store screenshot frames (6.7" iPhone and optionally iPad 12.9")
- Social-share preview images
- Release-post hero images (used by the `release-post` skill)
- Square card assets (social, press kit)

**Do not invoke** this skill to generate the source hero image. Source hero creation is out of scope — the founder supplies the hero PNG. Use `brand-asset-pipeline` for generating or compositing brand assets.

## Prerequisites

- Pillow (`pip install Pillow`) installed in the Python environment
- The source hero PNG must be ≥ 1600 px wide and in PNG format
- `foculoombrand` repo path available via `FOCULOOMBRAND_PATH` (recommended)
  or present at a local default path you control

## Asset Slots

| Slot name | Dimensions | Notes |
|---|---|---|
| `iphone-screenshot` | 1290 × 2796 | 6.7" iPhone App Store frame |
| `social-preview` | 1200 × 630 | Open Graph / social share |
| `release-hero` | 1600 × 900 | Release-post hero (wired to `release-post` skill) |
| `square-card` | 1080 × 1080 | Social card, press kit; also emitted as JPEG sibling |
| `instagram-portrait` | 1080 × 1350 | Instagram feed (4:5); also emitted as JPEG sibling; use `--portrait-hero` for best results |
| `instagram-stories` | 1080 × 1920 | Instagram Stories (9:16); PNG only |
| `ipad-screenshot` | 2048 × 2732 | iPad 12.9" (docketloom only) |

## Output Layout

```
foculoombrand/assets/release/{product}/{version}/
├── {product}-{version}-iphone-screenshot.png
├── {product}-{version}-social-preview.png
├── {product}-{version}-release-hero.png
├── {product}-{version}-square-card.png
├── {product}-{version}-square-card.jpg          ← JPEG sibling (quality 92, sRGB ICC)
├── {product}-{version}-instagram-portrait.png
├── {product}-{version}-instagram-portrait.jpg   ← JPEG sibling (quality 92, sRGB ICC)
├── {product}-{version}-instagram-stories.png
└── manifest.json
```

`docketloom` releases also include `{product}-{version}-ipad-screenshot.png`.

## Brand Compliance Gate

The script runs a dominant-color check on each output image. It extracts the most common color (via Pillow quantize) and computes Euclidean RGB distance to every color in the Foculoom brand palette (parsed from `foculoombrand/docs/brand-kit.md`).

| Distance | Verdict | Behavior |
|---|---|---|
| ≤ 50 | `pass` | Continues normally |
| > 50 | `warn` | Logs warning, continues (unless `--block-on-compliance-fail`) |
| > 50 + flag | `fail` | Exits 1, no files written |

Use `--block-on-compliance-fail` in CI or any automated context where off-brand assets must be rejected before emit.

## Steps

### 1. Verify prerequisites

```bash
python3 -c "from PIL import Image, ImageOps; print('Pillow OK')"
: "${FOCULOOMBRAND_PATH:?Set FOCULOOMBRAND_PATH to your foculoombrand checkout}"
ls "$FOCULOOMBRAND_PATH/docs/brand-kit.md"
```

### 2. Run the fanout script

```bash
python3 scripts/release-asset-fanout/fanout.py \
    --product <skiplet|veilsort|vorynce|docketloom> \
    --version <M.N.P> \
    --hero /path/to/hero.png \
    [--portrait-hero /path/to/portrait-hero.png]
```

`--portrait-hero` should be a 4:5-composed PNG (≥1080 px wide) used as the source for the `instagram-portrait` slot. Without it, the 16:9 hero is center-cropped (brand compliance may warn).

Add `--block-on-compliance-fail` to reject non-brand-compliant sources:

```bash
python3 scripts/release-asset-fanout/fanout.py \
    --product skiplet \
    --version 1.2.0 \
    --hero /path/to/hero.png \
    --block-on-compliance-fail
```

Override the output directory (useful for local testing):

```bash
python3 scripts/release-asset-fanout/fanout.py \
    --product skiplet \
    --version 1.2.0 \
    --hero /path/to/hero.png \
    --out-dir /tmp/fanout-test
```

### 3. Verify output

```bash
# Check dimensions for each output file
python3 - <<'EOF'
from PIL import Image, os
version_dir = os.path.join(os.environ["FOCULOOMBRAND_PATH"], "assets/release/skiplet/1.2.0")
for f in sorted(os.listdir(version_dir)):
    if f.endswith(".png"):
        img = Image.open(os.path.join(version_dir, f))
        print(f"{f}: {img.size}")
EOF

# Validate manifest.json is well-formed
python3 -c "import json, os; p=os.path.join(os.environ['FOCULOOMBRAND_PATH'],'assets/release/skiplet/1.2.0/manifest.json'); d=json.load(open(p)); print('assets:', len(d['assets']))"
```

### 4. Wire release-post hero

The `release-post` skill can reference the emitted hero directly:

```bash
python3 scripts/release-post/generate_release_post.py \
    --input release.json \
    --product skiplet \
    --hero "$FOCULOOMBRAND_PATH/assets/release/skiplet/1.2.0/skiplet-1.2.0-release-hero.png" \
    --output /path/to/website/skiplet/releases/1.2.0.html
```

### 5. Commit assets to foculoombrand

Generated assets should be committed to the `foculoombrand` repo under `assets/release/`:

```bash
cd "$FOCULOOMBRAND_PATH"
git add assets/release/{product}/{version}/
git commit -m "feat(release): add {product} {version} release assets"
```

## Manual Flow (when script is unavailable)

If Pillow is not available and cannot be installed:

1. Resize the hero PNG to each slot dimension using your preferred image editor (Photoshop, Pixelmator, GIMP).
2. Use center-crop to match the target aspect ratio — do not stretch or letterbox.
3. Name outputs per the canonical pattern: `{product}-{version}-{slot}.png`.
4. Write `manifest.json` manually using the schema below.
5. Run a visual brand-compliance check: confirm the dominant color of each output is recognizably within the Fizzy Rainbow palette.

## manifest.json Schema

```json
{
  "product": "skiplet",
  "version": "1.2.0",
  "source_hero": "/absolute/path/to/hero.png",
  "source_hash": "<sha256-hex>",
  "generated_at": "2026-04-01T12:00:00Z",
  "assets": [
    {
      "slot": "iphone-screenshot",
      "dimensions": { "width": 1290, "height": 2796 },
      "filename": "skiplet-1.2.0-iphone-screenshot.png",
      "source_hash": "<sha256-hex>",
      "brand_compliance": "pass"
    }
  ]
}
```

## Known Limitations (v1)

- Brand compliance checks dominant color only (not full palette coverage or typography).
- No localized variants — single language only.
- No video or animated asset support.
- No Steam capsule support.
- No auto-upload to App Store Connect — use ASC tools for that after fanout.

## Handoff boundary

This skill produces local PNG files and a manifest. **Do not auto-commit or auto-push.** Founder reviews the outputs before the foculoombrand PR is opened.
