function Trig_Pyroblast_Move_HU_Actions takes nothing returns nothing
    local location targetLoc
    local unit target = udg_SpellUnits[ udg_z_MA_FIRE_A ]

    if target == null or IsUnitDeadBJ(target)  then
        call DisableTrigger( gg_trg_Pyroblast_Move_HU )
        call DisableTrigger( gg_trg_Pyroblast_Explode_HU )

        call Trig_Pyroblast_Explode_HU_Actions()

        call SetUnitOwner( gg_unit_e01Q_1985, Player(PLAYER_NEUTRAL_PASSIVE), true )
        set targetLoc = GetRectCenter(gg_rct_DummyIsland)
        call SetUnitPositionLoc( gg_unit_e01Q_1985, targetLoc )
        call RemoveLocation (targetLoc)    
    else 
        set targetLoc = GetUnitLoc(target)
        call IssuePointOrderLocBJ( gg_unit_e01Q_1985, "move", targetLoc )
        call RemoveLocation (targetLoc)
    endif
    
    set target = null
    set targetLoc = null
endfunction
 
//===========================================================================
function InitTrig_Pyroblast_Move_HU takes nothing returns nothing
    set gg_trg_Pyroblast_Move_HU = CreateTrigger(  )
    call DisableTrigger( gg_trg_Pyroblast_Move_HU )
    call TriggerRegisterTimerEventPeriodic( gg_trg_Pyroblast_Move_HU, 0.20 )
    call TriggerAddAction( gg_trg_Pyroblast_Move_HU, function Trig_Pyroblast_Move_HU_Actions )
endfunction

