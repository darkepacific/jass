library TasItemBag initializer init_function requires Table, RegisterPlayerEvent, HoverOriginButton
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
        private real PosX = 0.64//0.4
        private real PosY = 0.30
        private framepointtype Pos = FRAMEPOINT_TOP
        private integer Cols = 6
        private integer Rows = 4

        private real ShowButtonPosX = 0.48
        private real ShowButtonPosY = 0.145
        private framepointtype ShowButtonPos = FRAMEPOINT_TOPLEFT
        private string ShowButtonTexture = "ReplaceableTextures/CommandButtons/BTNDustOfAppearance"
        private string ShowButtonTextureDisabled = "ReplaceableTextures/CommandButtonsDisabled/DISBTNDustOfAppearance"
        // show the showButton only when the inventory is shown?
        public boolean ShowButtonNeedsInventory = true

        // showButton closes the UI when clicked while the UI is shown?
        public boolean ShowButtonCloses = true
        

        private real TooltipWidth = 0.27
        public real TooltipScale = 1.0
        public boolean TooltipFixedPosition = true
        private real TooltipFixedPositionX = 0.79
        private real TooltipFixedPositionY = 0.16
        private framepointtype TooltipFixedPositionPoint = FRAMEPOINT_BOTTOMRIGHT

        public boolean MoveUsedItemsIntoBag = false

        // Can drop Items from the TasItemBag regardless of item/Inventory Flags
        public boolean IgnoreUndropAble = true

        // Units with the Locust skill do not move gained items into the bag
        public boolean IgnoreDummy = true
        private integer DummySkill = 'Aloc'

        // DestroyUndropAbleItems = true, When by death an undropable item would have to be droped from the TasItemBag, it is destroyed.
        private boolean DestroyUndropAbleItems = true
        
        // ItemBagSize is the maximum amount of items, an unit can carry in the bag, additional items are droped on pickup
        private integer ItemBagSize = 9999

        // can Equip only EquipClassLimit of one Item Class at one time
        public integer EquipClassLimit = 999

        // An unit that can not use Items (cause of it's inventory skills) does not need to fullfill the requirments
        private boolean IgnoreNeedWhenCanNotUse = true

        // Display the requirements in the Item Tooltip
        public boolean AddNeedText = true

        // ItemLevelRestriction = true; only a hero which level is equal or higher to the item's level can equip it
        private boolean ItemLevelRestriction = true

        //itemCode Require the unit to have ability X to equip
        //itemCode = AbilityCode
        public Table ItemAbilityNeed
        public Table ItemIsInBag
        public HashTable BagItem

        private abilityintegerlevelfield AbilityFieldDrop
        private abilityintegerlevelfield AbilityFieldUse
        private abilityintegerlevelfield AbilityFieldCanDrop
        public timer TimerUpdate
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
        public trigger TriggerUISplit
        public trigger TriggerUISplitAccept
        public trigger TriggerUISplitMinus
        public trigger TriggerUISplitPlus
        public trigger TriggerUISplitCancel
        public trigger TriggerUIHover
        public trigger TriggerUIPanelHover
        public trigger TriggerUIMouseUp
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
        public unit array Selected
        public boolean array IgnoreNextSelection
        // The UI moves all picked up items into the bag, RpgCustomUI.EquipNow = true prevents that
        public boolean EquipNow = false

        // Split UI state (per-player)
        public integer array SplitRequested
        public integer array SplitAmount

        // Charged item stack cap (assumption for now).
        // Some items may need custom caps later; keep this centralized.
        private constant integer DEFAULT_MAX_CHARGES = 20

        // Debug toggle: when true, prints key bag interaction events.
        private constant boolean DEBUG_MODE = false

        // Swap highlight (per-player): shows an autocast-like border on the source slot while swap is armed
        private framehandle array SwapHighlight

        private constant string SplitLabelPrefix = "|cffffcc00Split:|r "

        private unit array ItemGainTimerUnit
        private timer ItemGainTimer
        private item array ItemGainTimerItem
        private integer ItemGainTimerCount = 0

    endglobals

    private function DebugMsg takes player p, string s returns nothing
        if DEBUG_MODE then
            call DisplayTimedTextToPlayer(p, 0, 0, 6.0, s)
        endif
    endfunction


    private function SwapHighlightHide takes integer pId returns nothing
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


    // Per-player bank key helper
    private function BankKeyForUnit takes unit u returns integer
        return GetPlayerId(GetOwningPlayer(u))
    endfunction

    private function IsBankUnit takes unit u returns boolean
        return GetUnitTypeId(u) == 'n002'
    endfunction

    // --- Holes-based bag helpers (fixed 24 slots) ---
    private function BagSlotCount takes integer playerKey returns integer
        local integer c = 0
        local integer s = 1
        loop
            exitwhen s > Cols * Rows
            if BagItem[playerKey].item[s] != null then
                set c = c + 1
            endif
            set s = s + 1
        endloop
        return c
    endfunction

    private function BagFindFirstEmpty takes integer playerKey returns integer
        local integer s = 1
        loop
            exitwhen s > Cols * Rows
            if BagItem[playerKey].item[s] == null then
                return s
            endif
            set s = s + 1
        endloop
        return 0
    endfunction

    function TasItemBagAddItemEx takes unit u, item i, boolean allowMerge returns nothing
        local integer playerKey = BankKeyForUnit(u)
        local location itemIsland = GetRectCenter(gg_rct_ISLAND_ITEMS)
        local integer targetSlot
        local integer itemCode
        local integer incomingCharges
        local integer loopA
        local item existing
        local integer existingCharges
        local integer addCharges
        local integer beforeCharges
        local integer afterCharges
        local integer absorbed
        local integer remaining
        local integer maxCharges
        local integer space
        // Move banked items to the island and mark with custom value > 0
        call SetItemPositionLoc(i, itemIsland)
        call SetItemUserData(i, 1)

        if allowMerge then
            // Stack consumable charges into an existing item of the same type (if possible)
            // Only applies to charged consumables.
            set incomingCharges = GetItemCharges(i)
            if incomingCharges > 0 and GetItemType(i) == ITEM_TYPE_CHARGED then
                // Standardize max stack size for all charged consumables.
                set maxCharges = 20
                if incomingCharges > maxCharges then
                    set incomingCharges = maxCharges
                    call SetItemCharges(i, incomingCharges)
                endif
                set itemCode = GetItemTypeId(i)
                // Holes-based: scan all 24 slots for merge targets
                set loopA = Cols * Rows
                loop
                    exitwhen loopA <= 0 or incomingCharges <= 0
                    set existing = BagItem[playerKey].item[loopA]
                    if existing != null and GetItemTypeId(existing) == itemCode and GetItemCharges(existing) > 0 then
                        // Clamp existing stack too (in case it was already over).
                        set existingCharges = GetItemCharges(existing)
                        if existingCharges > maxCharges then
                            set existingCharges = maxCharges
                            call SetItemCharges(existing, existingCharges)
                        endif

                        // Add up to available space in this stack.
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

                        // Determine how many charges were actually absorbed.
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
                    set loopA = loopA - 1
                endloop
                // Fully merged -> remove the incoming item
                if incomingCharges <= 0 then
                    call RemoveItem(i)
                    call RemoveLocation(itemIsland)
                    set existing = null
                    return
                endif
                // Partially merged -> keep remaining charges on the incoming item before storing it
                call SetItemCharges(i, incomingCharges)
            endif
        endif

        // Holes-based storage: place into the first empty slot (1..24)
        if not ItemIsInBag.boolean[GetHandleId(i)] then
            set targetSlot = BagFindFirstEmpty(playerKey)
            if targetSlot > 0 then
                set ItemIsInBag.boolean[GetHandleId(i)] = true
                call SetItemVisible(i, false)
                set BagItem[playerKey].item[targetSlot] = i
            else
                // Bank is full (no empty slots). Keep item in world and unmark it.
                call SetItemUserData(i, 0)
                call SetItemVisible(i, true)
                call ErrorMessage("Bank is full.", GetOwningPlayer(u))
            endif
        elseif ItemIsInBag.boolean[GetHandleId(i)] then
            call SetItemVisible(i, false)
        endif
        call RemoveLocation(itemIsland)
    endfunction

    function TasItemBagAddItem takes unit u, item i returns nothing
        call TasItemBagAddItemEx(u, i, true)
    endfunction

    function TasItemBagGetItem takes unit u, integer index returns item
        local integer playerKey = BankKeyForUnit(u)    
        return BagItem[playerKey].item[index]    
    endfunction
    
    function TasItemBagSwap takes unit u, integer indexA, integer indexB returns boolean
        local integer playerKey = BankKeyForUnit(u)
        local item i
        local item i2
        if indexA <= 0 or indexB <= 0 then
            return false
        endif
        if indexA > Cols * Rows or indexB > Cols * Rows then
            return false
        endif
        set i = BagItem[playerKey].item[indexA]
        set i2 = BagItem[playerKey].item[indexB]
        // Allow swapping with empty slots (move)
        set BagItem[playerKey].item[indexB] = i
        set BagItem[playerKey].item[indexA] = i2
        set i = null
        set i2 = null
        return true
    endfunction

    function TasItemBagRemoveIndex takes unit u, integer index, boolean drop returns boolean
        local item i
        local integer playerKey = BankKeyForUnit(u)
        local location dropSpot = GetUnitLoc(u)
        if index <= 0 or index > Cols * Rows then
            return false
        endif
        set i = BagItem[playerKey].item[index]
        if i == null then
            return false
        endif
        // Holes-based removal: clear this slot; do not compact
        set BagItem[playerKey].item[index] = null
        set ItemIsInBag.boolean[GetHandleId(i)] = false
        if drop and GetHandleId(i) > 0 then
            // Place dropped-from-bank items on the island and mark them to avoid cleanup
            set dropSpot = GetUnitLoc(u)
            call SetItemPositionLoc(i, dropSpot)
            call SetItemUserData(i, 0)
            call SetItemVisible(i, true)
            call RemoveLocation(dropSpot)
            set i = null
            return true
        endif
        set i = null
        return false
    endfunction

    function TasItemBagRemoveItem takes unit u, item i, boolean drop returns boolean
        local integer playerKey = BankKeyForUnit(u)
        local integer loopA = Cols * Rows
        // loop all items in the bag and remove it if found
        loop
            exitwhen loopA <= 0
            if BagItem[playerKey].item[loopA] == i then
                call TasItemBagRemoveIndex(u, loopA, drop)
                return true
            endif
            set loopA = loopA - 1
        endloop

        return false
    endfunction

    private function FrameLoseFocus takes nothing returns nothing
        if GetLocalPlayer() == GetTriggerPlayer() then
            call BlzFrameSetEnable(BlzGetTriggerFrame(), false)
            call BlzFrameSetEnable(BlzGetTriggerFrame(), true)
        endif
    endfunction

    public function TasItemBagUnitCanUseItems takes unit u returns boolean
        // check for the USE flag
        if GetUnitAbilityLevel(u, 'AInv') > 0 and BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, 'AInv'), AbilityFieldUse, 0) > 0 then
            return true
        endif

        return false
    endfunction

    public function TasItemBagUnitIsDropItems takes unit u returns boolean
        // check for the DROP flag
        if GetUnitAbilityLevel(u, 'AInv') > 0 and BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, 'AInv'), AbilityFieldDrop, 0) > 0 then
            return true
        endif

        return false
    endfunction
    
    private function DropsOnDeath takes unit u returns boolean
        local integer i = 0
        if not IsUnitType(u, UNIT_TYPE_HERO) then
            return true
        endif
        if TasItemBagUnitIsDropItems(u) then
            return true
        endif
    
        return false
    endfunction

    private function CountItemsOfClass takes unit u, itemtype itemClass returns integer
        local integer count = 0
        local integer i = 0
        loop
            exitwhen i >= bj_MAX_INVENTORY
            if GetItemType(UnitItemInSlot(u, i)) == itemClass then
                set count = count + 1
            endif
            set i = i + 1
        endloop
        return count
    endfunction

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
        if IgnoreNeedWhenCanNotUse and not TasItemBagUnitCanUseItems(u) then
            return true
        endif
        // use Item Level as requirement. A lower Level can not equip it
        if ItemLevelRestriction and TasItemBagUnitCanUseItems(u) and GetUnitLevel(u) < GetItemLevel(i) then
            call DisplayTimedTextToPlayer(GetOwningPlayer(u), 0, 0, 20, GetItemName(i) + " needs " + GetLocalizedString("LEVEL") + " " + I2S(GetItemLevel(i)))
            set returnValue = false
        endif
        // itemCode can require an ability
        if ItemAbilityNeed[itemCode] != 0 and GetUnitAbilityLevel(u, ItemAbilityNeed[itemCode]) == 0 then
            call DisplayTimedTextToPlayer(GetOwningPlayer(u), 0, 0, 20, GetItemName(i) + " needs Ability " + GetObjectName(ItemAbilityNeed[itemCode]))
            set returnValue = false
        endif
        if EquipClassLimit <= CountItemsOfClass(u, GetItemType(i)) then
            call DisplayTimedTextToPlayer(GetOwningPlayer(u), 0, 0, 20, "To many Items of this Item-Class")
            return false
        endif
        return returnValue
    endfunction

    private function ItemBag2Equip takes player p, item i returns nothing
        local unit u = udg_Heroes[GetPlayerNumber(p)]
        local integer pId = GetPlayerId(p)
        local integer bagIndex = TransferIndex[pId]
        local item slotItem
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
            if i != null and GetItemType(i) == ITEM_TYPE_CHARGED and GetItemCharges(i) > 0 then
                set maxCharges = 20
                set incomingCharges = GetItemCharges(i)
                if incomingCharges > maxCharges then
                    set incomingCharges = maxCharges
                endif
                set slot = 0
                loop
                    exitwhen slot >= bj_MAX_INVENTORY or incomingCharges <= 0
                    set invItem = UnitItemInSlot(u, slot)
                    if invItem != null and GetItemType(invItem) == ITEM_TYPE_CHARGED and GetItemTypeId(invItem) == GetItemTypeId(i) then
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
                        // Fully absorbed into an inventory stack; clear the originating bag slot.
                        if bagIndex > 0 and bagIndex <= Cols * Rows then
                            set slotItem = BagItem[pId].item[bagIndex]
                            if slotItem != null and GetItemTypeId(slotItem) == GetItemTypeId(i) then
                                call TasItemBagRemoveIndex(u, bagIndex, false)
                            else
                                call TasItemBagRemoveItem(u, i, false)
                            endif
                        else
                            call TasItemBagRemoveItem(u, i, false)
                        endif
                    else
                        // Partially absorbed; keep the bank item with remaining charges.
                        call SetItemCharges(i, incomingCharges)
                        call SetItemVisible(i, false)
                    endif
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
     
        set EquipNow = true
        // Make the item visible and place it at the hero before equipping
        call SetItemVisible(i, true)
        call SetItemPosition(i, GetUnitX(u), GetUnitY(u))
        call Debug("Item to be equipped from Bank: " + GetItemName(i) + GetUnitName(u))
        if UnitAddItem(u, i) then
            // Holes-based bag: if the add succeeded, clear the originating slot.
            // Don't rely on handle equality (charged stacking can delete/merge handles).
            if bagIndex > 0 and bagIndex <= Cols * Rows then
                call TasItemBagRemoveIndex(u, bagIndex, false)
            else
                call TasItemBagRemoveItem(u, i, false)
            endif
        endif
        set EquipNow = false
        set u = null
    endfunction

    private function ItemEquip2Bag takes unit u, item i returns nothing
        // Ensure item is removed from the unit's inventory before stashing.
        // With holes-based banking (and charged-item stacking), leaving it in inventory can cause
        // WC3 inventory auto-merge/remove behavior to double-handle the same item.
        if UnitHasItem(u, i) then
            call UnitRemoveItem(u, i)
        endif
        call TasItemBagAddItem(u, i)
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
        if BagFindFirstEmpty(playerKey) <= 0 then
            call ErrorMessage("Bank is full.", p)
            set it = null
            return
        endif
        call ItemEquip2Bag(hero, it)
        set it = null
        set hero = null
    endfunction

    private function BagPopupActionDrop takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        if GetPlayerAlliance(GetOwningPlayer(Selected[pId]), p, ALLIANCE_SHARED_CONTROL) then
            if GetLocalPlayer() == p then
                call BlzFrameSetVisible(BlzFrameGetParent(BlzGetTriggerFrame()), false)
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            endif
        endif
        call TasItemBagRemoveIndex(Selected[pId], TransferIndex[pId], true)
        call FrameLoseFocus()
    endfunction

    private function BagPopupActionEquip takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(GetTriggerPlayer())
        if GetPlayerAlliance(GetOwningPlayer(Selected[pId]), p, ALLIANCE_SHARED_CONTROL) then
            call ItemBag2Equip(p, TransferItem[pId])
            if GetLocalPlayer() == p then
                call BlzFrameSetVisible(BlzFrameGetParent(BlzGetTriggerFrame()), false)
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            endif
        endif
        call FrameLoseFocus()
    endfunction

    private function BagPopupActionSwap takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(GetTriggerPlayer())
        if GetPlayerAlliance(GetOwningPlayer(Selected[pId]), p, ALLIANCE_SHARED_CONTROL) then
            if GetLocalPlayer() == p then
                call BlzFrameSetVisible(BlzFrameGetParent(BlzGetTriggerFrame()), false)
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            endif
            set SwapIndex[pId] = TransferIndex[pId]
            call SwapHighlightShowOnSlot(pId, SwapIndex[pId])
        endif
        call FrameLoseFocus()
    endfunction

    private function BagPopupActionSplit takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local item it
        local integer charges
        if GetPlayerAlliance(GetOwningPlayer(Selected[pId]), p, ALLIANCE_SHARED_CONTROL) then
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

        // Ensure bank has room for a new item (or stacking will absorb it).
        set playerKey = GetPlayerId(p)
        if BagFindFirstEmpty(playerKey) <= 0 then
            call ErrorMessage("Bank is full.", p)
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
        call TasItemBagAddItemEx(udg_Heroes[GetPlayerNumber(p)], newItem, false)
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

        // call Debug("BagButtonAction triggered")
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
        if not GetPlayerAlliance(GetOwningPlayer(Selected[pId]), p, ALLIANCE_SHARED_CONTROL) then
            set hero = null
            return
        endif

        if evt == FRAMEEVENT_CONTROL_CLICK then
            // If we're in swap mode, finalize swap on click.
            if SwapIndex[pId] > 0 then
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
                    call TasItemBagSwap(Selected[pId], SwapIndex[pId], bagIndex)
                    set SwapIndex[pId] = 0
                    call SwapHighlightHide(pId)
                    if GetLocalPlayer() == p then
                        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
                        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
                    endif
                endif
            else
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
                    set TransferItem[pId] = BagItem[pId].item[bagIndex]
                    if TransferItem[pId] != null then
                        if GetLocalPlayer() == p then
                            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), true)
                            call BlzFrameClearAllPoints(BlzGetFrameByName("TasItemBagPopUpPanel", 0))
                            call BlzFrameSetPoint(BlzGetFrameByName("TasItemBagPopUpPanel", 0), FRAMEPOINT_TOPLEFT, BlzGetFrameByName("TasItemBagSlot", rawIndex), FRAMEPOINT_TOPRIGHT, 0.004, 0)

                            // Split button only for charged items with charges > 1
                            set itemCharges = GetItemCharges(TransferItem[pId])
                            set itemType = GetItemType(TransferItem[pId])
                            if itemType == ITEM_TYPE_CHARGED and itemCharges > 1 then
                                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpButtonSplit", 0), true)
                            else
                                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpButtonSplit", 0), false)
                            endif
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
        local integer rawIdx

        // call Debug("HoverAction triggered")
        // Prefer numeric text when present (slot button), else resolve by frame handle (backdrop/container)
        if BlzFrameGetText(BlzGetTriggerFrame()) != "" then
            set btnIndex = S2I(BlzFrameGetText(BlzGetTriggerFrame()))
            set rawIdx = btnIndex
        else
            set rawIdx = ResolveBagSlotIndex(BlzGetTriggerFrame())
            set btnIndex = rawIdx
        endif
        if rawIdx > 0 then
            set LastHoveredIndex[pId] = rawIdx
            set PanelHover[pId] = true
            // call Debug("Hover: player " + I2S(pId) + " hovered slot " + I2S(LastHoveredIndex[pId]))
            if DragActive[pId] then
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

        // call Debug("HoverLeaveAction triggered")
        // Clear overlay text if leaving the button; do not flip PanelHover here
        if BlzFrameGetText(BlzGetTriggerFrame()) != "" then
            set btnIndex = S2I(BlzFrameGetText(BlzGetTriggerFrame()))
            if DragActive[pId] then
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", btnIndex), "")
            endif
        endif
        // Only clear LastHoveredIndex if the panel itself is not hovered
        if not PanelHover[pId] then
            set LastHoveredIndex[pId] = 0
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
        set PanelHover[pId] = false
        // call Debug("BagPanelLeaveAction LEAVE")
    endfunction

    // Global mouse up handler: right-click = withdraw, left-click = popup
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

        call DebugMsg(p, "[Bag] MOUSE_UP fired")

        // Ignore any clicks when bank panel is not open
        if not BlzFrameIsVisible(BlzGetFrameByName("TasItemBagPanel", 0)) then
            call DebugMsg(p, "[Bag] ignored: panel not visible")
            return
        endif

        if PanelHover[pId] then
            set panelStr = "true"
        else
            set panelStr = "false"
        endif
        call Debug("Global MOUSE_UP: invIndex=" + I2S(invIndex) + ", LastHoveredIndex=" + I2S(LastHoveredIndex[pId]) + ", PanelHover=" + panelStr)

        if btn == MOUSE_BUTTON_TYPE_RIGHT then
            call DebugMsg(p, "[Bag] RIGHT click")
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
            // Right-click: A) deposit when over inventory, B) quick withdraw when over bag
            if invIndex >= 0 and invIndex < bj_MAX_INVENTORY then
                if GetPlayerAlliance(GetOwningPlayer(Selected[pId]), p, ALLIANCE_SHARED_CONTROL) then
                    call Debug("Deposit: inventory slot " + I2S(invIndex) + " -> bank")
                    call DebugMsg(p, "[Bag] deposit inv slot " + I2S(invIndex))
                    call DepositInventorySlot(p, invIndex)
                    set didSomething = true
                endif
            else
                // Do not depend on PanelHover; resolve by mouse position first.
                set rawIdx = ResolveBagIndexFromMouse()
                if rawIdx <= 0 and targetIndex > 0 then
                    set rawIdx = targetIndex
                endif
                set bagIndex = rawIdx
                if bagIndex > 0 and bagIndex <= Cols * Rows then
                    set bi = BagItem[pId].item[bagIndex]
                    if bi != null then
                        call Debug("Withdraw (global right-click): rawIdx=" + I2S(rawIdx) + ", bagIndex=" + I2S(bagIndex))
                        call DebugMsg(p, "[Bag] withdraw slot " + I2S(bagIndex))
                        set TransferIndex[pId] = bagIndex
                        set TransferItem[pId] = bi
                        call ItemBag2Equip(p, bi)
                        set didSomething = true
                    else
                        call DebugMsg(p, "[Bag] withdraw blocked: empty slot " + I2S(bagIndex))
                    endif
                else
                    call DebugMsg(p, "[Bag] click not on bag grid")
                endif
            endif
            // If the click was not on inventory or bag, do nothing (let it be a move order, etc.)
            if not didSomething then
                call DebugMsg(p, "[Bag] no action taken")
                return
            endif
            // Reset drag only when we actually handled the click
            set DragOriginType[pId] = 0
            set DragOriginIndex[pId] = 0
            set DragActive[pId] = false
            call FrameLoseFocus()
        endif
    endfunction
    
    private function WheelAction takes nothing returns nothing
        // Holes-based bag: fixed 24 slots, no wheel scrolling
    endfunction

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
            if BlzFrameIsVisible(BlzGetFrameByName("TasItemBagPanel", 0)) then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), false)
            else
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), true)
            endif
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
        endif
        set SwapIndex[GetPlayerId(p)] = 0
        call SwapHighlightHide(GetPlayerId(p))
        call FrameLoseFocus()
    endfunction

    private function UpdateUI takes nothing returns nothing
        local integer pId = GetPlayerId(GetLocalPlayer())
        local integer itemCount = BagSlotCount(pId)
        local integer itemCode
        local item it
        local string text = ""
        local integer i
        // When the options from HeroScoreFrame are in this map use the tooltip&total scale slider
        if GetHandleId(BlzGetFrameByName("HeroScoreFrameOptionsSlider1", 0)) > 0 then
            set TooltipScale = BlzFrameGetValue(BlzGetFrameByName("HeroScoreFrameOptionsSlider1", 0))
        endif
        if GetHandleId(BlzGetFrameByName("HeroScoreFrameOptionsSlider3", 0)) > 0 then
            call BlzFrameSetScale(BlzGetFrameByName("TasItemBagPanel", 0), BlzFrameGetValue(BlzGetFrameByName("HeroScoreFrameOptionsSlider3", 0)))
        endif

        call BlzFrameSetScale(BlzGetFrameByName("TasItemBagTooltipPanel", 0), TooltipScale)
        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlot", 0), not ShowButtonNeedsInventory or BlzFrameIsVisible(BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, 0)))
        call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", 0), I2S(itemCount))

        if BlzFrameIsVisible(BlzGetFrameByName("TasItemBagPanel", 0)) then    

            // Holes-based bag: fixed 24 slots, no scrolling
            call BlzFrameSetMinMaxValue(BlzGetFrameByName("TasItemBagSlider", 0), 0, 0)
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSliderTooltip", 0), "")

            set i = 1
            loop
                exitwhen i > Cols * Rows
                set it = BagItem[pId].item[i]
                call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButton", i), it != null)
                if it != null then
                    set itemCode = GetItemTypeId(it)
                    call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", i), BlzGetAbilityIcon(itemCode), 0, true)
                    call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", i), BlzGetAbilityIcon(itemCode), 0, true)
                    if AddNeedText then
                        set text = "|nNEED " + GetLocalizedString("REQUIREDLEVELTOOLTIP") + " " + I2S(GetItemLevel(it))
                        if ItemAbilityNeed[itemCode] > 0 then
                            set text = text + "|nNEED " + GetObjectName(ItemAbilityNeed[itemCode])
                        endif
                    endif

                    call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonTooltip", i), GetObjectName(itemCode) + "|n" + BlzGetAbilityExtendedTooltip(itemCode, 0) + "|n|n" + text)
                
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
            if ShowButtonCloses and BlzFrameIsVisible(BlzGetFrameByName("TasItemBagPanel", 0)) then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), false)
            else
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), true)
            endif
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            // Quick Deposit: click handling disabled for now
            // set s = 0
            // loop
            //     exitwhen s >= bj_MAX_INVENTORY
            //     if BlzGetFrameByName("TasBankDeposit" + I2S(s), 0) == BlzGetTriggerFrame() then
            //         call DepositInventorySlot(Player(pId), s)
            //         exitwhen true
            //     endif
            //     set s = s + 1
            // endloop
        endif
        call FrameLoseFocus()
    endfunction

    private function SliderAction takes nothing returns nothing
        // Holes-based bag: fixed 24 slots, no slider scrolling
        set Offset[GetPlayerId(GetTriggerPlayer())] = 0
    endfunction

    private function SelectAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        if IgnoreNextSelection[pId] then
            set IgnoreNextSelection[pId] = false
            return
        endif
        set Selected[pId] = GetTriggerUnit()
        set Offset[pId] = 0
        // Open banking UI when a Bank unit is selected
        if IsBankUnit(Selected[pId]) then
            if GetLocalPlayer() == GetTriggerPlayer() then
                // Update once before showing to avoid a one-frame flash of stale/null slot data
                call UpdateUI()
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), true)
                // Auto-reselect the hero so their inventory is visible while banking
                set IgnoreNextSelection[pId] = true
                call SelectUnitForPlayerSingle(udg_Heroes[GetPlayerNumber(GetTriggerPlayer())], GetTriggerPlayer())
            endif
        endif
    endfunction

    private function ESCAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        // WoW-like: ESC cancels swap first, then closes UI on subsequent ESC
        if SwapIndex[pId] > 0 then
            set SwapIndex[pId] = 0
            call SwapHighlightHide(pId)
            if GetLocalPlayer() == GetTriggerPlayer() then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSplitPanel", 0), false)
            endif
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
                call ItemEquip2Bag(ItemGainTimerUnit[ItemGainTimerCount], ItemGainTimerItem[ItemGainTimerCount])
            endif
            set ItemGainTimerCount = ItemGainTimerCount - 1
        endloop
    endfunction

    private function ItemGainAction takes nothing returns nothing
        // dummies do not use the bag feature
        if IgnoreDummy and GetUnitAbilityLevel(GetTriggerUnit(), DummySkill) > 0 then 
            return
        endif
        // Banking change: only process pickups when the Bank unit picks up items (drag-drop deposit)
        // if not IsBankUnit(GetTriggerUnit()) then
        //     return
        // endif

        // Do not move Powerups that can be used into the bag
        if IsItemPowerup(GetManipulatedItem()) and TasItemBagUnitCanUseItems(GetTriggerUnit()) then 
            return
        endif

        // Original behavior: move picked up items into the bag for regular pickups.
        // Guard with EquipNow so using the Equip button does not re-stash the item.
        if not EquipNow then
            // dont move it instantly, delay it with a 0s timer, this stops item pickup orders onto the same item in a row and allows the user to do some stuff to pickedup items
            // does not prevent move ground pick up in rotation
            set ItemGainTimerCount = ItemGainTimerCount + 1
            set ItemGainTimerUnit[ItemGainTimerCount] = GetTriggerUnit()
            set ItemGainTimerItem[ItemGainTimerCount] = GetManipulatedItem()
            call TimerStart(ItemGainTimer, 0, false, function ItemGainTimerAction)
        endif
    endfunction

    private function ItemUseAction takes nothing returns nothing
        if IgnoreDummy and GetUnitAbilityLevel(GetTriggerUnit(), DummySkill) > 0 then 
            return
        endif
        if MoveUsedItemsIntoBag then
            call ItemEquip2Bag(GetTriggerUnit(), GetManipulatedItem())
        endif
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
        call BlzTriggerRegisterFrameEvent(TriggerUIWheel, panel, FRAMEEVENT_MOUSE_WHEEL)
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
            call BlzTriggerRegisterFrameEvent(TriggerUIWheel, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_MOUSE_WHEEL)
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
        // Give it a high frame level so it stays clickable over the command card.
        set frame = BlzCreateFrameByType("BUTTON", "TasItemBagPopUpPanel", panel, "", 0)
        call BlzFrameSetLevel(frame, 30)
        // Give the popup panel enough height to contain 4 buttons
        call BlzFrameSetSize(frame, 0.1, 0.12)
        set frame2 = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagPopUpButtonEquip", frame, "ScriptDialogButton", 0)
        call BlzFrameSetLevel(frame2, 31)
        call BlzFrameSetSize(frame2, 0.1, 0.03)
        call BlzFrameSetPoint(frame2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0, 0)
        call BlzFrameSetText(frame2, "EQUIP")
        call BlzTriggerRegisterFrameEvent(TriggerUIEquip, frame2, FRAMEEVENT_CONTROL_CLICK)

        set frame3 = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagPopUpButtonDrop", frame, "ScriptDialogButton", 0)
        call BlzFrameSetLevel(frame3, 31)
        call BlzFrameSetSize(frame3, 0.1, 0.03)
        call BlzFrameSetPoint(frame3, FRAMEPOINT_TOPLEFT, frame2, FRAMEPOINT_BOTTOMLEFT, 0, 0)
        call BlzFrameSetText(frame3, "DROP")
        call BlzTriggerRegisterFrameEvent(TriggerUIDrop, frame3, FRAMEEVENT_CONTROL_CLICK)

        set frame2 = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagPopUpButtonSwap", frame, "ScriptDialogButton", 0)
        call BlzFrameSetLevel(frame2, 31)
        call BlzFrameSetSize(frame2, 0.1, 0.03)
        call BlzFrameSetPoint(frame2, FRAMEPOINT_TOPLEFT, frame3, FRAMEPOINT_BOTTOMLEFT, 0, 0)
        call BlzFrameSetText(frame2, "SWAP")
        call BlzTriggerRegisterFrameEvent(TriggerUISwap, frame2, FRAMEEVENT_CONTROL_CLICK)

        // 4th popup button: Split (conditionally shown)
        set frame3 = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagPopUpButtonSplit", frame, "ScriptDialogButton", 0)
        call BlzFrameSetLevel(frame3, 31)
        call BlzFrameSetSize(frame3, 0.1, 0.03)
        call BlzFrameSetPoint(frame3, FRAMEPOINT_TOPLEFT, frame2, FRAMEPOINT_BOTTOMLEFT, 0, 0)
        call BlzFrameSetText(frame3, "SPLIT")
        call BlzTriggerRegisterFrameEvent(TriggerUISplit, frame3, FRAMEEVENT_CONTROL_CLICK)
        call BlzFrameSetVisible(frame3, false)

        // Split panel: info text + - / + / accept / cancel
        set frame2 = BlzCreateFrameByType("BACKDROP", "TasItemBagSplitPanel", panel, "EscMenuBackdrop", 0)
        // Ensure split panel is above popup menu and captures clicks
        call BlzFrameSetLevel(frame2, 20)
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
    
    private function At0s takes nothing returns nothing
        local integer i
        set AbilityFieldDrop = ConvertAbilityIntegerLevelField('inv2')
        set AbilityFieldUse = ConvertAbilityIntegerLevelField('inv3')
        set AbilityFieldCanDrop = ConvertAbilityIntegerLevelField('inv5')
        
        set ItemAbilityNeed = Table.create()
        set ItemIsInBag = Table.create()
        
        set BagItem = HashTable.create()
        set TimerUpdate = CreateTimer()
        call TimerStart(TimerUpdate, 0.1, true, function UpdateUI)
        
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

        set TriggerItemUse = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(TriggerItemUse, EVENT_PLAYER_UNIT_USE_ITEM)
        call TriggerAddAction(TriggerItemUse, function ItemUseAction)

        set TriggerUIOpen = CreateTrigger()
        call TriggerAddAction(TriggerUIOpen, function ShowButtonAction)

        set TriggerUIClose = CreateTrigger()
        call TriggerAddAction(TriggerUIClose, function CloseButtonAction)

        set TriggerUIBagButton = CreateTrigger()
        call TriggerAddAction(TriggerUIBagButton, function BagButtonAction)

        set TriggerUISlider = CreateTrigger()
        call TriggerAddAction(TriggerUISlider, function SliderAction)

        set TriggerUIWheel = CreateTrigger()
        call TriggerAddAction(TriggerUIWheel, function WheelAction)

        // Legacy popup triggers (events registered in InitFrames after frames are created)
        set TriggerUIEquip = CreateTrigger()
        call TriggerAddAction(TriggerUIEquip, function BagPopupActionEquip)

        set TriggerUIDrop = CreateTrigger()
        call TriggerAddAction(TriggerUIDrop, function BagPopupActionDrop)

        set TriggerUISwap = CreateTrigger()
        call TriggerAddAction(TriggerUISwap, function BagPopupActionSwap)

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

        // Hover tracking for slot buttons
        set TriggerUIHover = CreateTrigger()
        call TriggerAddAction(TriggerUIHover, function HoverAction)
        call TriggerAddAction(TriggerUIHover, function HoverLeaveAction)

        // Panel hover tracking trigger
        set TriggerUIPanelHover = CreateTrigger()
        call TriggerAddAction(TriggerUIPanelHover, function BagPanelEnterAction)
        call TriggerAddAction(TriggerUIPanelHover, function BagPanelLeaveAction)

        // Global mouse handlers (used for inventory deposit and diagnostics)
        set TriggerUIMouseUp = CreateTrigger()
        call RegisterAnyPlayerEvent(EVENT_PLAYER_MOUSE_UP, function GlobalMouseUpAction)

        // Note: Global mouse right-click detection removed for compatibility.

        // call UserInit()
        call InitFrames()
        static if LIBRARY_FrameLoader then
            call FrameLoaderAdd(function InitFrames)
        endif
    endfunction
    
    private function init_function takes nothing returns nothing
        set ItemGainTimer = CreateTimer()
        call TimerStart(ItemGainTimer, 0, false, function At0s)        

    endfunction
endlibrary
