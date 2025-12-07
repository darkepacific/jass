function Trig_Autosave_Periodic_Actions takes nothing returns nothing
    local integer i = 0
    local integer playerNumber

    // call Debug("Autosave Periodic Trigger Executed")
    if(udg_GameMode == "Normal") then

        loop
            exitwhen i >= bj_MAX_PLAYERS

            if(GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER) then
                set playerNumber = GetPlayerHeroNumber(Player(i))
                if udg_Heroes[playerNumber] != null then
                    // call Debug("Periodic Saving Unit Name: " + GetUnitName(udg_Heroes[playerNumber]) + " in slot " + I2S(GetSlotForHero(udg_Heroes[playerNumber])))
                    call SaveCharToSlot(udg_Heroes[playerNumber], GetSlotForHero(udg_Heroes[playerNumber]))
                endif
            endif
            set i = i + 1
        endloop
    endif
endfunction

//===========================================================================
function InitTrig_Autosave_Periodic takes nothing returns nothing
    set gg_trg_Autosave_Periodic = CreateTrigger()
    call TriggerRegisterTimerEventPeriodic(gg_trg_Autosave_Periodic, 60.00 )
    call TriggerAddAction(gg_trg_Autosave_Periodic, function Trig_Autosave_Periodic_Actions )
endfunction

