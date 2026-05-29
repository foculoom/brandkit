---
name: a11y-godot
description: Godot 4.6 iOS accessibility checklist for Foculoom kids products. VoiceOver, Reduce Motion, Dynamic Type, focus order, color contrast, and caption hooks.
tier: basic
---

> ⚠️ **OUTLINE — full skill blocked on foculoom/foculoom-project#947 (SPIKE-A11Y) and the open VoiceOver/Reduce-Motion shim spike.** Every GDScript API reference below is a placeholder annotated `<!-- TBD-SPIKE-A11Y -->`. Do not treat this skill as actionable until the spike closes and this file is finalized.

# Accessibility — Godot 4.6 iOS (a11y-godot)

## Status

**OUTLINE** — finalization blocked on:
- `foculoom/foculoom-project#947` (SPIKE-A11Y: Godot 4.6 iOS VoiceOver API surface investigation)
- Open VoiceOver/Reduce-Motion shim spike (tracked in `prs/spike-a11y.md`)

Every GDScript API reference in this file is annotated `<!-- TBD-SPIKE-A11Y -->` and must be replaced with verified API calls after the spike closes. Do not ship a feature with this skill as sole a11y evidence until this file is updated.

**Target finalization:** After both spikes above close. Owner: BUILDER post-spike, with REVIEWER sign-off.

## Model

