//===========================================================================
function Trig_Soul_Drain_Dies_Actions takes nothing returns nothing
    local boolean fired = false
    local boolean hasShard = false
    local boolean addedToMainInventory = false
    local boolean hasSpace = false
    local location pt
    local unit u = GetTriggerUnit()
    local item it
    local integer Equipped_Page = udg_Bag_Page[GetPlayerNumber(GetOwningPlayer(u))]
    local integer page
    local integer i

    if GetTriggerUnit() == udg_SpellUnits[udg_z_WL_DEMO_A + 4] then
        set u = udg_yA_Demon_Warlock
        set fired = true
    elseif GetTriggerUnit() == udg_SpellUnits[udg_z_WL_DEMO_H + 4] then
        set u = udg_yH_Demon_Warlock
        set fired = true
    endif


    if fired then
        call SetBagNumber(GetOwningPlayer(u) )


        // First Check if they already have one across all bags, if so increment its charge
        set i = 1
        loop
            exitwhen i > 18
            set it = udg_P_Items[(udg_Bag_Num + i)]
            if GetItemTypeId(it) == 'I08E' and BlzGetItemIntegerField(it, ITEM_IF_NUMBER_OF_CHARGES) < 10 then
                call SetItemCharges(it, (GetItemCharges(it) + 1))
                set hasShard = true
                exitwhen true
            endif
            set i = i + 1
        endloop

        // If not already have one, then make a new one
        if not hasShard then

            // First try to add to the main inventory
            set i = 1
            loop
                exitwhen i > 6
                set it = UnitItemInSlotBJ(u, i)
                if(it == null) then
                    call UnitAddItemByIdSwapped('I08E', u )
                    set it = UnitItemInSlotBJ(u, i)
                    set udg_P_Items[(udg_Bag_Num + ((Equipped_Page - 1) * 6) + i)] = it
                    call SetItemCharges(it, 1)
                    set addedToMainInventory = true
                    exitwhen true
                endif
                set i = i + 1
            endloop

            // But, if no space in main inventory, then try to add to another page
            if not addedToMainInventory then

                set page = 1
                loop
                    exitwhen page > 3
                    
                    if page != Equipped_Page then
                        set i = 1
                        loop 
                            exitwhen i > 6
                            if udg_P_Items[(udg_Bag_Num + ((page - 1) * 6) + i)] == null then
                                set pt = GetRectCenter(gg_rct_ISLAND_ITEMS)
                                set it = CreateItemLoc('I08E', pt )
                                call RemoveLocation(pt)
                                set udg_P_Items[(udg_Bag_Num + ((page - 1) * 6) + i)] = it
                                call SetItemCharges(it, 1)
                                call SetItemUserData(it, 1)
                                set hasSpace = true
                                exitwhen true
                            endif
                            set i = i + 1
                        endloop

                        exitwhen hasSpace
                    endif
                    
                    set page = page + 1
                endloop
            
                //Finally, if no space in any of the bags, and no existing soul shard, create it on the ground
                if not hasSpace then
                    call UnitAddItemByIdSwapped('I08E', u )
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
    set u = null
endfunction

//===========================================================================
function InitTrig_Soul_Drain_Dies takes nothing returns nothing
    set gg_trg_Soul_Drain_Dies = CreateTrigger()
    call DisableTrigger(gg_trg_Soul_Drain_Dies )
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Soul_Drain_Dies, EVENT_PLAYER_UNIT_DEATH )
    call TriggerAddAction(gg_trg_Soul_Drain_Dies, function Trig_Soul_Drain_Dies_Actions )
endfunction

