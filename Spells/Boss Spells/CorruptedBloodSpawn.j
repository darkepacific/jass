function Trig_Corrupted_Blood_Spawn_Conditions takes nothing returns boolean
    if ( not ( GetUnitTypeId(GetTriggerUnit()) == 'E04O' ) ) then
        return false
    endif
    if ( not ( GetUnitStateSwap(UNIT_STATE_LIFE, GetTriggerUnit()) < 1650.00 ) ) then
        return false
    endif
    return true
endfunction

function Trig_Corrupted_Blood_Spawn_Actions takes nothing returns nothing
    local location pt
    local unit u
    local integer i = 1
    local real facing = 0.0
    local rect array altars
    local real array facings
    local effect e

    //Disable the trigger to prevent subsequent calls while the units are spawning
    call DisableTrigger(GetTriggeringTrigger())

    // Define altar regions and facing angles
    set altars[1] = gg_rct_Altar_of_Hakkar1
    set altars[2] = gg_rct_Altar_of_Hakkar2
    set altars[3] = gg_rct_Altar_of_Hakkar3
    set altars[4] = gg_rct_Altar_of_Hakkar4
    set altars[5] = gg_rct_Altar_of_Hakkar5
    set altars[6] = gg_rct_Altar_of_Hakkar6
    set facings[1] = 45.00
    set facings[2] = 90.00
    set facings[3] = 170.00

    // Loop to 
    loop
        exitwhen i > 3

        // Fireball
        set pt = GetRectCenter(altars[i])
        set e = AddSpecialEffectLoc("Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl", pt)
        call BlzSetSpecialEffectZ(e, 20.00)
        call DestroyEffectBJ(e)
        call RemoveLocation(pt)

        //Spawn Corrupted Blood
        set u = null
        set pt = GetRectCenter(altars[i+3])
        if not IsTerrainPathable(GetLocationX(pt), GetLocationY(pt), PATHING_TYPE_WALKABILITY) then
            set u = CreateUnitAtLoc(Player(PLAYER_NEUTRAL_AGGRESSIVE), 'n05X', pt, facings[i])
        endif
        call RemoveLocation(pt)
        
        // call TriggerSleepAction(0.1)

        if u != null then
            call UnitApplyTimedLife(u, 'BTLF', 60.0)
            set pt = GetRectCenter(gg_rct_Hinterlands_Trolls_2)
            call IssuePointOrderLoc(u, "patrol", pt)
            call RemoveLocation(pt)
        endif

        set i = i + 1
    endloop

    // Re-enable trigger after delay
    call TriggerSleepAction(5.00)
    call EnableTrigger(GetTriggeringTrigger())

    set pt = null
    set u = null
    set e = null
    set altars[1] = null
    set altars[2] = null
    set altars[3] = null
    set altars[4] = null
    set altars[5] = null
    set altars[6] = null
endfunction


//===========================================================================
function InitTrig_Corrupted_Blood_Spawn takes nothing returns nothing
    set gg_trg_Corrupted_Blood_Spawn = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Corrupted_Blood_Spawn, EVENT_PLAYER_UNIT_DAMAGED )
    call TriggerAddCondition( gg_trg_Corrupted_Blood_Spawn, Condition( function Trig_Corrupted_Blood_Spawn_Conditions ) )
    call TriggerAddAction( gg_trg_Corrupted_Blood_Spawn, function Trig_Corrupted_Blood_Spawn_Actions )
endfunction

