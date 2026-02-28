# TasItemBag Pickup Interception: Option A vs Option B

## Problem Summary
When a player right-clicks a ground item with a full 6-slot inventory, Warcraft III can emit the native **"Inventory is full"** error before our bag logic helps.

Goal: reduce that friction while preserving stable gameplay behavior.

---

## Option A — Pre-Pickup Inventory Relief (Engine-Friendly)

### Idea
Intercept the player’s item pickup intent before `EVENT_PLAYER_UNIT_PICKUP_ITEM`, free one inventory slot by depositing to bag, then let native pickup complete.

### Typical Hook
- `EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER`
- Conditions:
  - order is smart (`851971`)
  - target is an item (`GetOrderTargetItem() != null`)
  - triggering unit is tracked hero

### A1 (Immediate deposit)
Deposit immediately on the order.

**Pros**
- Simple.
- Very compatible with native engine pickup flow.

**Cons**
- Creates a temporary unequip window while hero is still moving.
- Edge cases (stun, order interruption, retarget) can leave inventory state changed even if pickup never happens.

### A2 (Late deposit, recommended variant)
Store intent first; deposit only when hero is close enough to actually pick up.

**Pros**
- Keeps native behavior.
- Greatly reduces temporary unequip risk.
- Minimizes side effects from interrupted movement.

**Cons**
- More state tracking and timer logic.
- Slightly more complex debugging.

### Suggested guards for A2
- Validate hero still alive, not paused/stunned if desired.
- Validate target item still exists and is reachable.
- Validate order still relevant (optional strictness).
- Deposit at most once per intent.
- Clear intent on timeout, order change, pickup success/failure.

---

## Option B — Full Custom Pickup Override (System-First)

### Idea
On item intent, bypass native pickup by forcing the item directly into bag system and stopping/canceling native pickup path.

### Pros
- Maximum control over behavior and UX.
- Can avoid most native error text entirely.
- Consistent bag-first identity.

### Cons
- Highest implementation risk.
- Must emulate engine semantics (ownership, pathing timing, visibility, special item classes, edge cases).
- Greater chance of regressions with future systems.

---

## Quick Comparison

| Topic | Option A | Option B |
|---|---|---|
| Engine compatibility | High | Medium-Low |
| Complexity | Low-Medium | High |
| Side-effect risk | Low (A2), Medium (A1) | Medium-High |
| Control over UX | Medium | High |
| Time to safe rollout | Fast (A2) | Slow |

---

## Recommendation
Use **Option A2 (late deposit)** first.

Rationale:
- Preserves Warcraft III native pickup behavior.
- Avoids most temporary-unequip concerns from immediate deposit.
- Solves the practical pain point with limited invasive changes.

---

## High-Level Implementation Plan (for later)
1. Add `TriggerItemIntent` for `EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER`.
2. On smart-item order, store per-player intent:
   - hero
   - target item handle
   - timestamp/expiry
   - processed flag
3. Run a short periodic timer (e.g. 0.03s):
   - if intent invalid => clear
   - if hero near target and inventory full => call `DepositInventorySlot` once
4. Let native pickup continue naturally.
5. On `EVENT_PLAYER_UNIT_PICKUP_ITEM`, clear intent as completed.
6. Add conservative cleanup on order interruption/death/timeout.

---

## Notes
- This is a known QoL issue, not a blocker; current behavior is workable.
- Keeping this as a design note is reasonable until you prioritize implementation.
