/*****************************************************************************
*
*    Inventory v1.0.8
*       by SmitingDevil
*
*    Custom inventory that is compatible with the vanilla one
*
******************************************************************************
*
*    Requirements:
*
*       Table by Bribe
*          https://www.hiveworkshop.com/threads/lua-vjass-new-table.188084/
*
*       Alloc - choose whatever you like
*          e.g.: by AGD https://www.hiveworkshop.com/threads/global-alloc.324937/
*
*       HoverOriginButton by Tasyen
*           https://www.hiveworkshop.com/threads/hoveroriginbutton.337965/
*
*       GetMainSelectedUnit (vJASS) by Tasyen
*           https://www.hiveworkshop.com/threads/getmainselectedunit.325337/
*
*       Sync by TriggerHappy
*           https://www.hiveworkshop.com/threads/sync-game-cache.279148/
*
*       List<T> by Bannar
*           https://www.hiveworkshop.com/threads/containers-list-t.249011/
*
*       InventoryEvent by Bannar
*           https://www.hiveworkshop.com/threads/snippet-inventoryevent.287084/
*
*       StringIterator by edo494
*           https://www.hiveworkshop.com/threads/snippet-stringiterator.246143/
*
*       WorldBounds by Nestharus
*           https://raw.githubusercontent.com/nestharus/JASS/master/jass/Systems/WorldBounds/script.j
*
*       TimerUtils by Magtheridon96/Vexorian/Bribe
*           https://www.hiveworkshop.com/threads/system-timerutilsex.204500/#post-2019478
*
******************************************************************************
*
*    Inventory Struct API:
*
*       General:
*
*        | static method create takes nothing returns thistype
*        |    Default constructor.
*        |
*        | static method createEx takes integer slotCount, integer cols, real buttonSize, real spaceGap, real borderSize, real titleSize, real posX, real posY returns thistype
*        |    Constructor that builds the inventory in one go.
*        |
*        | method destroy takes nothing returns nothing
*        |    Default destructor.
*
*
*       Access:
*
*        | readonly emptySlotTexture
*        | readonly slotIndicatorModel
*        | readonly backdrop
*        | readonly buttonSize
*
*
*       Modifiers:
*
*        [Design]
*
*        | method setSlotCount takes integer count returns thistype
*        |    Sets the number of inventory slots.
*        |
*        | method setSlotEmptyTexture takes string texture returns thistype
*        |    Sets the default texture for slots.
*        |
*        | method setSlotIndicatorModel takes string str returns thistype
*        |    Sets the model that shows a slot is selected.
*        |
*        | method setButtonSize takes real size returns thistype
*        |    Sets the size of the inventory slots and other buttons.
*        |
*        | method setButtonSpaceGap takes real size returns thistype
*        |    Sets the size of the space between inventory slots.
*        |
*        | method setColumnCount takes integer cols returns thistype
*        |    Sets the number of slots in a row.
*        |
*        | method setTitle takes string str returns thistype
*        |    Sets the name of the inventory.
*        |
*        | method setTitleSize takes real size returns thistype
*        |    Sets the size of the title's margins.
*        |
*        | method setBorderSize takes real size returns thistype
*        |    Sets the size of the inventory's margins.
         |
*        | method setOpenButtonPosition takes real x, real y returns thistype
*        |    Sets the position of the open button icon.
*        |
*        | method setOpenButtonTexture takes string str returns thistype
*        |    Sets the texture for open button icon.
*        |
*        | method build takes nothing returns nothing
*        |    Creates the inventory and all its elements.
*        |    All methods for design must be called before running this method.
*        |        They cannot be modified after build.
*        |        Only title name and methods for the open button are the only exceptions.
*        |            They can be modified before and after build and are optional.
*
*        [Technical]
*
*        | method setPosition takes real x, real y returns thistype
*        |    Moves the inventory to given point on the screen
*        |
*        | method show takes boolean flag returns nothing
*        |    Hides or displays the inventory
*        |
*        | method showEx takes player p, boolean flag returns nothing
*        |    Hides or displays the inventory for specific player only
*        |    Links the inventory to player as the one being displayed
*
*
*****************************************************************************/
library Inventory initializer Init requires TimerUtilsEx, WorldBounds, ListT, StringIterator, Sync, InventoryEvent, HoverOriginButton, GetMainSelectedUnit
    globals
        private framehandle dummyFrame
        private framehandle dummyFrameEx
        private framehandle dummyIcon
        private framehandle array playerFrame
        private integer originItemSlot = -1
        private integer originItemSlotEx = -1
        private Table player2Inventory
        //private Table item2Unit
        player LOCAL_PLAYER
        framehandle GAME_UI
        framehandle ORIGIN_ITEM_BUTTON_ONE
        
        //private integer count = 0
    endglobals
    
    function IsFrameEnabled takes framehandle frame, player p returns boolean
        if GetLocalPlayer() == p or p == null then
            return BlzFrameGetEnable(frame)
        else
            return false
        endif
    endfunction
    
    function UnfocusFrame takes framehandle frame, player p returns nothing
        if IsFrameEnabled(frame, p) then
            call BlzFrameSetEnable(frame, false)
            call BlzFrameSetEnable(frame, true)
        else
            call BlzFrameSetEnable(frame, true)
            call BlzFrameSetEnable(frame, false)
        endif
    endfunction
    
    function print takes string msg returns nothing
        call DisplayTimedTextToPlayer(LOCAL_PLAYER, 0, 0, 3, msg)
    endfunction
    
    private function IsMouseDraggingItem takes nothing returns boolean
        local integer i = 0
        loop
            if BlzFrameIsVisible(BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, i)) then
                exitwhen true
            endif
            set i = i + 1
            exitwhen i == 12
        endloop
        return i == 11
    endfunction

    private module MyModule
        private static method onInit takes nothing returns nothing
            //this is run on map init
            call init()
        endmethod
    endmodule
    
    private struct Frame extends array
        implement Alloc
        
        framehandle handle
        
        static method create takes framehandle frame returns thistype
            local thistype this = allocate()
            
            set handle = frame
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            set handle = null
            call deallocate()
        endmethod
    endstruct
    
    private struct UnitItem extends array
        implement Alloc
        
        item itemHandle
        unit unitHandle
        
        static method create takes unit u, item it returns thistype
            local thistype this = allocate()
            
            set unitHandle = u
            set itemHandle = it
            
            return this
        endmethod
        
        method destroy takes nothing returns nothing
            set unitHandle = null
            set itemHandle = null
            
            call deallocate()
        endmethod
    endstruct

    private struct Slot extends array
        implement Alloc
        
        private framehandle actionButton
        private framehandle icon
        private framehandle tooltipParent
        private framehandle tooltipText
        private framehandle tooltipBackdrop
        readonly framehandle indicator
        readonly Inventory parent
        readonly static Table frame2Slot
        readonly static Table frame2Item
        readonly static Table unit2Item
        readonly static Table player2Unit
        readonly static Table data2Frame
        private static trigger actionTrigger
        private static trigger enterTrigger
        //private static framehandle clickedFrame
        
        static method create takes real size, real x, real y, Inventory parent returns thistype
            local thistype this = allocate()

            set actionButton = BlzCreateFrame("ScriptDialogButton", parent.backdrop, 0, 0)
            call BlzFrameSetSize(actionButton, size, size)
            call BlzFrameSetPoint(actionButton, FRAMEPOINT_TOPLEFT, parent.backdrop, FRAMEPOINT_TOPLEFT, x, y)
            
            set frame2Slot[GetHandleId(actionButton)] = this
            set frame2Item[GetHandleId(actionButton)] = Table.create()

            set icon = BlzCreateFrameByType("BACKDROP", "SlotIcon", actionButton, "", 0)
            call BlzFrameSetAllPoints(icon, actionButton)
            call BlzFrameSetTexture(icon, parent.emptySlotTexture, 0, true)

            set tooltipParent = BlzCreateFrameByType("FRAME", "SlotTooltipParent", actionButton, "", 0)
            call BlzFrameSetTooltip(actionButton, tooltipParent)

            set tooltipBackdrop = BlzCreateFrameByType("BACKDROP", "SlotTooltipBackdrop", tooltipParent, "", 0)
            call BlzFrameSetVisible(tooltipBackdrop, false)

            set tooltipText = BlzCreateFrameByType("TEXT", "SlotTooltipText", tooltipBackdrop, "", 0)
            call BlzFrameSetSize(tooltipText, 0.2, 0)
            call BlzFrameSetPoint(tooltipText, FRAMEPOINT_TOPLEFT, actionButton, FRAMEPOINT_TOPRIGHT, 0, 0)

            call BlzFrameSetPoint(tooltipBackdrop, FRAMEPOINT_TOPLEFT, tooltipText, FRAMEPOINT_TOPLEFT, -0.007, 0.007)
            call BlzFrameSetPoint(tooltipBackdrop, FRAMEPOINT_BOTTOMRIGHT, tooltipText, FRAMEPOINT_BOTTOMRIGHT, 0.007, -0.007)
            call BlzFrameSetTexture(tooltipBackdrop, "UI\\Widgets\\ToolTips\\Human\\human-tooltip-background.blp", 0, true)
            
            set indicator = BlzCreateFrameByType("SPRITE", "SlotIndicator", actionButton, "", 0)
            call BlzFrameSetAllPoints(indicator, actionButton)
            call BlzFrameSetScale(indicator, parent.buttonSize/0.036)
            call BlzFrameSetVisible(indicator, false)
            call BlzFrameSetModel(indicator, parent.slotIndicatorModel, 0)
            
            call BlzTriggerRegisterFrameEvent(actionTrigger, actionButton, FRAMEEVENT_CONTROL_CLICK)

            set .parent = parent

            return this
        endmethod
        
        private method update takes item itm returns nothing
            if itm != null then
                call BlzFrameSetTexture(icon, BlzGetItemIconPath(itm), 0, true)
                call BlzFrameSetVisible(tooltipBackdrop, true)
                call BlzFrameSetText(tooltipText, GetLocalizedString("|cffffcc00" + GetItemName(itm) + "|r\n\n" + BlzGetAbilityExtendedTooltip(GetItemTypeId(itm), 0)))
            else
                call BlzFrameSetTexture(icon, parent.emptySlotTexture, 0, true)
                call BlzFrameSetVisible(tooltipBackdrop, false)
            endif
        endmethod
        
        private static method onExpired takes nothing returns nothing
            local UnitItem data = ReleaseTimer(GetExpiredTimer()) 
            
            call SetItemVisible(data.itemHandle, true)
            call UnitAddItem(data.unitHandle, data.itemHandle)
            call UnitDropItemSlot(data.unitHandle, data.itemHandle, 0)
            
            call data.destroy()
        endmethod
        
        private static method clickAction takes nothing returns nothing
            local SyncData d = GetSyncedData()
            local StringIterator iter = StringIterator.create(d.readString(0))
            local Frame clickedFrame = data2Frame[d]
            local integer originSlot
            local integer pid
            local integer selectedIndex = S2I(iter.read())
            local unit mainSelectedUnit = GetMainSelectedUnit(selectedIndex)
            local framehandle frame
            local framehandle pFrame
            local boolean itemOnMouse
            local player syncer
            local item itemInOriginSlot
            local item slotItem
            local item item0
            local thistype slot
            local thistype pSlot
            local Table table
            local Table tb
            
            call data2Frame.remove(d)
            
            //call print("Click Action: " + GetUnitName(mainSelectedUnit))
            //call ClearTextMessages()
            //call print("------------------------------------------------------")
            if mainSelectedUnit != null then
                set frame = clickedFrame.handle
                set syncer = d.from
                set pid = GetPlayerId(syncer)
                set table = frame2Item[GetHandleId(frame)]
                set slot = frame2Slot[GetHandleId(frame)]
                set originSlot = S2I(iter.read())
                if iter.read() == "true" then
                    set itemOnMouse = true
                else
                    set itemOnMouse = false
                endif
                
                if itemOnMouse then
                    set itemInOriginSlot = UnitItemInSlot(mainSelectedUnit, originSlot)
                    if itemInOriginSlot != null then
                        set pFrame = playerFrame[pid]
                        set playerFrame[pid] = null
                        call SetItemPosition(itemInOriginSlot, WorldBounds.minX, WorldBounds.minY)
                        call SetItemVisible(itemInOriginSlot, false)
                        
                        if LOCAL_PLAYER == syncer then
                            call slot.update(itemInOriginSlot)
                            set originItemSlot = -1
                            set originItemSlotEx = -1
                        endif
                        
                        set slotItem = table.item[GetHandleId(mainSelectedUnit)]
                        set table.item[GetHandleId(mainSelectedUnit)] = itemInOriginSlot
                        set playerFrame[pid] = pFrame
                        if pFrame == null then
                            if slotItem != null then
                                //call print("Click Slot - itemOnMouse - no pFrame: " + GetItemName(slotItem))
                                call UnitAddItem(mainSelectedUnit, slotItem)
                                call UnitDropItemSlot(mainSelectedUnit, slotItem, originSlot)
                            endif
                        else
                            if originSlot == 0 then
                                set playerFrame[pid] = null
                                set slot = frame2Slot[GetHandleId(pFrame)]
                                set tb = frame2Item[GetHandleId(pFrame)]
                                if slotItem == null then
                                    call tb.item.remove(GetHandleId(mainSelectedUnit))
                                else
                                    set tb.item[GetHandleId(mainSelectedUnit)] = slotItem
                                endif
                                //call print("Click Slot - itemOnMouse - pFrame - originSlot 0: " + GetItemName(slotItem))
                                if LOCAL_PLAYER == syncer then
                                    call slot.update(slotItem)
                                    call BlzFrameSetVisible(dummyIcon, false)
                                    call BlzFrameSetAllPoints(ORIGIN_ITEM_BUTTON_ONE, dummyFrame)
                                    call BlzFrameSetVisible(slot.indicator, false)
                                endif
                                if unit2Item.item.has(GetHandleId(mainSelectedUnit)) then
                                    set item0 = unit2Item.item[GetHandleId(mainSelectedUnit)]
                                    call TimerStart(NewTimerEx(UnitItem.create(mainSelectedUnit, item0)), 0, false, function thistype.onExpired)
                                    //call UnitAddItem(mainSelectedUnit, item0)
                                    //call UnitDropItemSlot(mainSelectedUnit, item0, 0)
                                    call unit2Item.item.remove(GetHandleId(mainSelectedUnit))
                                endif
                            else
                                set playerFrame[pid] = null 
                                if slotItem != null then
                                    call UnitAddItem(mainSelectedUnit, slotItem)
                                    call UnitDropItemSlot(mainSelectedUnit, slotItem, originSlot)
                                endif
                                set playerFrame[pid] = pFrame
                            endif
                            set pFrame = null
                        endif
                    endif
                    set itemInOriginSlot = null
                else
                    if table.item.has(GetHandleId(mainSelectedUnit)) then

                        if playerFrame[GetPlayerId(syncer)] != null then
                            set pFrame = playerFrame[GetPlayerId(syncer)]
                            set playerFrame[GetPlayerId(syncer)] = null
                            set pSlot = frame2Slot[GetHandleId(pFrame)]
                            set tb = frame2Item[GetHandleId(pFrame)]
                            set slotItem = tb.item[GetHandleId(mainSelectedUnit)]
                            call SetItemPosition(slotItem, WorldBounds.minX, WorldBounds.minY)
                            call SetItemVisible(slotItem, false)
                            if LOCAL_PLAYER == syncer then
                                call BlzFrameSetVisible(pSlot.indicator, false)
                            endif
                            
                            if unit2Item.item.has(GetHandleId(mainSelectedUnit)) then
                                set item0 = unit2Item.item[GetHandleId(mainSelectedUnit)]
                                call UnitAddItem(mainSelectedUnit, item0)
                                call UnitDropItemSlot(mainSelectedUnit, item0, 0)
                                call unit2Item.item.remove(GetHandleId(mainSelectedUnit))
                            endif
                        endif
                        
                        if LOCAL_PLAYER == syncer then
                            call BlzFrameSetVisible(slot.indicator, true)
                            call BlzFrameSetAllPoints(ORIGIN_ITEM_BUTTON_ONE, frame)
                            set originItemSlot = -1
                            set originItemSlotEx = -1
                            call BlzFrameSetEnable(dummyFrameEx, true)
                        endif

                        set slotItem = UnitItemInSlot(mainSelectedUnit, 0)
                        if slotItem != null then
                            set unit2Item.item[GetHandleId(mainSelectedUnit)] = slotItem
                            //set item2Unit.unit[GetHandleId(slotItem)] = mainSelectedUnit
                            //call print("Clicked slot no item on mouse: " + GetItemName(slotItem))
                            if LOCAL_PLAYER == syncer then
                                call BlzFrameSetTexture(dummyIcon, BlzGetAbilityIcon(GetItemTypeId(slotItem)), 0, true)
                                call BlzFrameSetVisible(dummyIcon, true)
                            endif
                            call SetItemPosition(slotItem, WorldBounds.minX, WorldBounds.minY)
                            call SetItemVisible(slotItem, false)
                            set slotItem = null
                        endif
                            
                        set slotItem = table.item[GetHandleId(mainSelectedUnit)]
                        call UnitAddItem(mainSelectedUnit, slotItem)
                        call UnitDropItemSlot(mainSelectedUnit, slotItem, 0)
                        set slotItem = null

                        set playerFrame[GetPlayerId(syncer)] = frame
                    endif
                endif
                
                set frame = null
                set mainSelectedUnit = null
                set syncer = null
            endif
            
            call d.destroy()
            call clickedFrame.destroy()
        endmethod
        
        private static method onClick takes nothing returns nothing
            local SyncData req = SyncData.create(GetTriggerPlayer())
            local string str
            
            set data2Frame[req] = Frame.create(BlzGetTriggerFrame())
            
            call UnfocusFrame(BlzGetTriggerFrame(), GetTriggerPlayer())
            
            if frame2Slot.has(GetHandleId(BlzGetTriggerFrame())) then
                set str = ""
                if LOCAL_PLAYER == GetTriggerPlayer() then
                    set str = I2S(GetSelectedUnitIndex()) + " "
                    set str = str + I2S(originItemSlot) + " "
                    if IsMouseDraggingItem() then
                        set str = str + "true" 
                    else
                        set str = str + "false" 
                    endif
                endif
                set req.onComplete = Filter(function thistype.clickAction)
                call req.syncString(str, StringLength(str))
                //call SyncStr(str, GetTriggerPlayer(), function thistype.clickAction)
            endif
        endmethod
        
        private static method onEnter takes nothing returns nothing
            call UnfocusFrame(BlzGetTriggerFrame(), GetTriggerPlayer())
            call BlzFrameSetEnable(BlzGetTriggerFrame(), false)
            if BlzGetTriggerFrame() == dummyFrameEx then
                if IsMouseDraggingItem() then
                    set originItemSlotEx = 0
                endif
            endif
        endmethod
        
        private static method onItemMove takes nothing returns nothing
            local item item0
            local unit u = GetInventoryManipulatingUnit()
            local item itm 
            local item swapped 
            local integer slotFrom
            local integer slotTo = GetInventorySlotTo()
            local player p = GetOwningPlayer(u)
            local integer pid = GetPlayerId(p)
            local thistype slot
            local framehandle pFrame
            local Table tb
            
            if LOCAL_PLAYER == p then
                set originItemSlot = slotTo
            endif
            
            set pFrame = playerFrame[pid]
            set playerFrame[pid] = null
            if pFrame != null then
                //call print("Item Move: " + GetItemName(GetInventoryManipulatedItem()))
                set itm = GetInventoryManipulatedItem()
                set swapped = GetInventorySwappedItem()
                set slot = frame2Slot[GetHandleId(pFrame)]
                set slotFrom = GetInventorySlotFrom()
                
                if slotTo == slotFrom then
                    
                else
                    call BlzFrameSetEnable(dummyFrame, true)
                    
                    set tb = frame2Item[GetHandleId(pFrame)]
                    
                    if slotFrom == 0 then
                        if swapped != null then
                            set tb.item[GetHandleId(u)] = swapped
                            call SetItemPosition(swapped, WorldBounds.minX, WorldBounds.minY)
                            call SetItemVisible(swapped, false)
                            
                            if LOCAL_PLAYER == p then
                                call slot.update(swapped)
                                call BlzFrameSetVisible(slot.indicator, false)
                                call BlzFrameSetVisible(dummyIcon, false)
                                call BlzFrameSetAllPoints(ORIGIN_ITEM_BUTTON_ONE, dummyFrame)
                                //set originItemSlot = -1
                                set originItemSlotEx = -1
                            endif
                        else
                            call tb.item.remove(GetHandleId(u))
                            if LOCAL_PLAYER == p then
                                call slot.update(null)
                                call BlzFrameSetVisible(slot.indicator, false)
                                call BlzFrameSetVisible(dummyIcon, false)
                                call BlzFrameSetAllPoints(ORIGIN_ITEM_BUTTON_ONE, dummyFrame)
                                //set originItemSlot = -1
                                set originItemSlotEx = -1
                            endif
                        endif
                    elseif slotTo == 0 then
                        set tb.item[GetHandleId(u)] = itm
                        call print("sloTo 0 - swapped item: " + GetItemName(itm))
                        call SetItemPosition(itm, WorldBounds.minX, WorldBounds.minY)
                        call SetItemVisible(itm, false)
                        
                        if LOCAL_PLAYER == p then
                            call slot.update(itm)
                            call BlzFrameSetVisible(slot.indicator, false)
                            call BlzFrameSetVisible(dummyIcon, false)
                            call BlzFrameSetAllPoints(ORIGIN_ITEM_BUTTON_ONE, dummyFrame)
                            //set originItemSlot = -1
                            set originItemSlotEx = -1
                        endif
                        
                        call UnitDropItemSlot(u, swapped, slotFrom)
                    endif
                    if slotFrom == 0 or slotTo == 0 then
                        set pFrame = null
                        set item0 = unit2Item.item[GetHandleId(u)]
                        //call print("sloTo 0 - item0: " + GetItemName(item0))
                        if item0 != null then
                            call unit2Item.item.remove(GetHandleId(u))
                            call SetItemVisible(item0, true)
                            call UnitAddItem(u, item0)
                            call UnitDropItemSlot(u, item0, 0)
                            set item0 = null
                        endif
                    endif
                endif
            endif
            
            set u = null
            set itm = null
            set swapped = null 
            set playerFrame[pid] = pFrame
            set pFrame = null
        endmethod
        
        private static method onItemDrop takes nothing returns nothing
            local item itm = GetManipulatedItem()
            local item item0
            local unit u = GetTriggerUnit()
            local integer pid = GetPlayerId(GetTriggerPlayer())
            local thistype slot
            local framehandle pFrame = playerFrame[pid]
            local Table tb
            
            if pFrame != null and UnitItemInSlot(u, 0) == itm then
                set playerFrame[pid] = null
                //call print("Item Drop: " + GetItemName(itm))
                call BlzFrameSetEnable(dummyFrame, true)
                set slot = frame2Slot[GetHandleId(pFrame)]
                set tb = frame2Item[GetHandleId(pFrame)]
                call tb.item.remove(GetHandleId(u))
                if LOCAL_PLAYER == GetTriggerPlayer() then
                    call slot.update(null)
                    call BlzFrameSetVisible(slot.indicator, false)
                    call BlzFrameSetVisible(dummyIcon, false)
                    call BlzFrameSetAllPoints(ORIGIN_ITEM_BUTTON_ONE, dummyFrame)
                    set originItemSlot = -1
                    set originItemSlotEx = -1
                endif
                set item0 = unit2Item.item[GetHandleId(u)]
                if item0 != null then
                    //call print("Item Drop - item0: " + GetItemName(item0))
                    call unit2Item.item.remove(GetHandleId(u))
                    call TimerStart(NewTimerEx(UnitItem.create(u, item0)), 0, false, function thistype.onExpired)
                    set item0 = null
                endif
            endif
        endmethod
        
        private static method mouseAction takes nothing returns nothing
            local SyncData d = GetSyncedData()
            local StringIterator iter = StringIterator.create(d.readString(0))
            local IntegerListItem node
            local Inventory inv
            local Table tb
            local player p = d.from
            local integer pid = GetPlayerId(p) 
            local integer selectedIndex
            local integer originSlot
            local thistype slot
            local boolean itemOnMouse
            local item item0
            local item itm
            local unit u
            local unit mainUnit
            local string str = iter.read()
            local framehandle pFrame
            
            call d.destroy()
            
            if not player2Inventory.has(pid) then
                return
            endif
            
            if str == "true" then
                set itemOnMouse = true
            else
                set itemOnMouse = false
            endif
            set originSlot = S2I(iter.read())
            set selectedIndex = S2I(iter.read())
            //set count = count + 1
            
            if itemOnMouse then
                //call print("Main Selected Unit Index: " + I2S(selectedIndex))
                if playerFrame[pid] != null and originSlot == 0 then
                    set u = GetMainSelectedUnit(selectedIndex)
                    set slot = frame2Slot[GetHandleId(playerFrame[pid])]
                    set item0 = unit2Item.item[GetHandleId(u)]
                    set tb = frame2Item[GetHandleId(playerFrame[pid])]
                    
                    if item0 == null then
                        call tb.item.remove(GetHandleId(u))
                    else
                        call unit2Item.item.remove(GetHandleId(u))
                        set tb.item[GetHandleId(u)] = item0
                    endif
                    
                    if LOCAL_PLAYER == p then
                        call slot.update(item0)
                        call BlzFrameSetVisible(slot.indicator, false)
                        call BlzFrameSetVisible(dummyIcon, false)
                        call BlzFrameSetAllPoints(ORIGIN_ITEM_BUTTON_ONE, dummyFrame)
                        set originItemSlot = -1
                        set originItemSlotEx = -1
                        call ForceUICancel()
                        call BlzFrameSetEnable(dummyFrameEx, true)
                    endif
                    
                    set item0 = null
                    set u = null
                    set playerFrame[pid] = null
                endif
            else
                set pFrame = playerFrame[pid]
                set playerFrame[pid] = null
                set mainUnit = GetMainSelectedUnit(selectedIndex)
                set u = player2Unit.unit[pid]
                set player2Unit.unit[pid] = mainUnit
                if mainUnit != u and u != null then
                    if unit2Item.item.has(GetHandleId(u)) then
                        set item0 = unit2Item.item[GetHandleId(u)]
                        set itm = UnitItemInSlot(u, 0)
                        call SetItemPosition(itm, WorldBounds.minX, WorldBounds.minY)
                        call SetItemVisible(itm, false)
                        call UnitAddItem(u, item0)
                        call UnitDropItemSlot(u, item0, 0)
                        call unit2Item.item.remove(GetHandleId(u))
                        set itm = null
                        set item0 = null
                    endif
                    
                    set inv = player2Inventory[pid]
                    set node = inv.slots.first
                    loop
                        exitwhen node == 0
                        set slot = node.data
                        set tb = frame2Item[GetHandleId(slot.actionButton)]
                        set itm = tb.item[GetHandleId(mainUnit)]
                        if itm != null then
                             call SetItemPosition(itm, WorldBounds.minX, WorldBounds.minY)
                             call SetItemVisible(itm, false)
                        endif
                        if LOCAL_PLAYER == p then
                            call slot.update(itm)
                        endif
                        set itm = null
                        set node = node.next
                    endloop
                    
                    if unit2Item.item.has(GetHandleId(mainUnit)) then
                        set item0 = unit2Item.item[GetHandleId(mainUnit)]
                        //call print("mainUnit - item0: " + GetItemName(item0))
                        call UnitAddItem(mainUnit, item0)
                        call UnitDropItemSlot(mainUnit, item0, 0)
                        call unit2Item.item.remove(GetHandleId(mainUnit))
                        set item0 = null
                    endif
                    
                    if pFrame != null then
                        set slot = frame2Slot[GetHandleId(pFrame)]
                        set pFrame = null
                        if LOCAL_PLAYER == p then
                            call BlzFrameSetVisible(slot.indicator, false)
                            call BlzFrameSetVisible(dummyIcon, false)
                            call BlzFrameSetAllPoints(ORIGIN_ITEM_BUTTON_ONE, dummyFrame)
                            set originItemSlot = -1
                            set originItemSlotEx = -1
                            call BlzFrameSetEnable(dummyFrameEx, true)
                        endif
                    endif
                endif
                set playerFrame[pid] = pFrame
            endif
        endmethod
        
        private static method onMouseClick takes nothing returns nothing
            local SyncData req = SyncData.create(GetTriggerPlayer())
            local string str = ""
            if LOCAL_PLAYER == GetTriggerPlayer() then
                if IsMouseDraggingItem() then
                    set str = "true " 
                else
                    set str = "false " 
                endif
                set str = str + I2S(originItemSlotEx) + " "
                set str = str + I2S(GetSelectedUnitIndex())
            endif
            set req.onComplete = Filter(function thistype.mouseAction)
            call req.syncString(str, StringLength(str))
            //call print(str + ": " + I2S(StringLength(str)) + " characters")
            //call SyncStr(str, GetTriggerPlayer(), function thistype.mouseAction)
        endmethod
        
        private static method onInit takes nothing returns nothing
            set frame2Slot = Table.create()
            set frame2Item = Table.create()
            set unit2Item = Table.create()
            set player2Unit = Table.create()
            set data2Frame = Table.create()
            
            set actionTrigger = CreateTrigger()
            set enterTrigger = CreateTrigger()
            call TriggerAddCondition(actionTrigger, function thistype.onClick)
            call TriggerAddCondition(enterTrigger, function thistype.onEnter)
            
            set ORIGIN_ITEM_BUTTON_ONE = BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, 0)
            
            set dummyFrame = BlzCreateFrameByType("GLUETEXTBUTTON", "DummyFrame", GAME_UI, "", 0)
            call BlzFrameSetSize(dummyFrame, 0.030, 0.031)
            call BlzFrameSetAbsPoint(dummyFrame, FRAMEPOINT_CENTER, 0.5318, 0.097)
            
            set dummyIcon = BlzCreateFrameByType("BACKDROP", "DummyIcon", dummyFrame, "", 0)
            call BlzFrameSetAllPoints(dummyIcon, dummyFrame)
            call BlzFrameSetVisible(dummyIcon, false)
            
            set dummyFrameEx = BlzCreateFrameByType("GLUETEXTBUTTON", "DummyFrame", dummyFrame, "", 0)
            call BlzFrameSetSize(dummyFrameEx, 0.04, 0.04)
            call BlzFrameSetAbsPoint(dummyFrameEx, FRAMEPOINT_CENTER, 0.5318, 0.097)
            call BlzTriggerRegisterFrameEvent(enterTrigger, dummyFrameEx, FRAMEEVENT_MOUSE_ENTER)
            
            call RegisterNativeEvent(EVENT_ITEM_INVENTORY_MOVE, function thistype.onItemMove)
            
            call RegisterAnyPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function thistype.onItemDrop)
            
            call RegisterAnyPlayerEvent(EVENT_PLAYER_MOUSE_UP, function thistype.onMouseClick)
        endmethod
    endstruct

    struct Inventory extends array
        implement Alloc
            
        private static trigger closeTrigger
        private static trigger openTrigger
        private static Table frame2Inventory
        
        private framehandle title
        private framehandle closeButton
        private framehandle openIcon
        private framehandle nextButton
        private framehandle prevButton
        private framehandle pageNumber
        private integer slotCount
        private integer columns
        private real borderSize
        private real titleSize
        private real spaceGap

        readonly string emptySlotTexture
        readonly string slotIndicatorModel
        readonly framehandle backdrop
        readonly real buttonSize
        
        framehandle openButton
        IntegerList slots

        method setSlotCount takes integer count returns thistype
            set slotCount = count
            return this
        endmethod

        method setColumnCount takes integer cols returns thistype
            set columns = cols
            return this
        endmethod

        method setTitle takes string str returns thistype
            call BlzFrameSetText(title, GetLocalizedString(str))
            return this
        endmethod

        method setTitleSize takes real size returns thistype
            set titleSize = size
            return this
        endmethod

        method setBorderSize takes real size returns thistype
            set borderSize = size
            return this
        endmethod

        method setButtonSize takes real size returns thistype
            set buttonSize = size
            return this
        endmethod

        method setButtonSpaceGap takes real size returns thistype
            set spaceGap = size
            return this
        endmethod

        method setSlotEmptyTexture takes string texture returns thistype
            set emptySlotTexture = texture
            return this
        endmethod

        method setPosition takes real x, real y returns thistype
            call BlzFrameSetAbsPoint(backdrop, FRAMEPOINT_CENTER, x, y)
            return this
        endmethod
        
        method setOpenButtonPosition takes real x, real y returns thistype
            call BlzFrameSetAbsPoint(openButton, FRAMEPOINT_CENTER, x, y)
            return this
        endmethod
        
        method setOpenButtonTexture takes string str returns thistype
            call BlzFrameSetTexture(openIcon, str, 0, true)
            return this
        endmethod
        
        method setSlotIndicatorModel takes string str returns thistype
            set slotIndicatorModel = str
            return this
        endmethod

        method show takes boolean flag returns nothing
            call BlzFrameSetVisible(backdrop, flag)
        endmethod
        
        method showEx takes player p, boolean flag returns nothing
            if LOCAL_PLAYER == p then
                call BlzFrameSetVisible(backdrop, flag)
            endif
            if flag then
                set player2Inventory[GetPlayerId(p)] = this
            else
                call player2Inventory.remove(GetPlayerId(p))
            endif
        endmethod

        method build takes nothing returns nothing
            local integer rows = slotCount/columns
            local integer i = 0
            local integer j = 0
            local real x = borderSize
            local real y = -borderSize - titleSize
            
            call BlzFrameSetSize(backdrop, columns*buttonSize + (columns - 1)*spaceGap + 2*borderSize, rows*buttonSize + (rows - 1)*spaceGap + 2*borderSize + titleSize)
            
            loop
                exitwhen i == slotCount
                call slots.push(Slot.create(buttonSize, x, y, this))
                set x = x + spaceGap + buttonSize
                set j = j + 1
                if j == columns then
                    set j = 0
                    set x = borderSize
                    set y = y - spaceGap - buttonSize
                endif
                set i = i + 1
            endloop
            
            call BlzFrameSetSize(openButton, buttonSize, buttonSize)

            call BlzFrameSetSize(title, 0, titleSize)
            call BlzFrameSetPoint(title, FRAMEPOINT_CENTER, backdrop, FRAMEPOINT_TOP, 0, -borderSize*.75)
            //call BlzFrameSetSize(pageNumber, 0, titleSize) 
            //call BlzFrameSetPoint(pageNumber, FRAMEPOINT_CENTER, backdrop, FRAMEPOINT_BOTTOM, 0, borderSize)
            
            call BlzFrameSetSize(openButton, buttonSize, buttonSize)
            call BlzTriggerRegisterFrameEvent(openTrigger, openButton, FRAMEEVENT_CONTROL_CLICK)

            call BlzFrameSetPoint(closeButton, FRAMEPOINT_TOPRIGHT, backdrop, FRAMEPOINT_TOPRIGHT, 0, 0)
            call BlzFrameSetSize(closeButton, buttonSize, buttonSize)
            call BlzFrameSetText(closeButton, "X")
            call BlzTriggerRegisterFrameEvent(closeTrigger, closeButton, FRAMEEVENT_CONTROL_CLICK)

