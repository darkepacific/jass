function Load_GUI takes nothing returns nothing
    local location point 
    local unit loadedUnit 
    local unit createdUnit 
    local string heroID 
    local string hearth 
    local integer i 
    local integer j
    local integer loopEnd 
    local integer hearthNumber 
    local player p = udg_SaveLoadEvent_Player
    local Savecode saveCode = Savecode.create()
    set udg_SaveCount = 0 
   
    // -------------------  
    // NOTE: You must load values in the reverse order you saved them in  
    // -------------------  
    // Validate  
    // -------------------  
    if not(saveCode.Load(p, udg_SaveCodeString, 1)) then 
        // call DisplayTextToPlayer(p, 0,0, "Error loading save file. Character either belongs to another player or is corrupted.") 
        call saveCode.destroy() 
        call PlayerReturnToHeroSelection(p)
        call ClearNeatMessagesForPlayer(p)
        call NeatMessageToPlayer(p, "|cffffcc00Error loading save file.|r |nCharacter either belongs to another player or file is corrupted.")
        // call DisplayTextToPlayer(p, 0.35, 0, "Error loading save file. |nCharacter either belongs to another player or file is corrupted.")
        return 
    endif 
    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Loaded " + User[p].nameColored + "'s character!") 

    
    // -------------------  
    // Load Hero  
    // -------------------  

    // -------------------  
    // Load Hero String Identifier  
    // -------------------  
    set udg_SaveCount = (udg_SaveCount + 1) 
    set udg_SaveMaxValue[udg_SaveCount] = udg_SaveNameMax 
    call Debug("Name: ")         
    call SaveHelper.GUILoadNext(saveCode) 
    set heroID = SaveHelper.GetHeroNameFromID(udg_SaveValue[udg_SaveCount]) 
    call Debug("Loaded Hero: " + heroID) 

    //Check if the hero is already being played by another player
    set loadedUnit = ConvertStringtoHero(heroID) 
    call Debug("Loaded Unit: " + GetUnitName(loadedUnit)) 
    if(GetPlayerController(GetOwningPlayer(loadedUnit)) == MAP_CONTROL_USER and GetPlayerSlotState(GetOwningPlayer(loadedUnit)) == PLAYER_SLOT_STATE_PLAYING) then 
        call ErrorMessage("Another player is currently playing that class. Please pick another character.", p) 
        call saveCode.destroy() 
        set loadedUnit = null 
        set heroID = null 
        return 
    endif 

    // -------------------
    // Load Gold
    // -------------------
    // call DebugCritical("Loading Gold:") 
    set udg_SaveCount = (udg_SaveCount + 1) 
    set udg_SaveMaxValue[udg_SaveCount] = 10000000//9999999
    call SaveHelper.GUILoadNext(saveCode) 
    call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, udg_SaveValue[udg_SaveCount])

    // -------------------  
    // Load Hearth  
    // -------------------  
    set udg_SaveCount = (udg_SaveCount + 1) 
    set udg_SaveMaxValue[udg_SaveCount] = 999
    // call Debug("Hearth: ") 
    call SaveHelper.GUILoadNext(saveCode) 
    set hearthNumber = udg_SaveValue[udg_SaveCount] 
    set udg_Hearthstones[GetPlayerNumber(p)] = udg_SaveValue[udg_SaveCount] 
    set hearth = GetHearthStringFromNumber(udg_SaveValue[udg_SaveCount], p) 
    

    // -------------------  
    // Create Hero  
    // -------------------  
    set point = GetRectCenter(GetPlayableMapRect()) 
    set createdUnit = CreateUnitAtLoc(p, ConvertStringToHeroUnitID(heroID), point, bj_UNIT_FACING)
    call RemoveLocation(point) 
    call RemoveUnit(loadedUnit) 

    call SelectUnitForPlayerSingle(createdUnit, p) 
    call SetHeroVariableFromString(heroID, createdUnit) 
    call RemoveUnit(udg_Heroes[GetPlayerHeroNumber(p)]) 
    set udg_Heroes[GetPlayerHeroNumber(p)] = createdUnit 
   
    // Needed for gg_trg_Hearth
    set udg_X_Player_MUI = p 
    set udg_Temp_Unit = createdUnit 
    set udg_Player_Number = GetPlayerNumber(p) 

    //Register Hero Conditions and Hearth
    if(StringContains(heroID, "yA")) then 
        call StartingPoint(p, createdUnit, GetPlayableMapRect(), gg_cam_Alliance_Start, hearth, 0, hearthNumber, 270.00) 
        call TriggerExecute(gg_trg_Hearth_Alliance) 
    elseif(StringContains(heroID, "yH")) then 
        call StartingPoint(p, createdUnit, GetPlayableMapRect(), gg_cam_Horde_Start, hearth, 0, hearthNumber, 270.00) 
        call TriggerExecute(gg_trg_Hearth_Horde) 
    endif 

    
    // -------------------  
    // Load Experience
    // -------------------  
    set udg_SaveCount = (udg_SaveCount + 1) 
    set udg_SaveMaxValue[udg_SaveCount] = 1000000 
    call SaveHelper.GUILoadNext(saveCode) 
    call Debug("Loaded XP: " + I2S(udg_SaveValue[udg_SaveCount]))  
    call SetHeroXP(createdUnit, udg_SaveValue[udg_SaveCount], false) 


    // -------------------  
    // Load Items  
    // -------------------  

    //Load Items
    call DebugCritical("Loading Items:") 
    set i = 1
    loop 
        exitwhen i > 18
        //  call Debug("Item Type:") 
        set udg_SaveCount = (udg_SaveCount + 1) 
        set udg_SaveMaxValue[udg_SaveCount] = udg_SaveItemTypeMax 
        call SaveHelper.GUILoadNext(saveCode) 
        //  call Debug("Charges:") 
        set udg_SaveCount = (udg_SaveCount + 1) 
        set udg_SaveMaxValue[udg_SaveCount] = 999 
        call SaveHelper.GUILoadNext(saveCode) 
        //  call Debug("Special Condition:") 
        set udg_SaveCount = (udg_SaveCount + 1) 
        set udg_SaveMaxValue[udg_SaveCount] = 99 
        call SaveHelper.GUILoadNext(saveCode) 


        //Create Item
        set bj_lastCreatedItem = CreateItem(udg_SaveItemType[udg_SaveValue[udg_SaveCount - 2]], -16358.0, -8802.9)
        call SetItemCharges(bj_lastCreatedItem, udg_SaveValue[udg_SaveCount - 1]) 
        call SaveHelper.SetItemSpecialCondition(bj_lastCreatedItem, udg_SaveValue[udg_SaveCount]) 

        if i <= 6 then
            call Debug("Loading Inventory Item: " + I2S(i) + " - " + GetItemName(bj_lastCreatedItem) + " with " + I2S(udg_SaveValue[udg_SaveCount - 1]) + " charges and special condition: " + I2S(udg_SaveValue[udg_SaveCount]))
            call UnitAddItem(createdUnit, bj_lastCreatedItem)
        
        else
            call Debug("Loading Bag Item: " + I2S(i) + " - " + GetItemName(bj_lastCreatedItem) + " with " + I2S(udg_SaveValue[udg_SaveCount - 1]) + " charges and special condition: " + I2S(udg_SaveValue[udg_SaveCount]))
            call SetItemUserData( bj_lastCreatedItem, ( GetItemUserData(bj_lastCreatedItem) + 1 ) )
        
        endif 

        set udg_P_Items[GetPlayerBagNumber(p) + i] = bj_lastCreatedItem 
        set i = i + 1 
    endloop 
    
    // -------------------  
    // Load Abilities  
    // -------------------  
    // call Debug("Loading Abilities:") 

    // Loads the number of abilities lvl 1 and above
    set udg_SaveCount = (udg_SaveCount + 1) 
    set udg_SaveMaxValue[udg_SaveCount] = udg_SaveAbilityTypeMax 
    call SaveHelper.GUILoadNext(saveCode) 

    set i = 0 
    set loopEnd = udg_SaveValue[udg_SaveCount] 
    loop 
        exitwhen i > loopEnd 
        set udg_SaveCount = (udg_SaveCount + 1) 
        set udg_SaveMaxValue[udg_SaveCount] = udg_SaveAbilityTypeMax 
        call SaveHelper.GUILoadNext(saveCode) 
        // call UnitAddAbilityBJ(udg_SaveAbilityType[udg_SaveValue[udg_SaveCount]], createdUnit) 
        set udg_SaveCount = (udg_SaveCount + 1) 
        set udg_SaveMaxValue[udg_SaveCount] = 10 
        call SaveHelper.GUILoadNext(saveCode) 
        // call SetUnitAbilityLevel(createdUnit, udg_SaveAbilityType[udg_SaveValue[(udg_SaveCount - 1)]], udg_SaveValue[udg_SaveCount])
        set j = 0
        loop 
            exitwhen j >= udg_SaveValue[udg_SaveCount]
            call SelectHeroSkill(createdUnit, udg_SaveAbilityType[udg_SaveValue[udg_SaveCount - 1]]) 
            set j = j + 1
        endloop
        set i = i + 1 
    endloop 

    // -------------------  
    // Class Specific Conditionals  
    // -------------------  
    call TurnOnComboGen(createdUnit) 
    // -------------------

    call saveCode.destroy() 

    set loadedUnit = null 
    set createdUnit = null 
    set heroID = null 
    set hearth = null 
    set point = null 
    set p = null
endfunction 

//===========================================================================
function InitTrig_Load_GUI takes nothing returns nothing
    set gg_trg_Load_GUI = CreateTrigger()
    call TriggerAddAction(gg_trg_Load_GUI, function Load_GUI)
endfunction




