library MultiPageInventorySystem 

    //----------------------------------------------\\  
    //                                              \\  
    //  Multi-page Inventory System                 \\  
    //  Version 1.0.10 - Modified for P_Items       \\  
    //  Written by Rahko / Sabeximus#2923           \\  
    //  Modified by darkepacific for P_Items array  \\  
    //                                              \\  
    //----------------------------------------------\\  

    globals 
        //udg_Bag_Page has now been moved to globals for easier access across libraries
        private integer maxPages = 2
        
        private trigger trigInvMain = CreateTrigger() 
        private trigger trigInvLeft = CreateTrigger() 
        private trigger trigInvRight = CreateTrigger() 
        private trigger trigShowButtons = CreateTrigger() 
        private trigger trigItemSwap = CreateTrigger()

        // === Per-player hotkeys & state ===
        private oskeytype array hkMain      // go to page 1
        private oskeytype array hkLeft      // previous page
        private oskeytype array hkRight     // next page
        private string array hkMainStr
        private string array hkLeftStr
        private string array hkRightStr

        private boolean array listenMain    // awaiting key for main
        private boolean array listenLeft    // awaiting key for left
        private boolean array listenRight   // awaiting key for right
        private boolean array cfgOpen

        // Single trigger to handle all OS-key presses (both routing & capture)
        private trigger trigOSKeys = CreateTrigger()

        // Config UI
        private framehandle invConfigPanel = null
        private framehandle invConfigTitleText = null
        private framehandle invConfigHintText = null
        private framehandle invConfigBtnMain = null
        private framehandle invConfigBtnLeft = null
        private framehandle invConfigBtnRight = null

        private trigger trigInvConfig = CreateTrigger()
        private trigger trigCfgMain = CreateTrigger()
        private trigger trigCfgLeft = CreateTrigger()
        private trigger trigCfgRight = CreateTrigger()


        private string errorCantChangePage = "Cannot change inventory page while hero is stunned or rooted."
    endglobals 
    //===========================================================================

    // Update tooltip labels for one player (local safe)
    private function UpdateHotkeyTooltipsFor takes player whichPlayer returns nothing
        local integer id = GetPlayerId(whichPlayer)
        if GetLocalPlayer() == whichPlayer then
            call BlzFrameSetText(BlzGetFrameByName("MyScriptDialogButtonTooltip", 99), "First page (|cffffcc00" + hkMainStr[id] + "|r)\n|cffc0c0c0Click to view the first inventory page.|r")
            call BlzFrameSetText(BlzGetFrameByName("MyScriptDialogButtonTooltip", 101), "Next page (|cffffcc00" + hkRightStr[id] + "|r)\n|cffc0c0c0Click to view next inventory page.|r")
            if hkLeftStr[id] != "" then
                call BlzFrameSetText(BlzGetFrameByName("MyScriptDialogButtonTooltip", 100), "Previous page (|cffffcc00" + hkLeftStr[id] + "|r)\n|cffc0c0c0Click to view previous inventory page.|r")
            else
                call BlzFrameSetText(BlzGetFrameByName("MyScriptDialogButtonTooltip", 100), "Previous page\n|cffc0c0c0Click to view previous inventory page.|r")
            endif
            call BlzFrameSetText(BlzGetFrameByName("MyScriptDialogButtonTooltip", 102), "|cffc0c0c0Click to edit inventory button hot keys. \n(Useful if using Grid-Keys).|r")
        endif
    endfunction

    //===========================================================================

    function IsAbleToChangePage takes unit u returns boolean
        if u == null then
            call Debug("No hero found for player (null hero).")
            return false
        elseif IsUnitType(u, UNIT_TYPE_DEAD) or GetWidgetLife(u) <= 0.405 then
            // Hero is dead: ignore inventory hotkeys/page swaps
            return false
        elseif IsStunned(u) or IsRooted(u) or IsUnitPaused(u) then
            call ErrorMessage(errorCantChangePage, GetOwningPlayer(u))
            return false
        endif
        return true
    endfunction

    function ShowInventoryButtons takes player p, boolean b returns nothing
        if GetLocalPlayer() == p then 
            call BlzFrameSetVisible(BlzGetFrameByName("ScriptDialogButton", 99), b) 
            call BlzFrameSetVisible(BlzGetFrameByName("ScriptDialogButton", 100), b) 
            call BlzFrameSetVisible(BlzGetFrameByName("ScriptDialogButton", 101), b) 
            call BlzFrameSetVisible(BlzGetFrameByName("ScriptDialogButton", 102), b) 
        endif 
    endfunction

    private function InventoryButtonsSetPageText takes player whichPlayer, string s returns nothing 
        if GetLocalPlayer() == whichPlayer then 
            call BlzFrameSetText(BlzGetFrameByName("ScriptDialogButton", 102), s) 
        endif 
    endfunction 

    function ResetInventory takes player p returns nothing
        local integer playerNum = GetPlayerHeroNumber(p)
        local integer bagNum = GetPlayerBagNumber(p)
        local integer i = 0
        
        // Reset all stored items for this player (equipped + extra bag)
        set i = 0
        loop
            exitwhen i > udg_BAG_SIZE
            if udg_P_Items[bagNum + i] != null then
                call RemoveItem(udg_P_Items[bagNum + i])
                set udg_P_Items[bagNum + i] = null
            endif
            set i = i + 1 
        endloop

        set udg_Warmogs[playerNum] = null
        set udg_DeathCap[playerNum] = null
        set udg_PrevBONUSInt[playerNum] = 0

        set udg_Bag_Page[playerNum] = 1

        call InventoryButtonsSetPageText(p,("|cffffffff" + I2S(udg_Bag_Page[playerNum]) + "/" + I2S(maxPages) + "|r") )

        call ShowInventoryButtons(p, false)
    endfunction

    function ItemSwapConditions takes nothing returns boolean
        local integer order = GetIssuedOrderId() 
        return(order >= 852002 and order <= 852007)
    endfunction

    function ItemSwapActions takes nothing returns nothing
        local unit u = GetTriggerUnit() 
        local player p = GetOwningPlayer(u)
        local integer order = GetIssuedOrderId() 
        local integer slot 
        local integer toSlot = order - 852002
        local item item1 = GetOrderTargetItem() 
        local item item2 = UnitItemInSlot(u, toSlot)

        if item1 != item2 then
            set slot = GetUnitItemSlot(u, item1)
            set toSlot = toSlot + 1 // Adjust to 1-based index
            set udg_P_Items[GetPItemsCurrentIndex(p, slot)] = item2
            set udg_P_Items[GetPItemsCurrentIndex(p, toSlot)] = item1
        endif 

        set u = null
        set p = null
        set item1 = null
        set item2 = null
    endfunction

    private function DropInventoryToP_Items takes player p returns nothing 
        local integer playerNum = GetPlayerHeroNumber(p)
        local unit u = udg_Heroes[playerNum]
        local integer currentPage = udg_Bag_Page[playerNum]
        local integer pItemsIndex = 0
        local item it = null
        local integer itemId = 0
        local integer statCalc = 0
        local location itemIsland = GetRectCenter(gg_rct_ISLAND_ITEMS)
        local integer i = 1
        
        // Have to disable so it doesn't label their index in P_Items as null
        call DisableTrigger(gg_trg_Lose_Item) 

        // Store and drop current inventory items to P_Items
        loop
            set pItemsIndex = GetPItemsIndex(p, currentPage, i)
            set it = udg_P_Items[pItemsIndex]
            set itemId = GetItemTypeId(it)

            if it != null then
                // Dread Magic Cap
                if(itemId == 'I06Y') then
                    call BlzItemRemoveAbility(it, udg_InitDeathCap[GetItemUserData(it)])
                endif

                // Sea Heavy
                if(itemId == 'I06P') then
                    call BlzItemRemoveAbility(it, 'A00T')
                endif

                // Flamewalkers
                if(itemId == 'I06T') then
                    // Remove old buff
                    set statCalc =((S2I(SubStringBJ(BlzGetItemDescription(it), 226, 228)) - 20) / 3)
                    call BlzItemRemoveAbility(it, udg_InitFlamewalkers[statCalc] )
                endif

                set bj_lastRemovedItem = UnitRemoveItemFromSlot(u, i - 1)
                call SetItemPositionLoc(bj_lastRemovedItem, itemIsland)
                call SetItemUserData(bj_lastRemovedItem, 1)
            endif

            set i = i + 1
            exitwhen i > 6
        endloop
        
        // Elune's Veil
        call DestroyEffect(udg_Banshees[playerNum])

        set udg_DeathCap[playerNum] = null
        set udg_Warmogs[playerNum] = null
        set udg_PrevBONUSInt[playerNum] = 0

        call EnableTrigger(gg_trg_Lose_Item) 

        call RemoveLocation(itemIsland)
        set itemIsland = null
        set u = null
        set it = null
    endfunction

    // Replace the hash-based load with P_Items system  
    private function LoadInventoryFromP_Items takes player p returns nothing
        local integer playerNum = GetPlayerHeroNumber(p)
        local unit u = udg_Heroes[playerNum]
        local integer currentPage = udg_Bag_Page[playerNum]
        local integer i = 0
        local integer pItemsIndex = 0
        local item oldItem = null
        local item newItem = null
        local boolean hasBanshees = false
        local integer slotActuallyAddedTo = 0
        
        // Disable triggers
        call DisableTrigger(gg_trg_Firestone_Dropped) 
        call DisableTrigger(gg_trg_Firestone_Acquired) 
        
        set i = 1
        set slotActuallyAddedTo = 1
        loop
            set pItemsIndex = GetPItemsIndex(p, currentPage, i)
            set newItem = udg_P_Items[pItemsIndex]
            set udg_P_Items[pItemsIndex] = null
            
            if newItem != null then
                set udg_dontDepositIntoBag = true
                call UnitAddItem(u, newItem)
                set udg_P_Items[GetPItemsIndex(p, currentPage, slotActuallyAddedTo)] = newItem
                set slotActuallyAddedTo = slotActuallyAddedTo + 1 
            endif
                        
            set i = i + 1
            exitwhen i > 6
        endloop
        
        // Re-enable triggers
        call EnableTrigger(gg_trg_Firestone_Dropped) 
        call EnableTrigger(gg_trg_Firestone_Acquired) 
        
        call PlayLocalSound(gg_snd_PickUpItem, p)
        
        set oldItem = null
        set newItem = null
    endfunction 

    private function InventoryButtonClickMain takes nothing returns nothing 
        local string s = "" 
        local player p = GetTriggerPlayer() 
        local integer playerNum = GetPlayerHeroNumber(p)

        if IsAbleToChangePage(udg_Heroes[playerNum]) then
            call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 99), false) 
            call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 99), true) 
            call DropInventoryToP_Items(p) 
            set udg_Bag_Page[playerNum] = 1 
            call LoadInventoryFromP_Items(p)
            set s =("|cffffffff" + I2S(udg_Bag_Page[playerNum]) + "/" + I2S(maxPages) + "|r") 
            call InventoryButtonsSetPageText(p, s) 
        endif

        set s = null 
        set p = null 
    endfunction 

    private function InventoryButtonClickLeft takes nothing returns nothing 
        local string s = "" 
        local player p = GetTriggerPlayer() 
        local integer playerNum = GetPlayerHeroNumber(p)

        if IsAbleToChangePage(udg_Heroes[playerNum]) then
            call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 100), false) 
            call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 100), true) 
            call DropInventoryToP_Items(p) 
            call Debug("[LEFT] PAGE BEFORE CHANGE: " + I2S(udg_Bag_Page[playerNum])) 
            if(udg_Bag_Page[playerNum] <= 1) then 
                set udg_Bag_Page[playerNum] =(maxPages) 
            else 
                set udg_Bag_Page[playerNum] =(udg_Bag_Page[playerNum] - 1) 
            endif 
            call Debug("[LEFT] PAGE AFTER CHANGE: " + I2S(udg_Bag_Page[playerNum])) 
            call LoadInventoryFromP_Items(p) 
            set s =("|cffffffff" + I2S(udg_Bag_Page[playerNum]) + "/" + I2S(maxPages) + "|r") 
            call InventoryButtonsSetPageText(p, s) 
        endif

        set s = null 
        set p = null 
    endfunction 
    
    private function InventoryButtonClickRight takes nothing returns nothing 
        local string s = "" 
        local player p = GetTriggerPlayer() 
        local integer playerNum = GetPlayerHeroNumber(p)
        
        if IsAbleToChangePage(udg_Heroes[playerNum]) then
            call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 101), false) 
            call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 101), true) 
            call DropInventoryToP_Items(p) 
            call Debug("[RIGHT] PAGE BEFORE CHANGE: " + I2S(udg_Bag_Page[playerNum])) 
            if(udg_Bag_Page[playerNum] >=(maxPages)) then 
                set udg_Bag_Page[playerNum] = 1 
            else 
                set udg_Bag_Page[playerNum] =(udg_Bag_Page[playerNum] + 1) 
            endif 
            call Debug("[RIGHT] PAGE AFTER CHANGE: " + I2S(udg_Bag_Page[playerNum])) 
            call LoadInventoryFromP_Items(p) 
            set s =("|cffffffff" + I2S(udg_Bag_Page[playerNum]) + "/" + I2S(maxPages) + "|r") 
            call InventoryButtonsSetPageText(p, s) 
        endif

        set s = null 
        set p = null 
    endfunction 
    
    function ShowButtonsActions takes nothing returns nothing 
        local string s = "" 
        local player p = GetTriggerPlayer() 
        local integer playerNum = GetPlayerHeroNumber(p)
        local unit u = GetTriggerUnit() 
        
        if(GetTriggerPlayer() == GetOwningPlayer(u) and u == udg_Heroes[playerNum]) then
            call ShowInventoryButtons(p, true) 
            if(udg_Bag_Page[playerNum] <= 0) or(udg_Bag_Page[playerNum] > maxPages) then 
                call Debug("Setting pages") 
                set udg_Bag_Page[playerNum] = 1 
            endif 
            set s =("|cffffffff" + I2S(udg_Bag_Page[playerNum]) + "/" + I2S(maxPages) + "|r") 
            call InventoryButtonsSetPageText(p, s)
            // refresh tooltip texts for this player to show current bindings
            call UpdateHotkeyTooltipsFor(p)
        else 
            call ShowInventoryButtons(p, false) 
        endif 

        set p = null 
        set u = null 
    endfunction 
    
    function HideButtonsActions takes nothing returns nothing 
        call ShowInventoryButtons(GetTriggerPlayer(), false) 
    endfunction 

    // ===================== NEW SYSTEM (unchanged logic above) =====================

    // Map oskeytype to a short label for tooltips / buttons.
    private function OsKeyToString takes oskeytype k returns string
        // Letters A..Z
        if k == OSKEY_A then
            return "A"
        elseif k == OSKEY_B then
            return "B"
        elseif k == OSKEY_C then
            return "C"
        elseif k == OSKEY_D then
            return "D"
        elseif k == OSKEY_E then
            return "E"
        elseif k == OSKEY_F then
            return "F"
        elseif k == OSKEY_G then
            return "G"
        elseif k == OSKEY_H then
            return "H"
        elseif k == OSKEY_I then
            return "I"
        elseif k == OSKEY_J then
            return "J"
        elseif k == OSKEY_K then
            return "K"
        elseif k == OSKEY_L then
            return "L"
        elseif k == OSKEY_M then
            return "M"
        elseif k == OSKEY_N then
            return "N"
        elseif k == OSKEY_O then
            return "O"
        elseif k == OSKEY_P then
            return "P"
        elseif k == OSKEY_Q then
            return "Q"
        elseif k == OSKEY_R then
            return "R"
        elseif k == OSKEY_S then
            return "S"
        elseif k == OSKEY_T then
            return "T"
        elseif k == OSKEY_U then
            return "U"
        elseif k == OSKEY_V then
            return "V"
        elseif k == OSKEY_W then
            return "W"
        elseif k == OSKEY_X then
            return "X"
        elseif k == OSKEY_Y then
            return "Y"
        elseif k == OSKEY_Z then
            return "Z"
            // Numbers 0..9
        elseif k == OSKEY_0 then
            return "0"
        elseif k == OSKEY_1 then
            return "1"
        elseif k == OSKEY_2 then
            return "2"
        elseif k == OSKEY_3 then
            return "3"
        elseif k == OSKEY_4 then
            return "4"
        elseif k == OSKEY_5 then
            return "5"
        elseif k == OSKEY_6 then
            return "6"
        elseif k == OSKEY_7 then
            return "7"
        elseif k == OSKEY_8 then
            return "8"
        elseif k == OSKEY_9 then
            return "9"
            // Escape
        elseif k == OSKEY_ESCAPE then
            return "Esc"
        endif
        return "?"
    endfunction

    // Initialize per-player default hotkeys (keeps X/Z; left unbound)
    private function InitDefaultHotkeys takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i > 23
            set hkMain[i] = null //OSKEY_X
            set hkMainStr[i] = "" //"X"

            set hkRight[i] = OSKEY_Z
            set hkRightStr[i] = "Z"

            set hkLeft[i] = null
            set hkLeftStr[i] = "" // unbound

            set listenMain[i] = false
            set listenLeft[i] = false
            set listenRight[i] = false
            set i = i + 1
        endloop
    endfunction

    // Show/Hide the config panel (local safe). Also refresh button captions with current keys.
    private function ToggleHotkeyConfig takes player whichPlayer, boolean show returns nothing
        local integer id = GetPlayerId(whichPlayer)
        local string leftCap
        local string rightCap
        local string mainCap

        // Build captions without Lua-style inline conditionals
        if hkMainStr[id] == "" then
            set mainCap = "Set First (Unbound)"
        else
            set mainCap = "Set First (" + hkMainStr[id] + ")"
        endif

        if hkRightStr[id] == "" then
            set rightCap = "Set Next (Unbound)"
        else
            set rightCap = "Set Next (" + hkRightStr[id] + ")"
        endif

        if hkLeftStr[id] == "" then
            set leftCap = "Set Prev (Unbound)"
        else
            set leftCap = "Set Prev (" + hkLeftStr[id] + ")"
        endif

        set cfgOpen[id] = show
        if GetLocalPlayer() == whichPlayer then
            call BlzFrameSetVisible(invConfigPanel, show)
            call BlzFrameSetText(invConfigBtnMain, mainCap)
            call BlzFrameSetText(invConfigBtnRight, rightCap)
            call BlzFrameSetText(invConfigBtnLeft, leftCap)
            call BlzFrameSetText(invConfigHintText, "Click a button, then press a key.")
        endif
    endfunction

    // Start listening for the next key press for a specific binding.
    private function StartListen takes player whichPlayer, integer which returns nothing
        local integer id = GetPlayerId(whichPlayer)
        set listenMain[id] =(which == 1)
        set listenLeft[id] =(which == 2)
        set listenRight[id] =(which == 3)
        if GetLocalPlayer() == whichPlayer then
            if which == 1 then
                call BlzFrameSetText(invConfigHintText, "|cffffee88Press a key for: First Page|r")
            elseif which == 2 then
                call BlzFrameSetText(invConfigHintText, "|cffffee88Press a key for: Previous Page|r")
            else
                call BlzFrameSetText(invConfigHintText, "|cffffee88Press a key for: Next Page|r")
            endif
        endif
    endfunction

    // Apply a new key; resolves conflicts by unbinding duplicates on other actions.
    private function ApplyKey takes player whichPlayer, oskeytype key returns nothing
        local integer id = GetPlayerId(whichPlayer)
        local string label = OsKeyToString(key)


        if listenMain[id] then
            if hkMain[id] == key then
                set hkMain[id] = null
                set hkMainStr[id] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound First (duplicate).|r")
            else
                set hkMain[id] = key
                set hkMainStr[id] = label
            endif

            if hkRight[id] == key then
                set hkRight[id] = null
                set hkRightStr[id] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Next (duplicate).|r")
            endif
            if hkLeft[id] == key then
                set hkLeft[id] = null
                set hkLeftStr[id] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Prev (duplicate).|r")
            endif
        elseif listenLeft[id] then
            if hkLeft[id] == key then
                set hkLeft[id] = null
                set hkLeftStr[id] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Prev (duplicate).|r")
            else
                set hkLeft[id] = key
                set hkLeftStr[id] = label
            endif

            if hkMain[id] == key then
                set hkMain[id] = null
                set hkMainStr[id] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound First (duplicate).|r")
            endif
            if hkRight[id] == key then
                set hkRight[id] = null
                set hkRightStr[id] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Next (duplicate).|r")
            endif
        elseif listenRight[id] then
            if hkRight[id] == key then
                set hkRight[id] = null
                set hkRightStr[id] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Next (duplicate).|r")
            else
                set hkRight[id] = key
                set hkRightStr[id] = label
            endif

            if hkMain[id] == key then
                set hkMain[id] = null
                set hkMainStr[id] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound First (duplicate).|r")
            endif
            if hkLeft[id] == key then
                set hkLeft[id] = null
                set hkLeftStr[id] = ""
                call DisplayTextToPlayer(whichPlayer, 0, 0, "|cffffaa00Unbound Prev (duplicate).|r")
            endif
        endif

        set listenMain[id] = false
        set listenLeft[id] = false
        set listenRight[id] = false

        call UpdateHotkeyTooltipsFor(whichPlayer)
        call ToggleHotkeyConfig(whichPlayer, true) // update the text
    endfunction

    // One trigger handles all alphanumeric keys for all players.
    private function OSKeyRouter takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer id = GetPlayerId(p)
        local oskeytype k = BlzGetTriggerPlayerKey()

        call Debug("OSKeyRouter fired with Key: " + OsKeyToString(k))
        // --- ESC: cancel listen + close panel
        if k == OSKEY_ESCAPE then
            set listenMain[id] = false
            set listenLeft[id] = false
            set listenRight[id] = false
            call ToggleHotkeyConfig(p, false)
            set p = null
            return
        endif

        // If currently capturing: consume this key as a binding.
        if listenMain[id] or listenLeft[id] or listenRight[id] then
            call ApplyKey(p, k)
            set p = null
            return
        endif

        // If config panel is open (but not listening), ignore routing so keys don't flip pages.
        if cfgOpen[id] then
            set p = null
            return
        endif

        // Not capturing and no panel: route to actions if pressed key matches a binding.
        if hkMain[id] != null and k == hkMain[id] then
            call InventoryButtonClickMain()
        elseif hkLeft[id] != null and k == hkLeft[id] then
            call InventoryButtonClickLeft()
        elseif hkRight[id] != null and k == hkRight[id] then
            call InventoryButtonClickRight()
        endif

        set p = null
    endfunction

    // Register a sane set of keys for all players (A..Z, 0..9). No F-keys, no ESC.
    private function RegisterAllOSKeys takes nothing returns nothing
        local integer i = 0
        loop
            exitwhen i > 23
            // Letters
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_A, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_B, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_C, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_D, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_E, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_F, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_G, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_H, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_I, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_J, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_K, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_L, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_M, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_N, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_O, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_P, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_Q, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_R, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_S, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_T, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_U, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_V, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_W, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_X, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_Y, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_Z, 0, true)
            // Numbers
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_0, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_1, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_2, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_3, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_4, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_5, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_6, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_7, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_8, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_9, 0, true)
            // Escape Key - Special Case
            call BlzTriggerRegisterPlayerKeyEvent(trigOSKeys, Player(i), OSKEY_ESCAPE, 0, true)

            set i = i + 1
        endloop
        call TriggerAddAction(trigOSKeys, function OSKeyRouter)
    endfunction

    // === Config button actions (replacing lambdas) ===
    private function ConfigBtnMainClick takes nothing returns nothing
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 211), false)
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 211), true)
        call StartListen(GetTriggerPlayer(), 1)
    endfunction

    private function ConfigBtnRightClick takes nothing returns nothing
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 212), false)
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 212), true)
        call StartListen(GetTriggerPlayer(), 3)
    endfunction

    private function ConfigBtnLeftClick takes nothing returns nothing
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 213), false)
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 213), true)
        call StartListen(GetTriggerPlayer(), 2)
    endfunction

    private function InventoryButtonClickConfig takes nothing returns nothing
        local integer id = GetPlayerId(GetTriggerPlayer())

        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 102), false)
        call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 102), true)

        set cfgOpen[id] = not(cfgOpen[id])
        call ToggleHotkeyConfig(GetTriggerPlayer(), cfgOpen[id])
    endfunction

    // Create the small config panel and wire up its buttons.
    private function CreateHotkeyConfigUI takes nothing returns nothing
        // Background panel
        set invConfigPanel = BlzCreateFrame("QuestButtonBaseTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 210)
        set invConfigTitleText = BlzCreateFrameByType("TEXT", "InvCfgTitle", invConfigPanel, "", 210)
        set invConfigHintText = BlzCreateFrameByType("TEXT", "InvCfgHint", invConfigPanel, "", 210)
        set invConfigBtnMain = BlzCreateFrame("ScriptDialogButton", invConfigPanel, 0, 211)
        set invConfigBtnRight = BlzCreateFrame("ScriptDialogButton", invConfigPanel, 0, 212)
        set invConfigBtnLeft = BlzCreateFrame("ScriptDialogButton", invConfigPanel, 0, 213)


        call BlzFrameSetSize(invConfigPanel, 0.26, 0.14)
        call BlzFrameSetAbsPoint(invConfigPanel, FRAMEPOINT_CENTER, 0.50, 0.36)
        call BlzFrameSetVisible(invConfigPanel, false)
        call BlzFrameSetAlpha(invConfigPanel, 235)

        call BlzFrameSetText(invConfigTitleText, "|cffffcc00Inventory Hotkeys|r")
        call BlzFrameSetPoint(invConfigTitleText, FRAMEPOINT_TOPLEFT, invConfigPanel, FRAMEPOINT_TOPLEFT, 0.01, - 0.01)

        call BlzFrameSetPoint(invConfigBtnMain, FRAMEPOINT_TOPLEFT, invConfigPanel, FRAMEPOINT_TOPLEFT, 0.01, - 0.035)
        call BlzFrameSetPoint(invConfigBtnRight, FRAMEPOINT_TOPLEFT, invConfigBtnMain, FRAMEPOINT_BOTTOMLEFT, 0.00, - 0.006)
        call BlzFrameSetPoint(invConfigBtnLeft, FRAMEPOINT_TOPLEFT, invConfigBtnRight, FRAMEPOINT_BOTTOMLEFT, 0.00, - 0.006)

        call BlzFrameSetSize(invConfigBtnMain, 0.24, 0.024)
        call BlzFrameSetSize(invConfigBtnLeft, 0.24, 0.024)
        call BlzFrameSetSize(invConfigBtnRight, 0.24, 0.024)

        call BlzFrameSetPoint(invConfigHintText, FRAMEPOINT_BOTTOMLEFT, invConfigPanel, FRAMEPOINT_BOTTOMLEFT, 0.01, 0.01)

        // Wire clicks
        call BlzTriggerRegisterFrameEvent(trigCfgMain, invConfigBtnMain, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgLeft, invConfigBtnLeft, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigCfgRight, invConfigBtnRight, FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trigCfgMain, function ConfigBtnMainClick)
        call TriggerAddAction(trigCfgLeft, function ConfigBtnLeftClick)
        call TriggerAddAction(trigCfgRight, function ConfigBtnRightClick)
    endfunction

    // ===================== ORIGINAL SYSTEM (unchanged logic) =====================

    function CreateInventoryButtons takes nothing returns nothing 
        local integer i = 0 
        local framehandle invButtonMain = BlzCreateFrame("ScriptDialogButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 99) 
        local framehandle invButtonMainTooltipBackground = BlzCreateFrame("QuestButtonBaseTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 99) 
        local framehandle invButtonMainTooltipText = BlzCreateFrameByType("TEXT", "MyScriptDialogButtonTooltip", invButtonMainTooltipBackground, "", 99) 
        local framehandle invButtonLeft = BlzCreateFrame("ScriptDialogButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 100) 
        local framehandle invButtonLeftTooltipBackground = BlzCreateFrame("QuestButtonBaseTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 100) 
        local framehandle invButtonLeftTooltipText = BlzCreateFrameByType("TEXT", "MyScriptDialogButtonTooltip", invButtonLeftTooltipBackground, "", 100) 
        local framehandle invButtonRight = BlzCreateFrame("ScriptDialogButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 101) 
        local framehandle invButtonRightTooltipBackground = BlzCreateFrame("QuestButtonBaseTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 101) 
        local framehandle invButtonRightTooltipText = BlzCreateFrameByType("TEXT", "MyScriptDialogButtonTooltip", invButtonRightTooltipBackground, "", 101) 
        local framehandle invButtonPage = BlzCreateFrame("ScriptDialogButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 102) 
        local framehandle invButtonPageTooltipBackground = BlzCreateFrame("QuestButtonBaseTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 102) 
        local framehandle invButtonPageTooltipText = BlzCreateFrameByType("TEXT", "MyScriptDialogButtonTooltip", invButtonPageTooltipBackground, "", 102) 

        // New: central hotkey router init
        call InitDefaultHotkeys()
        call RegisterAllOSKeys()

        call BlzFrameSetSize(invButtonMain, 0.033, 0.025) 
        call BlzFrameSetSize(invButtonLeft, 0.033, 0.025) 
        call BlzFrameSetSize(invButtonRight, 0.033, 0.025) 
        call BlzFrameSetSize(invButtonPage, 0.04, 0.025) 
        call BlzFrameSetSize(invButtonMainTooltipText, 0, 0) 
        call BlzFrameSetSize(invButtonLeftTooltipText, 0, 0) 
        call BlzFrameSetSize(invButtonRightTooltipText, 0, 0) 
        call BlzFrameSetSize(invButtonPageTooltipText, 0, 0) 

        call BlzFrameSetAbsPoint(invButtonPage, FRAMEPOINT_CENTER, 0.5513, 0.1425) 
        call BlzFrameSetAbsPoint(invButtonRight, FRAMEPOINT_CENTER, 0.60, 0.0575) 
        call BlzFrameSetPoint(invButtonLeft, FRAMEPOINT_CENTER, invButtonRight, FRAMEPOINT_CENTER, 0, - 0.020) 
        call BlzFrameSetPoint(invButtonMain, FRAMEPOINT_CENTER, invButtonRight, FRAMEPOINT_CENTER, 0, 0.020) 

        call BlzFrameSetPoint(invButtonMainTooltipBackground, FRAMEPOINT_BOTTOMLEFT, invButtonMainTooltipText, FRAMEPOINT_BOTTOMLEFT, - 0.01, - 0.01) 
        call BlzFrameSetPoint(invButtonMainTooltipBackground, FRAMEPOINT_TOPRIGHT, invButtonMainTooltipText, FRAMEPOINT_TOPRIGHT, 0.01, 0.01) 
        call BlzFrameSetPoint(invButtonRightTooltipBackground, FRAMEPOINT_BOTTOMLEFT, invButtonRightTooltipText, FRAMEPOINT_BOTTOMLEFT, - 0.01, - 0.01) 
        call BlzFrameSetPoint(invButtonRightTooltipBackground, FRAMEPOINT_TOPRIGHT, invButtonRightTooltipText, FRAMEPOINT_TOPRIGHT, 0.01, 0.01) 
        call BlzFrameSetPoint(invButtonLeftTooltipBackground, FRAMEPOINT_BOTTOMLEFT, invButtonLeftTooltipText, FRAMEPOINT_BOTTOMLEFT, - 0.01, - 0.01) 
        call BlzFrameSetPoint(invButtonLeftTooltipBackground, FRAMEPOINT_TOPRIGHT, invButtonLeftTooltipText, FRAMEPOINT_TOPRIGHT, 0.01, 0.01) 
        call BlzFrameSetPoint(invButtonPageTooltipBackground, FRAMEPOINT_BOTTOMLEFT, invButtonPageTooltipText, FRAMEPOINT_BOTTOMLEFT, - 0.01, - 0.01) 
        call BlzFrameSetPoint(invButtonPageTooltipBackground, FRAMEPOINT_TOPRIGHT, invButtonPageTooltipText, FRAMEPOINT_TOPRIGHT, 0.01, 0.01) 

        call BlzFrameSetTooltip(invButtonMain, invButtonMainTooltipBackground) 
        call BlzFrameSetTooltip(invButtonRight, invButtonRightTooltipBackground) 
        call BlzFrameSetTooltip(invButtonLeft, invButtonLeftTooltipBackground) 
        call BlzFrameSetTooltip(invButtonPage, invButtonPageTooltipBackground) 

        call BlzFrameSetPoint(invButtonMainTooltipText, FRAMEPOINT_BOTTOM, invButtonMain, FRAMEPOINT_TOP, 0, 0.005) 
        call BlzFrameSetPoint(invButtonRightTooltipText, FRAMEPOINT_BOTTOM, invButtonRight, FRAMEPOINT_TOP, 0, 0.005) 
        call BlzFrameSetPoint(invButtonLeftTooltipText, FRAMEPOINT_BOTTOM, invButtonLeft, FRAMEPOINT_TOP, 0, 0.005) 
        call BlzFrameSetPoint(invButtonPageTooltipText, FRAMEPOINT_BOTTOM, invButtonPage, FRAMEPOINT_TOP, 0, 0.005) 

        call BlzFrameSetAlpha(invButtonMainTooltipBackground, 25) 
        call BlzFrameSetAlpha(invButtonLeftTooltipBackground, 25) 
        call BlzFrameSetAlpha(invButtonRightTooltipBackground, 25) 
        call BlzFrameSetAlpha(invButtonPageTooltipBackground, 25) 

        call BlzFrameSetEnable(invButtonMainTooltipText, false) 
        call BlzFrameSetEnable(invButtonRightTooltipText, false) 
        call BlzFrameSetEnable(invButtonLeftTooltipText, false) 
        call BlzFrameSetEnable(invButtonPageTooltipText, false) 

        call UpdateHotkeyTooltipsFor(GetLocalPlayer())

        call BlzFrameSetText(invButtonMain, "1") 
        call BlzFrameSetText(invButtonRight, "->") 
        call BlzFrameSetText(invButtonLeft, "<-") 
        call BlzFrameSetText(invButtonPage, "|cffffffff1/" + I2S(maxPages) + "|r")

        // IMPORTANT: make 102 clickable/visible so it opens the config
        // call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 102), true) 
        // call BlzFrameSetVisible(BlzGetFrameByName("ScriptDialogButton", 102), true) 
        
        // Register button events
        call BlzTriggerRegisterFrameEvent(trigInvMain, invButtonMain, FRAMEEVENT_CONTROL_CLICK) 
        call BlzTriggerRegisterFrameEvent(trigInvLeft, invButtonLeft, FRAMEEVENT_CONTROL_CLICK) 
        call BlzTriggerRegisterFrameEvent(trigInvRight, invButtonRight, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigInvConfig, invButtonPage, FRAMEEVENT_CONTROL_CLICK)
 
        call TriggerAddAction(trigInvMain, function InventoryButtonClickMain) 
        call TriggerAddAction(trigInvLeft, function InventoryButtonClickLeft) 
        call TriggerAddAction(trigInvRight, function InventoryButtonClickRight) 
        call TriggerAddAction(trigInvConfig, function InventoryButtonClickConfig)

        // Register item swap trigger for all players
        loop 
            call TriggerRegisterPlayerSelectionEventBJ(trigShowButtons, Player(i), true) 
            // Old per-key regs removed; trigOSKeys handles all keys centrally now.

            // Register item swap events for each player
            call TriggerRegisterAnyUnitEventBJ(trigItemSwap, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER) 
            call TriggerRegisterAnyUnitEventBJ(trigItemSwap, EVENT_PLAYER_UNIT_ISSUED_ORDER) 
            call TriggerRegisterAnyUnitEventBJ(trigItemSwap, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER) 

            set udg_Bag_Page[GetPlayerHeroNumber(Player(i))] = 1

            set i = i + 1 
            exitwhen i > 23 
        endloop 
        
        call TriggerAddAction(trigShowButtons, function ShowButtonsActions) 
        call TriggerAddCondition(trigItemSwap, Condition(function ItemSwapConditions))
        call TriggerAddAction(trigItemSwap, function ItemSwapActions)

        // Create config panel & wire the page label to open it
        call CreateHotkeyConfigUI()
    endfunction

endlibrary