//            call BlzFrameSetPoint(nextButton, FRAMEPOINT_BOTTOMRIGHT, backdrop, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
//            call BlzFrameSetSize(nextButton, buttonSize, buttonSize)
//            call BlzFrameSetText(nextButton, ">")
//
//            call BlzFrameSetPoint(prevButton, FRAMEPOINT_BOTTOMLEFT, backdrop, FRAMEPOINT_BOTTOMLEFT, 0, 0)
//            call BlzFrameSetSize(prevButton, buttonSize, buttonSize)
//            call BlzFrameSetText(prevButton, "<")
        endmethod
        
        private static method closeAction takes nothing returns nothing
            local SyncData d = GetSyncedData()
            local integer pid = GetPlayerId(d.from)
            local thistype this = player2Inventory[pid]
            local unit selectedUnit = GetMainSelectedUnit(d.readInt(0))
            local item item0
            local item itemSlot
            local framehandle pFrame
            local Slot slot
            local Table tb
            
            if LOCAL_PLAYER == GetTriggerPlayer() then
                call BlzFrameSetVisible(this.backdrop, false)
            endif
            
            call player2Inventory.remove(pid)
            
            set pFrame = playerFrame[pid]
            set playerFrame[pid] = null
            if pFrame != null then
                set slot = Slot.frame2Slot[GetHandleId(pFrame)]
                set tb = Slot.frame2Item[GetHandleId(pFrame)]
                set itemSlot = tb.item[GetHandleId(selectedUnit)]
                call SetItemPosition(itemSlot, WorldBounds.minX, WorldBounds.minY)
                call SetItemVisible(itemSlot, false)
                set itemSlot = null
                set pFrame = null
                
                if LOCAL_PLAYER == GetTriggerPlayer() then
                    call BlzFrameSetVisible(slot.indicator, false)
                    call BlzFrameSetVisible(dummyIcon, false)
                    call BlzFrameSetAllPoints(ORIGIN_ITEM_BUTTON_ONE, dummyFrame)
                    call BlzFrameSetEnable(dummyFrameEx, true)
                endif
                
                set item0 = Slot.unit2Item.item[GetHandleId(selectedUnit)]
                if item0 != null then
                    call UnitAddItem(selectedUnit, item0)
                    call UnitDropItemSlot(selectedUnit, item0, 0)
                    call Slot.unit2Item.item.remove(GetHandleId(selectedUnit))
                    set item0 = null
                endif
            endif
            
            set selectedUnit = null
            call d.destroy()
        endmethod
        
        private static method close takes nothing returns nothing
            local SyncData req = SyncData.create(GetTriggerPlayer())
            call UnfocusFrame(BlzGetTriggerFrame(), GetTriggerPlayer())
            set req.onComplete = Filter(function thistype.closeAction)
            call req.syncInt(GetSelectedUnitIndex())
        endmethod
        
        private static method open takes nothing returns nothing
            local thistype this = frame2Inventory[GetHandleId(BlzGetTriggerFrame())]
            call UnfocusFrame(BlzGetTriggerFrame(), GetTriggerPlayer())
            if LOCAL_PLAYER == GetTriggerPlayer() then
                call BlzFrameSetVisible(.backdrop, true)
            endif
            set player2Inventory[GetPlayerId(GetTriggerPlayer())] = this
        endmethod

        static method createEx takes integer slotCount, integer cols, real buttonSize, real spaceGap, real borderSize, real titleSize, real posX, real posY returns thistype
            local thistype this = allocate()
            local integer rows = slotCount/columns
            local integer i = 0
            local integer j = 0
            local real x = borderSize
            local real y = -borderSize - titleSize

            set .slotCount = slotCount
            set .columns = cols
            set .buttonSize = buttonSize
            set .spaceGap = spaceGap
            set .buttonSize = buttonSize
            set .borderSize = borderSize
            set .titleSize = titleSize

            set backdrop = BlzCreateFrame("QuestButtonBackdropTemplate", GAME_UI, 0, this)
            call BlzFrameSetSize(backdrop, columns*buttonSize + (columns - 1)*spaceGap + 2*borderSize, rows*buttonSize + (rows - 1)*spaceGap + 2*borderSize + titleSize)
            call BlzFrameSetAbsPoint(backdrop, FRAMEPOINT_CENTER, posX, posY)

            set title = BlzCreateFrameByType("TEXT", "InventoryTitle", backdrop, "", this)
            call BlzFrameSetSize(title, 0, titleSize)
            call BlzFrameSetPoint(title, FRAMEPOINT_CENTER, backdrop, FRAMEPOINT_TOP, 0, -borderSize*.75)
            call BlzFrameSetTextAlignment(title, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_TOP)
            call BlzFrameSetScale(title, 1.2)

