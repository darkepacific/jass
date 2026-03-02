library TasItemBag initializer init_function requires Table, RegisterPlayerEvent, HoverOriginButton, GenericFunctions
    /*  TasItemBag 1.3
    by Tasyen
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
        private real PosY = 0.30//0.3//0.40
        private framepointtype Pos = FRAMEPOINT_TOP
        private integer Cols = 6
        private integer Rows = 4

        private real ShowButtonPosX = 0.48
        private real ShowButtonPosY = 0.145
        private framepointtype ShowButtonPos = FRAMEPOINT_TOPLEFT
        private string ShowButtonTexture = "ReplaceableTextures/CommandButtons/BTNDustOfAppearance"
        private string ShowButtonTextureDisabled = "ReplaceableTextures/CommandButtonsDisabled/DISBTNDustOfAppearance"
       
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
        private itemintegerfield ItemFieldGoldCost
        public timer TimerUpdate

        // Debounced UI updates (avoid constant polling).
        private boolean UIUpdateScheduled = false
        public trigger Trigger
        public trigger TriggerESC
        public trigger TriggerUIXKey
        public trigger TriggerItemGain
        public trigger TriggerItemUse
        public trigger TriggerUnitDeath
        public trigger TriggerUIOpen
        public trigger TriggerUIClose
        public trigger TriggerUIBagButton
        public trigger TriggerUISlider
        public trigger TriggerUIWheel
        public trigger TriggerUIEquip
        public trigger TriggerUIDrop
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
        public trigger TriggerUnitOrder
        public integer array LastHoveredIndex
        // Drag tracking: origin type 0:none, 1:inventory slot, 2:bag slot
        public integer array DragOriginType
        public integer array DragOriginIndex
        public boolean array DragActive
        public boolean array PanelHover
    
        // TransferItem remembers the current Target
        public item array TransferItem
        public integer array TransferIndex
        public integer array SwapIndex
        public integer array Offset
        public boolean array IgnoreNextSelection // Need to refactor this out
        public boolean array SuppressNextBagPopup

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
        private constant integer SELL_GOLD_PER_LEVEL = 25
        private integer VendorUnitCount = 0
        private integer array VendorUnitId

        private unit array ItemGainTimerUnit
        private timer ItemGainTimer
        private item array ItemGainTimerItem
        private integer ItemGainTimerCount = 0
        private constant integer BAG_PAGE_SLOT_COUNT = 12

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
    endglobals

    // Maps a 1-based EXTRA-bag slot to the owning player's udg_P_Items index.
    // Page slots are 1..12; extra-bag slots are 13..36.
    private function BagSlotArrayIndex takes integer playerKey, integer bagSlot returns integer
        local integer slot = GetPlayerBagNumber(Player(playerKey)) + BAG_PAGE_SLOT_COUNT + bagSlot
        // call Debug("BagSlotArrayIndex: bagSlot=" + I2S(slot))   
        return slot
    endfunction

    private function UpdateUI takes nothing returns nothing
        local integer pId = GetPlayerId(GetLocalPlayer())
        local integer itemCount = 0
        local integer itemCode
        local item it
        local string text = ""
        local integer i
        local integer maxSlots
        set UIUpdateScheduled = false
        // When the options from HeroScoreFrame are in this map use the tooltip&total scale slider
        if GetHandleId(BlzGetFrameByName("HeroScoreFrameOptionsSlider1", 0)) > 0 then
            set TooltipScale = BlzFrameGetValue(BlzGetFrameByName("HeroScoreFrameOptionsSlider1", 0))
        endif
        if GetHandleId(BlzGetFrameByName("HeroScoreFrameOptionsSlider3", 0)) > 0 then
            call BlzFrameSetScale(BlzGetFrameByName("TasItemBagPanel", 0), BlzFrameGetValue(BlzGetFrameByName("HeroScoreFrameOptionsSlider3", 0)))
        endif

        call BlzFrameSetScale(BlzGetFrameByName("TasItemBagTooltipPanel", 0), TooltipScale)
        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlot", 0), ShowButtonAlwaysVisible or BlzFrameIsVisible(BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, 0)))

        // Count items for the little overlay on the show-button.
        set maxSlots = PITEMS_EXTRA_SLOTS
        set i = 1
        loop
            exitwhen i > maxSlots
            if udg_P_Items[BagSlotArrayIndex(pId, i)] != null then
                set itemCount = itemCount + 1
            endif
            set i = i + 1
        endloop
        call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", 0), I2S(itemCount))

        if BlzFrameIsVisible(BlzGetFrameByName("TasItemBagPanel", 0)) then    

            // Holes model: fixed grid, no scrolling.
            // call BlzFrameSetMinMaxValue(BlzGetFrameByName("TasItemBagSlider", 0), 0, 0)
            // call BlzFrameSetText(BlzGetFrameByName("TasItemBagSliderTooltip", 0), "")
            set Offset[pId] = 0

            set i = 1
            loop
                exitwhen i > PITEMS_EXTRA_SLOTS
                set it = udg_P_Items[BagSlotArrayIndex(pId, i)]
                call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButton", i), it != null)
                set text = ""
                if it != null then
                    set itemCode = GetItemTypeId(it)
                    call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", i), BlzGetItemIconPath(it), 0, true)
                    call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", i), BlzGetItemIconPath(it), 0, true)
                    if AddNeedText then
                        set text = "|nNEED " + GetLocalizedString("REQUIREDLEVELTOOLTIP") + " " + I2S(GetItemLevel(it))
                        // if ItemAbilityNeed[itemCode] > 0 then
                        //     set text = text + "|nNEED " + GetObjectName(ItemAbilityNeed[itemCode])
                        // endif
                    endif

                    call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonTooltip", i), GetItemName(it) + "|n" + BlzGetItemExtendedTooltip(it) + "|n|n" + text)
                
                    if GetItemCharges(it) > 0 then
                        call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", i), I2S(GetItemCharges(it)))
                        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", i), true)
                    else
                        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", i), false)
                    endif
                else
                    call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", i), false)
                    call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", i), "")
                    call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonTooltip", i), "")
                    // Ensure empty slots don't show stale textures for a frame
                    call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", i), "", 0, true)
                    call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", i), "", 0, true)
                endif
                set i = i + 1
            endloop
        endif
        set it = null
    endfunction

    // Schedules a UI refresh once (debounced). Safe to call many times.
    private function RequestUIUpdate takes nothing returns nothing
        if not UIUpdateScheduled then
            set UIUpdateScheduled = true
            call TimerStart(TimerUpdate, 0.00, false, function UpdateUI)
        endif
    endfunction

    private function RestoreBagSlotOverlay takes integer pId, integer rawSlotIndex returns nothing
        local item it
        if rawSlotIndex <= 0 or rawSlotIndex > PITEMS_EXTRA_SLOTS then
            return
        endif
        if GetLocalPlayer() == Player(pId) then
            set it = udg_P_Items[BagSlotArrayIndex(pId, rawSlotIndex)]
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

    private function SwapHoverHide takes integer pId returns nothing
        if SwapHoverIndex[pId] > 0 then
            call RestoreBagSlotOverlay(pId, SwapHoverIndex[pId])
            set SwapHoverIndex[pId] = 0
        endif
    endfunction

    private function SwapHoverShowOnSlot takes integer pId, integer rawSlotIndex returns nothing
        local integer arrIndex
        if rawSlotIndex <= 0 or rawSlotIndex > PITEMS_EXTRA_SLOTS then
            call SwapHoverHide(pId)
            return
        endif
        if SwapIndex[pId] <= 0 or rawSlotIndex == SwapIndex[pId] then
            call SwapHoverHide(pId)
            return
        endif

        set arrIndex = BagSlotArrayIndex(pId, rawSlotIndex)
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
            if SwapHighlight[pId] != null then
                call BlzFrameSetVisible(SwapHighlight[pId], false)
            endif
        endif
    endfunction

    private function SwapHighlightShowOnSlot takes integer pId, integer rawSlotIndex returns nothing
        if GetLocalPlayer() == Player(pId) then
            if SwapHighlight[pId] != null and rawSlotIndex > 0 then
                call BlzFrameClearAllPoints(SwapHighlight[pId])
                call BlzFrameSetPoint(SwapHighlight[pId], FRAMEPOINT_TOPLEFT, BlzGetFrameByName("TasItemBagSlotButton", rawSlotIndex), FRAMEPOINT_TOPLEFT, 0, -0.002)
                call BlzFrameSetPoint(SwapHighlight[pId], FRAMEPOINT_BOTTOMRIGHT, BlzGetFrameByName("TasItemBagSlotButton", rawSlotIndex), FRAMEPOINT_BOTTOMRIGHT, 0, -0.002)
                call BlzFrameSetVisible(SwapHighlight[pId], true)
            endif
        endif
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
        set VendorUnitId[VendorUnitCount] = 'n000' // Argent Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n010' // Blood Elf Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n047' // Draenei Epic Crafter
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n00Q' // Dwarf Vendor
        set VendorUnitCount = VendorUnitCount + 1
        set VendorUnitId[VendorUnitCount] = 'n035' // Epic Vendor
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
        set VendorUnitId[VendorUnitCount] = 'u030' // Alliance Flight Path (Greenwarden's Grove)
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
        return 0
    endfunction

    function IsStackableType takes item i returns boolean
        if i == null then
            return false
        endif
        return ( GetItemType(i) == ITEM_TYPE_CHARGED or GetItemType(i) == ITEM_TYPE_MISCELLANEOUS or GetItemType(i) == ITEM_TYPE_CAMPAIGN or GetItemType(i) == ITEM_TYPE_UNKNOWN)
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

        if i == null then
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
            call ErrorMessage("Bag is full.", GetOwningPlayer(u))
            return
        endif

        set itemIsland = GetRectCenter(gg_rct_ISLAND_ITEMS)
        call SetItemPositionLoc(i, itemIsland)
        call SetItemVisible(i, false)
        call SetItemUserData(i, 1)
        call RemoveLocation(itemIsland)

        set arrIndex = BagSlotArrayIndex(playerKey, emptySlot)
        set udg_P_Items[arrIndex] = i
        call RequestUIUpdate()
    endfunction

    function TasItemBagGetItem takes unit u, integer index returns item
        local integer playerKey = GetPlayerId(GetOwningPlayer(u))
        local integer maxSlots = PITEMS_EXTRA_SLOTS
        if index <= 0 or index > maxSlots then
            return null
        endif
        return udg_P_Items[BagSlotArrayIndex(playerKey, index)]
    endfunction
    
    function TasItemBagSwap takes unit u, integer indexA, integer indexB returns boolean
        local integer playerKey = GetPlayerId(GetOwningPlayer(u))
        local integer maxSlots = PITEMS_EXTRA_SLOTS
        local integer a
        local integer b
        local item i
        local item i2
        if indexA <= 0 or indexB <= 0 or indexA > maxSlots or indexB > maxSlots or indexA == indexB then
            return false
        endif
        set a = BagSlotArrayIndex(playerKey, indexA)
        set b = BagSlotArrayIndex(playerKey, indexB)
        set i = udg_P_Items[a]
        set i2 = udg_P_Items[b]
        set udg_P_Items[a] = i2
        set udg_P_Items[b] = i
        set i = null
        set i2 = null
        call RequestUIUpdate()
        return true
    endfunction

    function TasItemBagRemoveIndex takes unit u, integer index, boolean drop returns boolean
        local integer playerKey = GetPlayerId(GetOwningPlayer(u))
        local integer maxSlots = PITEMS_EXTRA_SLOTS
        local integer arrIndex
        local item i
        local location dropSpot
        if index <= 0 or index > maxSlots then
            return false
        endif
        set arrIndex = BagSlotArrayIndex(playerKey, index)
        set i = udg_P_Items[arrIndex]
        if i == null then
            return false
        endif
        set udg_P_Items[arrIndex] = null
        call RequestUIUpdate()

        if drop and GetHandleId(i) > 0 then
            set dropSpot = GetUnitLoc(u)
            call SetItemPositionLoc(i, dropSpot)
            call SetItemUserData(i, 0)
            call SetItemVisible(i, true)
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

    private function ItemBag2Equip takes player p, item i returns nothing
        local unit u = udg_Heroes[GetPlayerNumber(p)]
        local integer pId = GetPlayerId(p)
        local integer bagIndex = TransferIndex[pId]
        local integer arrIndex
        local integer maxCharges
        local integer incomingCharges
        local integer existingCharges
        local integer space
        local integer addCharges
        local integer slot
        local item invItem

        // Inventory Full?
        if UnitInventoryCount(u) >= UnitInventorySize(u) then
            // If inventory is full, still try to merge charged consumables into an existing stack.
            // This matches WC3's natural behavior when adding/picking up charged items.
            if i != null and IsStackableType(i) and GetItemCharges(i) > 0 then
                set maxCharges = 20
                set incomingCharges = GetItemCharges(i)
                if incomingCharges > maxCharges then
                    set incomingCharges = maxCharges
                endif
                set slot = 0
                loop
                    exitwhen slot >= bj_MAX_INVENTORY or incomingCharges <= 0
                    set invItem = UnitItemInSlot(u, slot)
                    if invItem != null and IsStackableType(invItem) and GetItemTypeId(invItem) == GetItemTypeId(i) then
                        set existingCharges = GetItemCharges(invItem)
                        if existingCharges < 0 then
                            set existingCharges = 0
                        endif
                        if existingCharges < maxCharges then
                            set space = maxCharges - existingCharges
                            if incomingCharges > space then
                                set addCharges = space
                            else
                                set addCharges = incomingCharges
                            endif
                            call SetItemCharges(invItem, existingCharges + addCharges)
                            set incomingCharges = incomingCharges - addCharges
                        endif
                    endif
                    set slot = slot + 1
                endloop

                // If we managed to merge anything, update the bank item accordingly.
                if incomingCharges < GetItemCharges(i) then
                    if incomingCharges <= 0 then
                        // Fully absorbed into an inventory stack; remove the bag item entry and destroy it.
                        if bagIndex <= 0 or TasItemBagGetItem(u, bagIndex) != i then
                            set bagIndex = BagFindItemSlot(pId, i)
                        endif
                        if bagIndex > 0 then
                            set arrIndex = BagSlotArrayIndex(pId, bagIndex)
                            set udg_P_Items[arrIndex] = null
                        endif
                        call RemoveItem(i)
                    else
                        // Partially absorbed; keep the bank item with remaining charges.
                        call SetItemCharges(i, incomingCharges)
                        call SetItemVisible(i, false)
                    endif
                    call RequestUIUpdate()
                    set invItem = null
                    set u = null
                    return
                endif
            endif

            call ErrorMessage("Inventory is full.", GetOwningPlayer(u))
            set invItem = null
            set u = null
            return
        endif
    
        // unit can equip this, restrictions
        if not UnitCanEquipItem(u, i) then
            return
        endif
     
        // Make the item visible and place it at the hero before equipping
        call SetItemVisible(i, true)
        call SetItemPosition(i, GetUnitX(u), GetUnitY(u))
        call Debug("Item to be equipped from Bank: " + GetItemName(i) + GetUnitName(u))

        set udg_dontDepositIntoBag = true
        if UnitAddItem(u, i) then
            // Clear the bag slot by index; WC3 may merge charges and delete handles.
            if bagIndex <= 0 or TasItemBagGetItem(u, bagIndex) != i then
                set bagIndex = BagFindItemSlot(pId, i)
            endif
            if bagIndex > 0 then
                set arrIndex = BagSlotArrayIndex(pId, bagIndex)
                set udg_P_Items[arrIndex] = null
            endif
        endif
        call RequestUIUpdate()
        set u = null
    endfunction

    // Moves the item in the given inventory slot into the player's bank
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
            call ErrorMessage("Bag is full.", p)
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

    private function StartWorldDropFromSelection takes player p, integer bagIndex, real x, real y returns boolean
        local integer pId = GetPlayerId(p)
        local unit hero = udg_Heroes[GetPlayerNumber(p)]
        local item it
        if hero == null then
            return false
        endif
        if bagIndex <= 0 or bagIndex > PITEMS_EXTRA_SLOTS then
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
                                call SetItemVisible(it, true)
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
        if u == null then
            return
        endif
        set owner = GetOwningPlayer(u)
        set pId = GetPlayerId(owner)
        if u == udg_Heroes[GetPlayerNumber(owner)] and WorldDropActive[pId] then
            if IgnoreNextWorldDropOrder[pId] then
                set IgnoreNextWorldDropOrder[pId] = false
            else
                call ClearWorldDropQueue(pId)
            endif
        endif
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
        local item bagItem
        local item invItem
        local item newInvItem
        local integer arrIndex
        local location itemIsland
        local integer firstOpen
        local integer bagTypeId
        local integer bagCharges
        local integer foundBagSlot

        if hero == null or bagSlot <= 0 then
            return false
        endif
        if invSlot < 0 or invSlot >= bj_MAX_INVENTORY then
            return false
        endif

        set bagItem = TasItemBagGetItem(hero, bagSlot)
        if bagItem == null then
            return false
        endif
        if not UnitCanEquipItem(hero, bagItem) then
            set bagItem = null
            return false
        endif

        // Remove target inventory item first (if any), so there is guaranteed space.
        set invItem = UnitItemInSlot(hero, invSlot)
        if invItem != null then
            set invItem = UnitRemoveItemFromSlot(hero, invSlot)
        endif

        set firstOpen = FirstOpenInventorySlot(hero)

        // If the target slot is the first open one, preserve the original item handle path.
        if firstOpen == invSlot then
            call ItemBag2Equip(p, bagItem)

            // If equip failed, put removed inventory item back and abort.
            if BagFindItemSlot(pId, bagItem) > 0 then
                if invItem != null then
                    call UnitAddItem(hero, invItem)
                endif
                set bagItem = null
                set invItem = null
                set hero = null
                return false
            endif
        else
            // Force exact target slot by spawning item directly into invSlot and removing bag instance.
            set bagTypeId = GetItemTypeId(bagItem)
            set bagCharges = GetItemCharges(bagItem)
            set udg_dontDepositIntoBag = true
            if not UnitAddItemToSlotById(hero, bagTypeId, invSlot) then
                set udg_dontDepositIntoBag = false
                if invItem != null then
                    call UnitAddItem(hero, invItem)
                endif
                set bagItem = null
                set invItem = null
                set hero = null
                return false
            endif

            set newInvItem = UnitItemInSlot(hero, invSlot)
            if newInvItem == null then
                if invItem != null then
                    call UnitAddItem(hero, invItem)
                endif
                set bagItem = null
                set invItem = null
                set hero = null
                return false
            endif

            if bagCharges > 0 then
                call SetItemCharges(newInvItem, bagCharges)
            endif

            // Consume the bag item instance and clear bag slot.
            set arrIndex = BagSlotArrayIndex(pId, bagSlot)
            if udg_P_Items[arrIndex] == bagItem then
                set udg_P_Items[arrIndex] = null
            else
                set foundBagSlot = BagFindItemSlot(pId, bagItem)
                if foundBagSlot > 0 then
                    set arrIndex = BagSlotArrayIndex(pId, foundBagSlot)
                    set udg_P_Items[arrIndex] = null
                endif
            endif
            call RemoveItem(bagItem)
            call RequestUIUpdate()
        endif

        // Put removed inventory item into the original bag slot (or any free slot fallback).
        if invItem != null then
            set arrIndex = BagSlotArrayIndex(pId, bagSlot)
            if udg_P_Items[arrIndex] == null then
                set itemIsland = GetRectCenter(gg_rct_ISLAND_ITEMS)
                call SetItemPositionLoc(invItem, itemIsland)
                call SetItemVisible(invItem, false)
                call SetItemUserData(invItem, 1)
                call RemoveLocation(itemIsland)
                set itemIsland = null
                set udg_P_Items[arrIndex] = invItem
                call RequestUIUpdate()
            else
                call TasItemBagAddItem(hero, invItem, true)
            endif
        endif

        set bagItem = null
        set invItem = null
        set newInvItem = null
        set hero = null
        return true
    endfunction

    private function BagPopupActionDrop takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local unit hero = udg_Heroes[GetPlayerNumber(p)]
        if GetLocalPlayer() == p then
            call BlzFrameSetVisible(BlzFrameGetParent(BlzGetTriggerFrame()), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
        endif

        // Always operate on the triggering player's own bag/hero.
        if hero != null then
            call TasItemBagRemoveIndex(hero, TransferIndex[pId], true)
        endif
        set hero = null
        call FrameLoseFocus()
    endfunction

    private function BagPopupActionEquip takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(GetTriggerPlayer())
        call ItemBag2Equip(p, TransferItem[pId])
        if GetLocalPlayer() == p then
            call BlzFrameSetVisible(BlzFrameGetParent(BlzGetTriggerFrame()), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
        endif
        call FrameLoseFocus()
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

    private function SellBagIndexToShop takes player p, integer bagIndex, unit shop, boolean requireRange returns boolean
        local unit hero = udg_Heroes[GetPlayerNumber(p)]
        local item it
        local texttag gainTag
        local integer goldGain
        local real dx
        local real dy
        local location heroLoc

        if hero == null then
            return false
        endif
        if bagIndex <= 0 or bagIndex > PITEMS_EXTRA_SLOTS then
            set hero = null
            return false
        endif

        set it = TasItemBagGetItem(hero, bagIndex)
        if it == null then
            set hero = null
            return false
        endif

        if not IsItemPawnable(it) then
            call ErrorMessage("This item cannot be sold.", p)
            set hero = null
            set it = null
            return false
        endif

        if shop == null or not IsVendorUnit(shop) then
            call ErrorMessage("No shop in range.", p)
            set hero = null
            set it = null
            set shop = null
            return false
        endif

        if requireRange then
            set dx = GetUnitX(hero) - GetUnitX(shop)
            set dy = GetUnitY(hero) - GetUnitY(shop)
            if SquareRoot(dx*dx + dy*dy) > SELL_RANGE then
                call ErrorMessage("No shop in range.", p)
                set hero = null
                set it = null
                set shop = null
                return false
            endif
        endif

        set goldGain = R2I(I2R(BlzGetItemIntegerField(it, ItemFieldGoldCost)) * 0.50)
        if goldGain < 1 then
            set goldGain = GetItemLevel(it) * SELL_GOLD_PER_LEVEL
        endif
        if goldGain < 1 then
            set goldGain = 1
        endif
        if IsStackableType(it) and GetItemCharges(it) > 0 then
            set goldGain = goldGain * GetItemCharges(it)
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
            call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 40, 90 )
            call CleanUpText( 3.00, 2.00)
            call StartSound(gg_snd_ReceiveGold)
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

    private function BagPopupActionSell takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local unit hero = udg_Heroes[GetPlayerNumber(p)]
        local unit shop = null

        if GetLocalPlayer() == p then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
        endif

        if hero == null then
            call FrameLoseFocus()
            return
        endif

        set shop = FindNearbySellShop(hero)
        call SellBagIndexToShop(p, TransferIndex[pId], shop, true)

        call FrameLoseFocus()
        set hero = null
        set shop = null
    endfunction

    private function BagPopupActionSplit takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local item it
        local integer charges
        // For now: open the (stub) split panel. No actual splitting logic yet.
        set SplitRequested[pId] = TransferIndex[pId]
        if GetLocalPlayer() == p then
            // Hide the popup menu while splitting to avoid click-through/interference
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), true)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitMinus", 0), true)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPlus", 0), true)
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
        // Perform split: move "take" charges into a new bank item.
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
        // Respect bank stacking cap of 20 charges.
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
            call ErrorMessage("Bag is full.", p)
            if GetLocalPlayer() == p then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            endif
            set SplitRequested[pId] = 0
            set SplitAmount[pId] = 0
            call FrameLoseFocus()
            return
        endif

        // Update source item charges (stays in bank).
        call Debug("Settng source item: "+  GetItemName(src) + "charges: " + I2S(remain))
        call SetItemCharges(src, remain)

        // Create a new item of same type and add it to the bank.
        set newItem = CreateItem(GetItemTypeId(src), GetUnitX(udg_Heroes[GetPlayerNumber(p)]), GetUnitY(udg_Heroes[GetPlayerNumber(p)]))
        call SetItemCharges(newItem, take)
        
        // Do not auto-merge split-created stacks back into the source stack.
        call TasItemBagAddItem(udg_Heroes[GetPlayerNumber(p)], newItem, false)
        call Debug("Created new item: " + GetItemName(newItem) + " charges: " + I2S(take))
        set newItem = null
        
        // Close split + popup
        if GetLocalPlayer() == p then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
        endif
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
        if GetLocalPlayer() == p then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
        endif
        set SplitRequested[pId] = 0
        set SplitAmount[pId] = 0
        call FrameLoseFocus()
    endfunction

    // Direct inventory item-button click handler to finalize armed bag swap.
    // This is more reliable than hover-timer sampling for empty inventory slots.
    private function InventoryButtonAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local integer invSlot = 0
        local frameeventtype evt = BlzGetTriggerFrameEvent()

        if SwapIndex[pId] <= 0 then
            return
        endif

        // Ignore non-left mouse-up (right/middle release) to avoid accidental finalize.
        if evt == FRAMEEVENT_MOUSE_UP and BlzGetTriggerPlayerMouseButton() != MOUSE_BUTTON_TYPE_LEFT then
            return
        endif

        loop
            exitwhen invSlot >= bj_MAX_INVENTORY
            if BlzGetTriggerFrame() == BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, invSlot) then
                exitwhen true
            endif
            set invSlot = invSlot + 1
        endloop

        if invSlot < bj_MAX_INVENTORY then
            if SwapBagSlotToInventorySlot(p, invSlot) then
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
        endif
    endfunction

    // Resolve a bag slot index from any of its related frames (button/backdrop/container)
    private function ResolveBagSlotIndex takes framehandle f returns integer
        local integer i = 1
        loop
            exitwhen i > Cols * Rows
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
        local real panelH = slotH * Rows + (Rows - 1) * 0.002 + 0.012
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
            if bagIndex <= 0 or bagIndex > Cols * Rows then
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
                    set SwapIndex[pId] = 0
                    set SuppressNextBagPopup[pId] = true
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
                if TransferItem[pId] != null then
                    if GetLocalPlayer() == p then
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
        call Debug("BagPanelEnterAction ENTER")
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
        call Debug("BagPanelLeaveAction LEAVE")
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

    // Global mouse up handler: right-click = select/deposit, left-click = bag/inventory finalize or world-drop when armed
    private function GlobalMouseUpAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local mousebuttontype btn = BlzGetTriggerPlayerMouseButton()
        local integer targetIndex = LastHoveredIndex[pId]
        local integer invIndex = HoverOriginButton_CurrentSelectedButtonIndex - HoverOriginButton_ItemButtonOffset
        local integer rawIdx
        local integer bagIndex
        local item bi
        local boolean didSomething = false
        local string panelStr
        local integer itemCharges
        local itemtype itemType
        local boolean mouseInPanel = IsMouseInsideBagPanel()

        // Ignore any clicks when bank panel is not open
        if not BlzFrameIsVisible(BlzGetFrameByName("TasItemBagPanel", 0)) then
            return
        endif

        if mouseInPanel then
            set PanelHover[pId] = true
        endif

        if PanelHover[pId] then
            set panelStr = "true"
        else
            set panelStr = "false"
        endif
        call Debug("Global MOUSE_UP: invIndex=" + I2S(invIndex) + ", LastHoveredIndex=" + I2S(LastHoveredIndex[pId]) + ", PanelHover=" + panelStr)

        if btn == MOUSE_BUTTON_TYPE_RIGHT then
            // WoW-like: right-click cancels an armed swap without side-effects
            if SwapIndex[pId] > 0 then
                set SwapIndex[pId] = 0
                call SwapHighlightHide(pId)
                if GetLocalPlayer() == p then
                    call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
                    call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
                endif
                return
            endif
            // Always hide the popup on any right-click while the bag UI is open
            if GetLocalPlayer() == p then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            endif
            // Right-click: A) deposit when over inventory, B) quick SELECT-arm when over bag
            if invIndex >= 0 and invIndex < bj_MAX_INVENTORY then
                call Debug("Deposit: inventory slot " + I2S(invIndex) + " -> bank")
                call DepositInventorySlot(p, invIndex)
                set didSomething = true
            elseif PanelHover[pId] then
                set rawIdx = ResolveBagIndexFromMouse()
                if rawIdx <= 0 and targetIndex > 0 then
                    set bagIndex = targetIndex
                    set rawIdx = bagIndex
                else
                    set bagIndex = rawIdx
                endif
                if rawIdx > 0 and rawIdx <= Cols * Rows then
                    set bi = udg_P_Items[BagSlotArrayIndex(pId, bagIndex)]
                    if bi != null then
                        call Debug("Select arm (global right-click): rawIdx=" + I2S(rawIdx) + ", bagIndex=" + I2S(bagIndex))
                        set SwapIndex[pId] = bagIndex
                        call SwapHighlightShowOnSlot(pId, SwapIndex[pId])
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
            // Finalize armed bag swap onto an inventory slot (supports empty slots).
            if SwapIndex[pId] > 0 and invIndex >= 0 and invIndex < bj_MAX_INVENTORY then
                if SwapBagSlotToInventorySlot(p, invIndex) then
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
                if rawIdx > 0 and rawIdx <= Cols * Rows then
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
                        set SwapIndex[pId] = 0
                        set SuppressNextBagPopup[pId] = true
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
                // Armed SELECT + left-click outside bag and inventory => move then drop at click point.
                if (not PanelHover[pId]) then
                    if StartWorldDropFromSelection(p, SwapIndex[pId], BlzGetTriggerPlayerMouseX(), BlzGetTriggerPlayerMouseY()) then
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
                endif
            endif
        endif
    endfunction
    
    // private function WheelAction takes nothing returns nothing
    //     // Slider disabled (fixed bag size fits on screen).
    //     local boolean upwards = BlzGetTriggerFrameValue() > 0
    //     if GetLocalPlayer() == GetTriggerPlayer() then
    //         if upwards then 
    //             call BlzFrameSetValue(BlzGetFrameByName("TasItemBagSlider", 0), BlzFrameGetValue(BlzGetFrameByName("TasItemBagSlider", 0)) + 1)
    //         else
    //             call BlzFrameSetValue(BlzGetFrameByName("TasItemBagSlider", 0), BlzFrameGetValue(BlzGetFrameByName("TasItemBagSlider", 0)) - 1)
    //         endif
    //     endif
    // endfunction

    private function CloseButtonAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        set SwapIndex[pId] = 0
        call SwapHighlightHide(pId)
        set TransferIndex[pId] = 0
        set TransferItem[pId] = null
        if GetLocalPlayer() == GetTriggerPlayer() then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
        endif
        call FrameLoseFocus()
    endfunction

    // Toggle the bag panel on OSKEY_X press
    private function XKeyToggleAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        if GetLocalPlayer() == p then
            // Update once before showing to avoid a one-frame flash of stale/null slot data
            call UpdateUI()
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), BlzFrameIsVisible(BlzGetFrameByName("TasItemBagPanel", 0)) == false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            call UpdateUI()
        endif
        set SwapIndex[GetPlayerId(p)] = 0
        call SwapHighlightHide(GetPlayerId(p))
        call FrameLoseFocus()
    endfunction

    private function ShowButtonAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        local integer s
        set SwapIndex[pId] = 0
        call SwapHighlightHide(pId)
        set TransferIndex[pId] = 0
        set TransferItem[pId] = null
        if GetLocalPlayer() == GetTriggerPlayer() then
            // Update once before showing to avoid a one-frame flash of stale/null slot data
            call UpdateUI()
            //Close/Open Bag Panel
            if BlzFrameIsVisible(BlzGetFrameByName("TasItemBagPanel", 0)) then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), false)
            else
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), true)
            endif
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            call UpdateUI()
        endif
        call FrameLoseFocus()
    endfunction

    private function SliderAction takes nothing returns nothing
        // Slider disabled (fixed bag size fits on screen).
        // set Offset[GetPlayerId(GetTriggerPlayer())] = 0
    endfunction

    private function SelectAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        local player p = GetTriggerPlayer()
        local unit selected = GetTriggerUnit()
        local unit hero = udg_Heroes[GetPlayerNumber(p)]

        if IgnoreNextSelection[pId] then
            set IgnoreNextSelection[pId] = false
            return
        endif

        set Offset[pId] = 0

        // Armed SELECT + selecting a vendor sells immediately to that selected shop.
        if SwapIndex[pId] > 0 and IsVendorUnit(selected) then
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
            set selected = null
            set hero = null
            set p = null
            return
        endif

        // Open banking UI when a Bank unit is selected
        if IsBankUnit(selected) then
            if GetLocalPlayer() == p then
                // Update once before showing to avoid a one-frame flash of stale/null slot data
                call UpdateUI()
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), true)
                // Auto-reselect the hero so their inventory is visible while banking
                set IgnoreNextSelection[pId] = true
                call SelectUnitForPlayerSingle(udg_Heroes[GetPlayerNumber(p)], p)
            endif
        endif
        set selected = null
        set hero = null
        set p = null
    endfunction

    private function ESCAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        // WoW-like: ESC cancels swap first, then closes UI on subsequent ESC
        if GetLocalPlayer() == GetTriggerPlayer() then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
        endif
        if SwapIndex[pId] > 0 then
            set SwapIndex[pId] = 0
            call SwapHighlightHide(pId)
            return
        endif
        if GetLocalPlayer() == GetTriggerPlayer() then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), false)
        endif
    endfunction

    // Process delayed item gains: move picked-up items into the bag after a short delay
    private function ItemGainTimerAction takes nothing returns nothing
        loop
            exitwhen ItemGainTimerCount <= 0
            if UnitHasItem(ItemGainTimerUnit[ItemGainTimerCount], ItemGainTimerItem[ItemGainTimerCount]) then
                call TasItemBagAddItem(ItemGainTimerUnit[ItemGainTimerCount], ItemGainTimerItem[ItemGainTimerCount], true)
            endif
            set ItemGainTimerCount = ItemGainTimerCount - 1
        endloop
    endfunction

    private function ItemGainAction takes nothing returns nothing
        if udg_dontDepositIntoBag then
            set udg_dontDepositIntoBag = false
            return
        endif

        // Do not move Powerups that can be used into the bag
        if IsItemPowerup(GetManipulatedItem()) and TasItemBagUnitCanUseItems(GetTriggerUnit()) then 
            return
        endif
        
        // dont move it instantly, delay it with a 0s timer, this stops item pickup orders onto the same item in a row and allows the user to do some stuff to pickedup items
        // does not prevent move ground pick up in rotation
        set ItemGainTimerCount = ItemGainTimerCount + 1
        set ItemGainTimerUnit[ItemGainTimerCount] = GetTriggerUnit()
        set ItemGainTimerItem[ItemGainTimerCount] = GetManipulatedItem()
        call TimerStart(ItemGainTimer, 0, false, function ItemGainTimerAction)

    endfunction
     
    private function CreateTextTooltip takes framehandle frame, string wantedframeName, integer wantedCreateContext, string text returns framehandle
        // this FRAME is important when the Box is outside of 4:3 it can be limited to 4:3.
        local framehandle toolTipParent = BlzCreateFrameByType("FRAME", "", BlzGetFrameByName("TasItemBagTooltipPanel", 0), "", 0)
        local framehandle toolTipBox = BlzCreateFrame("TasToolTipBox", toolTipParent, 0, 0)
        local framehandle toolTip = BlzCreateFrameByType("TEXT", wantedframeName, toolTipBox, "TasTooltipText", wantedCreateContext)

        if TooltipFixedPosition then 
            call BlzFrameSetAbsPoint(toolTip, TooltipFixedPositionPoint, TooltipFixedPositionX, TooltipFixedPositionY)
        else
            call BlzFrameSetPoint(toolTip, FRAMEPOINT_TOP, frame, FRAMEPOINT_BOTTOM, 0, - 0.008)
        endif

        call BlzFrameSetPoint(toolTipBox, FRAMEPOINT_TOPLEFT, toolTip, FRAMEPOINT_TOPLEFT, - 0.008, 0.008)
        call BlzFrameSetPoint(toolTipBox, FRAMEPOINT_BOTTOMRIGHT, toolTip, FRAMEPOINT_BOTTOMRIGHT, 0.008, - 0.008)
        call BlzFrameSetText(toolTip, text)
        call BlzFrameSetTooltip(frame, toolTipParent)
        call BlzFrameSetSize(toolTip, TooltipWidth, 0)
        // Important: tooltip frames must not capture mouse, otherwise hover can flicker.
        call BlzFrameSetEnable(toolTipParent, false)
        call BlzFrameSetEnable(toolTipBox, false)
        call BlzFrameSetEnable(toolTip, false)
        return toolTip
    endfunction

    private function InitFrames takes nothing returns nothing
        local boolean loaded = BlzLoadTOCFile("war3mapImported/TasItemBag.toc")
        local framehandle panel
        local framehandle frame
        local framehandle frame2
        local framehandle frame3
        local integer count = 0
        local integer buttonIndex = 0
        local boolean backup
        local integer invIndex
        local framehandle invButton
        local framehandle depButton

        set panel = BlzCreateFrameByType("BUTTON", "TasItemBagPanel", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        call BlzFrameSetAbsPoint(panel, Pos, PosX, PosY)
        call BlzFrameSetAllPoints(BlzCreateFrame("TasItemBagBox", panel, 0, 0), panel)
        // Slider disabled (fixed bag size fits on screen).
        // call BlzTriggerRegisterFrameEvent(TriggerUIWheel, panel, FRAMEEVENT_MOUSE_WHEEL)
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
            // Slider disabled (fixed bag size fits on screen).
            // call BlzTriggerRegisterFrameEvent(TriggerUIWheel, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_MOUSE_WHEEL)
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
        call BlzFrameSetSize(panel, BlzFrameGetWidth(frame) * Cols + (Cols - 1) * 0.002 + 0.02, BlzFrameGetHeight(frame) * Rows + (Rows - 1) * 0.002 + 0.012)
        call BlzFrameSetPoint(BlzGetFrameByName("TasItemBagSlot", 1), FRAMEPOINT_TOPLEFT, panel, FRAMEPOINT_TOPLEFT, 0.006, - 0.006)

        /*
        // Slider disabled (fixed bag size fits on screen).
        set frame = BlzCreateFrameByType("SLIDER", "TasItemBagSlider", panel, "QuestMainListScrollBar", 0)
        call BlzFrameClearAllPoints(frame)
        call BlzFrameSetPoint(frame, FRAMEPOINT_BOTTOMRIGHT, panel, FRAMEPOINT_BOTTOMRIGHT, - 0.004, 0.008)
        call BlzFrameSetSize(frame, BlzFrameGetWidth(frame), BlzFrameGetHeight(panel) - 0.02)
        //BlzFrameSetStepSize(frame, Cols)
        set backup = TooltipFixedPosition
        set TooltipFixedPosition = false
        call CreateTextTooltip(frame, "TasItemBagSliderTooltip", 0, "")
        call BlzFrameSetSize(BlzGetFrameByName("TasItemBagSliderTooltip", 0), 0, 0)
        set TooltipFixedPosition = backup
        call BlzTriggerRegisterFrameEvent(TriggerUIWheel, frame, FRAMEEVENT_MOUSE_WHEEL)
        call BlzTriggerRegisterFrameEvent(TriggerUISlider, frame, FRAMEEVENT_SLIDER_VALUE_CHANGED)
        */


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
        
        
        set frame = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagCloseButton", panel, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame, 0.03, 0.03)
        call BlzFrameSetText(frame, "X")
        call BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, BlzFrameGetParent(frame), FRAMEPOINT_TOPRIGHT, - 0.002, - 0.002)
        call BlzTriggerRegisterFrameEvent(TriggerUIClose, frame, FRAMEEVENT_CONTROL_CLICK)
        // BlzFrameClick(BlzGetFrameByName("TasItemBagCloseButton", 0))

        call BlzFrameSetLevel(BlzGetFrameByName("TasItemBagTooltipPanel", 0), 8)
        // Bag Popup (programmatic, original style)
        set frame = BlzCreateFrameByType("BUTTON", "TasItemBagPopUpPanel", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        call BlzFrameSetLevel(frame, POPUP_FRAME_LEVEL)
        // SELECT + SELL + SPLIT
        call BlzFrameSetSize(frame, 0.1, 0.09)
        set frame2 = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagPopUpButtonSelect", frame, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame2, 0.1, 0.03)
        call BlzFrameSetPoint(frame2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0, 0)
        call BlzFrameSetText(frame2, "SELECT")
        call BlzTriggerRegisterFrameEvent(TriggerUISwap, frame2, FRAMEEVENT_CONTROL_CLICK)

        set frame3 = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagPopUpButtonSell", frame, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame3, 0.1, 0.03)
        call BlzFrameSetPoint(frame3, FRAMEPOINT_TOPLEFT, frame2, FRAMEPOINT_BOTTOMLEFT, 0, 0)
        call BlzFrameSetText(frame3, "SELL")
        call BlzTriggerRegisterFrameEvent(TriggerUISell, frame3, FRAMEEVENT_CONTROL_CLICK)

        // 5th popup button: Split (conditionally shown)
        set frame2 = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagPopUpButtonSplit", frame, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame2, 0.1, 0.03)
        call BlzFrameSetPoint(frame2, FRAMEPOINT_TOPLEFT, frame3, FRAMEPOINT_BOTTOMLEFT, 0, 0)
        call BlzFrameSetText(frame2, "SPLIT")
        call BlzTriggerRegisterFrameEvent(TriggerUISplit, frame2, FRAMEEVENT_CONTROL_CLICK)
        call BlzFrameSetVisible(frame2, false)

        // Split panel: info text + - / + / accept / cancel
        set frame2 = BlzCreateFrameByType("BACKDROP", "TasItemBagSplitPanel", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "EscMenuBackdrop", 0)
        // Ensure split panel is above popup menu and captures clicks
        call BlzFrameSetLevel(frame2, SPLIT_FRAME_LEVEL)
        call BlzFrameSetSize(frame2, 0.17, 0.13)
        // Place the split panel clearly to the LEFT of the bag panel.
        call BlzFrameSetPoint(frame2, FRAMEPOINT_TOPRIGHT, panel, FRAMEPOINT_TOPLEFT, -0.04, 0.0)

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
        set ItemFieldGoldCost = ConvertItemIntegerField('igol')
        call InitVendorUnits()
        
        // set ItemAbilityNeed = Table.create()
        set TimerUpdate = CreateTimer()
        
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

        // Bind OSKEY_X to toggle the bag UI open/close
        set TriggerUIXKey = CreateTrigger()
        set i = 0
        loop
            call BlzTriggerRegisterPlayerKeyEvent(TriggerUIXKey, Player(i), OSKEY_X, 0, true)
            set i = i + 1
            exitwhen i >= bj_MAX_PLAYERS
        endloop
        call TriggerAddAction(TriggerUIXKey, function XKeyToggleAction)

        
        set TriggerItemGain = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(TriggerItemGain, EVENT_PLAYER_UNIT_PICKUP_ITEM)
        call TriggerAddAction(TriggerItemGain, function ItemGainAction)

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

        /*
        // Slider disabled (fixed bag size fits on screen).
        set TriggerUISlider = CreateTrigger()
        call TriggerAddAction(TriggerUISlider, function SliderAction)

        set TriggerUIWheel = CreateTrigger()
        call TriggerAddAction(TriggerUIWheel, function WheelAction)
        */

        // Legacy popup triggers (events registered in InitFrames after frames are created)
        set TriggerUIEquip = CreateTrigger()
        call TriggerAddAction(TriggerUIEquip, function BagPopupActionEquip)

        set TriggerUIDrop = CreateTrigger()
        call TriggerAddAction(TriggerUIDrop, function BagPopupActionDrop)

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

        // Global mouse handlers (used for inventory deposit and diagnostics)
        set TriggerUIMouseUp = CreateTrigger()
        call RegisterAnyPlayerEvent(EVENT_PLAYER_MOUSE_UP, function GlobalMouseUpAction)

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
        set WorldDropTimer = CreateTimer()
        call TimerStart(WorldDropTimer, 0.03, true, function WorldDropTimerAction)
        call TimerStart(ItemGainTimer, 0, false, function InitBagAt0s)  
        
        // set udg_BAG_SIZE = 13 + PITEMS_EXTRA_SLOTS

    endfunction
endlibrary
