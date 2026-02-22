function Trig_Pyroblast_Move_BE_Actions takes nothing returns nothing
    local location targetLoc
    local unit target = udg_SpellUnits[ udg_z_MA_FIRE_H ]

    if target == null or IsUnitDeadBJ(target)  then
        call DisableTrigger( gg_trg_Pyroblast_Move_BE )
        call DisableTrigger( gg_trg_Pyroblast_Explode_BE )
        
        call Trig_Pyroblast_Explode_BE_Actions()

        call SetUnitOwner( gg_unit_e01Q_0089, Player(PLAYER_NEUTRAL_PASSIVE), true )
        set targetLoc = GetRectCenter(gg_rct_DummyIsland)
        call SetUnitPositionLoc( gg_unit_e01Q_0089, targetLoc )
        call RemoveLocation (targetLoc)    
    else 
        set targetLoc = GetUnitLoc(target)
        call IssuePointOrderLocBJ( gg_unit_e01Q_0089, "move", targetLoc )
        call RemoveLocation (targetLoc)
    endif
    
    set target = null
    set targetLoc = null
endfunction

//===========================================================================
function InitTrig_Pyroblast_Move_BE takes nothing returns nothing
    set gg_trg_Pyroblast_Move_BE = CreateTrigger(  )
    call DisableTrigger( gg_trg_Pyroblast_Move_BE )
    call TriggerRegisterTimerEventPeriodic( gg_trg_Pyroblast_Move_BE, 0.20 )
    call TriggerAddAction( gg_trg_Pyroblast_Move_BE, function Trig_Pyroblast_Move_BE_Actions )
endfunction

