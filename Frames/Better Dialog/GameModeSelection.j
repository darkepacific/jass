scope GameModeSelection initializer Init
    globals
		private string gameMode = "Normal" //default state of button
    endglobals

    // function SelectGameMode takes framehandle whichDialog, player whichPlayer, string buttonName returns nothing
	// 	set gameMode = buttonName
    // endfunction

    function Confirm takes framehandle whichDialog, player whichPlayer, string buttonName returns nothing
		local real frameWaitTime = 11.0
		
		call CloseDialog(whichDialog)
		call NeatMessage(GetPlayerName(whichPlayer) + " votes for: " + buttonName )
		if (buttonName == "Normal") then
			set udg_GameVoteArray[GetPlayerId(whichPlayer)] = 1
		else
			set udg_GameVoteArray[GetPlayerId(whichPlayer)] = 2
		endif

		//Check which mode has the highest votes
		if TimerGetRemaining(udg_GameVoteTimer) > frameWaitTime then
			// call Debug("Waiting for " + R2S(TimerGetRemaining(udg_GameVoteTimer) - frameWaitTime))
			// call TriggerSleepAction((TimerGetRemaining(udg_GameVoteTimer) - frameWaitTime))
			call TimerStart(CreateTimer(), (TimerGetRemaining(udg_GameVoteTimer) - frameWaitTime), false, function CheckGameModeSelection)
		else
			call CheckGameModeSelection()
		endif
    endfunction
	
	private function Create takes nothing returns nothing
		local string array gameModeTooltips
		
		local ButtonData newButtonData = InitButtonData()
		local Button normalModeButton
		local Button pvpModeButton

		set gameModeTooltips[1] = "Select the game mode. 
				
		|cffffcc00Normal:
		Play a sandbox game. Ideal for exploration.
		
		All heroes start at level 1. Heroes can be saved and loaded.|r

		|cffaaaaaaPVP:
		Fast-paced PvP combat. Only one side can win.
		
		All heroes start at level 25 with bonus gold. No saving and loading.|r"

		set gameModeTooltips[2] = "Select the game mode. 
				
		|cffaaaaaaNormal:
		Play a sandbox game. Ideal for exploration.
		
		All heroes start at level 1. Heroes can be saved and loaded.|r

		|cffffcc00PVP:
		Fast-paced PvP combat. Only one side can win.
		
		All heroes start at level 25 with bonus gold. No saving and loading.|r"

		set normalModeButton = CreateButton("Normal", gameModeTooltips[1], Confirm)
		set pvpModeButton = CreateButton("PVP", gameModeTooltips[2], Confirm)
		// call AddButtonCycleState(gameModeButton, "PVP", gameModeTooltips[2])
		// set confirmButton = CreateButton("Confirm", null, Confirm)

		call AddButtonToData(newButtonData, normalModeButton)
		call AddButtonToData(newButtonData, pvpModeButton)
		

		call CreateBetterDialogForForce(udg_AlliancePlayers, "Choose Game Settings!", newButtonData)
		call CreateBetterDialogForForce(udg_HordePlayers, "Choose Game Settings!", newButtonData)

		call TimerStart(udg_GameVoteTimer, 15, false, function CheckGameModeSelection)
		set udg_GameVoteTimerDialog = CreateTimerDialogBJ(udg_GameVoteTimer, "Vote For a Game Mode")
		call TimerDialogDisplay(udg_GameVoteTimerDialog, true)
	endfunction

    private function Init takes nothing returns nothing
		call TimerStart(CreateTimer(), 0.01, false, function Create)
    endfunction
endscope