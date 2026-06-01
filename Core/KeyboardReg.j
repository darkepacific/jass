function GetOwnedHeroForPlayer takes player p returns unit
    local integer i = 0

    loop
        exitwhen i > 7
        if udg_Heroes[i] != null and GetOwningPlayer(udg_Heroes[i]) == p and GetUnitTypeId(udg_Heroes[i]) != 0 then
            return udg_Heroes[i]
        endif
        set i = i + 1
    endloop

    return null
endfunction

function Trig_Spacebar_Hero_Center_Actions takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local unit hero = GetOwnedHeroForPlayer(p)

    if hero != null then
        call SelectUnitForPlayerSingle(hero, p)
        call PanCameraToTimedForPlayer(p, GetUnitX(hero), GetUnitY(hero), 0.00)
    endif

    set hero = null
    set p = null
endfunction

function Trig_Keyboard_Reg_Actions takes nothing returns nothing
	local integer x
	local trigger spacebarCenterTrigger = CreateTrigger()
	set x = 2  
    loop
        exitwhen x > 13
        if GetPlayerController(Player(x)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(x)) == PLAYER_SLOT_STATE_PLAYING then
            call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Crafting, Player(x), OSKEY_K, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Endless_Rage_Press_R, Player(x), OSKEY_R, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Cloak_of_Shadows_Press_F, Player(x), OSKEY_F, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Pain_Suppression_Press_F, Player(x), OSKEY_F, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(spacebarCenterTrigger, Player(x), OSKEY_SPACE, 0, true)
        endif
        set x = x + 1
    endloop

    call TriggerAddAction(spacebarCenterTrigger, function Trig_Spacebar_Hero_Center_Actions)
    set spacebarCenterTrigger = null

    //Quest log reg OSKEY_L is in TalentGrid.j

    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Crafting, Player(4), OSKEY_K, 0, true)
    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Crafting, Player(5), OSKEY_K, 0, true)
    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Crafting, Player(6), OSKEY_K, 0, true)
    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Crafting, Player(7), OSKEY_K, 0, true)
    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Crafting, Player(8), OSKEY_K, 0, true)
    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Crafting, Player(9), OSKEY_K, 0, true)
    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Crafting, Player(10), OSKEY_K, 0, true)

    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Endless_Rage_Press_R, Player(4), OSKEY_R, 0, true)
    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Endless_Rage_Press_R, Player(5), OSKEY_R, 0, true)
    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Endless_Rage_Press_R, Player(6), OSKEY_R, 0, true)
    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Endless_Rage_Press_R, Player(7), OSKEY_R, 0, true)
    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Endless_Rage_Press_R, Player(8), OSKEY_R, 0, true)
    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Endless_Rage_Press_R, Player(9), OSKEY_R, 0, true)
    // call BlzTriggerRegisterPlayerKeyEvent(gg_trg_Endless_Rage_Press_R, Player(10), OSKEY_R, 0, true)
endfunction

//===========================================================================
function InitTrig_Keyboard_Reg takes nothing returns nothing
    set gg_trg_Keyboard_Reg = CreateTrigger(  )
    call TriggerRegisterTimerEventSingle( gg_trg_Keyboard_Reg, 0.01 )
    call TriggerAddAction( gg_trg_Keyboard_Reg, function Trig_Keyboard_Reg_Actions )
endfunction


