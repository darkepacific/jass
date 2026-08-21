function Trig_Rattlegore_Hamstring_Conditions takes nothing returns boolean
    if ( not ( GetUnitTypeId(GetTriggerUnit()) == 'U002' ) ) then
        return false
    endif
    if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, GetTriggerUnit()) <= 5900.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Rattlegore_Hamstring_Actions takes nothing returns nothing
    local real dx = GetUnitX(GetEventDamageSource()) - GetUnitX(GetTriggerUnit())
    local real dy = GetUnitY(GetEventDamageSource()) - GetUnitY(GetTriggerUnit())
    if ( SquareRoot(dx * dx + dy * dy) < 200.00 ) then
        call DisableTrigger( GetTriggeringTrigger() )
        call BlzEndUnitAbilityCooldown(udg_Rattlegore, 'A05G')
        call IssueImmediateOrderBJ( GetTriggerUnit(), "fanofknives" )
        call GameTimeWait(8.50)
        call EnableTrigger( GetTriggeringTrigger() )
    endif
endfunction

//===========================================================================
function InitTrig_Rattlegore_Hamstring takes nothing returns nothing
    set gg_trg_Rattlegore_Hamstring = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Rattlegore_Hamstring, EVENT_PLAYER_UNIT_DAMAGED )
    call TriggerAddCondition( gg_trg_Rattlegore_Hamstring, Condition( function Trig_Rattlegore_Hamstring_Conditions ) )
    call TriggerAddAction( gg_trg_Rattlegore_Hamstring, function Trig_Rattlegore_Hamstring_Actions )
endfunction

