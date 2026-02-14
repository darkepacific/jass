function SetAllHeroesToLvl takes integer level returns nothing
	local integer i = 0

	loop
		exitwhen i >= 7
		call SetHeroLevel(udg_Heroes[i], level, true)
		set i = i + 1
	endloop
endfunction

function GiveItemToEnumUnit takes nothing returns nothing
	local unit u = GetEnumUnit()
	if ( IsUnitType(u, UNIT_TYPE_HERO) == true ) then
		call UnitAddItem(u, CreateItem(udg_Temp_Int, GetUnitX(u), GetUnitY(u)))
	endif
	set u = null
endfunction

function GiveItemToAllHeroes takes integer itemType returns nothing
	set udg_Temp_Int = itemType
	//TODO
endfunction

function AddGoldToAllPlayers takes integer amount returns nothing
	local integer i = 0
	loop
		exitwhen i >= bj_MAX_PLAYERS
		if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
			call SetPlayerState(Player(i), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(i), PLAYER_STATE_RESOURCE_GOLD) + amount)
		endif
		set i = i + 1
	endloop
endfunction

function CheckGameModeSelection takes nothing returns nothing
	local integer numPlayers = 0
	local integer numEntries = 0
	local integer i = 0
	local integer countNormal = 0
	local integer countPVP = 0

	loop
		exitwhen i >= bj_MAX_PLAYERS
		if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER then
			set numPlayers = numPlayers + 1
			if udg_GameVoteArray[i] > 0 then
				set numEntries = numEntries + 1
			endif
		endif
		set i = i + 1
	endloop

	// call BJDebugMsg("numEntries: " + I2S(numEntries) + " numPlayers: " + I2S(numPlayers))

	if numEntries == numPlayers or TimerGetRemaining(udg_GameVoteTimer) == 0 then
		if numEntries == numPlayers then
			// call BJDebugMsg("All players have voted.")
			call NeatMessage("All players have voted.")
		else
			// call BJDebugMsg("Vote timer expired.")
			call NeatMessage("Vote timer expired.")
		endif
		set i = 0
		loop
			exitwhen i >= bj_MAX_PLAYERS
			if udg_GameVoteArray[i] == 1 then
				set countNormal = countNormal + 1
			elseif udg_GameVoteArray[i] == 2 then
				set countPVP = countPVP + 1
			endif
			set i = i + 1
		endloop

		if countPVP > countNormal then
			set udg_GameMode = "PVP"
			call AddGoldToAllPlayers(12000)
			set udg_QUEST_XP_MULTIPLIER = udg_QUEST_XP_MULTIPLIER * 1.25
			set udg_QUEST_GOLD_MULTIPLIER = udg_QUEST_GOLD_MULTIPLIER * 1.25
			call TriggerExecute(gg_trg_S_Kill_Sylvanas)
			// call TriggerExecute(gg_trg_S_Kill_Lorthemar)
			call TriggerExecute(gg_trg_S_Kill_Anduin)
			// call TriggerExecute(gg_trg_S_Kill_Magni)
		else
			set udg_GameMode = "Normal"
		endif
		
		// call QuestMessageBJ(GetPlayersAll() ,bj_QUESTMESSAGE_HINT, "Game Mode: |cffffcc00"+udg_GameMode+"|r")
		call NeatMessage("Game Mode: |cffffcc00"+udg_GameMode+"|r")
		// static if LIBRARY_NeatMessages and LIBRARY_TestHeroSelection then
		// 	call NeatMessageTimedInWindow(5, "Game Mode: |cffffcc00"+udg_GameMode+"|r", centerWindow)
		// endif
		call PauseTimer(udg_GameVoteTimer)
		call TimerDialogDisplayBJ(false, udg_GameVoteTimerDialog)
		call CloseOpenDialogForAll()

		// set udg_GameStartTime = GetTimeOfDay()
		call TimerStart(CreateTimer(), 0.15, false, function EnableHeroSelection)
		// call EnableHeroSelection()

		if udg_GameMode == "Normal" then
			// call Debug("It got here.")
			call TriggerSleepAction(1.00)
			// call QuestMessageBJ(GetPlayersAll() ,bj_QUESTMESSAGE_ALWAYSHINT, "Press |cffffcc00C|r to Open the Save/Load Menu.")
			call NeatMessage("Press |cffffcc00C|r to Open the Save/Load Menu.")
		endif

	endif
endfunction