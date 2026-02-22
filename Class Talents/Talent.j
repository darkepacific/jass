library TalentJUI initializer init_function uses optional TalentTasStats, optional Ascii
    
    //Talent Jui 1.36
    //by Tasyen
    
    // Talent provides at wanted Levels a choice from a collection (Tier), from which the user picks one.
    // Tiers are unitType specific (a paladin has different Choices then a demon hunter), This also includes the Levels obtaining them.
    // One can handle choices by Events or one can bind Code beeing executed when picking a choice.
    // Regardless using Events or binded code, creating a reset (revert picking a choice) is quite easy.
    // Talent is mui.
    // Choices and Tiers have a stable arrayIndex.
    
    // Only UnitTypId having used TalentHeroSetFinalTier can use Talent.
    
    // It is also recommented using "function TalentHeroSetCopy", if multiple unitTypes share the same Talent Setup, morphing units for example.
    
    // Before an TalentUser is removed from them game, one should use "call FlushChildHashtable(udg_TalentHash, GetHandleId(unit))"
    // Also it is recommented to do "call GroupRemoveUnit(udg_TalentUser, unit)"
    
    
    //Known Erros: Choosen options overglow sometimes (most frequently the lowest button).
    
    //===========================================================================
    //Definitions:
    //===========================================================================
    globals
    //TalentAutoDetectNewUser (true) will create an "unit enters map" event for udg_TalentTrigger[TT_AutoDetectUnits()]
        boolean TalentAutoDetectNewUser = true
    //Increases the Level of abilities gained by choices, if the ability is already owned.
        boolean TalentImproveAbilities = false
    //(true) only add the new ability if the unit has the to replaced Ability
        boolean TalentReplacedAbilityRequired = true
    //Throw an Event when an unit picks a choiceTalent
        boolean TalentThrowEventPick = true
    //Throw an Event when an unit gains a choice to pick a talent
        boolean TalentThrowEventAvailable = true
    //Throw an Event when an unit resets a choice
        boolean TalentThrowEventReset = true
    //Throw an Event when an unit resets a choice
        boolean TalentThrowEventFinish = true
    endglobals
    
    
    function TalentStringsInit takes nothing returns nothing
    //Customiceable Strings of Talent
    
        
        
    //Customiceable Strings of TalentPreMadeChoice	
        set udg_TalentStrings[1] = "Learn:"			//TalentChoiceCreateAddSpells First Word.
        set udg_TalentStrings[2] = "\n"				//TalentChoiceCreateAddSpells First Seperator.
        set udg_TalentStrings[3] = ", "				//TalentChoiceCreateAddSpells Further Seperator.
        set udg_TalentStrings[9] = ""							//TalentChoiceCreateImproveSpell	Prefix
        set udg_TalentStrings[10] = "Mana cost"			//TalentChoiceCreateImproveSpell ManaCost-Change
        set udg_TalentStrings[11] = "Cooldown"			//TalentChoiceCreateImproveSpell Cooldown-Change
        set udg_TalentStrings[12] = " "	                    //Space String
        
        set udg_TalentStrings[15] = "Weapon"			//TalentChoiceCreateImproveWeapon PreFix
        set udg_TalentStrings[16] = "Damage"			//TalentChoiceCreateImproveWeapon Damage-Bonus
        set udg_TalentStrings[17] = "Attack Speed Cooldown"			//TalentChoiceCreateImproveWeapon AttackSpeedCooldown-Bonus

        set udg_TalentStrings[18] = "Vision Range"		//TalentChoiceCreateImproveSightRange PreFix
        set udg_TalentStrings[19] = "Attack Range"
    
        set udg_TalentStrings[20] = ""					//TalentChoiceCreateSustain Prefix
        set udg_TalentStrings[21] = "Health"		//TalentChoiceCreateSustain Life-Bonus
        set udg_TalentStrings[22] = "Mana"		//TalentChoiceCreateSustain Mana-Bonus
        set udg_TalentStrings[23] = "Armor"		//TalentChoiceCreateSustain Armor-Bonus

        set udg_TalentStrings[24] = "Movement Speed"		//TalentChoiceCreateSustain Movement-Bonus

        set udg_TalentStrings[25] = "Health Regen"		//TalentChoiceCreateSustain Health Regen-Bonus
        set udg_TalentStrings[26] = "Mana Regen"		//TalentChoiceCreateSustain Mana Regen-Bonus
        
        set udg_TalentStrings[28] = ""		//TalentChoiceCreateStats Prefix
        set udg_TalentStrings[29] = "Base Str"		//TalentChoiceCreateStats Str-Bonus
        set udg_TalentStrings[30] = "Base Agi"		//TalentChoiceCreateStats Agi-Bonus
        set udg_TalentStrings[31] = "Base Int"		//TalentChoiceCreateStats Int-Bonus
        
        set udg_TalentStrings[100] = "Unlearn choosen Talents from this Level and higher Levels.|nCan also be used to relearn Talents from this level upwards."		//Tooltip of Unlearn Button
        set udg_TalentStrings[101] = "(Un)Learn"		//Text of Reset-Button
        set udg_TalentStrings[102] = "Talent Level: "	//TalentBox Titel Prefix
        set udg_TalentStrings[103] = "Show Talent"		//Text of ShowTalentButton
        set udg_TalentStrings[104] = "No Talent User"	//No Talent User
    
        set udg_TalentStrings[105] = "Group Mode"		//TooltipGroupModeHead
        set udg_TalentStrings[106] = "During GroupMode all selected Units using the same Talent and with the same amount of selections done, will do picks/Unlearn/Relearn together.|n|nClick to disable Group Mode."	//TooltipGroupModeText
        set udg_TalentStrings[107] = "ui/widgets/battlenet/bnet-mainmenu-customteam-up"	//TooltipGroupModeIcon
        set udg_TalentStrings[108] = "Single Mode"	//TooltipSingleModeHead
        set udg_TalentStrings[109] = "Only the selected Unit will do picks, unlearns.|n|nClick to enable Group Mode"	//TooltipSingleModeText
        set udg_TalentStrings[110] = "ui/widgets/battlenet/bnet-mainmenu-customteam-disabled"	//TooltipSingleModeIcon
    
    
    endfunction
    //===========================================================================
    //API:
    //===========================================================================
    //	function TalentMacroDo takes unit u, string s returns nothing
        //executes a bunch of Picks for Unit u.
        //"-U123" ->Unlearn all, Pick 1, Pick 2, Pick 3
        //"-112"  -> Pick 1, Pick 1, Pick 2, s has to start with "-"
        //Each done action will evoke events/triggers.
    
    //	function TalentGetMacro takes unit u returns nothing
        // returns the text to be used inside TalentMacroDo to pick the current Picks.
        // the use of this function is to save Talentpicks in files.
    
    //	function TalentAddSelection takes unit u returns nothing
        //Test if u gets a new Tier to pick from, done automatically in: udg_TalentTrigger[TT_LevelUp()] (LevelUp).
    
    //	function TalentAdd2Hero takes unit u returns nothing
        // can be used to force talentDetetcion
        //do not use it more than once for one unit.
    
    //	function TalentResetDo takes unit u, integer amountOfResets returns nothing
        //This will undo the last amountOfResets done choices of unit u. Each Time calling the needed "udg_TalentChoiceOnReset" and throwing an event.
        //An OnLearn Requiers an onReset doing the opposite, if one wants to use this feature.
        //call it with 1 to remove the last done choice.
        //To undo all done Choices of an unit, call it with an absurd high number.
    
    //	function TalentPickDo takes unit u, integer buttonNr returns nothing
        //unit u learns choice buttonNr of currentSelection Tier.
        //will only work if the hasSelection flag is set.
        //buttonNr is expected to be 1 to TalentBoxOptionMaxCount() including both
        //buttonNr also should not exceed TalentTierGetChoiceCount of the current Tier.
    
    //	function TalentGetUnitTypeId takes unit u returns integer
        //wrapper for TalentGetUsedHeroTypeId
    
    //	function TalentGetUsedHeroTypeId takes integer heroTypeId returns integer
        //Returns the unitTypeId used in Talent by that unit.
        //use it, if you used TalentHeroSetCopy in your map. If you did not use copy you can simple use GetUnitTypeId when using TalentHero-API
    
    //===========================================================================
    //TalentHero API
    //===========================================================================
    // TalentHero makes reading/writing HeroSheets(TalentTrees) more simple. This is not for data of existing units its the plan.
    
    //	function TalentHeroSetCopy takes integer result, integer copyOrigin returns nothing
        //units from type result will use the setup from copyOrigin
        //also supports copy copy...
        //TalentHeroSetCopy is quite important, if an hero can morph
        //reading further data from result is disabled
    
    //	function TalentHeroTierCreate takes integer heroTypeId, integer level returns integer
        //Create a new Tier for that hero at level.
        //level should be 0 or bigger.
        //returns udg_TalentTierLast
    
    //	function TalentHeroGetTier takes integer heroTypeId, integer level returns integer
        //get the tier at that level for heroTypeId
        //0 = no tier
    
    //	function TalentHeroSetTier takes integer heroTypeId, integer level, integer tier returns nothing
        //heroTypeId will use at level given tier.
    
    //	function TalentHeroGetFinalTier takes integer heroTypeId returns integer
        
    //	function TalentHeroSetFinalTier takes integer heroTypeId, integer level returns nothing
        //Units picking a choice of the tier added at level will be considered as Finished with their Talents.
        //this one has to be used to make a heroTypeId useable for talent.
            
    //	function TalentHeroLevel2SelectionIndex takes integer heroTypeId, integer level returns integer
        //Tells you which selectionIndex that level would be selected as.
        //Valid is 0 to x
        //Returns -1 if the level does not have a tier for that heroTypeId and therefore wouldn't be a valid selectionindex
    
    //===========================================================================
    //TalentUnit API
    //===========================================================================
    //Access Hashtable Data for active units
    
    //function TalentUnitGetSelectionsDoneCount takes integer unitHandle returns integer
    //	How many selections this unit has done?
    
    //function TalentUnitGetSelectionButtonUsed takes integer unitHandle, integer selectionIndex returns integer
    //	ButtonNr used, 1 to TalentBoxOptionMaxCount() (included)
    
    //function TalentUnitGetSelectionLevel takes integer unitHandle, integer selectionIndex returns integer
    //	level of that selectionDone (1 to TalentUnitGetSelectionsDoneCount)
    
    //function TalentUnitGetChoiceDone takes integer unitHandle, integer selectionIndex returns integer
    //	arrayIndex of the choice of that selectionDone
    
    //function TalentUnitGetCurrentTier takes integer unitHandle returns integer
    //	the tier from which unit can pick from
    
    //function TalentUnitGetCurrentTierLevel takes integer unitHandle returns integer
    //	from which level the tier the unit picks currently is from?
    
    //function TalentUnitGetTalentProgressLevel takes integer unitHandle returns integer
    //function TalentUnitHasChoice takes integer unitHandle returns boolean
    
    
    //===========================================================================
    //TalentTier API
    //===========================================================================
    //	function TalentTierCreate takes nothing returns integer
        //creates a new Tier
        //a Tier is an collection of choices from which the user can pick one.
        //returns udg_TalentTierLast the ArrayIndex of the tier
    
    //	function TalentTierAddChoice takes integer tier, integer choice returns nothing
        //Adds a Choice to the tier, tier is the ArrayIndex of the tier choice the ArrayIndex of Choice.
    
    //	function TalentTierGetChoiceCount takes integer tier returns integer
        //returns the amount of choices added to this tier
    
    //	function TalentTierGetChoice takes integer tier, integer index returns integer
        //returns the choice index (0 means no choice was added yet)
        //will return the to this tier last added choice if index is to high
        //expects index > 0
    
    //===========================================================================
    //TalentChoice API
    //===========================================================================
    
    //	function TalentChoiceCreate takes code onLearn, code onReset returns integer
        //if you do not need the function binding for this choice, you could use "set udg_TalentChoiceLast = udg_TalentChoiceLast + 1" instead.
        //Creates a choice and 1 Trigger for each OnLearn/OnReset, if they are not null.
        //returns the ArrayIndex of the Choice
        //afterwards one should set udg_TalentChoiceText[returnedValue], udg_TalentChoiceHead[returnedValue], udg_TalentChoiceIcon[returnedValue]
    
    //	function TalentChoiceCreateEx takes code onLearn, code onReset returns integer
        //Wrapper creating a choice and adding it to the last Created Tier
        //use this over TalentChoiceCreate and TalentTierAddChoice in most cases.
        //returns the choice ArrayIndex.
    
    //	function TalentChoiceCreateAddSpell takes integer spell, boolean useButtonInfos returns integer
    //		this choice will add 1 ability, if useButtonInfos is used then text, HeadLine and Icon are taken from the spell

    //	function TalentChoiceCreateAddSpells takes code onLearn, code onReset, string abilityCodes returns integer
        // creates a new choice, add it to the last created Tier. This choice will give all abilities mentioned
        // This will also set Text to: GetLocalizedString("COLON_SPELLS") spellA, spellB, ...
        // Expected Format TalentChoiceCreateAddSpells(function XLearn, function XReset, "AHbz,AHwe,AHab,AHmt")
        // returns the new choice
    
    //	function TalentChoiceCreateAddSpellsSimple takes string abilityCodes returns integer
        // TalentChoiceCreateAddSpells with null for callBacks
    
    //	function TalentChoiceCreateReplaceSpell takes integer oldSpell, integer newSpell returns integer
    
    //	function TalentChoiceCreateTrigger takes trigger onLearn, trigger onReset returns integer
    
    //	function TalentChoiceCreateTriggerEx takes trigger onLearn, trigger onReset returns integer
        //like TalentChoiceCreateEx
        
    //	function TalentChoiceCreateAll takes string head, string text, string icon, code onLearn, code onReset returns integer
        //creates the Choice with the wanted data
    
    //	function TalentChoiceCreateAllTrigger takes string head, string text, string icon, trigger onLearn, trigger onReset returns integer
    
    //	function TalentChoiceCreateAllEx takes string head, string text, string icon, code onLearn, code onReset  returns integer
        //Create and Add
    
    //	function TalentChoiceCreateAllTriggerEx takes string head, string text, string icon, trigger onLearn, trigger onReset  returns integer
    
    //	function TalentChoiceAddAbility takes integer choice, integer abilityId returns nothing
        //Add abilityId to choiceIndex
        //one can attach multiple abilities to one choice.
        //one can attach the same ability multiple times to the same choice to increase its level.
        //	^^ needs function TalentImproveAbilities to return true
    
    //	function TalentChoiceAddAbilityEx takes integer abilityId returns nothing
        //Add to last created Choice, just use the one above but pass in udg_TalentChoiceLast for the int choice
    
    // 	function TalentChoiceAddSpells takes integer choice, string abilityCodes returns nothing
        //Add many abilities to this choice in one String
        //call TalentChoiceAddSpells(choice, "AHbz,AHwe,AHab,AHmt")
    
    //	function TalentChoiceAddSpellsEx takes string abilityCodes returns nothing
        //Add to last created Choice
    
    //	function TalentChoiceReplaceAbility takes integer choice, integer oldAbility, integer newAbility returns nothing
        //TalentImproveAbilities(true)oldAbility - 1 Level and newAbility + 1 Level
        //TalentImproveAbilities(false) removed oldAbility, add newAbility set level of newAbility to level of oldAbility
    
    //	function TalentChoiceGetAbilityCount takes integer choice returns integer
    //===========================================================================
    //Variables inside Events and Code Binding:
    //===========================================================================
    //	udg_Talent__Unit 		= the unit doing the choice
    //	udg_Talent__UnitCode 	= the unitCode the unit is using
    //	udg_Talent__Choice 		= the arrayIndex of the selected choice.
    // 	udg_Talent__Level 		= the level from which this choice/Tier is.
    //	udg_Talent__Tier		= the arrayIndex of the tier from which the choice is.
    //	udg_Talent__Button		= the Index of the Button used, 1 to TalentBoxOptionMaxCount().
    //							, this variable is needed for event based Talent usage.
    
    //===========================================================================
    //Event:
    //===========================================================================
    //	To identyfy a choice in an Event use HeroType, udg_Talent__Level and udg_Talent__Button.
    // 	Inside trigger condition check for heroType, to use the correct talent tree for this unit.
            // UnitType of udg_Talent__Unit equal (==) "wanted Type"
    //	Now create ifs one for each udg_Talent__Level (it is the level of the tier picked from). 
    //	Inside this ifs now do a check: udg_Talent__Button equal (==) 1  -> yes, do actions of Level x Button 1
    //	Create another one with udg_Talent__Button equal (==) 2 -> yes, do actions of Level x, Button 2.
    //	You can skip Button Ifs not beeing used for that hero-Class on that Level.
    
    //	udg_Talent__Event
    //			= 1 => on Choice.
    //				after the Auotskills are added
    //			= 2 => Tier aviable, does only call when there is no choice for this hero yet.
    //			= 3 => Finished all choices of its hero Type.
    //			= -1 => on Reset for each choice reseted.
    //				before the autoskills are removed
    
    //	Events can be indivudal (de)aktivaded inside "Definitions"
    
    //===========================================================================
    //Code Binding
    //===========================================================================
    // One can directly bind functions/triggers to an choice, 1 for picking the choice, 1 for reseting the choice.
    // Talent allways uses triggers, but one can let the triggers be generated by only giving the functions.
     
    //	udg_TalentChoiceOnLearn		-	Executes when Picked
    //	udg_TalentChoiceOnReset		-	Executes when Reset, should do the opposite of OnLearn, if one wants to use the reset feature.
    //								-	if there is no reset in your project, just skip reset.
    
    //===========================================================================
    //Tier and Choice variables
    //===========================================================================
    // TalentChoice is a simple rising Array, each index represents a new choice.
    //	udg_TalentChoiceLast		- last Index used from TalentChoice
    //	udg_TalentChoiceHead		- the headLine shown
    //	udg_TalentChoiceText		- the mainTooltip shown
    //	udg_TalentChoiceIcon		- the image shown
    //	udg_TalentChoiceOnLearn		- trigger
    //	udg_TalentChoiceOnReset		- trigger
    
    //	TalentChoice Abilities are Saved in the hash.
    //	With the used ArrayIndex as main Key.
    //	rising Positive sec Keys are the abilities gained
    // 	falling negative sec Keys are the abilities replaced.
    //=====
    // Tier is managed inside the hash.
    // used tiers are from 1 to udg_TalentTierLast. (therefore you could also use arrayIndexes)
    // Tiers use negative main Keys, (Background Info).
    
    //===========================================================================
    //TalentSpells
    //===========================================================================
    //	udg_TalentSpellsPrefix		- text displayed before the choicesHead, if a choice uses this Button.
    //	udg_TalentSpellsSufix		- text displayed after choicesHead
    
    //	The displayed HeadLine is ButtonPrefix + choiceHead + ButtonSufix
    
    //===========================================================================
    //udg_TalentTrigger is an array of Triggers controlling this system.
    //		udg_TalentTrigger[TT_LevelUp()] = On Levelup| It checks for new Talent Tiers. 
    //		udg_TalentTrigger[TT_AutoDetectUnits()] = EnterPlayable Map Event
    //			, if you alreay have a EnterPlayable Map trigger you should let "constant function TalentAutoDetectNewUser" return false
    //			, also you then have to manualy inser talent users by:
    //			, if TalentHas(unit) then
    //				 call TalentAdd2Hero(unit)
    //			 endif
    //		udg_TalentTrigger[TT_SelectUnit()] = Make Talent UI (In)Visbile; Event On Unit Selection.
    
    // you could disable all TalentTriggers[0 to 4], if you do not use reset and all Choices are done.
    
    //		udg_TalentReset = when called resets udg_Talent__Unit and calls for each choice undone the reset event(-1).
    //			Reset uses following values 
    //					udg_Talent__ResetAmount = amount of talents undone starting from last selected. (use an absurd high number to undo all talents of a hero)
    //					udg_Talent__Unit = the hero losing talents.
    
    //===========================================================================
    //udg_TalentStrings contain all builtIn Strings which can/should be localiced used by This System.
    
    //===========================================================================
    //TT = TalentTrigger, ArrayIndexes
    
    constant function TT_LevelUp takes nothing returns integer
        return 1
    endfunction
    constant function TT_AutoDetectUnits takes nothing returns integer
        return 2
    endfunction
    constant function TT_SelectUnit takes nothing returns integer
        return 3
    endfunction
    constant function TT_DeathTrigger takes nothing returns integer
        return 4
    endfunction
    
    
    
    //Hashtable
    //unit handleId
    
    constant function TalentHashIndex_LastLevel takes nothing returns integer
        return -1
    endfunction
    constant function TalentHashIndex_LevelOfLastChoice takes nothing returns integer
        return -2
    endfunction
    constant function TalentHashIndex_CurrentChoice takes nothing returns integer
        return -3
    endfunction
    constant function TalentHashIndex_CurrentChoiceLevel takes nothing returns integer
        return -4
    endfunction
    constant function TalentHashIndex_SelectionsDone takes nothing returns integer
        return -5
    endfunction
    
    
    constant function TalentHashIndex_HasChoice takes nothing returns integer
        return 0
    endfunction
    
    
    //UnitTypeId
    //	0 to x choice containers
    //	x  =  last talent(true)
    constant function TalentHashIndex_DataCopyData takes nothing returns integer
        return -2
    endfunction
    constant function TalentHashIndex_FinalTierLevel takes nothing returns integer
        return -3
    endfunction
    
    //TalentSpells
    // at 0 they save its array index.
    //===========================================================================
    function TalentGetUsedHeroTypeId takes integer heroTypeId returns integer
        local integer copyId = LoadInteger(udg_TalentHash, heroTypeId, TalentHashIndex_DataCopyData())
        if copyId != 0 then
            return TalentGetUsedHeroTypeId(copyId)
        else
            return heroTypeId
        endif	
    endfunction
    function TalentGetUnitTypeId takes unit u returns integer
        return TalentGetUsedHeroTypeId(GetUnitTypeId(u))
    endfunction
    
    
    //TalentJ
    //Handleing Choice / Tier Creations
    function TalentChoiceCreateTrigger takes trigger onLearn, trigger onReset returns integer
        set udg_TalentChoiceLast = udg_TalentChoiceLast + 1
        set udg_TalentChoiceOnLearn[udg_TalentChoiceLast] = onLearn
        set udg_TalentChoiceOnReset[udg_TalentChoiceLast] = onReset
        return udg_TalentChoiceLast
    endfunction
    function TalentChoiceCreate takes code onLearn, code onReset returns integer
        set udg_TalentChoiceLast = udg_TalentChoiceLast + 1
        if onLearn != null then
            set udg_TalentChoiceOnLearn[udg_TalentChoiceLast] = CreateTrigger()
            call TriggerAddAction(udg_TalentChoiceOnLearn[udg_TalentChoiceLast], onLearn)
        endif
        if onReset != null then
            set udg_TalentChoiceOnReset[udg_TalentChoiceLast] = CreateTrigger()
            call TriggerAddAction(udg_TalentChoiceOnReset[udg_TalentChoiceLast], onReset)
        endif	
        return udg_TalentChoiceLast
    endfunction
    
    function TalentChoiceCreateAll takes string head, string text, string icon, code onLearn, code onReset returns integer
        call TalentChoiceCreate(onLearn, onReset)
        set udg_TalentChoiceHead[udg_TalentChoiceLast] = head
        set udg_TalentChoiceText[udg_TalentChoiceLast] = text
        set udg_TalentChoiceIcon[udg_TalentChoiceLast] = icon
        return udg_TalentChoiceLast
    endfunction
    function TalentChoiceCreateAllTrigger takes string head, string text, string icon, trigger onLearn, trigger onReset returns integer
        call TalentChoiceCreateTrigger(onLearn, onReset)
        set udg_TalentChoiceHead[udg_TalentChoiceLast] = head
        set udg_TalentChoiceText[udg_TalentChoiceLast] = text
        set udg_TalentChoiceIcon[udg_TalentChoiceLast] = icon
        return udg_TalentChoiceLast
    endfunction
    
    function TalentTierCreate takes nothing returns integer
        set udg_TalentTierLast = udg_TalentTierLast + 1
        return udg_TalentTierLast
    endfunction
    
    function TalentTierAddChoice takes integer tier, integer choice returns nothing
        local integer count = LoadInteger(udg_TalentHash, -tier, 0) + 1
        call SaveInteger(udg_TalentHash, -tier, count, choice)
        call SaveInteger(udg_TalentHash, -tier, 0, count)
    endfunction
    function TalentTierGetChoiceCount takes integer tier returns integer
        if tier > 0 then //tiers are saved in the negative side, convert positive calls in negative ones
            return LoadInteger(udg_TalentHash, -tier, 0)
        else
            return LoadInteger(udg_TalentHash, tier, 0)
        endif	
    endfunction
    function TalentTierGetChoice takes integer tier, integer index returns integer
        if tier > 0 then //tiers are saved in the negative side, convert positive calls in negative ones
            return LoadInteger(udg_TalentHash, -tier, index)
        else
            return LoadInteger(udg_TalentHash, tier, index)
        endif	
    endfunction
    
    function TalentChoiceCreateEx takes code onLearn, code onReset returns integer
        local integer choice = TalentChoiceCreate(onLearn, onReset)
        call TalentTierAddChoice(udg_TalentTierLast, choice)
        return choice
    endfunction
    function TalentChoiceCreateTriggerEx takes trigger onLearn, trigger onReset returns integer
        local integer choice = TalentChoiceCreateTrigger(onLearn, onReset)
        call TalentTierAddChoice(udg_TalentTierLast, choice)
        return choice
    endfunction
    function TalentChoiceCreateAllEx takes string head, string text, string icon, code onLearn, code onReset  returns integer
        local integer choice = TalentChoiceCreateAll(head, text, icon, onLearn, onReset)
        call TalentTierAddChoice(udg_TalentTierLast, choice)
        return choice
    endfunction
    function TalentChoiceCreateAllTriggerEx takes string head, string text, string icon, trigger onLearn, trigger onReset  returns integer
        local integer choice = TalentChoiceCreateAllTrigger(head, text, icon, onLearn, onReset)
        call TalentTierAddChoice(udg_TalentTierLast, choice)
        return choice
    endfunction
    function TalentChoiceGetAbilityCount takes integer choice returns integer
        return LoadInteger(udg_TalentHash, choice, 0)
    endfunction

    
    function TalentChoiceAddAbility takes integer choice, integer abilityId returns nothing
        local integer count = LoadInteger(udg_TalentHash, choice, 0) + 1
        call SaveInteger(udg_TalentHash, choice, count, abilityId)
        call SaveInteger(udg_TalentHash, choice, 0, count)
    endfunction
    function TalentChoiceReplaceAbility takes integer choice, integer oldAbility, integer newAbility returns nothing
        local integer count = LoadInteger(udg_TalentHash, choice, 0) + 1
        call SaveInteger(udg_TalentHash, choice, count, newAbility)
        call SaveInteger(udg_TalentHash, choice, -count, oldAbility)
        call SaveInteger(udg_TalentHash, choice, 0, count)
    endfunction
    function TalentChoiceReplaceAbilityEx takes integer oldAbility, integer newAbility returns nothing
        call TalentChoiceReplaceAbility(udg_TalentChoiceLast, oldAbility, newAbility)
    endfunction

    //Checks if ASCII is loaded b/c of S2A, if true then parse string for codes and add ability each 4 letters
    //Example: call TalentChoiceAddSpells(udg_TalentChoiceLast, abilityCodes)
    function TalentChoiceAddSpells takes integer choice, string abilityCodes returns nothing
    static if LIBRARY_Ascii then
        local integer startIndex = 0
        local integer skillCode = 1
        loop
        exitwhen startIndex + 3 >= StringLength(abilityCodes)
            set skillCode = S2A(SubString(abilityCodes, startIndex, startIndex + 4))
            call TalentChoiceAddAbility(choice, skillCode)
            set startIndex = startIndex + 5
        endloop
    else
        call BJDebugMsg("TalentChoiceAddSpells requires LIBRARY Ascii")
    endif
    endfunction
    
    // function TalentChoiceCreateAddSpellsSimple takes string abilityCodes returns integer
    //     return TalentChoiceCreateAddSpells(null, null, abilityCodes)
    // endfunction

    //Loop is just for setting the spells as a list, the Icon and Head (main descrip) still need to be set
    function TalentChoiceCreateAddSpells takes code onLearn, code onReset, string abilityCodes returns integer
        local integer choice = TalentChoiceCreateEx(onLearn, onReset)
        local integer index = 0
        local integer abiCode = 0
        call TalentChoiceAddSpells(choice, abilityCodes)
        set udg_TalentChoiceText[choice] = GetLocalizedString("COLON_SPELLS")
        loop
            set index = index + 1
            exitwhen index > TalentChoiceGetAbilityCount(choice)
            set abiCode = LoadInteger(udg_TalentHash, choice, index)
            if index == 1 then
                set udg_TalentChoiceText[choice] = udg_TalentChoiceText[choice] + " " + GetObjectName(abiCode) + "|r"
            else
                set udg_TalentChoiceText[choice] = udg_TalentChoiceText[choice] + ", " + GetObjectName(abiCode) + "|r"
            endif		
        endloop
        return choice
    endfunction

    //TODO: Make a Replace that takes onCallBack functions

    function TalentChoiceCreateReplaceSpell takes integer oldSpell, integer newSpell returns integer
        call TalentChoiceCreateEx(null,null)
        call TalentChoiceReplaceAbility(udg_TalentChoiceLast, oldSpell, newSpell)
        return udg_TalentChoiceLast
    endfunction

    //TalentHero
    //Access data by UnitTypeId
    function TalentHeroTierCreate takes integer heroTypeId, integer level returns integer
        call SaveInteger(udg_TalentHash, heroTypeId, level, TalentTierCreate())
        return udg_TalentTierLast
    endfunction
    function TalentHeroGetTier takes integer heroTypeId, integer level returns integer
        return LoadInteger(udg_TalentHash, heroTypeId, level)
    endfunction
    function TalentHeroSetTier takes integer heroTypeId, integer level, integer tier returns nothing
        call SaveInteger(udg_TalentHash, heroTypeId, level, tier)
    endfunction
    function TalentHeroGetFinalTier takes integer heroTypeId returns integer
        return LoadInteger(udg_TalentHash, heroTypeId, TalentHashIndex_FinalTierLevel())
    endfunction
    function TalentHeroSetFinalTier takes integer heroTypeId, integer level returns nothing
        call SaveInteger(udg_TalentHash, heroTypeId, TalentHashIndex_FinalTierLevel(), level)
    endfunction
    
    function TalentHeroSetCopy takes integer result, integer copyOrigin returns nothing
        call SaveInteger(udg_TalentHash, result, TalentHashIndex_DataCopyData(), copyOrigin)
    endfunction
    
    function TalentHeroLevel2SelectionIndex takes integer heroTypeId, integer level returns integer
        local integer i = 0
        local integer count = 0
        
        if TalentHeroGetTier(heroTypeId, level) == 0 then //The level has no tier?
            return -1
        endif
        
        loop
            exitwhen i > level
            if TalentHeroGetTier(heroTypeId, i) != 0 then
                set count = count + 1
            endif
            set i = i + 1
        endloop
    
        return count
    endfunction
    
    //TalentUnit
    //Talent-Data of an existing unit
    function TalentUnitGetSelectionsDoneCount takes integer unitHandle returns integer
        return LoadInteger(udg_TalentHash, unitHandle, TalentHashIndex_SelectionsDone())
    endfunction
    
    function TalentUnitGetSelectionButtonUsed takes integer unitHandle, integer selectionIndex returns integer
        return LoadInteger(udg_TalentHash, unitHandle, selectionIndex)
    endfunction
    function TalentUnitGetSelectionLevel takes integer unitHandle, integer selectionIndex returns integer
        return LoadInteger(udg_TalentHash, unitHandle, StringHash("SelectionLevel"+I2S(selectionIndex)))
    endfunction
    
    function TalentUnitGetChoiceDone takes unit u, integer selectionIndex returns integer
        local integer uId = GetHandleId(u)
        return TalentTierGetChoice(TalentHeroGetTier(TalentGetUnitTypeId(u), TalentUnitGetSelectionLevel(uId, selectionIndex)), TalentUnitGetSelectionButtonUsed(uId, selectionIndex))
    endfunction
    
    function TalentUnitGetCurrentTier takes integer unitHandle returns integer
        return LoadInteger(udg_TalentHash, unitHandle, TalentHashIndex_CurrentChoice())
    endfunction
    function TalentUnitGetCurrentTierLevel takes integer unitHandle returns integer
        return LoadInteger(udg_TalentHash, unitHandle, TalentHashIndex_CurrentChoiceLevel())
    endfunction
    
    
    function TalentUnitGetTalentProgressLevel takes integer unitHandle returns integer
        return LoadInteger(udg_TalentHash, unitHandle, TalentHashIndex_LevelOfLastChoice())
    endfunction
    function TalentUnitHasChoice takes integer unitHandle returns boolean
        return LoadBoolean(udg_TalentHash, unitHandle, TalentHashIndex_HasChoice())
    endfunction
    //Talent
    //=========
    
    function TalentHas takes unit u returns boolean
        return HaveSavedInteger(udg_TalentHash, TalentGetUnitTypeId(u), TalentHashIndex_FinalTierLevel())
    endfunction
    
    //has the general Choice UI or hero specific Choice UI.
    function TalentHasCondition takes nothing returns boolean
        return TalentHas(GetTriggerUnit())
    endfunction
    
    function TalentAddSelection takes unit u returns nothing
        local integer tierGained
        local integer heroTypeId = TalentGetUnitTypeId(u)
        local integer currentLevel = IMaxBJ(GetHeroLevel(u), GetUnitLevel(u))
        local integer uId = GetHandleId(u)
        local player owner 
        //Start from the last skill selection added.
        local integer loopA = TalentUnitGetTalentProgressLevel(uId)
    
        // Only show 1 SelectionContainer at the same time.
        if TalentUnitHasChoice(uId) then
            return
        endif
    
        set owner = GetOwningPlayer(u)
        loop
            exitwhen loopA > currentLevel
            set tierGained = TalentHeroGetTier(heroTypeId, loopA)			
            if tierGained != 0 then 
                
                //Remember the container gained
                call SaveInteger(udg_TalentHash, uId, TalentHashIndex_CurrentChoice(), tierGained)
                //Remember the level of the container gained
                call SaveInteger(udg_TalentHash, uId, TalentHashIndex_CurrentChoiceLevel(), loopA)
                //Mark unit to have a selection.
                call SaveBoolean(udg_TalentHash, uId, TalentHashIndex_HasChoice(), true)
                //Remember this Level to leave lower levels out for further selections checks.
                call SaveInteger(udg_TalentHash, uId,TalentHashIndex_LevelOfLastChoice(),loopA +1)
                
                if TalentThrowEventAvailable then //Throw Selection Event
                    set udg_Talent__Choice = 0
                    set udg_Talent__Unit = u
                    set udg_Talent__UnitCode = heroTypeId
                    set udg_Talent__Level = loopA
                    set udg_Talent__Tier = tierGained
                    set udg_Talent__Event = 0
                    set udg_Talent__Event = 2
                    set udg_Talent__Event = 0
                endif
            //	call TalentBoxSetTier(loopA, tierGained, owner)
                set owner = null
                
                return
            endif
            set loopA = loopA + 1
        endloop
        //if this part of code is reached there is no choice avaible
    
        //Remember this Level to leave lower levels out for further selections checks.
        call SaveInteger(udg_TalentHash, uId,TalentHashIndex_LevelOfLastChoice(),currentLevel + 1)
    
        set owner = null
    endfunction
    
    // function IsNotExemptHeroSkill takes integer skillGained returns boolean
    //     //Holy Nova
    //     if skillGained == 'A08W' then
    //         return false
    //     endif
    //     //Shadow Word: Pain Disc
    //     if skillGained == 'A08V' then
    //         return false
    //     endif
    //     return true
    // endfunction

    function TalentAddSkill takes unit u, integer skillGained, integer newLevel returns nothing
        local integer skillGainedLevel = GetUnitAbilityLevel(u, skillGained)
        if skillGainedLevel == 0 then //Already got skillGained?
            call UnitAddAbility(u, skillGained)
            call UnitMakeAbilityPermanent(u, true, skillGained)
            if newLevel == 0 then
                call SetUnitAbilityLevel(u, skillGained, 1)
                if (GetHeroLevel(u) >= udg_FINALS_LEVEL_2) then
                    call SetUnitAbilityLevel(u, skillGained, 2)
                    if (GetHeroLevel(u) >= udg_FINALS_LEVEL_3) then
                        call SetUnitAbilityLevel(u, skillGained, 3)
                    endif
                endif
            else
                call SetUnitAbilityLevel(u, skillGained, newLevel)
            endif
        // elseif TalentImproveAbilities then//Can upgrade Levels?
        //     call SetUnitAbilityLevel(u, skillGained, skillGainedLevel + 1)
        endif
    endfunction
    function TalentRemoveSkill takes unit u, integer skillLost returns nothing
        //local integer skillLostLevel = GetUnitAbilityLevel(u, skillLost)
        call UnitRemoveAbility(u, skillLost)
        // THE BELOW ERRORS B/C IT"S NOT LOOPING FOR skillLostLevel
        // if TalentImproveAbilities and skillLostLevel > 1 then //Can Decrease Level?
        //     set skillLostLevel = skillLostLevel - 1
        //     call SetUnitAbilityLevel(u, skillLost, skillLostLevel)
        // else
        //     call UnitRemoveAbility(u, skillLost)
        // endif
    endfunction
    function TalentReplaceSkill takes unit u, integer skillReplaced, integer skillGained, boolean isReset returns nothing
        local player p = GetOwningPlayer(u)
        local integer lvl = 1 
        local integer skillReplacedLevel = GetUnitAbilityLevel(u, skillReplaced)
        if not TalentReplacedAbilityRequired or skillReplacedLevel != 0 then
            // call TalentRemoveSkill(u, skillReplaced)
            // call BlzUnitDisableAbility( u, skillLost, true, true )
            if skillGained != 0 then
                //call TalentAddSkill(u, skillGained, skillReplacedLevel)
                //call Debug(BlzGetUnitStringField(u, UNIT_SF_NAME))
                //Change to > 3 then can work with other abilities
                if skillReplacedLevel > 2 then //and IsNotExemptHeroSkill(skillGained) then
                    if skillGained == 'A0F4' and u == udg_yH_Unholy_DK then
                        set lvl = 2
                    endif          
                else
                    set lvl = 8
                endif
                // call TalentAddSkill(u, skillGained, lvl)
                // call SetPlayerAbilityAvailable( p, skillReplaced, false ) 
                // call SetPlayerAbilityAvailable( p, skillGained, true )
                // // Disable the old ability to prevent it from being cast
                //Must disable and add/remove in reverse order to prevent inhertitance issues like what happened with ('AEbl' - blink)
                if not isReset then
                    call BlzUnitDisableAbility(u, skillReplaced, true, true)
                    call TalentAddSkill(u, skillGained, lvl)
                    // call SetPlayerAbilityAvailable( p, skillReplaced, false ) 
                else
                    call TalentRemoveSkill(u, skillReplaced)
                    call BlzUnitDisableAbility(u, skillGained, false, false)
                    // call SetPlayerAbilityAvailable( p, skillGained, true )
                endif
            endif
        endif
        set p = null
    endfunction
    
    function TalentPickDo takes unit u, integer buttonNr returns integer
        local integer uId 				= GetHandleId(u)
        local integer heroTypeId 		= TalentGetUnitTypeId(u)
        local integer tier 				= TalentUnitGetCurrentTier(uId)
        local integer tierLevel 		= TalentUnitGetCurrentTierLevel(uId)
        local integer selectionsDone 	= TalentUnitGetSelectionsDoneCount(uId)	+ 1
        local integer choiceIndex 		= TalentTierGetChoice(tier, buttonNr)
        local integer skillGained
        local integer skillReplaced
        local integer skillLevel        = 0
        local integer loopB 			= TalentChoiceGetAbilityCount(choiceIndex)
        if not TalentUnitHasChoice(uId) or choiceIndex == 0 then //Requiers to have a Choice
            return 404
        endif
        call PlayerNumbtoHeroesNumbParam(GetOwningPlayer(u))
        if TimerGetRemaining(udg_DamageTimer[udg_Player_Number]) > 0 then //Required to be out of combat
            call ErrorMessage( "Must be out of combat for 5 sec before changing talents", GetOwningPlayer(u) )
            return 404
        endif
        

        //tierLevel and buttonNr are consistent tierLevel == 5/10/20/30/40
        //call DisplayTimedTextToPlayer(GetOwningPlayer(u),0.52,0.96,2, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n|cffffcc00"+"Tier: " + I2S(tier) +" TierLVL: " + I2S(tierLevel) +" choiceIndex: " + I2S(choiceIndex) + " buttonNr: " + I2S(buttonNr) +"|r" )

        loop	//Load all saved Abilities and add/improve the lvl for them for the unit
            exitwhen loopB == 0
            set skillGained = LoadInteger(udg_TalentHash, choiceIndex, loopB)
            set skillReplaced = LoadInteger(udg_TalentHash, choiceIndex, -loopB)
            
            if skillReplaced != 0 then //Replaces?
                set skillLevel = GetUnitAbilityLevel(u, skillReplaced)
                if skillLevel == BlzGetAbilityIntegerField( BlzGetUnitAbility(u,skillReplaced),ABILITY_IF_LEVELS) and skillLevel != 0 then
                    if BlzGetUnitAbilityCooldownRemaining( u, skillReplaced ) == 0 then 
                        call TalentReplaceSkill(u, skillReplaced, skillGained, false)
                    else
                        call ErrorMessage( "That ability must be off cooldown before being replaced", GetOwningPlayer(u) )
                        return 404
                    endif
                else
                    call ErrorMessage( "That ability must be fully maxed out before being replaced", GetOwningPlayer(u) )
                    return 404
                endif
            else
                call TalentAddSkill(u, skillGained,0)
            endif
            set loopB = loopB - 1
        endloop
    
        //Execute OnLearn
        set udg_Talent__Unit = u
        set udg_Talent__UnitCode = heroTypeId
        set udg_Talent__Button = buttonNr
        set udg_Talent__Choice = choiceIndex
        set udg_Talent__Tier = tier
        set udg_Talent__Level = tierLevel
        static if LIBRARY_TalentTasStats then
            call TalentTasStatsAdd(u, choiceIndex)
        endif

        set udg_Talent__Error = 0
        call TriggerExecute(udg_TalentChoiceOnLearn[choiceIndex])
        if udg_Talent__Error != 0 then
            return 404
        endif
        
        if TalentThrowEventPick then
            //Throw Selection Event
            set udg_Talent__Event = 0
            set udg_Talent__Event = 1
            set udg_Talent__Event = 0
        endif
        //Save Choices
        //call SaveInteger(udg_TalentHash, uId, selectionsDone, choiceIndex) //Save the picked ChoiceIndex
        call SaveInteger(udg_TalentHash, uId, selectionsDone, buttonNr) //Save the picked ButtonIndex
        call SaveInteger(udg_TalentHash, uId, TalentHashIndex_SelectionsDone(), selectionsDone)
        call SaveInteger(udg_TalentHash, uId, StringHash("SelectionLevel"+I2S(selectionsDone)), tierLevel)
    
        //Unmark having a selection.
        call SaveBoolean(udg_TalentHash, uId, TalentHashIndex_HasChoice(), false)
        //Last choice for this heroType?
        if TalentHeroGetFinalTier(heroTypeId) == tierLevel then
            
            //Throw Finish Choices Event.
            if TalentThrowEventFinish then
                set udg_Talent__Event = 0
                set udg_Talent__Event = 3
                set udg_Talent__Event = 0
            endif
        else
            //Check for further choices.
            call TalentAddSelection(u)
        endif
        
        set u = null
        return 0
    endfunction
    
    function TalentLevelUpSimple takes nothing returns nothing
        call TalentAddSelection(GetTriggerUnit())
    endfunction
    
    
    function TalentAdd2Hero takes unit u returns nothing
        local integer uId = GetHandleId(u)
        if not IsUnitInGroup(u, udg_TalentUser) then
            call GroupAddUnit(udg_TalentUser, u)
        endif	
        call TalentAddSelection(u)
    endfunction
    function TalentAutoOnEnterMap takes nothing returns nothing
        call TalentAdd2Hero(GetTriggerUnit())
    endfunction
    
    function TalentResetDo takes unit u, integer amountOfResets, boolean isReroll returns nothing
        local integer uId
        local integer heroTypeId
        local integer selectionsDone
        local integer skillGained
        local integer skillReplaced
        local integer choice
        local integer level
        local integer loopB = 0
        local integer i = 0
        //local integer customUI
        local integer tier
        local integer spellNr
        local boolean isUsingBook
        local integer array prevSelections

        if u == null then
            return
        endif

        if amountOfResets < 1 then
            return
        endif
        
        set uId = GetHandleId(u)
        set heroTypeId = TalentGetUnitTypeId(u)
        set selectionsDone = TalentUnitGetSelectionsDoneCount(uId)
        //No selections done -> skip the rest
        if selectionsDone == 0 then
            return
        endif

        //Required to be out of combat
        call PlayerNumbtoHeroesNumbParam(GetOwningPlayer(u))
        if TimerGetRemaining(udg_DamageTimer[udg_Player_Number]) > 0  and not isReroll then
            call ErrorMessage( "Must be out of combat for 5 sec before changing talents", GetOwningPlayer(u) )
            return
        endif
        
        set udg_Talent__Unit = u
        set udg_Talent__UnitCode = heroTypeId
        set i = 0
        //Remove Auto-added Skills
        loop
            set level = TalentUnitGetSelectionLevel(uId, selectionsDone)
            set tier = TalentHeroGetTier(heroTypeId, level)
            set spellNr = TalentUnitGetSelectionButtonUsed(uId, selectionsDone)
            set choice = TalentTierGetChoice(tier, spellNr)
            
            set udg_Talent__Choice = choice
            set udg_Talent__Tier = tier
            set udg_Talent__Level = level
            set udg_Talent__Button = spellNr
            
            static if LIBRARY_TalentTasStats then
                call TalentTasStatsRemove(u, choice)
            endif
    
            if TalentThrowEventReset then	//Throw a event that this choice is going to be lost.
                set udg_Talent__Event = 0
                set udg_Talent__Event = -1
                set udg_Talent__Event = 0
            endif

            //if udg_TalentChoices[GetPlayerId(GetOwningPlayer(u)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] then
                //Have true, next need 12, and check if u == DH or MmH
            // call ErrorMessage( "Cannot unlearn talent while actively being used.", GetOwningPlayer(u) )
            //return
            //endif
            
            set loopB = TalentChoiceGetAbilityCount(choice)
            loop	//Load all saved Abilities and remove/decrease them for the unit
                exitwhen loopB == 0
                set skillGained = LoadInteger(udg_TalentHash, choice, loopB)
                set skillReplaced = LoadInteger(udg_TalentHash, choice, -loopB)
                
                if skillReplaced != 0 then //Replaces?
                    if BlzGetUnitAbilityCooldownRemaining( u, skillGained ) > 0  and not isReroll then
                        call ErrorMessage( "Abilities must be off cooldown before being unlearned", GetOwningPlayer(u) )
                        return
                    else 
                        //Delay 1
                        // call TalentReplaceSkill(u, prevSelections[i+1], prevSelections[i+2])
                        set prevSelections[i] = 1
                        set prevSelections[i+1] = skillGained
                        set prevSelections[i+2] = skillReplaced
                    endif
                else
                    if BlzGetUnitAbilityCooldownRemaining( u, skillGained ) > 0 and not isReroll then 
                        call ErrorMessage( "Abilities must be off cooldown before being unlearned", GetOwningPlayer(u) )
                        return
                    else
                        //Delay 2
                        set prevSelections[i] = 2
                        set prevSelections[i+1] = skillGained
                    endif
                endif
                set loopB = loopB - 1
            endloop
            
            //Delay 3
            if prevSelections[i] == 0 then
                set prevSelections[i] = 3
            endif
            set prevSelections[i+3] = choice

            set i = i + 5

            set selectionsDone = selectionsDone - 1
            set amountOfResets = amountOfResets - 1
            exitwhen selectionsDone <= 0 or amountOfResets <= 0
        endloop
        
        //4 blocks = skillGained/Replaced/choice/(extra future use?)
        set i = 0
        loop
            call Debug("Reset: " + I2S(i) + "," + I2S(prevSelections[i]) )
            exitwhen prevSelections[i] == 0
            if prevSelections[i] == 1 then
                call Debug(I2S(i) + "," + "TalentReplaceSkill")
                call TalentReplaceSkill(u, prevSelections[i+1], prevSelections[i+2], true)
            elseif prevSelections[i] == 2 then
                call Debug(I2S(i) + "," + "TalentRemoveSkill")
                call TalentRemoveSkill(u, prevSelections[i+1])
                //Band-Aid fix for TalentChoiceCreateAddAndHideSpells
                if prevSelections[i+1] == 'A0F2' then //Envenom
                    call TalentRemoveSkill(u, 'A0F1')
                endif
                // if prevSelections[i+1] == 'A0G1' then //SpectralSight
                //     call TalentRemoveSkill(u, 'Atru')
                // endif
            endif
            call Debug(I2S(i) + "," + "TriggerExecute")
            set udg_Talent__Choice = prevSelections[i+3]
            call TriggerExecute(udg_TalentChoiceOnReset[prevSelections[i+3]])

            set i = i + 5
        endloop

        //Forget this unit?
        if selectionsDone <= 0 then
            //Save Level Progress of talents to the choice Level.
            call SaveInteger(udg_TalentHash, uId, TalentHashIndex_LevelOfLastChoice(), 0)		
            //Choices Done
            call SaveInteger(udg_TalentHash, uId,TalentHashIndex_SelectionsDone(), 0)
            call SaveBoolean(udg_TalentHash, uId,TalentHashIndex_HasChoice(), false)
            //Full Reset
            //call FlushChildHashtable(udg_TalentHash, uId)
        else
            //Partly Reset.
            
            //Has no Choice,dat is needed to run the addChoice function.
            call SaveBoolean(udg_TalentHash, uId,TalentHashIndex_HasChoice(), false)
    
            //Save Level Progress of talents to the choice Level.
            call SaveInteger(udg_TalentHash, uId, TalentHashIndex_LevelOfLastChoice(), level)
    
            //Choices Done
            call SaveInteger(udg_TalentHash, uId,TalentHashIndex_SelectionsDone(), selectionsDone)
        endif	
        
        call TalentAddSelection(u)
    endfunction
    
    function TalentReset takes nothing returns nothing
        call TalentResetDo(udg_Talent__Unit, udg_Talent__ResetAmount, false)
        set udg_Talent__Unit = null
    endfunction
    
    //runs when executing the Talent <gen> trigger.
    function TalentInit takes nothing returns nothing
        local group g = CreateGroup()
        local unit fog
        local integer fogId
        
        set udg_TalentTrigger[TT_LevelUp()] = CreateTrigger()
        set udg_TalentTrigger[TT_AutoDetectUnits()] = CreateTrigger()
    
        
        set udg_TalentReset = CreateTrigger()
                
        call TriggerAddAction( udg_TalentReset, function TalentReset)
        
        call TriggerAddAction( udg_TalentTrigger[TT_LevelUp()], function TalentLevelUpSimple)
        
        
        
        //Get Choices on Entering Map for lvl 0/1.
        if TalentAutoDetectNewUser then
            call TriggerRegisterEnterRectSimple( udg_TalentTrigger[TT_AutoDetectUnits()], GetPlayableMapRect() )
        endif	
        call TriggerAddAction( udg_TalentTrigger[TT_AutoDetectUnits()], function TalentAutoOnEnterMap)
        call TriggerAddCondition( udg_TalentTrigger[TT_AutoDetectUnits()], Condition( function TalentHasCondition ))
    
        call TriggerRegisterAnyUnitEventBJ(udg_TalentTrigger[TT_LevelUp()], EVENT_PLAYER_HERO_LEVEL)
        
        //Add possible choices to all Units having the Talent book.
        call GroupEnumUnitsInRect (g, GetPlayableMapRect(), null)
        loop
            set fog = FirstOfGroup(g)
            exitwhen fog == null
            call GroupRemoveUnit(g,fog)
            if TalentHas(fog) then
                call TalentAdd2Hero(fog)
            endif
        endloop
        
        //cleanup
        call DestroyGroup(g)
        set g = null
        set fog = null
        
        call ExecuteFunc("TalentBoxInit")
        call ExecuteFunc("TalentGridInit")	
    endfunction
    
    function TalentMacroDo takes unit u, string s returns nothing
        local string char 
        local integer i = 0
        local integer sLength = StringLength(s)
        local integer charAsInt
        set char = SubString(s, 0, 1)
        if char != "-" then //Invalid macro, macro has to start with "-"
            return
        endif
        loop
            exitwhen i > sLength
            set char = SubString(s, i, i + 1)
    
            if char == "U" or char == "u" then
                call TalentResetDo(u, 999999, false)
            endif
            set charAsInt = S2I(char)
            if charAsInt > 0 then
                call TalentPickDo(u, charAsInt)
            endif
            set i = i + 1
        endloop
    endfunction
    
    function TalentGetMacro takes unit u returns string
        local string text = "-U"
        local integer uId = GetHandleId(u)
        local integer selectionsDone = TalentUnitGetSelectionsDoneCount(uId)
        local integer i = 1
        loop
            exitwhen i > selectionsDone
            set text = text + I2S(TalentUnitGetSelectionButtonUsed(uId, i))
            set i = i + 1
        endloop
        return text
    endfunction
    
    private function init_function takes nothing returns nothing
        set udg_TalentHash = InitHashtable(  )
        call ExecuteFunc("TalentStringsInit")	//TalentStringsInit should run before any TalentHeroSheet was generated
        call TimerStart(CreateTimer(),0,false, function TalentInit)
        endfunction
    
endlibrary
    