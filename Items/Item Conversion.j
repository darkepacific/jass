// 1) Item conversion data & helpers
// -----------------------------------------------------------------------------
// Item conversion: states
// -----------------------------------------------------------------------------
globals
    // Parallel to your existing udg_SaveItemType[] (rawcode per index)
    // These arrays define what to do when an old index appears in a save.
    integer array gItemState   // 0=ACTIVE, 1=DEPRECATED (swap), 2=REMOVED
    integer array gItemSwap    // for DEPRECATED: replacement index (0 = none)
    integer array gItemRefund  // for REMOVED: gold refund amount
endglobals

// convenience constants
function ITEM_STATE_ACTIVE takes nothing returns integer
    return 0
endfunction
function ITEM_STATE_DEPRECATED takes nothing returns integer
    return 1
endfunction
function ITEM_STATE_REMOVED takes nothing returns integer
    return 2
endfunction

// Mark an index as deprecated -> replaced by newIdx
function DeprecateItemIndex takes integer oldIdx, integer newIdx returns nothing
    set gItemState[oldIdx] = ITEM_STATE_DEPRECATED()
    set gItemSwap[oldIdx]  = newIdx
    set gItemRefund[oldIdx]= 0
endfunction

// Mark an index as removed -> skip and refund gold (or 0)
function RemoveItemIndex takes integer oldIdx, integer refund returns nothing
    set gItemState[oldIdx] = ITEM_STATE_REMOVED()
    set gItemSwap[oldIdx]  = 0
    set gItemRefund[oldIdx]= refund
endfunction

// Default all indices to ACTIVE; then apply your per-index changes.
// Call this once at map init, AFTER udg_SaveItemType[] is populated or hardcoded.
function InitItemConversion takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i > udg_SaveItemTypeMax
        set gItemState[i]  = ITEM_STATE_ACTIVE()
        set gItemSwap[i]   = 0
        set gItemRefund[i] = 0
        set i = i + 1
    endloop

    // --- Examples of planned changes (EDIT these for your patch notes) ---
    // Deprecate old Lesser Mana Potion (idx 225) -> new Balanced Mana Potion (idx 268)
    // call DeprecateItemIndex(225, 268)

    // Remove discontinued event item (idx 307) and refund 250 gold
    // call RemoveItemIndex(307, 250)

    // You can add as many lines as needed; never reuse removed indices later.
endfunction

// 2) Item creation wrapper (use everywhere you create saved items)
// Create and attach charges/special safely from a rawcode
function GiveItemByRaw takes unit u, integer raw, integer charges, integer special returns nothing
    local item it
    if raw == 0 then
        return
    endif
    set it = CreateItem(raw, GetUnitX(u), GetUnitY(u))
    if it != null then
        call SetItemCharges(it, charges)
        call SaveHelper.SetItemSpecialCondition(it, special)
        call UnitAddItem(u, it)
    endif
    set it = null
endfunction

// Apply one loaded item index using the conversion table
function ApplyLoadedItem takes unit u, integer idx, integer charges, integer special returns nothing
    local integer state = gItemState[idx]
    if state == ITEM_STATE_ACTIVE() then
        call GiveItemByRaw(u, udg_SaveItemType[idx], charges, special)

    elseif state == ITEM_STATE_DEPRECATED() and gItemSwap[idx] > 0 then
        // swap to replacement index
        call GiveItemByRaw(u, udg_SaveItemType[gItemSwap[idx]], charges, special)

    elseif state == ITEM_STATE_REMOVED() then
        // skip and optionally compensate
        if gItemRefund[idx] > 0 then
            call SetPlayerState(GetOwningPlayer(u), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(GetOwningPlayer(u), PLAYER_STATE_RESOURCE_GOLD) + gItemRefund[idx])
        endif
        // (Optional) consolation starter:
        // call GiveItemByRaw(u, 'Inew', 1, 0)
    else
        // Unknown state; fail safe by skipping
    endif
endfunction

// 3) Wire it into your current Load_GUI loop

// Find your current “Load Items” block and replace the creation lines with a call to ApplyLoadedItem. Your code already reads type index, charges, special in that order — perfect.

// -------------------  
// Load Items  
// -------------------
call DebugCritical("Loading Items:")
set i = 1
loop
    exitwhen i > 18

    // type index
    set udg_SaveCount = udg_SaveCount + 1
    set udg_SaveMaxValue[udg_SaveCount] = udg_SaveItemTypeMax
    call SaveHelper.GUILoadNext(saveCodePtr)
    set udg__loadedItemIndex = udg_SaveValue[udg_SaveCount] // temp var for clarity

    // charges
    set udg_SaveCount = udg_SaveCount + 1
    set udg_SaveMaxValue[udg_SaveCount] = 999
    call SaveHelper.GUILoadNext(saveCodePtr)
    set udg__loadedCharges = udg_SaveValue[udg_SaveCount]

    // special
    set udg_SaveCount = udg_SaveCount + 1
    set udg_SaveMaxValue[udg_SaveCount] = 99
    call SaveHelper.GUILoadNext(saveCodePtr)
    set udg__loadedSpecial = udg_SaveValue[udg_SaveCount]

    // Apply with conversion table:
    call ApplyLoadedItem(createdUnit, udg__loadedItemIndex, udg__loadedCharges, udg__loadedSpecial)

    // (Optional) keep your bag bookkeeping as before:
    // set bj_lastCreatedItem is set inside GiveItemByRaw when UnitAddItem happens
    // set udg_P_Items[GetPlayerBagNumber(p) + i] = bj_lastCreatedItem

    set i = i + 1
endloop


// (If you rely on bj_lastCreatedItem after each apply: you can set it inside GiveItemByRaw right after CreateItem.)

// 4) Initialize once (and stop reusing removed slots)

// Call InitItemConversion() once during map init (after your hardcoded udg_SaveItemType[] is assigned). Example:

function Init_Items takes nothing returns nothing
    call InitItemMap()        // your pasted mapping from ItemMap.txt
    set udg_SaveItemTypeMax = 999
    call InitItemConversion() // sets all ACTIVE then applies your deprecations/removals
endfunction

// 5) (Optional) Ability conversion with the same pattern

// If you want the same safety for your 5 saved abilities (still index-based for now), mirror a tiny table:

globals
    integer array gAbState   // 0 active, 1 deprecated->swap, 2 removed->refund
    integer array gAbSwap
endglobals

function DeprecateAbilityIndex takes integer oldIdx, integer newIdx returns nothing
    set gAbState[oldIdx] = 1
    set gAbSwap[oldIdx]  = newIdx
endfunction

function RemoveAbilityIndex takes integer oldIdx returns nothing
    set gAbState[oldIdx] = 2
    set gAbSwap[oldIdx]  = 0
endfunction

function ApplyLoadedAbility takes unit u, integer idx, integer level returns nothing
    if gAbState[idx] == 1 and gAbSwap[idx] > 0 then
        set idx = gAbSwap[idx]
    elseif gAbState[idx] == 2 then
        // skip and keep a point to refund later
        call ModifyHeroSkillPoints(u, bj_MODIFYMETHOD_ADD, 1)
        return
    endif
    call UnitAddAbilityBJ(udg_SaveAbilityType[idx], u)
    call SetUnitAbilityLevelSwapped(udg_SaveAbilityType[idx], u, level)
endfunction


// Use this inside your ability loop instead of directly adding by the old index. Later, when you move to rawcodes, the same shape becomes a raw->raw map.