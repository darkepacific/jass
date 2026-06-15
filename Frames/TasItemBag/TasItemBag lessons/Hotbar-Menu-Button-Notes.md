# Hotbar Menu (Computer) Button — Build Notes (June 2026)

## What it is
A standalone `TasItemBagSlot` button at the far LEFT of the quick-use hotbar that toggles the
main menu (DialogSystem). Mirror of the bag-toggle button on the far right: in line with the
hotbar, shows a rebindable hotkey badge, but is NOT part of the quick-use / 2nd-inventory system.
Built to be extended leftward later (crafting, talents).

## Architecture
- **`TasItemBag.j` owns the frame.**
  - `MENU_BUTTON_CONTEXT = 200` — its own create-context, outside quick-use 101–106. Future
    buttons: 201, 202, ... anchored `TOPRIGHT -> TOPLEFT` of the previous one, marching left.
  - `CreateMenuButton()` (called from `InitFrames`) builds it: textures (BTN + DISBTN), hotkey
    badge, anchored to the left of quick-use slot 1, starts hidden.
  - `SetMenuButtonVisible()` is called beside the two `SetQuickUseBarVisible` calls in
    `RenderBagFramesForPlayer`, gated on `ShowBagButtonForPlayer[pId]` — the whole row shows/hides
    as a unit.
  - Badge label: `MenuHotkeyText[]` + `GetMenuButtonCaption` + public
    `TasItemBagSetMenuHotkeyLabel`. Exact clone of the bag-toggle label trio. Never hardcode the
    key letter.
  - `TriggerUIMenuButton`: created in `InitBagAt0s` with the other UI triggers; the menu button's
    frame click is registered onto it in `CreateMenuButton`.
- **`DialogSystem.j` owns the behavior.**
  - `TasItemBagRegisterMenuButtonAction(function MenuButtonAction)` adds the toggle action to the
    trigger. TasItemBag never references DialogSystem (dependency stays DialogSystem -> TasItemBag).
  - `MenuButtonAction` = same path as the C hotkey: `ConfigOpen` guard, then `ToggleMenuForPlayer`.
  - `RefreshBoundHotkeyLabels` pushes `MenuHotkeyLabel[pid]` into the badge via
    `TasItemBagSetMenuHotkeyLabel` — fires on defaults, file-load, and every rebind.

## The bugs that actually cost the time (all confirmed by instrumentation, not theory)

1. **Trigger created mid-`InitFrames` silently killed the init thread.** An early rebuild lazily
   did `CreateTrigger()` + `TriggerAddAction()` *inside* `CreateMenuButton`, hundreds of frame
   natives deep into `InitFrames`. That deterministically killed the JASS thread with no error —
   so `InitFrames` never finished: bag panel left visible at start with null icons, popups dead,
   button never shown. **Fix:** create `TriggerUIMenuButton` up-front in `InitBagAt0s` with the
   other UI triggers, before `InitFrames`. Registering a frame *event* mid-InitFrames is fine;
   it's `CreateTrigger` that must not happen there.
   - This was at first misdiagnosed (by me and prior AIs) as the JASS op-limit. It was NOT.
     Numbered `BJDebugMsg` checkpoints proved the baseline thread completes with room to spare and
     that death was deterministic at the `CreateTrigger` line. Don't reach for "op-limit" without
     a checkpoint proving the thread is actually budget-bound.

2. **The DialogSystem handler was registered as the LAST line of `FinishHotkeyInit`.** Something in
   that init tail (`LoadHotkeysForPlayer` loop / `InitDialog`) appears to die before the end —
   latent in the baseline, harmless only because nothing used to come after it. The menu-button
   registration sat behind that landmine and never ran: the button's trigger fired but no handler
   was attached. **Fix:** register right after `RegisterAllHotkeys` (a known-reached point).
   Timing is safe — the trigger already exists and the menu isn't needed until clicked.
   - A pre-existing suspected crash still lurks in that init tail. Out of scope here, but worth a
     look someday (would affect saved-hotkey loading / multi-slot dialog setup).

3. **`MenuOpen` desync.** Native dialogs close on ANY button click, but only the Close/Hotkeys
   branches of `OnButtonClick` cleared `MenuOpen`. After Save/New Hero the flag stayed true →
   next toggle was a no-op ("needs two clicks"). **Fix:** clear `MenuOpen[pid]` unconditionally at
   the top of `OnButtonClick`.

4. **Cosmetics:** the `TasItemBagSlot` template's overlay shows a default "1"/count — hidden +
   cleared for the menu button. Badge texture uses backslash + `.blp` (forward-slash UI paths
   render blank here). The green-square icon was an invisible leading space in the imported BLP
   path — a map-asset issue, not code.

## The thing that wasted the MOST time and had nothing to do with code
**Manual copy-paste build.** The `.j` files here are pasted by hand into the WC3 map's editor.
For a long stretch, `TasItemBag.j` was being re-pasted but `DialogSystem.j` was NOT — so every
DialogSystem edit (mine and prior AIs') was invisible to the running map. Symptom: TasItemBag
`BJDebugMsg` lines appeared in-game, DialogSystem ones never did, despite identical code.
**If a DialogSystem change "does nothing," confirm the file was actually re-pasted into the map
before debugging the code.** When two files change, BOTH must be re-pasted.

## Method that finally worked
Revert to a known-good baseline, then rebuild in tiny stages (frame → click → badge), each one
verified by an actual in-game run with numbered `BJDebugMsg` checkpoints. Every real bug was
located by reading which checkpoint was the last to print — never by guessing. Confirmed no
desyncs after completion.

## Engine limitation (not a bug)
While the native dialog menu is open it is modal — the computer button can't be clicked to close
it. Close = dialog Close button / C / ESC. True click-to-close parity would need the menu
converted from a native dialog to a frame panel (like `hotkeyConfigPanel`).

## Adding the next button (crafting/talents)
- New context constant (201/202) + BTN/DISBTN texture constants.
- Clone `CreateMenuButton` (or generalize it to take context/texture/anchor + left-neighbor).
- Create its trigger in `InitBagAt0s`; register the frame click in the create function.
- Add a `SetXVisible` call beside both `SetMenuButtonVisible` sites in `RenderBagFramesForPlayer`.
- Register behavior from the owning library via a `TasItemBagRegisterXButtonAction` seam.
- If rebindable: label array + setter + a line in `RefreshBoundHotkeyLabels` + a Listen/ApplyKey
  branch in DialogSystem's hotkey config.
- Re-paste BOTH files into the map.
