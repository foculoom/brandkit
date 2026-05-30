---
name: brand-compliance
description: Validate brand alignment for any Foculoom product surface. Run after visual changes to website, store listings, or product UI.
tier: two-pass
---

# Brand Compliance Check

## Model

- **Preferred:** `claude-sonnet-4.6` (default); escalate to `claude-opus-4.8` for Social Media Art-Director Review (§8) — qualitative judgment matches the `reviewer-qa-gate` Pass 2 standard
- **Cost-tier fallback:** `/model auto` → `claude-sonnet-4.5`; for Opus-escalation use `claude-sonnet-4.6 --effort xhigh` + mandatory rubber-duck — see `/fallback-mode` (foculoom/foculoom-project#463)
- **Source of truth:** Model Routing Matrix in `.github/skills/dev-session/SKILL.md`

Validates that a product surface (website, app, store listing) aligns with the canonical brand-kit.md v2.0 (Fizzy Rainbow / playful-first).

## Prerequisites

- Access to the target surface's CSS or style configuration
- Familiarity with [brand-kit.md](https://github.com/foculoom/foculoombrand/blob/master/docs/brand-kit.md)
- Familiarity with [BRAND-MAP.md](https://github.com/foculoom/foculoombrand/blob/master/BRAND-MAP.md)

## Checklist

### 1. Color Palette (Fizzy Rainbow)

- [ ] Light foundation Marshmallow `#FFF8F0` is used for page backgrounds
- [ ] Dark text Midnight `#2A2A3A` is used for body copy
- [ ] Brand anchor Deep Indigo `#2B2F86` is present
- [ ] Brand accent Fizzy Teal `#4CD2CF` is used for interactive highlights
- [ ] Bright accents (Sunny `#FFB800`, Coral Pop `#FF5580`, Lime Zap `#4ECB4E`, Sky Splash `#41B8FF`, Grape Fizz `#7C4DFF`) used for decorative fills, icons, buttons — paired with Midnight text labels
- [ ] Near-Black `#17181F` used only as dark-mode override or character-art outlines, NOT as default foundation
- [ ] No retired palette colors present (`#2D3436`, `#6C5CE7`, `#FDCB6E`, `#74B9FF`, `#F5F5F5`)
- [ ] No Tailwind defaults substituted for brand colors (`#14b8a6`, `#0c0a09`, `#0f766e`)
- [ ] WCAG 2.2 AA contrast met: 4.5:1 text, 3:1 UI elements
- [ ] Verified pairings: Midnight on Marshmallow (13.4:1), Deep Indigo on Marshmallow (10.8:1), Grape Fizz on Marshmallow (4.6:1)

### 2. Typography

- [ ] Display font Bloom Play Bold is loaded from foculoombrand canonical source
- [ ] Body/UI font Bloom Text is loaded from foculoombrand canonical source
- [ ] `font-display: swap` set on @font-face declarations
- [ ] Font files are self-hosted (no external CDN or Google Fonts dependencies)
- [ ] OFL.txt license file accompanies any font deployment

### 3. Logo & Mascot

- [ ] Mascot references Play Owl PNG (not old zen-owl or bloom/notch SVG)
- [ ] Logo wordmark is the two-tone SVG (FOCU indigo / LOOM teal)
- [ ] No bloom/notch or frontal-abstract symbols in use
- [ ] Play Owl uses correct colors: Teal body, Indigo details, Marshmallow belly, Near-Black outlines
- [ ] Clear space and minimum size rules respected

### 4. Naming Hierarchy (v1.1 — 5-carrier rule)

Every product surface must carry the Foculoom parent signal via **at least one** of the following five carriers. Two or more is recommended.

- [ ] **Carrier 1 — Suffix:** `ProductName by Foculoom` in the primary title or first H1 mention
- [ ] **Carrier 2 — Eyebrow/lockup:** eyebrow chip, section label, or standalone lockup reads "A Foculoom product" or names Foculoom
- [ ] **Carrier 3 — Footer lockup:** visible footer contains Foculoom wordmark or `© Foculoom LLC`
- [ ] **Carrier 4 — Platform field:** platform-provided developer/publisher field names Foculoom (App Store "Foculoom LLC", Steam Publisher)
- [ ] **Carrier 5 — Domain:** page hosted at `foculoom.com/<product>/` **and** shared nav carries the Foculoom parent mark

**Check: at least 1 carrier must be present.** Zero carriers = ❌ Critical failure.

Additional naming checks:

- [ ] "DBA Foculoom" and "d/b/a Foculoom" are not mixed on the same page
- [ ] Legal entity "Foculoom LLC" appears in footer or legal sections (not just a carrier; required for legal surfaces)
- [ ] Meta `<title>`, og:title, twitter:title, and JSON-LD `name` retain the suffix form for SEO/share-card clarity (even when the page H1 uses a shorter form)
- [ ] App Store/Steam URL slugs (e.g., `/app/veilsort-by-foculoom/`) are not modified — these match live listing identities

### 4a. Naming Hierarchy — Test Examples

**✅ Pass examples (one carrier present):**

| Surface | Carrier used | Notes |
|---------|-------------|-------|
| Veilsort product page — eyebrow "A Foculoom product" + H1 "Veilsort" | Carrier 2 | Suffix dropped from H1; eyebrow carries the signal |
| Skiplet iOS App Store listing — developer field "Foculoom LLC" | Carrier 4 | Platform field alone satisfies rule |
| foculoom.com/veilsort/ — Foculoom mark in site nav | Carrier 5 | Domain + nav together satisfy Carrier 5 |
| README — H1 "Veilsort" + "A Foculoom product." byline in body | Carrier 2 | Byline acts as lockup carrier |

**❌ Fail example (zero carriers — Critical):**

| Surface | Carrier count | Finding |
|---------|--------------|---------|
| Hypothetical page: H1 "Veilsort", no eyebrow, no footer, external domain, no platform field | 0 | ❌ Critical — no parent signal; naming rule violated |

### 5. Trust Claims

- [ ] Any claim on the surface maps to a TC-XXX code in trust-claims-table.md
- [ ] Claims at the correct evidence tier (aspiration, directional, or proven)
- [ ] No unregistered claims published
- [ ] "All play, no tricks" is marketing framing only — NOT presented as a trust claim

### 6. Tone of Voice

- [ ] Default public-facing tone is Playful & Energetic
- [ ] Privacy, legal, support sections use Calm & Structured register
- [ ] No calm-first language in product/marketing copy (v1 residue)

### 7. Browser Chrome

- [ ] `<meta name="theme-color">` uses brand-appropriate color (Marshmallow `#FFF8F0` for light-mode, or Midnight `#2A2A3A` for dark)
- [ ] `site.webmanifest` background_color and theme_color are consistent

### 8. Social Media Assets

Run this section for any social post, release announcement image, story, or OG card associated with this product surface.

The reviewer for this section operates as a seasoned art director — someone who has won Apple Design Awards and has an immediate sense of when a post looks like it belongs alongside the apps that make the Editors' Choice list versus an afterthought. Feedback must be direct and cite specific public work that solved the same challenge well.

**Citation standard:** every qualitative finding must reference a public example. Acceptable: named ADA winners, well-documented App Store campaigns, or specific product releases with known visual direction (e.g., Alto's Odyssey launch assets, Monument Valley 2 press kit, Sayonara Wild Hearts Apple Arcade reveal).

- [ ] **Product name correct:** Asset filename, caption copy, and any in-image text name the correct product — no cross-product contamination (e.g., "Skiplet" copy in a Jumpyloo post)
- [ ] **Character / mascot correct:** The right product character or mascot is shown; no sibling-product sprite bleed
- [ ] **Color palette:** Matches the product's specific palette (not just the generic Foculoom palette unless this is a Foculoom-brand post)
- [ ] **No placeholder copy:** No "TBD", "Lorem", "CHANGE ME", "Headline here", or draft watermarks visible in the final export
- [ ] **OG / share card parity:** `og:image` on the website matches the intended social card — no stale card from a prior release
- [ ] **Dimensions correct per platform:**

  | Platform | Required size | Notes |
  |---|---|---|
  | Twitter / X post image | 1200×675 | 16:9 |
  | Instagram square post | 1080×1080 | 1:1 |
  | Instagram story | 1080×1920 | 9:16 |
  | App Store release hero | 1320×2868 | 6.9" portrait |
  | OG share card (web) | 1200×630 | Standard |

- [ ] **`release-asset-fanout` manifest up to date:** `foculoombrand/assets/release/<product>/<version>/manifest.json` exists and lists all slots (run `/release-asset-fanout` if missing)
- [ ] **Alt-text / caption:** Image alt-text and any caption draft refer to the correct product and reflect the current version messaging

**Qualitative review (required — not optional):** After checking the boxes, the reviewer must provide a brief opinionated assessment of the overall visual quality of the social asset with at least one citation:

```
Social Asset Qualitative Review:
Overall: APPROVED / REVISE / REJECT
Assessment: <direct opinion with citation>
  Example: "The launch card reads like a generic stock photo with our logo
  dropped on top. Compare to the Monument Valley 2 App Store reveal — every
  crop and color choice in that campaign was deliberate and unique to that
  world. This asset has no visual signature. Revise: the hero image should
  feature the actual gameplay moment we're proudest of, not a mock device."
```

## Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| 🔴 Critical | Retired colors, wrong mascot, broken contrast, stale v1 tone, **zero naming carriers** | Block merge |
| 🟡 Warning | Missing palette colors, font not loaded, stale theme-color, **only one carrier (recommend ≥2)** | Fix before next release |
| 🟢 Info | Minor spacing, optional accent missing | Note for future |

## Output

Produce a table:

| Check | Status | Notes |
|-------|--------|-------|
| Color palette | ✅/⚠️/❌ | Details |
| Typography | ✅/⚠️/❌ | Details |
| Naming carriers (count N/5 present) | ✅/⚠️/❌ | List carriers found |
| ... | ... | ... |

End with a **Pass / Conditional Pass / Fail** recommendation.
