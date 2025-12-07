library TestHeroSelection initializer Init requires HeroSelection, HeroSelectionConfig

	globals
		private integer loopInt = 4
		constant real HERO_SPAWN_X = FOREGROUND_HERO_X
		constant real HERO_SPAWN_Y = FOREGROUND_HERO_Y
		NeatWindow centerWindow
		unit array playerHero
		effect array circles
	endglobals
	
	private function MusicFadeOutLoop takes nothing returns nothing
		set loopInt = loopInt + 1
		if loopInt < 100 then
			call SetMusicVolumeBJ(100 - loopInt)
		else
			call DestroyTimer(GetExpiredTimer())
			call ClearMapMusic()
			call StopMusic(false)
			call SetMusicVolumeBJ(100)
		endif
	endfunction
	
	function MusicSlowFadeOut takes nothing returns nothing
		// call TimerStart(CreateTimer(), 0.05, true , function MusicFadeOutLoop)
		// set loopInt = 0
	endfunction
	
	function BeginGame takes nothing returns nothing
		// call DisplayTextToForce(GetPlayersAll(), "Let the battle begin!")
	endfunction
	
	private function PickBots takes nothing returns nothing
		if loopInt < 12 then
			call HeroSelectionPlayerForceRandom(Player(loopInt))
		else
			call DestroyTimer(GetExpiredTimer())
		endif
		set loopInt = loopInt + 1
	endfunction
	
	private function Enable takes nothing returns nothing
		// call EnableHeroSelection()
		call TimerStart(GetExpiredTimer(), 5.0, true , function PickBots)
	endfunction
	
	private function Start takes nothing returns nothing
		set centerWindow = NeatWindow.create(TEXT_MESSAGE_X_POSITION, 0.22, TEXT_MESSAGE_BLOCK_WIDTH, 0.2, 1, false)
		call InitHeroSelection()
		call BeginHeroSelection()
		// call Enable()
		// call TimerStart(GetExpiredTimer(), 1.0, false , function Enable)
	endfunction
	
	// private function Vendor takes nothing returns nothing
	// 	local integer i = 0
	// 	if GetItemTypeId(GetManipulatedItem()) == 'stwp' then
	// 		call PlayerReturnToHeroSelection(GetOwningPlayer(GetTriggerUnit()))
	// 		call RemoveUnit(GetTriggerUnit())
	// 	else
	// 		if NoOneInHeroSelection() then
	// 			loop
	// 				exitwhen i > 7
	// 				call RemoveUnit(playerHero[i])
	// 				set i = i + 1
	// 			endloop
	// 			call RestartHeroSelection()
	// 			call TimerStart(CreateTimer(), 2.0, false , function Enable)
	// 		else
	// 			call BJDebugMsg("Someone is in hero selection right now...")
	// 		endif
	// 	endif
	// endfunction
	
	private function Init takes nothing returns nothing
		local trigger trig = CreateTrigger()
		local integer i = 2
	
		call TimerStart( CreateTimer(), 0.01, false , function Start )
		// call FogEnableOff()
		// call FogMaskEnableOff()
		// call SetCameraBoundsToRectForPlayerBJ(GetPlayersAll(), gg_rct_HeroSelection)
		set i = 2
		loop
			exitwhen i > 10
			call FogModifierStart(CreateFogModifierRect(Player(i), FOG_OF_WAR_VISIBLE, gg_rct_HeroSelection, true, false))
			set i = i + 1
		endloop
		// call SetTimeOfDay(0)
		// call SetTimeOfDayScale(0)
		// call SetSkyModel("Starsphere.mdx")
		// call SetDoodadAnimationRect(GetPlayableMapRect(), 'D00O', "stand lumber", true)
	
		// call TriggerAddAction(trig,  function Vendor)
		// call TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_PICKUP_ITEM)
	endfunction
	
endlibrary