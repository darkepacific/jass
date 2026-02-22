function Trig_UP_Actions takes nothing returns nothing
    local string chat = GetEventPlayerChatString()
    local integer n = StringLength(chat)
    local string arg = ""
    local integer v

    // allow "-up20" and "-up 20"
    if n > 3 then
        set arg = SubString(chat, 3, n)
        if StringLength(arg) > 0 and SubString(arg, 0, 1) == " " then
            set arg = SubString(arg, 1, StringLength(arg))
        endif
    endif

    set v = S2I(arg)
    if arg != "" and v != 0 then
        if v < 1 then
            set v = 1
        endif
        set whosyourdaddy = I2R(v)
        return
    endif

    if whosyourdaddy < 1.0 then
        set whosyourdaddy = 1.0
    endif
    set whosyourdaddy = whosyourdaddy + 1.0
    call Debug("Cheat UP: " + R2S(whosyourdaddy))
endfunction

//===========================================================================
function InitTrig_UP takes nothing returns nothing
    set gg_trg_UP = CreateTrigger(  )
    call TriggerRegisterPlayerChatEvent( gg_trg_UP, Player(2), "-up", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_UP, Player(7), "-up", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_UP, Player(8), "-up", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_UP, Player(9), "-up", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_UP, Player(4), "-up", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_UP, Player(5), "-up", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_UP, Player(6), "-up", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_UP, Player(10), "-up", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_UP, Player(12), "-up", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_UP, Player(13), "-up", false )
    call TriggerAddAction( gg_trg_UP, function Trig_UP_Actions )
endfunction
