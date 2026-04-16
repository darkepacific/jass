
library TasItemShopLite initializer init_function requires TasButtonList, optional FrameLoader
/*    TasItemShopLite by Tasyen
An custom ui to buy items from a big pool and with a search bar, selecting a shop shows the ui.

 function TasItemShopAddShop takes integer unitCode, integer itemCode returns nothing
    adds itemcode for that shop, it should have the ability Asid and select Hero/unit
    unitCode is either GetUnitTypeId 'n000' or GetHandleId

easier use wrappers
 function TasItemShopAddShopUnit takes unit u, integer itemCode returns nothing
 function TasItemShopAddShop5 takes integer unitCode, integer a, integer b, integer c, integer d, integer e returns nothing
 function TasItemShopAddShop5Unit takes unit u, integer a, integer b, integer c, integer d, integer e returns nothing
*/
globals
    public boolean AutoRun = true //(true) will create Itself at 0s, (false) you need to InitSpellView()
    public string TocPath = "war3mapImported\\Templates.toc"    
    
    public trigger TriggerSelect
    public trigger TriggerESC
    public integer buttonListRows = 5
    public integer buttonListCols = 3
    public real buttonListButtonGapCol = 0.001
    public real buttonListButtonGapRow = 0.005

    public unit array CurrentShop

    public framehandle FrameBox
    public framehandle FrameParentSuper
    public framehandle FrameTitelText  
    public framehandle FrameMouseListener  
    public framehandle FrameParentList
    
    
    public integer ButtonListIndex // this is the index of the used TasButtonList.

    public hashtable Items = null // what can be bought [unit] = {itemCode1, ItemCode2, ...} > [unitCode] = {itemCode1, ItemCode2, ...}

// which button is used inside the ButtonList? Enable one block and disable the other one
//public string buttonListButtonName = "TasButtonSmall"
//public real buttonListButtonSizeX = 0.1
//public real buttonListButtonSizeY = 0.0325

// "TasButtonGrid" are smaller, they don't show the names in the list
public string buttonListButtonName = "TasButtonGrid"
public real buttonListButtonSizeX = 0.064
public real buttonListButtonSizeY = 0.0265

//public string buttonListButtonName = "TasButton"
//public real buttonListButtonSizeX = 0.2
//public real buttonListButtonSizeY = 0.0265

endglobals
public function ParentFunc takes nothing returns framehandle // who is the parent of this UI
    return BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
endfunction
public function Pos takes framehandle frame returns nothing
    // position of the whole Shop UI
    call BlzFrameSetAbsPoint(frame, FRAMEPOINT_TOPRIGHT, 0.79, 0.55)
endfunction
public function TooltipPos takes framehandle tooltip, framehandle buttonFrame returns nothing
    // position of the tooltips
    call BlzFrameClearAllPoints(tooltip)
    //call BlzFrameSetPoint(tooltip, FRAMEPOINT_TOPRIGHT, buttonFrame, FRAMEPOINT_BOTTOMRIGHT, 0, -0.052)
    call BlzFrameSetPoint(tooltip, FRAMEPOINT_TOPRIGHT, FrameBox, FRAMEPOINT_TOPLEFT, 0, -0.052)
    //call BlzFrameSetAbsPoint(tooltip, FRAMEPOINT_TOPRIGHT, 0, -0.052)
endfunction
// config ende

function TasItemShopAddShop takes integer unitCode, integer itemCode returns nothing
    local integer newIndex
    if itemCode <= 0 then
        return
    endif
    set newIndex = LoadInteger(Items, unitCode, 0) + 1
    call SaveInteger(Items, unitCode, newIndex, itemCode)
    call SaveInteger(Items, unitCode, 0, newIndex)
    call TasItemCaclCost(itemCode)
endfunction

function TasItemShopAddShop5 takes integer unitCode, integer a, integer b, integer c, integer d, integer e returns nothing
    call TasItemShopAddShop(unitCode, a)
    call TasItemShopAddShop(unitCode, b)
    call TasItemShopAddShop(unitCode, c)
    call TasItemShopAddShop(unitCode, d)
    call TasItemShopAddShop(unitCode, e)
