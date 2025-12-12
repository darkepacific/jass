library TasItemBag initializer init_function requires Table
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
    
    // TransferItem remembers the current Target
    public item array TransferItem
    public integer array TransferIndex
    public integer array SwapIndex
    public integer array Offset
    public unit array Selected
    // The UI moves all picked up items into the bag, RpgCustomUI.EquipNow = true prevents that
    public boolean EquipNow = false

    private unit array ItemGainTimerUnit
    private timer ItemGainTimer
    private item array ItemGainTimerItem
    private integer ItemGainTimerCount = 0
    
endglobals

private function UserInit takes nothing returns nothing
    set InventorySkills[0] = 'AInv'
    set InventorySkills[1] = 'Apak'
    set InventorySkills[2] = 'Aiun'
    set InventorySkills[3] = 'Aien'
    set InventorySkills[4] = 'Aihn'
    set InventorySkills[5] = 'Aion'
endfunction

function TasItemBagAddItem takes unit u, item i returns nothing
    local integer unitHandle = GetHandleId(u)    
    call SetItemPosition(i, GetUnitX(u), GetUnitY(u))
    if not ItemIsInBag.boolean[GetHandleId(i)] and BagItem[unitHandle].integer[0] < ItemBagSize then
        set BagItem[unitHandle].integer[0] = BagItem[unitHandle].integer[0] + 1
        set ItemIsInBag.boolean[GetHandleId(i)] = true
        call SetItemVisible(i, false)
        set BagItem[unitHandle].item[BagItem[unitHandle].integer[0]] = i
    elseif ItemIsInBag.boolean[GetHandleId(i)] then
        call SetItemVisible(i, false)
    endif
endfunction
function TasItemBagGetItem takes unit u, integer index returns item
    local integer unitHandle = GetHandleId(u)    
    if BagItem[unitHandle].integer[0] <= 0 then
        return null
    endif
    return BagItem[unitHandle].item[index]    
endfunction
function TasItemBagSwap takes unit u, integer indexA, integer indexB returns boolean
    local integer unitHandle = GetHandleId(u)
    local item i
    local item i2
    if BagItem[unitHandle].integer[0] <= 0 then
        return false
    endif
    if indexA <= 0 or indexB <= 0 then
        return false
    endif
    set i = BagItem[unitHandle].item[indexA]
    set i2 = BagItem[unitHandle].item[indexB]
    if GetHandleId(i) > 0 and GetHandleId(i2) > 0 then
        set BagItem[unitHandle].item[indexB] = i
        set BagItem[unitHandle].item[indexA] = i2
        set i = null
        set i2 = null
        return true
    endif
    set i = null
    set i2 = null
    return false
endfunction

function TasItemBagRemoveIndex takes unit u , integer index, boolean drop returns boolean
    local item i
    local integer unitHandle = GetHandleId(u)
    if BagItem[unitHandle].integer[0] <= 0 then
        return false
    endif
    
    set i = BagItem[unitHandle].item[index]
    set BagItem[unitHandle].item[index] = BagItem[unitHandle].item[BagItem[unitHandle].integer[0]]
    set BagItem[unitHandle].item[BagItem[unitHandle].integer[0]] = null
    set BagItem[unitHandle].integer[0] = BagItem[unitHandle].integer[0] - 1   
    set ItemIsInBag.boolean[GetHandleId(i)] = false
    if drop and GetHandleId(i) > 0 then
        call SetItemPosition(i, GetUnitX(u), GetUnitY(u))
        call SetItemVisible(i, true)
        set i = null
        return true
    endif
    set i = null
    return false
endfunction
function TasItemBagRemoveItem takes unit u , item i, boolean drop returns boolean
    local integer unitHandle = GetHandleId(u)
    local integer loopA = BagItem[unitHandle].integer[0]
    if loopA <= 0 then
        return false
    endif
    // loop all items in the bag and remove it if found
    loop
        exitwhen loopA <= 0
        if BagItem[unitHandle].item[loopA] == i then
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
private function UnitCanEquipItem takes unit u , item i returns boolean
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
        call DisplayTimedTextToPlayer(GetOwningPlayer(u), 0, 0, 20, GetItemName(i)+" needs "+GetLocalizedString("LEVEL")+" "+ I2S(GetItemLevel(i)))
        set returnValue = false
    endif
    // itemCode can require an ability
    if ItemAbilityNeed[itemCode] != 0 and GetUnitAbilityLevel(u, ItemAbilityNeed[itemCode]) == 0 then
        call DisplayTimedTextToPlayer(GetOwningPlayer(u), 0, 0, 20, GetItemName(i)+" needs Ability "+ GetObjectName(ItemAbilityNeed[itemCode]))
        set returnValue = false
    endif
    if EquipClassLimit <= CountItemsOfClass(u, GetItemType(i)) then
        call DisplayTimedTextToPlayer(GetOwningPlayer(u), 0, 0, 20, "To many Items of this Item-Class")
        return false
    endif
    return returnValue
