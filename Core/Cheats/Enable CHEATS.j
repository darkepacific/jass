function Trig_ENABLE_Cheats_Actions takes nothing returns nothing
    call EnableTrigger( gg_trg_EQUIP )
    call EnableTrigger( gg_trg_LVLS_UP )
    call EnableTrigger( gg_trg_LVLS_DWN )
    call EnableTrigger( gg_trg_LVLS_START )
    call EnableTrigger( gg_trg_GOLD )
    call EnableTrigger( gg_trg_VISION_ON )
    call EnableTrigger( gg_trg_KILL )
    call EnableTrigger( gg_trg_KILL_GATE )
    call EnableTrigger( gg_trg_MAKE_WORGEN )
    call EnableTrigger( gg_trg_EQUIP )
    call EnableTrigger( gg_trg_BOOTS )
    call EnableTrigger( gg_trg_STARTSOG )
    call EnableTrigger( gg_trg_FOOD )
    call EnableTrigger( gg_trg_TELE )
    call EnableTrigger( gg_trg_RESET_CDs )
    call EnableTrigger( gg_trg_QUICK_DEATHS )
    call EnableTrigger( gg_trg_FORCESPAWN )
    call EnableTrigger(gg_trg_TEST)
    call EnableTrigger(gg_trg_HEAL)
    //call EnableTrigger(gg_trg_Kael_Test)
endfunction

//===========================================================================
function InitTrig_ENABLE_Cheats takes nothing returns nothing
    set gg_trg_ENABLE_Cheats = CreateTrigger(  )
    call TriggerRegisterPlayerChatEvent( gg_trg_ENABLE_Cheats, Player(2), "-en", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_ENABLE_Cheats, Player(7), "-en", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_ENABLE_Cheats, Player(8), "-en", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_ENABLE_Cheats, Player(9), "-en", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_ENABLE_Cheats, Player(4), "-en", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_ENABLE_Cheats, Player(5), "-en", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_ENABLE_Cheats, Player(6), "-en", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_ENABLE_Cheats, Player(10), "-en", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_ENABLE_Cheats, Player(12), "-en", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_ENABLE_Cheats, Player(13), "-en", false )
    call TriggerAddAction( gg_trg_ENABLE_Cheats, function Trig_ENABLE_Cheats_Actions )
endfunction

