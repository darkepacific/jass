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
        private real PosX = 0.4
        private real PosY = 0.57
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


        // InventorySkills are the Inventory Abilities in the used map
        // They are used for drop on death
        public integer array InventorySkills 

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
        public trigger TriggerUIHover
        public trigger TriggerUIPanelHover
        public trigger TriggerUIMouseUp
        public trigger TriggerUIMouseDown
        public integer array LastHoveredIndex
        // Drag tracking: origin type 0:none, 1:inventory slot, 2:bag slot
        public integer array DragOriginType
        public integer array DragOriginIndex
        public boolean array DragActive
        public boolean array PanelHover
        // Right-click is handled via frame events (MOUSE_UP/DOWN) within BagButtonAction
    
        // TransferItem remembers the current Target
        public item array TransferItem
        public integer array TransferIndex
        public integer array SwapIndex
        public integer array Offset
        public unit array Selected
        public boolean array IgnoreNextSelection
        // The UI moves all picked up items into the bag, RpgCustomUI.EquipNow = true prevents that
        public boolean EquipNow = false

        private unit array ItemGainTimerUnit
        private timer ItemGainTimer
        private item array ItemGainTimerItem
        private integer ItemGainTimerCount = 0

    endglobals


    // Per-player bank key helper
    private function BankKeyForUnit takes unit u returns integer
        return GetPlayerId(GetOwningPlayer(u))
    endfunction


    private function IsBankUnit takes unit u returns boolean
        return GetUnitTypeId(u) == 'n002'
    endfunction

    private function UserInit takes nothing returns nothing
        set InventorySkills[0] = 'AInv'
        set InventorySkills[1] = 'Apak'
        set InventorySkills[2] = 'Aiun'
        set InventorySkills[3] = 'Aien'
        set InventorySkills[4] = 'Aihn'
        set InventorySkills[5] = 'Aion'
    endfunction

    function TasItemBagAddItem takes unit u, item i returns nothing
        local integer playerKey = BankKeyForUnit(u)
        local location itemIsland = GetRectCenter(gg_rct_ISLAND_ITEMS)
        // Move banked items to the island and mark with custom value > 0
        call SetItemPositionLoc(i, itemIsland)
        call SetItemUserData(i, 1)
        if not ItemIsInBag.boolean[GetHandleId(i)] and BagItem[playerKey].integer[0] < ItemBagSize then
            set BagItem[playerKey].integer[0] = BagItem[playerKey].integer[0] + 1
            set ItemIsInBag.boolean[GetHandleId(i)] = true
            call SetItemVisible(i, false)
            set BagItem[playerKey].item[BagItem[playerKey].integer[0]] = i
        elseif ItemIsInBag.boolean[GetHandleId(i)] then
            call SetItemVisible(i, false)
        endif
        call RemoveLocation(itemIsland)
    endfunction

    function TasItemBagGetItem takes unit u, integer index returns item
        local integer playerKey = BankKeyForUnit(u)    
        if BagItem[playerKey].integer[0] <= 0 then
            return null
        endif
        return BagItem[playerKey].item[index]    
    endfunction
    
    function TasItemBagSwap takes unit u, integer indexA, integer indexB returns boolean
        local integer playerKey = BankKeyForUnit(u)
        local item i
        local item i2
        if BagItem[playerKey].integer[0] <= 0 then
            return false
        endif
        if indexA <= 0 or indexB <= 0 then
            return false
        endif
        set i = BagItem[playerKey].item[indexA]
        set i2 = BagItem[playerKey].item[indexB]
        if GetHandleId(i) > 0 and GetHandleId(i2) > 0 then
            set BagItem[playerKey].item[indexB] = i
            set BagItem[playerKey].item[indexA] = i2
            set i = null
            set i2 = null
            return true
        endif
        set i = null
        set i2 = null
        return false
    endfunction

    function TasItemBagRemoveIndex takes unit u, integer index, boolean drop returns boolean
        local item i
        local integer playerKey = BankKeyForUnit(u)
        local location dropSpot = GetUnitLoc(u)
        if BagItem[playerKey].integer[0] <= 0 then
            return false
        endif
    
        set i = BagItem[playerKey].item[index]
        set BagItem[playerKey].item[index] = BagItem[playerKey].item[BagItem[playerKey].integer[0]]
        set BagItem[playerKey].item[BagItem[playerKey].integer[0]] = null
        set BagItem[playerKey].integer[0] = BagItem[playerKey].integer[0] - 1   
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
        local integer loopA = BagItem[playerKey].integer[0]
        if loopA <= 0 then
            return false
        endif
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
        // check all Inventory skills for the USE flag
        local integer i = 0
        loop    
            exitwhen InventorySkills[i] == 0 
            if GetUnitAbilityLevel(u, InventorySkills[i]) > 0 and BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, InventorySkills[i]), AbilityFieldUse, 0) > 0 then
                return true
            endif
            set i = i + 1
        endloop

        return false
    endfunction

    public function TasItemBagUnitIsDropItems takes unit u returns boolean
        // check all Inventory skills for the DROP flag
        local integer i = 0
        loop    
            exitwhen InventorySkills[i] == 0 
            if GetUnitAbilityLevel(u, InventorySkills[i]) > 0 and BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, InventorySkills[i]), AbilityFieldDrop, 0) > 0 then
                return true
            endif
            set i = i + 1
        endloop

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
        // check all Inventory skills for the DROP flag
        local integer i = 0
        loop    
            exitwhen InventorySkills[i] == 0 
            if GetUnitAbilityLevel(u, InventorySkills[i]) > 0 and BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(u, InventorySkills[i]), AbilityFieldCanDrop, 0) == 0 then
                return false
            endif
            set i = i + 1
        endloop

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
        // Inventory Full?
        if UnitInventoryCount(u) >= UnitInventorySize(u) then
            call ErrorMessage("Inventory is full.", GetOwningPlayer(u))
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
            call TasItemBagRemoveItem(u, i, false)
        endif
        set EquipNow = false
        set u = null
    endfunction

    private function ItemEquip2Bag takes unit u, item i returns nothing
        // Ensure item is removed from the unit's inventory before stashing
        // if UnitHasItem(u, i) then
        //     call UnitRemoveItem(u, i)
        // endif
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
        if BagItem[playerKey].integer[0] >= ItemBagSize then
            call ErrorMessage("Bank is full.", p)
            set it = null
            set hero = null
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
            endif
            set SwapIndex[pId] = TransferIndex[pId]
        endif
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
        local string dragStr
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
        set bagIndex = rawIndex + Offset[pId]
        set hero = udg_Heroes[GetPlayerNumber(p)]
        if not GetPlayerAlliance(GetOwningPlayer(Selected[pId]), p, ALLIANCE_SHARED_CONTROL) then
            set hero = null
            return
        endif

        // Right-click: show legacy popup menu (Equip/Drop/Swap)
        if evt == FRAMEEVENT_MOUSE_DOWN then
            set mouseButton = BlzGetTriggerPlayerMouseButton()
            if mouseButton == MOUSE_BUTTON_TYPE_RIGHT then
                set btnStr = "RIGHT"
            else
                set btnStr = "LEFT"
            endif
            call Debug("BagButton MOUSE_DOWN: pId=" + I2S(pId) + ", src=" + frameSrc + ", btn=" + btnStr + ", rawIndex=" + I2S(rawIndex) + ", bagIndex=" + I2S(bagIndex))
            if mouseButton == MOUSE_BUTTON_TYPE_RIGHT then
                set TransferIndex[pId] = bagIndex
                set TransferItem[pId] = BagItem[pId].item[bagIndex]
                // Only show popup when this slot has an item
                if TransferItem[pId] != null then
                    if GetLocalPlayer() == p then
                        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), true)
                        // Anchor popup next to the visible slot frame
                        call BlzFrameClearAllPoints(BlzGetFrameByName("TasItemBagPopUpPanel", 0))
                        call BlzFrameSetPoint(BlzGetFrameByName("TasItemBagPopUpPanel", 0), FRAMEPOINT_TOPLEFT, BlzGetFrameByName("TasItemBagSlot", rawIndex), FRAMEPOINT_TOPRIGHT, 0.004, 0)
                    endif
                else
                    call Debug("Right-click popup suppressed: empty slot at bagIndex=" + I2S(bagIndex))
                endif
            endif
        // Handle right mouse up over bag slot (no drag-stop needed when using popup)
        elseif evt == FRAMEEVENT_MOUSE_UP then
            set mouseButton = BlzGetTriggerPlayerMouseButton()
            if mouseButton == MOUSE_BUTTON_TYPE_RIGHT then
                set btnStr = "RIGHT"
            else
                set btnStr = "LEFT"
            endif
            call Debug("BagButton MOUSE_UP: pId=" + I2S(pId) + ", src=" + frameSrc + ", btn=" + btnStr + ", rawIndex=" + I2S(rawIndex) + ", bagIndex=" + I2S(bagIndex))
        // Left-click withdraw: quick equip item from bag
        elseif evt == FRAMEEVENT_CONTROL_CLICK then
            // If in swap mode, finalize swap with the clicked slot
            if SwapIndex[pId] > 0 and SwapIndex[pId] != bagIndex then
                call Debug("Swap finalize: " + I2S(SwapIndex[pId]) + " <-> " + I2S(bagIndex))
                call TasItemBagSwap(Selected[pId], SwapIndex[pId], bagIndex)
                set SwapIndex[pId] = 0
                if GetLocalPlayer() == p then
                    call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
                endif
            else
                // Default left-click: quick equip from bag
                set it = BagItem[pId].item[bagIndex]
                if it != null then
                    call Debug("Withdraw (left-click): bag index " + I2S(bagIndex))
                    call ItemBag2Equip(p, it)
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
        local integer btnIndex = S2I(BlzFrameGetText(BlzGetTriggerFrame()))
        // Guard: only slot buttons have numeric text; ignore panel hover
        if BlzFrameGetText(BlzGetTriggerFrame()) != "" then
            set LastHoveredIndex[pId] = btnIndex + Offset[pId]
            // Debug to verify hover mapping
            call Debug("Hover: player " + I2S(pId) + " hovered slot " + I2S(LastHoveredIndex[pId]))
            // Visual drag indicator on hovered slot when dragging
            if DragActive[pId] and LastHoveredIndex[pId] > 0 then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagSlotButtonOverLay", btnIndex), true)
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", btnIndex), "●")
            endif
        endif
    endfunction

    // Clear hover indicator when leaving a slot
    private function HoverLeaveAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local integer btnIndex = S2I(BlzFrameGetText(BlzGetTriggerFrame()))
        // Guard: only slot buttons have numeric text; ignore panel hover
        if BlzFrameGetText(BlzGetTriggerFrame()) != "" then
            if DragActive[pId] then
                // Restore overlay visibility will be handled in UpdateUI; just clear temp mark
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonOverLayText", btnIndex), "")
            endif
            // Leaving a slot clears hover index
            set LastHoveredIndex[pId] = 0
        endif
    endfunction

    // Panel hover enter: mark inside panel
    private function BagPanelEnterAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        set PanelHover[pId] = true
        call Debug("PanelHover ENTER: player " + I2S(pId) + ", PanelHover=true")
    endfunction

    // Panel hover leave: mark outside panel
    private function BagPanelLeaveAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        set PanelHover[pId] = false
        call Debug("PanelHover LEAVE: player " + I2S(pId) + ", PanelHover=false")
    endfunction

    // Global mouse up handler: perform swap/drop/deposit on right-click
    private function GlobalMouseUpAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local mousebuttontype btn = BlzGetTriggerPlayerMouseButton()
        local integer targetIndex = LastHoveredIndex[pId]
        local integer invIndex = HoverOriginButton_CurrentSelectedButtonIndex - HoverOriginButton_ItemButtonOffset
        local item bi
        // Ignore any clicks when bank panel is not open
        if not BlzFrameIsVisible(BlzGetFrameByName("TasItemBagPanel", 0)) then
            return
        endif
        if btn == MOUSE_BUTTON_TYPE_RIGHT then
            // Case A: Deposit from hero inventory into bank
            if invIndex >= 0 and invIndex < bj_MAX_INVENTORY then
                if GetPlayerAlliance(GetOwningPlayer(Selected[pId]), p, ALLIANCE_SHARED_CONTROL) then
                    call Debug("Deposit: inventory slot " + I2S(invIndex) + " -> bank")
                    call DepositInventorySlot(p, invIndex)
                endif
            // Case B: Swap bag-to-bag
            elseif DragOriginType[pId] == 2 and DragOriginIndex[pId] > 0 then
                // Right-click withdraw disabled: use left-click on bag slot instead
                // -// Case B1: Withdraw to hero inventory by releasing over an inventory slot
                if invIndex >= 0 and invIndex < bj_MAX_INVENTORY then