endfunction
function TasItemShopAddShopUnit takes unit u, integer itemCode returns nothing
    call TasItemShopAddShop(GetHandleId(u), itemCode)
endfunction
function TasItemShopAddShop5Unit takes unit u, integer a, integer b, integer c, integer d, integer e returns nothing
    call TasItemShopAddShop5(GetHandleId(u), a, b, c, d, e)
endfunction

public function updateItemFrame takes integer createContext, integer data returns nothing
    local integer lumber = TasItemGetCostLumber(data)
    local integer gold = TasItemGetCostGold(data)
    local integer playerIndex = GetPlayerId(GetLocalPlayer())
    call BlzFrameSetTexture(BlzGetFrameByName("TasButtonIcon", createContext),  BlzGetAbilityIcon(data), 0, false)
    call BlzFrameSetText(BlzGetFrameByName("TasButtonText", createContext), GetObjectName(data))

    call BlzFrameSetTexture(BlzGetFrameByName("TasButtonListTooltipIcon", createContext), BlzGetAbilityIcon(data), 0, false)
    call BlzFrameSetText(BlzGetFrameByName("TasButtonListTooltipName", createContext), GetObjectName(data))
    call BlzFrameSetText(BlzGetFrameByName("TasButtonListTooltipText", createContext), BlzGetAbilityExtendedTooltip(data, 0))

    if GetPlayerState(GetLocalPlayer(), PLAYER_STATE_RESOURCE_GOLD) >= gold then
        call BlzFrameSetText(BlzGetFrameByName("TasButtonTextGold", createContext), I2S(gold))
    else
        call BlzFrameSetText(BlzGetFrameByName("TasButtonTextGold", createContext), "|cffff2010" + I2S(gold))
    endif

    if GetPlayerState(GetLocalPlayer(), PLAYER_STATE_RESOURCE_LUMBER) >= lumber then
        call BlzFrameSetText(BlzGetFrameByName("TasButtonTextLumber", createContext), I2S(lumber))
    else
        call BlzFrameSetText(BlzGetFrameByName("TasButtonTextLumber", createContext), "|cffff2010" + I2S(lumber))
    endif
endfunction
public function updateItemFrameAction takes nothing returns nothing
    //TasButtonListFrame
   //TasButtonListData
   //TasButtonListIndex
    local integer buttonIndex = S2I(BlzFrameGetText(TasButtonListFrame))
    local integer context = TasButtonListCreateContext[TasButtonListIndex] + buttonIndex
       
    //call BJDebugMsg("updateItemFrameAction" + " context: " + I2S(context) + " buttonIndex: " + I2S(buttonIndex))
    call updateItemFrame(context, TasButtonListData)
endfunction
public function Show takes player p, unit shop returns nothing
    local integer playerIndex = GetPlayerId(p)
    local integer shopHandle = GetHandleId(shop)
    local integer shopCode = GetUnitTypeId(shop)
    local boolean flag = (shopCode > 0)
    local unit oldShop
    local boolean isNewShop
    local integer i = 1
    local integer dataKey = 0
    if flag and not HaveSavedInteger(Items, shopCode, 0) and not HaveSavedInteger(Items, shopHandle, 0) then
        set flag = false
    endif
    if p == GetLocalPlayer() then
        call BlzFrameSetVisible(FrameParentSuper, flag)
    endif
    
    if flag then
        set oldShop = CurrentShop[playerIndex]
        set isNewShop = oldShop != shop
        set CurrentShop[playerIndex] = shop
        
        if isNewShop then
            call TasButtonListClearDataEx(ButtonListIndex, playerIndex)
            if HaveSavedInteger(Items, shopHandle, 0) then
                set dataKey = shopHandle
            else
                if HaveSavedInteger(Items, shopCode, 0) then
                    set dataKey = shopCode
                endif
            endif
            if dataKey > 0 then
                loop
                    exitwhen not HaveSavedInteger(Items, dataKey, i)
                    call TasButtonListAddDataEx(ButtonListIndex, LoadInteger(Items, dataKey, i), playerIndex)
                    set i = i + 1
                endloop
            endif
        endif
        if GetLocalPlayer() == p then
            call BlzFrameSetText(FrameTitelText, GetUnitName(shop))
            
            if isNewShop then
                call TasButtonListSearch(ButtonListIndex, null)
            endif
        endif
        call UpdateTasButtonList(ButtonListIndex)
    else
        set CurrentShop[playerIndex] = null
    endif
    set oldShop = null
