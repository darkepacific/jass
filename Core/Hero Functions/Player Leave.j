
function Trig_Player_Leave_Actions takes nothing returns nothing
    local integer playerNumber = PlayerNumbtoHeroesNumb()
    local unit hero = udg_Heroes[playerNumber]
    local location pt = GetRectCenter(gg_rct_Reroll)

    call IssueImmediateOrderBJ( hero, "stop")
    call SetUnitInvulnerable( hero , true )
    call PauseUnit( hero, true )
    call HideUnit(hero)
    // call TalentResetDo(udg_Heroes[playerNumber], 999999, true )
    // call RefreshTalentUINoSound( p )
    call SetUnitOwner(hero, Player(GetPlayerNeutralPassive()), true )
    call SetUnitPositionLoc(hero, pt )
    call RemoveLocation(pt)
    call PlayerReturnToHeroSelection(GetTriggerPlayer())
    
    //Wait just to be safe
    call GameTimeWait(30.0)
    call RemoveUnit(hero)
    set udg_Heroes[playerNumber] = null

    set hero = null
    set pt = null
endfunction

//===========================================================================
function InitTrig_Player_Leave takes nothing returns nothing
    set gg_trg_Player_Leave = CreateTrigger(  )
    call TriggerRegisterPlayerEventLeave( gg_trg_Player_Leave, Player(5) )
    call TriggerRegisterPlayerEventLeave( gg_trg_Player_Leave, Player(4) )
    call TriggerRegisterPlayerEventLeave( gg_trg_Player_Leave, Player(6) )
    call TriggerRegisterPlayerEventLeave( gg_trg_Player_Leave, Player(10) )
    call TriggerRegisterPlayerEventLeave( gg_trg_Player_Leave, Player(2) )
    call TriggerRegisterPlayerEventLeave( gg_trg_Player_Leave, Player(7) )
    call TriggerRegisterPlayerEventLeave( gg_trg_Player_Leave, Player(8) )
    call TriggerRegisterPlayerEventLeave( gg_trg_Player_Leave, Player(9) )
    call TriggerRegisterPlayerEventLeave( gg_trg_Player_Leave, Player(12) )
    call TriggerRegisterPlayerEventLeave( gg_trg_Player_Leave, Player(13) )
    call TriggerAddAction( gg_trg_Player_Leave, function Trig_Player_Leave_Actions )
endfunction

