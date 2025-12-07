function Save_GUI takes nothing returns nothing 
    local string name 
    local integer i 
    local string items = ""
    local player p = udg_SaveLoadEvent_Player
    local unit u = udg_Heroes[GetPlayerHeroNumber(p)] 
    local integer saveCodePtr = 0
    // locals used in the item loop (declared here to satisfy JASS rules)
    local item it
    local integer idx
    local integer typeId
    local integer charges

    local integer numberOfAbilities = 0

    // ------------------- 
    // NOTE: You must load values in the reverse order you saved them in. This is why we save the unit type last. 
    // ------------------- 
    set udg_SaveCount = - 1 

    // ------------------- 
    // Save Abilities 
    // ------------------- 
    set i = 0 
    loop 
        exitwhen i > udg_SaveAbilityTypeMax 
        // Skip invalid ability IDs to avoid API errors
        if(udg_SaveAbilityType[i] != 0 and GetUnitAbilityLevel(u, udg_SaveAbilityType[i]) > 0) then 
            // Save level of ability 
            set udg_SaveCount =(udg_SaveCount + 1) 
            set udg_SaveValue[udg_SaveCount] = GetUnitAbilityLevel(u, udg_SaveAbilityType[i]) 
            set udg_SaveMaxValue[udg_SaveCount] = 10
            // Save the array index 
            set udg_SaveCount =(udg_SaveCount + 1) 
            set udg_SaveValue[udg_SaveCount] = i 
            set udg_SaveMaxValue[udg_SaveCount] = udg_SaveAbilityTypeMax 

            set numberOfAbilities = numberOfAbilities + 1
        else 
        endif 
        set i = i + 1 
    endloop 
    // Save the number of abilities lvl 1 and above
    set udg_SaveCount =(udg_SaveCount + 1) 
    set udg_SaveValue[udg_SaveCount] = numberOfAbilities
    set udg_SaveMaxValue[udg_SaveCount] = udg_SaveAbilityTypeMax 


    // ------------------- 
    // Save Items 
    // ------------------- 

    //Save Items (null-safe)
    set i = 18 
    loop 
        exitwhen i < 1
        set idx = GetPlayerBagNumber(p) + i
        set it = udg_P_Items[idx]
        if it == null then
            set typeId = 0
            set charges = 0
        else
            set typeId = GetItemTypeId(it)
            set charges = GetItemCharges(it)
        endif
        // Save Item Special Condition 
        set udg_SaveCount =(udg_SaveCount + 1) 
        set udg_SaveValue[udg_SaveCount] = SaveHelper.GetItemSpecialCondition(it) 
        set udg_SaveMaxValue[udg_SaveCount] = 99
        // Save Item Charges 
        set udg_SaveCount =(udg_SaveCount + 1) 
        set udg_SaveValue[udg_SaveCount] = charges 
        set udg_SaveMaxValue[udg_SaveCount] = 999 
        // Save Item Type 
        set udg_SaveCount =(udg_SaveCount + 1) 
        set udg_SaveValue[udg_SaveCount] = SaveHelper.ConvertItemId(typeId) 
        set udg_SaveMaxValue[udg_SaveCount] = udg_SaveItemTypeMax 
        set i = i - 1 
        set it = null
    endloop

    // ------------------- 
    // Save Crafting
    // -------------------
    // set udg_SaveCount = (udg_SaveCount + 1) 
    // set udg_SaveValue[udg_SaveCount] = GetCraftingLvl(u) 
    // set udg_SaveMaxValue[udg_SaveCount] = 100

    // ------------------- 
    // Save Provisioning
    // -------------------
    // set udg_SaveCount = (udg_SaveCount + 1) 
    // set udg_SaveValue[udg_SaveCount] = GetProvisioningLvl(u) 
    // set udg_SaveMaxValue[udg_SaveCount] = 100

    // ------------------- 
    // Save Experience
    // ------------------- 
    set udg_SaveCount =(udg_SaveCount + 1) 
    set udg_SaveValue[udg_SaveCount] = GetHeroXP(u) 
    set udg_SaveMaxValue[udg_SaveCount] = 1000000 
    // call Debug("Saved XP: " +  I2S(udg_SaveValue[udg_SaveCount])) 

    // ------------------- 
    // Save Hearth 
    // ------------------- 
    set udg_SaveCount =(udg_SaveCount + 1) 
    set udg_SaveValue[udg_SaveCount] = udg_Hearthstones[GetPlayerNumber(GetOwningPlayer(u))] 
    set udg_SaveMaxValue[udg_SaveCount] = 999

    // ---------------------------------------------------------------------------
    // Save Gold
    // ---------------------------------------------------------------------------
    set udg_SaveCount =(udg_SaveCount + 1) 
    set udg_SaveValue[udg_SaveCount] = GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)
    set udg_SaveMaxValue[udg_SaveCount] = 10000000 

    // ------------------- 
    // Save Hero String Identifier 
    // ------------------- 
    set udg_SaveCount =(udg_SaveCount + 1) 
    set name = ConvertHeroToString(u) 
    set udg_SaveValue[udg_SaveCount] = SaveHelper.GetHeroNameID(name) 
    set udg_SaveMaxValue[udg_SaveCount] = udg_SaveNameMax 
    // call BJDebugMsg("Saved Name: " + name) 
    // call BJDebugMsg("Name Number: " + I2S(udg_SaveValue[udg_SaveCount])) 

    // ------------------- 
    // Save to disk 
    // ------------------- 
    set saveCodePtr = Savecode.create() 
    set i = 0 
    loop 
        exitwhen i > udg_SaveCount 
        call Savecode(saveCodePtr).Encode(udg_SaveValue[i], udg_SaveMaxValue[i]) 
        set i = i + 1 
    endloop 

    set udg_SaveCodeString = ""
    set udg_SaveCodeString = Savecode(saveCodePtr).Save(p, 1) 

    // IMPORTANT: free allocated BigNum nodes
    call Savecode(saveCodePtr).destroy() 

    set u = null
    set p = null
endfunction 

// =========================================================================== 
function InitTrig_Save_GUI takes nothing returns nothing 
    set gg_trg_Save_GUI = CreateTrigger() 
    // call TriggerAddCondition(gg_trg_Save_GUI, Condition(function Trig_Save_GUI_Conditions)) 
    call TriggerAddAction(gg_trg_Save_GUI, function Save_GUI) 
endfunction 

