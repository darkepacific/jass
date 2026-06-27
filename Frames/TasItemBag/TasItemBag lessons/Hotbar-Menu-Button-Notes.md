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

## UPDATE (June 2026): now a generalized "side-key" subsystem
The bespoke menu button was generalized into an index-based **side-key** system in `TasItemBag.j`
(menu=0, talents=1, crafting=2; contexts `200+index`; screen order `[menu][talents][crafting]`).
The menu still works via thin back-compat wrappers (`TasItemBagRegisterMenuButtonAction`,
`TasItemBagSetMenuHotkeyLabel`), so `DialogSystem.j` was untouched.
- **Talents** side-key reuses TalentGrid's existing `ShowActionFunc` toggle — `TalentGridJUI` now
  `uses TasItemBag` and registers it on side-key 1 via a 0.10s deferred timer (so TasItemBag's
  triggers exist first — same null-trigger trap as before).
- **Crafting** side-key is a placeholder: prints "Crafting coming soon..." and owns the `K` key.
  The old `gg_trg_Crafting` K registration was removed from `KeyboardReg.j:50`; the GUI trigger is
  now orphaned (delete it in the editor whenever).

### Adding a 4th side-key (the easy path now)
- Bump `SIDEKEY_COUNT`, add a `SIDEKEY_FOO=3` index + BTN/DISBTN texture constants.
- Add one `CreateSideKey(SIDEKEY_FOO, …, rightNeighbor)` call in `InitFrames` and re-chain anchors.
- The trigger loop in `InitBagAt0s` already creates `SideKeyTrigger[0..COUNT-1]` — nothing to add
  there unless it needs its own hotkey.
- Owning library: `uses TasItemBag`, register its toggle via
  `TasItemBagRegisterSideKeyAction(SIDEKEY_FOO, function …)` (deferred if from a library init).
- Static badge: `TasItemBagSetSideKeyLabel(SIDEKEY_FOO, GetLocalPlayer(), "X")` in `InitFrames`.
- Re-paste every changed file into the map.

### Future work
- Make Talents/Crafting hotkeys **rebindable** like Menu: add Talents/Crafting rows to DialogSystem's
  "Set Hotkeys" config (Listen/ApplyKey branches + save slots), and push their labels through
  `RefreshBoundHotkeyLabels` via `TasItemBagSetSideKeyLabel(SIDEKEY_TALENTS/CRAFTING, …)` — replacing
  the static `N`/`K`. Talents' `N` key currently lives in `TalentGrid.j` (hardcoded); crafting's `K`
  in `TasItemBag.j`'s `InitBagAt0s`.
- Build the real Crafting UI; its library then `uses TasItemBag` and registers its own toggle on
  `SIDEKEY_CRAFTING`, replacing the placeholder action.
