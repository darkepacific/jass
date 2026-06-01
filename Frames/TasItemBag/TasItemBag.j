library TasItemBag initializer init_function requires Table, RegisterPlayerEvent, HoverOriginButton, GenericFunctions, MultiPageInventorySystem, TasItemCost, NeatMessages, AcquireAndLoseItemHandler
    /*  TasItemBag 1.3
    by Tasyen, expanded by Darke Pacific
    Allows units to carry additional items in a bag. Items in the bag do not give any boni. 
    The Items in the bag are displayed in a scrollable UI which is opened/closed by a button.
    Items from the bag can be equiped or droped.
    Equiping an item moves the item from the bag into the warcraft 3 inventory.
    When the unit fullfils the Requirments to use it.

    TasItemBag puts all items gained into the bag, instead of the inventory.
    The items still trigger a pickup&drop Event.

    Affected by HeroScoreFrame-Options, if found in the same map

    Requires: 
    Table by Bribe https://www.hiveworkshop.com/threads/snippet-new-table.188084/
    war3mapImported\TasItemBag.fdf
    war3mapImported\TasItemBag.toc

    */
    globals
        private real PosX = 0.4//0.64//0.4
        private real PosY = 0.375//0.38//0.40
        private framepointtype Pos = FRAMEPOINT_TOP
        private integer Cols = 6
        private integer Rows = 4

        private real ShowButtonPosX = 0.48
        private real ShowButtonPosY = 0.145
        private framepointtype ShowButtonPos = FRAMEPOINT_TOPLEFT
        private string ShowButtonTexture = "ReplaceableTextures/CommandButtons/BTNDustOfAppearance"
        private string ShowButtonTextureDisabled = "ReplaceableTextures/CommandButtonsDisabled/DISBTNDustOfAppearance"
        private constant integer QUICK_USE_BUTTON_COUNT = 6
        private constant integer QUICK_USE_CONTEXT_START = 101
       
        // Show the bag button even when the inventory UI is hidden?
        public boolean ShowButtonAlwaysVisible = false

        private real TooltipWidth = 0.27
        public real TooltipScale = 1.0
        public boolean TooltipFixedPosition = true
        private real TooltipFixedPositionX = 0.79
        private real TooltipFixedPositionY = 0.16
        private framepointtype TooltipFixedPositionPoint = FRAMEPOINT_BOTTOMRIGHT

        // Can drop Items from the TasItemBag regardless of item/Inventory Flags
        public boolean IgnoreUndropAble = true

        // DestroyUndropAbleItems = true, When by death an undropable item would have to be droped from the TasItemBag, it is destroyed.
        private boolean DestroyUndropAbleItems = true
        
        // Bag capacity is driven by Cols*Rows and the udg_P_Items extra-bag layout.
        // can Equip only EquipClassLimit of one Item Class at one time
        // public integer EquipClassLimit = 999

        // Display the requirements in the Item Tooltip
        public boolean AddNeedText = true

        // ItemLevelRestriction = true; only a hero which level is equal or higher to the item's level can equip it
        private boolean ItemLevelRestriction = false

        //itemCode Require the unit to have ability X to equip
        //itemCode = AbilityCode
        // public Table ItemAbilityNeed

        private abilityintegerlevelfield AbilityFieldDrop
        private abilityintegerlevelfield AbilityFieldUse
        private abilityintegerlevelfield AbilityFieldCanDrop
        public timer TimerUpdate
        private timer SuppressNextBagPopupClearTimer

        // Debounced UI updates (avoid constant polling).
        private boolean UIUpdateScheduled = false
        public trigger Trigger
        public trigger TriggerESC
        public trigger TriggerItemGain
        public trigger TriggerItemLose
        public trigger TriggerItemUse
        public trigger TriggerSpellEffect
        public trigger TriggerUnitDeath
        public trigger TriggerUIOpen
        public trigger TriggerUIClose
        public trigger TriggerUIBagButton
        public trigger TriggerUIWheel
        public trigger TriggerUISwap
        public trigger TriggerUISell
        public trigger TriggerUISplit
        public trigger TriggerUISplitAccept
        public trigger TriggerUISplitMinus
        public trigger TriggerUISplitPlus
        public trigger TriggerUISplitCancel
        public trigger TriggerUIHover
        public trigger TriggerUIPanelHover
        public trigger TriggerUIMouseUp
        public trigger TriggerUIInventoryButton
        private trigger TriggerUIQuickUse
        private trigger TriggerUIQuickUseHotkey
        private trigger TriggerUIInventoryPanelHover
        private trigger TriggerUIBagCloseSync
        private trigger TriggerUIBagInsertSync
        private trigger TriggerUIBagDropSync
        private trigger TriggerUIQuickUseSync
        private framehandle InventoryPanelHoverFrame
        private framehandle array InventoryHitbox
        private integer array InventoryHoverSlot
        public trigger TriggerUnitOrder
        public integer array LastHoveredIndex
        // Drag tracking: origin type 0:none, 1:inventory slot, 2:bag slot
        public integer array DragOriginType
        public integer array DragOriginIndex
        public boolean array DragActive
        public boolean array PanelHover
        public boolean array InventoryPanelHover
    
        // TransferItem remembers the current Target
        public item array TransferItem
        public integer array TransferIndex
        public integer array SwapIndex
        private string array BagToggleHotkeyText
        private string array SellHotkeyText
        private oskeytype array QuickUseHotkey
        private string array QuickUseHotkeyText
        private boolean array QuickUseHotkeyConfigOpen
        private boolean array SellHotkeyArmed
        private boolean array ShowBagButtonForPlayer
        public boolean array IgnoreNextSelection // Need to refactor this out
        public boolean array SuppressNextBagPopup

        // Sell-mode state (toggled by shop sell button)
        public boolean array SellMode
        public unit array SellTargetShop

        // Split UI state (per-player)
        public integer array SplitRequested
        public integer array SplitAmount

        // Charged item stack cap (assumption for now).
        // Some items may need custom caps later; keep this centralized.
        private constant integer DEFAULT_MAX_CHARGES = 20

        // Swap highlight (per-player): shows an autocast-like border on the source slot while swap is armed
        private framehandle array SwapHighlight
        // Hover-highlight target slot while swap is armed (empty bag holes only)
        private integer array SwapHoverIndex

        private constant string SplitLabelPrefix = "|cffffcc00Split:|r "
        private constant integer POPUP_FRAME_LEVEL = 1000
        private constant integer SPLIT_FRAME_LEVEL = 1001
        private constant real SELL_RANGE = 525.0
        private constant real DETECT_VENDOR_RANGE = 120.0
        private constant integer HEARTSEEKER_ITEM_ID = 'I06X'
        private constant integer HEARTSEEKER_BASE_STACKS = 15
        private constant string BAG_CLOSE_SYNC_PREFIX = "TIBC"
        private constant string BAG_INSERT_SYNC_PREFIX = "TIBI"
        private constant string BAG_DROP_SYNC_PREFIX = "TIBD"
        private constant string QUICK_USE_SYNC_PREFIX = "TIBU"
        private constant string TOOLTIP_SELL_ICON_TEXTURE = "UI\\Widgets\\ToolTips\\Human\\ToolTipGoldIcon.blp"
        private constant real TOOLTIP_SELL_ICON_SIZE = 0.010
        private constant string TOOLTIP_SEPARATOR_TEXT = "|cff7f7f7f---------------------------------|r"
        private boolean SellValueCacheReady = false
        private integer VendorUnitCount = 0
        private integer array VendorUnitId
        private sound SwapSelectSound
        private sound SwapConfirmSound

        private unit array ItemGainTimerUnit
        private timer ItemGainTimer
        private timer QuickUseLocalTimer
        private item array ItemGainTimerItem
        private integer ItemGainTimerCount = 0
        private constant integer BAG_PAGE_SLOT_COUNT = 12

        private boolean array QuickUseActive
        private integer array QuickUseOriginalPage
        private integer array QuickUseRequestedSlot
        private item array QuickUseItem
        private integer array QuickUseItemTypeId
        private boolean array QuickUsePendingLocalActivate
        private integer array QuickUseTargetPage
        private boolean array QuickUseAwaitingTarget
        private boolean array QuickUseNativeTargeting
        private integer array QuickUseTargetArmDelayTicks
        private boolean array QuickUseIgnoreNextOrder
        private real array QuickUseFailTimeLeft
        private boolean array QuickUseRestorePending
        private boolean array QuickUseHotkeyDown
        private constant real QUICK_USE_FAIL_TIMEOUT = 0.12
        private constant real QUICK_USE_TARGET_RESOLVE_TIMEOUT = 6.00
        private constant integer QUICK_USE_TARGET_ARM_WAIT_TICKS = 6
        private constant integer QUICK_USE_TARGET_MODE_NONE = 0
        private constant integer QUICK_USE_TARGET_MODE_POINT = 1
        private constant integer QUICK_USE_TARGET_MODE_UNIT = 2
        private constant integer QUICK_USE_TARGET_MODE_DESTRUCTABLE = 3

        // Armed SELECT outside-click world drop (move first, then drop at click point)
        private timer WorldDropTimer
        private boolean array WorldDropActive
        private integer array WorldDropBagIndex
        private real array WorldDropX
        private real array WorldDropY
        private real array WorldDropTimeLeft
        private boolean array IgnoreNextWorldDropOrder
        private constant real WORLD_DROP_REACH = 140.0
        private constant real WORLD_DROP_TIMEOUT = 4.0

        // Track the most recent SMART item-target order per player.
        // Used to disambiguate pickup events where GetManipulatedItem can be
        // the pre-existing stack handle instead of the ground item handle.
        private item array LastSmartPickupTarget
        private real array LastSmartPickupTimeLeft
        // Keep this long enough for far-distance move-to-pickup travel.
        // A short window causes handle disambiguation to expire before pickup fires.
        private constant real LAST_SMART_PICKUP_WINDOW = 8.00

        // Option A2 pickup-intent relief: when smart-picking an item with full inventory,
        // switch to another page with a free slot only when near the target item.
        private timer PickupIntentTimer
        private boolean array PickupIntentActive
        private unit array PickupIntentHero
        private item array PickupIntentItem
        private real array PickupIntentTimeLeft
        private real array PickupIntentReliefStaleTime
        private boolean array PickupIntentProcessed
        private integer array PickupIntentOriginalPage
        private integer array PickupIntentSwitchPage
        private constant integer ORDER_ID_SMART = 851971
        private constant real PICKUP_INTENT_REACH = 250.0 // CHANGED THIS
        private constant real PICKUP_INTENT_TIMEOUT = 8.0  //CHANGED THIS
        private constant real PICKUP_INTENT_RELIEF_STALE_DELAY = 2.50
        private constant real INVENTORY_HITBOX_PAD = 0.006
        private constant real INVENTORY_PANEL_HOVER_PAD = 0.018
        // Pickup relief mode:
        // false = pure A2 (near-item timing only), true = immediate-first then fallback (A1-style).
        // Current default: immediate-first (smoother feel in live play).
        public boolean PickupIntentUseImmediateRelief = true

        // Option A: short local suppression window for false-positive native
        // "Inventory is full" feedback during assisted pickup timing.
        private boolean array PickupWarnSuppressActive
        private real array PickupWarnSuppressTimeLeft
        private constant real PICKUP_WARN_SUPPRESS_WINDOW = 0.40

        // Option D placeholder: race-aware full feedback hook.
        // Keep behavior identical for now (same ErrorMessage) until custom sounds are imported.
        private constant string BAG_FULL_MESSAGE = "Bag is full."
        private constant string INVENTORY_PAGES_FULL_MESSAGE = "Inventory pages are full."
        // private constant string INVENTORY_FULL_MESSAGE = "Inventory is full."
        private constant string PAGES_FULL_WARNING_MESSAGE = "Warning! Auto-pickup will not work when both pages are full."
        private boolean array PagesFullWarningArmed
        private boolean array BagPanelOpen

        // ================================================================
        // P_Items Layout (single source of truth = udg_BAG_SIZE)
        // ================================================================
        // We intentionally keep the stride/bag-size as a GUI-style global (udg_BAG_SIZE)
        // so it stays easy to reference from GUI-heavy systems.
        //
        // Conventions:
        // - Slot 0 reserved
        // - Equipped slots come first (page-based inventory)
        // - Extra bag slots come after equipped
        //
        // Extra bag size is driven by these UI grid dimensions.
        // Total stride per player must be configured via udg_BAG_SIZE.
        private constant integer PITEMS_EXTRA_COLS = 6
        private constant integer PITEMS_EXTRA_ROWS = 4
        private constant integer PITEMS_EXTRA_SLOTS = PITEMS_EXTRA_COLS * PITEMS_EXTRA_ROWS
        // Page display rows: shows items from BOTH inventory pages
        private constant integer PAGE_DISPLAY_START = PITEMS_EXTRA_SLOTS + 1
        private constant integer PAGE1_DISPLAY_START = PAGE_DISPLAY_START          // 25
        private constant integer PAGE2_DISPLAY_START = PAGE_DISPLAY_START + 6      // 31
        private constant integer PAGE_DISPLAY_COUNT = 12
        // Highest interactive slot index (bag 1-24 + page display 25-36)
        private constant integer MAX_INTERACTIVE_SLOT = PAGE_DISPLAY_START + PAGE_DISPLAY_COUNT - 1
    endglobals

    // Bag system is enabled only for these fixed 1-based player numbers.
    private function BagEnabledForPlayer takes player p returns boolean
        if p == null then
            return false
        endif
        return (GetPlayerController(p) == MAP_CONTROL_USER and GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING and GetPlayerNumber(p) < 11)
    endfunction

    private function GetSellButtonCaption takes integer pId returns string
        if SellHotkeyText[pId] == "" then
            return "SELL"
        endif
        return "SELL (|cffffffff" + SellHotkeyText[pId] + "|r)"
    endfunction

    private function GetBagToggleHintText takes integer pId returns string
        if BagToggleHotkeyText[pId] == "" then
            return "|cffc0c0c0Toggle Bag:|r |cffff8080Unbound|r"
        endif
        return "|cffc0c0c0Toggle Bag:|r |cffffffff" + BagToggleHotkeyText[pId] + "|r"
    endfunction

    private function UpdateSellPopupButtonText takes player p returns nothing
        if p == null then
            return
        endif
        if GetLocalPlayer() == p then
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagPopUpButtonSell", 0), GetSellButtonCaption(GetPlayerId(p)))
        endif
    endfunction

    private function UpdateBagToggleHintText takes player p returns nothing
        if p == null then
            return
        endif
        if GetLocalPlayer() == p then
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagHintText", 0), GetBagToggleHintText(GetPlayerId(p)))
        endif
    endfunction

    function TasItemBagSetSellHotkeyLabel takes player p, string label returns nothing
        local integer pId
        if p == null then
            return
        endif
        set pId = GetPlayerId(p)
        set SellHotkeyText[pId] = label
        call UpdateSellPopupButtonText(p)
    endfunction

    function TasItemBagSetToggleHotkeyLabel takes player p, string label returns nothing
        local integer pId
        if p == null then
            return
        endif
        set pId = GetPlayerId(p)
        set BagToggleHotkeyText[pId] = label
        call UpdateBagToggleHintText(p)
    endfunction

    private function SetSellHotkeyArmed takes integer pId, boolean armed returns nothing
        set SellHotkeyArmed[pId] = armed
    endfunction

    private function HideBagPopupPanels takes player p returns nothing
        if p == null then
            return
        endif
        if GetLocalPlayer() == p then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
        endif
    endfunction

    private function ClearBagPanelTransientState takes integer pId returns nothing
        set PanelHover[pId] = false
        set InventoryPanelHover[pId] = false
        set LastHoveredIndex[pId] = 0
        set InventoryHoverSlot[pId] = 0
        set DragOriginType[pId] = 0
        set DragOriginIndex[pId] = 0
        set DragActive[pId] = false
    endfunction

    private function SetBagPanelOpen takes player p, boolean open returns nothing
        local integer pId
        if p == null then
            return
        endif

        set pId = GetPlayerId(p)
        set BagPanelOpen[pId] = open
        if not open then
            call ClearBagPanelTransientState(pId)
        endif

        if GetLocalPlayer() == p then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), open)
            if InventoryPanelHoverFrame != null then
                call BlzFrameSetEnable(InventoryPanelHoverFrame, open)
                call BlzFrameSetVisible(InventoryPanelHoverFrame, open)
            endif
            if not open then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            endif
        endif
    endfunction

    // Maps a 1-based EXTRA-bag slot to the owning player's udg_P_Items index.
    // Page slots are 1..12; extra-bag slots are 13..36.
    private function BagSlotArrayIndex takes integer playerKey, integer bagSlot returns integer
        local integer slot = GetPlayerBagNumber(Player(playerKey)) + BAG_PAGE_SLOT_COUNT + bagSlot
        // call Debug("BagSlotArrayIndex: bagSlot=" + I2S(slot))   
        return slot
    endfunction

    // Unified index resolver: bag slots 1-24 use BagSlotArrayIndex,
    // page display slots 25-30 = page 1, 31-36 = page 2.
    private function SlotToArrayIndex takes integer playerKey, integer slotIndex returns integer
        if slotIndex >= PAGE2_DISPLAY_START and slotIndex <= MAX_INTERACTIVE_SLOT then
            return GetPItemsIndex(Player(playerKey), 2, slotIndex - PAGE2_DISPLAY_START + 1)
        endif
        if slotIndex >= PAGE1_DISPLAY_START and slotIndex < PAGE2_DISPLAY_START then
            return GetPItemsIndex(Player(playerKey), 1, slotIndex - PAGE1_DISPLAY_START + 1)
        endif
        return BagSlotArrayIndex(playerKey, slotIndex)
    endfunction

    // Prime item cost cache from the save-item list once.
    // Uses a trailing-empty cutoff to avoid scanning unbounded array tails.
    private function PrimeSellValueCache takes nothing returns nothing
        local integer i = 1
        local integer emptyRun = 0
        local integer itemCode
        local integer found = 0
        if SellValueCacheReady then
            return
        endif
        loop
            exitwhen i > 2000 or emptyRun >= 200
            set itemCode = udg_SaveItemType[i]
            if itemCode > 0 then
                call TasItemCaclCost(itemCode)
                set found = found + 1
                set emptyRun = 0
            else
                set emptyRun = emptyRun + 1
            endif
            set i = i + 1
        endloop
        if found > 0 then
            set SellValueCacheReady = true
        endif
    endfunction

    private function GetTooltipSellValue takes item it returns integer
        local integer itemType
        local integer goldGain
        local integer stackCount

        if it == null or not IsItemPawnable(it) then
            return 0
        endif

        if not SellValueCacheReady then
            return 0
        endif

        set itemType = GetItemTypeId(it)
        set goldGain = TasItemGetCostGold(itemType) / 2

        if itemType == HEARTSEEKER_ITEM_ID then
            set stackCount = GetItemCharges(it)
            if stackCount > HEARTSEEKER_BASE_STACKS then
                set goldGain = goldGain + ((goldGain * (stackCount - HEARTSEEKER_BASE_STACKS)) / HEARTSEEKER_BASE_STACKS)
            endif
        endif

        return goldGain
    endfunction

    private function BuildBagItemTooltip takes item it, boolean includeNeedText returns string
        local string tooltipText
        local string extraText = ""

        if it == null then
            return ""
        endif

        if includeNeedText and ItemLevelRestriction then
            set extraText = "|nNEED " + GetLocalizedString("REQUIREDLEVELTOOLTIP") + " " + I2S(GetItemLevel(it))
        endif

        set tooltipText = GetItemName(it)
        if IsItemPawnable(it) then
            // Reserve one line for the dedicated sell icon + value frames.
            set tooltipText = tooltipText + "|n "
        endif
        set tooltipText = tooltipText + "|n" + TOOLTIP_SEPARATOR_TEXT + "|n" + BlzGetItemExtendedTooltip(it)

        if extraText != "" then
            set tooltipText = tooltipText + "|n|n" + extraText
        endif

        return tooltipText
    endfunction

    private function BuildQuickUseTooltip takes item it, integer slot returns string
        if it == null then
            return ""
        endif

        return BuildBagItemTooltip(it, false) //"|cffc0c0c0Other Page Slot:|r |cffffffff" + I2S(slot) + "|r|n|n" + BuildBagItemTooltip(it, false)
    endfunction

    private function UpdateTooltipSellDisplay takes integer createContext, item it returns nothing
        local framehandle sellIcon = BlzGetFrameByName("TasItemBagTooltipSellIcon", createContext)
        local framehandle sellText = BlzGetFrameByName("TasItemBagTooltipSellText", createContext)
        local integer sellValue

        if sellIcon == null or sellText == null then
            set sellIcon = null
            set sellText = null
            return
        endif

        if it != null and IsItemPawnable(it) then
            set sellValue = GetTooltipSellValue(it)
            call BlzFrameSetText(sellText, "|cffffcc00" + I2S(sellValue) + "|r")
            call BlzFrameSetVisible(sellIcon, true)
            call BlzFrameSetVisible(sellText, true)
        else
            call BlzFrameSetText(sellText, "")
            call BlzFrameSetVisible(sellIcon, false)
            call BlzFrameSetVisible(sellText, false)
        endif

        set sellIcon = null
        set sellText = null
    endfunction

    private function QuickUseContext takes integer slot returns integer
        return QUICK_USE_CONTEXT_START + slot - 1
    endfunction

    private function GetOtherInventoryPage takes player p returns integer
        local integer currentPage

        if p == null then
            return 0
        endif

        set currentPage = udg_Bag_Page[GetPlayerNumber(p)]
        if currentPage == 1 then
            return 2
        elseif currentPage == 2 then
            return 1
        endif
        return 0
    endfunction

    private function SetQuickUseBarVisible takes boolean visible returns nothing
        local integer slot = 1

        loop
            exitwhen slot > QUICK_USE_BUTTON_COUNT
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlot", QuickUseContext(slot)), visible)
            set slot = slot + 1
        endloop

        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagQuickUseLabel", 0), visible)
    endfunction

    private function QuickUseBindingIndex takes integer pId, integer slot returns integer
        return (pId * QUICK_USE_BUTTON_COUNT) + slot
    endfunction

    private function QuickUseKeyToString takes oskeytype key returns string
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

        return ""
    endfunction

    private function QuickUseDefaultHotkey takes integer slot returns oskeytype
        if slot == 1 then
            return OSKEY_1
        elseif slot == 2 then
            return OSKEY_2
        elseif slot == 3 then
            return OSKEY_3
        elseif slot == 4 then
            return OSKEY_4
        elseif slot == 5 then
            return OSKEY_5
        elseif slot == 6 then
            return OSKEY_6
        endif

        return null
    endfunction

    private function GetQuickUseButtonCaption takes integer pId, integer slot returns string
        local string label = QuickUseHotkeyText[QuickUseBindingIndex(pId, slot)]

        if label == "" then
            return "-"
        endif

        return label
    endfunction

    private function UpdateQuickUseButtonCaption takes player p, integer slot returns nothing
        if p == null or slot < 1 or slot > QUICK_USE_BUTTON_COUNT then
            return
        endif

        if GetLocalPlayer() == p then
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButton", QuickUseContext(slot)), "")
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagQuickUseHotkeyText", QuickUseContext(slot)), GetQuickUseButtonCaption(GetPlayerId(p), slot))
        endif
    endfunction

    private function UpdateQuickUseButtonCaptions takes player p returns nothing
        local integer slot = 1

        if p == null then
            return
        endif

        loop
            exitwhen slot > QUICK_USE_BUTTON_COUNT
            call UpdateQuickUseButtonCaption(p, slot)
            set slot = slot + 1
        endloop
    endfunction

    private function QuickUseSetHotkey takes integer pId, integer slot, oskeytype key, boolean refresh returns nothing
        local integer index

        if slot < 1 or slot > QUICK_USE_BUTTON_COUNT then
            return
        endif

        set index = QuickUseBindingIndex(pId, slot)
        set QuickUseHotkey[index] = key
        set QuickUseHotkeyText[index] = QuickUseKeyToString(key)

        if refresh then
            call UpdateQuickUseButtonCaption(Player(pId), slot)
        endif
    endfunction

    private function QuickUseResetHotkeysForPlayer takes integer pId, boolean refresh returns nothing
        local integer slot = 1

        loop
            exitwhen slot > QUICK_USE_BUTTON_COUNT
            call QuickUseSetHotkey(pId, slot, QuickUseDefaultHotkey(slot), refresh)
            set slot = slot + 1
        endloop
    endfunction

    function TasItemBagSetQuickUseHotkey takes player p, integer slot, oskeytype key returns nothing
        if p == null then
            return
        endif

        call QuickUseSetHotkey(GetPlayerId(p), slot, key, true)
    endfunction

    function TasItemBagGetQuickUseHotkey takes player p, integer slot returns oskeytype
        if p == null or slot < 1 or slot > QUICK_USE_BUTTON_COUNT then
            return null
        endif

        return QuickUseHotkey[QuickUseBindingIndex(GetPlayerId(p), slot)]
    endfunction

    function TasItemBagGetQuickUseHotkeyLabel takes player p, integer slot returns string
        if p == null or slot < 1 or slot > QUICK_USE_BUTTON_COUNT then
            return ""
        endif

        return QuickUseHotkeyText[QuickUseBindingIndex(GetPlayerId(p), slot)]
    endfunction

    function TasItemBagResetQuickUseHotkeys takes player p returns nothing
        if p == null then
            return
        endif

        call QuickUseResetHotkeysForPlayer(GetPlayerId(p), true)
    endfunction

    function TasItemBagSetQuickUseHotkeyConfigOpen takes player p, boolean open returns nothing
        local integer pId
        local integer slot = 1

        if p == null then
            return
        endif

        set pId = GetPlayerId(p)
        set QuickUseHotkeyConfigOpen[pId] = open

        if open then
            loop
                exitwhen slot > QUICK_USE_BUTTON_COUNT
                set QuickUseHotkeyDown[QuickUseBindingIndex(pId, slot)] = false
                set slot = slot + 1
            endloop
        endif
    endfunction

    private function RenderQuickUseSlot takes integer slot, item it returns nothing
        local integer context = QuickUseContext(slot)

        if it != null and GetItemTypeId(it) == 0 then
            set it = null
        endif

        call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButton", context), "")
        call BlzFrameSetText(BlzGetFrameByName("TasItemBagQuickUseHotkeyText", context), GetQuickUseButtonCaption(GetPlayerId(GetLocalPlayer()), slot))

        if it != null then
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButton", context), true)
            call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", context), BlzGetItemIconPath(it), 0, true)
            call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", context), BlzGetItemIconPath(it), 0, true)
            call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", context), BlzGetItemIconPath(it), 0, true)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", context), true)
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonTooltip", context), BuildQuickUseTooltip(it, slot))
            call UpdateTooltipSellDisplay(context, it)

            if GetItemCharges(it) > 0 then
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", context), I2S(GetItemCharges(it)))
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", context), true)
            else
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", context), false)
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", context), "")
            endif
        else
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButton", context), false)
            call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", context), "", 0, true)
            call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", context), "", 0, true)
            call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", context), "", 0, true)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", context), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", context), false)
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", context), "")
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonTooltip", context), "")
            call UpdateTooltipSellDisplay(context, null)
        endif
    endfunction

    private function ClearQuickUseState takes integer pId returns nothing
        set QuickUseActive[pId] = false
        set QuickUseOriginalPage[pId] = 0
        set QuickUseRequestedSlot[pId] = 0
        set QuickUseItem[pId] = null
        set QuickUseItemTypeId[pId] = 0
        set QuickUsePendingLocalActivate[pId] = false
        set QuickUseTargetPage[pId] = 0
        set QuickUseAwaitingTarget[pId] = false
        set QuickUseNativeTargeting[pId] = false
        set QuickUseTargetArmDelayTicks[pId] = 0
        set QuickUseIgnoreNextOrder[pId] = false
        set QuickUseFailTimeLeft[pId] = 0.0
        set QuickUseRestorePending[pId] = false
    endfunction

    private function QueueQuickUseRestore takes integer pId returns nothing
        if not QuickUseActive[pId] then
            return
        endif

        set QuickUsePendingLocalActivate[pId] = false
        set QuickUseAwaitingTarget[pId] = false
        set QuickUseNativeTargeting[pId] = false
        set QuickUseTargetArmDelayTicks[pId] = 0
        set QuickUseIgnoreNextOrder[pId] = false
        set QuickUseFailTimeLeft[pId] = 0.0
        set QuickUseRestorePending[pId] = true
    endfunction

    private function RestoreQuickUseForPlayer takes player p, unit hero returns boolean
        local integer pId
        local integer playerNum
        local integer currentPage
        local integer originalPage

        if p == null then
            return false
        endif

        set pId = GetPlayerId(p)
        if not QuickUseActive[pId] then
            return true
        endif

        if hero == null or GetWidgetLife(hero) <= 0.405 then
            call ClearQuickUseState(pId)
            return false
        endif

        set playerNum = GetPlayerNumber(p)
        set currentPage = udg_Bag_Page[playerNum]
        set originalPage = QuickUseOriginalPage[pId]
        if originalPage <= 0 or currentPage == originalPage then
            call ClearQuickUseState(pId)
            return true
        endif

        if MPInventorySwitchToPage(p, originalPage) then
            call ClearQuickUseState(pId)
            return true
        endif

        return false
    endfunction

    private function RequestQuickUseSync takes player p, integer slot returns nothing
        if p == null then
            return
        endif
        if slot < 0 or slot > QUICK_USE_BUTTON_COUNT then
            return
        endif
        if not BagEnabledForPlayer(p) then
            return
        endif

        if GetLocalPlayer() == p then
            call BlzSendSyncData(QUICK_USE_SYNC_PREFIX, I2S(slot))
        endif
    endfunction

    private function RequestQuickUseCancelSync takes player p returns nothing
        call RequestQuickUseSync(p, 0)
    endfunction

    private function QuickUseHotkeyStateIndex takes integer pId, integer slot returns integer
        return QuickUseBindingIndex(pId, slot)
    endfunction

    private function QuickUseHotkeyToSlot takes integer pId, oskeytype key returns integer
        local integer slot = 1

        loop
            exitwhen slot > QUICK_USE_BUTTON_COUNT
            if QuickUseHotkey[QuickUseBindingIndex(pId, slot)] == key then
                return slot
            endif
            set slot = slot + 1
        endloop

        return 0
    endfunction

    private function RegisterQuickUseHotkeyKey takes player p, oskeytype key returns nothing
        call BlzTriggerRegisterPlayerKeyEvent(TriggerUIQuickUseHotkey, p, key, 0, true)
        call BlzTriggerRegisterPlayerKeyEvent(TriggerUIQuickUseHotkey, p, key, 0, false)
    endfunction

    private function QuickUseHotkeyAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local integer slot
        local integer stateIndex

        if QuickUseHotkeyConfigOpen[pId] then
            set p = null
            return
        endif

        set slot = QuickUseHotkeyToSlot(pId, BlzGetTriggerPlayerKey())

        if slot <= 0 then
            set p = null
            return
        endif

        set stateIndex = QuickUseHotkeyStateIndex(pId, slot)
        if BlzGetTriggerPlayerIsKeyDown() then
            if QuickUseHotkeyDown[stateIndex] then
                set p = null
                return
            endif

            set QuickUseHotkeyDown[stateIndex] = true
            if BagEnabledForPlayer(p) and ShowBagButtonForPlayer[pId] then
                call RequestQuickUseSync(p, slot)
            endif
        else
            set QuickUseHotkeyDown[stateIndex] = false
        endif

        set p = null
    endfunction

    private function QuickUseTrackedItemTypeId takes integer pId returns integer
        local item it = QuickUseItem[pId]
        local integer itemType = QuickUseItemTypeId[pId]

        if it != null and GetItemTypeId(it) != 0 then
            set itemType = GetItemTypeId(it)
            set QuickUseItemTypeId[pId] = itemType
        endif

        set it = null
        return itemType
    endfunction

    private function PrepareQuickUseTargetingLocal takes player p, unit hero returns nothing
        local integer pId
        local item it
        local integer trackedItemType
        local string prompt

        if p == null or hero == null then
            return
        endif

        set pId = GetPlayerId(p)
        set it = QuickUseItem[pId]
        set trackedItemType = QuickUseTrackedItemTypeId(pId)
        if GetLocalPlayer() == p then
            call SelectUnitForPlayerSingle(hero, p)
        endif
        if trackedItemType != 0 then
            if trackedItemType == 'I08K' or trackedItemType == 'I08S' then
                if it != null and GetItemTypeId(it) != 0 then
                    set prompt = "Click " + GetItemName(it) + " to use it."
                else
                    set prompt = "Click the item to use it."
                endif
            else
                if it != null and GetItemTypeId(it) != 0 then
                    set prompt = "Right-click a target for " + GetItemName(it) + ", or click the item."
                else
                    set prompt = "Right-click a target."
                endif
            endif
            call NeatErrorMessage(prompt, p)
        else
            call NeatErrorMessage("Right-click a target.", p)
        endif

        set prompt = null
        set it = null
    endfunction

    private function StartQuickUseTargetResolve takes integer pId returns nothing
        if not QuickUseActive[pId] then
            return
        endif

        set QuickUseAwaitingTarget[pId] = false
        set QuickUseNativeTargeting[pId] = false
        set QuickUseTargetArmDelayTicks[pId] = 0
        set QuickUseFailTimeLeft[pId] = QUICK_USE_TARGET_RESOLVE_TIMEOUT
    endfunction

    private function ActivateQuickUseFrameLocal takes player p, framehandle frame returns nothing
        if p == null or frame == null then
            return
        endif

        if GetLocalPlayer() == p and BlzFrameGetEnable(frame) then
            call BlzFrameSetEnable(frame, false)
            call BlzFrameSetEnable(frame, true)
            call BlzFrameClick(frame)
        endif
    endfunction

    private function QuickUseLiveInventorySlot takes integer pId, unit hero returns integer
        local integer slotIndex = 0
        local item slotItem
        local item targetItem = QuickUseItem[pId]
        local integer targetType = QuickUseTrackedItemTypeId(pId)
        local integer targetCharges

        if hero == null or targetType == 0 then
            set targetItem = null
            return -1
        endif

        if targetItem != null and GetItemTypeId(targetItem) != 0 then
            set targetCharges = GetItemCharges(targetItem)
        else
            set targetCharges = 0
        endif

        loop
            exitwhen slotIndex >= bj_MAX_INVENTORY

            set slotItem = UnitItemInSlot(hero, slotIndex)
            if slotItem == targetItem then
                set slotItem = null
                set targetItem = null
                return slotIndex
            endif

            set slotIndex = slotIndex + 1
        endloop

        set slotIndex = 0
        loop
            exitwhen slotIndex >= bj_MAX_INVENTORY

            set slotItem = UnitItemInSlot(hero, slotIndex)
            if slotItem != null and GetItemTypeId(slotItem) == targetType and (targetCharges <= 0 or GetItemCharges(slotItem) == targetCharges) then
                set QuickUseItem[pId] = slotItem
                set slotItem = null
                set targetItem = null
                return slotIndex
            endif

            set slotIndex = slotIndex + 1
        endloop

        set slotIndex = 0
        loop
            exitwhen slotIndex >= bj_MAX_INVENTORY

            set slotItem = UnitItemInSlot(hero, slotIndex)
            if slotItem != null and GetItemTypeId(slotItem) == targetType then
                set QuickUseItem[pId] = slotItem
                set slotItem = null
                set targetItem = null
                return slotIndex
            endif

            set slotIndex = slotIndex + 1
        endloop

        set slotItem = null
        set targetItem = null
        return -1
    endfunction

    private function QuickUseTargetAbilityIdForItemType takes integer itemType returns integer
        if itemType == 'I08K' then
            // Blazing Torch (Point Target)
            return 'A0ER'
        elseif itemType == 'I099' then
            // Critter Catcher (Unit Target)
            return 'A0GA'
        elseif itemType == 'I0A5' then
            // Dragon Catcher (Unit Target)
            return 'A0GI'
        elseif itemType == 'I08S' then
            // Grove Acorn (Point Target)
            return 'A0F7'
        elseif itemType == 'I07G' then
            // Noxious Potion (Unit Target)
            return 'APLG'
        elseif itemType == 'I097' then
            // Sea Meat (Doodad Target)
            return 'A0G8'
        elseif itemType == 'I07A' then
            // Whip (Unit Target)
            return 'Ashs'
        endif

        return 0
    endfunction

    private function QuickUseTargetAbilityIdForItem takes item it returns integer
        if it == null or GetItemTypeId(it) == 0 then
            return 0
        endif

        return QuickUseTargetAbilityIdForItemType(GetItemTypeId(it))
    endfunction

    private function QuickUseTargetCommandButtonIndex takes integer pId, unit hero returns integer
        local item it = QuickUseItem[pId]
        local integer abilityId
        local integer primaryIndex
        local integer alternateIndex
        local ability unitAbility
        local integer buttonX
        local integer buttonY

        if hero == null or it == null or GetItemTypeId(it) == 0 then
            set it = null
            return -1
        endif

        set abilityId = QuickUseTargetAbilityIdForItemType(QuickUseTrackedItemTypeId(pId))
        if abilityId == 0 then
            set it = null
            return -1
        endif

        set unitAbility = BlzGetUnitAbility(hero, abilityId)
        if unitAbility == null then
            set it = null
            set unitAbility = null
            return -1
        endif

        set buttonX = BlzGetAbilityIntegerField(unitAbility, ABILITY_IF_BUTTON_POSITION_NORMAL_X)
        set buttonY = BlzGetAbilityIntegerField(unitAbility, ABILITY_IF_BUTTON_POSITION_NORMAL_Y)

        set unitAbility = null
        set it = null

        if buttonX < 0 or buttonX > 3 or buttonY < 0 or buttonY > 2 then
            return -1
        endif

        set primaryIndex = (buttonY * 4) + buttonX
        set alternateIndex = ((2 - buttonY) * 4) + buttonX

        if primaryIndex >= 0 and primaryIndex < 12 and BlzFrameIsVisible(BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, primaryIndex)) then
            return primaryIndex
        endif
        if alternateIndex >= 0 and alternateIndex < 12 and alternateIndex != primaryIndex and BlzFrameIsVisible(BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, alternateIndex)) then
            return alternateIndex
        endif

        return primaryIndex
    endfunction

    private function QuickUseTargetModeForItemType takes integer itemType returns integer
        local integer abilityId = QuickUseTargetAbilityIdForItemType(itemType)

        if abilityId == 'A0ER' or abilityId == 'A0F7' then
            return QUICK_USE_TARGET_MODE_POINT
        elseif abilityId == 'A0G8' then
            return QUICK_USE_TARGET_MODE_DESTRUCTABLE
        elseif abilityId != 0 then
            return QUICK_USE_TARGET_MODE_UNIT
        endif

        return QUICK_USE_TARGET_MODE_NONE
    endfunction

    private function QuickUseItemNeedsExplicitTarget takes item it returns boolean
        return QuickUseTargetAbilityIdForItem(it) != 0
    endfunction

    private function BeginQuickUseTargetingLocal takes player p, unit hero returns nothing
        local integer pId
        local integer slotIndex
        local integer commandButtonIndex
        local integer targetMode

        if p == null or hero == null then
            return
        endif

        set pId = GetPlayerId(p)
        set slotIndex = QuickUseLiveInventorySlot(pId, hero)
        set commandButtonIndex = -1
        set targetMode = QuickUseTargetModeForItemType(QuickUseTrackedItemTypeId(pId))
        set QuickUseNativeTargeting[pId] = false

        if slotIndex >= 0 then
            set QuickUseRequestedSlot[pId] = slotIndex + 1
        endif

        set QuickUseAwaitingTarget[pId] = true
        call PrepareQuickUseTargetingLocal(p, hero)
        if targetMode == QUICK_USE_TARGET_MODE_POINT then
            return
        endif
        if GetLocalPlayer() == p then
            set commandButtonIndex = QuickUseTargetCommandButtonIndex(pId, hero)
            if commandButtonIndex >= 0 then
                call ActivateQuickUseFrameLocal(p, BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, commandButtonIndex))
            elseif slotIndex >= 0 and slotIndex < bj_MAX_INVENTORY then
                call ActivateQuickUseFrameLocal(p, BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, slotIndex))
            endif
        endif
    endfunction

    private function TryQuickUseImmediateActivation takes integer pId, unit hero returns boolean
        local item it

        if hero == null or QuickUseLiveInventorySlot(pId, hero) < 0 then
            set it = null
            return false
        endif

        set it = QuickUseItem[pId]
        if it == null or GetItemTypeId(it) == 0 then
            set it = null
            return false
        endif

        if UnitUseItem(hero, it) then
            set it = null
            return true
        endif

        set it = null
        return false
    endfunction

    private function TryQuickUseTargetedActivation takes integer pId, unit hero returns boolean
        local item it
        local unit targetUnit = GetOrderTargetUnit()
        local item targetItem = GetOrderTargetItem()
        local destructable targetDest = GetOrderTargetDestructable()
        local boolean issued = false

        if hero == null or QuickUseLiveInventorySlot(pId, hero) < 0 then
            set targetDest = null
            set targetItem = null
            set targetUnit = null
            return false
        endif

        set it = QuickUseItem[pId]
        if it == null or GetItemTypeId(it) == 0 then
            set targetDest = null
            set targetItem = null
            set targetUnit = null
            set it = null
            return false
        endif

        set QuickUseIgnoreNextOrder[pId] = true
        set QuickUseNativeTargeting[pId] = false
        if targetUnit != null then
            set issued = UnitUseItemTarget(hero, it, targetUnit)
        elseif targetItem != null then
            set issued = UnitUseItemTarget(hero, it, targetItem)
        elseif targetDest != null then
            set issued = UnitUseItemTarget(hero, it, targetDest)
        else
            set issued = UnitUseItemPoint(hero, it, GetOrderPointX(), GetOrderPointY())
        endif

        if issued then
            call StartQuickUseTargetResolve(pId)
        else
            set QuickUseIgnoreNextOrder[pId] = false
        endif

        set targetDest = null
        set targetItem = null
        set targetUnit = null
        set it = null
        return issued
    endfunction

    private function IsQuickUseCancelOrder takes integer orderId returns boolean
        return orderId == ORDER_ID_SMART or orderId == OrderId("move") or orderId == OrderId("stop") or orderId == OrderId("holdposition") or orderId == OrderId("attack") or orderId == OrderId("patrol")
    endfunction

    private function QuickUseSyncAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local string data = BlzGetTriggerSyncData()
        local integer slot
        local integer pId
        local integer playerNum
        local integer currentPage
        local integer otherPage
        local unit hero
        local item targetItem

        if not BagEnabledForPlayer(p) or StringLength(data) != 1 then
            set p = null
            set data = null
            return
        endif

        set slot = S2I(data)
        if data != I2S(slot) or slot < 0 or slot > QUICK_USE_BUTTON_COUNT then
            set p = null
            set data = null
            return
        endif

        set pId = GetPlayerId(p)
        if slot == 0 then
            call QueueQuickUseRestore(pId)
            set p = null
            set data = null
            return
        endif

        if QuickUseActive[pId] then
            call QueueQuickUseRestore(pId)
            set p = null
            set data = null
            return
        endif

        set playerNum = GetPlayerNumber(p)
        set hero = udg_Heroes[playerNum]
        if hero == null or GetWidgetLife(hero) <= 0.405 then
            set p = null
            set data = null
            set hero = null
            return
        endif

        set currentPage = udg_Bag_Page[playerNum]
        set otherPage = GetOtherInventoryPage(p)
        if otherPage <= 0 or otherPage == currentPage then
            set p = null
            set data = null
            set hero = null
            return
        endif

        set targetItem = udg_P_Items[GetPItemsIndex(p, otherPage, slot)]
        if targetItem == null or GetItemTypeId(targetItem) == 0 then
            set p = null
            set data = null
            set hero = null
            set targetItem = null
            return
        endif

        set QuickUseActive[pId] = true
        set QuickUseOriginalPage[pId] = currentPage
        set QuickUseRequestedSlot[pId] = slot
        set QuickUseItem[pId] = targetItem
        set QuickUseItemTypeId[pId] = GetItemTypeId(targetItem)
        set QuickUsePendingLocalActivate[pId] = false
        set QuickUseTargetPage[pId] = otherPage
        set QuickUseAwaitingTarget[pId] = false
        set QuickUseNativeTargeting[pId] = false
        set QuickUseTargetArmDelayTicks[pId] = 0
        set QuickUseIgnoreNextOrder[pId] = false
        set QuickUseFailTimeLeft[pId] = 0.0
        set QuickUseRestorePending[pId] = false

        if MPInventorySwitchToPage(p, otherPage) then
            set QuickUsePendingLocalActivate[pId] = true
        else
            call ClearQuickUseState(pId)
        endif

        set p = null
        set data = null
        set hero = null
        set targetItem = null
    endfunction

    private function QuickUseLocalTimerAction takes nothing returns nothing
        local integer pId = 0
        local player p
        local unit hero
        local integer liveSlot
        local item slotItem
        local integer playerNum
        local integer currentPage

        loop
            exitwhen pId >= bj_MAX_PLAYERS

            if QuickUseActive[pId] then
                set p = Player(pId)
                set playerNum = GetPlayerNumber(p)
                set hero = udg_Heroes[playerNum]
                if hero == null or GetWidgetLife(hero) <= 0.405 then
                    call ClearQuickUseState(pId)
                else
                    set currentPage = udg_Bag_Page[playerNum]
                    if QuickUsePendingLocalActivate[pId] then
                        set liveSlot = QuickUseLiveInventorySlot(pId, hero)
                        if liveSlot >= 0 then
                            set QuickUseRequestedSlot[pId] = liveSlot + 1
                            set QuickUsePendingLocalActivate[pId] = false
                            if QuickUseTargetModeForItemType(QuickUseTrackedItemTypeId(pId)) == QUICK_USE_TARGET_MODE_POINT then
                                call BeginQuickUseTargetingLocal(p, hero)
                            elseif QuickUseTargetModeForItemType(QuickUseTrackedItemTypeId(pId)) != QUICK_USE_TARGET_MODE_NONE then
                                set QuickUseTargetArmDelayTicks[pId] = QUICK_USE_TARGET_ARM_WAIT_TICKS
                            elseif not TryQuickUseImmediateActivation(pId, hero) then
                                set QuickUseFailTimeLeft[pId] = QUICK_USE_FAIL_TIMEOUT
                            endif
                        elseif QuickUseTargetModeForItemType(QuickUseTrackedItemTypeId(pId)) == QUICK_USE_TARGET_MODE_POINT then
                            set QuickUsePendingLocalActivate[pId] = false
                            call BeginQuickUseTargetingLocal(p, hero)
                        endif
                    elseif QuickUseTargetArmDelayTicks[pId] > 0 then
                        set liveSlot = QuickUseLiveInventorySlot(pId, hero)
                        if liveSlot < 0 then
                            call QueueQuickUseRestore(pId)
                        else
                            set QuickUseRequestedSlot[pId] = liveSlot + 1
                            if QuickUseTargetCommandButtonIndex(pId, hero) >= 0 then
                                set QuickUseTargetArmDelayTicks[pId] = 0
                                call BeginQuickUseTargetingLocal(p, hero)
                            else
                                set QuickUseTargetArmDelayTicks[pId] = QuickUseTargetArmDelayTicks[pId] - 1
                                if QuickUseTargetArmDelayTicks[pId] <= 0 then
                                    call BeginQuickUseTargetingLocal(p, hero)
                                endif
                            endif
                        endif
                    elseif QuickUseRestorePending[pId] then
                        call RestoreQuickUseForPlayer(p, hero)
                    elseif QuickUseTargetPage[pId] > 0 and currentPage != QuickUseTargetPage[pId] then
                        call ClearQuickUseState(pId)
                    elseif QuickUseFailTimeLeft[pId] > 0.0 then
                        set QuickUseFailTimeLeft[pId] = QuickUseFailTimeLeft[pId] - 0.03
                        if QuickUseFailTimeLeft[pId] <= 0.0 then
                            call QueueQuickUseRestore(pId)
                        endif
                    endif
                endif
            endif

            set slotItem = null
            set liveSlot = -1
            set currentPage = 0
            set playerNum = 0
            set hero = null
            set p = null
            set pId = pId + 1
        endloop
    endfunction

    private function AreAllPageSlotsFilled takes player p returns boolean
        local integer page = 1
        local integer slot
        if p == null then
            return false
        endif

        loop
            exitwhen page > 2
            set slot = 1
            loop
                exitwhen slot > 6
                if udg_P_Items[GetPItemsIndex(p, page, slot)] == null then
                    return false
                endif
                set slot = slot + 1
            endloop
            set page = page + 1
        endloop

        return true
    endfunction

    private function WarnWhenPagesBecomeFull takes player p returns nothing
        local integer pId
        local boolean pagesFull
        if p == null then
            return
        endif

        set pId = GetPlayerId(p)
        set pagesFull = AreAllPageSlotsFilled(p)
        if pagesFull then
            if not PagesFullWarningArmed[pId] then
                set PagesFullWarningArmed[pId] = true
                call NeatErrorMessage(PAGES_FULL_WARNING_MESSAGE, p)
            endif
        else
            set PagesFullWarningArmed[pId] = false
        endif
    endfunction

    private function ClearSuppressNextBagPopup takes nothing returns nothing
        local integer pId = 0
        loop
            exitwhen pId >= bj_MAX_PLAYERS
            set SuppressNextBagPopup[pId] = false
            set pId = pId + 1
        endloop
    endfunction

    private function SuppressBagPopupUntilNextFrame takes integer pId returns nothing
        set SuppressNextBagPopup[pId] = true
        call TimerStart(SuppressNextBagPopupClearTimer, 0.00, false, function ClearSuppressNextBagPopup)
    endfunction

    private function RenderBagFramesForPlayer takes player p returns nothing
        local integer pId
        local unit hero
        local integer itemCount = 0
        local item it
        local integer slotIndex
        local integer pageSlot
        local integer maxSlots
        local integer currentPage
        local integer otherPage
        local integer utilitySlot
        local integer arrIndex

        if p == null or GetLocalPlayer() != p then
            return
        endif

        set pId = GetPlayerId(p)
        set hero = udg_Heroes[GetPlayerNumber(p)]

        if not BagEnabledForPlayer(p) then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlot", 0), false)
            call SetQuickUseBarVisible(false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            set hero = null
            return
        endif

        call BlzFrameSetScale(BlzGetFrameByName("TasItemBagTooltipPanel", 0), TooltipScale)
        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlot", 0), ShowBagButtonForPlayer[pId])
        call SetQuickUseBarVisible(ShowBagButtonForPlayer[pId])

        set otherPage = GetOtherInventoryPage(p)
        set utilitySlot = 1
        loop
            exitwhen utilitySlot > QUICK_USE_BUTTON_COUNT
            if otherPage > 0 then
                set it = udg_P_Items[GetPItemsIndex(p, otherPage, utilitySlot)]
            else
                set it = null
            endif
            call RenderQuickUseSlot(utilitySlot, it)
            set utilitySlot = utilitySlot + 1
        endloop

        set maxSlots = PITEMS_EXTRA_SLOTS
        set slotIndex = 1
        loop
            exitwhen slotIndex > maxSlots
            set it = udg_P_Items[BagSlotArrayIndex(pId, slotIndex)]
            if it != null and GetItemTypeId(it) != 0 then
                set itemCount = itemCount + 1
            endif
            set slotIndex = slotIndex + 1
        endloop
        call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", 0), I2S(itemCount))

        set slotIndex = 1
        loop
            exitwhen slotIndex > PITEMS_EXTRA_SLOTS
            set it = udg_P_Items[BagSlotArrayIndex(pId, slotIndex)]
            if it != null and GetItemTypeId(it) == 0 then
                set it = null
            endif

            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButton", slotIndex), it != null)
            if it != null then
                call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", slotIndex), BlzGetItemIconPath(it), 0, true)
                call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", slotIndex), BlzGetItemIconPath(it), 0, true)
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonTooltip", slotIndex), BuildBagItemTooltip(it, AddNeedText))
                call UpdateTooltipSellDisplay(slotIndex, it)

                if GetItemCharges(it) > 0 then
                    call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", slotIndex), I2S(GetItemCharges(it)))
                    call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", slotIndex), true)
                else
                    call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", slotIndex), false)
                endif
            else
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", slotIndex), false)
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", slotIndex), "")
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonTooltip", slotIndex), "")
                call UpdateTooltipSellDisplay(slotIndex, null)
                call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", slotIndex), "", 0, true)
                call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", slotIndex), "", 0, true)
            endif
            set slotIndex = slotIndex + 1
        endloop

        set currentPage = udg_Bag_Page[GetPlayerNumber(p)]
        call BlzFrameSetText(BlzGetFrameByName("TasItemBagPageLabel", 0), "|cffffcc00Pages|r")
        if currentPage == 1 then
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagPage1Indicator", 0), "|cffffcc001|r")
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagPage2Indicator", 0), "|cff8888882|r")
        else
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagPage1Indicator", 0), "|cff8888881|r")
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagPage2Indicator", 0), "|cffffcc002|r")
        endif

        set currentPage = 1
        loop
            exitwhen currentPage > 2
            if currentPage == 1 then
                set otherPage = PAGE1_DISPLAY_START
            else
                set otherPage = PAGE2_DISPLAY_START
            endif

            set pageSlot = 1
            loop
                exitwhen pageSlot > 6
                if hero != null and currentPage == udg_Bag_Page[GetPlayerNumber(p)] then
                    set it = UnitItemInSlot(hero, pageSlot - 1)
                else
                    set it = udg_P_Items[GetPItemsIndex(p, currentPage, pageSlot)]
                endif
                if it != null and GetItemTypeId(it) == 0 then
                    set it = null
                endif

                set slotIndex = otherPage + pageSlot - 1
                if it != null then
                    call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButton", slotIndex), true)
                    call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", slotIndex), BlzGetItemIconPath(it), 0, true)
                    call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", slotIndex), BlzGetItemIconPath(it), 0, true)
                    call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", slotIndex), BlzGetItemIconPath(it), 0, true)
                    call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", slotIndex), true)
                    call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonTooltip", slotIndex), BuildBagItemTooltip(it, false))
                    call UpdateTooltipSellDisplay(slotIndex, it)
                    if GetItemCharges(it) > 0 then
                        call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", slotIndex), I2S(GetItemCharges(it)))
                        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", slotIndex), true)
                    else
                        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", slotIndex), false)
                    endif
                else
                    call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButton", slotIndex), false)
                    call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", slotIndex), "", 0, true)
                    call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", slotIndex), "", 0, true)
                    call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", slotIndex), false)
                    call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", slotIndex), false)
                    call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonTooltip", slotIndex), "")
                    call UpdateTooltipSellDisplay(slotIndex, null)
                endif

                set pageSlot = pageSlot + 1
            endloop
            set currentPage = currentPage + 1
        endloop

        set it = null
        set hero = null
    endfunction

    private function UpdateUI takes nothing returns nothing
        local integer pId
        local player p
        local unit hero
        local integer itemCount = 0
        local item it
        local integer slotIndex
        local integer pageSlot
        local integer maxSlots
        local integer currentPage
        local integer arrIndex
        set UIUpdateScheduled = false

        set pId = 0
        loop
            exitwhen pId >= bj_MAX_PLAYERS
            set p = Player(pId)
            set hero = udg_Heroes[GetPlayerNumber(p)]

            if not BagEnabledForPlayer(p) then
                if GetLocalPlayer() == p then
                    call RenderBagFramesForPlayer(p)
                endif
                set p = null
                set hero = null
            else
                call WarnWhenPagesBecomeFull(p)

                set itemCount = 0
                set maxSlots = PITEMS_EXTRA_SLOTS
                set slotIndex = 1
                loop
                    exitwhen slotIndex > maxSlots
                    set arrIndex = BagSlotArrayIndex(pId, slotIndex)
                    set it = udg_P_Items[arrIndex]
                    if it != null then
                        if GetItemTypeId(it) == 0 then
                            set udg_P_Items[arrIndex] = null
                        else
                            set itemCount = itemCount + 1
                        endif
                    endif
                    set slotIndex = slotIndex + 1
                endloop

                set currentPage = 1
                loop
                    exitwhen currentPage > 2
                    set pageSlot = 1
                    loop
                        exitwhen pageSlot > 6
                        if hero != null and currentPage == udg_Bag_Page[GetPlayerNumber(p)] then
                            set it = UnitItemInSlot(hero, pageSlot - 1)
                        else
                            set arrIndex = GetPItemsIndex(p, currentPage, pageSlot)
                            set it = udg_P_Items[arrIndex]
                        endif
                        if it != null and GetItemTypeId(it) == 0 then
                            if hero == null or currentPage != udg_Bag_Page[GetPlayerNumber(p)] then
                                set udg_P_Items[arrIndex] = null
                            endif
                            set it = null
                        endif
                        set pageSlot = pageSlot + 1
                    endloop
                    set currentPage = currentPage + 1
                endloop

                if GetLocalPlayer() == p then
                    call RenderBagFramesForPlayer(p)
                endif
            endif
            set pId = pId + 1
        endloop

        set it = null
        set p = null
        set hero = null
    endfunction

    // Schedules a UI refresh once (debounced). Safe to call many times.
    private function RequestUIUpdate takes nothing returns nothing
        if not UIUpdateScheduled then
            set UIUpdateScheduled = true
            call TimerStart(TimerUpdate, 0.00, false, function UpdateUI)
        endif
    endfunction

    function TasItemBagSetShowButtonVisible takes player p, boolean visible returns nothing
        if p == null then
            return
        endif
        set ShowBagButtonForPlayer[GetPlayerId(p)] = visible
        call RequestUIUpdate()
    endfunction

    //Public facing one for other libraries/triggers to call
    function TasItemBag_RequestUIUpdate takes nothing returns nothing
        call RequestUIUpdate()
    endfunction

    private function PlaySwapConfirmSound takes player p returns nothing
        if SwapConfirmSound != null then
            call PlayLocalSound(SwapConfirmSound, p)
        endif
    endfunction

    private function PlaySwapSelectSound takes player p returns nothing
        if SwapSelectSound != null then
            call PlayLocalSound(SwapSelectSound, p)
        endif
    endfunction

    private function RestoreBagSlotOverlay takes integer pId, integer rawSlotIndex returns nothing
        local item it
        if rawSlotIndex <= 0 or rawSlotIndex > MAX_INTERACTIVE_SLOT then
            return
        endif
        if GetLocalPlayer() == Player(pId) then
            set it = udg_P_Items[SlotToArrayIndex(pId, rawSlotIndex)]
            if it != null and GetItemCharges(it) > 0 then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", rawSlotIndex), true)
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", rawSlotIndex), I2S(GetItemCharges(it)))
            else
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", rawSlotIndex), false)
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", rawSlotIndex), "")
            endif
        endif
        set it = null
    endfunction

    // Per-slot inventory gap hitboxes are enabled only while a bag slot is selected for insert.
    private function SetInventoryHitboxesEnabled takes boolean enabled returns nothing
        local integer invIndex = 0
        loop
            exitwhen invIndex >= bj_MAX_INVENTORY
            if InventoryHitbox[invIndex] != null then
                call BlzFrameSetEnable(InventoryHitbox[invIndex], enabled)
            endif
            set invIndex = invIndex + 1
        endloop
    endfunction

    private function SwapHoverHide takes integer pId returns nothing
        if SwapHoverIndex[pId] > 0 then
            call RestoreBagSlotOverlay(pId, SwapHoverIndex[pId])
            set SwapHoverIndex[pId] = 0
        endif
    endfunction

    private function SwapHoverShowOnSlot takes integer pId, integer rawSlotIndex returns nothing
        local integer arrIndex
        if rawSlotIndex <= 0 or rawSlotIndex > MAX_INTERACTIVE_SLOT then
            call SwapHoverHide(pId)
            return
        endif
        if SwapIndex[pId] <= 0 or rawSlotIndex == SwapIndex[pId] then
            call SwapHoverHide(pId)
            return
        endif

        set arrIndex = SlotToArrayIndex(pId, rawSlotIndex)
        if udg_P_Items[arrIndex] != null then
            call SwapHoverHide(pId)
            return
        endif

        if SwapHoverIndex[pId] != rawSlotIndex then
            call SwapHoverHide(pId)
            set SwapHoverIndex[pId] = rawSlotIndex
            if GetLocalPlayer() == Player(pId) then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", rawSlotIndex), true)
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", rawSlotIndex), "●")
            endif
        endif
    endfunction

    private function SwapHighlightHide takes integer pId returns nothing
        call SwapHoverHide(pId)
        if GetLocalPlayer() == Player(pId) then
            call SetInventoryHitboxesEnabled(false)
            if SwapHighlight[pId] != null then
                call BlzFrameSetVisible(SwapHighlight[pId], false)
            endif
        endif
    endfunction

    private function SwapHighlightShowOnSlot takes integer pId, integer rawSlotIndex returns nothing
        if GetLocalPlayer() == Player(pId) then
            call SetInventoryHitboxesEnabled(true)
            if SwapHighlight[pId] != null and rawSlotIndex > 0 then
                call BlzFrameClearAllPoints(SwapHighlight[pId])
                call BlzFrameSetPoint(SwapHighlight[pId], FRAMEPOINT_TOPLEFT, BlzGetFrameByName("TasItemBagSlotButton", rawSlotIndex), FRAMEPOINT_TOPLEFT, 0, -0.002)
                call BlzFrameSetPoint(SwapHighlight[pId], FRAMEPOINT_BOTTOMRIGHT, BlzGetFrameByName("TasItemBagSlotButton", rawSlotIndex), FRAMEPOINT_BOTTOMRIGHT, 0, -0.002)
                call BlzFrameSetVisible(SwapHighlight[pId], true)
            endif
        endif
    endfunction

    // Callback for MultiPageInventorySystem page changes
    private function PageChangedAction takes nothing returns nothing
        // Page display slot meanings are fixed (25-30=page1, 31-36=page2),
        // so armed swaps no longer become invalid on page change.
        // Just hide popups and refresh UI to update active-page indicator.
        if BlzFrameIsVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0)) then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
        endif
        if BlzFrameIsVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0)) then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
        endif
        call RequestUIUpdate()
    endfunction

    private function IsBankUnit takes unit u returns boolean
        return GetUnitTypeId(u) == 'n002'
    endfunction

    private function InitVendorUnits takes nothing returns nothing
        set VendorUnitCount = 0

        // Core vendors
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n03E' // Agility Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n036' // Agility Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n00O' // Argent Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n010' // Blood Elf Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n047' // Draenei Epic Crafter
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n00Q' // Dwarf Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n035' // Epic Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'ngme' // Goblin Merchant
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n00N' // Human Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n02E' // Human Vendor (Northrend)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n01W' // Intelligence Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n016' // Intelligence Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n020' // Mail Box
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n026' // Mail Box (Active)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n012' // Orc Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n02A' // Strength Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n029' // Strength Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n02B' // Traveling Worgen
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n01V' // Tuskar Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n00D' // Undead Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n02F' // Undead Vendor (Northrend)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n022' // Wisp Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n00E' // Worgen Vendor
        

        // Flight Path vendors (only entries containing "Flight Path")
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u01B' // Alliance Flight Path (Aerie Peak)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u007' // Alliance Flight Path (Chillwind)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u02X' // Alliance Flight Path (Gilneas)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u03O' // Alliance Flight Path (Greenwarden's Grove)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u03R' // Alliance Flight Path (Highbank)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u01E' // Alliance Flight Path (Ironforge)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u01D' // Alliance Flight Path (LH)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u03I' // Alliance Flight Path (Menethil Harbor)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u02U' // Alliance Flight Path (Northrend)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u019' // Alliance Flight Path (Southshore)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u01C' // Alliance Flight Path (Stormfeather)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u018' // Alliance Flight Path (Stromgarde)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u008' // Dwarven Flight Path
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u02Y' // Forsaken Flight Path (Gilneas)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u02V' // Forsaken Flight Path (Northrend)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u012' // Forsaken Flight Path (Tarren Mill)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u014' // Forsaken Flight Path (The Bulwark)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u011' // Forsaken Flight Path (The Sepulcher)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u006' // Forsaken Flight Path (Undercity)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u002' // Horde Flight Path
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u03S' // Horde Flight Path (Dragonmaw Port)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u017' // Horde Flight Path (LH)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u016' // Horde Flight Path (Revantusk)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u015' // Horde Flight Path (Silvermoon)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u03M' // Horde Flight Path (Tranquillien)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u02W' // Neutral Flight Path (Northrend)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u041' // Neutral Flight Path (Val'sharah)
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'u03T' // Neutral Flight Path (Vermillion Redoubt)
    endfunction

    private function IsVendorUnit takes unit u returns boolean
        local integer unitId
        local integer i = 1
        if u == null then
            return false
        endif
        set unitId = GetUnitTypeId(u)
        loop
            exitwhen i > VendorUnitCount
            if VendorUnitId[i] == unitId then
                return true
            endif
            set i = i + 1
        endloop
        return false
    endfunction

    private function PlayInventoryFullRaceSoundPlaceholder takes player p, unit hero returns nothing
        local race heroRace
        if p == null then
            return
        endif

        if hero == null then
            set hero = udg_Heroes[GetPlayerNumber(p)]
        endif

        if hero != null then
            set heroRace = GetUnitRace(hero)
        else
            set heroRace = GetPlayerRace(p)
        endif

        // Placeholder branch map by race (future race-specific sounds).
        call PlayRaceSpecificInventoryFullSound(hero, p)
        
        set heroRace = null
        set hero = null
    endfunction

    // Finds the next empty (null) slot for this player's bag.
    // Returns 0 when the bag is full.
    private function BagNextEmptySlot takes integer playerKey returns integer
        local integer slot = 1
        local integer maxSlots = PITEMS_EXTRA_SLOTS
        local integer arrIndex
        loop
            exitwhen slot > maxSlots
            set arrIndex = BagSlotArrayIndex(playerKey, slot)
            if udg_P_Items[arrIndex] == null then
                return slot
            endif
            set slot = slot + 1
        endloop
        return 0
    endfunction

    private function BagFindItemSlot takes integer playerKey, item i returns integer
        local integer slot = 1
        local integer maxSlots = PITEMS_EXTRA_SLOTS
        local integer arrIndex
        loop
            exitwhen slot > maxSlots
            set arrIndex = BagSlotArrayIndex(playerKey, slot)
            if udg_P_Items[arrIndex] == i then
                return slot
            endif
            set slot = slot + 1
        endloop
        // Also search page display slots (both pages)
        set slot = PAGE_DISPLAY_START
        loop
            exitwhen slot > MAX_INTERACTIVE_SLOT
            set arrIndex = SlotToArrayIndex(playerKey, slot)
            if udg_P_Items[arrIndex] == i then
                return slot
            endif
            set slot = slot + 1
        endloop
        return 0
    endfunction

    function IsStackableType takes item i returns boolean
        if i == null then
            return false
        endif
        return ( GetItemType(i) == ITEM_TYPE_CHARGED or GetItemType(i) == ITEM_TYPE_MISCELLANEOUS or GetItemType(i) == ITEM_TYPE_CAMPAIGN or GetItemType(i) == ITEM_TYPE_UNKNOWN)
    endfunction

    // Safe stack preference for picked items:
    // Merge into matching CURRENT inventory stacks first (slots 1..6 via UnitItemInSlot).
    // Returns true when the picked item was fully absorbed/removed.
    private function MergePickedItemIntoPagedStacks takes unit hero, item picked returns boolean
        local integer invSlot
        local integer itemCode
        local integer maxCharges
        local integer incomingCharges
        local integer existingCharges
        local integer space
        local integer addCharges
        local integer beforeCharges
        local integer afterCharges
        local integer absorbed
        local integer originalCharges
        local item existing

        if hero == null or picked == null then
            return false
        endif
        if not UnitHasItem(hero, picked) then
            return false
        endif
        if not IsStackableType(picked) then
            return false
        endif

        set incomingCharges = GetItemCharges(picked)
        if incomingCharges <= 0 then
            return false
        endif

        set originalCharges = incomingCharges
        set maxCharges = DEFAULT_MAX_CHARGES
        if incomingCharges > maxCharges then
            set incomingCharges = maxCharges
        endif
        set itemCode = GetItemTypeId(picked)
        // Merge against LIVE inventory only (current page equipped slots).
        set invSlot = 0
        loop
            exitwhen invSlot >= bj_MAX_INVENTORY or incomingCharges <= 0
            set existing = UnitItemInSlot(hero, invSlot)
            if existing != null and existing != picked and IsStackableType(existing) and GetItemTypeId(existing) == itemCode and GetItemCharges(existing) > 0 then
                set existingCharges = GetItemCharges(existing)
                if existingCharges < 0 then
                    set existingCharges = 0
                elseif existingCharges > maxCharges then
                    set existingCharges = maxCharges
                    call SetItemCharges(existing, existingCharges)
                endif
                set beforeCharges = existingCharges
                set space = maxCharges - beforeCharges
                if space > 0 then
                    if incomingCharges > space then
                        set addCharges = space
                    else
                        set addCharges = incomingCharges
                    endif
                    call SetItemCharges(existing, beforeCharges + addCharges)
                else
                    set addCharges = 0
                endif
                set afterCharges = GetItemCharges(existing)
                set absorbed = afterCharges - beforeCharges
                if absorbed < 0 then
                    set absorbed = 0
                endif
                set incomingCharges = incomingCharges - absorbed
                if incomingCharges < 0 then
                    set incomingCharges = 0
                endif
            endif
            set invSlot = invSlot + 1
        endloop

        if incomingCharges <= 0 then
            call RemoveItem(picked)
            call RequestUIUpdate()
            set existing = null
            return true
        endif

        if incomingCharges < originalCharges then
            call SetItemCharges(picked, incomingCharges)
            call RequestUIUpdate()
        endif

        set existing = null
        return false
    endfunction

    private function BagHasMergeSpace takes integer playerKey, item incoming returns boolean
        local integer incomingCharges
        local integer itemCode
        local integer slot = 1
        local integer maxSlots = PITEMS_EXTRA_SLOTS
        local integer arrIndex
        local item existing
        if incoming == null then
            return false
        endif
        set incomingCharges = GetItemCharges(incoming)
        if incomingCharges <= 0 or not IsStackableType(incoming) then
            return false
        endif
        set itemCode = GetItemTypeId(incoming)
        loop
            exitwhen slot > maxSlots
            set arrIndex = BagSlotArrayIndex(playerKey, slot)
            set existing = udg_P_Items[arrIndex]
            if existing != null and IsStackableType(existing) and GetItemTypeId(existing) == itemCode then
                if GetItemCharges(existing) < DEFAULT_MAX_CHARGES then
                    set existing = null
                    return true
                endif
            endif
            set slot = slot + 1
        endloop
        set existing = null
        return false
    endfunction

    function TasItemBagAddItem takes unit u, item i, boolean allowMerge returns nothing
        local integer playerKey = GetPlayerId(GetOwningPlayer(u))
        local integer itemCode
        local integer incomingCharges
        local integer slot
        local integer maxSlots
        local integer arrIndex
        local item existing
        local integer existingCharges
        local integer addCharges
        local integer beforeCharges
        local integer afterCharges
        local integer absorbed
        local integer remaining
        local integer maxCharges
        local integer space
        local integer emptySlot
        local location itemIsland
        local integer page

        if i == null then
            return
        endif
        if not BagEnabledForPlayer(GetOwningPlayer(u)) then
            return
        endif

        // if UnitHasItem(u, i) then
        //     call UnitRemoveItem(u, i)
        // endif

        // Stack consumable charges into an existing item of the same type (if possible)
        // Only applies to charged consumables, now also applies to ITEM_TYPE_MISCELLANEOUS or ITEM_TYPE_CAMPAIGN
        if allowMerge then
            set incomingCharges = GetItemCharges(i)
            if incomingCharges > 0 and IsStackableType(i) then
                set maxCharges = DEFAULT_MAX_CHARGES
                if incomingCharges > maxCharges then
                    set incomingCharges = maxCharges
                    call SetItemCharges(i, incomingCharges)
                endif
                set itemCode = GetItemTypeId(i)

                // First: merge into hero's 6 native inventory slots
                set slot = 0
                loop
                    exitwhen slot >= UnitInventorySize(u) or incomingCharges <= 0
                    set existing = UnitItemInSlot(u, slot)
                    if existing != null and existing != i and GetItemTypeId(existing) == itemCode and GetItemCharges(existing) > 0 then
                        set existingCharges = GetItemCharges(existing)
                        if existingCharges > maxCharges then
                            set existingCharges = maxCharges
                            call SetItemCharges(existing, existingCharges)
                        endif
                        set space = maxCharges - existingCharges
                        if space > 0 then
                            if incomingCharges > space then
                                set addCharges = space
                            else
                                set addCharges = incomingCharges
                            endif
                            call SetItemCharges(existing, existingCharges + addCharges)
                            set incomingCharges = incomingCharges - addCharges
                        endif
                    endif
                    set slot = slot + 1
                endloop

                // Fully merged into hero inventory -> remove incoming
                if incomingCharges <= 0 then
                    call RemoveItem(i)
                    set existing = null
                    call RequestUIUpdate()
                    return
                endif

                // Merge into non-visible page inventory slots (stored in udg_P_Items)
                set page = 1
                loop
                    exitwhen page > MPInventoryGetMaxPages() or incomingCharges <= 0
                    if page != udg_Bag_Page[GetPlayerNumber(GetOwningPlayer(u))] then
                        set slot = 1
                        loop
                            exitwhen slot > 6 or incomingCharges <= 0
                            set arrIndex = GetPItemsIndex(GetOwningPlayer(u), page, slot)
                            set existing = udg_P_Items[arrIndex]
                            if existing != null and existing != i and GetItemTypeId(existing) == itemCode and GetItemCharges(existing) > 0 then
                                set existingCharges = GetItemCharges(existing)
                                if existingCharges > maxCharges then
                                    set existingCharges = maxCharges
                                    call SetItemCharges(existing, existingCharges)
                                endif
                                set space = maxCharges - existingCharges
                                if space > 0 then
                                    if incomingCharges > space then
                                        set addCharges = space
                                    else
                                        set addCharges = incomingCharges
                                    endif
                                    call SetItemCharges(existing, existingCharges + addCharges)
                                    set incomingCharges = incomingCharges - addCharges
                                endif
                            endif
                            set slot = slot + 1
                        endloop
                    endif
                    set page = page + 1
                endloop

                // Fully merged into non-visible page -> remove incoming
                if incomingCharges <= 0 then
                    call RemoveItem(i)
                    set existing = null
                    call RequestUIUpdate()
                    return
                endif

                // Second: merge into bag's extra slots
                set slot = 1
                set maxSlots = PITEMS_EXTRA_SLOTS
                loop
                    exitwhen slot > maxSlots or incomingCharges <= 0
                    set arrIndex = BagSlotArrayIndex(playerKey, slot)
                    set existing = udg_P_Items[arrIndex]
                    if existing != null and IsStackableType(existing) and GetItemTypeId(existing) == itemCode and GetItemCharges(existing) > 0 then
                        set existingCharges = GetItemCharges(existing)
                        if existingCharges > maxCharges then
                            set existingCharges = maxCharges
                            call SetItemCharges(existing, existingCharges)
                        endif

                        set beforeCharges = existingCharges
                        set space = maxCharges - beforeCharges
                        if space > 0 then
                            if incomingCharges > space then
                                set addCharges = space
                            else
                                set addCharges = incomingCharges
                            endif
                            call SetItemCharges(existing, beforeCharges + addCharges)
                        else
                            set addCharges = 0
                        endif
                        set afterCharges = GetItemCharges(existing)

                        set absorbed = afterCharges - beforeCharges
                        if absorbed < 0 then
                            set absorbed = 0
                        endif
                        set remaining = incomingCharges - absorbed
                        if remaining < 0 then
                            set remaining = 0
                        endif
                        set incomingCharges = remaining
                    endif
                    set slot = slot + 1
                endloop

                // Fully merged -> remove the incoming item
                if incomingCharges <= 0 then
                    call RemoveItem(i)
                    set existing = null
                    call RequestUIUpdate()
                    return
                endif

                // Partially merged -> keep remaining charges on the incoming item before storing it
                call SetItemCharges(i, incomingCharges)
            endif
        endif

        // Need a free slot if the item still exists after any merge
        set emptySlot = BagNextEmptySlot(playerKey)
        if emptySlot <= 0 then
            call PlayInventoryFullRaceSoundPlaceholder(GetOwningPlayer(u), u)
            call NeatErrorMessage(BAG_FULL_MESSAGE, GetOwningPlayer(u))
            call RequestUIUpdate()
            return
        endif

        set itemIsland = GetRectCenter(gg_rct_ISLAND_ITEMS)
        call SetItemPositionLoc(i, itemIsland)
        // call SetItemVisible(i, false)
        call SetItemUserData(i, 1)
        call RemoveLocation(itemIsland)

        set arrIndex = BagSlotArrayIndex(playerKey, emptySlot)
        set udg_P_Items[arrIndex] = i
        call RequestUIUpdate()
    endfunction

    function TasItemBagGetItem takes unit u, integer index returns item
        local integer playerKey = GetPlayerId(GetOwningPlayer(u))
        if index <= 0 or index > MAX_INTERACTIVE_SLOT then
            return null
        endif
        return udg_P_Items[SlotToArrayIndex(playerKey, index)]
    endfunction
    
    // Returns the active page's display start index (25 for page 1, 31 for page 2), or 0 if invalid.
    private function GetActivePageDisplayStart takes integer playerKey returns integer
        local integer currentPage = udg_Bag_Page[GetPlayerNumber(Player(playerKey))]
        if currentPage == 1 then
            return PAGE1_DISPLAY_START
        elseif currentPage == 2 then
            return PAGE2_DISPLAY_START
        endif
        return 0
    endfunction

    // Returns true if slotIndex is a page display slot on the currently-equipped page.
    private function IsActivePageSlot takes integer playerKey, integer slotIndex returns boolean
        local integer start = GetActivePageDisplayStart(playerKey)
        return start > 0 and slotIndex >= start and slotIndex < start + 6
    endfunction

    private function CanSwapActivePageSlots takes unit hero, integer playerKey, integer indexA, integer indexB returns boolean
        if hero == null then
            return false
        endif
        if (IsActivePageSlot(playerKey, indexA) or IsActivePageSlot(playerKey, indexB)) and not IsAbleToChangePage(hero) then
            return false
        endif
        return true
    endfunction

    // Converts a page display slot index to a 0-based hero inventory slot.
    private function PageSlotToInvSlot takes integer slotIndex returns integer
        if slotIndex >= PAGE2_DISPLAY_START then
            return slotIndex - PAGE2_DISPLAY_START
        endif
        return slotIndex - PAGE1_DISPLAY_START
    endfunction

    // Unequip an item from the hero's inventory slot: remove, move to island, mark stored.
    // Native acquire/loss side effects are suppressed because callers (e.g. TasItemBagSwap)
    // already invoke LoseItemHandler manually; allowing the native trigger to also fire
    // would double-apply DeathCap/Warmogs/Banshees/PrevBONUSInt mutations.
    private function UnequipFromHero takes unit hero, integer invSlot returns nothing
        local item removed
        local location itemIsland
        local boolean prevSuppress = AcquireAndLoseItemHandler_PageRebuildSuppress
        set AcquireAndLoseItemHandler_PageRebuildSuppress = true
        set removed = UnitRemoveItemFromSlot(hero, invSlot)
        if removed != null then
            set itemIsland = GetRectCenter(gg_rct_ISLAND_ITEMS)
            call SetItemPositionLoc(removed, itemIsland)
            call SetItemUserData(removed, 1)
            // call SetItemVisible(removed, false)
            call RemoveLocation(itemIsland)
            set itemIsland = null
        endif
        set AcquireAndLoseItemHandler_PageRebuildSuppress = prevSuppress
        set removed = null
    endfunction

    // Equip an item into a specific hero inventory slot. Creates a new WC3 item
    // instance, updates udg_P_Items[arrIndex] to the new handle, and destroys the old.
    private function EquipToHeroSlot takes unit hero, item it, integer invSlot, integer arrIndex returns nothing
        local integer typeId = GetItemTypeId(it)
        local integer charges = GetItemCharges(it)
        local item newItem
        set udg_dontDepositIntoBag = true
        if UnitAddItemToSlotById(hero, typeId, invSlot) then
            set newItem = UnitItemInSlot(hero, invSlot)
            if newItem != null and charges > 0 then
                call SetItemCharges(newItem, charges)
            endif
            // Update P_Items to reference the new WC3 handle
            set udg_P_Items[arrIndex] = newItem
            // Destroy the old island-parked item
            call RemoveItem(it)
            set newItem = null
        endif
    endfunction

    // Rebuild the currently active hero inventory page from udg_P_Items.
    // This keeps page display and native inventory in sync after swaps involving
    // active page slots, while preserving the map's compacting page-load behavior.
    //
    // Native acquire/loss side effects are suppressed during the rebuild because the
    // rebuild itself is synthetic. Callers manually apply the meaningful active-page
    // acquire/loss side effects exactly once around the rebuild.
    private function SyncCurrentPageInventory takes player p returns nothing
        local integer playerNum = GetPlayerNumber(p)
        local unit hero = udg_Heroes[playerNum]
        local integer currentPage = udg_Bag_Page[playerNum]
        local integer pageIndex
        local integer slot = 1
        local item currentItem
        local location itemIsland
        local item array Temp_Items
        local boolean prevSuppress

        if hero == null then
            return
        endif

        set prevSuppress = AcquireAndLoseItemHandler_PageRebuildSuppress
        set AcquireAndLoseItemHandler_PageRebuildSuppress = true

        set itemIsland = GetRectCenter(gg_rct_ISLAND_ITEMS)
        call DisableTrigger(gg_trg_Firestone_Dropped)
        call DisableTrigger(gg_trg_Firestone_Acquired)

        loop
            exitwhen slot > 6
            set pageIndex = GetPItemsIndex(p, currentPage, slot)
            set Temp_Items[slot] = udg_P_Items[pageIndex]
            set slot = slot + 1
        endloop

        set slot = 1
        loop
            exitwhen slot > 6
            set currentItem = UnitRemoveItemFromSlot(hero, slot - 1)
            if currentItem != null then
                call SetItemPositionLoc(currentItem, itemIsland)
                // call SetItemVisible(currentItem, false)
            endif
            set slot = slot + 1
        endloop

        // Clear the active page entries before re-adding; we will repopulate them
        // deterministically below from the unit's native slots once items settle.
        set slot = 1
        loop
            exitwhen slot > 6
            set pageIndex = GetPItemsIndex(p, currentPage, slot)
            set udg_P_Items[pageIndex] = null
            set slot = slot + 1
        endloop

        set slot = 1
        loop
            exitwhen slot > 6
            set currentItem = Temp_Items[slot]
            if currentItem != null then
                set udg_dontDepositIntoBag = true
                call UnitAddItem(hero, currentItem)
            endif
            set slot = slot + 1
        endloop

        // Deterministic repopulate: scan native slots and write the resulting
        // handles back into udg_P_Items. UnitAddItem may have compacted slots or
        // merged stacks, so the final slot ordering must come from the engine.
        set slot = 1
        loop
            exitwhen slot > 6
            set pageIndex = GetPItemsIndex(p, currentPage, slot)
            set currentItem = UnitItemInSlot(hero, slot - 1)
            if currentItem != null and GetItemTypeId(currentItem) != 0 then
                set udg_P_Items[pageIndex] = currentItem
            else
                set udg_P_Items[pageIndex] = null
            endif
            set slot = slot + 1
        endloop

        call EnableTrigger(gg_trg_Firestone_Dropped)
        call EnableTrigger(gg_trg_Firestone_Acquired)
        set AcquireAndLoseItemHandler_PageRebuildSuppress = prevSuppress
        call RemoveLocation(itemIsland)
        set itemIsland = null
        set currentItem = null
        set hero = null
    endfunction

    function TasItemBagSwap takes unit u, integer indexA, integer indexB returns boolean
        local integer playerKey = GetPlayerId(GetOwningPlayer(u))
        local integer a
        local integer b
        local item i
        local item i2
        local integer codeA
        local integer codeB
        local integer chargesA
        local integer chargesB
        local integer space
        local integer add
        local boolean aIsActive
        local boolean bIsActive
        local unit hero
        local item acquireCandidate = null
        if indexA <= 0 or indexB <= 0 or indexA > MAX_INTERACTIVE_SLOT or indexB > MAX_INTERACTIVE_SLOT or indexA == indexB then
            return false
        endif
        if not CanSwapActivePageSlots(u, playerKey, indexA, indexB) then
            return false
        endif
        set a = SlotToArrayIndex(playerKey, indexA)
        set b = SlotToArrayIndex(playerKey, indexB)
        set i = udg_P_Items[a]
        set i2 = udg_P_Items[b]
        set aIsActive = IsActivePageSlot(playerKey, indexA)
        set bIsActive = IsActivePageSlot(playerKey, indexB)

        if aIsActive and not bIsActive and i2 != null then
            set acquireCandidate = i2
        elseif bIsActive and not aIsActive and i != null then
            set acquireCandidate = i
        endif

        // Auto-merge matching stacks on any swap (intuitive: same item + swap = combine).
        if i != null and i2 != null then
            set codeA = GetItemTypeId(i)
            set codeB = GetItemTypeId(i2)
            if codeA == codeB and IsStackableType(i) and GetItemCharges(i) > 0 and GetItemCharges(i2) > 0 then
                set chargesA = GetItemCharges(i)
                set chargesB = GetItemCharges(i2)
                // If either stack is already at cap, treat as a plain swap (merge would be a no-op).
                if chargesA >= DEFAULT_MAX_CHARGES or chargesB >= DEFAULT_MAX_CHARGES then
                    // fall through to positional swap below
                elseif chargesA + chargesB <= DEFAULT_MAX_CHARGES then
                    // Fully absorb: merge all into destination, remove source
                    call SetItemCharges(i2, chargesA + chargesB)
                    call RemoveItem(i)
                    set udg_P_Items[a] = null
                    if aIsActive or bIsActive then
                        call SyncCurrentPageInventory(GetOwningPlayer(u))
                    endif
                    set i = null
                    set i2 = null
                    set acquireCandidate = null
                    call RequestUIUpdate()
                    return true
                else
                    // Partial merge: fill destination to cap, leave remainder in source
                    set space = DEFAULT_MAX_CHARGES - chargesB
                    if space > 0 then
                        call SetItemCharges(i2, DEFAULT_MAX_CHARGES)
                        call SetItemCharges(i, chargesA - space)
                    endif
                    // Still do the positional swap so the topped-up stack ends where player intended
                endif
            endif
        endif

        // When an item leaves the active page during a swap, preserve the native
        // lose-side effects without turning the move into a real ground drop.
        if aIsActive and not bIsActive and i != null then
            if GetItemType(i) != ITEM_TYPE_POWERUP and GetItemTypeId(i) != 'I07W' then
                call LoseItemHandler(u, i)
                call UnequipFromHero(u, PageSlotToInvSlot(indexA))
            endif
        endif
        if bIsActive and not aIsActive and i2 != null then
            if GetItemType(i2) != ITEM_TYPE_POWERUP and GetItemTypeId(i2) != 'I07W' then
                call LoseItemHandler(u, i2)
                call UnequipFromHero(u, PageSlotToInvSlot(indexB))
            endif
        endif

        set udg_P_Items[a] = i2
        set udg_P_Items[b] = i

        if aIsActive or bIsActive then
            call SyncCurrentPageInventory(GetOwningPlayer(u))
            if acquireCandidate != null and UnitHasItem(u, acquireCandidate) and GetItemType(acquireCandidate) != ITEM_TYPE_POWERUP and GetItemTypeId(acquireCandidate) != 'I07W' then
                call AcquireItemHandler(u, acquireCandidate)
            endif
        endif

        set i = null
        set i2 = null
        set acquireCandidate = null
        call RequestUIUpdate()
        return true
    endfunction

    function TasItemBagRemoveIndex takes unit u, integer index, boolean drop returns boolean
        local integer playerKey = GetPlayerId(GetOwningPlayer(u))
        local integer arrIndex
        local item i
        local location dropSpot
        if index <= 0 or index > MAX_INTERACTIVE_SLOT then
            return false
        endif
        set arrIndex = SlotToArrayIndex(playerKey, index)
        set i = udg_P_Items[arrIndex]
        if i == null then
            return false
        endif
        // If removing from active page: fire the native drop event (triggers gg_trg_Lose_Item naturally),
        // then park item on island so TasItemBag state stays consistent.
        // ITEM_TYPE_POWERUP and 'I07W' are excluded (same gates as the original trigger condition).
        if IsActivePageSlot(playerKey, index) then
            if GetItemType(i) != ITEM_TYPE_POWERUP and GetItemTypeId(i) != 'I07W' then
                // call DisableTrigger(gg_trg_Acquire_Item)
                call UnitDropItemPoint(u, i, GetUnitX(u), GetUnitY(u))
                call SetItemPosition(i, GetRectCenterX(gg_rct_ISLAND_ITEMS), GetRectCenterY(gg_rct_ISLAND_ITEMS))
                call SetItemUserData(i, 1)
                // call SetItemVisible(i, false)
                // call EnableTrigger(gg_trg_Acquire_Item)
            else
                call UnequipFromHero(u, PageSlotToInvSlot(index))
            endif
        endif
        set udg_P_Items[arrIndex] = null
        call RequestUIUpdate()

        if drop and GetHandleId(i) > 0 then
            set dropSpot = GetUnitLoc(u)
            call SetItemPositionLoc(i, dropSpot)
            call SetItemUserData(i, 0)
            // call SetItemVisible(i, true)
            call RemoveLocation(dropSpot)
            set dropSpot = null
            set i = null
            return true
        endif

        set i = null
        return true
    endfunction

    function TasItemBagRemoveItem takes unit u, item i, boolean drop returns boolean
        local integer playerKey = GetPlayerId(GetOwningPlayer(u))
        local integer slot
        if i == null then
            return false
        endif
        set slot = BagFindItemSlot(playerKey, i)
        if slot > 0 then
            return TasItemBagRemoveIndex(u, slot, drop)
        endif
        return false
    endfunction

    private function FrameLoseFocus takes nothing returns nothing
        if GetLocalPlayer() == GetTriggerPlayer() then
            call BlzFrameSetEnable(BlzGetTriggerFrame(), false)
            call BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        endif
    endfunction

    private function QuickUseButtonAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local frameeventtype evt = BlzGetTriggerFrameEvent()
        local integer slot = S2I(BlzFrameGetText(BlzGetTriggerFrame()))

        if p == null or not BagEnabledForPlayer(p) then
            set p = null
            return
        endif

        if evt == FRAMEEVENT_MOUSE_UP then
            call FrameLoseFocus()
            set p = null
            return
        endif

        if slot < 1 or slot > QUICK_USE_BUTTON_COUNT then
            set p = null
            return
        endif

        call RequestQuickUseSync(p, slot)
        call FrameLoseFocus()
        set p = null
    endfunction

    private function CloseBagPanelFromSyncedRequest takes player p returns nothing
        local integer pId
        if p == null then
            return
        endif

        set pId = GetPlayerId(p)
        call RenderBagFramesForPlayer(p)
        call SetBagPanelOpen(p, false)
        call HideBagPopupPanels(p)
        call RenderBagFramesForPlayer(p)
        set SwapIndex[pId] = 0
        set TransferIndex[pId] = 0
        set TransferItem[pId] = null
        set SplitRequested[pId] = 0
        set SplitAmount[pId] = 0
        call SetSellHotkeyArmed(pId, false)
        call SwapHighlightHide(pId)
    endfunction

    private function RequestBagCloseSync takes player p returns nothing
        local integer pId
        if p == null then
            return
        endif

        set pId = GetPlayerId(p)
        if not BagEnabledForPlayer(p) or not BagPanelOpen[pId] or SwapIndex[pId] > 0 then
            return
        endif

        if GetLocalPlayer() == p then
            call BlzSendSyncData(BAG_CLOSE_SYNC_PREFIX, "close")
        endif
    endfunction

    private function BagCloseSyncAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId
        local string data = BlzGetTriggerSyncData()

        if data != "close" or not BagEnabledForPlayer(p) then
            set p = null
            set data = null
            return
        endif

        set pId = GetPlayerId(p)
        if BagPanelOpen[pId] and SwapIndex[pId] <= 0 then
            call CloseBagPanelFromSyncedRequest(p)
        endif

        set p = null
        set data = null
    endfunction

    public function TasItemBagUnitCanUseItems takes unit u returns boolean
        // check for USE flag
        if GetUnitAbilityLevel(u, 'AInv') > 0 and BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, 'AInv'), AbilityFieldUse, 0) > 0 then
            return true
        endif

        return false
    endfunction

    public function TasItemBagUnitIsDropItems takes unit u returns boolean
        // check for DROP flag
        if GetUnitAbilityLevel(u, 'AInv') > 0 and BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, 'AInv'), AbilityFieldDrop, 0) > 0 then
            return true
        endif

        return false
    endfunction
    
    // private function DropsOnDeath takes unit u returns boolean
    //     local integer i = 0
    //     if not IsUnitType(u, UNIT_TYPE_HERO) then
    //         return true
    //     endif
    //     if TasItemBagUnitIsDropItems(u) then
    //         return true
    //     endif
    
    //     return false
    // endfunction

    // private function CountItemsOfClass takes unit u, itemtype itemClass returns integer
    //     local integer count = 0
    //     local integer i = 0
    //     loop
    //         exitwhen i >= bj_MAX_INVENTORY
    //         if GetItemType(UnitItemInSlot(u, i)) == itemClass then
    //             set count = count + 1
    //         endif
    //         set i = i + 1
    //     endloop
    //     return count
    // endfunction

    private function UnitCanDropItems takes unit u returns boolean
        // check for the CAN DROP flag
        if GetUnitAbilityLevel(u, 'AInv') > 0 and BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, 'AInv'), AbilityFieldCanDrop, 0) == 0 then
            return false
        endif

        return true    
    endfunction

    private function CanDropItem takes item it returns boolean
        return BlzGetItemBooleanField(it, ITEM_BF_CAN_BE_DROPPED)
    endfunction

    private function UnitCanEquipItem takes unit u, item i returns boolean
        // don't use returns, to display all errors
        local boolean returnValue = true
        local integer itemCode = GetItemTypeId(i)
        // units that can not use items, ignore requirements hence return true when not
        local boolean canUse = false
        local integer loopA = 0
        
        if not TasItemBagUnitCanUseItems(u) then
            return true
        endif
        // use Item Level as requirement. A lower Level can not equip it
        if ItemLevelRestriction and TasItemBagUnitCanUseItems(u) and GetUnitLevel(u) < GetItemLevel(i) then
            call DisplayTimedTextToPlayer(GetOwningPlayer(u), 0, 0, 20, GetItemName(i) + " needs " + GetLocalizedString("LEVEL") + " " + I2S(GetItemLevel(i)))
            set returnValue = false
        endif
        // itemCode can require an ability
        // if ItemAbilityNeed[itemCode] != 0 and GetUnitAbilityLevel(u, ItemAbilityNeed[itemCode]) == 0 then
        //     call DisplayTimedTextToPlayer(GetOwningPlayer(u), 0, 0, 20, GetItemName(i) + " needs Ability " + GetObjectName(ItemAbilityNeed[itemCode]))
        //     set returnValue = false
        // endif
        // if EquipClassLimit <= CountItemsOfClass(u, GetItemType(i)) then
        //     call DisplayTimedTextToPlayer(GetOwningPlayer(u), 0, 0, 20, "To many Items of this Item-Class")
        //     return false
        // endif
        return returnValue
    endfunction

    // Moves the item in the given inventory slot into the player's bag
    private function DepositInventorySlot takes player p, integer slot returns nothing
        local unit hero = udg_Heroes[GetPlayerNumber(p)]
        local item it
        local integer playerKey
        if hero == null then
            return
        endif
        set it = UnitItemInSlot(hero, slot)
        if it == null then
            return
        endif
        set playerKey = GetPlayerId(p)
        if BagNextEmptySlot(playerKey) <= 0 and not BagHasMergeSpace(playerKey, it) then
            call PlayInventoryFullRaceSoundPlaceholder(p, hero)
            call NeatErrorMessage(BAG_FULL_MESSAGE, p)
            call RequestUIUpdate()
            set it = null
            return
        endif
        call TasItemBagAddItem(hero, it, true)
        set it = null
        set hero = null
    endfunction

    // Queue a world drop for selected bag item: hero moves to point, then item is dropped there.
    private function ClearWorldDropQueue takes integer pId returns nothing
        set WorldDropActive[pId] = false
        set WorldDropBagIndex[pId] = 0
        set WorldDropX[pId] = 0.0
        set WorldDropY[pId] = 0.0
        set WorldDropTimeLeft[pId] = 0.0
        set IgnoreNextWorldDropOrder[pId] = false
    endfunction

    private function ClearPickupIntent takes integer pId returns nothing
        set PickupIntentActive[pId] = false
        set PickupIntentHero[pId] = null
        set PickupIntentItem[pId] = null
        set PickupIntentTimeLeft[pId] = 0.0
        set PickupIntentReliefStaleTime[pId] = 0.0
        set PickupIntentProcessed[pId] = false
        set PickupIntentOriginalPage[pId] = 0
        set PickupIntentSwitchPage[pId] = 0
    endfunction

    private function CanPickupAbsorbIntoLiveInventory takes unit hero, item targetItem returns boolean
        local integer slot = 0
        local integer maxSlots
        local integer itemType
        local item invItem

        if hero == null or targetItem == null then
            return false
        endif
        if IsItemPowerup(targetItem) and TasItemBagUnitCanUseItems(hero) then
            return true
        endif
        if not IsStackableType(targetItem) or GetItemCharges(targetItem) <= 0 then
            return false
        endif

        set itemType = GetItemTypeId(targetItem)
        set maxSlots = UnitInventorySize(hero)
        loop
            exitwhen slot >= maxSlots
            set invItem = UnitItemInSlot(hero, slot)
            if invItem != null and IsStackableType(invItem) and GetItemTypeId(invItem) == itemType and GetItemCharges(invItem) < DEFAULT_MAX_CHARGES then
                set invItem = null
                return true
            endif
            set slot = slot + 1
        endloop

        set invItem = null
        return false
    endfunction

    private function HandleBlockedPickupIntent takes player p, unit hero, item targetItem returns boolean
        local integer pId = GetPlayerId(p)
        if CanPickupAbsorbIntoLiveInventory(hero, targetItem) then
            call ClearPickupIntent(pId)
            return false
        endif

        call PlayInventoryFullRaceSoundPlaceholder(p, hero)
        call NeatErrorMessage(INVENTORY_PAGES_FULL_MESSAGE, p)
        call ClearPickupIntent(pId)
        return true
    endfunction

    private function StartPickupWarningSuppression takes integer pId, real duration returns nothing
        if duration <= 0.0 then
            set duration = PICKUP_WARN_SUPPRESS_WINDOW
        endif
        set PickupWarnSuppressActive[pId] = true
        if PickupWarnSuppressTimeLeft[pId] < duration then
            set PickupWarnSuppressTimeLeft[pId] = duration
        endif
    endfunction

    private function TickPickupWarningSuppression takes integer pId returns nothing
        if not PickupWarnSuppressActive[pId] then
            return
        endif

        set PickupWarnSuppressTimeLeft[pId] = PickupWarnSuppressTimeLeft[pId] - 0.03
        if GetLocalPlayer() == Player(pId) then
            call StopSound(gg_snd_Error, false, false)
            call ClearTextMessages()
        endif

        if PickupWarnSuppressTimeLeft[pId] <= 0.0 then
            set PickupWarnSuppressActive[pId] = false
            set PickupWarnSuppressTimeLeft[pId] = 0.0
        endif
    endfunction

    private function PickupIntentShouldUseImmediateRelief takes unit hero returns boolean
        return PickupIntentUseImmediateRelief
    endfunction

    private function RestorePlayerIntendedPageForPlayer takes player p, unit u returns boolean
        local integer pId
        local integer playerNum
        local integer currentPage
        local integer intendedPage

        if p == null or u == null then
            return false
        endif

        set pId = GetPlayerId(p)
        set playerNum = GetPlayerHeroNumber(p)
        set currentPage = udg_Bag_Page[playerNum]
        set intendedPage = MPInventoryGetPlayerIntendedPage(p)
        if intendedPage > 0 and currentPage != intendedPage then
            if MPInventorySwitchToPage(p, intendedPage) then
                call Debug("Auto-return to intended page: player=" + I2S(pId) + ", page " + I2S(currentPage) + " -> " + I2S(intendedPage))
                return true
            endif
            return false
        endif
        return true
    endfunction

    private function StartPickupIntent takes player p, unit hero, item targetItem returns nothing
        local integer pId = GetPlayerId(p)
        local integer playerNum = GetPlayerHeroNumber(p)
        local integer currentPage
        local integer reliefPage

        if hero == null or targetItem == null then
            call ClearPickupIntent(pId)
            return
        endif
        if UnitInventorySize(hero) <= 0 then
            call ClearPickupIntent(pId)
            return
        endif
        if CanPickupAbsorbIntoLiveInventory(hero, targetItem) then
            call ClearPickupIntent(pId)
            return
        endif

        // No need to assist when inventory still has space.
        if UnitInventoryCount(hero) < UnitInventorySize(hero) then
            call ClearPickupIntent(pId)
            return
        endif

        // Refresh same-item intent without losing original-page context.
        if PickupIntentActive[pId] and PickupIntentItem[pId] == targetItem then
            set PickupIntentHero[pId] = hero
            set PickupIntentTimeLeft[pId] = PICKUP_INTENT_TIMEOUT
            set PickupIntentReliefStaleTime[pId] = 0.0

            set currentPage = udg_Bag_Page[playerNum]
            if not PickupIntentProcessed[pId] and PickupIntentShouldUseImmediateRelief(hero) then
                set reliefPage = MPInventoryFindPageWithEmptySlot(p, currentPage)
                if reliefPage > 0 and MPInventorySwitchToPage(p, reliefPage) then
                    call StartPickupWarningSuppression(pId, PICKUP_WARN_SUPPRESS_WINDOW)
                    set PickupIntentProcessed[pId] = true
                    set PickupIntentSwitchPage[pId] = reliefPage
                    set PickupIntentReliefStaleTime[pId] = 0.0
                    call Debug("Pickup intent refreshed relief switch: player=" + I2S(pId) + ", page " + I2S(currentPage) + " -> " + I2S(reliefPage))
                elseif reliefPage <= 0 then
                    if HandleBlockedPickupIntent(p, hero, targetItem) then
                        return
                    endif
                endif
            elseif PickupIntentProcessed[pId] then
                call StartPickupWarningSuppression(pId, PICKUP_WARN_SUPPRESS_WINDOW)
            endif
            return
        endif

        set PickupIntentActive[pId] = true
        set PickupIntentHero[pId] = hero
        set PickupIntentItem[pId] = targetItem
        set PickupIntentTimeLeft[pId] = PICKUP_INTENT_TIMEOUT
        set PickupIntentReliefStaleTime[pId] = 0.0
        set PickupIntentProcessed[pId] = false
        set PickupIntentOriginalPage[pId] = udg_Bag_Page[playerNum]
        set PickupIntentSwitchPage[pId] = 0
        call Debug("Pickup intent armed: player=" + I2S(pId) + ", page=" + I2S(PickupIntentOriginalPage[pId]) + ", item=" + GetItemName(targetItem))

        // Optional immediate-first relief. For pure A2 testing keep this disabled.
        set currentPage = udg_Bag_Page[playerNum]
        set reliefPage = MPInventoryFindPageWithEmptySlot(p, currentPage)
        if PickupIntentShouldUseImmediateRelief(hero) and reliefPage > 0 and MPInventorySwitchToPage(p, reliefPage) then
            call StartPickupWarningSuppression(pId, PICKUP_WARN_SUPPRESS_WINDOW)
            set PickupIntentProcessed[pId] = true
            set PickupIntentSwitchPage[pId] = reliefPage
            set PickupIntentReliefStaleTime[pId] = 0.0
            call Debug("Pickup intent immediate relief switch: player=" + I2S(pId) + ", page " + I2S(currentPage) + " -> " + I2S(reliefPage))
        elseif PickupIntentShouldUseImmediateRelief(hero) and reliefPage <= 0 then
            call HandleBlockedPickupIntent(p, hero, targetItem)
        endif
    endfunction

    private function PickupIntentTimerAction takes nothing returns nothing
        local integer pId = 0
        local player p
        local unit hero
        local item targetItem
        local integer playerNum
        local integer currentPage
        local integer reliefPage
        local real dx
        local real dy
        local real dist

        loop
            exitwhen pId >= bj_MAX_PLAYERS
            if LastSmartPickupTimeLeft[pId] > 0.0 then
                set LastSmartPickupTimeLeft[pId] = LastSmartPickupTimeLeft[pId] - 0.03
                if LastSmartPickupTimeLeft[pId] <= 0.0 then
                    set LastSmartPickupTimeLeft[pId] = 0.0
                    set LastSmartPickupTarget[pId] = null
                endif
            endif
            call TickPickupWarningSuppression(pId)
            if PickupIntentActive[pId] then
                set p = Player(pId)
                set hero = PickupIntentHero[pId]
                set targetItem = PickupIntentItem[pId]

                if hero == null or GetWidgetLife(hero) <= 0.405 then
                    call ClearPickupIntent(pId)
                elseif targetItem == null then
                    call ClearPickupIntent(pId)
                elseif UnitHasItem(hero, targetItem) then
                    // Item already picked up; clear the intent.
                    call ClearPickupIntent(pId)
                else
                    set PickupIntentTimeLeft[pId] = PickupIntentTimeLeft[pId] - 0.03
                    if PickupIntentTimeLeft[pId] <= 0.0 then
                        if PickupIntentProcessed[pId] then
                            call RestorePlayerIntendedPageForPlayer(p, hero)
                        endif
                        call ClearPickupIntent(pId)
                    elseif PickupIntentProcessed[pId] then
                        set playerNum = GetPlayerHeroNumber(p)
                        set currentPage = udg_Bag_Page[playerNum]
                        if currentPage == PickupIntentSwitchPage[pId] and IsInCombat(hero) then
                            set PickupIntentReliefStaleTime[pId] = PickupIntentReliefStaleTime[pId] + 0.03
                            if PickupIntentReliefStaleTime[pId] >= PICKUP_INTENT_RELIEF_STALE_DELAY then
                                if IsStunned(hero) or IsRooted(hero) or IsUnitPaused(hero) then
                                    set PickupIntentReliefStaleTime[pId] = PICKUP_INTENT_RELIEF_STALE_DELAY
                                else
                                    if RestorePlayerIntendedPageForPlayer(p, hero) then
                                        call Debug("Pickup intent stale relief restored: player=" + I2S(pId) + ", page=" + I2S(currentPage))
                                        call ClearPickupIntent(pId)
                                    else
                                        set PickupIntentReliefStaleTime[pId] = 0.0
                                    endif
                                endif
                            endif
                        else
                            set PickupIntentReliefStaleTime[pId] = 0.0
                        endif
                    elseif (not PickupIntentProcessed[pId]) and UnitInventoryCount(hero) >= UnitInventorySize(hero) then
                        set dx = GetUnitX(hero) - GetItemX(targetItem)
                        set dy = GetUnitY(hero) - GetItemY(targetItem)
                        set dist = SquareRoot(dx*dx + dy*dy)
                        if dist <= PICKUP_INTENT_REACH then
                            set playerNum = GetPlayerHeroNumber(p)
                            set currentPage = udg_Bag_Page[playerNum]
                            set reliefPage = MPInventoryFindPageWithEmptySlot(p, currentPage)
                            if reliefPage > 0 and MPInventorySwitchToPage(p, reliefPage) then
                                call StartPickupWarningSuppression(pId, PICKUP_WARN_SUPPRESS_WINDOW)
                                set PickupIntentProcessed[pId] = true
                                set PickupIntentSwitchPage[pId] = reliefPage
                                set PickupIntentReliefStaleTime[pId] = 0.0
                                call Debug("Pickup intent relief switch: player=" + I2S(pId) + ", page " + I2S(currentPage) + " -> " + I2S(reliefPage))
                            elseif reliefPage <= 0 then
                                call HandleBlockedPickupIntent(p, hero, targetItem)
                            endif
                        endif
                    endif
                endif
            endif
            set targetItem = null
            set hero = null
            set p = null
            set pId = pId + 1
        endloop
    endfunction

    private function ResolvePickupIntentOnGain takes unit u, item gained returns nothing
        local player p
        local integer pId
        local item resolvedItem

        if u == null then
            return
        endif

        set p = GetOwningPlayer(u)
        set pId = GetPlayerId(p)

        if not PickupIntentActive[pId] then
            set p = null
            return
        endif

        set resolvedItem = PickupIntentItem[pId]
        // Handle-robust match: when gained is present, accept direct or same-type while intent is active.
        // If gained is null (merge/consume edge), keep intent item as authoritative.
        if gained != null and gained != resolvedItem then
            if resolvedItem == null or GetItemTypeId(gained) != GetItemTypeId(resolvedItem) then
                set resolvedItem = null
            endif
        endif
        if resolvedItem == null then
            set p = null
            return
        endif

        call ClearPickupIntent(pId)
        set resolvedItem = null
        set p = null
    endfunction

    private function RestorePlayerIntendedPage takes unit u returns nothing
        local player p

        if u == null then
            return
        endif

        set p = GetOwningPlayer(u)
        call RestorePlayerIntendedPageForPlayer(p, u)
        set p = null
    endfunction

    private function PlayDropConfirmationEffect takes player p, real x, real y returns nothing
        local effect arrow = AddSpecialEffect("UI\\Feedback\\Confirmation\\Confirmation.mdl", x, y)
        call BlzSetSpecialEffectColor(arrow, 0, 255, 0)
        if GetLocalPlayer() != p then
            call BlzSetSpecialEffectAlpha(arrow, 0)
        endif
        call DestroyEffect(arrow)
        set arrow = null
    endfunction

    private function StartWorldDropFromSelection takes player p, integer bagIndex, real x, real y returns boolean
        local integer pId = GetPlayerId(p)
        local unit hero = udg_Heroes[GetPlayerNumber(p)]
        local item it
        if hero == null then
            return false
        endif
        if bagIndex <= 0 or bagIndex > MAX_INTERACTIVE_SLOT then
            set hero = null
            return false
        endif
        set it = TasItemBagGetItem(hero, bagIndex)
        if it == null then
            set hero = null
            set it = null
            return false
        endif

        set WorldDropActive[pId] = true
        set WorldDropBagIndex[pId] = bagIndex
        set WorldDropX[pId] = x
        set WorldDropY[pId] = y
        set WorldDropTimeLeft[pId] = WORLD_DROP_TIMEOUT
        set IgnoreNextWorldDropOrder[pId] = true
        call IssuePointOrder(hero, "move", x, y)

        call PlayDropConfirmationEffect(p, x, y)
        set hero = null
        set it = null
        return true
    endfunction

    private function WorldDropTimerAction takes nothing returns nothing
        local integer pId = 0
        local unit hero
        local item it
        local real dx
        local real dy
        local real dist
        loop
            exitwhen pId >= bj_MAX_PLAYERS
            if WorldDropActive[pId] then
                set hero = udg_Heroes[GetPlayerNumber(Player(pId))]
                if hero == null or GetWidgetLife(hero) <= 0.405 then
                    call ClearWorldDropQueue(pId)
                else
                    set it = TasItemBagGetItem(hero, WorldDropBagIndex[pId])
                    if it == null then
                        call ClearWorldDropQueue(pId)
                    else
                        set WorldDropTimeLeft[pId] = WorldDropTimeLeft[pId] - 0.03
                        if WorldDropTimeLeft[pId] <= 0.0 then
                            call ClearWorldDropQueue(pId)
                            set it = null
                            set hero = null
                            set pId = pId + 1
                            exitwhen pId >= bj_MAX_PLAYERS
                        endif
                        set dx = GetUnitX(hero) - WorldDropX[pId]
                        set dy = GetUnitY(hero) - WorldDropY[pId]
                        set dist = SquareRoot(dx*dx + dy*dy)
                        if dist <= WORLD_DROP_REACH then
                            if TasItemBagRemoveIndex(hero, WorldDropBagIndex[pId], false) then
                                call SetItemPosition(it, WorldDropX[pId], WorldDropY[pId])
                                call SetItemUserData(it, 0)
                                // call SetItemVisible(it, true)
                            endif
                            call ClearWorldDropQueue(pId)
                        endif
                    endif
                endif
            endif
            set it = null
            set hero = null
            set pId = pId + 1
        endloop
    endfunction

    // Any new player order to the hero cancels pending world-drop, except our own queued move order.
    private function UnitOrderAction takes nothing returns nothing
        local unit u = GetTriggerUnit()
        local player owner
        local integer pId
        local integer orderId
        local integer eventId
        local item orderTargetItem
        local boolean handledQuickUseOrder = false
        local boolean quickUseTargetIssued = false
        if u == null then
            return
        endif
        set owner = GetOwningPlayer(u)
        set pId = GetPlayerId(owner)
        set orderId = GetIssuedOrderId()
        set eventId = GetHandleId(GetTriggerEventId())
        set orderTargetItem = GetOrderTargetItem()
        if u == udg_Heroes[GetPlayerNumber(owner)] then
            if QuickUseIgnoreNextOrder[pId] then
                set QuickUseIgnoreNextOrder[pId] = false
                set handledQuickUseOrder = true
            elseif QuickUseActive[pId] and not QuickUsePendingLocalActivate[pId] then
                if QuickUseAwaitingTarget[pId] then
                    if eventId == GetHandleId(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER) or eventId == GetHandleId(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER) then
                        if QuickUseNativeTargeting[pId] then
                            call StartQuickUseTargetResolve(pId)
                            set handledQuickUseOrder = true
                        elseif QuickUseTargetModeForItemType(QuickUseTrackedItemTypeId(pId)) == QUICK_USE_TARGET_MODE_POINT then
                            set handledQuickUseOrder = true
                        else
                            set quickUseTargetIssued = TryQuickUseTargetedActivation(pId, u)
                            if quickUseTargetIssued then
                                set handledQuickUseOrder = true
                            else
                                call QueueQuickUseRestore(pId)
                            endif
                        endif
                    elseif IsQuickUseCancelOrder(orderId) then
                        call QueueQuickUseRestore(pId)
                        set handledQuickUseOrder = true
                    endif
                elseif IsQuickUseCancelOrder(orderId) then
                    call QueueQuickUseRestore(pId)
                endif
            endif

            // Option A2 pickup intent tracking from SMART item-target orders.
            // Do not clear on follow-up move orders; clear only when retargeting to another item.
            if not handledQuickUseOrder and orderId == ORDER_ID_SMART and orderTargetItem != null then
                set LastSmartPickupTarget[pId] = orderTargetItem
                set LastSmartPickupTimeLeft[pId] = LAST_SMART_PICKUP_WINDOW
                if PickupIntentActive[pId] and orderTargetItem != PickupIntentItem[pId] then
                    call ClearPickupIntent(pId)
                endif
                call StartPickupIntent(owner, u, orderTargetItem)
                // Any other explicit order from the player invalidates prior smart pickup intent/target.
                // This prevents stale long-window targets from leaking into unrelated gains.
            elseif not handledQuickUseOrder and orderId != ORDER_ID_SMART then
                set LastSmartPickupTarget[pId] = null
                set LastSmartPickupTimeLeft[pId] = 0.0
                if PickupIntentActive[pId] then
                    // After a relief page-switch the engine issues follow-up movement
                    // orders. Don't kill the intent until the pickup actually fires.
                    if not PickupIntentProcessed[pId] then
                        call ClearPickupIntent(pId)
                    endif
                endif
            endif

            if WorldDropActive[pId] then
                if IgnoreNextWorldDropOrder[pId] then
                    set IgnoreNextWorldDropOrder[pId] = false
                else
                    call ClearWorldDropQueue(pId)
                endif
            endif
        endif
        set orderTargetItem = null
        set owner = null
        set u = null
    endfunction

    // Finalize an armed bag swap onto an inventory slot (occupied or empty).
    // If occupied, the inventory item is moved into the original bag slot.
    private function FirstOpenInventorySlot takes unit hero returns integer
        local integer slot = 0
        if hero == null then
            return -1
        endif
        loop
            exitwhen slot >= bj_MAX_INVENTORY
            if UnitItemInSlot(hero, slot) == null then
                return slot
            endif
            set slot = slot + 1
        endloop
        return -1
    endfunction

    private function SwapBagSlotToInventorySlot takes player p, integer invSlot returns boolean
        local integer pId = GetPlayerId(p)
        local unit hero = udg_Heroes[GetPlayerNumber(p)]
        local integer bagSlot = SwapIndex[pId]
        local integer targetSlot
        local item bagItem

        if hero == null or bagSlot <= 0 then
            return false
        endif
        if invSlot < 0 or invSlot >= bj_MAX_INVENTORY then
            return false
        endif

        set targetSlot = GetActivePageDisplayStart(pId)
        if targetSlot <= 0 then
            return false
        endif
        set targetSlot = targetSlot + invSlot

        set bagItem = TasItemBagGetItem(hero, bagSlot)
        if bagItem == null then
            return false
        endif
        if not UnitCanEquipItem(hero, bagItem) then
            set bagItem = null
            return false
        endif

        if bagSlot == targetSlot then
            set bagItem = null
            set hero = null
            return true
        endif

        set bagItem = null
        set hero = null
        return TasItemBagSwap(udg_Heroes[GetPlayerNumber(p)], bagSlot, targetSlot)
    endfunction

    private function RequestBagInventoryInsertSync takes player p, integer invSlot returns nothing
        local integer pId
        if p == null then
            return
        endif

        set pId = GetPlayerId(p)
        if not BagEnabledForPlayer(p) or not BagPanelOpen[pId] or SwapIndex[pId] <= 0 then
            return
        endif
        if invSlot < 0 or invSlot >= bj_MAX_INVENTORY then
            return
        endif

        if GetLocalPlayer() == p then
            call BlzSendSyncData(BAG_INSERT_SYNC_PREFIX, I2S(invSlot))
        endif
    endfunction

    private function BagInventoryInsertSyncAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId
        local string data = BlzGetTriggerSyncData()
        local integer invSlot

        if not BagEnabledForPlayer(p) or StringLength(data) != 1 then
            set p = null
            set data = null
            return
        endif

        set invSlot = S2I(data)
        if data != I2S(invSlot) or invSlot < 0 or invSlot >= bj_MAX_INVENTORY then
            set p = null
            set data = null
            return
        endif

        set pId = GetPlayerId(p)
        if BagPanelOpen[pId] and SwapIndex[pId] > 0 and SwapBagSlotToInventorySlot(p, invSlot) then
            call PlaySwapConfirmSound(p)
            set SwapIndex[pId] = 0
            call SuppressBagPopupUntilNextFrame(pId)
            call SwapHighlightHide(pId)
            call HideBagPopupPanels(p)
            set DragOriginType[pId] = 0
            set DragOriginIndex[pId] = 0
            set DragActive[pId] = false
        endif

        set p = null
        set data = null
    endfunction

    private function FindBagDropPayloadSeparator takes string data, integer start returns integer
        local integer i = start
        local integer dataLength = StringLength(data)
        loop
            exitwhen i >= dataLength
            if SubString(data, i, i + 1) == "|" then
                return i
            endif
            set i = i + 1
        endloop
        return -1
    endfunction

    private function RequestBagDropSync takes player p, integer bagIndex, real x, real y returns nothing
        local string payload
        if p == null then
            return
        endif
        if not BagEnabledForPlayer(p) or not BagPanelOpen[GetPlayerId(p)] then
            return
        endif
        if bagIndex <= 0 or bagIndex > MAX_INTERACTIVE_SLOT then
            return
        endif

        if GetLocalPlayer() == p then
            set payload = I2S(bagIndex) + "|" + I2S(R2I(x)) + "|" + I2S(R2I(y))
            call BlzSendSyncData(BAG_DROP_SYNC_PREFIX, payload)
        endif
        set payload = null
    endfunction

    private function BagDropSyncAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId
        local string data = BlzGetTriggerSyncData()
        local integer sepA
        local integer sepB
        local string bagText
        local string xText
        local string yText
        local integer bagIndex
        local integer dropX
        local integer dropY

        if not BagEnabledForPlayer(p) then
            set p = null
            set data = null
            return
        endif

        set sepA = FindBagDropPayloadSeparator(data, 0)
        set sepB = FindBagDropPayloadSeparator(data, sepA + 1)
        if sepA <= 0 or sepB <= sepA + 1 or sepB >= StringLength(data) then
            set p = null
            set data = null
            return
        endif

        set bagText = SubString(data, 0, sepA)
        set xText = SubString(data, sepA + 1, sepB)
        set yText = SubString(data, sepB + 1, StringLength(data))
        set bagIndex = S2I(bagText)
        set dropX = S2I(xText)
        set dropY = S2I(yText)
        if bagText != I2S(bagIndex) or xText != I2S(dropX) or yText != I2S(dropY) or bagIndex <= 0 or bagIndex > MAX_INTERACTIVE_SLOT then
            set p = null
            set data = null
            set bagText = null
            set xText = null
            set yText = null
            return
        endif

        set pId = GetPlayerId(p)
        if StartWorldDropFromSelection(p, bagIndex, I2R(dropX), I2R(dropY)) then
            set SwapIndex[pId] = 0
            call SwapHighlightHide(pId)
            set DragOriginType[pId] = 0
            set DragOriginIndex[pId] = 0
            set DragActive[pId] = false
        endif

        call SetSellHotkeyArmed(pId, false)
        call HideBagPopupPanels(p)
        if TransferIndex[pId] == bagIndex then
            set TransferIndex[pId] = 0
            set TransferItem[pId] = null
        endif
        set SplitRequested[pId] = 0
        set SplitAmount[pId] = 0

        set p = null
        set data = null
        set bagText = null
        set xText = null
        set yText = null
    endfunction

    private function BagPopupActionSelect takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(GetTriggerPlayer())
        if GetLocalPlayer() == p then
            call BlzFrameSetVisible(BlzFrameGetParent(BlzGetTriggerFrame()), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
        endif
        set SwapIndex[pId] = TransferIndex[pId]
        call SwapHighlightShowOnSlot(pId, SwapIndex[pId])
        call PlaySwapSelectSound(p)
        call FrameLoseFocus()
    endfunction

    private function FindNearbySellShop takes unit hero returns unit
        local group g
        local unit u
        local player owner
        if hero == null then
            return null
        endif
        set owner = GetOwningPlayer(hero)
        set g = CreateGroup()
        call GroupEnumUnitsInRange(g, GetUnitX(hero), GetUnitY(hero), SELL_RANGE, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if IsVendorUnit(u) and GetWidgetLife(u) > 0.405 and not IsPlayerEnemy(GetOwningPlayer(u), owner) then
                call DestroyGroup(g)
                set g = null
                set owner = null
                return u
            endif
        endloop
        call DestroyGroup(g)
        set g = null
        set owner = null
        return null
    endfunction

    // Find a vendor unit near a world-space click point (used when armed-select clicks on a shop).
    // Find the nearest vendor within DETECT_VENDOR_RANGE of the click point (no hero range check).
    private function FindVendorNearClick takes player p, real x, real y returns unit
        local group g
        local unit u
        local unit best = null
        local real bestDist = 99999.0
        local real dx
        local real dy
        local real dist
        set g = CreateGroup()
        call GroupEnumUnitsInRange(g, x, y, DETECT_VENDOR_RANGE, null)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
            call GroupRemoveUnit(g, u)
            if IsVendorUnit(u) and GetWidgetLife(u) > 0.405 and not IsPlayerEnemy(GetOwningPlayer(u), p) then
                set dx = GetUnitX(u) - x
                set dy = GetUnitY(u) - y
                set dist = dx*dx + dy*dy
                if dist < bestDist then
                    set bestDist = dist
                    set best = u
                endif
            endif
        endloop
        call DestroyGroup(g)
        set g = null
        set u = null
        return best
    endfunction

    private function IsHeroInSellRange takes player p, unit shop returns boolean
        local unit hero = udg_Heroes[GetPlayerNumber(p)]
        local real dx
        local real dy
        if hero == null or shop == null then
            return false
        endif
        set dx = GetUnitX(hero) - GetUnitX(shop)
        set dy = GetUnitY(hero) - GetUnitY(shop)
        set hero = null
        return SquareRoot(dx*dx + dy*dy) <= SELL_RANGE
    endfunction

    private function ItemLoseRefreshAction takes nothing returns nothing
        local unit hero = GetTriggerUnit()
        if hero == null then
            return
        endif
        if IsPlayerHero(hero) and GetItemType(GetManipulatedItem()) != ITEM_TYPE_POWERUP then
            call RequestUIUpdate()
        endif
        set hero = null
    endfunction

    private function ItemUseAction takes nothing returns nothing
        local unit hero = GetTriggerUnit()
        local player p
        local integer pId
        local item usedItem = GetManipulatedItem()
        local integer trackedType

        if hero == null then
            set usedItem = null
            return
        endif

        set p = GetOwningPlayer(hero)
        if not BagEnabledForPlayer(p) or hero != udg_Heroes[GetPlayerNumber(p)] then
            set hero = null
            set p = null
            set usedItem = null
            return
        endif

        set pId = GetPlayerId(p)
        set trackedType = QuickUseTrackedItemTypeId(pId)
        if QuickUseActive[pId] and usedItem != null and trackedType != 0 and GetItemTypeId(usedItem) == trackedType then
            set QuickUseItem[pId] = usedItem
            if QuickUseAwaitingTarget[pId] and QuickUseItemNeedsExplicitTarget(usedItem) then
                set QuickUseNativeTargeting[pId] = true
            elseif QuickUseItemNeedsExplicitTarget(usedItem) then
                call StartQuickUseTargetResolve(pId)
            else
                call QueueQuickUseRestore(pId)
            endif
        endif

        set hero = null
        set p = null
        set usedItem = null
    endfunction

    private function SpellEffectAction takes nothing returns nothing
        local unit hero = GetTriggerUnit()
        local player p
        local integer pId
        local integer trackedType

        if hero == null then
            return
        endif

        set p = GetOwningPlayer(hero)
        if not BagEnabledForPlayer(p) or hero != udg_Heroes[GetPlayerNumber(p)] then
            set hero = null
            set p = null
            return
        endif

        set pId = GetPlayerId(p)
        if not QuickUseActive[pId] then
            set hero = null
            set p = null
            return
        endif

        set trackedType = QuickUseTrackedItemTypeId(pId)
        if trackedType != 0 and QuickUseTargetAbilityIdForItemType(trackedType) == GetSpellAbilityId() then
            call QueueQuickUseRestore(pId)
        endif

        set hero = null
        set p = null
    endfunction

    private function SellBagIndexToShop takes player p, integer bagIndex, unit shop, boolean requireRange returns boolean
        local unit hero = udg_Heroes[GetPlayerNumber(p)]
        local item it
        local texttag gainTag
        local integer goldGain
        local integer itemType
        local integer stackCount
        local real dx
        local real dy
        local location heroLoc

        if hero == null then
            return false
        endif
        if bagIndex <= 0 or bagIndex > MAX_INTERACTIVE_SLOT then
            set hero = null
            return false
        endif

        set it = TasItemBagGetItem(hero, bagIndex)
        if it == null then
            set hero = null
            return false
        endif

        if not IsItemPawnable(it) then
            call NeatErrorMessage("This item cannot be sold.", p)
            set hero = null
            set it = null
            return false
        endif

        if shop == null or not IsVendorUnit(shop) then
            call NeatErrorMessage("No shop in range.", p)
            set hero = null
            set it = null
            set shop = null
            return false
        endif

        if requireRange then
            set dx = GetUnitX(hero) - GetUnitX(shop)
            set dy = GetUnitY(hero) - GetUnitY(shop)
            if SquareRoot(dx*dx + dy*dy) > SELL_RANGE then
                call NeatErrorMessage("No shop in range.", p)
                set hero = null
                set it = null
                set shop = null
                return false
            endif
        endif

        set itemType = GetItemTypeId(it)
        set goldGain = TasItemGetCostGold(itemType) / 2
        if IsStackableType(it) then
            set stackCount = GetItemCharges(it)
            if stackCount > 0 then
                set goldGain = goldGain * stackCount
            endif
        elseif itemType == HEARTSEEKER_ITEM_ID then
            set stackCount = GetItemCharges(it)
            if stackCount > HEARTSEEKER_BASE_STACKS then
                set goldGain = goldGain + ((goldGain * (stackCount - HEARTSEEKER_BASE_STACKS)) / HEARTSEEKER_BASE_STACKS)
            endif
        endif

        if TasItemBagRemoveIndex(hero, bagIndex, false) then
            call RemoveItem(it)
            call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) + goldGain)

            set heroLoc = GetUnitLoc(hero)
            call CreateTextTagLocBJ("|cffffcc00+" + I2S(goldGain) + "|r", heroLoc, 25, 10.0, 100, 100, 100, 0)
            set gainTag = GetLastCreatedTextTag()
            call SetTextTagVisibility(gainTag, false)
            if IsHordePlayer(p) then
                call SetTextTagVisibility(gainTag, true)
            elseif IsAlliancePlayer(p) then
                call SetTextTagVisibility(gainTag, true)
            endif
            call RemoveLocation(heroLoc)
            call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 50, 90 )
            call CleanUpText( 3.00, 2.00)
            call PlaySoundOnUnitBJ(gg_snd_ReceiveGold, 100.00, hero)
            set hero = null
            set heroLoc = null
            set it = null
            set shop = null
            set gainTag = null
            return true
        endif

        set hero = null
        set it = null
        set shop = null
        return false
    endfunction

    public function ClearSwapState takes integer pId returns nothing
        set SwapIndex[pId] = 0
        call SwapHighlightHide(pId)
    endfunction

    public function SellBagSlot takes player p, integer bagIndex, unit shop returns boolean
        return SellBagIndexToShop(p, bagIndex, shop, true)
    endfunction

    function TasItemBagSellSelectedForPlayer takes player p returns nothing
        local integer pId
        local unit hero
        local unit shop
        local item selectedItem
        if p == null then
            return
        endif
        if not BagEnabledForPlayer(p) then
            return
        endif

        set pId = GetPlayerId(p)
        if not SellHotkeyArmed[pId] then
            return
        endif
        set hero = udg_Heroes[GetPlayerNumber(p)]
        if hero == null then
            call SetSellHotkeyArmed(pId, false)
            call NeatErrorMessage("No hero available.", p)
            set hero = null
            return
        endif

        if TransferIndex[pId] <= 0 then
            call SetSellHotkeyArmed(pId, false)
            call NeatErrorMessage("Select a bag item first.", p)
            set hero = null
            return
        endif

        set selectedItem = TasItemBagGetItem(hero, TransferIndex[pId])
        if selectedItem == null or TransferItem[pId] != selectedItem then
            call SetSellHotkeyArmed(pId, false)
            call NeatErrorMessage("Select a bag item first.", p)
            set hero = null
            set selectedItem = null
            return
        endif

        set shop = FindNearbySellShop(hero)
        call SellBagIndexToShop(p, TransferIndex[pId], shop, true)
        call HideBagPopupPanels(p)
        call SetSellHotkeyArmed(pId, false)
        call FrameLoseFocus()
        set selectedItem = null
        set shop = null
        set hero = null
    endfunction

    private function BagPopupActionSell takes nothing returns nothing
        call TasItemBagSellSelectedForPlayer(GetTriggerPlayer())
    endfunction

    private function BagPopupActionSplit takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local item it
        local integer charges
        // For now: open the (stub) split panel. No actual splitting logic yet.
        set SplitRequested[pId] = TransferIndex[pId]
        call SetSellHotkeyArmed(pId, false)
        call HideBagPopupPanels(p)
        
        set it = TransferItem[pId]
        if it != null then
            set charges = GetItemCharges(it)
            if charges < 2 then
                set SplitAmount[pId] = 1
            else
                set SplitAmount[pId] = charges / 2
                if SplitAmount[pId] < 1 then
                    set SplitAmount[pId] = 1
                endif
                if SplitAmount[pId] >= charges then
                    set SplitAmount[pId] = charges - 1
                endif
            endif
        else
            set SplitAmount[pId] = 1
        endif
        if GetLocalPlayer() == p then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), true)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitMinus", 0), true)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPlus", 0), true)
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSplitInfo", 0), SplitLabelPrefix + I2S(SplitAmount[pId]))
        endif
        set it = null
        call FrameLoseFocus()
    endfunction

    private function BagPopupActionSplitAccept takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local item src
        local item newItem
        local integer total
        local integer take
        local integer remain
        local integer playerKey
        // Perform split: move "take" charges into a new bag item.
        call Debug("Performing split for index " + I2S(SplitRequested[pId]) + ", amount " + I2S(SplitAmount[pId]))
        set src = TransferItem[pId]
        call Debug("Source item: " + GetItemName(src))
        if src == null or SplitRequested[pId] <= 0 then
            if GetLocalPlayer() == p then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            endif
            set SplitRequested[pId] = 0
            set SplitAmount[pId] = 0
            call FrameLoseFocus()
            return
        endif
        set total = GetItemCharges(src)
        if total < 2 then
            if GetLocalPlayer() == p then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            endif
            set SplitRequested[pId] = 0
            set SplitAmount[pId] = 0
            call FrameLoseFocus()
            return
        endif
        set take = SplitAmount[pId]
        if take < 1 then
            set take = 1
        endif
        if take >= total then
            set take = total - 1
        endif
        // Respect bag stacking cap of 20 charges.
        if take > 20 then
            set take = 20
        endif

        set remain = total - take
        if remain < 1 then
            set remain = 1
            set take = total - 1
        endif

        // Ensure bag has room for a new item.
        set playerKey = GetPlayerId(p)
        if BagNextEmptySlot(playerKey) <= 0 then
            call PlayInventoryFullRaceSoundPlaceholder(p, udg_Heroes[GetPlayerNumber(p)])
            call NeatErrorMessage(BAG_FULL_MESSAGE, p)
            call RequestUIUpdate()
            if GetLocalPlayer() == p then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            endif
            set SplitRequested[pId] = 0
            set SplitAmount[pId] = 0
            call FrameLoseFocus()
            return
        endif

        // Update source item charges (stays in bag).
        call Debug("Settng source item: "+  GetItemName(src) + "charges: " + I2S(remain))
        call SetItemCharges(src, remain)

        // Create a new item of same type and add it to the bag.
        set newItem = CreateItem(GetItemTypeId(src), GetUnitX(udg_Heroes[GetPlayerNumber(p)]), GetUnitY(udg_Heroes[GetPlayerNumber(p)]))
        call SetItemCharges(newItem, take)
        
        // Do not auto-merge split-created stacks back into the source stack.
        call TasItemBagAddItem(udg_Heroes[GetPlayerNumber(p)], newItem, false)
        call Debug("Created new item: " + GetItemName(newItem) + " charges: " + I2S(take))
        set newItem = null
        
        // Close split + popup
        call HideBagPopupPanels(p)
        set SplitRequested[pId] = 0
        set SplitAmount[pId] = 0
        set src = null
        call FrameLoseFocus()
    endfunction

    private function BagPopupActionSplitMinus takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local item it = TransferItem[pId]
        local integer total
        if GetLocalPlayer() != p then
            set it = null
            return
        endif
        if it == null then
            set SplitAmount[pId] = 1
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSplitInfo", 0), SplitLabelPrefix + I2S(SplitAmount[pId]))
            set it = null
            return
        endif
        set total = GetItemCharges(it)
        if total < 2 then
            set SplitAmount[pId] = 1
        else
            set SplitAmount[pId] = SplitAmount[pId] - 1
            if SplitAmount[pId] < 1 then
                set SplitAmount[pId] = 1
            endif
            if SplitAmount[pId] >= total then
                set SplitAmount[pId] = total - 1
            endif
        endif
        call BlzFrameSetText(BlzGetFrameByName("TasItemBagSplitInfo", 0), SplitLabelPrefix + I2S(SplitAmount[pId]))
        set it = null
    endfunction

    private function BagPopupActionSplitPlus takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local item it = TransferItem[pId]
        local integer total
        if GetLocalPlayer() != p then
            set it = null
            return
        endif
        if it == null then
            set SplitAmount[pId] = 1
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSplitInfo", 0), SplitLabelPrefix + I2S(SplitAmount[pId]))
            set it = null
            return
        endif
        set total = GetItemCharges(it)
        if total < 2 then
            set SplitAmount[pId] = 1
        else
            set SplitAmount[pId] = SplitAmount[pId] + 1
            if SplitAmount[pId] >= total then
                set SplitAmount[pId] = total - 1
            endif
            if SplitAmount[pId] > 20 then
                set SplitAmount[pId] = 20
            endif
        endif
        call BlzFrameSetText(BlzGetFrameByName("TasItemBagSplitInfo", 0), SplitLabelPrefix + I2S(SplitAmount[pId]))
        set it = null
    endfunction

    private function BagPopupActionSplitCancel takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        call SetSellHotkeyArmed(pId, false)
        call HideBagPopupPanels(p)
        set SplitRequested[pId] = 0
        set SplitAmount[pId] = 0
        call FrameLoseFocus()
    endfunction

    // Direct native inventory and hitbox hover/click tracking.
    private function InventoryButtonAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local integer invSlot = 0
        local frameeventtype evt = BlzGetTriggerFrameEvent()

        loop
            exitwhen invSlot >= bj_MAX_INVENTORY
            if BlzGetTriggerFrame() == BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, invSlot) or BlzGetTriggerFrame() == InventoryHitbox[invSlot] then
                exitwhen true
            endif
            set invSlot = invSlot + 1
        endloop

        if invSlot >= bj_MAX_INVENTORY then
            return
        endif

        // Track currently hovered inventory slot from native buttons or per-slot hitboxes.
        if evt == FRAMEEVENT_MOUSE_ENTER then
            set InventoryHoverSlot[pId] = invSlot + 1
            return
        elseif evt == FRAMEEVENT_MOUSE_LEAVE then
            if InventoryHoverSlot[pId] == invSlot + 1 then
                set InventoryHoverSlot[pId] = 0
            endif
            return
        endif

        if SwapIndex[pId] <= 0 then
            return
        endif

        if BlzGetTriggerPlayerMouseButton() != MOUSE_BUTTON_TYPE_LEFT then
            return
        endif

        if evt == FRAMEEVENT_CONTROL_CLICK or evt == FRAMEEVENT_MOUSE_UP then
            call RequestBagInventoryInsertSync(p, invSlot)
            call FrameLoseFocus()
        endif

        return
    endfunction

    // Resolve a bag slot index from any of its related frames (button/backdrop/container)
    private function ResolveBagSlotIndex takes framehandle f returns integer
        local integer i = 1
        loop
            exitwhen i > MAX_INTERACTIVE_SLOT
            if f == BlzGetFrameByName("TasItemBagSlotButton", i) then
                return i
            endif
            if f == BlzGetFrameByName("TasItemBagSlotButtonBackdrop", i) then
                return i
            endif
            if f == BlzGetFrameByName("TasItemBagSlot", i) then
                return i
            endif
            set i = i + 1
        endloop
        return 0
    endfunction

    // Compute bag slot under the mouse using panel abs position and grid
    private function ResolveBagIndexFromMouse takes nothing returns integer
        local real mx = BlzGetTriggerPlayerMouseX()
        local real my = BlzGetTriggerPlayerMouseY()
        local framehandle slotFrame = BlzGetFrameByName("TasItemBagSlot", 1)
        local real slotW = BlzFrameGetWidth(slotFrame)
        local real slotH = BlzFrameGetHeight(slotFrame)
        local real panelW = slotW * Cols + (Cols - 1) * 0.002 + 0.02
        local real panelH = slotH * Rows + (Rows - 1) * 0.002 + 0.012
        local real panelTLX = PosX - panelW * 0.5
        local real panelTLY = PosY
        local real firstTLX = panelTLX + 0.006
        local real firstTLY = panelTLY - 0.006
        local real cellW = slotW + 0.002
        local real cellH = slotH + 0.002
        local integer col
        local integer row
        local integer idx
        // inside panel bounds?
        if mx < firstTLX or my > firstTLY then
            return 0
        endif
        if mx > (firstTLX + Cols * cellW - 0.002) or my < (firstTLY - Rows * cellH + 0.002) then
            return 0
        endif
        set col = R2I((mx - firstTLX) / cellW) + 1
        set row = R2I((firstTLY - my) / cellH) + 1
        if col < 1 or col > Cols or row < 1 or row > Rows then
            return 0
        endif
        set idx = (row - 1) * Cols + col
        return idx
    endfunction

    // True if mouse is anywhere inside the bag panel rectangle (including slot gaps/margins).
    private function IsMouseInsideBagPanel takes nothing returns boolean
        local real mx = BlzGetTriggerPlayerMouseX()
        local real my = BlzGetTriggerPlayerMouseY()
        local framehandle slotFrame = BlzGetFrameByName("TasItemBagSlot", 1)
        local real slotW = BlzFrameGetWidth(slotFrame)
        local real slotH = BlzFrameGetHeight(slotFrame)
        local real panelW = slotW * Cols + (Cols - 1) * 0.002 + 0.02
        local real panelH = slotH * Rows + (Rows - 1) * 0.002 + 0.012 + 0.020 + slotH + 0.002 + slotH
        local real panelTLX = PosX - panelW * 0.5
        local real panelTLY = PosY
        local real pad = 0.003

        if mx >= (panelTLX - pad) and mx <= (panelTLX + panelW + pad) and my <= (panelTLY + pad) and my >= (panelTLY - panelH - pad) then
            return true
        endif
        return false
    endfunction

    private function BagButtonAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(GetTriggerPlayer())
        local integer rawIndex = 0
        local integer bagIndex
        local string frameSrc
        local unit hero
        local item it
        local mousebuttontype mouseButton
        local frameeventtype evt = BlzGetTriggerFrameEvent()
        local integer targetIndex
        local string btnStr
        local string evtStr
        local string dragStr
        local integer itemCharges
        local itemtype itemType

        call Debug("BagButtonAction triggered")
        // Try to read numeric text first; if empty, resolve by frame handle
        if BlzFrameGetText(BlzGetTriggerFrame()) != "" then
            set rawIndex = S2I(BlzFrameGetText(BlzGetTriggerFrame()))
            set frameSrc = "Button(text)"
        else
            set rawIndex = ResolveBagSlotIndex(BlzGetTriggerFrame())
            // Identify which frame type matched for better diagnostics
            if BlzGetTriggerFrame() == BlzGetFrameByName("TasItemBagSlotButtonBackdrop", rawIndex) then
                set frameSrc = "Backdrop"
            elseif BlzGetTriggerFrame() == BlzGetFrameByName("TasItemBagSlot", rawIndex) then
                set frameSrc = "Slot"
            else
                set frameSrc = "Button(handle)"
            endif
        endif
        set bagIndex = rawIndex
        set hero = udg_Heroes[GetPlayerNumber(p)]
        if hero == null then
            return
        endif

        // If we're in swap mode, finalize on click OR mouse-up so empty (disabled) bag slots can be targets.
        if SwapIndex[pId] > 0 and (evt == FRAMEEVENT_CONTROL_CLICK or evt == FRAMEEVENT_MOUSE_UP) then
            if bagIndex <= 0 then
                set targetIndex = ResolveBagIndexFromMouse()
                if targetIndex > 0 then
                    set bagIndex = targetIndex
                endif
            endif
            if bagIndex <= 0 or bagIndex > MAX_INTERACTIVE_SLOT then
                set it = null
                set hero = null
                call FrameLoseFocus()
                return
            endif
            // WoW-like: clicking the source slot again cancels swap
            if SwapIndex[pId] == bagIndex then
                set SwapIndex[pId] = 0
                call SwapHighlightHide(pId)
                if GetLocalPlayer() == p then
                    call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
                    call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
                endif
            else
                call Debug("Swap finalize: " + I2S(SwapIndex[pId]) + " <-> " + I2S(bagIndex))
                if TasItemBagSwap(hero, SwapIndex[pId], bagIndex) then
                    call PlaySwapConfirmSound(p)
                    set SwapIndex[pId] = 0
                    call SuppressBagPopupUntilNextFrame(pId)
                    call SwapHighlightHide(pId)
                    if GetLocalPlayer() == p then
                        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
                        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
                    endif
                endif
            endif
        elseif evt == FRAMEEVENT_CONTROL_CLICK then
            if SuppressNextBagPopup[pId] then
                set SuppressNextBagPopup[pId] = false
                set it = null
                set hero = null
                call FrameLoseFocus()
                return
            endif
            // Normal left-click: open popup for the clicked slot (if it contains an item)
            if rawIndex <= 0 then
                set targetIndex = ResolveBagIndexFromMouse()
                if targetIndex > 0 then
                    set rawIndex = targetIndex
                    set bagIndex = rawIndex
                endif
            endif
            if rawIndex > 0 then
                set TransferIndex[pId] = bagIndex
                set TransferItem[pId] = TasItemBagGetItem(hero, bagIndex)
                call SetSellHotkeyArmed(pId, TransferItem[pId] != null and IsItemPawnable(TransferItem[pId]))
                if TransferItem[pId] != null then
                    if GetLocalPlayer() == p then
                        call UpdateSellPopupButtonText(p)
                        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), true)
                        call BlzFrameClearAllPoints(BlzGetFrameByName("TasItemBagPopUpPanel", 0))
                        call BlzFrameSetPoint(BlzGetFrameByName("TasItemBagPopUpPanel", 0), FRAMEPOINT_TOPLEFT, BlzGetFrameByName("TasItemBagSlot", rawIndex), FRAMEPOINT_TOPRIGHT, 0.004, 0)

                        // Split button only for charged items with charges > 1
                        set itemCharges = GetItemCharges(TransferItem[pId])
                        set itemType = GetItemType(TransferItem[pId])
                        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpButtonSell", 0), IsItemPawnable(TransferItem[pId]))
                        if IsStackableType(TransferItem[pId]) and itemCharges > 1 then
                            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpButtonSplit", 0), true)
                        else
                            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpButtonSplit", 0), false)
                        endif
                    endif
                else
                    call SetSellHotkeyArmed(pId, false)
                endif
            endif
        endif

        set it = null
        set hero = null
        call FrameLoseFocus()
    endfunction

    // Record last hovered slot index per player to support global right-click
    private function HoverAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local integer btnIndex
        local string frameText = BlzFrameGetText(BlzGetTriggerFrame())

        if frameText != "" then
            set btnIndex = S2I(frameText)
        else
            set btnIndex = ResolveBagSlotIndex(BlzGetTriggerFrame())
            if btnIndex <= 0 then
                set btnIndex = ResolveBagIndexFromMouse()
            endif
        endif
        if btnIndex > 0 then
            // call Debug("HoverAction triggered")
            set LastHoveredIndex[pId] = btnIndex
            set PanelHover[pId] = true
            // call Debug("Hover: player " + I2S(pId) + " hovered slot " + I2S(LastHoveredIndex[pId]))
            if SwapIndex[pId] > 0 then
                call SwapHoverShowOnSlot(pId, btnIndex)
            elseif DragActive[pId] then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", btnIndex), true)
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", btnIndex), "●")
            endif
        endif
    endfunction

    // Clear hover indicator when leaving a slot
    private function HoverLeaveAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local integer btnIndex
        local integer stillHovering
        local string frameText = BlzFrameGetText(BlzGetTriggerFrame())

        if frameText != "" then
            set btnIndex = S2I(frameText)
        else
            set btnIndex = ResolveBagSlotIndex(BlzGetTriggerFrame())
            if btnIndex <= 0 then
                set btnIndex = ResolveBagIndexFromMouse()
            endif
        endif
        if btnIndex <= 0 then
            return
        endif
        // call Debug("HoverLeaveAction triggered")
        // Clear overlay text if leaving the button; do not flip PanelHover here
        if SwapIndex[pId] > 0 then
            call SwapHoverHide(pId)
        elseif DragActive[pId] then
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", btnIndex), "")
        endif
        // Ignore synthetic LEAVE events when mouse is still over a valid bag slot.
        set stillHovering = ResolveBagIndexFromMouse()
        if stillHovering > 0 then
            set LastHoveredIndex[pId] = stillHovering
            set PanelHover[pId] = true
            if SwapIndex[pId] > 0 then
                call SwapHoverShowOnSlot(pId, stillHovering)
            endif
            return
        endif
        if IsMouseInsideBagPanel() then
            set PanelHover[pId] = true
            return
        endif
        set PanelHover[pId] = false
        // Only clear LastHoveredIndex if the panel itself is not hovered
        if not PanelHover[pId] then
            set LastHoveredIndex[pId] = 0
        endif
    endfunction

    // Hover dispatcher: this trigger is registered for both ENTER and LEAVE,
    // so we must branch on the actual frame event.
    private function SlotHoverEventAction takes nothing returns nothing
        local frameeventtype evt = BlzGetTriggerFrameEvent()
        if evt == FRAMEEVENT_MOUSE_ENTER then
            call HoverAction()
        elseif evt == FRAMEEVENT_MOUSE_LEAVE then
            call HoverLeaveAction()
        endif
    endfunction

    // Panel hover enter: mark inside panel
    private function BagPanelEnterAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        set PanelHover[pId] = true
        // call Debug("BagPanelEnterAction ENTER")
        // call Debug("PanelHover ENTER: player " + I2S(pId) + ", PanelHover=true")
    endfunction

    // Panel hover leave: mark outside panel
    private function BagPanelLeaveAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        // In WC3 UI, the parent frame can receive a LEAVE as soon as the mouse is over a child.
        // If the mouse is still inside the panel grid bounds, ignore this LEAVE.
        if IsMouseInsideBagPanel() then
            set PanelHover[pId] = true
            return
        endif
        set PanelHover[pId] = false
        set LastHoveredIndex[pId] = 0
        call SwapHoverHide(pId)
        // call Debug("BagPanelLeaveAction LEAVE")
    endfunction

    // Panel hover dispatcher: this trigger is registered for both ENTER and LEAVE,
    // so we must branch on the actual frame event.
    private function PanelHoverEventAction takes nothing returns nothing
        local frameeventtype evt = BlzGetTriggerFrameEvent()
        if evt == FRAMEEVENT_MOUSE_ENTER then
            call BagPanelEnterAction()
        elseif evt == FRAMEEVENT_MOUSE_LEAVE then
            call BagPanelLeaveAction()
        endif
    endfunction

    private function InventoryPanelEnterAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        set InventoryPanelHover[pId] = true
    endfunction

    private function InventoryPanelLeaveAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        set InventoryPanelHover[pId] = false
    endfunction

    private function InventoryPanelHoverEventAction takes nothing returns nothing
        local frameeventtype evt = BlzGetTriggerFrameEvent()
        if evt == FRAMEEVENT_MOUSE_ENTER then
            call InventoryPanelEnterAction()
        elseif evt == FRAMEEVENT_MOUSE_LEAVE then
            call InventoryPanelLeaveAction()
        elseif evt == FRAMEEVENT_CONTROL_CLICK then
            call InventoryPanelEnterAction()
            if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
                call RequestBagCloseSync(GetTriggerPlayer())
                call FrameLoseFocus()
            endif
        endif
    endfunction

    // Global mouse up handler: right-click = select/deposit, left-click = bag/inventory finalize or world-drop when armed
    private function GlobalMouseUpAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local mousebuttontype btn = BlzGetTriggerPlayerMouseButton()
        local integer targetIndex = LastHoveredIndex[pId]
        local integer invIndex = -1
        local integer rawIdx
        local integer bagIndex
        local item bi
        local boolean didSomething = false
        local unit clickShop
        local string panelStr

        if not BagEnabledForPlayer(p) then
            return
        endif

        // Ignore any clicks when bag panel is not open
        if not BagPanelOpen[pId] then
            return
        endif

        if IsMouseInsideBagPanel() then
            set PanelHover[pId] = true
        endif

        // Only trust direct inventory frame or per-slot hitbox hover in shared mouse logic.
        // HoverOriginButton is tooltip-polled/async and must not route shared state.
        if InventoryHoverSlot[pId] > 0 and InventoryHoverSlot[pId] <= bj_MAX_INVENTORY then
            set invIndex = InventoryHoverSlot[pId] - 1
        endif

        if PanelHover[pId] then
            set panelStr = "true"
        else
            set panelStr = "false"
        endif
        // call Debug("Global MOUSE_UP: invIndex=" + I2S(invIndex) + ", LastHoveredIndex=" + I2S(LastHoveredIndex[pId]) + ", PanelHover=" + panelStr)

        if btn == MOUSE_BUTTON_TYPE_RIGHT then
            // WoW-like: right-click cancels an armed swap without side-effects
            if SwapIndex[pId] > 0 then
                set SwapIndex[pId] = 0
                call SetSellHotkeyArmed(pId, false)
                call SwapHighlightHide(pId)
                call HideBagPopupPanels(p)
                return
            endif
            // Always hide the popup on any right-click while the bag UI is open
            call SetSellHotkeyArmed(pId, false)
            call HideBagPopupPanels(p)
            // Right-click over native inventory: local hover detects, sync handler performs the close.
            if InventoryPanelHover[pId] then
                call RequestBagCloseSync(p)
                set DragOriginType[pId] = 0
                set DragOriginIndex[pId] = 0
                set DragActive[pId] = false
                return
            else
                if PanelHover[pId] then
                    set rawIdx = ResolveBagIndexFromMouse()
                    if rawIdx <= 0 and targetIndex > 0 then
                        set bagIndex = targetIndex
                        set rawIdx = bagIndex
                    else
                        set bagIndex = rawIdx
                    endif
                    if rawIdx > 0 and rawIdx <= MAX_INTERACTIVE_SLOT then
                        set bi = udg_P_Items[SlotToArrayIndex(pId, bagIndex)]
                        if bi != null then
                            call Debug("Select arm (global right-click): rawIdx=" + I2S(rawIdx) + ", bagIndex=" + I2S(bagIndex))
                            set SwapIndex[pId] = bagIndex
                            call SwapHighlightShowOnSlot(pId, SwapIndex[pId])
                            call PlaySwapSelectSound(p)
                            if GetLocalPlayer() == p then
                                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
                                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
                            endif
                            set didSomething = true
                        else
                            call Debug("Select suppressed: empty at bagIndex=" + I2S(bagIndex))
                        endif
                    endif
                endif
            endif
            // If the click was not on inventory or bag, do nothing (let it be a move order, etc.)
            if not didSomething then
                return
            endif
            // Reset drag only when we actually handled the click
            set DragOriginType[pId] = 0
            set DragOriginIndex[pId] = 0
            set DragActive[pId] = false
            call FrameLoseFocus()
        elseif btn == MOUSE_BUTTON_TYPE_LEFT then
            // Local inventory detection only sends intent; the synced handler performs the swap.
            if SwapIndex[pId] > 0 and invIndex >= 0 and invIndex < bj_MAX_INVENTORY then
                call RequestBagInventoryInsertSync(p, invIndex)
                return
            endif

            // If not over inventory, allow bag-to-bag finalize.
            if SwapIndex[pId] > 0 and PanelHover[pId] then
                set rawIdx = ResolveBagIndexFromMouse()
                if rawIdx <= 0 and targetIndex > 0 then
                    set bagIndex = targetIndex
                    set rawIdx = bagIndex
                else
                    set bagIndex = rawIdx
                endif
                if rawIdx > 0 and rawIdx <= MAX_INTERACTIVE_SLOT then
                    if SwapIndex[pId] == bagIndex then
                        set SwapIndex[pId] = 0
                        call SwapHighlightHide(pId)
                        if GetLocalPlayer() == p then
                            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
                            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
                        endif
                        call FrameLoseFocus()
                        return
                    elseif TasItemBagSwap(udg_Heroes[GetPlayerNumber(p)], SwapIndex[pId], bagIndex) then
                        call PlaySwapConfirmSound(p)
                        set SwapIndex[pId] = 0
                        call SuppressBagPopupUntilNextFrame(pId)
                        call SwapHighlightHide(pId)
                        if GetLocalPlayer() == p then
                            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
                            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
                        endif
                        set DragOriginType[pId] = 0
                        set DragOriginIndex[pId] = 0
                        set DragActive[pId] = false
                        call FrameLoseFocus()
                        return
                    endif
                endif
            endif

            if SwapIndex[pId] > 0 then
                // Armed SELECT + left-click outside bag and inventory.
                if (not PanelHover[pId]) then
                    // Check if the player clicked on a vendor.
                    set clickShop = FindVendorNearClick(p, BlzGetTriggerPlayerMouseX(), BlzGetTriggerPlayerMouseY())
                    if clickShop != null then
                        // Vendor near click — only sell if hero is in range, otherwise block.
                        if IsHeroInSellRange(p, clickShop) then
                            if SellBagIndexToShop(p, SwapIndex[pId], clickShop, false) then
                                set SwapIndex[pId] = 0
                                call SwapHighlightHide(pId)
                                if GetLocalPlayer() == p then
                                    call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
                                    call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
                                endif
                                set DragOriginType[pId] = 0
                                set DragOriginIndex[pId] = 0
                                set DragActive[pId] = false
                                call FrameLoseFocus()
                            endif
                        else
                            call NeatErrorMessage("Move closer to the shop.", p)
                        endif
                        set clickShop = null
                    else
                        // No vendor — world drop at click point.
                        call RequestBagDropSync(p, SwapIndex[pId], BlzGetTriggerPlayerMouseX(), BlzGetTriggerPlayerMouseY())
                    endif
                endif
            endif
        endif
    endfunction

    private function CloseButtonAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        set SwapIndex[pId] = 0
        call SetSellHotkeyArmed(pId, false)
        call SwapHighlightHide(pId)
        set TransferIndex[pId] = 0
        set TransferItem[pId] = null
        call HideBagPopupPanels(p)
        call SetBagPanelOpen(p, false)
        call FrameLoseFocus()
        set p = null
    endfunction

    function TasItemBagToggleForPlayer takes player p, boolean forceClose returns nothing
        local integer pId = 0
        if p == null then
            return
        endif
        set pId = GetPlayerId(p)
        if not BagEnabledForPlayer(p) then
            call SetBagPanelOpen(p, false)
            if GetLocalPlayer() == p then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlot", 0), false)
            endif
            return
        endif

        call SetSellHotkeyArmed(pId, false)
        call RenderBagFramesForPlayer(p)
        if forceClose then
            call SetBagPanelOpen(p, false)
        else
            call SetBagPanelOpen(p, not BagPanelOpen[pId])
        endif
        call HideBagPopupPanels(p)
        call RenderBagFramesForPlayer(p)
        set SwapIndex[pId] = 0
        call SwapHighlightHide(pId)
        call FrameLoseFocus()
    endfunction

    function TasItemBagIsOpenForPlayer takes player p returns boolean
        if p == null then
            return false
        endif
        return BagEnabledForPlayer(p) and BagPanelOpen[GetPlayerId(p)]
    endfunction

    function TasItemBagOpenForPlayer takes player p returns nothing
        local integer pId = 0
        if p == null then
            return
        endif
        if not BagEnabledForPlayer(p) then
            return
        endif

        set pId = GetPlayerId(p)
        if BagPanelOpen[pId] then
            return
        endif

        set SwapIndex[pId] = 0
        call SwapHighlightHide(pId)
        set TransferIndex[pId] = 0
        set TransferItem[pId] = null
        call SetSellHotkeyArmed(pId, false)
        call RenderBagFramesForPlayer(p)
        call SetBagPanelOpen(p, true)
        call HideBagPopupPanels(p)
        call RenderBagFramesForPlayer(p)
        call FrameLoseFocus()
    endfunction

    // Toggle the bag panel on OSKEY_X press
    // private function XKeyToggleAction takes nothing returns nothing
    //     call TasItemBagToggleForPlayer(GetTriggerPlayer(), false)
    // endfunction

    private function ShowButtonAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local integer s
        if not BagEnabledForPlayer(p) then
            set p = null
            return
        endif
        set SwapIndex[pId] = 0
        call SwapHighlightHide(pId)
        set TransferIndex[pId] = 0
        set TransferItem[pId] = null
        call SetSellHotkeyArmed(pId, false)
        call RenderBagFramesForPlayer(p)
        call SetBagPanelOpen(p, not BagPanelOpen[pId])
        call HideBagPopupPanels(p)
        call RenderBagFramesForPlayer(p)
        call FrameLoseFocus()
        set p = null
    endfunction

    private function SelectAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        local player p = GetTriggerPlayer()
        local unit selected = GetTriggerUnit()
        local unit hero = udg_Heroes[GetPlayerNumber(p)]

        if not BagEnabledForPlayer(p) then
            set selected = null
            set hero = null
            set p = null
            return
        endif

        if IgnoreNextSelection[pId] then
            set IgnoreNextSelection[pId] = false
            return
        endif

        // Armed SELECT + selecting a vendor sells immediately to that selected shop.
        if SwapIndex[pId] > 0 and IsVendorUnit(selected) then
            // Shop-select sell should always override any queued world-drop command.
            call ClearWorldDropQueue(pId)
            if IsHeroInSellRange(p, selected) then
                call Debug("Shop-select immediate sell: player=" + I2S(pId) + ", bagIndex=" + I2S(SwapIndex[pId]) + ", shop=" + GetUnitName(selected))
                if SellBagIndexToShop(p, SwapIndex[pId], selected, false) then
                    set SwapIndex[pId] = 0
                    call SwapHighlightHide(pId)
                    if GetLocalPlayer() == p then
                        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
                        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
                    endif
                    set DragOriginType[pId] = 0
                    set DragOriginIndex[pId] = 0
                    set DragActive[pId] = false
                    if hero != null then
                        set IgnoreNextSelection[pId] = true
                        call SelectUnitForPlayerSingle(hero, p)
                    endif
                endif
            else
                call NeatErrorMessage("Move closer to the shop.", p)
            endif
            set selected = null
            set hero = null
            set p = null
            return
        endif

        set selected = null
        set hero = null
        set p = null
    endfunction

    private function ESCAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        if not BagEnabledForPlayer(p) then
            set p = null
            return
        endif
        if QuickUseActive[pId] then
            call RequestQuickUseCancelSync(p)
            set p = null
            return
        endif
        // WoW-like: ESC cancels swap first, then closes UI on subsequent ESC
        call SetSellHotkeyArmed(pId, false)
        call HideBagPopupPanels(p)
        if SwapIndex[pId] > 0 then
            set SwapIndex[pId] = 0
            call SwapHighlightHide(pId)
            return
        endif
        call SetBagPanelOpen(p, false)
        set p = null
    endfunction

    // Process delayed item gains: move picked-up items into the bag after a short delay
    private function ItemGainTimerAction takes nothing returns nothing
        local unit u
        local item it
        local integer pId
        local integer playerNum
        local integer currentPage
        local integer intendedPage
        loop
            exitwhen ItemGainTimerCount <= 0
            set u = ItemGainTimerUnit[ItemGainTimerCount]
            set it = ItemGainTimerItem[ItemGainTimerCount]
            set pId = GetPlayerId(GetOwningPlayer(u))

            if not BagEnabledForPlayer(GetOwningPlayer(u)) then
                set u = null
                set it = null
                set ItemGainTimerCount = ItemGainTimerCount - 1
            else

                // Check whether current page differs from the player's intended page
                // BEFORE processing the item, so we know this was a relief-switch pickup.
                set playerNum = GetPlayerHeroNumber(GetOwningPlayer(u))
                set currentPage = udg_Bag_Page[playerNum]
                set intendedPage = MPInventoryGetPlayerIntendedPage(GetOwningPlayer(u))

                if UnitHasItem(u, it) then
                    if intendedPage > 0 and currentPage != intendedPage then
                        // Relief-switch flow: skip live-inventory merge so charges
                        // don't leak into the relief page.  TasItemBagAddItem has its
                        // own bag-storage merge logic.
                        call TasItemBagAddItem(u, it, true)
                    elseif not MergePickedItemIntoPagedStacks(u, it) then
                        if UnitHasItem(u, it) then
                            call TasItemBagAddItem(u, it, true)
                        endif
                    endif
                endif
                call RestorePlayerIntendedPage(u)
                set u = null
                set it = null
                set ItemGainTimerCount = ItemGainTimerCount - 1
            endif
        endloop
    endfunction

    private function ItemGainAction takes nothing returns nothing
        local unit triggerUnit = GetTriggerUnit()
        local player owner
        local integer pId
        local item queuedItem = GetManipulatedItem()
        local item intentItem
        set owner = GetOwningPlayer(triggerUnit)
        if not BagEnabledForPlayer(owner) then
            set triggerUnit = null
            set queuedItem = null
            set owner = null
            return
        endif
        set pId = GetPlayerId(owner)
        set intentItem = PickupIntentItem[pId]

        // When pickup intent is active, prefer the intent target item handle.
        // This keeps delayed processing aligned with auto-page return logic.
        if PickupIntentActive[pId] and intentItem != null then
            if queuedItem == null or GetItemTypeId(intentItem) == GetItemTypeId(queuedItem) then
                set queuedItem = intentItem
            endif
        endif

        // Prefer the recent SMART target handle only when pickup intent is not active.
        // During auto-page relief, intent target must stay authoritative.
        if (not PickupIntentActive[pId]) and LastSmartPickupTarget[pId] != null and LastSmartPickupTimeLeft[pId] > 0.0 then
            if queuedItem != null and GetItemTypeId(LastSmartPickupTarget[pId]) == GetItemTypeId(queuedItem) then
                set queuedItem = LastSmartPickupTarget[pId]
            endif
            set LastSmartPickupTarget[pId] = null
            set LastSmartPickupTimeLeft[pId] = 0.0
        endif

        // Resolve pickup intent using the same (possibly disambiguated) handle
        // that will continue through the delayed bag pipeline.
        // Skip during page-switch loads (dontDepositIntoBag) — those UnitAddItem
        // calls are not real pickups and must not consume / clear the active intent.
        if not udg_dontDepositIntoBag then
            call ResolvePickupIntentOnGain(triggerUnit, queuedItem)
        endif

        if udg_dontDepositIntoBag then
            // Page-switch re-equip — not a real pickup. Do NOT restore intended page
            // here; the page switch is still in progress.
            set udg_dontDepositIntoBag = false
            set triggerUnit = null
            set queuedItem = null
            set owner = null
            return
        endif

        // Do not move Powerups that can be used into the bag
        if IsItemPowerup(GetManipulatedItem()) and TasItemBagUnitCanUseItems(GetTriggerUnit()) then 
            call RestorePlayerIntendedPage(triggerUnit)
            set triggerUnit = null
            set queuedItem = null
            set owner = null
            return
        endif
        
        // dont move it instantly, delay it with a 0s timer, this stops item pickup orders onto the same item in a row and allows the user to do some stuff to pickedup items
        // does not prevent move ground pick up in rotation
        set ItemGainTimerCount = ItemGainTimerCount + 1
        set ItemGainTimerUnit[ItemGainTimerCount] = triggerUnit
        set ItemGainTimerItem[ItemGainTimerCount] = queuedItem
        call TimerStart(ItemGainTimer, 0, false, function ItemGainTimerAction)

        set triggerUnit = null
        set queuedItem = null
        set intentItem = null
        set owner = null

    endfunction
     
    private function CreateTextTooltip takes framehandle frame, string wantedframeName, integer wantedCreateContext, string text returns framehandle
        // this FRAME is important when the Box is outside of 4:3 it can be limited to 4:3.
        local framehandle toolTipParent = BlzCreateFrameByType("FRAME", "", BlzGetFrameByName("TasItemBagTooltipPanel", 0), "", 0)
        local framehandle toolTipBox = BlzCreateFrame("TasToolTipBox", toolTipParent, 0, 0)
        local framehandle toolTip = BlzCreateFrameByType("TEXT", wantedframeName, toolTipBox, "TasTooltipText", wantedCreateContext)
        local framehandle sellIcon = BlzCreateFrameByType("BACKDROP", "TasItemBagTooltipSellIcon", toolTipBox, "", wantedCreateContext)
        local framehandle sellText = BlzCreateFrameByType("TEXT", "TasItemBagTooltipSellText", toolTipBox, "TasTooltipText", wantedCreateContext)

        if TooltipFixedPosition then 
            call BlzFrameSetAbsPoint(toolTip, TooltipFixedPositionPoint, TooltipFixedPositionX, TooltipFixedPositionY)
        else
            call BlzFrameSetPoint(toolTip, FRAMEPOINT_TOP, frame, FRAMEPOINT_BOTTOM, 0, - 0.008)
        endif

        call BlzFrameSetPoint(toolTipBox, FRAMEPOINT_TOPLEFT, toolTip, FRAMEPOINT_TOPLEFT, - 0.008, 0.008)
        call BlzFrameSetPoint(toolTipBox, FRAMEPOINT_BOTTOMRIGHT, toolTip, FRAMEPOINT_BOTTOMRIGHT, 0.008, - 0.008)
        call BlzFrameSetText(toolTip, text)
        call BlzFrameSetTexture(sellIcon, TOOLTIP_SELL_ICON_TEXTURE, 0, true)
        call BlzFrameSetSize(sellIcon, TOOLTIP_SELL_ICON_SIZE, TOOLTIP_SELL_ICON_SIZE)
        call BlzFrameSetPoint(sellIcon, FRAMEPOINT_TOPLEFT, toolTip, FRAMEPOINT_TOPLEFT, 0.0015, -0.0145)
        call BlzFrameSetPoint(sellText, FRAMEPOINT_LEFT, sellIcon, FRAMEPOINT_RIGHT, 0.0025, 0.0)
        call BlzFrameSetSize(sellText, TooltipWidth - 0.02, 0.012)
        call BlzFrameSetTextAlignment(sellText, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
        call BlzFrameSetText(sellText, "")
        call BlzFrameSetVisible(sellIcon, false)
        call BlzFrameSetVisible(sellText, false)
        call BlzFrameSetTooltip(frame, toolTipParent)
        call BlzFrameSetSize(toolTip, TooltipWidth, 0)
        // Important: tooltip frames must not capture mouse, otherwise hover can flicker.
        call BlzFrameSetEnable(toolTipParent, false)
        call BlzFrameSetEnable(toolTipBox, false)
        call BlzFrameSetEnable(toolTip, false)
        call BlzFrameSetEnable(sellIcon, false)
        call BlzFrameSetEnable(sellText, false)
        set sellIcon = null
        set sellText = null
        return toolTip
    endfunction

    private function InitFrames takes nothing returns nothing
        local boolean loaded = BlzLoadTOCFile("war3mapImported/TasItemBag.toc")
        local framehandle panel
        local framehandle frame
        local framehandle frame2
        local framehandle frame3
        local framehandle frame4
        local integer count = 0
        local integer buttonIndex = 0
        local boolean backup
        local integer invIndex
        local framehandle invButton
        local framehandle depButton

        set panel = BlzCreateFrameByType("BUTTON", "TasItemBagPanel", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        call BlzFrameSetLevel(panel, 3)
        call BlzFrameSetAbsPoint(panel, Pos, PosX, PosY)
        call BlzFrameSetAllPoints(BlzCreateFrame("TasItemBagBox", panel, 0, 0), panel)

        // Per-slot hitboxes sit above the broad hover overlay while insert is armed.
        set invIndex = 0
        loop
            exitwhen invIndex >= bj_MAX_INVENTORY
            set InventoryHitbox[invIndex] = BlzCreateFrameByType("BUTTON", "TasItemBagInventoryHitbox", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", invIndex)
            call BlzFrameClearAllPoints(InventoryHitbox[invIndex])
            call BlzFrameSetPoint(InventoryHitbox[invIndex], FRAMEPOINT_TOPLEFT, BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, invIndex), FRAMEPOINT_TOPLEFT, -INVENTORY_HITBOX_PAD, INVENTORY_HITBOX_PAD)
            call BlzFrameSetPoint(InventoryHitbox[invIndex], FRAMEPOINT_BOTTOMRIGHT, BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, invIndex), FRAMEPOINT_BOTTOMRIGHT, INVENTORY_HITBOX_PAD, -INVENTORY_HITBOX_PAD)
            call BlzFrameSetEnable(InventoryHitbox[invIndex], false)
            call BlzFrameSetAlpha(InventoryHitbox[invIndex], 0)
            call BlzFrameSetLevel(InventoryHitbox[invIndex], 3)
            call BlzTriggerRegisterFrameEvent(TriggerUIInventoryButton, InventoryHitbox[invIndex], FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(TriggerUIInventoryButton, InventoryHitbox[invIndex], FRAMEEVENT_MOUSE_LEAVE)
            call BlzTriggerRegisterFrameEvent(TriggerUIInventoryButton, InventoryHitbox[invIndex], FRAMEEVENT_CONTROL_CLICK)
            call BlzTriggerRegisterFrameEvent(TriggerUIInventoryButton, InventoryHitbox[invIndex], FRAMEEVENT_MOUSE_UP)
            set invIndex = invIndex + 1
        endloop

        set InventoryPanelHoverFrame = BlzCreateFrameByType("BUTTON", "TasItemBagInventoryPanelHover", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        call BlzFrameClearAllPoints(InventoryPanelHoverFrame)
        call BlzFrameSetPoint(InventoryPanelHoverFrame, FRAMEPOINT_TOPLEFT, BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, 0), FRAMEPOINT_TOPLEFT, -INVENTORY_PANEL_HOVER_PAD, INVENTORY_PANEL_HOVER_PAD)
        call BlzFrameSetPoint(InventoryPanelHoverFrame, FRAMEPOINT_BOTTOMRIGHT, BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, bj_MAX_INVENTORY - 1), FRAMEPOINT_BOTTOMRIGHT, INVENTORY_PANEL_HOVER_PAD, -INVENTORY_PANEL_HOVER_PAD)
        call BlzFrameSetEnable(InventoryPanelHoverFrame, false)
        call BlzFrameSetVisible(InventoryPanelHoverFrame, false)
        call BlzFrameSetAlpha(InventoryPanelHoverFrame, 0)
        call BlzFrameSetLevel(InventoryPanelHoverFrame, 2)
        call BlzTriggerRegisterFrameEvent(TriggerUIInventoryPanelHover, InventoryPanelHoverFrame, FRAMEEVENT_MOUSE_ENTER)
        call BlzTriggerRegisterFrameEvent(TriggerUIInventoryPanelHover, InventoryPanelHoverFrame, FRAMEEVENT_MOUSE_LEAVE)
        call BlzTriggerRegisterFrameEvent(TriggerUIInventoryPanelHover, InventoryPanelHoverFrame, FRAMEEVENT_CONTROL_CLICK)

        call BlzCreateFrameByType("BUTTON", "TasItemBagTooltipPanel", panel, "", 0)

        // Swap highlight (autocast border) - per player context, positioned on demand
        set invIndex = 0
        loop
            exitwhen invIndex >= bj_MAX_PLAYERS
            set SwapHighlight[invIndex] = BlzCreateFrameByType("SPRITE", "TasItemBagSwapHighlight", panel, "", invIndex)
            call BlzFrameSetModel(SwapHighlight[invIndex], "UI\\Feedback\\Autocast\\UI-ModalButtonOn.mdl", 0)
            call BlzFrameSetScale(SwapHighlight[invIndex], 0.70)
            call BlzFrameSetVisible(SwapHighlight[invIndex], false)
            call BlzFrameSetLevel(SwapHighlight[invIndex], 10)
            set invIndex = invIndex + 1
        endloop
        // Custom Bag
        set count = 0
        set buttonIndex = 1
        loop
            exitwhen buttonIndex > Rows * Cols
        
            set frame = BlzCreateFrame("TasItemBagSlot", panel, 0, buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButton", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonBackdrop", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonOverLay", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonOverLayText", buttonIndex)
            // Keep visual child frames non-interactive to avoid tooltip hover flicker.
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", buttonIndex), false)
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", buttonIndex), false)
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", buttonIndex), false)
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonOverLay", buttonIndex), false)
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", buttonIndex), false)
            call CreateTextTooltip(BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), "TasItemBagSlotButtonTooltip", buttonIndex, "")
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_CONTROL_CLICK)
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_MOUSE_UP)
            // Also register mouse events on backdrop frames and the slot container to capture routed events
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlotButtonBackdrop", buttonIndex), FRAMEEVENT_MOUSE_UP)
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlot", buttonIndex), FRAMEEVENT_MOUSE_UP)
            // Track hover to know which slot is under the cursor for global mouse
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_MOUSE_LEAVE)
            // Also track hover on backdrop and slot container to ensure PanelHover/LastHoveredIndex
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlotButtonBackdrop", buttonIndex), FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlotButtonBackdrop", buttonIndex), FRAMEEVENT_MOUSE_LEAVE)
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlot", buttonIndex), FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlot", buttonIndex), FRAMEEVENT_MOUSE_LEAVE)
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), I2S(buttonIndex))
            
            set count = count + 1
            if count > Cols then
                call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, BlzGetFrameByName("TasItemBagSlot", buttonIndex - Cols), FRAMEPOINT_BOTTOMLEFT, 0, - 0.002)
                set count = 1
            elseif buttonIndex > 1 then
                call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, BlzGetFrameByName("TasItemBagSlot", buttonIndex - 1), FRAMEPOINT_TOPRIGHT, 0.002, 0)
            endif
            set buttonIndex = buttonIndex + 1
        endloop
        if GetHandleId(frame) == 0 then
            call BJDebugMsg("Error - Creating TasItemBagSlot")
        endif
        // Extra height for page-display separator + two rows of page items
        call BlzFrameSetSize(panel, BlzFrameGetWidth(frame) * Cols + (Cols - 1) * 0.002 + 0.02, BlzFrameGetHeight(frame) * Rows + (Rows - 1) * 0.002 + 0.012 + 0.020 + BlzFrameGetHeight(frame) + 0.002 + BlzFrameGetHeight(frame))
        call BlzFrameSetPoint(BlzGetFrameByName("TasItemBagSlot", 1), FRAMEPOINT_TOPLEFT, panel, FRAMEPOINT_TOPLEFT, 0.006, - 0.006)

        // Page display separator label
        set frame2 = BlzCreateFrameByType("TEXT", "TasItemBagPageLabel", panel, "", 0)
        call BlzFrameSetPoint(frame2, FRAMEPOINT_TOPLEFT, BlzGetFrameByName("TasItemBagSlot", PITEMS_EXTRA_SLOTS - Cols + 1), FRAMEPOINT_BOTTOMLEFT, 0.0, -0.006)
        call BlzFrameSetText(frame2, "|cffffcc00Pages|r")

        // 12 interactive slots showing both inventory pages (6 per row)
        set buttonIndex = PAGE_DISPLAY_START
        loop
            exitwhen buttonIndex > MAX_INTERACTIVE_SLOT
            set frame3 = BlzCreateFrame("TasItemBagSlot", panel, 0, buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButton", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonBackdrop", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonOverLay", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonOverLayText", buttonIndex)
            // Keep visual child frames non-interactive to avoid tooltip hover flicker.
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", buttonIndex), false)
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", buttonIndex), false)
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", buttonIndex), false)
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonOverLay", buttonIndex), false)
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", buttonIndex), false)
            call CreateTextTooltip(BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), "TasItemBagSlotButtonTooltip", buttonIndex, "")
            // Register click events (same as regular bag slots)
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_CONTROL_CLICK)
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_MOUSE_UP)
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlotButtonBackdrop", buttonIndex), FRAMEEVENT_MOUSE_UP)
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlot", buttonIndex), FRAMEEVENT_MOUSE_UP)
            // Register hover events
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_MOUSE_LEAVE)
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlotButtonBackdrop", buttonIndex), FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlotButtonBackdrop", buttonIndex), FRAMEEVENT_MOUSE_LEAVE)
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlot", buttonIndex), FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlot", buttonIndex), FRAMEEVENT_MOUSE_LEAVE)
            // Set button text to index for event resolution
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), I2S(buttonIndex))
            // Layout: first slot of each page row anchored differently
            if buttonIndex == PAGE1_DISPLAY_START then
                call BlzFrameSetPoint(frame3, FRAMEPOINT_TOPLEFT, frame2, FRAMEPOINT_BOTTOMLEFT, 0.0, -0.004)
            elseif buttonIndex == PAGE2_DISPLAY_START then
                call BlzFrameSetPoint(frame3, FRAMEPOINT_TOPLEFT, BlzGetFrameByName("TasItemBagSlot", PAGE1_DISPLAY_START), FRAMEPOINT_BOTTOMLEFT, 0, -0.002)
            else
                call BlzFrameSetPoint(frame3, FRAMEPOINT_TOPLEFT, BlzGetFrameByName("TasItemBagSlot", buttonIndex - 1), FRAMEPOINT_TOPRIGHT, 0.002, 0)
            endif
            set buttonIndex = buttonIndex + 1
        endloop

        // Page number indicators to the right of each row
        set frame2 = BlzCreateFrameByType("TEXT", "TasItemBagPage1Indicator", panel, "", 0)
        call BlzFrameSetPoint(frame2, FRAMEPOINT_LEFT, BlzGetFrameByName("TasItemBagSlot", PAGE1_DISPLAY_START + 5), FRAMEPOINT_RIGHT, 0.001, 0)
        call BlzFrameSetText(frame2, "|cffffcc001|r")
        set frame2 = BlzCreateFrameByType("TEXT", "TasItemBagPage2Indicator", panel, "", 0)
        call BlzFrameSetPoint(frame2, FRAMEPOINT_LEFT, BlzGetFrameByName("TasItemBagSlot", PAGE2_DISPLAY_START + 5), FRAMEPOINT_RIGHT, 0.001, 0)
        call BlzFrameSetText(frame2, "|cffffcc002|r")

        // show Buttons
        set frame = BlzCreateFrame("TasItemBagSlot", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)
        call BlzFrameSetAbsPoint(frame, ShowButtonPos, ShowButtonPosX, ShowButtonPosY)
        call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", 0), ShowButtonTexture, 0, false)
        call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", 0), ShowButtonTextureDisabled, 0, false)
        call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", 0), ShowButtonTexture, 0, false)
        call BlzGetFrameByName("TasItemBagSlotButtonOverLay", 0)
        call BlzGetFrameByName("TasItemBagSlotButtonOverLayText", 0)
        call BlzTriggerRegisterFrameEvent(TriggerUIOpen, BlzGetFrameByName("TasItemBagSlotButton", 0), FRAMEEVENT_CONTROL_CLICK)
        call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButton", 0), true)

        set frame2 = BlzCreateFrameByType("TEXT", "TasItemBagQuickUseLabel", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        call BlzFrameSetPoint(frame2, FRAMEPOINT_BOTTOMLEFT, frame, FRAMEPOINT_TOPLEFT, -(BlzFrameGetWidth(frame) * QUICK_USE_BUTTON_COUNT), 0.002)
        call BlzFrameSetText(frame2, "") //"|cffffcc00Other Page|r")

        set buttonIndex = 1
        loop
            exitwhen buttonIndex > QUICK_USE_BUTTON_COUNT

            set frame3 = BlzCreateFrame("TasItemBagSlot", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, QuickUseContext(buttonIndex))
            call BlzGetFrameByName("TasItemBagSlotButton", QuickUseContext(buttonIndex))
            call BlzGetFrameByName("TasItemBagSlotButtonBackdrop", QuickUseContext(buttonIndex))
            call BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", QuickUseContext(buttonIndex))
            call BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", QuickUseContext(buttonIndex))
            call BlzGetFrameByName("TasItemBagSlotButtonOverLay", QuickUseContext(buttonIndex))
            call BlzGetFrameByName("TasItemBagSlotButtonOverLayText", QuickUseContext(buttonIndex))
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", QuickUseContext(buttonIndex)), false)
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", QuickUseContext(buttonIndex)), false)
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", QuickUseContext(buttonIndex)), false)
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonOverLay", QuickUseContext(buttonIndex)), false)
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", QuickUseContext(buttonIndex)), false)
            set frame4 = BlzCreateFrameByType("TEXT", "TasItemBagQuickUseHotkeyText", frame3, "", QuickUseContext(buttonIndex))
            call BlzFrameSetSize(frame4, BlzFrameGetWidth(frame3) - 0.002, 0.009)
            call BlzFrameSetPoint(frame4, FRAMEPOINT_TOPRIGHT, frame3, FRAMEPOINT_TOPRIGHT, -0.0050, -0.0045)
            call BlzFrameSetTextAlignment(frame4, TEXT_JUSTIFY_RIGHT, TEXT_JUSTIFY_TOP)
            call BlzFrameSetScale(frame4, 0.70)
            call CreateTextTooltip(BlzGetFrameByName("TasItemBagSlotButton", QuickUseContext(buttonIndex)), "TasItemBagSlotButtonTooltip", QuickUseContext(buttonIndex), "")
            call BlzTriggerRegisterFrameEvent(TriggerUIQuickUse, BlzGetFrameByName("TasItemBagSlotButton", QuickUseContext(buttonIndex)), FRAMEEVENT_CONTROL_CLICK)
            call BlzTriggerRegisterFrameEvent(TriggerUIQuickUse, BlzGetFrameByName("TasItemBagSlot", QuickUseContext(buttonIndex)), FRAMEEVENT_MOUSE_UP)
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButton", QuickUseContext(buttonIndex)), "")
            call BlzFrameSetText(frame4, GetQuickUseButtonCaption(GetPlayerId(GetLocalPlayer()), buttonIndex))

            if buttonIndex == 1 then
                call BlzFrameSetPoint(frame3, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, -(BlzFrameGetWidth(frame3) * QUICK_USE_BUTTON_COUNT), 0.0)
            else
                call BlzFrameSetPoint(frame3, FRAMEPOINT_TOPLEFT, BlzGetFrameByName("TasItemBagSlot", QuickUseContext(buttonIndex - 1)), FRAMEPOINT_TOPRIGHT, 0.0, 0.0)
            endif

            set buttonIndex = buttonIndex + 1
        endloop
        set frame4 = null
        call SetQuickUseBarVisible(false)
        
        
        set frame = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagCloseButton", panel, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame, 0.03, 0.03)
        call BlzFrameSetText(frame, "X")
        call BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, BlzFrameGetParent(frame), FRAMEPOINT_TOPRIGHT, - 0.002, - 0.002)
        call BlzTriggerRegisterFrameEvent(TriggerUIClose, frame, FRAMEEVENT_CONTROL_CLICK)
        // BlzFrameClick(BlzGetFrameByName("TasItemBagCloseButton", 0))

        set frame2 = BlzCreateFrameByType("TEXT", "TasItemBagHintText", panel, "", 0)
        call BlzFrameSetSize(frame2, BlzFrameGetWidth(panel) - 0.045, 0.012)
        call BlzFrameSetPoint(frame2, FRAMEPOINT_BOTTOMLEFT, panel, FRAMEPOINT_TOPLEFT, 0.008, 0.004)
        call BlzFrameSetText(frame2, GetBagToggleHintText(GetPlayerId(GetLocalPlayer())))
        call BlzFrameSetTextAlignment(frame2, TEXT_JUSTIFY_LEFT, TEXT_JUSTIFY_MIDDLE)

        call BlzFrameSetLevel(BlzGetFrameByName("TasItemBagTooltipPanel", 0), 8)
        // Bag Popup (programmatic, original style)
        set frame = BlzCreateFrameByType("BUTTON", "TasItemBagPopUpPanel", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        call BlzFrameSetLevel(frame, POPUP_FRAME_LEVEL)
        // SELECT + SELL + SPLIT
        call BlzFrameSetSize(frame, 0.1, 0.082)
        set frame2 = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagPopUpButtonSelect", frame, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame2, 0.1, 0.028)
        call BlzFrameSetPoint(frame2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0, 0)
        call BlzFrameSetText(frame2, "SELECT")
        call BlzTriggerRegisterFrameEvent(TriggerUISwap, frame2, FRAMEEVENT_CONTROL_CLICK)

        set frame3 = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagPopUpButtonSell", frame, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame3, 0.1, 0.028)
        call BlzFrameSetPoint(frame3, FRAMEPOINT_TOPLEFT, frame2, FRAMEPOINT_BOTTOMLEFT, 0, 0.001)
        call BlzFrameSetText(frame3, GetSellButtonCaption(GetPlayerId(GetLocalPlayer())))
        call BlzTriggerRegisterFrameEvent(TriggerUISell, frame3, FRAMEEVENT_CONTROL_CLICK)

        // 5th popup button: Split (conditionally shown)
        set frame2 = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagPopUpButtonSplit", frame, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame2, 0.1, 0.028)
        call BlzFrameSetPoint(frame2, FRAMEPOINT_TOPLEFT, frame3, FRAMEPOINT_BOTTOMLEFT, 0, 0.001)
        call BlzFrameSetText(frame2, "SPLIT")
        call BlzTriggerRegisterFrameEvent(TriggerUISplit, frame2, FRAMEEVENT_CONTROL_CLICK)
        call BlzFrameSetVisible(frame2, false)

        // Split panel: info text + - / + / accept / cancel
        set frame2 = BlzCreateFrameByType("BACKDROP", "TasItemBagSplitPanel", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "EscMenuBackdrop", 0)
        // Ensure split panel is above popup menu and captures clicks
        call BlzFrameSetLevel(frame2, SPLIT_FRAME_LEVEL)
        call BlzFrameSetSize(frame2, 0.17, 0.13)
        // Place the split panel clearly to the LEFT of the bag panel.
        call BlzFrameSetPoint(frame2, FRAMEPOINT_TOPRIGHT, panel, FRAMEPOINT_TOPLEFT, -0.02, 0.0)

        set frame3 = BlzCreateFrameByType("TEXT", "TasItemBagSplitInfo", frame2, "", 0)
        call BlzFrameSetPoint(frame3, FRAMEPOINT_TOP, frame2, FRAMEPOINT_TOP, 0.0, -0.02)
        call BlzFrameSetText(frame3, SplitLabelPrefix)
        call BlzFrameSetScale(frame3, 1.25)

        // +/- buttons: no BACKDROP (removes the annoying EscMenuBackdrop border).
        set frame = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagSplitMinus", frame2, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame, 0.035, 0.035)
        call BlzFrameSetPoint(frame, FRAMEPOINT_BOTTOMLEFT, frame2, FRAMEPOINT_BOTTOMLEFT, 0.04, 0.055)
        call BlzFrameSetText(frame, "-")
        call BlzTriggerRegisterFrameEvent(TriggerUISplitMinus, frame, FRAMEEVENT_CONTROL_CLICK)

        set frame = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagSplitPlus", frame2, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame, 0.035, 0.035)
        call BlzFrameSetPoint(frame, FRAMEPOINT_BOTTOMLEFT, frame2, FRAMEPOINT_BOTTOMLEFT, 0.10, 0.055)
        call BlzFrameSetText(frame, "+")
        call BlzTriggerRegisterFrameEvent(TriggerUISplitPlus, frame, FRAMEEVENT_CONTROL_CLICK)

        set frame = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagSplitAccept", frame2, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame, 0.07, 0.035)
        // Move OK down a bit to avoid overlapping +/- row
        call BlzFrameSetPoint(frame, FRAMEPOINT_BOTTOMRIGHT, frame2, FRAMEPOINT_BOTTOMRIGHT, -0.015, 0.02)
        call BlzFrameSetText(frame, "Accept")
        call BlzTriggerRegisterFrameEvent(TriggerUISplitAccept, frame, FRAMEEVENT_CONTROL_CLICK)

        set frame = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagSplitCancel", frame2, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame, 0.069, 0.035)
        // Keep CANCEL aligned with OK, but also lower
        call BlzFrameSetPoint(frame, FRAMEPOINT_BOTTOMRIGHT, BlzGetFrameByName("TasItemBagSplitAccept", 0), FRAMEPOINT_BOTTOMLEFT, -0.0010, 0.0)
        call BlzFrameSetText(frame, "Cancel")
        call BlzTriggerRegisterFrameEvent(TriggerUISplitCancel, frame, FRAMEEVENT_CONTROL_CLICK)

        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)

        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), false)
        // Panel hover tracking
        call BlzTriggerRegisterFrameEvent(TriggerUIPanelHover, panel, FRAMEEVENT_MOUSE_ENTER)
        call BlzTriggerRegisterFrameEvent(TriggerUIPanelHover, panel, FRAMEEVENT_MOUSE_LEAVE)
    endfunction
    
    private function InitBagAt0s takes nothing returns nothing
        local integer i
        set AbilityFieldDrop = ConvertAbilityIntegerLevelField('inv2')
        set AbilityFieldUse = ConvertAbilityIntegerLevelField('inv3')
        set AbilityFieldCanDrop = ConvertAbilityIntegerLevelField('inv5')
        set SwapSelectSound = CreateSound("Sound\\Interface\\MouseClick1.wav", false, false, false, 10, 10, "")
        call SetSoundParamsFromLabel(SwapSelectSound, "InterfaceClick")
        call SetSoundDuration(SwapSelectSound, 239)
        set SwapConfirmSound = CreateSound("Sound\\Interface\\MouseClick1.wav", false, false, false, 10, 10, "")
        call SetSoundParamsFromLabel(SwapConfirmSound, "InterfaceClick")
        call SetSoundDuration(SwapConfirmSound, 239)
        call InitVendorUnits()
        call PrimeSellValueCache()
        
        // set ItemAbilityNeed = Table.create()
        set TimerUpdate = CreateTimer()
        set SuppressNextBagPopupClearTimer = CreateTimer()
        
        set Trigger = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(Trigger, EVENT_PLAYER_UNIT_SELECTED)
        call TriggerAddAction(Trigger, function SelectAction)
        
        set TriggerESC = CreateTrigger()
        set i = 0
        loop
            call BlzTriggerRegisterPlayerKeyEvent(TriggerESC, Player(i), OSKEY_ESCAPE, 0, true)
            set i = i + 1
            exitwhen i >= bj_MAX_PLAYERS
        endloop
        
        call TriggerAddAction(TriggerESC, function ESCAction)

        set TriggerUIQuickUseHotkey = CreateTrigger()
        set i = 0
        loop
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_A)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_B)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_C)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_D)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_E)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_F)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_G)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_H)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_I)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_J)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_K)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_L)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_M)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_N)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_O)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_P)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_Q)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_R)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_S)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_T)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_U)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_V)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_W)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_X)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_Y)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_Z)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_0)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_1)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_2)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_3)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_4)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_5)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_6)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_7)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_8)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_9)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_NUMPAD0)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_NUMPAD1)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_NUMPAD2)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_NUMPAD3)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_NUMPAD4)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_NUMPAD5)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_NUMPAD6)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_NUMPAD7)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_NUMPAD8)
            call RegisterQuickUseHotkeyKey(Player(i), OSKEY_NUMPAD9)
            set i = i + 1
            exitwhen i >= bj_MAX_PLAYERS
        endloop
        call TriggerAddAction(TriggerUIQuickUseHotkey, function QuickUseHotkeyAction)

        set TriggerUIBagCloseSync = CreateTrigger()
        set i = 0
        loop
            call BlzTriggerRegisterPlayerSyncEvent(TriggerUIBagCloseSync, Player(i), BAG_CLOSE_SYNC_PREFIX, false)
            set i = i + 1
            exitwhen i >= bj_MAX_PLAYER_SLOTS
        endloop
        call TriggerAddAction(TriggerUIBagCloseSync, function BagCloseSyncAction)

        set TriggerUIBagInsertSync = CreateTrigger()
        set i = 0
        loop
            call BlzTriggerRegisterPlayerSyncEvent(TriggerUIBagInsertSync, Player(i), BAG_INSERT_SYNC_PREFIX, false)
            set i = i + 1
            exitwhen i >= bj_MAX_PLAYER_SLOTS
        endloop
        call TriggerAddAction(TriggerUIBagInsertSync, function BagInventoryInsertSyncAction)

        set TriggerUIBagDropSync = CreateTrigger()
        set i = 0
        loop
            call BlzTriggerRegisterPlayerSyncEvent(TriggerUIBagDropSync, Player(i), BAG_DROP_SYNC_PREFIX, false)
            set i = i + 1
            exitwhen i >= bj_MAX_PLAYER_SLOTS
        endloop
        call TriggerAddAction(TriggerUIBagDropSync, function BagDropSyncAction)

        set TriggerUIQuickUseSync = CreateTrigger()
        set i = 0
        loop
            call BlzTriggerRegisterPlayerSyncEvent(TriggerUIQuickUseSync, Player(i), QUICK_USE_SYNC_PREFIX, false)
            set i = i + 1
            exitwhen i >= bj_MAX_PLAYER_SLOTS
        endloop
        call TriggerAddAction(TriggerUIQuickUseSync, function QuickUseSyncAction)

        // Listen for page changes from MultiPageInventorySystem
        call TriggerAddAction(PageChangedTrigger, function PageChangedAction)

        // Bag hotkey routing is owned by SampleDialogSystem.

        
        set TriggerItemGain = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(TriggerItemGain, EVENT_PLAYER_UNIT_PICKUP_ITEM)
        call TriggerAddAction(TriggerItemGain, function ItemGainAction)

        set TriggerItemLose = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(TriggerItemLose, EVENT_PLAYER_UNIT_DROP_ITEM)
        call TriggerRegisterAnyUnitEventBJ(TriggerItemLose, EVENT_PLAYER_UNIT_PAWN_ITEM)
        call TriggerAddAction(TriggerItemLose, function ItemLoseRefreshAction)

        set TriggerItemUse = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(TriggerItemUse, EVENT_PLAYER_UNIT_USE_ITEM)
        call TriggerAddAction(TriggerItemUse, function ItemUseAction)

        set TriggerSpellEffect = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(TriggerSpellEffect, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddAction(TriggerSpellEffect, function SpellEffectAction)

        set TriggerUnitOrder = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(TriggerUnitOrder, EVENT_PLAYER_UNIT_ISSUED_ORDER)
        call TriggerRegisterAnyUnitEventBJ(TriggerUnitOrder, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
        call TriggerRegisterAnyUnitEventBJ(TriggerUnitOrder, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
        call TriggerAddAction(TriggerUnitOrder, function UnitOrderAction)

        set TriggerUIOpen = CreateTrigger()
        call TriggerAddAction(TriggerUIOpen, function ShowButtonAction)

        set TriggerUIClose = CreateTrigger()
        call TriggerAddAction(TriggerUIClose, function CloseButtonAction)

        set TriggerUIBagButton = CreateTrigger()
        call TriggerAddAction(TriggerUIBagButton, function BagButtonAction)

        set TriggerUIQuickUse = CreateTrigger()
        call TriggerAddAction(TriggerUIQuickUse, function QuickUseButtonAction)

        set TriggerUISwap = CreateTrigger()
        call TriggerAddAction(TriggerUISwap, function BagPopupActionSelect)

        set TriggerUISell = CreateTrigger()
        call TriggerAddAction(TriggerUISell, function BagPopupActionSell)

        set TriggerUISplit = CreateTrigger()
        call TriggerAddAction(TriggerUISplit, function BagPopupActionSplit)

        set TriggerUISplitAccept = CreateTrigger()
        call TriggerAddAction(TriggerUISplitAccept, function BagPopupActionSplitAccept)

        set TriggerUISplitMinus = CreateTrigger()
        call TriggerAddAction(TriggerUISplitMinus, function BagPopupActionSplitMinus)

        set TriggerUISplitPlus = CreateTrigger()
        call TriggerAddAction(TriggerUISplitPlus, function BagPopupActionSplitPlus)

        set TriggerUISplitCancel = CreateTrigger()
        call TriggerAddAction(TriggerUISplitCancel, function BagPopupActionSplitCancel)

        // Direct inventory slot click handling for swap-to-inventory (including empty slots).
        set TriggerUIInventoryButton = CreateTrigger()
        set i = 0
        loop
            call BlzTriggerRegisterFrameEvent(TriggerUIInventoryButton, BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, i), FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(TriggerUIInventoryButton, BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, i), FRAMEEVENT_MOUSE_LEAVE)
            call BlzTriggerRegisterFrameEvent(TriggerUIInventoryButton, BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, i), FRAMEEVENT_CONTROL_CLICK)
            call BlzTriggerRegisterFrameEvent(TriggerUIInventoryButton, BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, i), FRAMEEVENT_MOUSE_UP)
            set i = i + 1
            exitwhen i >= bj_MAX_INVENTORY
        endloop
        call TriggerAddAction(TriggerUIInventoryButton, function InventoryButtonAction)

        // Hover tracking for slot buttons
        set TriggerUIHover = CreateTrigger()
        call TriggerAddAction(TriggerUIHover, function SlotHoverEventAction)

        // Panel hover tracking trigger
        set TriggerUIPanelHover = CreateTrigger()
        call TriggerAddAction(TriggerUIPanelHover, function PanelHoverEventAction)

        set TriggerUIInventoryPanelHover = CreateTrigger()
        call TriggerAddAction(TriggerUIInventoryPanelHover, function InventoryPanelHoverEventAction)

        // Global mouse handlers (used for inventory deposit and diagnostics)
        set TriggerUIMouseUp = CreateTrigger()
        call RegisterAnyPlayerEvent(EVENT_PLAYER_MOUSE_UP, function GlobalMouseUpAction)

        set i = 0
        loop
            exitwhen i >= bj_MAX_PLAYERS
            set SellHotkeyText[i] = "G"
            set QuickUseHotkeyConfigOpen[i] = false
            call QuickUseResetHotkeysForPlayer(i, false)
            set i = i + 1
        endloop

        // Note: Global mouse right-click detection removed for compatibility.

        call InitFrames()

        // Initial UI paint (show button state + counters)
        call RequestUIUpdate()
        static if LIBRARY_FrameLoader then
            call FrameLoaderAdd(function InitFrames)
        endif
    endfunction
    
    private function init_function takes nothing returns nothing
        set ItemGainTimer = CreateTimer()
        set QuickUseLocalTimer = CreateTimer()
        set WorldDropTimer = CreateTimer()
        set PickupIntentTimer = CreateTimer()
        call TimerStart(QuickUseLocalTimer, 0.03, true, function QuickUseLocalTimerAction)
        call TimerStart(WorldDropTimer, 0.03, true, function WorldDropTimerAction)
        call TimerStart(PickupIntentTimer, 0.03, true, function PickupIntentTimerAction)
        call TimerStart(ItemGainTimer, 0, false, function InitBagAt0s)  
    endfunction
endlibrary
