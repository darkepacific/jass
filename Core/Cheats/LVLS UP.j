function Trig_LVLS_UP_Actions takes nothing returns nothing
    local integer i = 0
    if SubStringBJ(GetEventPlayerChatString(), 5, 5) == " " or SubStringBJ(GetEventPlayerChatString(), 5, 5) == "a" then
        set udg_HeroStatCalc = S2I(SubStringBJ(GetEventPlayerChatString(), 6, 7))
    else
        set udg_HeroStatCalc = S2I(SubStringBJ(GetEventPlayerChatString(), 5, 6))
    endif
    if udg_HeroStatCalc == 0 then
        set udg_HeroStatCalc = udg_FINALS_LEVEL_3
    endif
    if SubStringBJ(GetEventPlayerChatString(), 5, 5) == "m" then
	set udg_HeroStatCalc = 60
    endif
    
    loop
        exitwhen i > 7
        if ( GetHeroLevel(udg_Heroes[i]) < udg_HeroStatCalc ) then
            call SetHeroLevelBJ( udg_Heroes[i], udg_HeroStatCalc, true )
        endif
            set i = i + 1
    endloop
endfunction

//===========================================================================
function InitTrig_LVLS_UP takes nothing returns nothing
    set gg_trg_LVLS_UP = CreateTrigger(  )
    call TriggerRegisterPlayerChatEvent( gg_trg_LVLS_UP, Player(2), "-lvl", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_LVLS_UP, Player(7), "-lvl", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_LVLS_UP, Player(8), "-lvl", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_LVLS_UP, Player(9), "-lvl", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_LVLS_UP, Player(4), "-lvl", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_LVLS_UP, Player(5), "-lvl", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_LVLS_UP, Player(6), "-lvl", false )
    call TriggerRegisterPlayerChatEvent( gg_trg_LVLS_UP, Player(10), "-lvl", false )
    call TriggerAddAction( gg_trg_LVLS_UP, function Trig_LVLS_UP_Actions )
endfunction
