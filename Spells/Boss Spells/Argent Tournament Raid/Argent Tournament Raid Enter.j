//===========================================================================
// ARGENT TOURNAMENT RAID - ENTER
//===========================================================================

function Argent_Tournament_Raid_Enable_Barrier takes nothing returns nothing
    local destructable d = GetEnumDestructable()
    call DestructableRestoreLife(d, 500.0, false)
    call SetDestructableAnimation(d, "Stand")
    set d = null
endfunction

function Argent_Tournament_Raid_Enter_Conditions takes nothing returns boolean
    local unit u = GetEnteringUnit()
    local player p = GetOwningPlayer(u)

    if GetPlayerController(p) != MAP_CONTROL_USER or GetPlayerSlotState(p) != PLAYER_SLOT_STATE_PLAYING or not IsUnitType(u, UNIT_TYPE_HERO) then
        set u = null
        set p = null
        return false
    endif

    set u = null
    set p = null
    return true
endfunction

function Argent_Tournament_Raid_Enter_Actions takes nothing returns nothing
    call EnumDestructablesInRect(gg_rct_Argent_Tourney_Enable_Barrier, null, function Argent_Tournament_Raid_Enable_Barrier)
endfunction

//===========================================================================
function InitTrig_Argent_Tournament_Raid_Enter takes nothing returns nothing
    set gg_trg_Argent_Tournament_Raid_Enter = CreateTrigger()
    call TriggerRegisterEnterRectSimple(gg_trg_Argent_Tournament_Raid_Enter, gg_rct_Argent_Tournament_Raid)
    call TriggerAddCondition(gg_trg_Argent_Tournament_Raid_Enter, Condition(function Argent_Tournament_Raid_Enter_Conditions))
    call TriggerAddAction(gg_trg_Argent_Tournament_Raid_Enter, function Argent_Tournament_Raid_Enter_Actions)
endfunction