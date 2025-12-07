function Trig_Lose_Item_Conditions takes nothing returns boolean
    if IsPlayerHero(GetTriggerUnit()) then
        if GetItemType(GetManipulatedItem()) != ITEM_TYPE_POWERUP then
            if  GetItemTypeId(GetManipulatedItem()) != 'I07W' then //Syndicate Missive
                return true
            endif
        endif
    endif
    return false
endfunction

//Fires before the item is lost
function Trig_Lose_Item_Actions takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local player p = GetOwningPlayer(u)
    local integer playerNum = GetPlayerHeroNumber(p)
    local item it = GetManipulatedItem()
    local integer itemId = GetItemTypeId(it)
    local integer pItemsIndex = 0
    local integer statCalc = 0
    local boolean hasItem = false
    
    local integer i = 0
        
    // Find which slot the item was dropped from and clear it in P_Items
    set i = 1
    loop
        exitwhen i > 6
        set pItemsIndex = GetCurrentPItemsIndex(p, i)
        if udg_P_Items[pItemsIndex] == it then
            set udg_P_Items[pItemsIndex] = null
            exitwhen true
        endif
        set i = i + 1
    endloop

    call Debug("Lost Itm: " + GetItemName(it) + " Int Decr: " + I2S(GetItemUserData(it) ) )


    // Remove old buff
    call BlzItemRemoveAbility(udg_DeathCap[playerNum], udg_InitDeathCap[GetItemUserData(udg_DeathCap[playerNum])] )
    call SetItemUserData(udg_DeathCap[playerNum], 0 )
    
    // lost death cap
    if udg_DeathCap[playerNum] == it then
        
        // check if there is another deathcap
        set i = 1
        loop
            exitwhen i > 6
            if(GetItemTypeId(UnitItemInSlotBJ(u, i)) == 'I06Y' and udg_DeathCap[playerNum] != UnitItemInSlotBJ(u, i) ) then
                set udg_DeathCap[playerNum] = UnitItemInSlotBJ(u, i)
                call Debug("Found another Cap in slot: " + I2S(i) )
                set hasItem = true
                exitwhen true
            endif
            set i = i + 1
        endloop
        
        if hasItem == false then
            set udg_DeathCap[playerNum] = null
        endif
    endif

    // lost another item or have a second cap
    if(udg_DeathCap[playerNum] != null) then
        set statCalc = GetHeroStatBJ(bj_HEROSTAT_INT, u, true) - GetHeroStatBJ(bj_HEROSTAT_INT, u, false) - GetItemUserData(it)
        if(GetItemTypeId(it) == 'I06Y') then
            set statCalc = (statCalc - 20 )
        endif
        set statCalc = statCalc / 3 
        call SetItemUserData(udg_DeathCap[playerNum], statCalc )
        call BlzItemAddAbility(udg_DeathCap[playerNum], udg_InitDeathCap[statCalc] )
        call BlzSetItemDescription(udg_DeathCap[playerNum],("+2 Armor +20 Intelligence |n|n|c00CC44FFNon-Stacking Passive:|r Boosts the wearer's bonus Intelligence by an additonal 33%. |n|cc00096FFCurrent Bonus:|r |cffffcc00" + I2S(statCalc) + " |r") )
        call BlzSetItemExtendedTooltip(udg_DeathCap[playerNum],("+2 Armor +20 Intelligence |n|n|c00CC44FFNon-Stacking Passive:|r Boosts the wearer's bonus Intelligence by an additonal 33%. |n|cc00096FFCurrent Bonus:|r |cffffcc00" + I2S(statCalc) + " |r") )
    endif

    // lost warmogs
    if(udg_Warmogs[playerNum] == it) then
        call BlzItemRemoveAbility(udg_Warmogs[playerNum], 'A00T' )

        // Check if there is another warmogs
        set i = 1
        loop
            exitwhen i > 6
            if(GetItemTypeId(UnitItemInSlotBJ(u, i)) == 'I06P' and udg_Warmogs[playerNum] != UnitItemInSlotBJ(u, i) ) then
                set udg_Warmogs[playerNum] = UnitItemInSlotBJ(u, i)
                call BlzItemAddAbility(udg_Warmogs[playerNum], 'A00T' )
                set hasItem = true
                exitwhen true
            endif
            set i = i + 1
        endloop

        if hasItem == false then
            set udg_Warmogs[playerNum] = null
        endif
    endif

    // lost banshees
    if(itemId == 'I06Z') then
        set i = 1
        
        loop
            exitwhen i > 6
            if(GetItemTypeId(UnitItemInSlotBJ(u, i)) == 'I06Z' and it != UnitItemInSlotBJ(u, i) ) then
                set hasItem = true
                exitwhen true
            endif
            set i = i + 1
        endloop

        if hasItem == false then
            call DestroyEffectBJ(udg_Banshees[playerNum])
        endif
    endif

    // set prevBONUSInt
    set udg_PrevBONUSInt[playerNum] = GetHeroStatBJ(bj_HEROSTAT_INT, u, true) - GetHeroStatBJ(bj_HEROSTAT_INT, u, false) - GetItemUserData(it)
    if(GetItemTypeId(it) == 'I06Y') then
        set udg_PrevBONUSInt[playerNum] = (udg_PrevBONUSInt[playerNum] - 20 )
    endif
    call SetItemUserData(it, 0 )

    set u = null
    set it = null
    set p = null
endfunction

//===========================================================================
function InitTrig_Lose_Item takes nothing returns nothing
    set gg_trg_Lose_Item = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Lose_Item, EVENT_PLAYER_UNIT_DROP_ITEM )
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Lose_Item, EVENT_PLAYER_UNIT_PAWN_ITEM )
    call TriggerAddCondition(gg_trg_Lose_Item, Condition(function Trig_Lose_Item_Conditions) )
    call TriggerAddAction(gg_trg_Lose_Item, function Trig_Lose_Item_Actions )
endfunction

