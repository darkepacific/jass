function Trig_Rattlegore_Bonestorm_Conditions takes nothing returns boolean
    if ( not ( GetUnitTypeId(GetTriggerUnit()) == 'U002' ) ) then
        return false
    endif
    if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, GetTriggerUnit()) <= 5500.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Rattlegore_Bonestorm_Actions takes nothing returns nothing
    call DisableTrigger( GetTriggeringTrigger() )
    //call SetUnitAbilityLevel(gg_unit_e03G_2001, 'A0BF', 35)
    //call IssueTargetOrder(gg_unit_e03G_2001, "innerfire", GetTriggerUnit() )
    call DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl", GetUnitX(GetTriggerUnit()), GetUnitY(GetTriggerUnit())))
    call GameTimeWait(2.00)
    call IssueImmediateOrderBJ( GetTriggerUnit(), "battleroar" )
    call GameTimeWait(6.00)
    call EnableTrigger( GetTriggeringTrigger() )
endfunction

//===========================================================================
function InitTrig_Rattlegore_Bonestorm takes nothing returns nothing
    set gg_trg_Rattlegore_Bonestorm = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Rattlegore_Bonestorm, EVENT_PLAYER_UNIT_DAMAGED )
    call TriggerAddCondition( gg_trg_Rattlegore_Bonestorm, Condition( function Trig_Rattlegore_Bonestorm_Conditions ) )
    call TriggerAddAction( gg_trg_Rattlegore_Bonestorm, function Trig_Rattlegore_Bonestorm_Actions )
endfunction

