function Trig_DISABLE_Cheats_Actions takes nothing returns nothing
    call DisableTrigger( gg_trg_EQUIP )
    call DisableTrigger( gg_trg_LVLS_UP )
    call DisableTrigger( gg_trg_LVLS_DWN )
    call DisableTrigger( gg_trg_LVLS_START )
    call DisableTrigger( gg_trg_GOLD )
    call DisableTrigger( gg_trg_VISION_ON )
    call DisableTrigger( gg_trg_KILL )
    call DisableTrigger( gg_trg_KILL_GATE )
    call DisableTrigger( gg_trg_MAKE_WORGEN )
    call DisableTrigger( gg_trg_EQUIP )
    call DisableTrigger( gg_trg_BOOTS )
    call DisableTrigger( gg_trg_STARTSOG )
    call DisableTrigger( gg_trg_FOOD )
    call DisableTrigger( gg_trg_TELE )
    call DisableTrigger( gg_trg_RESET_CDs )
    call DisableTrigger( gg_trg_QUICK_DEATHS )
    call DisableTrigger( gg_trg_FORCESPAWN )
    call DisableTrigger(gg_trg_TEST)
    call DisableTrigger(gg_trg_HEAL)
endfunction

//===========================================================================
function InitTrig_DISABLE_Cheats takes nothing returns nothing
    set gg_trg_DISABLE_Cheats = CreateTrigger(  )
    call TriggerRegisterPlayerChatEvent( gg_trg_DISABLE_Cheats, Player(2), "-dis", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_DISABLE_Cheats, Player(7), "-dis", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_DISABLE_Cheats, Player(8), "-dis", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_DISABLE_Cheats, Player(9), "-dis", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_DISABLE_Cheats, Player(4), "-dis", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_DISABLE_Cheats, Player(5), "-dis", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_DISABLE_Cheats, Player(6), "-dis", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_DISABLE_Cheats, Player(10), "-dis", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_DISABLE_Cheats, Player(12), "-dis", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_DISABLE_Cheats, Player(13), "-dis", false )
    call TriggerAddAction( gg_trg_DISABLE_Cheats, function Trig_DISABLE_Cheats_Actions )
endfunction

