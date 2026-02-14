function CleanUpItems_RemoveAllItemsOfType takes nothing returns nothing
    if(GetItemTypeId(GetEnumItem()) == udg_ItemTypeCheck) then
        call RemoveItem(GetEnumItem() )
    endif
endfunction

function CleanUpItemsGround takes integer it returns nothing
    set udg_ItemTypeCheck = it
    call EnumItemsInRectBJ(GetPlayableMapRect(), function CleanUpItems_RemoveAllItemsOfType )
endfunction

function CleanUpItems_Enum takes nothing returns nothing
    local player p = GetEnumPlayer()
    local integer i = GetPlayerBagNumber(p) + 1
    
    loop
        exitwhen i >=  GetPlayerBagNumber(p) + udg_BAG_SIZE
        if GetItemTypeId(udg_P_Items[i]) == udg_ItemTypeCheck then
            call RemoveItem(udg_P_Items[i])
            set udg_P_Items[i] = null
        endif
        
        set i = i + 1
    endloop

    set p = null
endfunction

function CleanUpItems_Alliance takes integer it returns nothing
    set udg_ItemTypeCheck = it
    call ForForce(udg_AlliancePlayers, function CleanUpItems_Enum)
endfunction

function CleanUpItems_Horde takes integer it returns nothing
    set udg_ItemTypeCheck = it
    call ForForce(udg_HordePlayers, function CleanUpItems_Enum)
endfunction

function CleanUpItems takes integer it returns nothing
    set udg_ItemTypeCheck = it
    call CleanUpItems_Alliance(it)
    call CleanUpItems_Horde(it)
    call CleanUpItemsGround(it)
endfunction