endfunction

private function ItemBag2Equip takes unit u , item i returns nothing
    // Inventory Full?
    if UnitInventoryCount(u) >= UnitInventorySize(u) then
        return
    endif
    
    // unit can equip this, restrictions
    if not UnitCanEquipItem(u, i) then
        return
    endif
     
    set EquipNow = true
    if UnitAddItem(u, i) then
        call TasItemBagRemoveItem(u, i, false)
    endif
    set EquipNow = false
endfunction
private function ItemEquip2Bag takes unit u , item i returns nothing
    call TasItemBagAddItem(u, i)
endfunction

private function BagPopupActionDrop takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local integer pId = GetPlayerId(GetTriggerPlayer())
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
        call ItemBag2Equip(Selected[pId], TransferItem[pId])
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

private function BagButtonAction takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local integer pId = GetPlayerId(GetTriggerPlayer())
    local integer bagIndex = S2I(BlzFrameGetText(BlzGetTriggerFrame())) + Offset[pId]
    if GetPlayerAlliance(GetOwningPlayer(Selected[pId]), p, ALLIANCE_SHARED_CONTROL) then
        set TransferItem[pId] = BagItem[GetHandleId(Selected[pId])].item[bagIndex]
        set TransferIndex[pId] = bagIndex
        if SwapIndex[pId] > 0 then
            call TasItemBagSwap(Selected[pId], bagIndex, SwapIndex[pId])
            set SwapIndex[pId] = 0

        elseif GetLocalPlayer() == p then
            call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), true)
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagPopUpButtonDrop", 0), IgnoreUndropAble or (UnitCanDropItems(Selected[pId]) and CanDropItem(TransferItem[pId])))
            call BlzFrameSetPoint(BlzGetFrameByName("TasItemBagPopUpPanel", 0), FRAMEPOINT_TOPLEFT, BlzGetTriggerFrame(), FRAMEPOINT_TOPRIGHT, 0.005, 0)
        endif
    endif
    call FrameLoseFocus()
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
    endif
    call FrameLoseFocus()
endfunction
private function SliderAction takes nothing returns nothing
    set Offset[GetPlayerId(GetTriggerPlayer())] = R2I(BlzGetTriggerFrameValue()*Cols)
endfunction

private function SelectAction takes nothing returns nothing
    local integer pId = GetPlayerId(GetTriggerPlayer())
    set Selected[pId] = GetTriggerUnit()
    set Offset[pId] = 0
endfunction
private function ESCAction takes nothing returns nothing
    if GetLocalPlayer() == GetTriggerPlayer() then
        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), false)
    endif
endfunction
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

    // Do not move Powerups that can be used into the bag
    if IsItemPowerup(GetManipulatedItem()) and TasItemBagUnitCanUseItems(GetTriggerUnit()) then 
        return
    endif

    // GUI flag to ignore pick up 2 bag
    static if LIBRARY_TasUnitBagGUI then
        if udg_TasItemBagEquipNow then
            return
        endif
    endif

    //System flag to ignore pickup 2 bag
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
    local unit u = GetTriggerUnit()
    local integer unitHandle = GetHandleId(u)
    local item i
    local integer loopA
    local boolean dropOnDeath
    local boolean canDropItems

    
    
    set loopA = BagItem[unitHandle].integer[0]
    if loopA > 0 then
        set dropOnDeath = DropsOnDeath(u)
        set canDropItems = UnitCanDropItems(u)
            
        loop
            exitwhen loopA <= 0
            set loopA = loopA - 1
        
            set i = BagItem[unitHandle].item[loopA]
            if dropOnDeath then
                call TasItemBagRemoveIndex(u, loopA, true)
                if DestroyUndropAbleItems and (not CanDropItem(i) or not canDropItems)  then
                    call RemoveItem(i)
                endif
            endif
        endloop
        if not IsUnitType(u, UNIT_TYPE_HERO) then
            call BagItem.remove(unitHandle)
        endif
    endif
    set u = null
    set i = null
