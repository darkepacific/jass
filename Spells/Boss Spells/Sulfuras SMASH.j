function Trig_Sulfuras_SMASH_Conditions takes nothing returns boolean
    if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, GetTriggerUnit()) < 12625.00 ) ) then
        return false
    endif
    if ( not ( GetUnitTypeId(GetTriggerUnit()) == 'Nfir' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Sulfuras_SMASH_Actions takes nothing returns nothing
    local unit target = BlzGetEventDamageTarget()
    local unit source = GetEventDamageSource()
    local location udg_Temp_Unit_Point
    local location udg_Temp_Polar_Point
    local real angle
    
    // If the damage source is close, spawn the smash dummy and force Ragnaros to attack it.
    if source != null and target != null and DistanceBetweenUnits(source, target) <= 600.00 then
        call DisableTrigger( GetTriggeringTrigger() )

        set udg_Temp_Unit_Point = GetUnitLoc( target )
        set udg_Temp_Polar_Point = GetUnitLoc( source )
        set angle = AngleBetweenPoints(udg_Temp_Unit_Point, udg_Temp_Polar_Point)
        call RemoveLocation (udg_Temp_Polar_Point)

        set udg_Temp_Polar_Point = PolarProjectionBJ(udg_Temp_Unit_Point, 80.00, angle)
        call RemoveLocation (udg_Temp_Unit_Point)

        call CreateNUnitsAtLoc( 1, 'e03F', Player(PLAYER_NEUTRAL_AGGRESSIVE), udg_Temp_Polar_Point, bj_UNIT_FACING )
        call RemoveLocation (udg_Temp_Polar_Point)
        
        call UnitApplyTimedLifeBJ( 1.25, 'BTLF', GetLastCreatedUnit() )
        call UnitRemoveBuffsBJ( bj_REMOVEBUFFS_NEGATIVE, target )
        call IssueTargetOrderBJ( target, "attack", GetLastCreatedUnit() )

        call TriggerSleepAction( 10.00 )
        call EnableTrigger( GetTriggeringTrigger() )
    endif

    set udg_Temp_Unit_Point = null
    set udg_Temp_Polar_Point = null
    set target = null
    set source = null
endfunction

//===========================================================================
function InitTrig_Sulfuras_SMASH takes nothing returns nothing
    set gg_trg_Sulfuras_SMASH = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Sulfuras_SMASH, EVENT_PLAYER_UNIT_DAMAGED )
    call TriggerAddCondition( gg_trg_Sulfuras_SMASH, Condition( function Trig_Sulfuras_SMASH_Conditions ) )
    call TriggerAddAction( gg_trg_Sulfuras_SMASH, function Trig_Sulfuras_SMASH_Actions )
endfunction