- **Preferred:** `claude-haiku-4.5` (while in OUTLINE — placeholder checklist; minimal judgment required pending #947 SPIKE-A11Y)
- **Post-#947 preferred:** `claude-sonnet-4.6` — upgrade after SPIKE-A11Y closes and real GDScript API calls replace `<!-- TBD-SPIKE-A11Y -->` placeholders
- **Cost-tier fallback:** `claude-haiku-4.5` (already cheap while OUTLINE); `/model auto` → `claude-sonnet-4.5` post-#947
- **Source of truth:** Model Routing Matrix in `.github/skills/dev-session/SKILL.md`

## When to use

Run this skill when:
- A new screen, scene, or interactive UI element is added to Jumpyloo or any Godot 4.6 iOS kids product
- An existing screen undergoes layout changes (node tree restructure, animation changes, control reordering)
- `reviewer-qa-gate` item 8 triggers: "Run a11y-godot skill if product = Jumpyloo"
- A new animation, sound cue, or transition is introduced that may need Reduce Motion gating

## Checklist

> ⚠️ All GDScript API references below are **TBD placeholders**. Verify against actual Godot 4.6 iOS build after SPIKE-A11Y closes.

### 1. VoiceOver labels on Control nodes <!-- TBD-SPIKE-A11Y -->

- [ ] Every interactive `Control` node (Button, TextureButton, Slider, CheckBox) has a non-empty accessibility label set via `<!-- TBD-SPIKE-A11Y: accessibility_name property or equivalent -->` 
- [ ] Labels are descriptive (e.g., "Play level 3" not "Button")
- [ ] Dynamic labels (score displays, progress bars) update their accessibility label when the underlying value changes
- [ ] Decorative nodes that should be skipped by VoiceOver are marked with `<!-- TBD-SPIKE-A11Y: focus_mode = FOCUS_NONE equivalent -->`

### 2. Focus order <!-- TBD-SPIKE-A11Y -->

- [ ] Focus traversal order matches the visual reading order (top-to-bottom, left-to-right for LTR locales)
- [ ] Focus does not escape to off-screen nodes or invisible layers
- [ ] Modal dialogs trap focus within the dialog until dismissed
- [ ] Custom focus order is set via `<!-- TBD-SPIKE-A11Y: focus_neighbor_* properties or equivalent -->` where automatic order is incorrect

### 3. Reduce Motion gating for AnimationPlayer and Tween <!-- TBD-SPIKE-A11Y -->

- [ ] `AnimationPlayer` nodes check for Reduce Motion preference via `<!-- TBD-SPIKE-A11Y: DisplayServer.is_reduce_motion_enabled() or equivalent -->` before playing non-essential animations
- [ ] `Tween` objects for parallax, idle animations, and screen transitions respect Reduce Motion
- [ ] Essential animations (gameplay feedback, level completion) are preserved at reduced scale/duration when Reduce Motion is on
- [ ] Screen transitions fall back to a simple cut or minimal crossfade under Reduce Motion

### 4. Dynamic Type / font-scale <!-- TBD-SPIKE-A11Y -->

- [ ] All UI text uses theme-driven font sizes (not hardcoded pixel values) that respond to iOS Dynamic Type
- [ ] Text containers expand gracefully at large and extra-large text sizes (no clipping, no overflow)
- [ ] Primary game UI tested at XXXL Dynamic Type (matches `reviewer-qa-gate` item 6)
- [ ] Minimum legible font size is 11pt equivalent at default text size

### 5. Color contrast <!-- TBD-SPIKE-A11Y -->

- [ ] Primary text on background meets WCAG AA contrast ratio (4.5:1 minimum)
- [ ] Interactive UI elements (buttons, sliders) meet 3:1 minimum contrast against adjacent non-interactive areas
- [ ] Color is not the **sole** means of conveying information (error states, status indicators also use shape or text)
- [ ] Tested with Increase Contrast system setting on (matches `reviewer-qa-gate` item 8)

### 6. Hit-area minimum <!-- TBD-SPIKE-A11Y -->

- [ ] All interactive `Control` nodes have a minimum touch target of 44×44 points (matches `reviewer-qa-gate` item 13 — kids product gate)
- [ ] Hit areas verified on SE-class device (smallest screen in the test matrix)
- [ ] Invisible hit-area extensions used where visual element is smaller than 44×44pt

### 7. Captioning hooks for audio cues <!-- TBD-SPIKE-A11Y -->

- [ ] Every meaningful audio cue (level complete, error, collectible pickup) has a visual or haptic equivalent
- [ ] Dialogue or narration audio provides a text caption or subtitle option
- [ ] Caption/subtitle toggle is accessible via Accessibility settings or in-app settings
- [ ] ElevenLabs TTS narration is paired with on-screen text (required for kids-warm / kids-clear preset output)

## Integration

This skill is invoked from `reviewer-qa-gate` after item 8 when `product == jumpyloo` (or any kids product).

### Invocation point in reviewer-qa-gate

```
8. Increase Contrast: primary CTAs remain legible
   > If product = Jumpyloo (or any kids product), run the a11y-godot skill before continuing.
```

### Example invocation

```
/a11y-godot

Product: Jumpyloo
Scene: LevelSelectScreen.tscn
Change: Added 12 new level buttons in a GridContainer. Each button shows a star rating and a lock icon when the level is not yet unlocked.
Build: 2.1.0 (TestFlight 42)
Device: iPhone SE (3rd gen, iOS 18.4)
```

**Expected output skeleton (post-SPIKE-A11Y finalization):**

```
## a11y-godot checklist — Jumpyloo LevelSelectScreen (build 42)

### VoiceOver labels <!-- TBD-SPIKE-A11Y: verify API -->
[ ] ...

### Focus order <!-- TBD-SPIKE-A11Y -->
[ ] ...

### Reduce Motion
[ ] ...

### Color contrast
[ ] ...

### Hit areas
[ ] All 12 level buttons: 44×44pt minimum ← verify on SE

### Verdict
TBD pending SPIKE-A11Y resolution
```

> ⚠️ **Reminder:** This file is an OUTLINE. Do not file a passing verdict from this skill until the SPIKE-A11Y placeholders are replaced with verified API calls. See `## Status` above.

## Anti-patterns

- Using this skill as sole a11y evidence before SPIKE-A11Y closes (the GDScript API references are unverified)
- Running this skill on non-Godot surfaces (use platform-native a11y tools for web or native Swift/UIKit)
- Skipping VoiceOver label verification because "it's a kids game" (WCAG and KOSA both apply)
- Treating color contrast as optional (required for KOSA harmful-content mitigation and Apple App Store kids-category approval)
