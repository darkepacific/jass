//===========================================================================
function Trig_Soul_Drain_Dies_Actions takes nothing returns nothing
    local boolean fired = false
    local boolean hasShard = false
    local boolean hasSpace = false
    local location pt
    local unit u = GetTriggerUnit()
    local item it
    local player p
    local integer Equipped_Page
    local integer page
    local integer i
    local integer arrIndex

    if GetTriggerUnit() == udg_SpellUnits[udg_z_WL_DEMO_A + 4] then
        set u = udg_yA_Demon_Warlock
        set fired = true
    elseif GetTriggerUnit() == udg_SpellUnits[udg_z_WL_DEMO_H + 4] then
        set u = udg_yH_Demon_Warlock
        set fired = true
    endif


    if fired then
        set p = GetOwningPlayer(u)
        set Equipped_Page = udg_Bag_Page[GetPlayerNumber(p)]
        call SetBagNumber(p)


        // First Check if they already have one across all bags, if so increment its charge
        set i = 1
        loop
            exitwhen i > 36
            set it = udg_P_Items[(udg_Bag_Num + i)]
            if it != null and GetItemTypeId(it) == 'I08E' and BlzGetItemIntegerField(it, ITEM_IF_NUMBER_OF_CHARGES) < 20 then
                call SetItemCharges(it, (GetItemCharges(it) + 1))
                set hasShard = true
                exitwhen true
            endif
            set i = i + 1
        endloop

        // If not already have one, then make a new one
        if not hasShard then
            // First try to add to the extended bag slots (P_Items 13..36)
            set i = 1
            loop
                exitwhen i > 24
                set arrIndex = udg_Bag_Num + 12 + i
                if udg_P_Items[arrIndex] == null then
                    set pt = GetRectCenter(gg_rct_ISLAND_ITEMS)
                    set it = CreateItemLoc('I08E', pt)
                    call RemoveLocation(pt)
                    set pt = null
                    set udg_P_Items[arrIndex] = it
                    call SetItemCharges(it, 1)
                    call SetItemUserData(it, 1)
                    set hasSpace = true
                    exitwhen true
                endif
                set i = i + 1
            endloop

            // If the extra bag is full, fall back to page 2 first, then page 1.
            if not hasSpace then
                set page = 2
                loop
                    exitwhen page < 1

                    set i = 1
                    loop
                        exitwhen i > 6
                        set arrIndex = GetPItemsIndex(p, page, i)
                        if udg_P_Items[arrIndex] == null then
                            if page == Equipped_Page then
                                call UnitAddItemByIdSwapped('I08E', u)
                                set it = UnitItemInSlotBJ(u, UnitInventoryCount(u))
                                if it != null then
                                    call SetItemCharges(it, 1)
                                    set hasSpace = true
                                endif
                            else
                                set pt = GetRectCenter(gg_rct_ISLAND_ITEMS)
                                set it = CreateItemLoc('I08E', pt)
                                call RemoveLocation(pt)
                                set pt = null
                                set udg_P_Items[arrIndex] = it
                                call SetItemCharges(it, 1)
                                call SetItemUserData(it, 1)
                                set hasSpace = true
                            endif
                            exitwhen true
                        endif
                        set i = i + 1
                    endloop

                    exitwhen hasSpace
                    set page = page - 1
                endloop

                // Finally, if no space in the extra bag or pages, create it on the ground/current inventory fallback.
                if not hasSpace then
                    call UnitAddItemByIdSwapped('I08E', u)
                endif
            endif
        endif

        call CreateTextTagUnitBJ("Soul Shard", u, 0.00, 9.00, 80.00, 40.00, 100.00, 0 )
        call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 64, 90.00 )
        call cleanUpText(1.25, 0.75)

        // CD Reset Talent
        if udg_TalentChoices[GetPlayerId(GetOwningPlayer(u)) * udg_NUM_OF_TC + 5] then
            call BlzEndUnitAbilityCooldown(u, 'A00D' )
        endif
    endif

    set pt = null
    set it = null
    set p = null
    set u = null
endfunction

//===========================================================================
function InitTrig_Soul_Drain_Dies takes nothing returns nothing
    set gg_trg_Soul_Drain_Dies = CreateTrigger()
    call DisableTrigger(gg_trg_Soul_Drain_Dies )
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Soul_Drain_Dies, EVENT_PLAYER_UNIT_DEATH )
    call TriggerAddAction(gg_trg_Soul_Drain_Dies, function Trig_Soul_Drain_Dies_Actions )
endfunction

