library SampleDialogSystem initializer Init requires HeroSelectionCallbacks

    globals
        private dialog array Dialog
        private button array Button
        private trigger T = CreateTrigger()
    endglobals

    // --- Main Button Handler ---
    private function OnButtonClick takes nothing returns boolean
        local button b = GetClickedButton()
        local player p = GetTriggerPlayer()
        local integer pid = GetPlayerId(p)
        local integer curSlot = GetSlotForHero(udg_Heroes[GetPlayerHeroNumber(p)])

        call DebugCritical("Current Slot: " + I2S(curSlot))
        
        if(b == Button[(pid * 12) + 0]) then
            // Save Character
            call SaveCharToSlot(udg_Heroes[GetPlayerHeroNumber(p)], curSlot) 
            call DisplayTextToPlayer(p, 0, 0, "|cffffcc00[" + I2S(curSlot) + "]|r " + SaveHelper.GetUnitTitle(udg_Heroes[GetPlayerHeroNumber(p)]))
        
        elseif(b == Button[(pid * 12) + 1]) then
            // New Character
            if(udg_GameMode == "Normal") then
                call SaveCharToSlot(udg_Heroes[GetPlayerHeroNumber(p)], curSlot)
            endif
            call DisplayTextToPlayer(p, 0, 0, "|cffffcc00[" + I2S(curSlot) + "]|r " + SaveHelper.GetUnitTitle(udg_Heroes[GetPlayerHeroNumber(p)]))
            call TriggerExecute(gg_trg_REROLL)
        endif
    
        return false
    endfunction


    private function ShowMenu takes nothing returns boolean
        local player p = GetTriggerPlayer()
        local integer pid = GetPlayerId(p)

        call DialogClear(Dialog[(pid * 12) + 0])
        call DialogSetMessage(Dialog[(pid * 12) + 0], "|cffff8000Main Menu|r")
        if not isFadingOut[pid] then 
            if(udg_GameMode == "PVP") then
                if not isInHeroSelection[pid] then
                    set Button[(pid* 12) + 1] = DialogAddButton(Dialog[(pid * 12) + 0], "|cffffffffN|r|cffffcc00ew Character|r", 78)
                endif
            elseif(udg_GameMode == "Normal") then
                if not isInHeroSelection[pid] then
                    set Button[(pid* 12) + 1] = DialogAddButton(Dialog[(pid * 12) + 0], "|cffffffffN|r|cffffcc00ew Character|r", 78)
                    set Button[(pid * 12) + 0] = DialogAddButton(Dialog[(pid * 12) + 0], "|cffffffffS|rave Character", 83)
                endif
            endif
            call DialogAddButton(Dialog[(pid * 12) + 0], "|cffff8000|cffffffffC|rlose", 67)
            call DialogDisplay(p, Dialog[(pid * 12) + 0], GetLocalPlayer() == p)
        endif
        return false
    endfunction

    private function CloseMenu takes nothing returns boolean
        local player p = GetTriggerPlayer()
        local integer pid = GetPlayerId(p)
        if(GetLocalPlayer() == p) then
            call DialogDisplay(p, Dialog[(pid * 12) + 0], false)
        endif
        return false
    endfunction

    private function InitDialog takes nothing returns nothing
        local integer i = 0
        local trigger t = CreateTrigger()
        local User u
        
        loop
            exitwhen i == User.AmountPlaying
            set u = User.fromPlaying(i)

            // Main Menu dialog
            set Dialog[(u.id * 12) + 0] = DialogCreate()
            call TriggerRegisterDialogEvent(t, Dialog[(u.id * 12) + 0])
            
            set i = i + 1
        endloop
        
        call TriggerAddCondition(t, Filter(function OnButtonClick))
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local trigger t_close = CreateTrigger()
        local integer i = 0
        
        loop
            // call BlzTriggerRegisterPlayerKeyEvent(t, Player(i), OSKEY_V, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(t, Player(i), OSKEY_C, 0, true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-load", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-save", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-new", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-menu", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-reroll", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-repick", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-rr", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-delete", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-reset", true)
            call BlzTriggerRegisterPlayerKeyEvent(t_close, Player(i), OSKEY_ESCAPE, 0, true)
            set i = i + 1
            exitwhen i == bj_MAX_PLAYER_SLOTS
        endloop
        
        call TriggerAddCondition(t, Filter(function ShowMenu))
        call TriggerAddCondition(t_close, Filter(function CloseMenu))
        call TimerStart(CreateTimer(), 0, false, function InitDialog)
    endfunction
endlibrary
