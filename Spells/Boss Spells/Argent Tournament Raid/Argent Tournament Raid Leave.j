//===========================================================================
// ARGENT TOURNAMENT RAID - LEAVE
//===========================================================================

function Argent_Tournament_Raid_Disable_Barrier takes nothing returns nothing
    local destructable d = GetEnumDestructable()
    call KillDestructable(d)
    set d = null
endfunction

function Argent_Tournament_Raid_Leave_Conditions takes nothing returns boolean
    local unit u = GetLeavingUnit()
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

function Argent_Tournament_Raid_Leave_Actions takes nothing returns nothing
    call EnumDestructablesInRect(gg_rct_Argent_Tourney_Enable_Barrier, null, function Argent_Tournament_Raid_Disable_Barrier)
endfunction

//===========================================================================
function InitTrig_Argent_Tournament_Raid_Leave takes nothing returns nothing
    set gg_trg_Argent_Tournament_Raid_Leave = CreateTrigger()
    call TriggerRegisterLeaveRectSimple(gg_trg_Argent_Tournament_Raid_Leave, gg_rct_Argent_Tournament_Raid)
    call TriggerAddCondition(gg_trg_Argent_Tournament_Raid_Leave, Condition(function Argent_Tournament_Raid_Leave_Conditions))
    call TriggerAddAction(gg_trg_Argent_Tournament_Raid_Leave, function Argent_Tournament_Raid_Leave_Actions)
endfunction