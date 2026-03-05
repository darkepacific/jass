# TasItemBag Pickup Intent System Notes

## Current Decision (March 2026)
- **Default mode is A1-style immediate relief** (`PickupIntentUseImmediateRelief = true`).
- Reason: feels smoother and more responsive in normal gameplay.

## Mode Definitions
- **A1 / Immediate-first**
  - On smart item pickup intent with full inventory, system immediately switches to a relief page (if available), then native pickup continues.
- **A2 / Near-item timing**
  - System arms intent and waits until hero is near target item before switching pages.

## What We Learned in Testing
- A1 feels best in practice and avoids extra user re-click friction.
- A2 works, but can feel less reliable to players because:
  - switch happens late (near target only),
  - user perception can be "didn't trigger" until close,
  - can appear to need another click in some movement/order timing paths.
- Deferred return (Phase 1.5) is important:
  - return-to-original page should happen **after** item gain/bag insert handling,
  - otherwise pickup item can end up in page inventory path incorrectly.

## Implemented Safety/Quality Notes
- Same-target SMART re-orders preserve original intent context (prevents origin page drift).
- Return guard avoids overriding manual page changes after relief switch.
- Shop-select sell override still clears pending world-drop queue first.

## Known UX Risk Areas
- Native "Inventory is full" warning text/sound may still leak in some timing windows even with suppression.
- Item-flood disarm strategy is theoretically possible (forcing frequent swap behavior), but currently considered fringe and hard to execute consistently.

## Future Toggle Roadmap (not fully implemented yet)
Desired player-facing control:
1. **A1 mode** (immediate-first)
2. **A2 mode** (near-item timing)
3. **Off** (disable smart page swapping assistance)

Current code already has a binary mode switch (`PickupIntentUseImmediateRelief`), which can be expanded into a tri-state config later.

## Practical Recommendation
- Keep default on A1 for live gameplay.
- Keep A2 path in code/docs for experimentation and fallback.
- Revisit warning suppression separately with a more explicit gating approach if needed.
