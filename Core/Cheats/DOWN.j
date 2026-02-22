function Trig_DOWN_Actions takes nothing returns nothing
    set whosyourdaddy = 1.0
endfunction

//===========================================================================
function InitTrig_DOWN takes nothing returns nothing
    set gg_trg_DOWN = CreateTrigger(  )
    call TriggerRegisterPlayerChatEvent( gg_trg_DOWN, Player(2), "-do", true )
    call TriggerRegisterPlayerChatEvent( gg_trg_DOWN, Player(7), "-do", true )
    call TriggerRegisterPlayerChatEvent( gg_trg_DOWN, Player(8), "-do", true )
    call TriggerRegisterPlayerChatEvent( gg_trg_DOWN, Player(9), "-do", true )
    call TriggerRegisterPlayerChatEvent( gg_trg_DOWN, Player(4), "-do", true )
    call TriggerRegisterPlayerChatEvent( gg_trg_DOWN, Player(5), "-do", true )
    call TriggerRegisterPlayerChatEvent( gg_trg_DOWN, Player(6), "-do", true )
    call TriggerRegisterPlayerChatEvent( gg_trg_DOWN, Player(10), "-do", true )
    call TriggerRegisterPlayerChatEvent( gg_trg_DOWN, Player(12), "-do", true )
    call TriggerRegisterPlayerChatEvent( gg_trg_DOWN, Player(13), "-do", true )
    call TriggerAddAction( gg_trg_DOWN, function Trig_DOWN_Actions )
endfunction