//            set pageNumber = BlzCreateFrameByType("TEXT", "InventoryPage", backdrop, "", this)
//            call BlzFrameSetSize(pageNumber, 0, titleSize) 
//            call BlzFrameSetPoint(pageNumber, FRAMEPOINT_CENTER, backdrop, FRAMEPOINT_BOTTOM, 0, borderSize)
//            call BlzFrameSetTextAlignment(pageNumber, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
//            call BlzFrameSetText(pageNumber, "1")

            set openButton = BlzCreateFrameByType("GLUETEXTBUTTON", "InventoryOpen", GAME_UI, "", this)
            set openIcon = BlzCreateFrameByType("BACKDROP", "InventoryOpenIcon", openButton, "", this)
            call BlzFrameSetAllPoints(openIcon, openButton)
            
            set closeButton = BlzCreateFrame("ScriptDialogButton", backdrop, 0, this)
            call BlzFrameSetPoint(closeButton, FRAMEPOINT_TOPRIGHT, backdrop, FRAMEPOINT_TOPRIGHT, 0, 0)
            call BlzFrameSetSize(closeButton, buttonSize, buttonSize)
            call BlzFrameSetText(closeButton, "X")
            call BlzTriggerRegisterFrameEvent(closeTrigger, closeButton, FRAMEEVENT_CONTROL_CLICK)

