scope GameModeSelection initializer Init
    globals
		private string gameMode = "Normal" //default state of button
		private boolean array closeRequested
		private timer closeTimer = CreateTimer()
		private boolean closeTimerRunning = false
    endglobals

	private function CloseRequestedDialogs takes nothing returns nothing
		local integer i = 0
		loop
			exitwhen i >= bj_MAX_PLAYERS
			if closeRequested[i] then
				set closeRequested[i] = false
				call CloseOpenDialogForPlayer(Player(i))
			endif
			set i = i + 1
		endloop
		set closeTimerRunning = false
	endfunction

    // function SelectGameMode takes framehandle whichDialog, player whichPlayer, string buttonName returns nothing
	// 	set gameMode = buttonName
    // endfunction

    function Confirm takes framehandle whichDialog, player whichPlayer, string buttonName returns nothing
		local integer pid = GetPlayerId(whichPlayer)
		
		// IMPORTANT: do not destroy frames during their own click event.
		// Closing/destroying the dialog here can intermittently crash Warcraft 3.
		if udg_GameVoteArray[pid] > 0 then
			return
		endif

		// Close the dialog safely (next tick), instead of destroying frames during the click event.
		set closeRequested[pid] = true
		if not closeTimerRunning then
			set closeTimerRunning = true
			call TimerStart(closeTimer, 0.00, false, function CloseRequestedDialogs)
		endif

		call NeatMessage(GetPlayerName(whichPlayer) + " votes for: " + buttonName )
		if (buttonName == "Normal") then
			set udg_GameVoteArray[pid] = 1
		else
			set udg_GameVoteArray[pid] = 2
		endif

		// Defer to next tick to ensure we're out of the UI event handler.
		call TimerStart(CreateTimer(), 0.00, false, function CheckGameModeSelection)
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