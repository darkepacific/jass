function Trig_Acquire_Item_Conditions takes nothing returns boolean
    if IsPlayerHero(GetTriggerUnit()) then
        if GetItemType(GetManipulatedItem()) != ITEM_TYPE_POWERUP then
            if GetItemTypeId(GetManipulatedItem()) != 'I07W' then //Syndicate Missive
                return true
            endif
        endif
    endif
    return false
endfunction

//Fires after the item is acquired
function Trig_Acquire_Item_Actions takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local player p = GetOwningPlayer(u)
    local integer playerNum = GetPlayerHeroNumber(p)
    local item it = GetManipulatedItem()
    local integer itemId = GetItemTypeId(it)
    local integer pItemsIndex = 0
    local integer statCalc = 0
    local boolean hasItem = false
    
    local integer i = 0

    set statCalc = (GetHeroStatBJ(bj_HEROSTAT_INT, u, true) - GetHeroStatBJ(bj_HEROSTAT_INT, u, false) - udg_PrevBONUSInt[playerNum] )
    call Debug("Acquire Itm: " + GetItemName(it) + " Int Incr: " + I2S(statCalc) )

    // Update P_Items with the newly equipped item
    set udg_P_Items[GetCurrentPItemsIndex(p, GetUnitItemSlot(u, it))] = it
    
    // Non-Cap Custom Value Set
    if(itemId != 'I06Y') then
        call SetItemUserData(it, statCalc )
    else
        call SetItemUserData(it, 0 )
    endif
    
    // First Time Acquiring Warmogs    
    if(itemId == 'I06P' and udg_Warmogs[playerNum] == null) then
        set udg_Warmogs[playerNum] = it
        call BlzItemAddAbility(udg_Warmogs[playerNum], 'A00T' )
    endif

    // Flamewalkers
    if(itemId == 'I06T') then
        // Remove old buff
        set statCalc = ( (S2I(SubStringBJ(BlzGetItemDescription(it), 226, 228)) - 20) / 3 )
        call BlzItemRemoveAbility(it, udg_InitFlamewalkers[statCalc] )
        // Add new buffs
        set statCalc = GetUnitLevel(u)
        call BlzItemAddAbility(it, udg_InitFlamewalkers[statCalc] )
        set statCalc = ( (statCalc * 3) + 20 )
        call BlzSetItemDescription(it, ("+6 Armor +400 Health +8 Strength |n|n|cccFFaa00Non-Stacking Passive:|r Nearby enemies take |cffffcc00|r|cffffcc0020|r + |cffffcc00|r|cffffcc003|r x Hero Level|r magic damage per second. |n|cccFFaa00Current Bonus:|r |cffffcc00" + (I2S(statCalc) + " |rdps") ) )
        call BlzSetItemExtendedTooltip(it, ("+6 Armor +400 Health +8 Strength |n|n|cccFFaa00Non-Stacking Passive:|r Nearby enemies take |cffffcc00|r|cffffcc0020|r + |cffffcc00|r|cffffcc003|r x Hero Level|r magic damage per second. |n|cccFFaa00Current Bonus:|r |cffffcc00" + (I2S(statCalc) + " |rdps") ) )
    endif

    // Banshees/Elune's Veil
    if(itemId == 'I06Z') then
        set i = 1
        loop
            exitwhen i > 6
            if(GetItemTypeId(UnitItemInSlotBJ(u, i)) == 'I06Z' and BlzGetUnitAbilityCooldownRemaining(udg_Heroes[playerNum], 'ANss') <= 0.00) then
                call DestroyEffect(udg_Banshees[playerNum])
                call AddSpecialEffectTargetUnitBJ("origin", udg_Heroes[playerNum], "war3mapImported\\MagicShield_Blue.mdx")
                set udg_Banshees[playerNum] = GetLastCreatedEffectBJ()
                exitwhen true
            endif
            set i = i + 1
        endloop

    endif

    // Dummy Orb Swap
    set udg_Temp_Item = it
    if not IsMultiShotForm(u) then
        call TriggerExecute(gg_trg_Orb_Added_No_Loop)
    else
        call TriggerExecute(gg_trg_Orb_Removal_No_Loop)
    endif

    // First Time Acquiring Cap
    if(itemId == 'I06Y' and udg_DeathCap[playerNum] == null) then
        set udg_DeathCap[playerNum] = it
    endif

    // Calculate Int Increase for Cap
    if(udg_DeathCap[playerNum] != null) then
        // Cap has its own +20
        // Remove old buff
        call BlzItemRemoveAbility(udg_DeathCap[playerNum], udg_InitDeathCap[GetItemUserData(udg_DeathCap[playerNum])])

        // Add new buffs
        set statCalc = GetHeroStatBJ(bj_HEROSTAT_INT, u, true) - GetHeroStatBJ(bj_HEROSTAT_INT, u, false) 
        set statCalc = statCalc / 3 
        call BlzItemAddAbility(udg_DeathCap[playerNum], udg_InitDeathCap[statCalc] )
        call SetItemUserData(udg_DeathCap[playerNum], statCalc )
        call BlzSetItemDescription(udg_DeathCap[playerNum],("+2 Armor +20 Intelligence |n|n|c00CC44FFNon-Stacking Passive:|r Boosts the wearer's bonus Intelligence by an additonal 33%. |n|cc00096FFCurrent Bonus:|r |cffffcc00" + I2S(statCalc) + " |r") )
        call BlzSetItemExtendedTooltip(udg_DeathCap[playerNum],("+2 Armor +20 Intelligence |n|n|c00CC44FFNon-Stacking Passive:|r Boosts the wearer's bonus Intelligence by an additonal 33%. |n|cc00096FFCurrent Bonus:|r |cffffcc00" + I2S(statCalc) + " |r") )
    endif

    set udg_PrevBONUSInt[playerNum] = GetHeroStatBJ(bj_HEROSTAT_INT, u, true) - GetHeroStatBJ(bj_HEROSTAT_INT, u, false) 

    set u = null
    set it = null
    set p = null
endfunction

//===========================================================================
function InitTrig_Acquire_Item takes nothing returns nothing
    set gg_trg_Acquire_Item = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Acquire_Item, EVENT_PLAYER_UNIT_PICKUP_ITEM )
    call TriggerAddCondition(gg_trg_Acquire_Item, Condition(function Trig_Acquire_Item_Conditions) )
    call TriggerAddAction(gg_trg_Acquire_Item, function Trig_Acquire_Item_Actions )
endfunction