endfunction
private function UpdateUI takes nothing returns nothing
    local integer pId = GetPlayerId(GetLocalPlayer())
    local integer unitHandle = GetHandleId(Selected[pId])
    local integer itemCount = BagItem[unitHandle].integer[0]
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
            set max = IMaxBJ(0, (itemCount+Cols - Cols*Rows)/Cols)
            
            call BlzFrameSetMinMaxValue(BlzGetFrameByName("TasItemBagSlider", 0), 0, max)
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSliderTooltip", 0), I2S(R2I(offset/Cols))+"/"+I2S(max))
        else
            call BlzFrameSetMinMaxValue(BlzGetFrameByName("TasItemBagSlider", 0), 0, 0)
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSliderTooltip", 0), "")
        endif

        set i = 1
        loop
            exitwhen i > Cols*Rows
            set dataIndex = i + offset
            call BlzFrameSetEnable(BlzGetFrameByName("TasItemBagSlotButton", i), dataIndex <= itemCount)
            if dataIndex <= itemCount  then
                set it = BagItem[unitHandle].item[dataIndex]
                set itemCode = GetItemTypeId(it)
                call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdrop", i), BlzGetAbilityIcon(itemCode) , 0, true)
                call BlzFrameSetTexture(BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", i), BlzGetAbilityIcon(itemCode) , 0, true)
                if AddNeedText then
                    set text = "|nNEED "+ GetLocalizedString("REQUIREDLEVELTOOLTIP")+" "+I2S(GetItemLevel(it))
                    if ItemAbilityNeed[itemCode] > 0 then
                        set text = text + "|nNEED "+ GetObjectName(ItemAbilityNeed[itemCode])
                    endif
                endif

                call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButtonTooltip", i), GetObjectName(itemCode)+ "|n"+BlzGetAbilityExtendedTooltip(itemCode, 0) +"|n|n"+text)
                
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
        call BlzFrameSetPoint(toolTip, FRAMEPOINT_TOP, frame, FRAMEPOINT_BOTTOM, 0, -0.008)
    endif

    call BlzFrameSetPoint(toolTipBox, FRAMEPOINT_TOPLEFT, toolTip, FRAMEPOINT_TOPLEFT, -0.008, 0.008)
    call BlzFrameSetPoint(toolTipBox, FRAMEPOINT_BOTTOMRIGHT, toolTip, FRAMEPOINT_BOTTOMRIGHT, 0.008, -0.008)
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

        set panel = BlzCreateFrameByType("BUTTON", "TasItemBagPanel", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        call BlzFrameSetAbsPoint(panel, Pos, PosX, PosY)
        call BlzFrameSetAllPoints(BlzCreateFrame("TasItemBagBox", panel, 0, 0), panel)
        call BlzTriggerRegisterFrameEvent(TriggerUIWheel, panel, FRAMEEVENT_MOUSE_WHEEL)
        call BlzCreateFrameByType("BUTTON", "TasItemBagTooltipPanel", panel, "", 0)
            // Custom Bag
        set count = 0
        set buttonIndex = 1
        loop
            exitwhen buttonIndex > Rows*Cols
        
            set frame = BlzCreateFrame("TasItemBagSlot", panel, 0, buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButton", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonBackdrop", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonBackdropDisabled", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonBackdropPushed", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonOverLay", buttonIndex)
            call BlzGetFrameByName("TasItemBagSlotButtonOverLayText", buttonIndex)
            call CreateTextTooltip(BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), "TasItemBagSlotButtonTooltip", buttonIndex, "")
            call BlzTriggerRegisterFrameEvent(TriggerUIBagButton, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_CONTROL_CLICK)
            call BlzTriggerRegisterFrameEvent(TriggerUIWheel, BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), FRAMEEVENT_MOUSE_WHEEL)
            call BlzFrameSetText(BlzGetFrameByName("TasItemBagSlotButton", buttonIndex), I2S(buttonIndex))
            
            set count = count + 1
            if count > Cols then
                call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, BlzGetFrameByName("TasItemBagSlot", buttonIndex - Cols), FRAMEPOINT_BOTTOMLEFT, 0, -0.002)
                set count = 1
            elseif buttonIndex > 1 then
                call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, BlzGetFrameByName("TasItemBagSlot", buttonIndex - 1), FRAMEPOINT_TOPRIGHT, 0.002, 0)
            endif
            set buttonIndex = buttonIndex + 1
        endloop
        if GetHandleId(frame) == 0 then
            call BJDebugMsg("Error - Creating TasItemBagSlot")
        endif
        call BlzFrameSetSize(panel, BlzFrameGetWidth(frame)*Cols + (Cols - 1)*0.002 + 0.02, BlzFrameGetHeight(frame)*Rows + (Rows - 1)*0.002 + 0.012)
        call BlzFrameSetPoint(BlzGetFrameByName("TasItemBagSlot", 1), FRAMEPOINT_TOPLEFT, panel, FRAMEPOINT_TOPLEFT, 0.006, -0.006)

        set frame = BlzCreateFrameByType("SLIDER", "TasItemBagSlider", panel, "QuestMainListScrollBar", 0)
        call BlzFrameClearAllPoints(frame)
        call BlzFrameSetPoint(frame, FRAMEPOINT_BOTTOMRIGHT, panel, FRAMEPOINT_BOTTOMRIGHT, -0.004, 0.008)
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
        call BlzFrameSetPoint(frame, FRAMEPOINT_CENTER, BlzFrameGetParent(frame), FRAMEPOINT_TOPRIGHT, -0.002, -0.002)
        call BlzTriggerRegisterFrameEvent(TriggerUIClose, frame, FRAMEEVENT_CONTROL_CLICK)
       // BlzFrameClick(BlzGetFrameByName("TasItemBagCloseButton", 0))

        call BlzFrameSetLevel(BlzGetFrameByName("TasItemBagTooltipPanel", 0), 8)
        // Bag Popup
        set frame = BlzCreateFrameByType("BUTTON", "TasItemBagPopUpPanel", panel, "", 0)
        call BlzFrameSetLevel(frame, 9)
        call BlzFrameSetSize(frame, 0.1, 0.0001)
        set frame2 = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagPopUpButtonEquip", frame, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame2, 0.1, 0.03)
        call BlzFrameSetPoint(frame2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0, 0)
        call BlzFrameSetText(frame2, "EQUIP")
        call BlzTriggerRegisterFrameEvent(TriggerUIEquip, frame2, FRAMEEVENT_CONTROL_CLICK)

        set frame3 = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagPopUpButtonDrop", frame, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame3, 0.1, 0.03)
        call BlzFrameSetPoint(frame3, FRAMEPOINT_TOPLEFT, frame2, FRAMEPOINT_BOTTOMLEFT, 0, 0)
        call BlzFrameSetText(frame3, "DROP")
        call BlzTriggerRegisterFrameEvent(TriggerUIDrop, frame3, FRAMEEVENT_CONTROL_CLICK)

        set frame2 = BlzCreateFrameByType("GLUETEXTBUTTON", "TasItemBagPopUpButtonSwap", frame, "ScriptDialogButton", 0)
        call BlzFrameSetSize(frame2, 0.1, 0.03)
        call BlzFrameSetPoint(frame2, FRAMEPOINT_TOPLEFT, frame3, FRAMEPOINT_BOTTOMLEFT, 0, 0)
        call BlzFrameSetText(frame2, "SWAP")
        call BlzTriggerRegisterFrameEvent(TriggerUISwap, frame2, FRAMEEVENT_CONTROL_CLICK)
        

        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPopUpPanel", 0), false)
        call BlzFrameSetVisible(BlzGetFrameByName("TasItemBagPanel", 0), false)
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

        set TriggerUIEquip = CreateTrigger()
        call TriggerAddAction(TriggerUIEquip, function BagPopupActionEquip)

        set TriggerUIDrop = CreateTrigger()
        call TriggerAddAction(TriggerUIDrop, function BagPopupActionDrop)

        set TriggerUISwap = CreateTrigger()
        call TriggerAddAction(TriggerUISwap, function BagPopupActionSwap)

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
