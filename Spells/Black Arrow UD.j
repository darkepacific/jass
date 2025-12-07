function Trig_Black_Arrow_UD_Jass_Conditions takes nothing returns boolean
    if ( not ( GetDyingUnit() == udg_HunterShots[2] ) ) then
        return false
    endif
    if ( not ( IsUnitType(GetTriggerUnit(), UNIT_TYPE_STRUCTURE) == false ) ) then
        return false
    endif
    if ( not ( IsUnitType(GetTriggerUnit(), UNIT_TYPE_MECHANICAL) == false ) ) then
        return false
    endif
    if ( not ( GetOwningPlayer(GetTriggerUnit()) != Player(PLAYER_NEUTRAL_PASSIVE) ) ) then
        return false
    endif
    return true
endfunction


function Trig_Black_Arrow_UD_Jass_Actions takes nothing returns nothing
    call AddSpecialEffectLocBJ( udg_Temp_Unit_Point, "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl" )
    call DestroyEffectBJ( GetLastCreatedEffectBJ() )
    set udg_Temp_Unit_Point = GetUnitLoc(udg_HunterShots[2])
    set udg_Temp_Unit = udg_yH_Dark_Ranger
    call CreateDarkMinion()
    call RemoveLocation (udg_Temp_Unit_Point)
endfunction

//===========================================================================
function InitTrig_Black_Arrow_UD_Jass takes nothing returns nothing
    set gg_trg_Black_Arrow_UD_Jass = CreateTrigger(  )
    call DisableTrigger( gg_trg_Black_Arrow_UD_Jass )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Black_Arrow_UD_Jass, EVENT_PLAYER_UNIT_DEATH )
    call TriggerAddCondition( gg_trg_Black_Arrow_UD_Jass, Condition( function Trig_Black_Arrow_UD_Jass_Conditions ) )
    call TriggerAddAction( gg_trg_Black_Arrow_UD_Jass, function Trig_Black_Arrow_UD_Jass_Actions )
endfunction

