# TasItemBag "Inventory is full" Warning Options

## Context
Even with pickup-intent relief enabled, Warcraft III can still emit the native "Inventory is full" text/sound briefly during smart-pickup timing.

Goal: suppress false-positive warning feedback during assisted pickups, while preserving legitimate full-inventory feedback.

---

## Option A — Assisted Pickup Suppression Window (implemented)

### Idea
When pickup intent is armed **and** a relief page exists, open a very short local suppression window.
During that window, locally:
- clear UI text messages
- stop the default error sound (`gg_snd_Error`)

### Scope guard
Only active for assisted pickup attempts (not global).

### Pros
- Minimal invasive change.
- Keeps existing pickup flow and page-relief behavior.
- Easy to toggle/tune by duration.

### Cons
- Tiny chance of hiding other messages that happen in the same short window.
- Does not replace native engine behavior globally; it just mutes/clears locally during the window.

---

## Option B — Re-issue Pickup Order After Relief

### Idea
After switching to relief page, re-issue SMART on the target item to reduce timing race and native warning occurrence.

### Pros
- Can further improve consistency when engine timing is noisy.

### Cons
- More order churn.
- Potential interference with user micro/queued commands.

---

## Option C — Conditional Error Message Gate

### Idea
Add a shared gate in `ErrorMessage` or wrapper flow to ignore/suppress inventory-full feedback only when an assisted pickup flag is active.

### Pros
- Centralized handling.
- Easier to reason about than local ad-hoc clears.

### Cons
- Requires touching broader messaging path.
- Must avoid side effects on unrelated systems.

---

## Option D — Replace Default Sound + Play Custom Legit Sound (note)

### Idea
Replace/neutralize default error sound handling, then when a **legitimate full inventory** case is detected (example: first 12 `udg_P_Items` page slots are full), play an imported custom sound locally.

### Important note
This is best done with strict legitimacy checks to avoid false positives.
A practical check mentioned:
- all first 12 `udg_P_Items` slots for active page are occupied

Potential enhancement:
- also verify no merge space for stackables before playing the custom legit-full sound.

---

## Recommendation Path
1. Ship Option A first (low risk, local scope).
2. If warning still leaks in edge timing, test Option B selectively.
3. If broader consistency is needed, evaluate Option C.
4. Keep Option D as UX polish path once legit-full detection is finalized.