endfunction
public function BuyItem takes player p, integer itemCode returns nothing
    local integer playerIndex = GetPlayerId(p)
    local integer gold = TasItemGetCostGold(itemCode)
    local integer lumber = TasItemGetCostLumber(itemCode)

    if GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) >= gold then
        if GetPlayerState(p, PLAYER_STATE_RESOURCE_LUMBER) >= lumber then
            call AddItemToStock(CurrentShop[playerIndex], itemCode, 1, 1)
            call IssueNeutralImmediateOrderById(p, CurrentShop[playerIndex], itemCode)
            call RemoveItemFromStock(CurrentShop[playerIndex], itemCode)
            call Show(p, CurrentShop[playerIndex])
        elseif not GetSoundIsPlaying(SoundNoLumber[GetHandleId(GetPlayerRace(p))]) then
            call StartSoundForPlayerBJ(p, SoundNoLumber[GetHandleId(GetPlayerRace(p))])
        endif
    elseif not GetSoundIsPlaying(SoundNoGold[GetHandleId(GetPlayerRace(p))]) then
        call StartSoundForPlayerBJ(p, SoundNoGold[GetHandleId(GetPlayerRace(p))])
    endif
endfunction
private function ButtonListFunction_Search takes nothing returns boolean
    //TasButtonListText
    //TasButtonListData
    //TasButtonListIndex
    local string text = StringCase(TasButtonListText, false)
    if FindIndex(StringCase(BlzGetAbilityTooltip(TasButtonListData, 0), false), text) >= 0 then
     return true 
    endif
    if FindIndex(StringCase(BlzGetAbilityExtendedTooltip(TasButtonListData, 0), false), text) >= 0 then 
    return true
     endif
    return FindIndex(StringCase(GetObjectName(TasButtonListData),false), text) >= 0
endfunction
private function ButtonListFunction_LeftClick takes nothing returns nothing
    call BuyItem(GetTriggerPlayer(), TasButtonListData)    
endfunction

