function Trig_Rattlegore_Impale_Conditions takes nothing returns boolean
    if ( not ( GetUnitTypeId(GetTriggerUnit()) == 'U002' ) ) then
        return false
    endif
    if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, GetTriggerUnit()) <= 5200.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Rattlegore_Impale_Actions takes nothing returns nothing
    local unit source = GetEventDamageSource() 

    if RectContainsUnit( gg_rct_Scholomance_Music, source ) then
        call DisableTrigger( GetTriggeringTrigger() )
        call BlzEndUnitAbilityCooldown(udg_Rattlegore, 'A0GR')
        call IssuePointOrder( GetTriggerUnit(), "impale", GetUnitX(source), GetUnitY(source) )
        call GameTimeWait(6.00)
        call EnableTrigger( GetTriggeringTrigger() )
    endif
    
    set source = null
endfunction

//===========================================================================
function InitTrig_Rattlegore_Impale takes nothing returns nothing
    set gg_trg_Rattlegore_Impale = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Rattlegore_Impale, EVENT_PLAYER_UNIT_DAMAGED )
    call TriggerAddCondition( gg_trg_Rattlegore_Impale, Condition( function Trig_Rattlegore_Impale_Conditions ) )
    call TriggerAddAction( gg_trg_Rattlegore_Impale, function Trig_Rattlegore_Impale_Actions )
endfunction