// -                    set bi = BagItem[pId].item[DragOriginIndex[pId]]
// -                    if bi != null then
// -                        call Debug("Withdraw: bag index " + I2S(DragOriginIndex[pId]) + " -> hero inventory")
// -                        call ItemBag2Equip(p, bi)
// -                        set bi = null
// -                    endif
                    call Debug("Withdraw via right-click disabled; ignoring release over inventory")
                // Case B2: Swap within bag
                elseif targetIndex > 0 and targetIndex != DragOriginIndex[pId] then
                    call Debug("Swap: bag " + I2S(DragOriginIndex[pId]) + " <-> " + I2S(targetIndex))
                    call TasItemBagSwap(Selected[pId], DragOriginIndex[pId], targetIndex)
                elseif not PanelHover[pId] then
                    // Case C: Drop bag item (released outside the bag panel)
                    call Debug("Drop: bag index " + I2S(DragOriginIndex[pId]))
                    call TasItemBagRemoveIndex(Selected[pId], DragOriginIndex[pId], true)
                endif
            endif
            // Reset drag origin
            set DragOriginType[pId] = 0
            set DragOriginIndex[pId] = 0
            set DragActive[pId] = false
            call FrameLoseFocus()
        endif
    endfunction

    // Track drag begin globally for inventory-origin drags
    private function GlobalMouseDownAction takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local integer pId = GetPlayerId(p)
        local mousebuttontype btn = BlzGetTriggerPlayerMouseButton()
        local integer invIndex = HoverOriginButton_CurrentSelectedButtonIndex - HoverOriginButton_ItemButtonOffset
        local integer bagHoverIndex
        local string btnStr
        local string panelStr
        local integer calcIndex
        // Ignore drags when bank panel is not open
        if not BlzFrameIsVisible(BlzGetFrameByName("TasItemBagPanel", 0)) then
            return
        endif
        // Diagnostics for right-click detection context
        if btn == MOUSE_BUTTON_TYPE_RIGHT then
            set btnStr = "RIGHT"
        else
            set btnStr = "LEFT"
        endif
        if PanelHover[pId] then
            set panelStr = "true"
        else
            set panelStr = "false"
        endif
        call Debug("Global MOUSE_DOWN: pId=" + I2S(pId) + ", btn=" + btnStr + ", invIndex=" + I2S(invIndex) + ", LastHoveredIndex=" + I2S(LastHoveredIndex[pId]) + ", PanelHover=" + panelStr)
        if btn == MOUSE_BUTTON_TYPE_RIGHT then
            set DragActive[pId] = true
            if invIndex >= 0 and invIndex < bj_MAX_INVENTORY then
                set DragOriginType[pId] = 1
                set DragOriginIndex[pId] = invIndex
                call Debug("Drag start: inventory slot " + I2S(invIndex))
            else
                // Start bag drag when hovering a bag slot
                set bagHoverIndex = LastHoveredIndex[pId]
                if PanelHover[pId] and bagHoverIndex > 0 then
                    set DragOriginType[pId] = 2
                    set DragOriginIndex[pId] = bagHoverIndex
                    call Debug("Drag start: bag slot " + I2S(bagHoverIndex))
                else
                    // Fallback: compute slot from mouse position
                    set calcIndex = ResolveBagIndexFromMouse()
                    if calcIndex > 0 then
                        set DragOriginType[pId] = 2
                        set DragOriginIndex[pId] = calcIndex + Offset[pId]
                        set PanelHover[pId] = true
                        call Debug("Drag start (computed): bag rawIndex " + I2S(calcIndex) + ", bagIndex " + I2S(DragOriginIndex[pId]))
                    else
                    call Debug("Right-click drag ignored: bagHoverIndex=" + I2S(bagHoverIndex) + ", PanelHover=" + panelStr)
                    endif
                endif
            endif
        endif
    endfunction
    
    private function WheelAction takes nothing returns nothing
        local boolean upwards = BlzGetTriggerFrameValue() > 0
        if GetLocalPlayer() == GetTriggerPlayer() then
            if upwards then 
                call BlzFrameSetValue(BlzGetFrameByName("TasItemBagSlider", 0), BlzFrameGetValue(BlzGetFrameByName("TasItemBagSlider", 0)) + 1)
            else
                call BlzFrameSetValue(BlzGetFrameByName("TasItemBagSlider", 0), BlzFrameGetValue(BlzGetFrameByName("TasItemBagSlider", 0)) - 1)
            endif
        endif
    endfunction

    private function CloseButtonAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        set SwapIndex[pId] = 0
        set TransferIndex[pId] = 0
        set TransferItem[pId] = null
        if GetLocalPlayer() == GetTriggerPlayer() then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
        endif
        call FrameLoseFocus()
    endfunction

    private function ShowButtonAction takes nothing returns nothing
        local integer pId = GetPlayerId(GetTriggerPlayer())
        local integer s
        set SwapIndex[pId] = 0
        set TransferIndex[pId] = 0
        set TransferItem[pId] = null
        if GetLocalPlayer() == GetTriggerPlayer() then
            if ShowButtonCloses and BlzFrameIsVisible(BlzGetFrameByName("TasItemBagPanel", 0)) then
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), false)
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
            else
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), true)
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
            endif
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
        set Offset[GetPlayerId(GetTriggerPlayer())] = R2I(BlzGetTriggerFrameValue() * Cols)
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
                call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), true)
                // Auto-reselect the hero so their inventory is visible while banking
                set IgnoreNextSelection[pId] = true
                call SelectUnitForPlayerSingle(udg_Heroes[GetPlayerNumber(GetTriggerPlayer())], GetTriggerPlayer())
            endif
        endif
    endfunction

    private function ESCAction takes nothing returns nothing
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
        if not IsBankUnit(GetTriggerUnit()) then
            return
        endif

        // Do not move Powerups that can be used into the bag
        if IsItemPowerup(GetManipulatedItem()) and TasItemBagUnitCanUseItems(GetTriggerUnit()) then 
            return
        endif

        // System flag to ignore pickup to bag
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

    private function UnitDeathAction takes nothing returns nothing
        // Global per-player bank: do not drop bank items on unit death.
        // No action needed.
    endfunction

    private function UpdateUI takes nothing returns nothing
        local integer pId = GetPlayerId(GetLocalPlayer())
        local integer itemCount = BagItem[pId].integer[0]
        local integer offset = Offset[pId]
        local integer max
        local integer itemCode
        local item it
        local string text = ""
        local integer dataIndex
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

            if itemCount > 0 then

                // scroll by rows
                set max = IMaxBJ(0, (itemCount + Cols - Cols * Rows) / Cols)
            
                call BlzFrameSetMinMaxValue(BlzGetFrameByName("TasItemBagSlider", 0), 0, max)
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSliderTooltip", 0), I2S(R2I(offset / Cols)) + "/" + I2S(max))
            else
                call BlzFrameSetMinMaxValue(BlzGetFrameByName("TasItemBagSlider", 0), 0, 0)
                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSliderTooltip", 0), "")
            endif

            set i = 1
            loop
                exitwhen i > Cols * Rows
                set dataIndex = i + offset
                call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButton", i), dataIndex <= itemCount)
                if dataIndex <= itemCount then
                    set it = BagItem[pId].item[dataIndex]
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
                    call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonTooltip", i), "")
                endif
                set i = i + 1
            endloop
        endif
        set it = null
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
            // Register both mouse up and down to maximize right-click detection across patches
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_MOUSE_UP)
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_MOUSE_DOWN)
            // Also register mouse events on backdrop frames and the slot container to capture routed events
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlotButtonBackdrop", buttonIndex), FRAMEEVENT_MOUSE_UP)
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlotButtonBackdrop", buttonIndex), FRAMEEVENT_MOUSE_DOWN)
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlot", buttonIndex), FRAMEEVENT_MOUSE_UP)
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlot", buttonIndex), FRAMEEVENT_MOUSE_DOWN)
            // Track hover to know which slot is under the cursor for global mouse
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(TriggerUIHover, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_MOUSE_LEAVE)
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
        // Create popup container and child buttons from FDF and hide initially
        call BlzCreateFrame("TasItemBagPopUpPanel", panel, 0, 0)
        call BlzGetFrameByName("TasItemBagPopUpEquip", 0)
        call BlzGetFrameByName("TasItemBagPopUpDrop", 0)
        call BlzGetFrameByName("TasItemBagPopUpSwap", 0)
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

        
        set TriggerItemGain = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(TriggerItemGain, EVENT_PLAYER_UNIT_PICKUP_ITEM)
        call TriggerAddAction(TriggerItemGain, function ItemGainAction)

        set TriggerItemUse = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(TriggerItemUse, EVENT_PLAYER_UNIT_USE_ITEM)
        call TriggerAddAction(TriggerItemUse, function ItemUseAction)

        set TriggerUnitDeath = CreateTrigger()
        call TriggerRegisterAnyUnitEventBJ(TriggerUnitDeath, EVENT_PLAYER_UNIT_DEATH)
        call TriggerAddAction(TriggerUnitDeath, function UnitDeathAction)


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

        // Legacy popup triggers restored
        set TriggerUIEquip = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(TriggerUIEquip, BlzGetFrameByName("TasItemBagPopUpEquip", 0), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(TriggerUIEquip, function BagPopupActionEquip)

        set TriggerUIDrop = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(TriggerUIDrop, BlzGetFrameByName("TasItemBagPopUpDrop", 0), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(TriggerUIDrop, function BagPopupActionDrop)

        set TriggerUISwap = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(TriggerUISwap, BlzGetFrameByName("TasItemBagPopUpSwap", 0), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(TriggerUISwap, function BagPopupActionSwap)

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
        set TriggerUIMouseDown = CreateTrigger()
        call RegisterAnyPlayerEvent(EVENT_PLAYER_MOUSE_DOWN, function GlobalMouseDownAction)

        // Note: Global mouse right-click detection removed for compatibility.

        call UserInit()
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