public function InitFrames takes nothing returns nothing
    local boolean loaded = BlzLoadTOCFile(TocPath)
    local integer loopA 
    local framehandle parent
    local framehandle frame
    //local  object
    set parent = ParentFunc()
    // super
    set FrameParentSuper = BlzCreateFrameByType("FRAME", "TasItemShopUI", parent, "", 0)
    set FrameBox = BlzCreateFrameByType("BACKDROP", "TasItemShopUIBox", FrameParentSuper, "EscMenuControlBackdropTemplate", 0)
    set parent = BlzCreateFrameByType("FRAME", "TasItemShopUI", FrameParentSuper, "", 0)
    call BlzFrameSetSize(parent, 0.01, 0.01)
    call Pos(parent)
    set FrameParentList = parent

    set FrameMouseListener = BlzCreateFrameByType("SLIDER", "TasItemShopUI", FrameParentList, "", 0)
        
    // ButtonList
    set ButtonListIndex = CreateTasButtonList10(buttonListButtonName, buttonListCols, buttonListRows, FrameParentList, function ButtonListFunction_LeftClick, null, function updateItemFrameAction, function ButtonListFunction_Search, null, null, null, buttonListButtonGapCol, buttonListButtonGapRow)
    set frame = BlzGetFrameByName(TasButtonListButtonName[ButtonListIndex], TasButtonListCreateContext[ButtonListIndex] + 1)
    call BlzFrameClearAllPoints(frame)
    //call BlzFrameSetPoint(frame, FRAMEPOINT_TOPRIGHT, FrameCategoryBox, FRAMEPOINT_BOTTOMRIGHT, -0.014, 0)
    call BlzFrameSetPoint(frame, FRAMEPOINT_TOPRIGHT, TasButtonListInputFrame[ButtonListIndex], FRAMEPOINT_BOTTOMRIGHT, -0.0045 - (buttonListCols - 1)*(BlzFrameGetWidth(frame) +buttonListButtonGapCol), -0.015)
    set loopA = buttonListRows*buttonListCols
    loop
        exitwhen loopA <= 0
        set frame = BlzGetFrameByName("TasButtonListTooltipText", TasButtonListCreateContext[ButtonListIndex] + loopA)
        call TooltipPos(BlzGetFrameByName("TasButtonListTooltipText", TasButtonListCreateContext[ButtonListIndex] + loopA), BlzGetFrameByName(TasButtonListButtonName[ButtonListIndex], TasButtonListCreateContext[ButtonListIndex] + loopA))
       
        set loopA = loopA - 1
    endloop

    set frame = BlzCreateFrame("TasButtonTextTemplate", FrameParentList, 0, 0)
    call BlzFrameSetPoint(frame, FRAMEPOINT_TOPRIGHT, TasButtonListInputFrame[ButtonListIndex], FRAMEPOINT_BOTTOMRIGHT, -0.002, 0)
    call BlzFrameSetTextAlignment(frame, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
    call BlzFrameSetPoint(frame, FRAMEPOINT_BOTTOMLEFT, BlzGetFrameByName(TasButtonListButtonName[ButtonListIndex], TasButtonListCreateContext[ButtonListIndex] + 1), FRAMEPOINT_TOPLEFT, 0, 0)
    call BlzFrameSetText(frame, "Name")
    set FrameTitelText = frame

   // BlzFrameSetSize(this.ButtonList.Head, BlzFrameGetWidth(this.ButtonList.Head), BlzFrameGetHeight(this.ButtonList.Head) + 0.01)
   // call BlzFrameSetPoint(FrameMouseListener, FRAMEPOINT_TOPLEFT, BlzGetFrameByName(TasButtonListButtonName[ButtonListIndex], TasButtonListCreateContext[ButtonListIndex] + 1), FRAMEPOINT_TOPLEFT, 0, 0)
    //call BlzFrameSetAllPoints(FrameMouseListener, this.ButtonList.TotalFrame)
    //call TasSliderAction(FrameMouseListener, nil, cols, this.ButtonList.Slider)

    call BlzFrameSetPoint(FrameBox, FRAMEPOINT_TOPRIGHT, TasButtonListInputFrame[ButtonListIndex], FRAMEPOINT_TOPRIGHT, 0.003, 0.003)
    call BlzFrameSetPoint(FrameBox, FRAMEPOINT_BOTTOMLEFT, BlzGetFrameByName(TasButtonListButtonName[ButtonListIndex], TasButtonListCreateContext[ButtonListIndex] + buttonListRows*buttonListCols - (buttonListCols - 1)), FRAMEPOINT_BOTTOMLEFT, -0.003, -0.003)
    call BlzFrameSetVisible(FrameParentSuper, false)
endfunction




public function CreateTriggerEx takes code action returns trigger
    local trigger t = CreateTrigger()
    call TriggerAddAction(t, action)
    return t
endfunction
public function TriggerFuctionESC takes nothing returns nothing
    call Show(GetTriggerPlayer(), null)
endfunction 
public function TriggerFuctionSelect takes nothing returns nothing
    call Show(GetTriggerPlayer(), GetTriggerUnit())
endfunction
function Init takes nothing returns nothing
    local integer i
    if GetExpiredTimer() != null then
        call PauseTimer(GetExpiredTimer())
        call DestroyTimer(GetExpiredTimer())
    endif    
    call InitFrames()
    //this.SoundConfig()
    static if LIBRARY_FrameLoader then
        call FrameLoaderAdd(function InitFrames)
    endif
    
    set TriggerSelect = CreateTriggerEx(function TriggerFuctionSelect)
    call TriggerRegisterAnyUnitEventBJ(TriggerSelect, EVENT_PLAYER_UNIT_SELECTED)

    set TriggerESC = CreateTriggerEx(function TriggerFuctionESC)
    set i = bj_MAX_PLAYER_SLOTS - 1
    loop
        exitwhen i < 0
        call TriggerRegisterPlayerEventEndCinematic(TriggerESC, Player(i))
        set i = i - 1
    endloop
endfunction
public function init_function takes nothing returns nothing    
    set Items = InitHashtable()
    if AutoRun then
        call TimerStart(CreateTimer(), 0, false, function Init)
    endif
endfunction


endlibrary