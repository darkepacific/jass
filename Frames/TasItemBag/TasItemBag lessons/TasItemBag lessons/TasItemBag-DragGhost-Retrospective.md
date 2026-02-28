# TasItemBag Drag/Ghost Retrospective (Feb 2026)

## Why this doc exists
You decided to roll back to a safer checkpoint, but wanted a complete record of:
- what we attempted,
- what worked,
- what failed,
- and what to keep in mind if you revisit custom drag + ghost later.

This file is that reference.

---

## Original goal
Recreate WC3-like inventory UX while avoiding native drag lockups:
- Right-click inventory item while bag UI is open.
- Show a custom ghost icon following mouse.
- Next click should place into a bag slot (or drop to ground if clicked elsewhere).
- No hard lock/freeze/mouse capture issues.

Also: preserve existing page-based + extra-bag architecture (`udg_P_Items` stride model), without switching to Bannar’s system.

---

## Existing architecture constraints (important)
- Main file: `Frames/TasItemBag/TasItemBag.j`
- Data layout:
  - Page inventory slots first (12)
  - Extra bag slots after (`Cols * Rows` = 24)
  - Combined through `udg_BAG_SIZE` and index helpers
- Core indexing assumptions:
  - `BagSlotArrayIndex(playerKey, bagSlot)` maps bag slot -> `udg_P_Items` index
- Pickup pipeline:
  - `EVENT_PLAYER_UNIT_PICKUP_ITEM` delayed through timer and then bagged
- UI events:
  - Frame events + global mouse up/down/move + hover tracking

---

## What was changed during the session

### 1) UI positioning
- Bag panel position was moved toward center.
- This part is straightforward and low-risk.

### 2) Design exploration (non-code)
- Reviewed alternatives to pure `EVENT_PLAYER_UNIT_PICKUP_ITEM`.
- Discussed hybrid approach:
  - order-target intent (`EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER`) +
  - pickup confirmation (`EVENT_PLAYER_UNIT_PICKUP_ITEM`).
- Reviewed Bannar’s Inventory Event system and concluded:
  - useful event bus patterns,
  - but not required for your current architecture.

### 3) Custom drag implementation (major)
Added/iterated custom drag state in `TasItemBag.j`:
- Per-player drag state arrays (`DragActive`, `DragOriginType`, `DragOriginIndex`, etc.)
- Ghost frame array (`DragGhost[]`)
- Mouse handlers:
  - `GlobalMouseDownAction`
  - `GlobalMouseUpAction`
  - `GlobalMouseMoveAction`
- Drop handlers:
  - to bag slot,
  - to ground,
  - cancel-return behavior.

### 4) Freeze/input-lock fixes (multiple passes)
Several anti-freeze changes were attempted and mostly improved stability:
- disable/enable inventory origin buttons during drag,
- reset native inventory drag state,
- clear drag state safely on close/ESC/toggle,
- convert to explicit drag lifecycle,
- eventually remove source inventory item at drag-start and carry cached handle.

This removed the hard freeze issue.

### 5) Behavioral regressions encountered
After freeze fix, different regressions appeared at times:
- immediate ground drop,
- fallback auto-deposit feeling,
- custom ghost not visible despite drag logic active.

We alternated start timing between:
- mouse-down start + skip corresponding mouse-up, and
- mouse-up start (no skip),
trying to eliminate race/ordering conflicts.

### 6) Custom ghost visibility hardening
Attempted improvements for ghost visibility:
- dedicated ghost size/offset config,
- higher frame level,
- unified ghost move helper,
- non-interactive frame.

Despite this, ghost still did not visibly render for you in runtime testing.

---

## What appears to be true from testing

### Confirmed improvements
- Freeze/lockup behavior was resolved in later iterations.
- General drag transaction logic moved closer to intended behavior.

### Persistent unresolved issue
- Custom ghost icon did not visibly render near cursor in your environment.

This strongly suggests one of:
1. Frame draw/layer/context issue in this UI stack,
2. Local player/frame creation context mismatch at runtime,
3. Mouse event timing not driving visible updates as expected,
4. Another frame visually occluding ghost in your specific setup.

---

## Why this got tricky (key lesson)
WC3 UI inventory interactions are sensitive because three systems overlap:
1. Native item button behavior,
2. Custom frame event routing,
3. Global mouse event sequence.

If these are not strictly serialized, symptoms oscillate between:
- freeze/captured input,
- unintended immediate actions,
- invisible visual state.

---

## If you revisit this later (recommended clean approach)

### A) Keep the architecture, but rebuild drag in a small isolated branch
- Do NOT stack fixes on the older experimental version.
- Start from your stable rollback and reintroduce only minimal drag parts.

### B) Stage the implementation in strict phases
1. **Phase 1: transaction only, no ghost**
   - Right-click starts drag state and removes source item.
   - Next click commits to bag/ground.
   - Ensure 100% stable behavior first.
2. **Phase 2: debug-visible ghost placeholder**
   - Show a bright static BACKDROP texture (known visible icon) at fixed screen point.
   - Confirm it renders for local player before following cursor.
3. **Phase 3: cursor follow**
   - Move that proven-visible frame on mouse move.
4. **Phase 4: item icon texture swap**
   - Replace placeholder texture with item icon path.

### C) Keep native suppression minimal
- Disable native inventory buttons only while drag is active.
- Re-enable immediately on clear/cancel/commit.
- Avoid multiple redundant reset calls if not needed.

### D) Add temporary diagnostics (short-lived)
Log only these checkpoints:
- drag start (with slot + item type id),
- ghost show (frame handle/context),
- ghost move ticks,
- commit target resolution,
- drag clear reason.

Then remove debug spam once stable.

---

## Design decisions worth keeping
- Preserve `udg_P_Items` as single source of truth for bag storage.
- Keep `BagSlotArrayIndex(...)` + page/extra split convention.
- Keep withdraw/equip logic separated from drag-commit logic.
- Keep ESC/close/toggle hard-cancel behavior for any active drag.

---

## Practical takeaway
- You are not blocked on core bag architecture.
- The hard part was not inventory data—it was WC3 frame/mouse/native drag interaction.
- Rolling back now is a good decision.
- If revisited later, implement in phased, visibility-first steps with very small diffs.

---

## Suggested next-time checklist
- [ ] Stable baseline loaded (no experimental drag code)
- [ ] Phase 1 transaction-only drag passes
- [ ] Placeholder ghost frame is visible at fixed point
- [ ] Placeholder follows mouse
- [ ] Item icon texture swap works
- [ ] ESC/close/toggle cleanly return item and clear state
- [ ] No auto-drop/auto-deposit regressions

---

## Session summary in one line
We successfully removed the freeze and validated most transaction mechanics, but custom ghost rendering remained unreliable in your runtime, so rollback + documented learnings is the safest path.
