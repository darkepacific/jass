function Trig_Inventory_Debug_Actions takes nothing returns nothing
    local player p = GetTriggerPlayer()
    local integer playerNum = GetPlayerHeroNumber(p)
    local integer page = 1
    local integer slot = 1
    local integer pItemsIndex = 0
    local item currentItem = null
    local string itemName = ""
    local string output = ""
    
    call DisplayTextToPlayer(p, 0, 0, "|cffFFFF00=== INVENTORY DEBUG FOR PLAYER " + I2S(playerNum) + " ===|r")
    call DisplayTextToPlayer(p, 0, 0, "|cffFFFF00Current Page: " + I2S(udg_Bag_Page[playerNum]) + "|r")
    call DisplayTextToPlayer(p, 0, 0, "")
    
    // Loop through all 3 pages
    loop
        exitwhen page > 3
        call DisplayTextToPlayer(p, 0, 0, "|cff00FFFF--- PAGE " + I2S(page) + " ---:|r")
        
        set slot = 1
        loop
            exitwhen slot > 6
            set pItemsIndex = GetPItemsIndex(p, page, slot)
            set currentItem = udg_P_Items[pItemsIndex]
            
            if currentItem != null then
                set itemName = GetItemName(currentItem)
                set output = "  Slot " + I2S(slot) + ": " + itemName
                if page == udg_Bag_Page[playerNum] then
                    set output = output + " |cff00FF00(EQUIPPED)|r"
                endif
            else
                set output = "  Slot " + I2S(slot) + ": |cff808080(Empty)|r"
            endif
            
            call DisplayTextToPlayer(p, 0, 0, output)
            set slot = slot + 1
        endloop
        
        call DisplayTextToPlayer(p, 0, 0, "")
        set page = page + 1
    endloop
    
    call DisplayTextToPlayer(p, 0, 0, "|cffFFFF00=== END INVENTORY DEBUG ===|r")
endfunction

function Trig_Inventory_Debug_Conditions takes nothing returns boolean
    return GetEventPlayerChatString() == "-i"
endfunction

//===========================================================================
function InitTrig_Inventory_Debug takes nothing returns nothing
    local integer i = 0
    set gg_trg_Inventory_Debug = CreateTrigger()
    
    loop
        call TriggerRegisterPlayerChatEvent(gg_trg_Inventory_Debug, Player(i), "-i", true)
        set i = i + 1
        exitwhen i > 11
    endloop
    
    call TriggerAddCondition(gg_trg_Inventory_Debug, Condition(function Trig_Inventory_Debug_Conditions))
    call TriggerAddAction(gg_trg_Inventory_Debug, function Trig_Inventory_Debug_Actions)
endfunction
