library SaveHelperLib initializer Init requires SyncHelper, PlayerUtils, SaveFile, HeroFunctions, Ascii

    // Uses GUI variables from the "Save Init" trigger. You can modify these functions to use your own variables.
    private keyword SaveHelperInit
    
    struct SaveHelper extends array
        
        static constant hashtable Hashtable = InitHashtable()
        static constant integer KEY_ITEMS = 1
        static constant integer KEY_UNITS = 2
        static constant integer KEY_NAMES = 3
        static constant integer KEY_HEARTHS = 4
        
        static method MaxCodeSyncLength takes nothing returns integer
            return udg_SaveLoadMaxLength
        endmethod
    
        static method GetSavesPerSlot takes player p, integer slot returns integer
            return udg_NumberOfSaves[GetPlayerId(p)*300+slot]
        endmethod

        static method SetSavesPerSlot takes player p, integer slot, integer saves returns nothing
           set udg_NumberOfSaves[GetPlayerId(p)*300+slot] = saves
        endmethod
        
        static method IsUserLoading takes User user returns boolean
            return udg_SavePlayerLoading[user.id]
        endmethod
        
        static method SetUserLoading takes User user, boolean flag returns nothing
            set udg_SavePlayerLoading[user.id] = flag
        endmethod
        
        // static method GetSaveSlot takes User user returns integer
            // return GetSlotForHero(udg_SavePlayerHero[user.id]) //Via HeroFunctions
        // endmethod
        
        static method GetUnitTitle takes unit u returns string
            return ConvertHeroToProperName(u) + " (lvl " + I2S(GetHeroLevel(u)) + ")" 
        endmethod
        
        // static method GetMapName takes nothing returns string
        //     return udg_MapName
        // endmethod
        
        static method MaxAbilityLevel takes nothing returns integer
            return 10
        endmethod
        
        static method MaxAbilities takes nothing returns integer
            return udg_SaveAbilityTypeMax
        endmethod
        
        static method MaxItems takes nothing returns integer
            return udg_SaveItemTypeMax
        endmethod
        
        // static method MaxUnits takes nothing returns integer
        //     return udg_SaveUnitTypeMax
        // endmethod
        
        static method MaxNames takes nothing returns integer
            return udg_SaveNameMax
        endmethod

        static method MaxHeroStat takes nothing returns integer
            return udg_SaveUnitMaxStat
        endmethod
        
        static method GetAbility takes integer index returns integer
            return udg_SaveAbilityType[index]
        endmethod
        
        static method GetItem takes integer index returns integer
            return udg_SaveItemType[index]
        endmethod
        
        // static method GetUnit takes integer index returns integer
        //     return udg_SaveUnitType[index]
        // endmethod
        
        static method ConvertItemId takes integer itemId returns integer
            return LoadInteger(thistype.Hashtable, KEY_ITEMS, itemId)
        endmethod

        // static method ConvertUnitId takes integer unitId returns integer
        //     return LoadInteger(thistype.Hashtable, KEY_UNITS, unitId)
        // endmethod
        
        static method GetHeroNameFromID takes integer id returns string
            return udg_SaveNameList[id]
        endmethod

        // static method GetHearthFromID takes integer id returns string
        //     return udg_SaveHearthList[id]
        // endmethod
        
        static method GetHeroNameID takes string name returns integer
            return LoadInteger(thistype.Hashtable, KEY_NAMES, StringHash(name))
        endmethod

        // static method GetHearthID takes string hearth returns integer
        //     return LoadInteger(thistype.Hashtable, KEY_HEARTHS, StringHash(hearth))
        // endmethod
        
        static method ConvertHeroName takes string name returns string
            return udg_SaveNameList[GetHeroNameID(name)]
        endmethod

        static method GetItemSpecialCondition takes item it returns integer
            //Heart Seeker Blood/Thirster
            if GetItemTypeId(it) == 'I06X' then
                return 0
            endif
            //Item Suffixes
            // of Spirit
                //Increase mana regen
            // of Agility
            // of Intelligence
            // of Strength

            // of the Bear
                //Increase health regen
            // of the Tiger
                //Agility and Str
            // of the Owl
                //Int and Mana Regen
            // of the Eagle
                //Int and Health
            //
            
            return 0
        endmethod

        static method SetItemSpecialCondition takes item it, integer condition returns nothing
            local integer charges
            //Heart Seeker Blood/Thirster
            if GetItemTypeId(it) == 'I06X' then
                set charges = GetItemCharges(it)
                if charges > 15 then
                    call BlzItemRemoveAbilityBJ( it, udg_InitBloodThirst[( 0 )] )
                    call BlzItemAddAbilityBJ( it, udg_InitBloodThirst[( charges - 15 )] )
                    call BlzSetItemDescription( it, ( "+45 Attack +8 Strength +" + I2S( charges ) + "% Life Steal |n|n|cccFF2200Non-Stacking Passive:|r Each Hero or Boss you kill with this item equipped increases the Life Steal of it by 1% up to a maximum of 30%. |cffc0c0c0(Enemies must not be 10 levels below your own.)|r" ) ) 
                    call BlzSetItemExtendedTooltip( it, ( "+45 Attack +8 Strength +" + I2S( charges ) + "% Life Steal |n|n|cccFF2200Non-Stacking Passive:|r Each Hero or Boss you kill with this item equipped increases the Life Steal of it by 1% up to a maximum of 30%. |cffc0c0c0(Enemies must not be 10 levels below your own.)|r" ) ) 
                endif
            elseif condition > 0 then
                //Put logic for other items here
            endif
        endmethod
        
        static method GUILoadNext takes Savecode sc returns nothing
            set udg_SaveValue[udg_SaveCount] = sc.Decode(udg_SaveMaxValue[udg_SaveCount])
            // call Debug(I2S(udg_SaveCount) + ", " + I2S(udg_SaveValue[udg_SaveCount]))
        endmethod
        
        // static method GetLevelXP takes integer level returns real
        //     local real xp = udg_HeroXPLevelFactor // level 1
        //     local integer i = 1

        //     loop
        //         exitwhen i > level
        //         set xp = (xp*udg_HeroXPPrevLevelFactor) + (i+1) * udg_HeroXPLevelFactor
        //         set i = i + 1
        //     endloop
        //     return xp-udg_HeroXPLevelFactor
        // endmethod
        
        static method Init takes nothing returns nothing // called at the end of "Save Init" trigger
            local integer i = 0
            loop
                exitwhen i >= thistype.MaxItems() //or udg_SaveItemType[i] == 0
                
                call SaveInteger(thistype.Hashtable, KEY_ITEMS, udg_SaveItemType[i], i)
                
                set i = i + 1
            endloop
            // set i = 0
            // loop
            //     exitwhen i >= thistype.MaxUnits() //or udg_SaveUnitType[i] == 0
                
            //     call SaveInteger(thistype.Hashtable, KEY_UNITS, udg_SaveUnitType[i], i)
                
            //     set i = i + 1
            // endloop
            set i = 1
            loop
                exitwhen i >= SaveHelper.MaxNames() or udg_SaveNameList[i] == "" or udg_SaveNameList[i] == null
                
                call SaveInteger(thistype.Hashtable, KEY_NAMES, StringHash(udg_SaveNameList[i]), i)
                
                set i = i + 1
            endloop
            // loop
            //     exitwhen i >= 999 or udg_SaveHearthList[i] == "" or udg_SaveHearthList[i] == null
                
            //     call SaveInteger(thistype.Hashtable, KEY_HEARTHS, StringHash(udg_SaveHearthList[i]), i)
                
            //     set i = i + 1
            // endloop
        endmethod
    endstruct

    function SaveCharToSlot takes unit u, integer slot returns nothing
        local player p = GetOwningPlayer(u)
        local integer saveNumber = SaveHelper.GetSavesPerSlot(p, slot) + 1
        local string items = ""
        local string saveCode = null
        local integer i = 1

        loop
            exitwhen i > 18
            set items = items + A2S(GetItemTypeId(udg_P_Items[GetPlayerBagNumber(p) + i])) + "-"
            set i = i + 1
        endloop

        call SaveHelper.SetSavesPerSlot(p, slot, saveNumber)
        // Generate the save code; retry once if it unexpectedly comes back empty.

        // set saveCode = Save_GUI()
        set udg_SaveLoadEvent_Player = p
        call TriggerExecute(gg_trg_Save_GUI)
        set saveCode = udg_SaveCodeString
        // if (saveCode == null or saveCode == "") then
        //     set saveCode = Save_GUI(p)
        // endif
        call Debug("Save Code: " + saveCode)
        call SaveFile(slot).create(p, SaveHelper.GetUnitTitle(u), items, slot, saveNumber, saveCode)

        set p = null
        set saveCode = null
    endfunction

    private function LoadSaveSlot_OnSync takes nothing returns nothing
        local player p = GetTriggerPlayer()
        local string prefix = BlzGetTriggerSyncPrefix()
        local string s = BlzGetTriggerSyncData()
        local integer pid = GetPlayerId(p)
        local User user = User[p]
        
        call SaveHelper.SetUserLoading(user, false)
        call Debug("Sync'd from player:" + GetPlayerName(p) + " string: " + s)
        set  udg_Hero_Strings[pid] = s

        set p = null
        set prefix = null
        set s = null
    endfunction

    function LoadSaveSlot takes player p, integer slot returns nothing
        local SaveFile savefile = SaveFile(slot)
        local string s
        local User user = User[p]
        local integer saveNumber = SaveHelper.GetSavesPerSlot(p, slot)
        local unit hero = udg_Heroes[GetPlayerHeroNumber(p)]
            
        if (not SaveFile.exists(p, slot, saveNumber)) then
            // call DisplayTextToPlayer(p, 0, 0, "Did not find any save data.")
            set s = ""
            if (GetLocalPlayer() == p) then
                call SyncString(s)
            endif
        elseif (SaveHelper.IsUserLoading(user)) then
            // call DisplayTextToPlayer(p, 0, 0, "Please wait while your character synchronizes.")
        else
            set s = savefile.getData(p, saveNumber)
            if (GetLocalPlayer() == p) then
                call SyncString(s)
            endif
            call SaveHelper.SetUserLoading(user, true) 
            call ClearTextMessages()
            call Debug("Synchronzing with other players... ")//+ GetPlayerName(p) + " slot: " + I2S(slot) + " saveNumber: " + I2S(saveNumber) + " string: " + s)
        endif

        set s = null
        set hero = null
    endfunction
    
    function DeleteCharSlot takes player p, integer slot returns nothing
        local integer saveNumber = SaveHelper.GetSavesPerSlot(p, slot) + 1
        call SaveHelper.SetSavesPerSlot(p, slot, saveNumber)
        if (GetLocalPlayer() == p) then
            call SaveFile(slot).clear(p, slot, saveNumber)
        endif
    endfunction


    private function Init takes nothing returns nothing
        call OnSyncString(function LoadSaveSlot_OnSync)
    endfunction
    
endlibrary