//            set nextButton = BlzCreateFrame("ScriptDialogButton", backdrop, 0, this)
//            call BlzFrameSetPoint(nextButton, FRAMEPOINT_BOTTOMRIGHT, backdrop, FRAMEPOINT_BOTTOMRIGHT, 0, 0)
//            call BlzFrameSetSize(nextButton, buttonSize, buttonSize)
//            call BlzFrameSetText(nextButton, "→")
//
//            set prevButton = BlzCreateFrame("ScriptDialogButton", backdrop, 0, this)
//            call BlzFrameSetPoint(prevButton, FRAMEPOINT_BOTTOMLEFT, backdrop, FRAMEPOINT_BOTTOMLEFT, 0, 0)
//            call BlzFrameSetSize(prevButton, buttonSize, buttonSize)
//            call BlzFrameSetText(prevButton, "←")
//            call BlzFrameSetVisible(prevButton, false)

            set slots = IntegerList.create()
            loop
                exitwhen i == slotCount
                call slots.push(Slot.create(buttonSize, x, y, this))
                set x = x + spaceGap + buttonSize
                set j = j + 1
                if j == columns then
                    set j = 0
                    set x = borderSize
                    set y = y - spaceGap - buttonSize
                endif
                set i = i + 1
            endloop

            call BlzFrameSetVisible(backdrop, false)

            return this
        endmethod

        static method create takes nothing returns thistype
            local thistype this = allocate()

            set backdrop = BlzCreateFrame("QuestButtonBackdropTemplate", GAME_UI, 0, this)

            set title = BlzCreateFrameByType("TEXT", "InventoryTitle", backdrop, "", this)
            call BlzFrameSetTextAlignment(title, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_TOP)
            call BlzFrameSetScale(title, 1.2)

