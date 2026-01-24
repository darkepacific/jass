// Returns the 0-based index of the first occurrence of `needle` in `haystack`, starting at `start`.
// Returns -1 if not found.
function StringFind takes string haystack, string needle, integer start returns integer
    local integer hayLen = StringLength(haystack)
    local integer needleLen = StringLength(needle)
    local integer i = start

    if i < 0 then
        set i = 0
    endif

    // Empty needle: treat as found at start.
    if needleLen == 0 then
        return i
    endif

    loop
        exitwhen i > hayLen - needleLen
        if SubString(haystack, i, i + needleLen) == needle then
            return i
        endif
        set i = i + 1
    endloop

    return -1
endfunction

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
    local string saveStr
    local integer expectedSlot = 0
    local integer sep = -1
    local integer metaMagic
    local integer metaVersion
    local integer metaFaction
    local integer metaMode
    local integer metaHeroSlot = 0
    local integer altMagic
    set udg_SaveCount = 0 
   
    // -------------------  
    // NOTE: You must load values in the reverse order you saved them in  
    // -------------------  
    // Validate  
    // -------------------  
    // The synced payload may be prefixed as: "<slot>|<savecode>"
    // Find the first '|' (if present).
    set sep = StringFind(udg_SaveCodeString, "|", 0)

    if sep > -1 then
        set expectedSlot = S2I(SubString(udg_SaveCodeString, 0, sep))
        set saveStr = SubString(udg_SaveCodeString, sep + 1, StringLength(udg_SaveCodeString))
    else
        set saveStr = udg_SaveCodeString
    endif

    if not(saveCode.Load(p, saveStr, SaveHelper.GetCurrentSaveKey())) then 
        // Try the other mode key so we can show a friendlier message.
        if saveCode.Load(p, saveStr, SaveHelper.GetOtherSaveKey()) then
            set altMagic = saveCode.Decode(2048)
            call saveCode.destroy()
            call PlayerReturnToHeroSelection(p)
            call ClearNeatMessagesForPlayer(p)
            if altMagic == SaveHelper.SAVE_META_MAGIC then
                call NeatMessageToPlayer(p, "|cffffcc00Wrong mode.|r |nThat save is for a different game mode (Singleplayer vs Multiplayer).")
            else
                call NeatMessageToPlayer(p, "|cffffcc00Old save format.|r |nThis save was made before the save system update and can’t be loaded anymore.")
            endif
            return
        endif
        call saveCode.destroy() 
        call PlayerReturnToHeroSelection(p)
        call ClearNeatMessagesForPlayer(p)
        call NeatMessageToPlayer(p, "|cffffcc00Error loading save file.|r |nCharacter either belongs to another player or file is corrupted.")
        return 
    endif 

    // -------------------
    // Load Metadata (these were saved LAST, so they load FIRST)
    // -------------------
    // Magic
    set udg_SaveCount = (udg_SaveCount + 1)
    set udg_SaveMaxValue[udg_SaveCount] = 2048
    call SaveHelper.GUILoadNext(saveCode)
    set metaMagic = udg_SaveValue[udg_SaveCount]

    // Version
    set udg_SaveCount = (udg_SaveCount + 1)
    set udg_SaveMaxValue[udg_SaveCount] = 9999
    call SaveHelper.GUILoadNext(saveCode)
    set metaVersion = udg_SaveValue[udg_SaveCount]

    // Faction
    set udg_SaveCount = (udg_SaveCount + 1)
    set udg_SaveMaxValue[udg_SaveCount] = 2
    call SaveHelper.GUILoadNext(saveCode)
    set metaFaction = udg_SaveValue[udg_SaveCount]

    // Mode
    set udg_SaveCount = (udg_SaveCount + 1)
    set udg_SaveMaxValue[udg_SaveCount] = 2
    call SaveHelper.GUILoadNext(saveCode)
    set metaMode = udg_SaveValue[udg_SaveCount]

    if metaMagic != SaveHelper.SAVE_META_MAGIC then
        call saveCode.destroy()
        call PlayerReturnToHeroSelection(p)
        call ClearNeatMessagesForPlayer(p)
        call NeatMessageToPlayer(p, "|cffffcc00Old save format.|r |nThis save was made before the save system update and can’t be loaded anymore.")
        return
    endif
    // Allow older versions (we branch behavior below). Reject only future/invalid.
    if metaVersion < 1 or metaVersion > SaveHelper.SAVE_VERSION then
        call saveCode.destroy()
        call PlayerReturnToHeroSelection(p)
        call ClearNeatMessagesForPlayer(p)
        call NeatMessageToPlayer(p, "|cffffcc00Error loading save file.|r |nSave version mismatch.")
        return
    endif
    if metaMode != SaveHelper.GetCurrentMode() then
        call saveCode.destroy()
        call PlayerReturnToHeroSelection(p)
        call ClearNeatMessagesForPlayer(p)
        call NeatMessageToPlayer(p, "|cffffcc00Wrong mode.|r |nThat save is for a different game mode (Singleplayer vs Multiplayer).")
        return
    endif
    if metaFaction != SaveHelper.GetFactionId(p) then
        call saveCode.destroy()
        call PlayerReturnToHeroSelection(p)
        call ClearNeatMessagesForPlayer(p)
        call NeatMessageToPlayer(p, "|cffffcc00Wrong faction.|r |nThat save is for the other faction.")
        return
    endif

    call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Loaded " + User[p].nameColored + "'s character!") 

    
    // -------------------  
    // Load Hero String Identifier  
    // -------------------  
    // Embedded hero slot id is saved right before the hero name id.
    set udg_SaveCount = (udg_SaveCount + 1)
    set udg_SaveMaxValue[udg_SaveCount] = 499
    call SaveHelper.GUILoadNext(saveCode)
    set metaHeroSlot = udg_SaveValue[udg_SaveCount]

    set udg_SaveCount = (udg_SaveCount + 1) 
    set udg_SaveMaxValue[udg_SaveCount] = udg_SaveNameMax 
    call Debug("Name: ")         
    call SaveHelper.GUILoadNext(saveCode) 
    set heroID = SaveHelper.GetHeroNameFromID(udg_SaveValue[udg_SaveCount]) 
    call Debug("Loaded Hero: " + heroID) 

    // Validate that the save matches the selected hero slot.
    // This prevents renaming a file (e.g. 220 -> 222) and loading the wrong class.
    if expectedSlot > 0 then
        if GetSlotForHeroUnitID(ConvertStringToHeroUnitID(heroID)) != expectedSlot then
            call saveCode.destroy()
            call PlayerReturnToHeroSelection(p)
            call ClearNeatMessagesForPlayer(p)
            call NeatMessageToPlayer(p, "|cffffcc00Wrong class for this slot.|r |nThat save does not match the selected hero slot.")
            return
        endif
        if metaHeroSlot != expectedSlot then
            call saveCode.destroy()
            call PlayerReturnToHeroSelection(p)
            call ClearNeatMessagesForPlayer(p)
            call NeatMessageToPlayer(p, "|cffffcc00Wrong class for this slot.|r |nThat save does not match the selected hero slot.")
            return
        endif
    endif

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

    //-------------------  
    // Load Provisioning
    // -------------------  
    set udg_SaveCount = (udg_SaveCount + 1)
    set udg_SaveMaxValue[udg_SaveCount] = 300
    call SaveHelper.GUILoadNext(saveCode)
    // call SetProvisioningLvl(createdUnit, udg_SaveValue[udg_SaveCount])

    //-------------------
    // Load Crafting
    // -------------------
    set udg_SaveCount = (udg_SaveCount + 1)
    set udg_SaveMaxValue[udg_SaveCount] = 300
    call SaveHelper.GUILoadNext(saveCode)
    // call SetCraftingLvl(createdUnit, udg_SaveValue[udg_SaveCount])


    // -------------------  
    // Load Items  
    // -------------------  

    //Load Items
    call DebugCritical("Loading Items:") 
    set i = 1
    loop 
        exitwhen i > 48
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

        if i <= 18 then

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
        
        endif
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
    set saveStr = null
endfunction 

//===========================================================================
function InitTrig_Load_GUI takes nothing returns nothing
    set gg_trg_Load_GUI = CreateTrigger()
    call TriggerAddAction(gg_trg_Load_GUI, function Load_GUI)
endfunction




