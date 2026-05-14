library SampleDialogSystem initializer Init requires HeroSelectionCallbacks, MultiPageInventorySystem, TasItemBag

    globals
        private dialog array Dialog
        private button array Button
        private boolean array MenuOpen

        private oskeytype array MenuHotkey
        private oskeytype array PageHotkey
        private oskeytype array BagHotkey
        private oskeytype array SellHotkey
        private string array MenuHotkeyLabel
        private string array PageHotkeyLabel
        private string array BagHotkeyLabel
        private string array SellHotkeyLabel
        private boolean array ListenMenu
        private boolean array ListenPage
        private boolean array ListenBag
        private boolean array ListenSell
        private boolean array ConfigOpen

        private trigger trigHotkeys = CreateTrigger()
        private trigger trigCfgMenu = CreateTrigger()
        private trigger trigCfgPage = CreateTrigger()
        private trigger trigCfgBag = CreateTrigger()
        private trigger trigCfgSell = CreateTrigger()
        private trigger trigCfgClose = CreateTrigger()

        private framehandle hotkeyConfigPanel = null
        private framehandle hotkeyConfigTitleText = null
        private framehandle hotkeyConfigHintText = null
        private framehandle hotkeyConfigBtnMenu = null
        private framehandle hotkeyConfigBtnPage = null
        private framehandle hotkeyConfigBtnBag = null
        private framehandle hotkeyConfigBtnSell = null
    endglobals

    private function OsKeyToString takes oskeytype key returns string
        if key == OSKEY_A then
            return "A"
        elseif key == OSKEY_B then
            return "B"
        elseif key == OSKEY_C then
            return "C"
        elseif key == OSKEY_D then
            return "D"
        elseif key == OSKEY_E then
            return "E"
        elseif key == OSKEY_F then
            return "F"
        elseif key == OSKEY_G then
            return "G"
        elseif key == OSKEY_H then
            return "H"
        elseif key == OSKEY_I then
            return "I"
        elseif key == OSKEY_J then
            return "J"
        elseif key == OSKEY_K then
            return "K"
        elseif key == OSKEY_L then
            return "L"
        elseif key == OSKEY_M then
            return "M"
        elseif key == OSKEY_N then
            return "N"
        elseif key == OSKEY_O then
            return "O"
        elseif key == OSKEY_P then
            return "P"
        elseif key == OSKEY_Q then
            return "Q"
        elseif key == OSKEY_R then
            return "R"
        elseif key == OSKEY_S then
            return "S"
        elseif key == OSKEY_T then
            return "T"
        elseif key == OSKEY_U then
            return "U"
        elseif key == OSKEY_V then
            return "V"
        elseif key == OSKEY_W then
            return "W"
        elseif key == OSKEY_X then
            return "X"
        elseif key == OSKEY_Y then
            return "Y"
        elseif key == OSKEY_Z then
            return "Z"
        elseif key == OSKEY_0 then
            return "0"
        elseif key == OSKEY_1 then
            return "1"
        elseif key == OSKEY_2 then
            return "2"
        elseif key == OSKEY_3 then
            return "3"
        elseif key == OSKEY_4 then
            return "4"
        elseif key == OSKEY_5 then
            return "5"
        elseif key == OSKEY_6 then
            return "6"
        elseif key == OSKEY_7 then
            return "7"
        elseif key == OSKEY_8 then
            return "8"
        elseif key == OSKEY_9 then
            return "9"
        elseif key == OSKEY_ESCAPE then
            return "Esc"
        endif
        return "?"
    endfunction

    private function ClearListenState takes integer pid returns nothing
        set ListenMenu[pid] = false
        set ListenPage[pid] = false
        set ListenBag[pid] = false
        set ListenSell[pid] = false
    endfunction

    private function CloseMenuForPlayer takes player p returns nothing
        local integer pid = GetPlayerId(p)
        set MenuOpen[pid] = false
        if GetLocalPlayer() == p then
            call DialogDisplay(p, Dialog[(pid * 12) + 0], false)
        endif
    endfunction

    private function ShowMenuForPlayer takes player p returns nothing
        local integer pid = GetPlayerId(p)
        local string closeLabel

        call DialogClear(Dialog[(pid * 12) + 0])
        call DialogSetMessage(Dialog[(pid * 12) + 0], "|cffff8000Main Menu|r")
        if isFadingOut[pid] then
            set MenuOpen[pid] = false
            return
        endif

        if udg_GameMode == "PVP" then
            if not isInHeroSelection[pid] then
                set Button[(pid * 12) + 1] = DialogAddButton(Dialog[(pid * 12) + 0], "|cffffffffN|r|cffffcc00ew Hero|r", 78)
            endif
        elseif udg_GameMode == "Normal" then
            if not isInHeroSelection[pid] then
                set Button[(pid * 12) + 1] = DialogAddButton(Dialog[(pid * 12) + 0], "|cffffffffN|r|cffffcc00ew/Swap Hero|r", 78)
                set Button[(pid * 12) + 0] = DialogAddButton(Dialog[(pid * 12) + 0], "|cffffffffS|rave Hero", 83)
            endif
        endif

        set Button[(pid * 12) + 2] = DialogAddButton(Dialog[(pid * 12) + 0], "|cffffcc00Select|r |cffffffffH|r|cffffcc00ot keys|r|r", 72)
        set closeLabel = "|cffff8000|cffffffffC|rlose|r"
        // if MenuHotkeyLabel[pid] == "" then
        //     set closeLabel = "|cffff8000Close|r"
        // elseif MenuHotkeyLabel[pid] == "C" then
        //     set closeLabel = "|cffff8000|cffffffffC|rlose"
        // else
        //     set closeLabel = "|cffff8000(|cffffffff" + MenuHotkeyLabel[pid] + "|r) Close"
        // endif
        set Button[(pid * 12) + 3] = DialogAddButton(Dialog[(pid * 12) + 0], closeLabel, 67)
        call DialogDisplay(p, Dialog[(pid * 12) + 0], GetLocalPlayer() == p)
        set MenuOpen[pid] = true
        set closeLabel = null
    endfunction

    private function ToggleMenuForPlayer takes player p returns nothing
        local integer pid = GetPlayerId(p)
        if MenuOpen[pid] then
            call CloseMenuForPlayer(p)
        else
            call ShowMenuForPlayer(p)
        endif
    endfunction

    private function ToggleHotkeyConfig takes player whichPlayer, boolean show returns nothing
        local integer pid = GetPlayerId(whichPlayer)
        local string menuCap
        local string pageCap
        local string bagCap
        local string sellCap

        if MenuHotkeyLabel[pid] == "" then
            set menuCap = "Set Menu (Unbound)"
        else
            set menuCap = "Set Menu (" + MenuHotkeyLabel[pid] + ")"
        endif
        if PageHotkeyLabel[pid] == "" then
            set pageCap = "Set Swap Page (Unbound)"
        else
            set pageCap = "Set Swap Page (" + PageHotkeyLabel[pid] + ")"
        endif
        if BagHotkeyLabel[pid] == "" then
            set bagCap = "Set Bag (Unbound)"
        else
            set bagCap = "Set Bag (" + BagHotkeyLabel[pid] + ")"
        endif
        if SellHotkeyLabel[pid] == "" then
            set sellCap = "Set Sell (Unbound)"
        else
            set sellCap = "Set Sell (" + SellHotkeyLabel[pid] + ")"
        endif

        set ConfigOpen[pid] = show
        if not show then
            call ClearListenState(pid)
        endif
        if GetLocalPlayer() == whichPlayer then
            call BlzFrameSetVisible(hotkeyConfigPanel, show)
            call BlzFrameSetText(hotkeyConfigBtnMenu, menuCap)
            call BlzFrameSetText(hotkeyConfigBtnPage, pageCap)
            call BlzFrameSetText(hotkeyConfigBtnBag, bagCap)
            call BlzFrameSetText(hotkeyConfigBtnSell, sellCap)
            call BlzFrameSetText(hotkeyConfigHintText, "Click a button, then press a key.")
        endif
    endfunction

    private function StartListen takes player whichPlayer, integer whichAction returns nothing
        local integer pid = GetPlayerId(whichPlayer)
        call ClearListenState(pid)
        set ListenMenu[pid] = whichAction == 1
        set ListenPage[pid] = whichAction == 2
        set ListenBag[pid] = whichAction == 3
        set ListenSell[pid] = whichAction == 4
        if GetLocalPlayer() == whichPlayer then
            if whichAction == 1 then
                call BlzFrameSetText(hotkeyConfigHintText, "|cffffee88Press a key for: Main Menu|r")
            elseif whichAction == 2 then
                call BlzFrameSetText(hotkeyConfigHintText, "|cffffee88Press a key for: Swap Page|r")
            elseif whichAction == 3 then
                call BlzFrameSetText(hotkeyConfigHintText, "|cffffee88Press a key for: Bag Toggle|r")
            else
                call BlzFrameSetText(hotkeyConfigHintText, "|cffffee88Press a key for: Sell Mode|r")
            endif
        endif
    endfunction

    private function ApplyKey takes player whichPlayer, oskeytype key returns nothing
        local integer pid = GetPlayerId(whichPlayer)
        local string label = OsKeyToString(key)

        if ListenMenu[pid] then
            if MenuHotkey[pid] != key then
                set MenuHotkey[pid] = key
                set MenuHotkeyLabel[pid] = label
            endif
            if PageHotkey[pid] == key then
                set PageHotkey[pid] = null
                set PageHotkeyLabel[pid] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Swap Page (duplicate).|r")
            endif
            if BagHotkey[pid] == key then
                set BagHotkey[pid] = null
                set BagHotkeyLabel[pid] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Bag (duplicate).|r")
            endif
            if SellHotkey[pid] == key then
                set SellHotkey[pid] = null
                set SellHotkeyLabel[pid] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Sell (duplicate).|r")
            endif
        elseif ListenPage[pid] then
            if MenuHotkey[pid] == key then
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00That key is reserved for Menu. Pick a different Swap Page key.|r")
                call ClearListenState(pid)
                call ToggleHotkeyConfig(whichPlayer, true)
                return
            endif
            if PageHotkey[pid] != key then
                set PageHotkey[pid] = key
                set PageHotkeyLabel[pid] = label
            endif
            if BagHotkey[pid] == key then
                set BagHotkey[pid] = null
                set BagHotkeyLabel[pid] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Bag (duplicate).|r")
            endif
            if SellHotkey[pid] == key then
                set SellHotkey[pid] = null
                set SellHotkeyLabel[pid] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Sell (duplicate).|r")
            endif
        elseif ListenBag[pid] then
            if MenuHotkey[pid] == key then
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00That key is reserved for Menu. Pick a different Bag key.|r")
                call ClearListenState(pid)
                call ToggleHotkeyConfig(whichPlayer, true)
                return
            endif
            if BagHotkey[pid] != key then
                set BagHotkey[pid] = key
                set BagHotkeyLabel[pid] = label
            endif
            if PageHotkey[pid] == key then
                set PageHotkey[pid] = null
                set PageHotkeyLabel[pid] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Swap Page (duplicate).|r")
            endif
            if SellHotkey[pid] == key then
                set SellHotkey[pid] = null
                set SellHotkeyLabel[pid] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Sell (duplicate).|r")
            endif
        elseif ListenSell[pid] then
            if MenuHotkey[pid] == key then
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00That key is reserved for Menu. Pick a different Sell key.|r")
                call ClearListenState(pid)
                call ToggleHotkeyConfig(whichPlayer, true)
                return
            endif
            if SellHotkey[pid] != key then
                set SellHotkey[pid] = key
                set SellHotkeyLabel[pid] = label
            endif
            if PageHotkey[pid] == key then
                set PageHotkey[pid] = null
                set PageHotkeyLabel[pid] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Swap Page (duplicate).|r")
            endif
            if BagHotkey[pid] == key then
                set BagHotkey[pid] = null
                set BagHotkeyLabel[pid] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Bag (duplicate).|r")
            endif
        endif

        call ClearListenState(pid)
        call MPInventorySetNextPageHotkeyLabel(whichPlayer, PageHotkeyLabel[pid])
        call TasItemBagSetToggleHotkeyLabel(whichPlayer, BagHotkeyLabel[pid])
        call TasItemBagSetSellHotkeyLabel(whichPlayer, SellHotkeyLabel[pid])
        call ToggleHotkeyConfig(whichPlayer, true)
    endfunction

    private function HotkeyRouter takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pid = GetPlayerId(p)
        local oskeytype key = BlzGetTriggerPlayerKey()

        if key == OSKEY_ESCAPE then
            if ConfigOpen[pid] then
                call ToggleHotkeyConfig(p, false)
            endif
            set p = null
            return
        endif

        if ListenMenu[pid] or ListenPage[pid] or ListenBag[pid] or ListenSell[pid] then
            call ApplyKey(p, key)
            set p = null
            return
        endif

        if ConfigOpen[pid] then
            set p = null
            return
        endif

        if MenuHotkey[pid] != null and key == MenuHotkey[pid] then
            call ToggleMenuForPlayer(p)
        elseif PageHotkey[pid] != null and key == PageHotkey[pid] then
            call MPInventoryCycleToNextPage(p)
        elseif BagHotkey[pid] != null and key == BagHotkey[pid] then
            call TasItemBagToggleForPlayer(p, false)
        elseif SellHotkey[pid] != null and key == SellHotkey[pid] then
            call TasItemBagSellSelectedForPlayer(p)
        endif

        set p = null
    endfunction

    private function RegisterAllHotkeys takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= bj_MAX_PLAYER_SLOTS
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_A, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_B, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_C, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_D, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_E, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_F, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_G, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_H, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_I, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_J, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_K, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_L, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_M, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_N, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_O, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_P, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_Q, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_R, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_S, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_T, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_U, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_V, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_W, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_X, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_Y, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_Z, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_0, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_1, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_2, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_3, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_4, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_5, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_6, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_7, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_8, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_9, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_ESCAPE, 0, true)
            set i = i + 1
        endloop
        call TriggerAddAction(trigHotkeys, function HotkeyRouter)
    endfunction

    private function ConfigBtnMenuClick takes nothing returns nothing
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 211), false)
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 211), true)
        call StartListen(GetTriggerPlayer(), 1)
    endfunction

    private function ConfigBtnPageClick takes nothing returns nothing
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 212), false)
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 212), true)
        call StartListen(GetTriggerPlayer(), 2)
    endfunction

    private function ConfigBtnBagClick takes nothing returns nothing
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 213), false)
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 213), true)
        call StartListen(GetTriggerPlayer(), 3)
    endfunction

    private function ConfigBtnSellClick takes nothing returns nothing
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 214), false)
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 214), true)
        call StartListen(GetTriggerPlayer(), 4)
    endfunction

    private function ConfigBtnCloseClick takes nothing returns nothing
        call ToggleHotkeyConfig(GetTriggerPlayer(), false)
    endfunction

    private function CreateHotkeyConfigUI takes nothing returns nothing
        local framehandle hotkeyConfigBtnClose

        set hotkeyConfigPanel = BlzCreateFrame("QuestButtonBaseTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 210)
        set hotkeyConfigTitleText = BlzCreateFrameByType("TEXT", "DlgHotkeyCfgTitle", hotkeyConfigPanel, "", 210)
        set hotkeyConfigHintText = BlzCreateFrameByType("TEXT", "DlgHotkeyCfgHint", hotkeyConfigPanel, "", 210)
        set hotkeyConfigBtnMenu = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 211)
        set hotkeyConfigBtnPage = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 212)
        set hotkeyConfigBtnBag = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 213)
        set hotkeyConfigBtnSell = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 214)
        set hotkeyConfigBtnClose = BlzCreateFrameByType("GLUETEXTBUTTON", "DlgHotkeyCfgCloseButton", hotkeyConfigPanel, "ScriptDialogButton", 0)

        call BlzFrameSetSize(hotkeyConfigPanel, 0.26, 0.17)
        call BlzFrameSetAbsPoint(hotkeyConfigPanel, FRAMEPOINT_CENTER, 0.40, 0.30)
        call BlzFrameSetVisible(hotkeyConfigPanel, false)
        call BlzFrameSetAlpha(hotkeyConfigPanel, 235)

        call BlzFrameSetText(hotkeyConfigTitleText, "|cffffcc00Hot Keys|r")
        call BlzFrameSetPoint(hotkeyConfigTitleText, FRAMEPOINT_TOPLEFT, hotkeyConfigPanel, FRAMEPOINT_TOPLEFT, 0.01, -0.01)
        call BlzFrameSetPoint(hotkeyConfigBtnClose, FRAMEPOINT_TOPRIGHT, hotkeyConfigPanel, FRAMEPOINT_TOPRIGHT, -0.002, -0.002)
        call BlzFrameSetSize(hotkeyConfigBtnClose, 0.03, 0.03)
        call BlzFrameSetText(hotkeyConfigBtnClose, "X")

        call BlzFrameSetPoint(hotkeyConfigBtnMenu, FRAMEPOINT_TOPLEFT, hotkeyConfigPanel, FRAMEPOINT_TOPLEFT, 0.01, -0.035)
        call BlzFrameSetPoint(hotkeyConfigBtnPage, FRAMEPOINT_TOPLEFT, hotkeyConfigBtnMenu, FRAMEPOINT_BOTTOMLEFT, 0.00, -0.006)
        call BlzFrameSetPoint(hotkeyConfigBtnBag, FRAMEPOINT_TOPLEFT, hotkeyConfigBtnPage, FRAMEPOINT_BOTTOMLEFT, 0.00, -0.006)
        call BlzFrameSetPoint(hotkeyConfigBtnSell, FRAMEPOINT_TOPLEFT, hotkeyConfigBtnBag, FRAMEPOINT_BOTTOMLEFT, 0.00, -0.006)

        call BlzFrameSetSize(hotkeyConfigBtnMenu, 0.24, 0.024)
        call BlzFrameSetSize(hotkeyConfigBtnPage, 0.24, 0.024)
        call BlzFrameSetSize(hotkeyConfigBtnBag, 0.24, 0.024)
        call BlzFrameSetSize(hotkeyConfigBtnSell, 0.24, 0.024)
        call BlzFrameSetPoint(hotkeyConfigHintText, FRAMEPOINT_BOTTOMLEFT, hotkeyConfigPanel, FRAMEPOINT_BOTTOMLEFT, 0.01, 0.01)
        call BlzFrameSetText(hotkeyConfigHintText, "Click a button, then press a key.")

        call BlzTriggerRegisterFrameEvent(trigCfgMenu, hotkeyConfigBtnMenu, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgPage, hotkeyConfigBtnPage, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgBag, hotkeyConfigBtnBag, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgSell, hotkeyConfigBtnSell, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgClose, hotkeyConfigBtnClose, FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trigCfgMenu, function ConfigBtnMenuClick)
        call TriggerAddAction(trigCfgPage, function ConfigBtnPageClick)
        call TriggerAddAction(trigCfgBag, function ConfigBtnBagClick)
        call TriggerAddAction(trigCfgSell, function ConfigBtnSellClick)
        call TriggerAddAction(trigCfgClose, function ConfigBtnCloseClick)

        set hotkeyConfigBtnClose = null
    endfunction

    private function InitDefaultHotkeys takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= bj_MAX_PLAYER_SLOTS
            set MenuHotkey[i] = OSKEY_C
            set MenuHotkeyLabel[i] = "C"
            set PageHotkey[i] = OSKEY_Z
            set PageHotkeyLabel[i] = "Z"
            set BagHotkey[i] = OSKEY_X
            set BagHotkeyLabel[i] = "X"
            set SellHotkey[i] = OSKEY_G
            set SellHotkeyLabel[i] = "G"
            call TasItemBagSetToggleHotkeyLabel(Player(i), BagHotkeyLabel[i])
            call TasItemBagSetSellHotkeyLabel(Player(i), SellHotkeyLabel[i])
            set ConfigOpen[i] = false
            set MenuOpen[i] = false
            call ClearListenState(i)
            set i = i + 1
        endloop
    endfunction

    // --- Main Button Handler ---
    private function OnButtonClick takes nothing returns boolean
        local button b = GetClickedButton()
        local player p = GetTriggerPlayer()
        local integer pid = GetPlayerId(p)
        local integer curSlot = GetSlotForHero(udg_Heroes[GetPlayerHeroNumber(p)])

        call DebugCritical("Current Slot: " + I2S(curSlot))
        
        if b == Button[(pid * 12) + 0] then
            call SaveCharToSlot(udg_Heroes[GetPlayerHeroNumber(p)], curSlot)
            call DisplayTextToPlayer(p, 0, 0, "|cffffcc00[" + I2S(curSlot) + "]|r " + SaveHelper.GetUnitTitle(udg_Heroes[GetPlayerHeroNumber(p)]))
        elseif b == Button[(pid * 12) + 1] then
            if udg_GameMode == "Normal" then
                call SaveCharToSlot(udg_Heroes[GetPlayerHeroNumber(p)], curSlot)
            endif
            call DisplayTextToPlayer(p, 0, 0, "|cffffcc00[" + I2S(curSlot) + "]|r " + SaveHelper.GetUnitTitle(udg_Heroes[GetPlayerHeroNumber(p)]))
            call TriggerExecute(gg_trg_REROLL)
        elseif b == Button[(pid * 12) + 2] then
            call CloseMenuForPlayer(p)
            call ToggleHotkeyConfig(p, true)
        elseif b == Button[(pid * 12) + 3] then
            call CloseMenuForPlayer(p)
        endif
    
        return false
    endfunction

    private function ShowMenu takes nothing returns boolean
        call ShowMenuForPlayer(GetTriggerPlayer())
        return false
    endfunction

    private function CloseMenu takes nothing returns boolean
        call CloseMenuForPlayer(GetTriggerPlayer())
        return false
    endfunction

    private function InitDialog takes nothing returns nothing
        local integer i = 0
        local trigger t = CreateTrigger()
        local User u
        
        loop
            exitwhen i == User.AmountPlaying
            set u = User.fromPlaying(i)
            set Dialog[(u.id * 12) + 0] = DialogCreate()
            call TriggerRegisterDialogEvent(t, Dialog[(u.id * 12) + 0])
            set i = i + 1
        endloop
        
        call TriggerAddCondition(t, Filter(function OnButtonClick))
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local trigger tClose = CreateTrigger()
        local integer i = 0

        call InitDefaultHotkeys()
        call CreateHotkeyConfigUI()
        call RegisterAllHotkeys()
        
        loop
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-load", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-save", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-new", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-menu", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-reroll", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-repick", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-rr", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-delete", true)
            call TriggerRegisterPlayerChatEvent(t, Player(i), "-reset", true)
            call BlzTriggerRegisterPlayerKeyEvent(tClose, Player(i), OSKEY_ESCAPE, 0, true)
            set i = i + 1
            exitwhen i == bj_MAX_PLAYER_SLOTS
        endloop
        
        call TriggerAddCondition(t, Filter(function ShowMenu))
        call TriggerAddCondition(tClose, Filter(function CloseMenu))
        call TimerStart(CreateTimer(), 0, false, function InitDialog)
    endfunction
endlibrary
