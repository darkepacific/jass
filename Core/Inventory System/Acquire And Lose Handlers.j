library AcquireAndLoseItemHandler requires GenericFunctions
    
    function HasBanshees takes unit u returns boolean
        local integer playerNum = GetPlayerHeroNumber(GetOwningPlayer(u))
        local integer i = 1

        loop
            exitwhen i > 6
            if(GetItemTypeId(UnitItemInSlotBJ(u, i)) == 'I06Z' and BlzGetUnitAbilityCooldownRemaining(udg_Heroes[playerNum], 'ANss') <= 0.00) then
                call DestroyEffect(udg_Banshees[playerNum])
                call AddSpecialEffectTargetUnitBJ("origin", udg_Heroes[playerNum], "war3mapImported\\MagicShield_Blue.mdx")
                set udg_Banshees[playerNum] = GetLastCreatedEffectBJ()
                return true
            endif
            set i = i + 1
        endloop

        return false
    endfunction

    //Fires after the item is acquired
    function AcquireItemHandler takes unit u, item it returns nothing
        local player p = GetOwningPlayer(u)
        local integer playerNum = GetPlayerHeroNumber(p)
        local integer itemId = GetItemTypeId(it)
        local integer pItemsIndex = 0
        local integer statCalc = 0
        local boolean hasItem = false

        local integer i = 0

        set statCalc = (GetHeroStatBJ(bj_HEROSTAT_INT, u, true) - GetHeroStatBJ(bj_HEROSTAT_INT, u, false) - udg_PrevBONUSInt[playerNum] )
        call Debug("Acquire Itm: " + GetItemName(it) + " Int Incr: " + I2S(statCalc) )

        // Update P_Items with the newly equipped item
        set udg_P_Items[GetPItemsCurrentIndex(p, GetUnitItemSlot(u, it))] = it
    
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
            call HasBanshees(u)
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

    //Fires before the item is lost
    // Called whenever an item leaves a hero's active inventory — either via the
    // native trigger (drop/pawn) or directly from TasItemBag UI actions.
    function LoseItemHandler takes unit u, item it returns nothing
        local player p = GetOwningPlayer(u)
        local integer playerNum = GetPlayerHeroNumber(p)
        local integer itemId = GetItemTypeId(it)
        local integer pItemsIndex = 0
        local integer statCalc = 0
        local boolean hasItem = false
        local integer i = 0

        call Debug("Losing Item: " + GetItemName(it) + " from player: " + I2S(playerNum) )
        
        // Find which slot the item was dropped from and clear it in P_Items
        set i = 1
        loop
            exitwhen i > 6
            set pItemsIndex = GetPItemsCurrentIndex(p, i)
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

endlibrary