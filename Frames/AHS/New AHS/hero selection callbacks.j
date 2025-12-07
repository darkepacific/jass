library HeroSelectionCallbacks requires HeroSelection, StartingPoint

	globals

		//=============================================================================================================================
		//Globals for interfacing with rest of map. All player indices start at 0.
		//=============================================================================================================================

		integer array heroIdOfPlayer								//Stores the unit id of the hero each player picked.
		integer array startingZoneOfPlayer							//Stores the type of the hero each player picked.
		string array heroIconPathOfPlayer							//Stores the icon path of the hero each player picked.
		
		//=============================================================================================================================
		//Can also be used in custom code. Read-Only!

		boolean array playerHasHero									//Player has picked a hero (does not mean hero was created).
		boolean array isInHeroSelection								//Player is currently viewing the hero selection screen.
		boolean array isFadingOut										//Player is currently fading out of hero selection.
	
		boolean inBanPhase = false
		boolean array playerIsHuman
		string array coloredPlayerName
		boolean array heroSelectionDisabledForPlayer
		boolean array heroPreselectionDisabledForPlayer
		boolean array playerHasBan
		boolean array isRepicking
		integer numPlayersWithHero = 0
		integer numPlayersInSelection = 0
		integer numSelectingPlayers = 0
		integer numSelectingHumans = 0
		integer array playerNumberOfSlot							//To get the player index when iterating over all selecting players from 1 to numSelectingPlayers.
		
		effect array selectedHero
		effect array backgroundHeroHighlight
		effect array backgroundHero

		real array BACKGROUND_HERO_X
		real array BACKGROUND_HERO_Y
		integer NUMBER_OF_HEROES = 0

	endglobals

	//=================================================================================================================================
	//These functions are the main interface with the rest of your map.
	//=================================================================================================================================

	function HeroSelectionOnEscape takes player whichPlayer returns nothing
		local integer pid = GetPlayerId(whichPlayer)
		local string s = udg_Hero_Strings[pid]

		//Loaded heroes are registered correctly but new ones are not.
		static if LIBRARY_TestHeroSelection then

			if udg_GameMode == "PVP" or (s == null or s == "") then
				set playerHero[pid] = CreateUnit(whichPlayer, heroIdOfPlayer[pid], HERO_SPAWN_X, HERO_SPAWN_Y, 90)
				call SetHeroVariable(playerHero[pid])

				//Combo effects and glow called in StartingPoint
				if startingZoneOfPlayer[pid] == 0 then
					call DwarfStartingPoint(whichPlayer, playerHero[pid])
				elseif startingZoneOfPlayer[pid] == 1 then
					call HumanStartingPoint(whichPlayer, playerHero[pid])
				elseif startingZoneOfPlayer[pid] == 2 then
					call NightElfStartingPoint(whichPlayer, playerHero[pid])
				elseif startingZoneOfPlayer[pid] == 3 then
					call UndeadStartingPoint(whichPlayer, playerHero[pid])
				elseif startingZoneOfPlayer[pid] == 4 then
					call BloodElfStartingPoint(whichPlayer, playerHero[pid])
				elseif startingZoneOfPlayer[pid] == 5 then
					call TrollStartingPoint(whichPlayer, playerHero[pid])
				endif

				if udg_GameMode == "PVP" then
					call SetHeroLevel(playerHero[pid], 25, false)
					//Bandit's Boots
					// call UnitAddItem(playerHero[pid], CreateItem('I008', GetUnitX(playerHero[pid]), GetUnitY(playerHero[pid])))
					call UnitAddItemByIdSwapped( 'I008', playerHero[pid])
					set udg_P_Items[GetPItemsIndex(whichPlayer, udg_Bag_Page[GetPlayerHeroNumber(whichPlayer)], 1)] = bj_lastCreatedItem
				else
					//Burnt Leather Boots
					// call UnitAddItem(playerHero[pid], CreateItem('I007', GetUnitX(playerHero[pid]), GetUnitY(playerHero[pid])))
					call UnitAddItemByIdSwapped( 'I007', playerHero[pid])
					set udg_P_Items[GetPItemsIndex(whichPlayer, udg_Bag_Page[GetPlayerHeroNumber(whichPlayer)], 1)] = bj_lastCreatedItem
				endif
			else
            	call Debug("Loading Hero for Player: " + GetPlayerName(whichPlayer))
				set udg_SaveLoadEvent_Player = whichPlayer
				set udg_SaveCodeString = s
				call TriggerExecute(gg_trg_Load_GUI)
            	// call Load_GUI(whichPlayer, s)
			endif

			//Register autosave on lvl
			if udg_GameMode != "PVP" then
				call TriggerRegisterUnitEvent(gg_trg_Autosave_On_Lvl_Up, udg_Heroes[GetPlayerHeroNumber(whichPlayer)], EVENT_UNIT_HERO_LEVEL)
				call TriggerRegisterUnitEvent(gg_trg_Autosave_On_Lvl_Up, udg_Heroes[GetPlayerHeroNumber(whichPlayer)], EVENT_UNIT_DEATH)
				// call TriggerRegisterUnitEvent(gg_trg_Autosave_On_Lvl_Up, udg_Heroes[GetPlayerHeroNumber(whichPlayer)], EVENT_UNIT_PICKUP_ITEM)
			endif

			static if LIBRARY_NeatMessages then
				call ClearNeatMessages()
			else
				call ClearTextMessages()
			endif
		endif
	endfunction
	
	function HeroSelectionOnFinal takes nothing returns nothing
		//Here you can insert the code that is executed when hero selection is concluded. This will most likely involve calling the main
		//function that progresses your map after hero selection ends. It is recommended to execute player-specific actions in OnEscape
		//instead.

		static if LIBRARY_TestHeroSelection then
			call ExecuteFunc("BeginGame")
		endif
	endfunction
	
	//=================================================================================================================================
	//These functions allow you to add additional visual effects, sounds, texts etc. to the hero selection that can't be achieved with 
	//the default options.
	//=================================================================================================================================
	
	function HeroSelectionOnRestart takes nothing returns nothing
		//Here you can insert additional code that is executed when hero selection is restarted.
		static if LIBRARY_TestHeroSelection then
		endif
	endfunction

	function HeroSelectionOnLast takes nothing returns nothing
		//Here you can insert additional code that is executed when the last player picks a hero.
		static if LIBRARY_TestHeroSelection then
			call ExecuteFunc("MusicSlowFadeOut")
		endif
	endfunction
	
	//=================================================================================================================================
	function HeroSelectionOnPick takes player whichPlayer, Hero whichHero, boolean wasRandomPick, boolean wasRepick returns nothing
		//Send the sync string here
		local integer pid = GetPlayerId(whichPlayer)
		local integer slot = GetSlotForHeroUnitID(heroIdOfPlayer[pid])
		local string s = ""

		if udg_GameMode != "PVP" then
			if whichPlayer == GetLocalPlayer() then
				call LoadSaveSlot(whichPlayer, slot)
			endif
		endif

		set s = null
	endfunction

	function HeroSelectionOnPreselect takes player whichPlayer, Hero oldHero, Hero newHero returns nothing
		//Here you can insert additional code that is executed when a player switches to a new hero during pre-selection.
	endfunction

	function HeroSelectionOnReturn takes player whichPlayer returns nothing
		//Here you can insert additional code that is executed when a player returns to hero selection.
	endfunction

	function HeroSelectionOnAllRandom takes nothing returns nothing
		//Here you can insert additional code that is executed when all random mode is selected.
	endfunction

	function HeroSelectionOnBegin takes nothing returns nothing
		//Here you can insert additional code that is executed when players are locked into hero selection.
		// static if LIBRARY_NeatMessages and LIBRARY_TestHeroSelection then
		// 	call NeatMessageTimedInWindow(5, "Heroes from all across Azeroth have gathered to fight the darkness. Only you can save this land...", centerWindow)
		// endif
	endfunction
	
	function HeroSelectionOnEnable takes nothing returns nothing
		//Here you can insert additional code that is executed when hero selection is enabled.
		// local integer i = 1
		// local integer P
		// local location tempLoc
		static if LIBRARY_TestHeroSelection then
			// loop
			// 	exitwhen i > numSelectingPlayers
			// 	set P = playerNumberOfSlot[i]
			// 	set circles[P] = AddSpecialEffect("buildings\\other\\CircleOfPower\\CircleOfPower.mdl", BACKGROUND_HERO_X[P], BACKGROUND_HERO_Y[P])
			// 	call BlzSetSpecialEffectColorByPlayer(circles[P], Player(PLAYER_NEUTRAL_AGGRESSIVE))
			// 	set tempLoc = Location(BACKGROUND_HERO_X[P], BACKGROUND_HERO_Y[P])
			// 	call BlzSetSpecialEffectZ(circles[P], GetLocationZ(tempLoc) + 10)
			// 	call RemoveLocation(tempLoc)
			// 	set i = i + 1
			// endloop
		endif
		// call ClearMapMusic()
		// call PlayMusic("LegendsofAzeroth.mp3")
	endfunction

	function HeroSelectionOnExpire takes nothing returns nothing
		//Here you can insert the code that is executed when the timer for the hero selection duration expires.
		static if LIBRARY_NeatMessages and LIBRARY_TestHeroSelection then
			call NeatMessageTimedInWindow(4, "The time has expired.", centerWindow)
		endif
	endfunction

	function HeroSelectionOnLeave takes player whichPlayer returns nothing
		//Here you can insert additional code that is executed when a player who is in hero selection leaves the game.
	endfunction

endlibrary