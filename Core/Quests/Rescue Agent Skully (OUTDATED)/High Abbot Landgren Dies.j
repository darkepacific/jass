function Trig_High_Abbot_Landgren_Dies_Conditions takes nothing returns boolean
    if ( not ( GetUnitTypeId(GetTriggerUnit()) == 'H041' ) ) then
        return false
    endif
    return true
endfunction

function Trig_High_Abbot_Landgren_Dies_Func003C takes nothing returns boolean
    if ( not ( IsQuestCompleted(udg_Quests[169]) == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_High_Abbot_Landgren_Dies_Actions takes nothing returns nothing
    local location udg_Temp_Unit_Point
    set udg_Temp_Unit_Point = GetUnitLoc(GetDyingUnit())
    if ( Trig_High_Abbot_Landgren_Dies_Func003C() ) then
        call CreateItemLoc( 'I0AJ', udg_Temp_Unit_Point )
    else
    endif
    call CreateItemLoc( 'ciri', udg_Temp_Unit_Point )
    call RemoveLocation (udg_Temp_Unit_Point)
    call TriggerSleepAction( 5.00 )
    call HideHero( GetTriggerUnit() )
    call TriggerSleepAction( 40.00 )
    set udg_Temp_Unit_Point = GetRectCenter(gg_rct_High_Abbot_Landgren)
    call ReviveHeroLoc( GetTriggerUnit(), udg_Temp_Unit_Point, true )
    call SetUnitColor( udg_Temp_Unit, PLAYER_COLOR_RED )
    call RemoveLocation (udg_Temp_Unit_Point)
    set udg_Temp_Unit_Point = null
endfunction

//===========================================================================
function InitTrig_High_Abbot_Landgren_Dies takes nothing returns nothing
    set gg_trg_High_Abbot_Landgren_Dies = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_High_Abbot_Landgren_Dies, EVENT_PLAYER_UNIT_DEATH )
    call TriggerAddCondition( gg_trg_High_Abbot_Landgren_Dies, Condition( function Trig_High_Abbot_Landgren_Dies_Conditions ) )
    call TriggerAddAction( gg_trg_High_Abbot_Landgren_Dies, function Trig_High_Abbot_Landgren_Dies_Actions )
endfunction

