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
        // The page the player last voluntarily switched to (via hotkey or button).
        // System-initiated relief switches do NOT update this.
        integer array PlayerIntendedPage
        // Fires after any page change so external systems (e.g. TasItemBag) can refresh.
        trigger PageChangedTrigger = CreateTrigger()
        
        private trigger trigInvMain = CreateTrigger() 
        private trigger trigInvLeft = CreateTrigger() 
        private trigger trigInvRight = CreateTrigger() 
        private trigger trigInvPage = CreateTrigger() 
        private trigger trigShowButtons = CreateTrigger() 
        private trigger trigItemSwap = CreateTrigger()
        private string array nextPageHotkeyLabel


        private string errorCantChangePage = "Cannot change inventory page while hero is stunned or rooted."
    endglobals 
    //===========================================================================

    // Update tooltip labels for one player (local safe)
    private function UpdateHotkeyTooltipsFor takes player whichPlayer returns nothing
        local integer id = GetPlayerId(whichPlayer)
        if GetLocalPlayer() == whichPlayer then
            if nextPageHotkeyLabel[id] != "" then
                call BlzFrameSetText(BlzGetFrameByName("MyScriptDialogButtonTooltip", 101), "Next page (|cffffcc00" + nextPageHotkeyLabel[id] + "|r)\n|cffc0c0c0Click to view next inventory page.|r")
            else
                call BlzFrameSetText(BlzGetFrameByName("MyScriptDialogButtonTooltip", 101), "Next page\n|cffc0c0c0Click to view next inventory page.|r")
            endif
            call BlzFrameSetText(BlzGetFrameByName("MyScriptDialogButtonTooltip", 102), "|cffc0c0c0Current inventory page.|r")
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

    // Public helpers for external systems (e.g. pickup-intent relief in TasItemBag)
    function MPInventoryGetMaxPages takes nothing returns integer
        return maxPages
    endfunction

    function MPInventoryGetPlayerIntendedPage takes player p returns integer
        return PlayerIntendedPage[GetPlayerId(p)]
    endfunction

    function MPInventoryPageHasEmptySlot takes player p, integer page returns boolean
        local integer slot = 1
        if p == null then
            return false
        endif
        if page < 1 or page > maxPages then
            return false
        endif
        loop
            exitwhen slot > 6
            if udg_P_Items[GetPItemsIndex(p, page, slot)] == null then
                return true
            endif
            set slot = slot + 1
        endloop
        return false
    endfunction

    function MPInventoryFindPageWithEmptySlot takes player p, integer skipPage returns integer
        local integer page = 1
        loop
            exitwhen page > maxPages
            if page != skipPage and MPInventoryPageHasEmptySlot(p, page) then
                return page
            endif
            set page = page + 1
        endloop
        return 0
    endfunction

    function ShowInventoryButtons takes player p, boolean b returns nothing
        if GetLocalPlayer() == p then 
            // call BlzFrameSetVisible(BlzGetFrameByName("ScriptDialogButton", 99), b)
            // call BlzFrameSetVisible(BlzGetFrameByName("ScriptDialogButton", 100), b)
            call BlzFrameSetVisible(BlzGetFrameByName("ScriptDialogButton", 101), b) 
            call BlzFrameSetVisible(BlzGetFrameByName("ScriptDialogButton", 102), b) 
        endif 
    endfunction

    private function InventoryButtonsSetPageText takes player whichPlayer, string s returns nothing 
        if GetLocalPlayer() == whichPlayer then 
            call BlzFrameSetText(BlzGetFrameByName("ScriptDialogButton", 102), s) 
        endif 
    endfunction 

    function MPInventorySetInterfaceVisible takes player p, boolean visible returns nothing
        local integer playerNum
        local string s
        if p == null then
            return
        endif

        if visible then
            set playerNum = GetPlayerHeroNumber(p)
            if udg_Bag_Page[playerNum] <= 0 or udg_Bag_Page[playerNum] > maxPages then
                set udg_Bag_Page[playerNum] = 1
            endif
            set s = "|cffffffff" + I2S(udg_Bag_Page[playerNum]) + "/" + I2S(maxPages) + "|r"
            call InventoryButtonsSetPageText(p, s)
            call UpdateHotkeyTooltipsFor(p)
        endif

        call ShowInventoryButtons(p, visible)
        set s = null
    endfunction

    function ResetInventory takes player p returns nothing
        local integer playerNum = GetPlayerHeroNumber(p)
        local integer bagNum = GetPlayerBagNumber(p)
        local integer i = 0
        
        // Reset all stored items for this player (equipped + extra bag)
        set i = 0
        loop
            exitwhen i >= udg_BAG_SIZE
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
        set PlayerIntendedPage[GetPlayerId(p)] = 1

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
            call TriggerExecute(PageChangedTrigger)
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
                // Check if WC3 engine consumed the item (e.g. auto-merged stacks).
                // A destroyed item still passes != null but GetItemTypeId returns 0.
                if GetItemTypeId(newItem) != 0 then
                    set udg_P_Items[GetPItemsIndex(p, currentPage, slotActuallyAddedTo)] = newItem
                    set slotActuallyAddedTo = slotActuallyAddedTo + 1
                endif
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

    function MPInventorySwitchToPage takes player p, integer targetPage returns boolean
        local integer playerNum = GetPlayerHeroNumber(p)
        local unit hero = udg_Heroes[playerNum]
        local string s

        if p == null then
            return false
        endif
        if targetPage < 1 or targetPage > maxPages then
            set hero = null
            return false
        endif
        if hero == null then
            return false
        endif
        if not IsAbleToChangePage(hero) then
            set hero = null
            return false
        endif
        if udg_Bag_Page[playerNum] == targetPage then
            set hero = null
            return true
        endif

        call DropInventoryToP_Items(p)
        set udg_Bag_Page[playerNum] = targetPage
        call LoadInventoryFromP_Items(p)
        set s = "|cffffffff" + I2S(udg_Bag_Page[playerNum]) + "/" + I2S(maxPages) + "|r"
        call InventoryButtonsSetPageText(p, s)
        call TriggerExecute(PageChangedTrigger)

        set s = null
        set hero = null
        return true
    endfunction

    function MPInventoryCycleToNextPage takes player p returns boolean
        local integer playerNum = 0
        local integer targetPage = 0

        if p == null then
            return false
        endif

        set playerNum = GetPlayerHeroNumber(p)
        if udg_Bag_Page[playerNum] >= maxPages then
            set targetPage = 1
        else
            set targetPage = udg_Bag_Page[playerNum] + 1
        endif

        set PlayerIntendedPage[GetPlayerId(p)] = targetPage
        return MPInventorySwitchToPage(p, targetPage)
    endfunction

    private function InventoryButtonClickMain takes nothing returns nothing 
        local string s = "" 
        local player p = GetTriggerPlayer() 
        local integer playerNum = GetPlayerHeroNumber(p)

        if IsAbleToChangePage(udg_Heroes[playerNum]) then
            // Main button removed.
            // call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 99), false)
            // call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 99), true)
            call DropInventoryToP_Items(p) 
            set udg_Bag_Page[playerNum] = 1 
            set PlayerIntendedPage[GetPlayerId(p)] = 1
            call LoadInventoryFromP_Items(p)
            set s =("|cffffffff" + I2S(udg_Bag_Page[playerNum]) + "/" + I2S(maxPages) + "|r") 
            call InventoryButtonsSetPageText(p, s) 
            call TriggerExecute(PageChangedTrigger)
        endif

        set s = null 
        set p = null 
    endfunction 

    private function InventoryButtonClickLeft takes nothing returns nothing 
        local string s = "" 
        local player p = GetTriggerPlayer() 
        local integer playerNum = GetPlayerHeroNumber(p)

        if IsAbleToChangePage(udg_Heroes[playerNum]) then
            // Previous button removed.
            // call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 100), false)
            // call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 100), true)
            call DropInventoryToP_Items(p) 
            call Debug("[LEFT] PAGE BEFORE CHANGE: " + I2S(udg_Bag_Page[playerNum])) 
            if(udg_Bag_Page[playerNum] <= 1) then 
                set udg_Bag_Page[playerNum] =(maxPages) 
            else 
                set udg_Bag_Page[playerNum] =(udg_Bag_Page[playerNum] - 1) 
            endif 
            call Debug("[LEFT] PAGE AFTER CHANGE: " + I2S(udg_Bag_Page[playerNum])) 
            set PlayerIntendedPage[GetPlayerId(p)] = udg_Bag_Page[playerNum]
            call LoadInventoryFromP_Items(p) 
            set s =("|cffffffff" + I2S(udg_Bag_Page[playerNum]) + "/" + I2S(maxPages) + "|r") 
            call InventoryButtonsSetPageText(p, s) 
            call TriggerExecute(PageChangedTrigger)
        endif

        set s = null 
        set p = null 
    endfunction 
    
    private function InventoryButtonClickRight takes nothing returns nothing 
        local player p = GetTriggerPlayer() 
        
        if MPInventoryCycleToNextPage(p) then
            call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 101), false) 
            call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 101), true) 
        endif

        set p = null 
    endfunction 

    private function InventoryButtonClickPage takes nothing returns nothing
        local player p = GetTriggerPlayer()

        if GetLocalPlayer() == p then
            call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 102), false)
            call BlzFrameSetEnable(BlzGetFrameByName("ScriptDialogButton", 102), true)
        endif

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

    function MPInventorySetNextPageHotkeyLabel takes player whichPlayer, string label returns nothing
        if whichPlayer == null then
            return
        endif
        set nextPageHotkeyLabel[GetPlayerId(whichPlayer)] = label
        call UpdateHotkeyTooltipsFor(whichPlayer)
    endfunction

    // ===================== ORIGINAL SYSTEM (unchanged logic) =====================

    function CreateInventoryButtons takes nothing returns nothing 
        local integer i = 0 
        // local framehandle invButtonMain = BlzCreateFrame("ScriptDialogButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 99)
        // local framehandle invButtonMainTooltipBackground = BlzCreateFrame("QuestButtonBaseTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 99)
        // local framehandle invButtonMainTooltipText = BlzCreateFrameByType("TEXT", "MyScriptDialogButtonTooltip", invButtonMainTooltipBackground, "", 99)
        // local framehandle invButtonLeft = BlzCreateFrame("ScriptDialogButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 100)
        // local framehandle invButtonLeftTooltipBackground = BlzCreateFrame("QuestButtonBaseTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 100)
        // local framehandle invButtonLeftTooltipText = BlzCreateFrameByType("TEXT", "MyScriptDialogButtonTooltip", invButtonLeftTooltipBackground, "", 100)
        local framehandle invButtonRight = BlzCreateFrame("ScriptDialogButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 101) 
        local framehandle invButtonRightTooltipBackground = BlzCreateFrame("QuestButtonBaseTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 101) 
        local framehandle invButtonRightTooltipText = BlzCreateFrameByType("TEXT", "MyScriptDialogButtonTooltip", invButtonRightTooltipBackground, "", 101) 
        local framehandle invButtonPage = BlzCreateFrame("ScriptDialogButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 102) 
        local framehandle invButtonPageTooltipBackground = BlzCreateFrame("QuestButtonBaseTemplate", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 102) 
        local framehandle invButtonPageTooltipText = BlzCreateFrameByType("TEXT", "MyScriptDialogButtonTooltip", invButtonPageTooltipBackground, "", 102) 

        // call BlzFrameSetSize(invButtonMain, 0.033, 0.025)
        // call BlzFrameSetSize(invButtonLeft, 0.033, 0.025)
        call BlzFrameSetSize(invButtonRight, 0.033, 0.025) 
        call BlzFrameSetSize(invButtonPage, 0.04, 0.025) 
        // call BlzFrameSetSize(invButtonMainTooltipText, 0, 0)
        // call BlzFrameSetSize(invButtonLeftTooltipText, 0, 0)
        call BlzFrameSetSize(invButtonRightTooltipText, 0, 0) 
        call BlzFrameSetSize(invButtonPageTooltipText, 0, 0) 

        call BlzFrameSetAbsPoint(invButtonPage, FRAMEPOINT_CENTER, 0.5513, 0.1425) 
        call BlzFrameSetAbsPoint(invButtonRight, FRAMEPOINT_CENTER, 0.60, 0.0575) 
        // call BlzFrameSetPoint(invButtonLeft, FRAMEPOINT_CENTER, invButtonRight, FRAMEPOINT_CENTER, 0, - 0.020)
        // call BlzFrameSetPoint(invButtonMain, FRAMEPOINT_CENTER, invButtonRight, FRAMEPOINT_CENTER, 0, 0.020)

        // call BlzFrameSetPoint(invButtonMainTooltipBackground, FRAMEPOINT_BOTTOMLEFT, invButtonMainTooltipText, FRAMEPOINT_BOTTOMLEFT, - 0.01, - 0.01)
        // call BlzFrameSetPoint(invButtonMainTooltipBackground, FRAMEPOINT_TOPRIGHT, invButtonMainTooltipText, FRAMEPOINT_TOPRIGHT, 0.01, 0.01)
        call BlzFrameSetPoint(invButtonRightTooltipBackground, FRAMEPOINT_BOTTOMLEFT, invButtonRightTooltipText, FRAMEPOINT_BOTTOMLEFT, - 0.01, - 0.01) 
        call BlzFrameSetPoint(invButtonRightTooltipBackground, FRAMEPOINT_TOPRIGHT, invButtonRightTooltipText, FRAMEPOINT_TOPRIGHT, 0.01, 0.01) 
        // call BlzFrameSetPoint(invButtonLeftTooltipBackground, FRAMEPOINT_BOTTOMLEFT, invButtonLeftTooltipText, FRAMEPOINT_BOTTOMLEFT, - 0.01, - 0.01)
        // call BlzFrameSetPoint(invButtonLeftTooltipBackground, FRAMEPOINT_TOPRIGHT, invButtonLeftTooltipText, FRAMEPOINT_TOPRIGHT, 0.01, 0.01)
        call BlzFrameSetPoint(invButtonPageTooltipBackground, FRAMEPOINT_BOTTOMLEFT, invButtonPageTooltipText, FRAMEPOINT_BOTTOMLEFT, - 0.01, - 0.01) 
        call BlzFrameSetPoint(invButtonPageTooltipBackground, FRAMEPOINT_TOPRIGHT, invButtonPageTooltipText, FRAMEPOINT_TOPRIGHT, 0.01, 0.01) 

        // call BlzFrameSetTooltip(invButtonMain, invButtonMainTooltipBackground)
        call BlzFrameSetTooltip(invButtonRight, invButtonRightTooltipBackground) 
        // call BlzFrameSetTooltip(invButtonLeft, invButtonLeftTooltipBackground)
        call BlzFrameSetTooltip(invButtonPage, invButtonPageTooltipBackground) 

        // call BlzFrameSetPoint(invButtonMainTooltipText, FRAMEPOINT_BOTTOM, invButtonMain, FRAMEPOINT_TOP, 0, 0.005)
        call BlzFrameSetPoint(invButtonRightTooltipText, FRAMEPOINT_BOTTOM, invButtonRight, FRAMEPOINT_TOP, 0, 0.005) 
        // call BlzFrameSetPoint(invButtonLeftTooltipText, FRAMEPOINT_BOTTOM, invButtonLeft, FRAMEPOINT_TOP, 0, 0.005)
        call BlzFrameSetPoint(invButtonPageTooltipText, FRAMEPOINT_BOTTOM, invButtonPage, FRAMEPOINT_TOP, 0, 0.005) 

        // call BlzFrameSetAlpha(invButtonMainTooltipBackground, 25)
        // call BlzFrameSetAlpha(invButtonLeftTooltipBackground, 25)
        call BlzFrameSetAlpha(invButtonRightTooltipBackground, 25) 
        call BlzFrameSetAlpha(invButtonPageTooltipBackground, 25) 

        // call BlzFrameSetEnable(invButtonMainTooltipText, false)
        call BlzFrameSetEnable(invButtonRightTooltipText, false) 
        // call BlzFrameSetEnable(invButtonLeftTooltipText, false)
        call BlzFrameSetEnable(invButtonPageTooltipText, false) 

        call UpdateHotkeyTooltipsFor(GetLocalPlayer())

        // call BlzFrameSetText(invButtonMain, "1")
        call BlzFrameSetText(invButtonRight, "->") 
        // call BlzFrameSetText(invButtonLeft, "<-")
        call BlzFrameSetText(invButtonPage, "|cffffffff1/" + I2S(maxPages) + "|r")

        // Register button events
        // call BlzTriggerRegisterFrameEvent(trigInvMain, invButtonMain, FRAMEEVENT_CONTROL_CLICK)
        // call BlzTriggerRegisterFrameEvent(trigInvLeft, invButtonLeft, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigInvRight, invButtonRight, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(trigInvPage, invButtonPage, FRAMEEVENT_CONTROL_CLICK)
 
        // call TriggerAddAction(trigInvMain, function InventoryButtonClickMain)
        // call TriggerAddAction(trigInvLeft, function InventoryButtonClickLeft)
        call TriggerAddAction(trigInvRight, function InventoryButtonClickRight) 
        call TriggerAddAction(trigInvPage, function InventoryButtonClickPage) 

        // Register item swap trigger for all players
        loop 
            // Configurable inventory hotkeys are now routed from SampleDialogSystem.

            // Register item swap events for each player
            call TriggerRegisterAnyUnitEventBJ(trigItemSwap, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER) 
            call TriggerRegisterAnyUnitEventBJ(trigItemSwap, EVENT_PLAYER_UNIT_ISSUED_ORDER) 
            call TriggerRegisterAnyUnitEventBJ(trigItemSwap, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER) 

            set udg_Bag_Page[GetPlayerHeroNumber(Player(i))] = 1
            set nextPageHotkeyLabel[i] = "Z"

            set i = i + 1 
            exitwhen i > 23 
        endloop 
        
        call TriggerAddCondition(trigItemSwap, Condition(function ItemSwapConditions))
        call TriggerAddAction(trigItemSwap, function ItemSwapActions)
    endfunction

endlibrary