//            set pageNumber = BlzCreateFrameByType("TEXT", "InventoryPage", backdrop, "", this)
//            call BlzFrameSetTextAlignment(pageNumber, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
//            call BlzFrameSetText(pageNumber, "1")

            set openButton = BlzCreateFrameByType("GLUETEXTBUTTON", "InventoryOpen", GAME_UI, "", this)
            set openIcon = BlzCreateFrameByType("BACKDROP", "InventoryOpenIcon", openButton, "", this)
            call BlzFrameSetAllPoints(openIcon, openButton)
            set frame2Inventory[GetHandleId(openButton)] = this
            
            set closeButton = BlzCreateFrame("ScriptDialogButton", backdrop, 0, this)

            //set nextButton = BlzCreateFrame("ScriptDialogButton", backdrop, 0, this)

            //set prevButton = BlzCreateFrame("ScriptDialogButton", backdrop, 0, this)

            set slots = IntegerList.create()

            call BlzFrameSetVisible(backdrop, false)

            return this
        endmethod
        
        private static method init takes nothing returns nothing
            set GAME_UI = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
            set LOCAL_PLAYER = GetLocalPlayer()
            set player2Inventory = Table.create()
            set closeTrigger = CreateTrigger()
            call TriggerAddCondition(closeTrigger, Filter(function thistype.close))
            set openTrigger = CreateTrigger()
            call TriggerAddCondition(openTrigger, Filter(function thistype.open))
            set frame2Inventory = Table.create()
        endmethod
        
        implement MyModule
    endstruct
    
    private function MouseOnItem takes nothing returns nothing
        local integer index = HoverOriginButton_CurrentSelectedButtonIndex - HoverOriginButton_ItemButtonOffset
        if not IsMouseDraggingItem() then
            set originItemSlot = index
        endif
        if index > 0 then
            call BlzFrameSetEnable(dummyFrameEx, true)
            set originItemSlotEx = index
        endif
    endfunction
    
    private function MouseLeftItem takes nothing returns nothing
        if not IsMouseDraggingItem() then
            set originItemSlot = -1
        endif
        set originItemSlotEx = -1
    endfunction
    
    private function Init takes nothing returns nothing
        call HoverOriginButtonAdd(false, function MouseOnItem)
        call HoverOriginButtonAddClose(function MouseLeftItem)
        //set item2Unit = Table.create()
    endfunction
endlibrary
