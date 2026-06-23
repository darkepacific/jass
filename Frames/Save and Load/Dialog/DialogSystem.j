library SampleDialogSystem initializer Init requires HeroSelectionCallbacks, MultiPageInventorySystem, TasItemBag, SaveFile, FileIO, WorldMapUI

    globals
        private dialog array Dialog
        private button array Button
        private boolean array MenuOpen

        private oskeytype array MenuHotkey
        private oskeytype array PageHotkey
        private oskeytype array BagHotkey
        private oskeytype array SellHotkey
        private oskeytype array MapHotkey
        private oskeytype array CraftHotkey
        private string array MenuHotkeyLabel
        private string array PageHotkeyLabel
        private string array BagHotkeyLabel
        private string array SellHotkeyLabel
        private string array MapHotkeyLabel
        private string array CraftHotkeyLabel
        private boolean array HotkeyConfigInventoryPage
        private boolean array ListenMenu
        private boolean array ListenPage
        private boolean array ListenBag
        private boolean array ListenSell
        private boolean array ListenMap
        private boolean array ListenCraft
        private integer array ListenInventoryQuickCastSlot
        private boolean array ConfigOpen
        private constant string HOTKEY_SETTINGS_HEADER = "HOTKEYS1"

        private trigger trigHotkeys = CreateTrigger()
        private trigger trigCfgInventory = CreateTrigger()
        private trigger trigCfgMenu = CreateTrigger()
        private trigger trigCfgPage = CreateTrigger()
        private trigger trigCfgBag = CreateTrigger()
        private trigger trigCfgSell = CreateTrigger()
        private trigger trigCfgMap = CreateTrigger()
        private trigger trigCfgCraft = CreateTrigger()
        private trigger trigCfgReset = CreateTrigger()
        private trigger trigCfgQuickUse = CreateTrigger()
        private trigger trigCfgQuickUseBack = CreateTrigger()
        private trigger trigCfgClose = CreateTrigger()
        private trigger trigDialogButtons = CreateTrigger()

        private framehandle hotkeyConfigPanel = null
        private framehandle hotkeyConfigTitleText = null
        private framehandle hotkeyConfigHintText = null
        private framehandle hotkeyConfigBtnInventory = null
        private framehandle hotkeyConfigBtnMenu = null
        private framehandle hotkeyConfigBtnPage = null
        private framehandle hotkeyConfigBtnBag = null
        private framehandle hotkeyConfigBtnSell = null
        private framehandle hotkeyConfigBtnMap = null
        private framehandle hotkeyConfigBtnCraft = null
        private framehandle hotkeyConfigBtnReset = null
        private framehandle array hotkeyConfigBtnQuickUse
        private framehandle hotkeyConfigBtnQuickUseBack = null
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
        elseif key == OSKEY_NUMPAD0 then
            return "Num0"
        elseif key == OSKEY_NUMPAD1 then
            return "Num1"
        elseif key == OSKEY_NUMPAD2 then
            return "Num2"
        elseif key == OSKEY_NUMPAD3 then
            return "Num3"
        elseif key == OSKEY_NUMPAD4 then
            return "Num4"
        elseif key == OSKEY_NUMPAD5 then
            return "Num5"
        elseif key == OSKEY_NUMPAD6 then
            return "Num6"
        elseif key == OSKEY_NUMPAD7 then
            return "Num7"
        elseif key == OSKEY_NUMPAD8 then
            return "Num8"
        elseif key == OSKEY_NUMPAD9 then
            return "Num9"
        elseif key == OSKEY_ESCAPE then
            return "Esc"
        endif
        return "?"
    endfunction

    private function OsKeyToStoredInt takes oskeytype key returns integer
        if key == null then
            return 0
        elseif key == OSKEY_A then
            return $41
        elseif key == OSKEY_B then
            return $42
        elseif key == OSKEY_C then
            return $43
        elseif key == OSKEY_D then
            return $44
        elseif key == OSKEY_E then
            return $45
        elseif key == OSKEY_F then
            return $46
        elseif key == OSKEY_G then
            return $47
        elseif key == OSKEY_H then
            return $48
        elseif key == OSKEY_I then
            return $49
        elseif key == OSKEY_J then
            return $4A
        elseif key == OSKEY_K then
            return $4B
        elseif key == OSKEY_L then
            return $4C
        elseif key == OSKEY_M then
            return $4D
        elseif key == OSKEY_N then
            return $4E
        elseif key == OSKEY_O then
            return $4F
        elseif key == OSKEY_P then
            return $50
        elseif key == OSKEY_Q then
            return $51
        elseif key == OSKEY_R then
            return $52
        elseif key == OSKEY_S then
            return $53
        elseif key == OSKEY_T then
            return $54
        elseif key == OSKEY_U then
            return $55
        elseif key == OSKEY_V then
            return $56
        elseif key == OSKEY_W then
            return $57
        elseif key == OSKEY_X then
            return $58
        elseif key == OSKEY_Y then
            return $59
        elseif key == OSKEY_Z then
            return $5A
        elseif key == OSKEY_0 then
            return $30
        elseif key == OSKEY_1 then
            return $31
        elseif key == OSKEY_2 then
            return $32
        elseif key == OSKEY_3 then
            return $33
        elseif key == OSKEY_4 then
            return $34
        elseif key == OSKEY_5 then
            return $35
        elseif key == OSKEY_6 then
            return $36
        elseif key == OSKEY_7 then
            return $37
        elseif key == OSKEY_8 then
            return $38
        elseif key == OSKEY_9 then
            return $39
        elseif key == OSKEY_NUMPAD0 then
            return $60
        elseif key == OSKEY_NUMPAD1 then
            return $61
        elseif key == OSKEY_NUMPAD2 then
            return $62
        elseif key == OSKEY_NUMPAD3 then
            return $63
        elseif key == OSKEY_NUMPAD4 then
            return $64
        elseif key == OSKEY_NUMPAD5 then
            return $65
        elseif key == OSKEY_NUMPAD6 then
            return $66
        elseif key == OSKEY_NUMPAD7 then
            return $67
        elseif key == OSKEY_NUMPAD8 then
            return $68
        elseif key == OSKEY_NUMPAD9 then
            return $69
        elseif key == OSKEY_ESCAPE then
            return $1B
        endif

        return 0
    endfunction

    private function StoredIntToOsKey takes integer keyValue returns oskeytype
        if (keyValue >= $30 and keyValue <= $39) or (keyValue >= $41 and keyValue <= $5A) or (keyValue >= $60 and keyValue <= $69) or keyValue == $1B then
            return ConvertOsKeyType(keyValue)
        endif
        return null
    endfunction

    private function HotkeyLabelForKey takes oskeytype key returns string
        if key == null then
            return ""
        endif
        return OsKeyToString(key)
    endfunction

    private function HotkeySettingsPath takes player whichPlayer returns string
        return SaveFile.Folder + "Settings\\Hotkeys\\Hotkeys.pld"
    endfunction

    private function HotkeySettingsFactionPath takes player whichPlayer returns string
        return SaveFile.Folder + "Settings\\Hotkeys\\" + SaveFile.Faction(whichPlayer) + "\\Hotkeys.pld"
    endfunction

    private function HotkeySettingsLegacyPath takes player whichPlayer returns string
        return SaveFile.Folder + SaveFile.Faction(whichPlayer) + "\\Hotkeys.pld"
    endfunction

    private function HotkeySettingsModeLegacyPath takes player whichPlayer returns string
        return SaveFile.Folder + SaveFile.ModeFolder() + "\\" + SaveFile.Faction(whichPlayer) + "\\Hotkeys.pld"
    endfunction

    private function TrimTrailingCarriageReturn takes string value returns string
        local integer len = StringLength(value)
        if len > 0 and SubString(value, len - 1, len) == "\r" then
            return SubString(value, 0, len - 1)
        endif
        return value
    endfunction

    private function HotkeySettingsLine takes string contents, integer wantedLine returns string
        local integer len = StringLength(contents)
        local integer currentLine = 1
        local integer startIndex = 0
        local integer i = 0
        local string ch
        local string value

        if wantedLine <= 0 then
            return ""
        endif

        loop
            exitwhen i >= len
            set ch = SubString(contents, i, i + 1)
            if ch == "\n" then
                if currentLine == wantedLine then
                    set value = TrimTrailingCarriageReturn(SubString(contents, startIndex, i))
                    set ch = null
                    return value
                endif
                set currentLine = currentLine + 1
                set startIndex = i + 1
            endif
            set i = i + 1
        endloop

        if currentLine == wantedLine then
            set value = TrimTrailingCarriageReturn(SubString(contents, startIndex, len))
            set ch = null
            return value
        endif

        set ch = null
        return ""
    endfunction

    private function HotkeySettingsStoredInt takes string contents, integer wantedLine returns integer
        local string value = HotkeySettingsLine(contents, wantedLine)
        local integer keyValue

        if value == "" then
            return -1
        endif

        set keyValue = S2I(value)
        if value != I2S(keyValue) then
            return -1
        endif

        return keyValue
    endfunction

    private function RefreshBoundHotkeyLabels takes player whichPlayer returns nothing
        local integer pid

        if whichPlayer == null then
            return
        endif

        set pid = GetPlayerId(whichPlayer)
        call TasItemBagSetMenuHotkeyLabel(whichPlayer, MenuHotkeyLabel[pid])
        call MPInventorySetNextPageHotkeyLabel(whichPlayer, PageHotkeyLabel[pid])
        call TasItemBagSetToggleHotkeyLabel(whichPlayer, BagHotkeyLabel[pid])
        call TasItemBagSetSellHotkeyLabel(whichPlayer, SellHotkeyLabel[pid])
        call TasItemBagSetMapHotkeyLabel(whichPlayer, MapHotkeyLabel[pid])
        call TasItemBagSetCraftHotkeyLabel(whichPlayer, CraftHotkeyLabel[pid])
    endfunction

    private function SaveHotkeysForPlayer takes player whichPlayer returns nothing
        local integer pid
        local integer slot = 1
        local string contents

        if whichPlayer == null then
            return
        endif

        set pid = GetPlayerId(whichPlayer)
        set contents = HOTKEY_SETTINGS_HEADER + "\n" + I2S(OsKeyToStoredInt(MenuHotkey[pid])) + "\n" + I2S(OsKeyToStoredInt(PageHotkey[pid])) + "\n" + I2S(OsKeyToStoredInt(BagHotkey[pid])) + "\n" + I2S(OsKeyToStoredInt(SellHotkey[pid]))
        loop
            exitwhen slot > 6
            set contents = contents + "\n" + I2S(OsKeyToStoredInt(TasItemBagGetQuickUseHotkey(whichPlayer, slot)))
            set slot = slot + 1
        endloop
        // Map + Craft appended last (lines 12,13) so older save files just fall back to the defaults.
        set contents = contents + "\n" + I2S(OsKeyToStoredInt(MapHotkey[pid])) + "\n" + I2S(OsKeyToStoredInt(CraftHotkey[pid]))

        if GetLocalPlayer() == whichPlayer then
            call FileIO_Write(HotkeySettingsPath(whichPlayer), contents)
        endif

        set contents = null
    endfunction

    private function LoadHotkeysForPlayer takes player whichPlayer returns nothing
        local integer pid
        local string contents
        local integer keyValue
        local oskeytype loadedKey
        local integer slot = 1

        if whichPlayer == null then
            return
        endif
        if GetLocalPlayer() != whichPlayer then
            return
        endif

        set contents = FileIO_Read(HotkeySettingsPath(whichPlayer))
        if HotkeySettingsLine(contents, 1) != HOTKEY_SETTINGS_HEADER then
            set contents = FileIO_Read(HotkeySettingsFactionPath(whichPlayer))
            if HotkeySettingsLine(contents, 1) != HOTKEY_SETTINGS_HEADER then
                set contents = FileIO_Read(HotkeySettingsLegacyPath(whichPlayer))
                if HotkeySettingsLine(contents, 1) != HOTKEY_SETTINGS_HEADER then
                    set contents = FileIO_Read(HotkeySettingsModeLegacyPath(whichPlayer))
                    if HotkeySettingsLine(contents, 1) != HOTKEY_SETTINGS_HEADER then
                        set contents = null
                        return
                    endif
                endif
            endif
        endif

        set pid = GetPlayerId(whichPlayer)

        set keyValue = HotkeySettingsStoredInt(contents, 2)
        set loadedKey = StoredIntToOsKey(keyValue)
        if loadedKey != null then
            set MenuHotkey[pid] = loadedKey
            set MenuHotkeyLabel[pid] = HotkeyLabelForKey(loadedKey)
        endif

        set keyValue = HotkeySettingsStoredInt(contents, 3)
        if keyValue >= 0 then
            set loadedKey = StoredIntToOsKey(keyValue)
            set PageHotkey[pid] = loadedKey
            set PageHotkeyLabel[pid] = HotkeyLabelForKey(loadedKey)
        endif

        set keyValue = HotkeySettingsStoredInt(contents, 4)
        if keyValue >= 0 then
            set loadedKey = StoredIntToOsKey(keyValue)
            set BagHotkey[pid] = loadedKey
            set BagHotkeyLabel[pid] = HotkeyLabelForKey(loadedKey)
        endif

        set keyValue = HotkeySettingsStoredInt(contents, 5)
        if keyValue >= 0 then
            set loadedKey = StoredIntToOsKey(keyValue)
            set SellHotkey[pid] = loadedKey
            set SellHotkeyLabel[pid] = HotkeyLabelForKey(loadedKey)
        endif

        loop
            exitwhen slot > 6
            set keyValue = HotkeySettingsStoredInt(contents, slot + 5)
            if keyValue >= 0 then
                call TasItemBagSetQuickUseHotkey(whichPlayer, slot, StoredIntToOsKey(keyValue))
            endif
            set slot = slot + 1
        endloop

        set keyValue = HotkeySettingsStoredInt(contents, 12)
        if keyValue >= 0 then
            set loadedKey = StoredIntToOsKey(keyValue)
            set MapHotkey[pid] = loadedKey
            set MapHotkeyLabel[pid] = HotkeyLabelForKey(loadedKey)
        endif

        set keyValue = HotkeySettingsStoredInt(contents, 13)
        if keyValue >= 0 then
            set loadedKey = StoredIntToOsKey(keyValue)
            set CraftHotkey[pid] = loadedKey
            set CraftHotkeyLabel[pid] = HotkeyLabelForKey(loadedKey)
        endif

        call RefreshBoundHotkeyLabels(whichPlayer)
        set contents = null
    endfunction

    private function ClearListenState takes integer pid returns nothing
        set ListenMenu[pid] = false
        set ListenPage[pid] = false
        set ListenBag[pid] = false
        set ListenSell[pid] = false
        set ListenMap[pid] = false
        set ListenCraft[pid] = false
        set ListenInventoryQuickCastSlot[pid] = 0
    endfunction

    private function GetQuickUseConfigCaption takes player whichPlayer, integer slot returns string
        local string label = TasItemBagGetQuickUseHotkeyLabel(whichPlayer, slot)

        if label == "" then
            return "Set Slot " + I2S(slot) + " (Unbound)"
        endif

        return "Set Slot " + I2S(slot) + " (" + label + ")"
    endfunction

    private function UpdateHotkeyConfigView takes player whichPlayer returns nothing
        local integer pid = GetPlayerId(whichPlayer)
        local integer slot = 1
        local string menuCap
        local string pageCap
        local string bagCap
        local string sellCap
        local string mapCap
        local string craftCap
        local string hintText

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
        if MapHotkeyLabel[pid] == "" then
            set mapCap = "Set Map (Unbound)"
        else
            set mapCap = "Set Map (" + MapHotkeyLabel[pid] + ")"
        endif
        if CraftHotkeyLabel[pid] == "" then
            set craftCap = "Set Craft (Unbound)"
        else
            set craftCap = "Set Craft (" + CraftHotkeyLabel[pid] + ")"
        endif

        if ListenMenu[pid] then
            set hintText = "|cffffee88Press a key for: Main Menu|r"
        elseif ListenPage[pid] then
            set hintText = "|cffffee88Press a key for: Swap Page|r"
        elseif ListenBag[pid] then
            set hintText = "|cffffee88Press a key for: Bag Toggle|r"
        elseif ListenSell[pid] then
            set hintText = "|cffffee88Press a key for: Sell Mode|r"
        elseif ListenMap[pid] then
            set hintText = "|cffffee88Press a key for: World Map|r"
        elseif ListenCraft[pid] then
            set hintText = "|cffffee88Press a key for: Crafting|r"
        elseif ListenInventoryQuickCastSlot[pid] > 0 then
            set hintText = "|cffffee88Press a key for: Inventory Quick Cast Slot " + I2S(ListenInventoryQuickCastSlot[pid]) + "|r"
        elseif HotkeyConfigInventoryPage[pid] then
            set hintText = "Click a slot, then press a key."
        else
            set hintText = "Click a button, then press a key."
        endif

        if GetLocalPlayer() == whichPlayer then
            call BlzFrameSetVisible(hotkeyConfigPanel, ConfigOpen[pid])
            if not ConfigOpen[pid] then
                return
            endif

            call BlzFrameSetVisible(hotkeyConfigBtnInventory, not HotkeyConfigInventoryPage[pid])
            call BlzFrameSetVisible(hotkeyConfigBtnMenu, not HotkeyConfigInventoryPage[pid])
            call BlzFrameSetVisible(hotkeyConfigBtnPage, not HotkeyConfigInventoryPage[pid])
            call BlzFrameSetVisible(hotkeyConfigBtnBag, not HotkeyConfigInventoryPage[pid])
            call BlzFrameSetVisible(hotkeyConfigBtnSell, not HotkeyConfigInventoryPage[pid])
            call BlzFrameSetVisible(hotkeyConfigBtnMap, not HotkeyConfigInventoryPage[pid])
            call BlzFrameSetVisible(hotkeyConfigBtnCraft, not HotkeyConfigInventoryPage[pid])
            call BlzFrameSetVisible(hotkeyConfigBtnReset, not HotkeyConfigInventoryPage[pid])

            loop
                exitwhen slot > 6
                call BlzFrameSetVisible(hotkeyConfigBtnQuickUse[slot], HotkeyConfigInventoryPage[pid])
                if HotkeyConfigInventoryPage[pid] then
                    call BlzFrameSetText(hotkeyConfigBtnQuickUse[slot], GetQuickUseConfigCaption(whichPlayer, slot))
                endif
                set slot = slot + 1
            endloop
            call BlzFrameSetVisible(hotkeyConfigBtnQuickUseBack, HotkeyConfigInventoryPage[pid])

            if HotkeyConfigInventoryPage[pid] then
                call BlzFrameSetText(hotkeyConfigTitleText, "|cffffcc00Inventory Quick Cast|r")
                call BlzFrameSetText(hotkeyConfigBtnQuickUseBack, "Back")
            else
                call BlzFrameSetText(hotkeyConfigTitleText, "|cffffcc00Hot Keys|r")
                call BlzFrameSetText(hotkeyConfigBtnInventory, "Inventory Quick Cast")
                call BlzFrameSetText(hotkeyConfigBtnMenu, menuCap)
                call BlzFrameSetText(hotkeyConfigBtnPage, pageCap)
                call BlzFrameSetText(hotkeyConfigBtnBag, bagCap)
                call BlzFrameSetText(hotkeyConfigBtnSell, sellCap)
                call BlzFrameSetText(hotkeyConfigBtnMap, mapCap)
                call BlzFrameSetText(hotkeyConfigBtnCraft, craftCap)
            endif

            call BlzFrameSetText(hotkeyConfigHintText, hintText)
        endif
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
        set closeLabel = "|cffffaa00|cffffffffC|rlose|r"
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

    // Far-left hotbar menu button handler (registered into TasItemBag).
    private function MenuButtonAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pid
        if p == null then
            return
        endif
        set pid = GetPlayerId(p)
        if ConfigOpen[pid] then
            set p = null
            return
        endif
        call ToggleMenuForPlayer(p)
        set p = null
    endfunction

    private function ToggleHotkeyConfig takes player whichPlayer, boolean show returns nothing
        local integer pid = GetPlayerId(whichPlayer)

        set ConfigOpen[pid] = show
        if not show then
            call ClearListenState(pid)
            set HotkeyConfigInventoryPage[pid] = false
        endif
        call TasItemBagSetQuickUseHotkeyConfigOpen(whichPlayer, show)
        call UpdateHotkeyConfigView(whichPlayer)
    endfunction

    private function StartListen takes player whichPlayer, integer whichAction returns nothing
        local integer pid = GetPlayerId(whichPlayer)
        call ClearListenState(pid)
        set ListenMenu[pid] = whichAction == 1
        set ListenPage[pid] = whichAction == 2
        set ListenBag[pid] = whichAction == 3
        set ListenSell[pid] = whichAction == 4
        set ListenMap[pid] = whichAction == 5
        set ListenCraft[pid] = whichAction == 6
        if whichAction >= 101 and whichAction <= 106 then
            set ListenInventoryQuickCastSlot[pid] = whichAction - 100
        endif
        call UpdateHotkeyConfigView(whichPlayer)
    endfunction

    private function UnbindDuplicateQuickUseKey takes player whichPlayer, oskeytype key, integer exceptSlot returns nothing
        local integer slot = 1

        loop
            exitwhen slot > 6
            if slot != exceptSlot and TasItemBagGetQuickUseHotkey(whichPlayer, slot) == key then
                call TasItemBagSetQuickUseHotkey(whichPlayer, slot, null)
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Inventory Quick Cast Slot " + I2S(slot) + " (duplicate).|r")
            endif
            set slot = slot + 1
        endloop
    endfunction

    // Unbind the Map / Craft hotkeys if either currently holds `key` (duplicate cleanup), except the
    // one being assigned right now (keep: 5 = Map, 6 = Craft, 0 = neither).
    private function UnbindMapCraftExcept takes integer pid, oskeytype key, integer keep returns nothing
        if keep != 5 and MapHotkey[pid] == key then
            set MapHotkey[pid] = null
            set MapHotkeyLabel[pid] = ""
            call DisplayTextToPlayer(Player(pid), 0, 0, "|cffffaa00Unbound Map (duplicate).|r")
        endif
        if keep != 6 and CraftHotkey[pid] == key then
            set CraftHotkey[pid] = null
            set CraftHotkeyLabel[pid] = ""
            call DisplayTextToPlayer(Player(pid), 0, 0, "|cffffaa00Unbound Craft (duplicate).|r")
        endif
    endfunction

    private function ApplyKey takes player whichPlayer, oskeytype key returns nothing
        local integer pid = GetPlayerId(whichPlayer)
        local string label = OsKeyToString(key)
        local integer quickUseSlot = ListenInventoryQuickCastSlot[pid]

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
            call UnbindMapCraftExcept(pid, key, 0)
            call UnbindDuplicateQuickUseKey(whichPlayer, key, 0)
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
            call UnbindMapCraftExcept(pid, key, 0)
            call UnbindDuplicateQuickUseKey(whichPlayer, key, 0)
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
            call UnbindMapCraftExcept(pid, key, 0)
            call UnbindDuplicateQuickUseKey(whichPlayer, key, 0)
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
            call UnbindMapCraftExcept(pid, key, 0)
            call UnbindDuplicateQuickUseKey(whichPlayer, key, 0)
        elseif ListenMap[pid] then
            if MenuHotkey[pid] == key then
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00That key is reserved for Menu. Pick a different Map key.|r")
                call ClearListenState(pid)
                call ToggleHotkeyConfig(whichPlayer, true)
                return
            endif
            if MapHotkey[pid] != key then
                set MapHotkey[pid] = key
                set MapHotkeyLabel[pid] = label
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
            call UnbindMapCraftExcept(pid, key, 5)
            call UnbindDuplicateQuickUseKey(whichPlayer, key, 0)
        elseif ListenCraft[pid] then
            if MenuHotkey[pid] == key then
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00That key is reserved for Menu. Pick a different Craft key.|r")
                call ClearListenState(pid)
                call ToggleHotkeyConfig(whichPlayer, true)
                return
            endif
            if CraftHotkey[pid] != key then
                set CraftHotkey[pid] = key
                set CraftHotkeyLabel[pid] = label
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
            call UnbindMapCraftExcept(pid, key, 6)
            call UnbindDuplicateQuickUseKey(whichPlayer, key, 0)
        elseif quickUseSlot > 0 then
            if MenuHotkey[pid] == key then
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00That key is reserved for Menu. Pick a different Inventory Quick Cast key.|r")
                call ClearListenState(pid)
                call ToggleHotkeyConfig(whichPlayer, true)
                return
            endif
            call TasItemBagSetQuickUseHotkey(whichPlayer, quickUseSlot, key)
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
            call UnbindMapCraftExcept(pid, key, 0)
            call UnbindDuplicateQuickUseKey(whichPlayer, key, quickUseSlot)
        endif

        call ClearListenState(pid)
        call RefreshBoundHotkeyLabels(whichPlayer)
        call SaveHotkeysForPlayer(whichPlayer)
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

        if ListenMenu[pid] or ListenPage[pid] or ListenBag[pid] or ListenSell[pid] or ListenMap[pid] or ListenCraft[pid] or ListenInventoryQuickCastSlot[pid] > 0 then
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
        elseif MapHotkey[pid] != null and key == MapHotkey[pid] then
            call WorldMapToggleForPlayer(p)
        elseif CraftHotkey[pid] != null and key == CraftHotkey[pid] then
            call TasItemBagCraftingForPlayer(p)
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
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_NUMPAD0, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_NUMPAD1, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_NUMPAD2, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_NUMPAD3, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_NUMPAD4, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_NUMPAD5, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_NUMPAD6, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_NUMPAD7, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_NUMPAD8, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_NUMPAD9, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigHotkeys, Player(i), OSKEY_ESCAPE, 0, true)
            set i = i + 1
        endloop
        call TriggerAddAction(trigHotkeys, function HotkeyRouter)
    endfunction

    // The 6 default key bindings, shared by first-time init and the Reset button (one source of truth).
    private function ApplyDefaultHotkeys takes integer pid returns nothing
        set MenuHotkey[pid] = OSKEY_C
        set MenuHotkeyLabel[pid] = "C"
        set PageHotkey[pid] = OSKEY_Z
        set PageHotkeyLabel[pid] = "Z"
        set BagHotkey[pid] = OSKEY_X
        set BagHotkeyLabel[pid] = "X"
        set SellHotkey[pid] = OSKEY_G
        set SellHotkeyLabel[pid] = "G"
        set MapHotkey[pid] = OSKEY_M
        set MapHotkeyLabel[pid] = "M"
        set CraftHotkey[pid] = OSKEY_K
        set CraftHotkeyLabel[pid] = "K"
    endfunction

    // "Reset Hot Keys": restore every binding (the 6 above + the inventory quick-cast slots) to default,
    // push the badges, and persist.
    private function ResetHotkeysForPlayer takes player whichPlayer returns nothing
        call ApplyDefaultHotkeys(GetPlayerId(whichPlayer))
        call TasItemBagResetQuickUseHotkeys(whichPlayer)
        call RefreshBoundHotkeyLabels(whichPlayer)
        call SaveHotkeysForPlayer(whichPlayer)
    endfunction

    private function ConfigBtnInventoryClick takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pid = GetPlayerId(p)

        call ClearListenState(pid)
        set HotkeyConfigInventoryPage[pid] = true
        call UpdateHotkeyConfigView(p)

        set p = null
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

    private function ConfigBtnMapClick takes nothing returns nothing
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 223), false)
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 223), true)
        call StartListen(GetTriggerPlayer(), 5)
    endfunction

    private function ConfigBtnCraftClick takes nothing returns nothing
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 224), false)
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 224), true)
        call StartListen(GetTriggerPlayer(), 6)
    endfunction

    private function ConfigBtnResetClick takes nothing returns nothing
        local player p = GetTriggerPlayer()
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 225), false)
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 225), true)
        call ClearListenState(GetPlayerId(p))
        call ResetHotkeysForPlayer(p)
        call ToggleHotkeyConfig(p, true)
        call DisplayTextToPlayer(p, 0, 0, "|cffffee88Hot keys reset to defaults.|r")
        set p = null
    endfunction

    private function ConfigBtnQuickUseClick takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local framehandle clicked = BlzGetTriggerFrame()
        local integer slot = 1

        loop
            exitwhen slot > 6
            if clicked == hotkeyConfigBtnQuickUse[slot] then
                call BlzFrameSetEnable(hotkeyConfigBtnQuickUse[slot], false)
                call BlzFrameSetEnable(hotkeyConfigBtnQuickUse[slot], true)
                call StartListen(p, 100 + slot)
                set clicked = null
                set p = null
                return
            endif
            set slot = slot + 1
        endloop

        set clicked = null
        set p = null
    endfunction

    private function ConfigBtnQuickUseBackClick takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pid = GetPlayerId(p)

        call ClearListenState(pid)
        set HotkeyConfigInventoryPage[pid] = false
        call UpdateHotkeyConfigView(p)

        set p = null
    endfunction

    private function ConfigBtnCloseClick takes nothing returns nothing
        call ToggleHotkeyConfig(GetTriggerPlayer(), false)
    endfunction

    private function CreateHotkeyConfigUI takes nothing returns nothing
        local framehandle hotkeyConfigBtnClose
        local integer slot = 1

        set hotkeyConfigPanel = BlzCreateFrame("QuestButtonBaseTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 210)
        set hotkeyConfigTitleText = BlzCreateFrameByType("TEXT", "DlgHotkeyCfgTitle", hotkeyConfigPanel, "", 210)
        set hotkeyConfigHintText = BlzCreateFrameByType("TEXT", "DlgHotkeyCfgHint", hotkeyConfigPanel, "", 210)
        set hotkeyConfigBtnInventory = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 215)
        set hotkeyConfigBtnMenu = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 211)
        set hotkeyConfigBtnPage = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 212)
        set hotkeyConfigBtnBag = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 213)
        set hotkeyConfigBtnSell = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 214)
        set hotkeyConfigBtnMap = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 223)
        set hotkeyConfigBtnCraft = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 224)
        set hotkeyConfigBtnReset = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 225)
        set hotkeyConfigBtnClose = BlzCreateFrameByType("GLUETEXTBUTTON", "DlgHotkeyCfgCloseButton", hotkeyConfigPanel, "ScriptDialogButton", 0)

        loop
            exitwhen slot > 6
            set hotkeyConfigBtnQuickUse[slot] = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 215 + slot)
            set slot = slot + 1
        endloop
        set hotkeyConfigBtnQuickUseBack = BlzCreateFrame("ScriptDialogButton", hotkeyConfigPanel, 0, 222)

        call BlzFrameSetSize(hotkeyConfigPanel, 0.26, 0.28)
        call BlzFrameSetAbsPoint(hotkeyConfigPanel, FRAMEPOINT_CENTER, 0.40, 0.30)
        call BlzFrameSetVisible(hotkeyConfigPanel, false)
        call BlzFrameSetAlpha(hotkeyConfigPanel, 235)

        call BlzFrameSetText(hotkeyConfigTitleText, "|cffffcc00Hot Keys|r")
        call BlzFrameSetPoint(hotkeyConfigTitleText, FRAMEPOINT_TOPLEFT, hotkeyConfigPanel, FRAMEPOINT_TOPLEFT, 0.01, -0.01)
        call BlzFrameSetPoint(hotkeyConfigBtnClose, FRAMEPOINT_TOPRIGHT, hotkeyConfigPanel, FRAMEPOINT_TOPRIGHT, -0.002, -0.002)
        call BlzFrameSetSize(hotkeyConfigBtnClose, 0.03, 0.03)
        call BlzFrameSetText(hotkeyConfigBtnClose, "X")

        call BlzFrameSetPoint(hotkeyConfigBtnInventory, FRAMEPOINT_TOPLEFT, hotkeyConfigPanel, FRAMEPOINT_TOPLEFT, 0.01, -0.035)
        call BlzFrameSetPoint(hotkeyConfigBtnMenu, FRAMEPOINT_TOPLEFT, hotkeyConfigBtnInventory, FRAMEPOINT_BOTTOMLEFT, 0.00, -0.004)
        call BlzFrameSetPoint(hotkeyConfigBtnPage, FRAMEPOINT_TOPLEFT, hotkeyConfigBtnMenu, FRAMEPOINT_BOTTOMLEFT, 0.00, -0.004)
        call BlzFrameSetPoint(hotkeyConfigBtnBag, FRAMEPOINT_TOPLEFT, hotkeyConfigBtnPage, FRAMEPOINT_BOTTOMLEFT, 0.00, -0.004)
        call BlzFrameSetPoint(hotkeyConfigBtnSell, FRAMEPOINT_TOPLEFT, hotkeyConfigBtnBag, FRAMEPOINT_BOTTOMLEFT, 0.00, -0.004)
        call BlzFrameSetPoint(hotkeyConfigBtnMap, FRAMEPOINT_TOPLEFT, hotkeyConfigBtnSell, FRAMEPOINT_BOTTOMLEFT, 0.00, -0.004)
        call BlzFrameSetPoint(hotkeyConfigBtnCraft, FRAMEPOINT_TOPLEFT, hotkeyConfigBtnMap, FRAMEPOINT_BOTTOMLEFT, 0.00, -0.004)
        call BlzFrameSetPoint(hotkeyConfigBtnReset, FRAMEPOINT_TOPLEFT, hotkeyConfigBtnCraft, FRAMEPOINT_BOTTOMLEFT, 0.00, -0.010)

        call BlzFrameSetPoint(hotkeyConfigBtnQuickUse[1], FRAMEPOINT_TOPLEFT, hotkeyConfigPanel, FRAMEPOINT_TOPLEFT, 0.01, -0.035)
        call BlzFrameSetPoint(hotkeyConfigBtnQuickUse[2], FRAMEPOINT_TOPLEFT, hotkeyConfigBtnQuickUse[1], FRAMEPOINT_BOTTOMLEFT, 0.00, -0.004)
        call BlzFrameSetPoint(hotkeyConfigBtnQuickUse[3], FRAMEPOINT_TOPLEFT, hotkeyConfigBtnQuickUse[2], FRAMEPOINT_BOTTOMLEFT, 0.00, -0.004)
        call BlzFrameSetPoint(hotkeyConfigBtnQuickUse[4], FRAMEPOINT_TOPLEFT, hotkeyConfigBtnQuickUse[3], FRAMEPOINT_BOTTOMLEFT, 0.00, -0.004)
        call BlzFrameSetPoint(hotkeyConfigBtnQuickUse[5], FRAMEPOINT_TOPLEFT, hotkeyConfigBtnQuickUse[4], FRAMEPOINT_BOTTOMLEFT, 0.00, -0.004)
        call BlzFrameSetPoint(hotkeyConfigBtnQuickUse[6], FRAMEPOINT_TOPLEFT, hotkeyConfigBtnQuickUse[5], FRAMEPOINT_BOTTOMLEFT, 0.00, -0.004)
        call BlzFrameSetPoint(hotkeyConfigBtnQuickUseBack, FRAMEPOINT_TOPLEFT, hotkeyConfigBtnQuickUse[6], FRAMEPOINT_BOTTOMLEFT, 0.00, -0.004)

        call BlzFrameSetSize(hotkeyConfigBtnInventory, 0.24, 0.022)
        call BlzFrameSetSize(hotkeyConfigBtnMenu, 0.24, 0.022)
        call BlzFrameSetSize(hotkeyConfigBtnPage, 0.24, 0.022)
        call BlzFrameSetSize(hotkeyConfigBtnBag, 0.24, 0.022)
        call BlzFrameSetSize(hotkeyConfigBtnSell, 0.24, 0.022)
        call BlzFrameSetSize(hotkeyConfigBtnMap, 0.24, 0.022)
        call BlzFrameSetSize(hotkeyConfigBtnCraft, 0.24, 0.022)
        call BlzFrameSetSize(hotkeyConfigBtnReset, 0.24, 0.022)
        call BlzFrameSetText(hotkeyConfigBtnReset, "Reset Hot Keys")
        // Crafting has no real system yet: grey out its "Set Craft" button (the K placeholder still works).
        call BlzFrameSetEnable(hotkeyConfigBtnCraft, false)
        call BlzFrameSetSize(hotkeyConfigBtnQuickUse[1], 0.24, 0.022)
        call BlzFrameSetSize(hotkeyConfigBtnQuickUse[2], 0.24, 0.022)
        call BlzFrameSetSize(hotkeyConfigBtnQuickUse[3], 0.24, 0.022)
        call BlzFrameSetSize(hotkeyConfigBtnQuickUse[4], 0.24, 0.022)
        call BlzFrameSetSize(hotkeyConfigBtnQuickUse[5], 0.24, 0.022)
        call BlzFrameSetSize(hotkeyConfigBtnQuickUse[6], 0.24, 0.022)
        call BlzFrameSetSize(hotkeyConfigBtnQuickUseBack, 0.24, 0.022)
        call BlzFrameSetPoint(hotkeyConfigHintText, FRAMEPOINT_BOTTOMLEFT, hotkeyConfigPanel, FRAMEPOINT_BOTTOMLEFT, 0.01, 0.01)
        call BlzFrameSetText(hotkeyConfigHintText, "Click a button, then press a key.")

        call BlzTriggerRegisterFrameEvent(trigCfgInventory, hotkeyConfigBtnInventory, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgMenu, hotkeyConfigBtnMenu, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgPage, hotkeyConfigBtnPage, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgBag, hotkeyConfigBtnBag, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgSell, hotkeyConfigBtnSell, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgMap, hotkeyConfigBtnMap, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgCraft, hotkeyConfigBtnCraft, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgReset, hotkeyConfigBtnReset, FRAMEEVENT_CONTROL_CLICK)
        set slot = 1
        loop
            exitwhen slot > 6
            call BlzTriggerRegisterFrameEvent(trigCfgQuickUse, hotkeyConfigBtnQuickUse[slot], FRAMEEVENT_CONTROL_CLICK)
            set slot = slot + 1
        endloop
        call BlzTriggerRegisterFrameEvent(trigCfgQuickUseBack, hotkeyConfigBtnQuickUseBack, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgClose, hotkeyConfigBtnClose, FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trigCfgInventory, function ConfigBtnInventoryClick)
        call TriggerAddAction(trigCfgMenu, function ConfigBtnMenuClick)
        call TriggerAddAction(trigCfgPage, function ConfigBtnPageClick)
        call TriggerAddAction(trigCfgBag, function ConfigBtnBagClick)
        call TriggerAddAction(trigCfgSell, function ConfigBtnSellClick)
        call TriggerAddAction(trigCfgMap, function ConfigBtnMapClick)
        call TriggerAddAction(trigCfgCraft, function ConfigBtnCraftClick)
        call TriggerAddAction(trigCfgReset, function ConfigBtnResetClick)
        call TriggerAddAction(trigCfgQuickUse, function ConfigBtnQuickUseClick)
        call TriggerAddAction(trigCfgQuickUseBack, function ConfigBtnQuickUseBackClick)
        call TriggerAddAction(trigCfgClose, function ConfigBtnCloseClick)

        set slot = 1
        loop
            exitwhen slot > 6
            call BlzFrameSetVisible(hotkeyConfigBtnQuickUse[slot], false)
            set slot = slot + 1
        endloop
        call BlzFrameSetVisible(hotkeyConfigBtnQuickUseBack, false)

        set hotkeyConfigBtnClose = null
    endfunction

    private function InitDefaultHotkeys takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i >= bj_MAX_PLAYER_SLOTS
            call ApplyDefaultHotkeys(i)
            call RefreshBoundHotkeyLabels(Player(i))
            set HotkeyConfigInventoryPage[i] = false
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

        // Clicking any dialog button closes the native dialog, so the toggle state must
        // clear here too - not just on the branches that call CloseMenuForPlayer.
        set MenuOpen[pid] = false

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
        
        loop
            exitwhen i == bj_MAX_PLAYER_SLOTS
            set Dialog[(i * 12) + 0] = DialogCreate()
            call TriggerRegisterDialogEvent(trigDialogButtons, Dialog[(i * 12) + 0])
            set i = i + 1
        endloop
    endfunction

    private function FinishHotkeyInit takes nothing returns nothing
        local integer i = 0

        call CreateHotkeyConfigUI()
        call RegisterAllHotkeys()

        // Register the menu-button handler EARLY, right after hotkeys are set up - a point we
        // KNOW is reached (the C key works). It used to be the last line of this function, after
        // the LoadHotkeys loop and InitDialog; if either dies the registration was silently
        // skipped, so the C button's trigger fired but nothing was listening. Timing is safe:
        // the trigger exists (created in InitBagAt0s) and the menu isn't needed until clicked.
        call TasItemBagRegisterMenuButtonAction(function MenuButtonAction)

        loop
            exitwhen i == bj_MAX_PLAYER_SLOTS
            call LoadHotkeysForPlayer(Player(i))
            set i = i + 1
        endloop

        call TriggerAddCondition(trigDialogButtons, Filter(function OnButtonClick))
        call InitDialog()
    endfunction

    private function Init takes nothing returns nothing
        local trigger t = CreateTrigger()
        local trigger tClose = CreateTrigger()
        local integer i = 0

        call InitDefaultHotkeys()
        
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
        call TimerStart(CreateTimer(), 0.01, false, function FinishHotkeyInit)
    endfunction
endlibrary
