function CreateItemsFromDropTable takes location point returns nothing
    local integer index = 0
    local real draw = GetRandomReal(1, 100)
    // call Debug("Roll: " + R2S(draw))

    //First Set
    loop
        // call Debug(R2S(udg_ItemDropPerc[index]))
        if (udg_ItemDropPerc[index] == 0) or index >= 10 then // Check for a null entry
            // call Debug("Null Entry")
            exitwhen true
        endif

        if index > 0 then
            set udg_ItemDropPerc[index] = udg_ItemDropPerc[index] + udg_ItemDropPerc[index - 1]
        endif
        // call Debug("New: " + R2S(udg_ItemDropPerc[index]))
        if(draw <= udg_ItemDropPerc[index]) then
            call CreateItemLoc( udg_ItemDropTable[index], point )
            // call Debug("Item Created: " + GetItemName(bj_lastCreatedItem))
            exitwhen true
        endif
        set index = index + 1
    endloop

    set draw = GetRandomReal(1, 100)
    set index = 10

    //Second Set
    loop
        if (udg_ItemDropPerc[index] == 0) or index >= 20 then
            exitwhen true
        endif

        if index > 10 then
            set udg_ItemDropPerc[index] = udg_ItemDropPerc[index] + udg_ItemDropPerc[index - 1]
        endif
        if(draw <= udg_ItemDropPerc[index]) then
            call CreateItemLoc( udg_ItemDropTable[index], point )
            exitwhen true
        endif
        set index = index + 1
    endloop

    //Clean Up for next run
    set index = 0
    loop
        if index >= 40 then
            exitwhen true
        endif

        set udg_ItemDropPerc[index] = 0
        set index = index + 1
    endloop

endfunction