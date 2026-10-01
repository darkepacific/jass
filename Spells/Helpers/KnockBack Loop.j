function Trig_KnockBackLoop_Func002Func001Func021C takes nothing returns boolean
    if ( not ( udg_RealStatCalc >= 16.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_KnockBackLoop_Func002Func001C takes nothing returns boolean
    if ( not ( BlzIsUnitInvulnerable(GetEnumUnit()) == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_KnockBackLoop_Func002A takes nothing returns nothing
    if ( Trig_KnockBackLoop_Func002Func001C() ) then
        //call Debug("Knockback Loop Fired")
        set udg_Temp_Angle = LoadRealBJ(0, GetHandleIdBJ(GetEnumUnit()), udg_KnockBacksHash)
        set udg_Temp_Polar_Point = GetUnitLoc(GetEnumUnit())
        set udg_RealStatCalc = LoadRealBJ(3, GetHandleIdBJ(GetEnumUnit()), udg_KnockBacksHash)
        set udg_Temp_Unit_Point = PolarProjectionBJ(udg_Temp_Polar_Point, udg_RealStatCalc, udg_Temp_Angle)
        if LoadBooleanBJ(4, GetHandleIdBJ(GetEnumUnit()), udg_KnockBacksHash) then    //Check If Ignoring Pathing
        call Debug("Invalid pathing allowed")
        call SetUnitPositionLoc( GetEnumUnit(), udg_Temp_Unit_Point )
        elseif not IsTerrainPathable( GetLocationX(udg_Temp_Unit_Point), GetLocationY(udg_Temp_Unit_Point), PATHING_TYPE_WALKABILITY) then
        call SetUnitPositionLoc( GetEnumUnit(), udg_Temp_Unit_Point )
        endif
        call RemoveLocation (udg_Temp_Unit_Point)
        call RemoveLocation (udg_Temp_Polar_Point)
        set udg_RealStatCalc = LoadRealBJ(1, GetHandleIdBJ(GetEnumUnit()), udg_KnockBacksHash)
        set udg_RealStatCalc = ( udg_RealStatCalc + 1 )
        set udg_Temp_Real = LoadRealBJ(2, GetHandleIdBJ(GetEnumUnit()), udg_KnockBacksHash)
        call SetUnitFlyHeightBJ( GetEnumUnit(), ( udg_Temp_Real * SinBJ(AcosBJ(( 1.00 - ( udg_RealStatCalc / 8.00 ) ))) ), 0.00 )
        if ( Trig_KnockBackLoop_Func002Func001Func021C() ) then
            call FlushChildHashtableBJ( GetHandleIdBJ(GetEnumUnit()), GetLastCreatedHashtableBJ() )
            call GroupRemoveUnitSimple( GetEnumUnit(), udg_KnockBacks )
            call SetUnitFlyHeightBJ( GetEnumUnit(), 0.00, 0.00 )
        else
            call SaveRealBJ( udg_RealStatCalc, 1, GetHandleIdBJ(GetEnumUnit()), udg_KnockBacksHash )
        endif
    else
        call SetUnitFlyHeightBJ( GetEnumUnit(), 0.00, 0.00 )
        call FlushChildHashtableBJ( GetHandleIdBJ(GetEnumUnit()), GetLastCreatedHashtableBJ() )
        call GroupRemoveUnitSimple( GetEnumUnit(), udg_KnockBacks )
    endif
endfunction

function Trig_KnockBackLoop_Func003C takes nothing returns boolean
    if ( not ( IsUnitGroupEmptyBJ(udg_KnockBacks) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_KnockBackLoop_Actions takes nothing returns nothing
    call ForGroupBJ( udg_KnockBacks, function Trig_KnockBackLoop_Func002A )
    if ( Trig_KnockBackLoop_Func003C() ) then
        call Debug("Knockbacks Is Empty")
        call DisableTrigger( GetTriggeringTrigger() )
    else
    endif
endfunction

//===========================================================================
function InitTrig_KnockBackLoop takes nothing returns nothing
    set gg_trg_KnockBackLoop = CreateTrigger(  )
    call DisableTrigger( gg_trg_KnockBackLoop )
    call TriggerRegisterTimerEventPeriodic( gg_trg_KnockBackLoop, 0.02 )
    call TriggerAddAction( gg_trg_KnockBackLoop, function Trig_KnockBackLoop_Actions )
endfunction

