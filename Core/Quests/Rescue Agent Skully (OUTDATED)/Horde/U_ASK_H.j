function Trig_U_ASK_H_Conditions takes nothing returns boolean
    if ( not ( GetDestructableTypeId(GetDyingDestructable()) == 'LOcg' ) ) then
        return false
    endif
    return true
endfunction

function Trig_U_ASK_H_Func013C takes nothing returns boolean
    if ( not ( GetTriggerExecCount(GetTriggeringTrigger()) > 5 ) ) then
        return false
    endif
    return true
endfunction

function Trig_U_ASK_H_Actions takes nothing returns nothing
    local integer udg_Temp_Int = 169
    local unit Freed
    local destructable cage = GetDyingDestructable()
    local location udg_Temp_Unit_Point
    set udg_Temp_Unit_Point = GetDestructableLoc(GetDyingDestructable())
    call CreateNUnitsAtLoc( 1, 'u00O', Player(PLAYER_NEUTRAL_AGGRESSIVE), udg_Temp_Unit_Point, GetRandomDirectionDeg() )
    call RemoveLocation (udg_Temp_Unit_Point)
    set Freed = GetLastCreatedUnit()
     call CreateTextTagUnitBJ( "!", Freed, 0.00, 8.00, 100.00, 100.00, 0.00, 0 )
    call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 20.00, 90.00 )
    call cleanUpText(1.2, 0.8)
    if ( Trig_U_ASK_H_Func013C() ) then
        set udg_Temp_Unit_Point = GetRectCenter(gg_rct_High_Abbot_Landgren)
        call CreateNUnitsAtLoc( 1, 'H041', Player(PLAYER_NEUTRAL_PASSIVE), udg_Temp_Unit_Point, 300.00 )
        call RemoveLocation (udg_Temp_Unit_Point)
        set udg_HighAbbotLandgren = GetLastCreatedUnit()
        call SetHeroLevelBJ( GetLastCreatedUnit(), 40, false )
        call MaxManaRestore( 1.0, udg_HighAbbotLandgren)
        call CreateTextTagUnitBJ( "WHO IS FREEING ALL THE PRISONERS?", GetLastCreatedUnit(), 0, 8.00, 100.00, 15.00, 15.00, 0 )
        call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 10.00, 90.00 )
        call cleanUpText(1.3, 1.0)
        call ShowTextTagForceBJ( false, GetLastCreatedTextTag(), GetPlayersAll() )
        call ShowTextTagForceBJ( true, GetLastCreatedTextTag(), udg_HordePlayers )
    else
    endif
    call TriggerSleepAction( 20.00 )
    call DestructableRestoreLife( cage, 50.00, false )
    set Freed = null
    set cage = null
    set udg_Temp_Unit_Point = null
endfunction

//===========================================================================
function InitTrig_U_ASK_H takes nothing returns nothing
    set gg_trg_U_ASK_H = CreateTrigger(  )
    call TriggerRegisterDestDeathInRegionEvent( gg_trg_U_ASK_H, gg_rct_Dragonblight )
    call TriggerAddCondition( gg_trg_U_ASK_H, Condition( function Trig_U_ASK_H_Conditions ) )
    call TriggerAddAction( gg_trg_U_ASK_H, function Trig_U_ASK_H_Actions )
endfunction

