library HeroSelection requires HeroSelectionConfig, HeroDeclaration, SaveHelperLib, Ascii, optional NeatMessages

	globals
		private effect array selectedHeroGlow
		private effect array backgroundHeroGlow
		private destructable array backgroundHeroShadow
		private destructable foregroundHeroShadow = null
		private texttag array backgroundHeroTextTag

		private integer array preselectedHeroIndex
		private integer array pickedHeroIndex
		private integer localPlayerId												//asynchronous
		private boolean array heroIndexWasPicked
		private boolean array heroIndexWasBanned[1][24]
		private real localForegroundHeroX											//asynchronous
		private real localForegroundHeroY											//asynchronous
		private real localHeroSelectionAngle										//asynchronous
		private integer currentPage = 1				//asynchronous
	
		private framehandle captionFrame = null
		private framehandle timerFrame = null
		private framehandle heroSelectionMenu = null
		private framehandle array heroSelectionButton
		private framehandle array heroSelectionButtonIcon
		private framehandle heroSelectionButtonHighlight
		private framehandle array heroSelectionButtonIconClicked
		private framehandle array heroSelectionButtonTooltip
		private framehandle array heroSelectionButtonTooltipTitle
		private framehandle array heroSelectionButtonTooltipText
		private framehandle array heroSelectionAbility
		private framehandle array heroSelectionAbilityHover
		private framehandle array heroSelectionAbilityTooltip
		private framehandle array heroSelectionAbilityTooltipTitle
		private framehandle array heroSelectionAbilityTooltipText
		private framehandle array heroSelectionCategory
		private framehandle heroAcceptButton = null
		private framehandle heroBanButton = null
		private framehandle heroResetButton = null
		
		// Reset confirmation dialog
		private dialog array resetConfirmDialog
		private button array resetYesButton
		private button array resetNoButton
		private trigger resetDialogTrigger = CreateTrigger()
		
		private camerasetup heroSelectionCamera = CreateCameraSetup()
		private hashtable hash = InitHashtable()
		private timer lockCameraTimer = CreateTimer()
		private timer captionTimer = CreateTimer()
		private timer countdownTimer = CreateTimer()
		private timer countdownUpdateTimer = CreateTimer()
		private trigger heroSelectionButtonTrigger
		private trigger pageCycleTrigger
		
		private framehandle fullScreenFrame
		private framehandle fullScreenParent
		
		private boolean isForcedSelect = false
		private real captionAlphaMultiplier = 1
		
		private constant real TOOLTIP_BASE_HEIGHT = 0.032
		private real tooltipLeftXLocal
		
		private constant string HEX_STRING = "0123456789abcdef"
		private integer r1
		private integer r2
		private integer g1
		private integer g2
		private integer b1
		private integer b2

		private location moveableLoc = Location(0, 0)

		// Guard against intermittent "UI not ready yet" races.
		private timer enableHeroSelectionRetryTimer = CreateTimer()
		private integer enableHeroSelectionRetryAttempts = 0
		
		private integer storePlayerIndex
		private integer storeHeroIndex

		private real GARBAGE_DUMP_X
		private real GARBAGE_DUMP_Y
		
		private integer NUMBER_OF_CATEGORIES = 0
		private integer NUMBER_OF_PAGES = 1
		private integer NUMBER_OF_ABILITY_FRAMES = 0
		private integer NUMBER_OF_TEAMS = 0
		private integer RANDOM_HERO = 0
		private integer SUGGEST_RANDOM = 0
		private integer PAGE_DOWN = 0
		private integer PAGE_UP = 0

		// Region selection UI
		framehandle heroInfo
		private framehandle titleText
		private framehandle regionText
		private framehandle array g_categoryText[6]
		private framehandle array g_buttons[6]
		private framehandle array g_buttonsIcon[6]
		private framehandle array g_buttonsIconClicked[6]
		private string array REGION_NAMES[6]
		
		private framehandle array inventoryIconFrames[6]
		private framehandle array inventoryIconHover[6]
		private framehandle array inventoryTooltip[6]
		private framehandle array inventoryTooltipTitle[6]
		private framehandle array inventoryTooltipText[6]

	endglobals

	private function HeroSelectionUIReady takes nothing returns boolean
		return heroSelectionMenu != null and heroInfo != null and heroAcceptButton != null and heroBanButton != null and heroResetButton != null and timerFrame != null and captionFrame != null
	endfunction
	
	private function interface playerCallback takes player whichPlayer returns nothing
	private function interface playerHeroCallback takes player whichPlayer, Hero whichHero returns nothing
	private function interface onPickCallback takes player whichPlayer, Hero whichHero, boolean wasRandom, boolean wasRepick returns nothing
	private function interface playerHeroHeroCallback takes player whichPlayer, Hero oldHero, Hero newHero returns nothing
	private function interface noArgCallback takes nothing returns nothing

	struct Hero
		//Fields that must be set.
		//===================================
		integer array abilities[9]
		boolean array isNonHeroAbility[9]
		integer unitId
		string tooltip
		string selectEmote
		animtype selectAnim
		subanimtype selectSubAnim
		real selectAnimLength
		integer category
		boolean needsHeroGlow
		boolean unavailable
		boolean array unavailableToTeam[5]
		integer startingZone
		//===================================
		
		readonly string modelPath
		readonly integer index
		readonly string iconPath
		readonly real scalingValue
		readonly string name
		readonly integer red
		readonly integer green
		readonly integer blue

		readonly static integer numHeroes = 0
		readonly static Hero array list

		static method create takes nothing returns Hero
			local Hero this = Hero.allocate()
			set numHeroes = numHeroes + 1
			set.index = numHeroes
			set list[numHeroes] = this
			return this
		endmethod

		method GetValues takes nothing returns nothing
			local unit tempUnit
			local item tempItem

			set tempUnit = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE),.unitId, GARBAGE_DUMP_X, GARBAGE_DUMP_Y, 0 )
			set.name = GetUnitName(tempUnit)
			set.scalingValue = BlzGetUnitRealField(tempUnit, UNIT_RF_SCALING_VALUE )
			set.red = BlzGetUnitIntegerField(tempUnit, UNIT_IF_TINTING_COLOR_RED)
			set.green = BlzGetUnitIntegerField(tempUnit, UNIT_IF_TINTING_COLOR_GREEN)
			set.blue = BlzGetUnitIntegerField(tempUnit, UNIT_IF_TINTING_COLOR_BLUE)
			set.iconPath = BlzGetAbilityIcon(GetUnitTypeId(tempUnit))
			call RemoveUnit(tempUnit)
			set tempUnit = null

			set tempItem = CreateItem('afac', GARBAGE_DUMP_X, GARBAGE_DUMP_Y)
			call BlzSetItemSkin(tempItem,.unitId)
			set.modelPath = BlzGetItemStringField(tempItem, ITEM_SF_MODEL_USED)
			call RemoveItem(tempItem)
			set tempItem = null
		endmethod
	endstruct
	
	//==========================================================================================================================================================
	//Utility
	//==========================================================================================================================================================

	// Helper function to find the position of a substring in a string (returns -1 if not found)
	private function StringFind takes string haystack, string needle, integer start returns integer
		local integer hayLen = StringLength(haystack)
		local integer needleLen = StringLength(needle)
		local integer i = start
		loop
			exitwhen i > hayLen - needleLen
			if SubString(haystack, i, i + needleLen) == needle then
				return i
			endif
			set i = i + 1
		endloop
		return - 1
	endfunction

	private function GetTitle takes player p, integer slot returns string
		local integer saveNumber = SaveHelper.GetSavesPerSlot(p, slot)
		call Debug("saveNumber:" + I2S(saveNumber))

		return SaveFile(slot).getTitle(p, saveNumber)		
	endfunction

	private function GetItems takes player p, integer slot returns string
		local string s = SaveFile(slot).getItems(p, SaveHelper.GetSavesPerSlot(p, slot))
		if s == null then
			return ""
		else
			return s
		endif
	endfunction

	private function GetHeroTitle takes string s, integer slot returns string
		local integer parenPos = - 1
		
		if udg_GameMode == "PVP" then
			return "" + GetHeroProperNameFromSlot(slot) + "|n|cffffffff(lvl 25)|r"
		elseif(s == null or s == "") then
			return "" + GetHeroProperNameFromSlot(slot) + "|n|cff808080New Hero|r"
		else
			set parenPos = StringFind(s, "(", 0)
			if parenPos != - 1 then
				return GetHeroProperNameFromSlot(slot) + "|n|cffffffff" + SubString(s, parenPos, StringLength(s)) + "|r"
			endif
		endif
		return s
	endfunction

	private function InitFullScreenParents takes nothing returns nothing
		local framehandle board
		local integer localClientHeight = BlzGetLocalClientHeight()
		call CreateLeaderboardBJ(bj_FORCE_ALL_PLAYERS, "title")
		set board = BlzGetFrameByName("Leaderboard", 0)
		call BlzFrameSetSize(board, 0, 0)
		call BlzFrameSetVisible(BlzGetFrameByName("LeaderboardBackdrop", 0), false)
		call BlzFrameSetVisible(BlzGetFrameByName("LeaderboardTitle", 0), false)
		set fullScreenParent = BlzCreateFrameByType("FRAME", "fullScreenParent", board, "", 0)
		set fullScreenFrame = BlzCreateFrameByType("FRAME", "fullscreen", fullScreenParent, "", 0)
		call BlzFrameSetVisible(fullScreenFrame, false)
		if localClientHeight > 0 then
			call BlzFrameSetSize(fullScreenFrame, BlzGetLocalClientWidth() / I2R(localClientHeight) * 0.6, 0.6)
		else
			call BlzFrameSetSize(fullScreenFrame, 16.0 / 9.0 * 0.6, 0.6)
		endif
		call BlzFrameSetAbsPoint(fullScreenFrame, FRAMEPOINT_BOTTOM, 0.4, 0)
	endfunction

	private function CheckForCrash takes nothing returns nothing
		static if HERO_SELECTION_ENABLE_DEBUG_MODE then
			local timer crashTimer = GetExpiredTimer()
			local boolean didCrash = LoadBoolean(hash, GetHandleId(crashTimer), 0)
			local string functionName
			if didCrash then
				set functionName = LoadStr(hash, GetHandleId(crashTimer), 1)
				call BJDebugMsg("|cffff0000Warning:|r " + functionName + " function crashed...")
			endif
			call FlushChildHashtable(hash, GetHandleId(crashTimer))
			call DestroyTimer(crashTimer)
			set crashTimer = null
		endif
	endfunction

	private function InitCrashCheck takes string functionName returns nothing
		static if HERO_SELECTION_ENABLE_DEBUG_MODE then
			local timer crashTimer = CreateTimer()
			call TimerStart(crashTimer, 0.01, false, function CheckForCrash)
			call SaveBoolean(hash, GetHandleId(crashTimer), 0, true)
			call SaveStr(hash, GetHandleId(crashTimer), 1, functionName)
			call SaveTimerHandle(hash, StringHash(functionName), 0, crashTimer)
			set crashTimer = null
		endif
	endfunction

	private function NoCrash takes string functionName returns nothing
		static if HERO_SELECTION_ENABLE_DEBUG_MODE then
			local timer crashTimer = LoadTimerHandle(hash, StringHash(functionName), 0)
			call SaveBoolean(hash, GetHandleId(crashTimer), 0, false)
			set crashTimer = null
		endif
	endfunction

	private function GetClockString takes real rawSeconds returns string
		local integer seconds
		local integer minutes = R2I(rawSeconds) / 60
		local string clock
	
		set seconds = ModuloInteger(R2I(rawSeconds), 60)
		set clock = I2S(minutes) + ":"
		if seconds >= 10 then
			set clock = clock + I2S(seconds)
		else
			set clock = clock + "0" + I2S(seconds)
		endif
		return clock
	endfunction

	private function TimeExpires takes nothing returns nothing
		local noArgCallback onExpire = HeroSelectionOnExpire
		call ExecuteFunc("HeroSelectionForceEnd")
		call PauseTimer(countdownUpdateTimer)
		call BlzFrameSetText(timerFrame, TIMER_TEXT + GetClockString(0))
		call onExpire.evaluate()
	endfunction

	private function GetLocZ takes real x, real y returns real
		call MoveLocation(moveableLoc, x, y)
		return GetLocationZ(moveableLoc)
	endfunction

	private function TimerCounterPlus takes timer t returns integer
		local integer counter = LoadInteger(hash, GetHandleId(t), 0 )
		set counter = counter + 1
		call SaveInteger(hash, GetHandleId(t), 0, counter )
		return counter
	endfunction
	
	private function PlaySoundLocal takes string soundPath, boolean localPlayerCanHearSound returns nothing
		local real volume
		local sound s = CreateSound(soundPath, FALSE, FALSE, FALSE, 10, 10, "DefaultEAXON")
		call SetSoundChannel(s, 0)
		if localPlayerCanHearSound then
			set volume = 100
		else
			set volume = 0
		endif
		call SetSoundVolumeBJ(s, volume )
		call StartSound(s)
		call KillSoundWhenDone(s)
		set s = null
	endfunction

	private function GetPickedHeroDisplayedName takes integer heroIndex, boolean capitalize returns string
		local unit tempUnit
		local string name
		static if USE_HERO_PROPER_NAME then
			set tempUnit = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), Hero.list[heroIndex].unitId, GARBAGE_DUMP_X, GARBAGE_DUMP_Y, 0)
			set name = "|cffffcc00" + GetHeroProperName(tempUnit) + "|r"
			call RemoveUnit(tempUnit)
			set tempUnit = null
			return name
		else
			if capitalize then
				return "The |cffffcc00" + Hero.list[heroIndex].name + "|r"
			else
				return "the |cffffcc00" + Hero.list[heroIndex].name + "|r"
			endif
		endif
	endfunction

	//==========================================================================================================================================================
	//Region Selection
	//==========================================================================================================================================================

	private function SetRegionButtonFrames takes integer whichButton returns nothing
		// Retrieve the child frames of this button, which will be used for the textures.
		set g_buttonsIcon[whichButton] = BlzFrameGetChild(g_buttons[whichButton], 0)
		set g_buttonsIconClicked[whichButton] = BlzFrameGetChild(g_buttons[whichButton], 1)
		// Clear and set the points for the clicked icon so it fully covers the button.
		call BlzFrameClearAllPoints(g_buttonsIconClicked[whichButton])
		call BlzFrameSetPoint(g_buttonsIconClicked[whichButton], FRAMEPOINT_BOTTOMLEFT, g_buttons[whichButton], FRAMEPOINT_BOTTOMLEFT, 0.001, 0.001)
		call BlzFrameSetPoint(g_buttonsIconClicked[whichButton], FRAMEPOINT_TOPRIGHT, g_buttons[whichButton], FRAMEPOINT_TOPRIGHT, - 0.001, - 0.001)
	endfunction

	function SetRegionButtonTextures takes integer i, string iconPath returns nothing
		// Set the texture for the button icon.
		if i == 0 then 
			call BlzFrameSetTexture(g_buttonsIcon[i], "dun_morogh.blp", 0, true)
			call BlzFrameSetTexture(g_buttonsIconClicked[i], "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNGryphonAviary.blp", 0, true)
		elseif i == 1 then
			call BlzFrameSetTexture(g_buttonsIcon[i], "arathi.blp", 0, true)
			call BlzFrameSetTexture(g_buttonsIconClicked[i], "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNFarm.blp", 0, true)
		elseif i == 2 then
			call BlzFrameSetTexture(g_buttonsIcon[i], "teldrassil.blp", 0, true)
			call BlzFrameSetTexture(g_buttonsIconClicked[i], "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNTreeOfAges.blp", 0, true)
		elseif i == 3 then
			call BlzFrameSetTexture(g_buttonsIcon[i], "tirisfal.blp", 0, true)
			call BlzFrameSetTexture(g_buttonsIconClicked[i], "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNGraveyard.blp", 0, true)
		elseif i == 4 then
			call BlzFrameSetTexture(g_buttonsIcon[i], "eversong.blp", 0, true)
			call BlzFrameSetTexture(g_buttonsIconClicked[i], "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNElvenFarm.blp", 0, true)
		elseif i == 5 then
			call BlzFrameSetTexture(g_buttonsIcon[i], "echo_isles.blp", 0, true)
			call BlzFrameSetTexture(g_buttonsIconClicked[i], "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNVoodooLounge.blp", 0, true)
		endif
	endfunction

	function OnRegionButtonClicked takes nothing returns nothing
		local framehandle btn = BlzGetTriggerFrame()
		local player whichPlayer = GetTriggerPlayer()
		local integer P = GetPlayerId(whichPlayer)
		local integer i 
		local integer end

		call PlaySoundLocal("Sound\\Interface\\BigButtonClick.flac", GetPlayerId(GetLocalPlayer()) == P )
		
		// Find which button was clicked and update the selection.
		if IsAlliancePlayer(whichPlayer) then
			set i = 0
			set end = 2
		else
			set i = 3
			set end = 5
		endif
		loop
			exitwhen i >= end
			if btn == g_buttons[i] then
				call BlzFrameSetText(g_buttons[i], REGION_NAMES[i] + "|n(Selected)")
				set startingZoneOfPlayer[P] = i
			else
				call BlzFrameSetText(g_buttons[i], REGION_NAMES[i])
			endif
			set i = i + 1
		endloop
	endfunction

	//==========================================================================================================================================================
	//Hero Menu
	//==========================================================================================================================================================

	private function HeroCanBePicked takes integer heroIndex, integer P returns boolean
		return heroIndex != 0 and not((heroIndexWasPicked[heroIndex] and not HERO_CAN_BE_PICKED_MULTIPLE_TIMES) or Hero.list[heroIndex].unavailable or heroIndexWasBanned[heroIndex][P])
	endfunction

	private function GetHeroAbilityName takes integer id returns string
		local string tooltip = BlzGetAbilityTooltip(id, 0)
		local integer length = StringLength(tooltip)
		local integer delimLength = StringLength(HERO_ABILITY_LEVEL_DELIMITER)
		local integer i = 1
		local integer j

		if HERO_ABILITY_LEVEL_DELIMITER == null or HERO_ABILITY_LEVEL_DELIMITER == "" then
			return tooltip
		endif

		loop
			exitwhen i > length - delimLength
			set j = 0
			loop
				exitwhen SubString(tooltip, i + j, i + j + 1) != SubString(HERO_ABILITY_LEVEL_DELIMITER, j, j + 1)
				if j == delimLength - 1 then
					return SubString(tooltip, 0, i)
				endif
				set j = j + 1
			endloop
			set i = i + 1
		endloop
		return tooltip
	endfunction

	private function GetRandomHero takes integer currentSelection, integer P returns integer
		local integer array heroesAvailable
		local integer numChars = 0
		local integer i
		local boolean currentSelectionAvailable = false
		local integer currentSelectionChar
		
		set i = 1
		loop
			exitwhen i > NUMBER_OF_HEROES
			if HeroCanBePicked(i, P) and not Hero.list[i].unavailableToTeam[TEAM_OF_PLAYER[P]] then
				set numChars = numChars + 1
				set heroesAvailable[numChars] = i
				if currentSelection == i then
					set currentSelectionAvailable = true
					set currentSelectionChar = numChars
				endif
			endif
			set i = i + 1
		endloop
		if currentSelectionAvailable and currentSelection != 0 then
			//Return random hero not currently selected.
			return heroesAvailable[ModuloInteger(currentSelectionChar + GetRandomInt(0, numChars - 2), numChars) + 1]
		else
			return heroesAvailable[GetRandomInt(1, numChars)]
		endif
	endfunction

	private function SetButtonFrames takes integer whichButton returns nothing
		set heroSelectionButtonIcon[whichButton] = BlzFrameGetChild(heroSelectionButton[whichButton], 0)
		set heroSelectionButtonIconClicked[whichButton] = BlzFrameGetChild(heroSelectionButton[whichButton], 1)
		call BlzFrameClearAllPoints(heroSelectionButtonIconClicked[whichButton])
		call BlzFrameSetPoint(heroSelectionButtonIconClicked[whichButton], FRAMEPOINT_BOTTOMLEFT, heroSelectionButton[whichButton], FRAMEPOINT_BOTTOMLEFT, 0.001, 0.001)
		call BlzFrameSetPoint(heroSelectionButtonIconClicked[whichButton], FRAMEPOINT_TOPRIGHT, heroSelectionButton[whichButton], FRAMEPOINT_TOPRIGHT, - 0.001, - 0.001)
	endfunction

	private function SetButtonTooltip takes integer whichButton, string whichTitle, string whichTooltip returns nothing
		set heroSelectionButtonTooltip[whichButton] = BlzCreateFrame("CustomTooltip", heroSelectionButton[whichButton], 0, 0)
		if TOOLTIP_LOCK_TOP then
			call BlzFrameSetAbsPoint(heroSelectionButtonTooltip[whichButton], FRAMEPOINT_TOPLEFT, TOOLTIP_LEFT_X, TOOLTIP_Y )
		else
			call BlzFrameSetAbsPoint(heroSelectionButtonTooltip[whichButton], FRAMEPOINT_BOTTOMLEFT, TOOLTIP_LEFT_X, TOOLTIP_Y )
		endif
		call BlzFrameSetTooltip(heroSelectionButton[whichButton], heroSelectionButtonTooltip[whichButton] )
		
		set heroSelectionButtonTooltipTitle[whichButton] = BlzFrameGetChild(heroSelectionButtonTooltip[whichButton], 0)
		set heroSelectionButtonTooltipText[whichButton] = BlzFrameGetChild(heroSelectionButtonTooltip[whichButton], 1)
		
		call BlzFrameSetText(heroSelectionButtonTooltipTitle[whichButton], whichTitle )
		call BlzFrameSetText(heroSelectionButtonTooltipText[whichButton], whichTooltip )
		call BlzFrameSetSize(heroSelectionButtonTooltipText[whichButton], TOOLTIP_WIDTH - 0.01, 0.0 )
		call BlzFrameSetSize(heroSelectionButtonTooltip[whichButton], TOOLTIP_WIDTH, BlzFrameGetHeight(heroSelectionButtonTooltipText[whichButton]) + TOOLTIP_BASE_HEIGHT)
	endfunction

	private function SetInventoryTooltip takes integer whichButton, string whichTitle, string whichTooltip returns nothing
		set inventoryTooltip[whichButton] = BlzCreateFrame("CustomTooltip", inventoryIconHover[whichButton], 0, 0)
		if TOOLTIP_LOCK_TOP then
			call BlzFrameSetAbsPoint(inventoryTooltip[whichButton], FRAMEPOINT_TOPLEFT, TOOLTIP_LEFT_X, TOOLTIP_Y )
		else
			call BlzFrameSetAbsPoint(inventoryTooltip[whichButton], FRAMEPOINT_BOTTOMLEFT, TOOLTIP_LEFT_X, TOOLTIP_Y )
		endif
		call BlzFrameSetTooltip(inventoryIconHover[whichButton], inventoryTooltip[whichButton] )
		
		set inventoryTooltipTitle[whichButton] = BlzFrameGetChild(inventoryTooltip[whichButton], 0)
		set inventoryTooltipText[whichButton] = BlzFrameGetChild(inventoryTooltip[whichButton], 1)
		
		call BlzFrameSetText(inventoryTooltipTitle[whichButton], whichTitle )
		call BlzFrameSetText(inventoryTooltipText[whichButton], whichTooltip )
		call BlzFrameSetSize(inventoryTooltipText[whichButton], TOOLTIP_WIDTH - 0.01, 0.0 )
		call BlzFrameSetSize(inventoryTooltip[whichButton], TOOLTIP_WIDTH, BlzFrameGetHeight(inventoryTooltipText[whichButton]) + TOOLTIP_BASE_HEIGHT)
	endfunction
	
	private function SetInventoryTooltipText takes player p, integer whichButton, string whichTitle, string whichTooltip returns nothing
		if GetLocalPlayer() == p then
			call BlzFrameSetText(inventoryTooltipTitle[whichButton], whichTitle )
			call BlzFrameSetText(inventoryTooltipText[whichButton], whichTooltip )
			call BlzFrameSetSize(inventoryTooltipText[whichButton], TOOLTIP_WIDTH - 0.01, 0.0 )
			call BlzFrameSetSize(inventoryTooltip[whichButton], TOOLTIP_WIDTH, BlzFrameGetHeight(inventoryTooltipText[whichButton]) + TOOLTIP_BASE_HEIGHT)
		endif
	endfunction

	private function UpdateInventoryTooltips takes player whichPlayer, string items returns nothing
		local integer i = 0
		local integer itemTypeId
		local string itemName
		local string itemTooltip
		
		loop
			exitwhen i > 5
			if StringLength(items) >= (i * 5 + 5) and SubString(items, i * 5, i * 5 + 1) != "-" then
				set itemTypeId = S2A(SubString(items, i * 5, i * 5 + 4))
				set itemName = GetObjectName(itemTypeId)
				set itemTooltip = BlzGetAbilityExtendedTooltip(itemTypeId, 0)
				
				// If tooltip is empty, create a basic one
				if itemTooltip == null or itemTooltip == "" then
					set itemTooltip = "This is a " + itemName + "."
				endif
				
				call SetInventoryTooltipText(whichPlayer, i, itemName, itemTooltip)
			else
				call SetInventoryTooltipText(whichPlayer, i, "Empty Slot", "No item equipped in this slot.")
			endif
			set i = i + 1
		endloop
	endfunction
	
	private function SetButtonTextures takes integer whichButton, boolean disabledTexture returns nothing
		local integer i
		local integer stringLength
		local string disabledPath
		local string path

		if whichButton <= NUMBER_OF_HEROES then
			set path = Hero.list[whichButton].iconPath
		elseif whichButton == RANDOM_HERO then
			set path = RANDOM_HERO_ICON
		elseif whichButton == SUGGEST_RANDOM then
			set path = SUGGEST_RANDOM_ICON
		elseif whichButton == PAGE_DOWN then
			set path = MENU_PAGE_DOWN_ICON
		else
			set path = MENU_PAGE_UP_ICON
		endif

		if not disabledTexture then
			call BlzFrameSetTexture(heroSelectionButtonIcon[whichButton], path, 0, true)
			call BlzFrameSetTexture(heroSelectionButtonIconClicked[whichButton], path, 0, true)
		else
			set stringLength = StringLength(path)
			set i = 0
			loop
				exitwhen i > stringLength - 3
				if SubString(path, i, i + 1) == "B" and SubString(path, i + 1, i + 2) == "T" and SubString(path, i + 2, i + 3) == "N" then
					set disabledPath = "ReplaceableTextures\\CommandButtonsDisabled\\DISBTN" + SubString(path, i + 3, stringLength)
					call BlzFrameSetTexture(heroSelectionButtonIcon[whichButton], disabledPath, 0, true)
					call BlzFrameSetTexture(heroSelectionButtonIconClicked[whichButton], disabledPath, 0, true)
					return
				endif
				set i = i + 1
			endloop
		endif
	endfunction

	//==========================================================================================================================================================
	//Caption
	//==========================================================================================================================================================
	
	private function TextColor takes nothing returns nothing
		local integer counter = TimerCounterPlus(GetExpiredTimer())
		local real colorState =(1 + Cos(2 * bj_PI * counter / (CAPTION_CYCLE_TIME / 0.02))) / 2
		local integer r = R2I((1 - colorState) * r1 + colorState * r2)
		local integer g = R2I((1 - colorState) * g1 + colorState * g2)
		local integer b = R2I((1 - colorState) * b1 + colorState * b2)
		local integer array c
		local integer i
		local string colorString = "|cff"

		set c[1] = r / 16
		set c[2] = r - 16 * c[1]
		set c[3] = g / 16
		set c[4] = g - 16 * c[3]
		set c[5] = b / 16
		set c[6] = b - 16 * c[5]

		set i = 1
		loop
			exitwhen i > 6
			set colorString = colorString + SubString(HEX_STRING, c[i], c[i] + 1)
			set i = i + 1
		endloop

		if CAPTION_FADEOUT_TIME != - 1 then
			if playerHasHero[localPlayerId] then
				if CAPTION_FADEOUT_TIME > 0 then
					set captionAlphaMultiplier = RMaxBJ(0, captionAlphaMultiplier - 1 / (50 * CAPTION_FADEOUT_TIME))
				else
					set captionAlphaMultiplier = 0
				endif
			endif
		endif

		call BlzFrameSetText(captionFrame, colorString + HERO_SELECTION_CAPTION + "|r")
		call BlzFrameSetAlpha(captionFrame, R2I(captionAlphaMultiplier * ((1 - colorState) * CAPTION_ALPHA_1 + colorState * CAPTION_ALPHA_2)))
	endfunction

	private function HexToInt takes string hexString returns integer
		local integer i = 0
		local integer int = 0
		local string firstChar = StringCase(SubString(hexString, 0, 1), false)
		local string secondChar = StringCase(SubString(hexString, 1, 2), false)
		local boolean firstCharFound = false
		local boolean secondCharFound = false

		set i = 0
		loop
			exitwhen i > 15 or(firstCharFound and secondCharFound)
			if not firstCharFound and firstChar == SubString(HEX_STRING, i, i + 1) then
				set int = int + 16 * i
				set firstCharFound = true
			endif
			if not secondCharFound and secondChar == SubString(HEX_STRING, i, i + 1) then
				set int = int + i
				set secondCharFound = true
			endif
			set i = i + 1
		endloop

		return int
	endfunction
	
	private function AnimateCaption takes nothing returns nothing
		local integer i
		local string s
		local integer j

		//Get RGB values of CAPTION_COLOR_1 and CAPTION_COLO_2.
		set r1 = HexToInt(SubString(CAPTION_COLOR_1, 4, 6))
		set g1 = HexToInt(SubString(CAPTION_COLOR_1, 6, 8))
		set b1 = HexToInt(SubString(CAPTION_COLOR_1, 8, 10))
		set r2 = HexToInt(SubString(CAPTION_COLOR_2, 4, 6))
		set g2 = HexToInt(SubString(CAPTION_COLOR_2, 6, 8))
		set b2 = HexToInt(SubString(CAPTION_COLOR_2, 8, 10))

		call TimerStart(captionTimer, 0.02, true, function TextColor )
		call SaveInteger(hash, GetHandleId(captionTimer), 0, 0 )
	endfunction
	
	//==========================================================================================================================================================
	//Hero Effects
	//==========================================================================================================================================================

	private function FadeInBackgroundHero takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local integer counter = TimerCounterPlus(t)
		local integer P = LoadInteger(hash, GetHandleId(t), 1 )
		local boolean concealed = LoadBoolean(hash, GetHandleId(t), 2 )
		local Hero whichHero = Hero.list[pickedHeroIndex[P]]

		//Hero for owner fades in later than for other players since it's still in the front.
		local integer ownerDelay = R2I(50 * (FOREGROUND_HERO_FADEOUT_DELAY + FOREGROUND_HERO_FADEOUT_TIME) / BACKGROUND_HERO_FADEIN_TIME)
		local string modelPath
		
		if localPlayerId != P and counter <= 51 then
			if concealed then
				call BlzSetSpecialEffectAlpha(backgroundHero[P], R2I(2.5 * counter) )
				if whichHero.needsHeroGlow then
					call BlzSetSpecialEffectAlpha(backgroundHeroGlow[P], R2I(2.5 * counter) )
				endif
			else
				call BlzSetSpecialEffectAlpha(backgroundHero[P], 5 * counter )
				if whichHero.needsHeroGlow then
					call BlzSetSpecialEffectAlpha(backgroundHeroGlow[P], 5 * counter )
				endif
			endif
		elseif localPlayerId == P and counter > ownerDelay then
			call BlzSetSpecialEffectAlpha(backgroundHero[P], 5 * (counter - ownerDelay))
			if whichHero.needsHeroGlow then
				call BlzSetSpecialEffectAlpha(backgroundHeroGlow[P], 5 * (counter - ownerDelay))
			endif
		endif

		static if CREATE_SHADOWS then
			if counter == ownerDelay then
				call RemoveDestructable(backgroundHeroShadow[P])
				set backgroundHeroShadow[P] = CreateDestructable(SHADOW_DESTRUCTABLE_ID, BACKGROUND_HERO_X[P], BACKGROUND_HERO_Y[P], 0, 1, 0)
			endif
		endif
		
		if counter == 51 + ownerDelay then
			if BACKGROUND_HERO_SELF_HIGHLIGHT != null then
				if localPlayerId == P then
					set modelPath = BACKGROUND_HERO_SELF_HIGHLIGHT
				else
					set modelPath = ""
				endif
				set backgroundHeroHighlight[P] = AddSpecialEffect(modelPath, BACKGROUND_HERO_X[P], BACKGROUND_HERO_Y[P])
				call BlzSetSpecialEffectZ(backgroundHeroHighlight[P], GetLocZ(BACKGROUND_HERO_X[P], BACKGROUND_HERO_Y[P]) + BACKGROUND_HERO_HIGHLIGHT_Z)
			endif
			call FlushChildHashtable(hash, GetHandleId(t) )
			call DestroyTimer(t)
		endif
		set t = null
	endfunction
	
	private function FadeoutForegroundHero takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local integer counter = TimerCounterPlus(t)
		local integer P = LoadInteger(hash, GetHandleId(t), 1 )
	
		if counter < 51 and FOREGROUND_HERO_FADEOUT_TIME > 0 then
			call BlzSetSpecialEffectAlpha(selectedHero[P], 255 - 5 * counter )
			call BlzSetSpecialEffectAlpha(selectedHeroGlow[P], 255 - 5 * counter )
			call TimerStart(t, FOREGROUND_HERO_FADEOUT_TIME / 50.0, false, function FadeoutForegroundHero )
		else
			call BlzSetSpecialEffectPosition(selectedHero[P], GARBAGE_DUMP_X, GARBAGE_DUMP_Y, 0 )
			call DestroyEffect(selectedHero[P] )
			call DestroyEffect(selectedHeroGlow[P] )
			call FlushChildHashtable(hash, GetHandleId(t) )
			call DestroyTimer(t)
		endif
		set t = null
	endfunction

	private function ResetAnimation takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local integer id = GetHandleId(t)
		local integer P = LoadInteger(hash, id, 0 )
		local integer heroIndex = LoadInteger(hash, id, 1 )
		local boolean animateBackgroundHero = LoadBoolean(hash, id, 2)
	
		if animateBackgroundHero then
			if localPlayerId != P then
				call BlzSpecialEffectClearSubAnimations(backgroundHero[P])
				call BlzPlaySpecialEffect(backgroundHero[P], ANIM_TYPE_STAND )
			endif
		else
			if preselectedHeroIndex[P] == heroIndex then
				call BlzSpecialEffectClearSubAnimations(selectedHero[P])
				call BlzPlaySpecialEffect(selectedHero[P], ANIM_TYPE_STAND )
			endif
		endif
	
		call FlushChildHashtable(hash, GetHandleId(t) )
		call DestroyTimer(t)
		set t = null
	endfunction

	private function PlayHeroAnimation takes integer P, integer heroIndex, boolean animateBackgroundHero returns nothing
		local timer t = CreateTimer()
		local integer id = GetHandleId(t)
		if animateBackgroundHero then
			if localPlayerId != P and(not CONCEAL_HERO_PICKS_FROM_ENEMIES or(TEAM_OF_PLAYER[localPlayerId] == TEAM_OF_PLAYER[P] and TEAM_OF_PLAYER[P] != 0)) then
				call BlzSpecialEffectAddSubAnimation(backgroundHero[P], Hero.list[heroIndex].selectSubAnim )
				call BlzPlaySpecialEffect(backgroundHero[P], Hero.list[heroIndex].selectAnim )
			endif
		else
			call BlzSpecialEffectAddSubAnimation(selectedHero[P], Hero.list[heroIndex].selectSubAnim )
			call BlzPlaySpecialEffect(selectedHero[P], Hero.list[heroIndex].selectAnim )
		endif

		call TimerStart(t, Hero.list[heroIndex].selectAnimLength, false, function ResetAnimation )
		call SaveInteger(hash, id, 0, P )
		call SaveInteger(hash, id, 1, heroIndex )
		call SaveBoolean(hash, id, 2, animateBackgroundHero)
		set t = null
	endfunction

	private function CreateNewForegroundHero takes integer P, integer heroIndex returns nothing
		local string modelPath = ""
		local string glowPath = ""
		local real locZ
		local Hero whichHero = Hero.list[heroIndex]

		if localPlayerId == P then
			if heroIndex == RANDOM_HERO then
				set modelPath = "Objects\\InventoryItems\\QuestionMark\\QuestionMark.mdl"
			else
				set modelPath = whichHero.modelPath
			endif
			if whichHero.needsHeroGlow then
				set glowPath = "HeroGlow.mdx"
			endif
		endif

		call BlzSetSpecialEffectPosition(selectedHero[P], GARBAGE_DUMP_X, GARBAGE_DUMP_Y, 0 )
		call BlzSetSpecialEffectTimeScale(selectedHero[P], 9999)
		call BlzSetSpecialEffectScale(selectedHero[P], 0)
		call DestroyEffect(selectedHero[P])
		call DestroyEffect(selectedHeroGlow[P])
		set selectedHero[P] = AddSpecialEffect(modelPath, localForegroundHeroX, localForegroundHeroY )
		set selectedHeroGlow[P] = AddSpecialEffect(glowPath, localForegroundHeroX, localForegroundHeroY )
		set locZ = GetLocZ(localForegroundHeroX, localForegroundHeroY)
		call BlzSetSpecialEffectZ(selectedHero[P], locZ + FOREGROUND_HERO_Z )
		call BlzSetSpecialEffectZ(selectedHeroGlow[P], locZ + FOREGROUND_HERO_Z )
		call BlzSetSpecialEffectYaw(selectedHero[P], Deg2Rad(localHeroSelectionAngle) + bj_PI )
		call BlzSetSpecialEffectColorByPlayer(selectedHero[P], Player(P) )
		call BlzSetSpecialEffectColorByPlayer(selectedHeroGlow[P], Player(P) )
		if heroIndex != RANDOM_HERO then
			call BlzSetSpecialEffectScale(selectedHero[P], whichHero.scalingValue )
		endif
		if PHANTOM_HERO_WHEN_CANNOT_BE_PICKED and(heroSelectionDisabledForPlayer[P] or not HeroCanBePicked(heroIndex, P)) then
			call BlzSetSpecialEffectColor(selectedHero[P], 0, 0, 0 )
			call BlzSetSpecialEffectAlpha(selectedHero[P], 128 )
		else
			call BlzSetSpecialEffectColor(selectedHero[P], whichHero.red, whichHero.green, whichHero.blue)
		endif
	endfunction

	private function DeleteBackgroundHero takes integer P returns nothing
		call BlzSetSpecialEffectPosition(backgroundHero[P], GARBAGE_DUMP_X, GARBAGE_DUMP_Y, 0)
		call DestroyEffect(backgroundHero[P])
		call DestroyEffect(backgroundHeroGlow[P])
		call DestroyEffect(backgroundHeroHighlight[P])
		static if CREATE_SHADOWS then
			call RemoveDestructable(backgroundHeroShadow[P])
		endif
		static if PLAYER_TEXT_TAGS then
			call DestroyTextTag(backgroundHeroTextTag[P])
		endif
	endfunction

	//==========================================================================================================================================================
	//Miscellaneous.
	//==========================================================================================================================================================

	private function UpdateTimerFrame takes nothing returns nothing
		if inBanPhase then
			call BlzFrameSetText(timerFrame, TIMER_BAN_PHASE_TEXT + GetClockString(TimerGetRemaining(countdownTimer)))
		else
			call BlzFrameSetText(timerFrame, TIMER_TEXT + GetClockString(TimerGetRemaining(countdownTimer)))
		endif
	endfunction
	
	private function LockSelecterCamera takes nothing returns nothing
		local integer i = 1
	
		loop
			exitwhen i > numSelectingPlayers
			if isInHeroSelection[playerNumberOfSlot[i]] then
				call CameraSetupApplyForPlayer(true, heroSelectionCamera, Player(playerNumberOfSlot[i]), 0 )
			endif
			set i = i + 1
		endloop
	endfunction

	//==========================================================================================================================================================
	//End hero selection.
	//==========================================================================================================================================================

	private function EscapePlayer takes player whichPlayer returns nothing
		local integer P = GetPlayerId(whichPlayer)
		local playerCallback onEscape = HeroSelectionOnEscape
		local framehandle consoleUIBackdrop = BlzGetFrameByName("ConsoleUIBackdrop", 0)
		local framehandle bottomUI = BlzGetFrameByName("ConsoleBottomBar", 0)
		local framehandle topUI = BlzGetFrameByName("ConsoleTopBar", 0)

		if not isInHeroSelection[P] then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Attempted to escape player who is not in hero selection...")
			endif
			return
		endif

		call InitCrashCheck("EscapePlayer")

		set isInHeroSelection[P] = false
		set preselectedHeroIndex[P] = 0
		set isRepicking[P] = false
		set playerHasBan[P] = false
		set numPlayersInSelection = numPlayersInSelection - 1
		call DestroyEffect(selectedHero[P])
		call ResetToGameCameraForPlayer(whichPlayer, 0)

		if localPlayerId == P then
			call BlzFrameSetVisible(heroSelectionMenu, false)
			call BlzFrameSetVisible(heroInfo, false)
			call BlzFrameSetVisible(captionFrame, false)
			call BlzFrameSetVisible(timerFrame, false)
			static if HIDE_GAME_UI then
				call BlzHideOriginFrames(false)
				call BlzFrameSetVisible(consoleUIBackdrop, true)
				call BlzFrameSetVisible(bottomUI, true)
				call BlzFrameSetVisible(topUI, true)
			endif
		endif

		// if not isLoad then
		call onEscape.evaluate(whichPlayer)
		// endif

		set isFadingOut[P] = false

		call NoCrash("EscapePlayer")
	endfunction

	// function EscapePlayer takes player whichPlayer returns nothing
	// 	call EscapePlayerWithLoad(whichPlayer, false)
	// endfunction
	
	private function EndHeroSelection takes nothing returns nothing
		local integer i = 1
		local integer P
		local noArgCallback onFinal = HeroSelectionOnFinal

		call InitCrashCheck("EndHeroSelection")
	
		call PauseTimer(lockCameraTimer)
		call PauseTimer(countdownTimer)
		call PauseTimer(countdownUpdateTimer)

		static if not ESCAPE_PLAYER_AFTER_SELECTING then
			loop
				exitwhen i > numSelectingPlayers
				set P = playerNumberOfSlot[i]
				call EscapePlayer(Player(P))
				set i = i + 1
			endloop
		endif

		set i = 1
		loop
			exitwhen i > numSelectingPlayers
			set P = playerNumberOfSlot[i]
			call BlzSetSpecialEffectPosition(selectedHero[P], GARBAGE_DUMP_X, GARBAGE_DUMP_Y, 0)
			call DestroyEffect(selectedHero[P])
			call DestroyEffect(selectedHeroGlow[P])
			static if DELETE_BACKGROUND_HEROES_AFTER_END then
				call BlzSetSpecialEffectPosition(backgroundHero[P], GARBAGE_DUMP_X, GARBAGE_DUMP_Y, 0)
				call DeleteBackgroundHero(P)
			endif
			set i = i + 1
		endloop

		static if CREATE_SHADOWS then
			call RemoveDestructable(foregroundHeroShadow)
		endif

		call onFinal.evaluate()

		call NoCrash("EndHeroSelection")
	endfunction

	private function EscapePlayerCaller takes nothing returns nothing
		local timer t = GetExpiredTimer()
		call EscapePlayer(Player(LoadInteger(hash, GetHandleId(t), 0)))
		call FlushChildHashtable(hash, GetHandleId(t))
		call DestroyTimer(t)
		set t = null

		static if ESCAPE_PLAYER_AFTER_SELECTING then
			if numPlayersInSelection == 0 then
				call EndHeroSelection()
			endif
		endif
	endfunction

	private function EndHeroSelectionCaller takes nothing returns nothing
		local timer t = GetExpiredTimer()
		call EndHeroSelection()
		call DestroyTimer(t)
		set t = null
	endfunction

	private function OnPlayerLeave takes nothing returns nothing
		local player whichPlayer = GetTriggerPlayer()
		local integer P = GetPlayerId(whichPlayer)
		local integer i = 1
		local integer j = 1
		local playerCallback onLeave = HeroSelectionOnLeave

		call InitCrashCheck("OnPlayerLeave")

		loop
			exitwhen i > numSelectingPlayers
			if P == playerNumberOfSlot[i] then
				set j = i
				loop
					exitwhen j > numSelectingPlayers - 1
					set playerNumberOfSlot[j] = playerNumberOfSlot[j + 1]
					set j = j + 1
				endloop
				exitwhen true
			endif
			set i = i + 1
		endloop
		set numSelectingPlayers = numSelectingPlayers - 1
		if isInHeroSelection[P] then
			call onLeave.evaluate(whichPlayer)
			set numPlayersInSelection = numPlayersInSelection - 1
			set isInHeroSelection[P] = false
		endif
		if playerHasHero[P] then
			set numPlayersWithHero = numPlayersWithHero - 1
			set playerHasHero[P] = false
			call BlzSetSpecialEffectPosition(selectedHero[P], GARBAGE_DUMP_X, GARBAGE_DUMP_Y, 0)
			call DestroyEffect(selectedHero[P])
			call DestroyEffect(selectedHeroGlow[P])
			call DestroyEffect(selectedHeroGlow[P])
			call BlzSetSpecialEffectPosition(backgroundHero[P], GARBAGE_DUMP_X, GARBAGE_DUMP_Y, 0)
			call DeleteBackgroundHero(P)
		elseif numPlayersWithHero == numSelectingPlayers and not isRepicking[P] then
			call TimerStart(CreateTimer(), LAST_PLAYER_SELECT_END_DELAY, false, function EndHeroSelectionCaller )
		endif
	
		call NoCrash("OnPlayerLeave")
	endfunction

	//==========================================================================================================================================================
	//Cycle Page.
	//==========================================================================================================================================================

	private function DisplayNewPage takes integer P returns nothing
		local integer i
		call BlzFrameSetVisible(heroSelectionButtonHighlight, PAGE_OF_CATEGORY[Hero.list[preselectedHeroIndex[P]].category] == currentPage)

		set i = 1
		loop
			exitwhen i > NUMBER_OF_CATEGORIES
			call BlzFrameSetVisible(heroSelectionCategory[i], PAGE_OF_CATEGORY[i] == currentPage)
			set i = i + 1
		endloop

		set i = 1
		loop
			exitwhen i > NUMBER_OF_HEROES
			// call BlzFrameSetVisible(heroSelectionButton[i], PAGE_OF_CATEGORY[Hero.list[i].category] == currentPage)
			call BlzFrameSetVisible(heroSelectionButton[i], PAGE_OF_CATEGORY[Hero.list[i].category] == currentPage and not Hero.list[i].unavailableToTeam[TEAM_OF_PLAYER[localPlayerId]])
			set i = i + 1
		endloop
	endfunction

	private function CyclePage takes nothing returns nothing
		local player whichPlayer = GetTriggerPlayer()
		local integer P = GetPlayerId(whichPlayer)
		local integer i

		call PlaySoundLocal("Sound\\Interface\\BigButtonClick.flac", localPlayerId == P )

		if localPlayerId == P then
			if BlzGetTriggerFrame() == heroSelectionButton[PAGE_DOWN] then
				set currentPage = ModuloInteger(currentPage - 2, NUMBER_OF_PAGES) + 1
			else
				set currentPage = ModuloInteger(currentPage, NUMBER_OF_PAGES) + 1
			endif
			call DisplayNewPage(P)
		endif
	endfunction
	
	//==========================================================================================================================================================
	//Ban Hero.
	//==========================================================================================================================================================

	// private function ExecuteBan takes Hero whichHero, boolean disable, integer whichPlayer returns nothing
	// 	local integer i
	// 	local integer P
	// 	if disable then
	// 		call BlzFrameSetText(heroSelectionButtonTooltipText[whichHero.index], whichHero.tooltip + "|n|n|cffff0000This hero was banned.|r")
	// 	else
	// 		call BlzFrameSetText(heroSelectionButtonTooltipText[whichHero.index], whichHero.tooltip)
	// 	endif
	// 	call BlzFrameSetSize(heroSelectionButtonTooltipText[whichHero.index], TOOLTIP_WIDTH - 0.01, 0.0 )
	// 	call BlzFrameSetSize(heroSelectionButtonTooltip[whichHero.index], TOOLTIP_WIDTH, BlzFrameGetHeight(heroSelectionButtonTooltipText[whichHero.index]) + TOOLTIP_BASE_HEIGHT)

	// 	set i = 1
	// 	loop
	// 		exitwhen i > numSelectingPlayers
	// 		set P = playerNumberOfSlot[i]
	// 		if P == whichPlayer or whichPlayer == - 1 then
	// 			set heroIndexWasBanned[whichHero.index][P] = true
	// 			if localPlayerId == P then
	// 				call SetButtonTextures(whichHero.index, not HeroCanBePicked(whichHero.index, P))
	// 				if preselectedHeroIndex[P] == whichHero then
	// 					call BlzFrameSetEnable(heroAcceptButton, false )
	// 					call BlzFrameSetEnable(heroBanButton, false )
	// 					static if PHANTOM_HERO_WHEN_CANNOT_BE_PICKED then
	// 						call BlzSetSpecialEffectAlpha(selectedHero[P], 128)
	// 						call BlzSetSpecialEffectColor(selectedHero[P], 0, 0, 0)
	// 					endif
	// 				endif
	// 			endif
	// 		endif
	// 		set i = i + 1
	// 	endloop
	// endfunction

	// private function BanHero takes nothing returns nothing
	// 	local string message
	// 	local player whichPlayer = GetTriggerPlayer()
	// 	local integer P = GetPlayerId(whichPlayer)
	// 	local integer heroIndex = preselectedHeroIndex[P]

	// 	call InitCrashCheck("BanHero")

	// 	if localPlayerId == P then
	// 		call BlzFrameSetEnable(heroBanButton, false)
	// 	endif
	// 	set playerHasBan[P] = false
		
	// 	set message = GetPickedHeroDisplayedName(heroIndex, true) + " was banned."

	// 	static if LIBRARY_NeatMessages then
	// 		call NeatMessage(message)
	// 	else
	// 		call DisplayTextToPlayer(GetLocalPlayer(), TEXT_MESSAGE_X_OFFSET, TEXT_MESSAGE_Y_OFFSET, message)
	// 	endif
	// 	if OTHER_PLAYER_HERO_PICK_SOUND != null then
	// 		call PlaySoundLocal(OTHER_PLAYER_HERO_PICK_SOUND, true)
	// 	endif

	// 	call ExecuteBan(Hero.list[heroIndex], true, - 1)

	// 	call NoCrash("BanHero")
	// endfunction

	//==========================================================================================================================================================
	//Reset Hero Confirmation Dialog.
	//==========================================================================================================================================================
	
	private function ExecuteResetHero takes player whichPlayer returns nothing
		local integer heroIndex = preselectedHeroIndex[GetPlayerId(whichPlayer)]
		local integer pid = GetPlayerId(whichPlayer)
		local string s
		local integer i
		local integer end
		local string defualtSelectionText = ""

		call DeleteCharSlot(whichPlayer, GetSlotForHeroUnitID(Hero.list[heroIndex].unitId))
		set s = GetTitle(whichPlayer, GetSlotForHeroUnitID(Hero.list[heroIndex].unitId))
		
		// Set starting zone for all players (moved outside GetLocalPlayer to prevent desync)
		set startingZoneOfPlayer[pid] = Hero.list[heroIndex].startingZone
		
		if whichPlayer == GetLocalPlayer() then
			call BlzFrameSetText(titleText, "|cffffcc00" + GetHeroTitle(s, GetSlotForHeroUnitID(Hero.list[heroIndex].unitId)) + "|r")
			call BlzFrameSetText(regionText, "|cffffcc00Starting Zone|r")
			if IsAlliancePlayer(whichPlayer) then
				set i = 0
				set end = 1
			else
				set i = 3
				set end = 4
			endif
			loop
				exitwhen i > end
				if i == Hero.list[heroIndex].startingZone then
					set defualtSelectionText = "|n(Default)"
				else
					set defualtSelectionText = ""
				endif
				call BlzFrameSetText(g_buttons[i], REGION_NAMES[i] + defualtSelectionText)
				call BlzFrameSetVisible(g_buttons[i], true)
				set i = i + 1
			endloop

			// Hide Inventory Icons
			set i = 0
			loop
				exitwhen i > 5
				call BlzFrameSetVisible(inventoryIconFrames[i], false)
				// Reset inventory tooltips to empty slots
				call SetInventoryTooltipText(whichPlayer, i, "Empty Slot", "No item equipped in this slot.")
				set i = i + 1
			endloop
			call BlzFrameSetVisible(heroResetButton, false)
		endif
	endfunction
	
	private function OnResetDialogButtonClick takes nothing returns nothing
		local button b = GetClickedButton()
		local player p = GetTriggerPlayer()
		local integer pid = GetPlayerId(p)
		
		if b == resetYesButton[pid] then
			// Player confirmed reset - proceed with the actual reset
			call ExecuteResetHero(p)
		endif
		
		// Hide the dialog for the local player
		if GetLocalPlayer() == p then
			call DialogDisplay(p, resetConfirmDialog[pid], false)
		endif
	endfunction
	
	private function ShowResetConfirmation takes player whichPlayer returns nothing
		local integer pid = GetPlayerId(whichPlayer)
		
		call DialogClear(resetConfirmDialog[pid])
		call DialogSetMessage(resetConfirmDialog[pid], "|cffff8000Reset to Lvl 1?|r")
		set resetYesButton[pid] = DialogAddButton(resetConfirmDialog[pid], "|cffffffffY|r|cffffcc00es|r", 89)
		set resetNoButton[pid] = DialogAddButton(resetConfirmDialog[pid], "|cffffffffN|r|cffffcc00o|r", 78)
		
		if GetLocalPlayer() == whichPlayer then
			call DialogDisplay(whichPlayer, resetConfirmDialog[pid], true)
		endif
	endfunction

	//==========================================================================================================================================================
	//Reset Hero.
	//==========================================================================================================================================================
	private function ResetHero takes nothing returns nothing
		local player whichPlayer = GetTriggerPlayer()

		call ShowResetConfirmation(whichPlayer)

		set whichPlayer = null
	endfunction

	//==========================================================================================================================================================
	//Pick Hero.
	//==========================================================================================================================================================
	
	private function PickHero takes nothing returns nothing
		local integer i
		local integer P
		local integer Q
		local string message
		local player whichPlayer
		local integer heroIndex
		local timer t
		local string modelPath
		local boolean wasRandomSelect
		local boolean concealed
		local integer id
		local boolean allHumanPlayersHaveHeroes
		local effect pickEffect
		local noArgCallback onLast = HeroSelectionOnLast
		local onPickCallback onPick = HeroSelectionOnPick

		call InitCrashCheck("PickHero")
		
		if not isForcedSelect then
			set whichPlayer = GetTriggerPlayer()
			set P = GetPlayerId(whichPlayer)
			set heroIndex = preselectedHeroIndex[P]
		else
			set P = storePlayerIndex
			set whichPlayer = Player(P)
			set heroIndex = storeHeroIndex
		endif

		set concealed = CONCEAL_HERO_PICKS_FROM_ENEMIES and localPlayerId != P and(TEAM_OF_PLAYER[localPlayerId] != TEAM_OF_PLAYER[P] or TEAM_OF_PLAYER[P] == 0)
		
		//Random
		
		if heroIndex == RANDOM_HERO then
			set heroIndex = GetRandomHero(0, P)
			
			if PICK_SOUND != null then
				call PlaySoundLocal(PICK_SOUND, localPlayerId == P )
			endif

			set wasRandomSelect = true
			
			static if CREATE_FOREGROUND_HERO then
				if localPlayerId == P then
					set modelPath = Hero.list[heroIndex].modelPath
				else
					set modelPath = ""
				endif
				call DestroyEffect(selectedHero[P])
				call BlzSetSpecialEffectPosition(selectedHero[P], GARBAGE_DUMP_X, GARBAGE_DUMP_Y, 0 )
				set selectedHero[P] = AddSpecialEffect(modelPath, localForegroundHeroX, localForegroundHeroY )
				call BlzSetSpecialEffectYaw(selectedHero[P], Deg2Rad(localHeroSelectionAngle) + bj_PI )
				call BlzSetSpecialEffectScale(selectedHero[P], Hero.list[heroIndex].scalingValue )
			endif
		else
			call PlaySoundLocal("Sound\\Interface\\BigButtonClick.flac", localPlayerId == P )
			if PICK_SOUND != null then
				call PlaySoundLocal(PICK_SOUND, localPlayerId == P )
			endif
			set wasRandomSelect = false
		endif
		
		//Disable Buttons for selecting player.
		
		set i = 1
		loop
			exitwhen i > SUGGEST_RANDOM
			if localPlayerId == P then
				call SetButtonTextures(i, true)
			endif
			set i = i + 1
		endloop
		
		if localPlayerId == P then
			call BlzFrameSetEnable(heroAcceptButton, false )
			call BlzFrameSetEnable(heroBanButton, false )
			call BlzFrameSetEnable(heroResetButton, false )
		endif

		//Disable button for other players that have pre-selected that hero.
	
		static if CREATE_FOREGROUND_HERO then
			static if not HERO_CAN_BE_PICKED_MULTIPLE_TIMES then
				call SetButtonTextures(heroIndex, true)
				set i = 1
				loop
					exitwhen i > numSelectingPlayers
					if localPlayerId == playerNumberOfSlot[i] and preselectedHeroIndex[playerNumberOfSlot[i]] == heroIndex then
						call BlzFrameSetEnable(heroAcceptButton, false )
						call BlzFrameSetEnable(heroBanButton, false )
						static if PHANTOM_HERO_WHEN_CANNOT_BE_PICKED then
							if playerNumberOfSlot[i] != P then
								call BlzSetSpecialEffectAlpha(selectedHero[playerNumberOfSlot[i]], 128)
								call BlzSetSpecialEffectColor(selectedHero[playerNumberOfSlot[i]], 0, 0, 0)
							endif
						endif
					endif
					set i = i + 1
				endloop
			endif
		endif
		
		//Set variables
	
		set heroIndexWasPicked[heroIndex] = true
		set pickedHeroIndex[P] = heroIndex
		set heroIdOfPlayer[P] = Hero.list[heroIndex].unitId
		set heroIconPathOfPlayer[P] = "ReplaceableTextures\\CommandButtons\\" + Hero.list[heroIndex].iconPath
		set playerHasHero[P] = true
		set playerHasBan[P] = false
		set numPlayersWithHero = numPlayersWithHero + 1
		
		//Text messages

		if OTHER_PLAYER_HERO_PICK_SOUND != null then
			call PlaySoundLocal(OTHER_PLAYER_HERO_PICK_SOUND, localPlayerId != P and(MESSAGE_EVEN_WHEN_CONCEALED or not concealed))
		endif
	
		set i = 1
		loop
			exitwhen i > numSelectingPlayers
			set Q = playerNumberOfSlot[i]
			if P != Q then
				if CREATE_TEXT_MESSAGE_ON_PICK then
					set message = ""
					// if (CONCEAL_HERO_PICKS_FROM_ENEMIES and (TEAM_OF_PLAYER[P] != TEAM_OF_PLAYER[Q] or TEAM_OF_PLAYER[P] == 0)) then
					// 	if MESSAGE_EVEN_WHEN_CONCEALED then
					// 		set message = message + coloredPlayerName[P] + " has selected " + GetPickedHeroDisplayedName(heroIndex, false) + "."
					// 	endif
					// else
					if wasRandomSelect then
						set message = message + coloredPlayerName[P] + " has randomly selected " + GetPickedHeroDisplayedName(heroIndex, false) + "."
					else
						set message = message + coloredPlayerName[P] + " has selected " + GetPickedHeroDisplayedName(heroIndex, false) + "."
					endif
					// endif
					static if INCLUDE_PROGRESSION_IN_MESSAGE then
						set message = message + " " + I2S(numPlayersWithHero) + "/" + I2S(numSelectingPlayers) + " players have selected."
					endif
					if message != "" then
						static if LIBRARY_NeatMessages then
							call NeatMessageToPlayer(Player(Q), message)
						else
							call DisplayTextToPlayer(Player(Q), TEXT_MESSAGE_X_OFFSET, TEXT_MESSAGE_Y_OFFSET, message)
						endif
					endif
				endif
			else
				if wasRandomSelect then
					set message = "You randomly selected " + GetPickedHeroDisplayedName(heroIndex, false) + "."
				else
					set message = "You selected " + GetPickedHeroDisplayedName(heroIndex, false) + "."
				endif
				static if INCLUDE_PROGRESSION_IN_MESSAGE then
					set message = message + " " + I2S(numPlayersWithHero) + "/" + I2S(numSelectingPlayers) + " players have selected."
				endif
				static if LIBRARY_NeatMessages then
					call NeatMessageToPlayer(Player(P), message)
				else
					call DisplayTextToPlayer(Player(P), TEXT_MESSAGE_X_OFFSET, TEXT_MESSAGE_Y_OFFSET, message)
				endif
			endif
			set i = i + 1
		endloop
		
		//Foreground hero
		
		static if CREATE_FOREGROUND_HERO then
			if PICK_EFFECT != null then
				if localPlayerId == P then
					set modelPath = PICK_EFFECT
				else
					set modelPath = ""
				endif
			endif

			set pickEffect = AddSpecialEffect(modelPath, localForegroundHeroX, localForegroundHeroY )
			call BlzSetSpecialEffectZ(pickEffect, GetLocZ(localForegroundHeroX, localForegroundHeroY) + FOREGROUND_HERO_Z)
			call DestroyEffect(pickEffect)
			set pickEffect = null
		
			static if PLAY_ANIMATION_ON_PICK then
				call PlayHeroAnimation(P, heroIndex, false)
			endif

			static if PLAY_EMOTE_ON_PICK then
				call PlaySoundLocal(Hero.list[heroIndex].selectEmote, localPlayerId == P )
			endif

			if CREATE_BACKGROUND_HEROES or ESCAPE_PLAYER_AFTER_SELECTING or isRepicking[P] then
				set t = CreateTimer()
				call TimerStart(t, FOREGROUND_HERO_FADEOUT_DELAY, false, function FadeoutForegroundHero )
				call SaveInteger(hash, GetHandleId(t), 0, 0 )
				call SaveInteger(hash, GetHandleId(t), 1, P )
			endif
		endif
		
		//Create Background Hero
		
		static if CREATE_BACKGROUND_HEROES then
			if concealed then
				set modelPath = CONCEALED_HERO_EFFECT
			else
				set modelPath = Hero.list[heroIndex].modelPath
			endif
			set backgroundHero[P] = AddSpecialEffect(modelPath, BACKGROUND_HERO_X[P], BACKGROUND_HERO_Y[P] )
			call BlzSetSpecialEffectScale(backgroundHero[P], Hero.list[heroIndex].scalingValue )
			call BlzSetSpecialEffectAlpha(backgroundHero[P], 0 )
			call BlzSetSpecialEffectYaw(backgroundHero[P], Atan2(localForegroundHeroY - BACKGROUND_HERO_Y[P] + Sin(Deg2Rad(localHeroSelectionAngle)) * BACKGROUND_HERO_FACING_POINT_OFFSET, localForegroundHeroX - BACKGROUND_HERO_X[P] + Cos(Deg2Rad(localHeroSelectionAngle)) * BACKGROUND_HERO_FACING_POINT_OFFSET) )
			call BlzSetSpecialEffectColorByPlayer(backgroundHero[P], whichPlayer )
			call BlzSetSpecialEffectColor(backgroundHero[P], Hero.list[heroIndex].red, Hero.list[heroIndex].green, Hero.list[heroIndex].blue)

			if Hero.list[heroIndex].needsHeroGlow then
				set backgroundHeroGlow[P] = AddSpecialEffect("HeroGlow.mdx", BACKGROUND_HERO_X[P], BACKGROUND_HERO_Y[P] )
				call BlzSetSpecialEffectAlpha(backgroundHeroGlow[P], 0 )
				call BlzSetSpecialEffectColorByPlayer(backgroundHeroGlow[P], whichPlayer )
			endif

			if concealed then
				call BlzSetSpecialEffectColor(backgroundHero[P], 0, 0, 0)
			endif

			static if PLAY_ANIMATION_ON_BACKGROUND_HERO then
				call PlayHeroAnimation(P, heroIndex, true)
			endif
			
			if BACKGROUND_HERO_FADEIN_EFFECT != null then
				if localPlayerId != P then
					set modelPath = BACKGROUND_HERO_FADEIN_EFFECT
				else
					set modelPath = ""
				endif
				call DestroyEffect(AddSpecialEffect(modelPath, BACKGROUND_HERO_X[P], BACKGROUND_HERO_Y[P] ))
			endif

			static if PLAY_EMOTE_ON_BACKGROUND_HERO then
				call PlaySoundLocal(Hero.list[heroIndex].selectEmote, localPlayerId != P and isInHeroSelection[localPlayerId] and not concealed)
			endif

			static if CREATE_SHADOWS then
				if localPlayerId == P then
					set id = NO_SHADOW_DESTRUCTABLE_ID
				else
					set id = SHADOW_DESTRUCTABLE_ID
				endif
				set backgroundHeroShadow[P] = CreateDestructable(id, BACKGROUND_HERO_X[P], BACKGROUND_HERO_Y[P], 0, 1, 0)
			endif
			
			if BACKGROUND_HERO_FADEIN_TIME > 0 then
				set t = CreateTimer()
				call TimerStart(t, BACKGROUND_HERO_FADEIN_TIME / 50.0, true, function FadeInBackgroundHero )
				set id = GetHandleId(t)
				call SaveInteger(hash, id, 0, 0 )
				call SaveInteger(hash, id, 1, P )
				call SaveBoolean(hash, id, 2, concealed)
			else
				if concealed then
					call BlzSetSpecialEffectAlpha(backgroundHero[P], 128 )
				else
					call BlzSetSpecialEffectAlpha(backgroundHero[P], 255 )
				endif
			endif
		endif

		//Escape player after selecting hero. 
		if ESCAPE_PLAYER_AFTER_SELECTING or isRepicking[P] then
			set t = CreateTimer()
			set isFadingOut[P] = true
			call TimerStart(t, PLAYER_PICK_ESCAPE_DELAY, false, function EscapePlayerCaller)
			call SaveInteger(hash, GetHandleId(t), 0, P)
		endif
			
		//End hero selection.
		if not isRepicking[P] and numPlayersWithHero == numSelectingPlayers then
			call onLast.evaluate()
			if TIME_LIMIT > 0 then
				call PauseTimer(countdownTimer)
			endif
			static if not ESCAPE_PLAYER_AFTER_SELECTING then
				call TimerStart(CreateTimer(), LAST_PLAYER_SELECT_END_DELAY, false, function EndHeroSelectionCaller )
			endif
		endif

		// Force Computers to Auto Pick Random Hero when all humans are done picking.
		static if COMPUTER_AUTO_PICK_RANDOM_HERO then
			if playerIsHuman[P] and not isRepicking[P] then
				set allHumanPlayersHaveHeroes = true
				set i = 1
				loop
					exitwhen i > numSelectingPlayers
					set P = playerNumberOfSlot[i]
					if playerIsHuman[P] and not playerHasHero[P] then
						set allHumanPlayersHaveHeroes = false
						exitwhen true
					endif
					set i = i + 1
				endloop

				if allHumanPlayersHaveHeroes then
					set i = 1
					loop
						exitwhen i > numSelectingPlayers
						set P = playerNumberOfSlot[i]
						if not playerIsHuman[P] and not playerHasHero[P] and isInHeroSelection[P] then
							set isForcedSelect = true
							set storePlayerIndex = P
							set storeHeroIndex = RANDOM_HERO
							call PickHero()
							set isForcedSelect = false
						endif
						set i = i + 1
					endloop
				endif
			endif
		endif

		call onPick.evaluate(whichPlayer, Hero.list[heroIndex], wasRandomSelect, isRepicking[P])

		call NoCrash("PickHero")
		set t = null
	endfunction

	//==========================================================================================================================================================
	//Preselect Hero.
	//==========================================================================================================================================================
	
	private function PreselectRandomCycle takes nothing returns nothing
		local timer t = GetExpiredTimer()
		local integer P = LoadInteger(hash, GetHandleId(t), 0 )
		local integer heroIndexShown = LoadInteger(hash, GetHandleId(t), 1 )
		local integer newHeroShown

		call InitCrashCheck("PreselectRandomCycle")
	
		if preselectedHeroIndex[P] == RANDOM_HERO and not playerHasHero[P] then
			set newHeroShown = GetRandomHero(heroIndexShown, P)
			call CreateNewForegroundHero(P, newHeroShown)
			call SaveInteger(hash, GetHandleId(t), 1, newHeroShown )
		else
			call FlushChildHashtable(hash, GetHandleId(t) )
			call DestroyTimer(t)
		endif
		call NoCrash("PreselectRandomCycle")
		set t = null
	endfunction
	
	private function PreselectHero takes nothing returns nothing
		local player whichPlayer = GetTriggerPlayer()
		local integer P = GetPlayerId(whichPlayer)
		local integer i
		local framehandle whichFrame = BlzGetTriggerFrame()
		local boolean isSuggest
		local boolean isRandom
		local integer heroIndex
		local string modelPath = ""
		local string s = ""
		local timer t
		local integer oldHero = preselectedHeroIndex[P]
		local integer id
		local effect preselectEffect
		local playerHeroHeroCallback onPreselect = HeroSelectionOnPreselect
		local integer firstRandomHero

		local string defualtSelectionText
		local string items
		local integer itemTypeId
		local integer end

		if localPlayerId == P then
			call BlzFrameSetEnable(whichFrame, false)
			call BlzFrameSetEnable(whichFrame, true)
		endif
		
		if heroPreselectionDisabledForPlayer[P] then
			return
		endif

		call InitCrashCheck("PreselectHero")
	
		call PlaySoundLocal("Sound\\Interface\\BigButtonClick.flac", localPlayerId == P )

		if PRESELECT_EFFECT != null then
			if localPlayerId == P then
				set modelPath = PRESELECT_EFFECT
			endif
			set preselectEffect = AddSpecialEffect(modelPath, localForegroundHeroX, localForegroundHeroY )
			call BlzSetSpecialEffectZ(preselectEffect, GetLocZ(localForegroundHeroX, localForegroundHeroY) + FOREGROUND_HERO_Z)
			call DestroyEffect(preselectEffect)
			set preselectEffect = null
		endif
		
		set i = 1
		loop
			exitwhen i > SUGGEST_RANDOM
			if whichFrame == heroSelectionButton[i] then
				set heroIndex = i
				if heroIndex == RANDOM_HERO then
					set isSuggest = false
					set isRandom = true
				elseif heroIndex == SUGGEST_RANDOM then
					set isSuggest = true
					set isRandom = false
				else
					set isSuggest = false
					set isRandom = false
				endif
				exitwhen true
			endif
			set i = i + 1
		endloop
		set whichFrame = null
		
		if isSuggest then
			set heroIndex = GetRandomHero(preselectedHeroIndex[P], P)
			if localPlayerId == P and PAGE_OF_CATEGORY[Hero.list[heroIndex].category] != currentPage then
				set currentPage = PAGE_OF_CATEGORY[Hero.list[heroIndex].category]
				call DisplayNewPage(P)
			endif
		endif
		
		set startingZoneOfPlayer[P] = Hero.list[heroIndex].startingZone

		if localPlayerId == P then
			if not isRandom then
				set i = 1
				loop
					exitwhen i > NUMBER_OF_ABILITY_FRAMES
					if Hero.list[heroIndex].abilities[i] != 0 then
						call BlzFrameSetTexture(heroSelectionAbility[i], BlzGetAbilityIcon(Hero.list[heroIndex].abilities[i] ), 0, true )
						call BlzFrameSetText(heroSelectionAbilityTooltipTitle[i], GetHeroAbilityName(Hero.list[heroIndex].abilities[i]) )
						if Hero.list[heroIndex].isNonHeroAbility[i] then
							call BlzFrameSetText(heroSelectionAbilityTooltipText[i], BlzGetAbilityExtendedTooltip(Hero.list[heroIndex].abilities[i], 0) )
						else
							call BlzFrameSetText(heroSelectionAbilityTooltipText[i], BlzGetAbilityResearchExtendedTooltip(Hero.list[heroIndex].abilities[i], 0) )
						endif
						call BlzFrameSetSize(heroSelectionAbilityTooltipText[i], TOOLTIP_WIDTH - 0.01, 0.0 )
						call BlzFrameSetSize(heroSelectionAbilityTooltip[i], TOOLTIP_WIDTH, BlzFrameGetHeight(heroSelectionAbilityTooltipText[i]) + TOOLTIP_BASE_HEIGHT)
						call BlzFrameSetVisible(heroSelectionAbility[i], true )
					else
						call BlzFrameSetVisible(heroSelectionAbility[i], false )
					endif
					set i = i + 1
				endloop
			else
				set i = 1
				loop
					exitwhen i > NUMBER_OF_ABILITY_FRAMES
					call BlzFrameSetVisible(heroSelectionAbility[i], false )
					set i = i + 1
				endloop
			endif

			// call Debug("PreselectHeroID: " + I2S(Hero.list[heroIndex].unitId) + " slot: " + I2S(GetSlotForHeroUnitID(Hero.list[heroIndex].unitId)))
			
			if udg_GameMode == "PVP" then
				set s = ""
			else
				set s = GetTitle(whichPlayer, GetSlotForHeroUnitID(Hero.list[heroIndex].unitId))
			endif

			call BlzFrameSetEnable(heroResetButton, true )
			call BlzFrameSetVisible(regionText, true)
			if(s == null or s == "") then
				call BlzFrameSetText(regionText, "|cffffcc00Starting Zone|r")

				// Show Regions
				if IsAlliancePlayer(whichPlayer) then
					set i = 0
					set end = 1
				else
					set i = 3
					set end = 4
				endif
				loop
					exitwhen i > end
					if i == Hero.list[heroIndex].startingZone then
						set defualtSelectionText = "|n(Default)"
					else
						set defualtSelectionText = ""
					endif
					call BlzFrameSetText(g_buttons[i], REGION_NAMES[i] + defualtSelectionText)
					call BlzFrameSetVisible(g_buttons[i], true)
					set i = i + 1
				endloop

				// Hide Inventory Icons
				set i = 0
				loop
					exitwhen i > 5
					call BlzFrameSetVisible(inventoryIconFrames[i], false)
					set i = i + 1
				endloop
				call BlzFrameSetVisible(heroResetButton, false)
			else
				call BlzFrameSetText(regionText, "|cffffcc00Items|r")
				
				// Hide Regions
				set i = 0
				set end = 5
				loop
					exitwhen i > end
					call BlzFrameSetVisible(g_buttons[i], false)
					set i = i + 1
				endloop

				// Show Inventory Icons
				set items = GetItems(whichPlayer, GetSlotForHeroUnitID(Hero.list[heroIndex].unitId))
				set i = 0
				loop
					exitwhen i > 5
					if StringLength(items) >=(i * 5 + 5) and SubString(items, i * 5, i * 5 + 1) != "-" then
						set itemTypeId = S2A(SubString(items, i * 5, i * 5 + 4))
						// call Debug("PreselectHero itemTypeId: " + I2S(itemTypeId) + "Substring " + SubString(items, i * 5, i * 5 + 4))
						call BlzFrameSetTexture(inventoryIconFrames[i], BlzGetAbilityIcon(itemTypeId), 0, false)
					else
						if GetPlayerRace(whichPlayer) == RACE_HUMAN then
							call BlzFrameSetTexture(inventoryIconFrames[i], "war3mapImported\\HuInvTile.blp", 0, false)
						elseif GetPlayerRace(whichPlayer) == RACE_ORC then
							call BlzFrameSetTexture(inventoryIconFrames[i], "war3mapImported\\OrcInvTile.blp", 0, false)
						elseif GetPlayerRace(whichPlayer) == RACE_NIGHTELF then
							call BlzFrameSetTexture(inventoryIconFrames[i], "war3mapImported\\NeInvTile.blp", 0, false)
						elseif GetPlayerRace(whichPlayer) == RACE_UNDEAD then
							call BlzFrameSetTexture(inventoryIconFrames[i], "war3mapImported\\UdInvTile.blp", 0, false)
						else
							call BlzFrameSetTexture(inventoryIconFrames[i], "war3mapImported\\human-inventory-slotfiller.dds", 0, false)
						endif
					endif
					call BlzFrameSetVisible(inventoryIconFrames[i], true)
					set i = i + 1
				endloop
				
				// Update inventory tooltips
				call UpdateInventoryTooltips(whichPlayer, items)
				
				call BlzFrameSetVisible(heroResetButton, true)
			endif
			call BlzFrameSetText(titleText, "|cffffcc00" + GetHeroTitle(s, GetSlotForHeroUnitID(Hero.list[heroIndex].unitId)) + "|r")


			call BlzFrameSetEnable(heroAcceptButton, HeroCanBePicked(heroIndex, P) and not playerHasHero[P] and not heroSelectionDisabledForPlayer[P] )
			call BlzFrameSetEnable(heroBanButton, HeroCanBePicked(heroIndex, P) and heroIndex != RANDOM_HERO and playerHasBan[P] )
		endif

		static if CREATE_FOREGROUND_HERO then
			if not playerHasHero[P] and preselectedHeroIndex[P] != heroIndex then
				if not isRandom then
					call CreateNewForegroundHero(P, heroIndex)
					
					if HeroCanBePicked(heroIndex, P) and not heroSelectionDisabledForPlayer[P] then
						static if PLAY_EMOTE_ON_PRESELECT then
							call PlaySoundLocal(Hero.list[heroIndex].selectEmote, localPlayerId == P )
						endif
						static if PLAY_ANIMATION_ON_PRESELECT then
							call PlayHeroAnimation(P, heroIndex, false)
						endif
					endif
				elseif preselectedHeroIndex[P] != RANDOM_HERO then
					static if RANDOM_SELECT_CYCLE_STYLE then
						set firstRandomHero = GetRandomHero(0, P)
						call CreateNewForegroundHero(P, firstRandomHero)

						set t = CreateTimer()
						call TimerStart(t, RANDOM_SELECT_CYCLE_INTERVAL, true, function PreselectRandomCycle )
						call SaveInteger(hash, GetHandleId(t), 0, P )
						call SaveInteger(hash, GetHandleId(t), 1, firstRandomHero )
						set t = null
					else
						call CreateNewForegroundHero(P, RANDOM_HERO)
					endif
				endif
			endif

			static if CREATE_SHADOWS then
				call RemoveDestructable(foregroundHeroShadow)
				if preselectedHeroIndex[localPlayerId] == 0 or playerHasHero[localPlayerId] then
					set id = NO_SHADOW_DESTRUCTABLE_ID
				else
					set id = SHADOW_DESTRUCTABLE_ID
				endif
				set foregroundHeroShadow = CreateDestructable(id, localForegroundHeroX, localForegroundHeroY, 0, 1, 0)
			endif
		endif

		if localPlayerId == P then
			if not isRandom then
				call BlzFrameSetPoint(heroSelectionButtonHighlight, FRAMEPOINT_TOPLEFT, heroSelectionButton[heroIndex], FRAMEPOINT_TOPLEFT, 0.005 * 0.039 / MENU_BUTTON_SIZE, - 0.005 * 0.039 / MENU_BUTTON_SIZE )
				call BlzFrameSetPoint(heroSelectionButtonHighlight, FRAMEPOINT_BOTTOMRIGHT, heroSelectionButton[heroIndex], FRAMEPOINT_BOTTOMRIGHT, - 0.005 * 0.039 / MENU_BUTTON_SIZE, 0.005 * 0.039 / MENU_BUTTON_SIZE )
			else
				call BlzFrameSetPoint(heroSelectionButtonHighlight, FRAMEPOINT_TOPLEFT, heroSelectionButton[RANDOM_HERO], FRAMEPOINT_TOPLEFT, 0.005 * 0.039 / MENU_BUTTON_SIZE, - 0.005 * 0.039 / MENU_BUTTON_SIZE )
				call BlzFrameSetPoint(heroSelectionButtonHighlight, FRAMEPOINT_BOTTOMRIGHT, heroSelectionButton[RANDOM_HERO], FRAMEPOINT_BOTTOMRIGHT, - 0.005 * 0.039 / MENU_BUTTON_SIZE, 0.005 * 0.039 / MENU_BUTTON_SIZE )
			endif
			call BlzFrameSetVisible(heroSelectionButtonHighlight, true )
		endif

		set preselectedHeroIndex[P] = heroIndex

		call onPreselect.evaluate(whichPlayer, Hero.list[oldHero], Hero.list[heroIndex])

		call NoCrash("PreselectHero")
	endfunction

	//==========================================================================================================================================================
	//Init.
	//==========================================================================================================================================================
	
	private function InitMenu takes nothing returns nothing
		local integer i
		local integer j
		local integer jLocal
		local integer h
		local integer k
		local trigger trig
	
		local real buttonSpacing = MENU_BUTTON_SIZE + MENU_BUTTON_BUTTON_GAP
	
		local real menuWidth
		local real menuHeight
		local real Ystart
		local real currentY
		local real currentYLowest
		local real widthDiff
		local integer buttonsInRandomRow
	
		local integer column
		local integer heroesThisCategory
		local integer array whichHeroes
		local integer heroesThisCategoryLocal
		local boolean newRow
		local real xOffset
		local real glueTextOffset = 0.005

		local boolean hasNoCategoryHeroes = false
		local boolean firstCategoryThisPage

		local real pageCycleDownX
		local real pageCycleUpX
		local real pageCycleDownY
		local real pageCycleUpY
		local boolean pageCycleTextType
		local real pageCycleButtonSpacing
		local real pageCycleButtonSize
		local real pageCycleScaleOffset

		local real wideScreenAreaWidth
		local real menuXLeftLocal
		local real menuXRightLocal


		local real categoryScale
		local integer localClientHeight = BlzGetLocalClientHeight()

		local real frameWidth
		local real frameHeight = 0.12

		
		// Inventory Icons Grid (2x3)

		local integer invRow
		local integer invCol
		local integer invIdx
		local real invStartX
		local real invStartY
		local real invGap = 0.004


		call InitCrashCheck("InitMenu")
		
		call BlzLoadTOCFile("HeroSelectionTemplates.toc")

		if localClientHeight > 0 then
			set wideScreenAreaWidth = 0.6 * (BlzGetLocalClientWidth() / I2R(localClientHeight) - 4.0 / 3.0) / 2.0
		else
			set wideScreenAreaWidth = 0.6 * (16.0 / 9.0 - 4.0 / 3.0) / 2.0
		endif
		set menuXLeftLocal = RMaxBJ(0, MENU_X_LEFT + wideScreenAreaWidth)
		set menuXRightLocal = RMaxBJ(MENU_X_RIGHT - wideScreenAreaWidth, MENU_X_RIGHT - (wideScreenAreaWidth / 2.0))
		call Debug("WideScreenAreaWidth: " + R2S(wideScreenAreaWidth))
		call Debug("MenuXLeftLocal: " + R2S(menuXLeftLocal))
		call Debug("MenuXRightLocal: " + R2S(menuXRightLocal))
		set tooltipLeftXLocal = RMinBJ(TOOLTIP_LEFT_X + wideScreenAreaWidth, 0.8 + wideScreenAreaWidth - TOOLTIP_WIDTH)
	
		set menuWidth = 2 * MENU_LEFT_RIGHT_EDGE_GAP + MENU_NUMBER_OF_COLUMNS * MENU_BUTTON_SIZE +(MENU_NUMBER_OF_COLUMNS - 1) * MENU_BUTTON_BUTTON_GAP
		if MENU_BORDER_TILE_SIZE > 0 then
			set widthDiff = menuWidth
			set menuWidth = R2I(menuWidth / MENU_BORDER_TILE_SIZE + 0.99) * MENU_BORDER_TILE_SIZE
			set widthDiff = menuWidth - widthDiff
		else
			set widthDiff = 0
		endif

		//Hero Info
		set frameWidth	= menuWidth
		set heroInfo = BlzCreateFrame("HeroSelectionMenu", fullScreenParent, 0, 0)

		call BlzFrameSetPoint(heroInfo, FRAMEPOINT_TOPLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXRightLocal, MENU_Y_TOP )
		call BlzFrameSetPoint(heroInfo, FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXRightLocal + menuWidth, 0.33)//0.26)//0.33)//0.25 )//0.48)
		call BlzFrameSetVisible(heroInfo, false)

		// Set up the category names.
		set REGION_NAMES[0] = "Dun Morogh"
		set REGION_NAMES[1] = "Arathi Highlands"
		set REGION_NAMES[2] = "Teldrassil"
		set REGION_NAMES[3] = "Tirisfal Glades"
		set REGION_NAMES[4] = "Eversong Woods"
		set REGION_NAMES[5] = "Echo Isles"

		set titleText = BlzCreateFrameByType("TEXT", "titleText", heroInfo, "", 0)
		call BlzFrameSetPoint(titleText, FRAMEPOINT_TOP, heroInfo, FRAMEPOINT_TOP, 0, - 0.012)
		call BlzFrameSetTextAlignment(titleText, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
		call BlzFrameSetScale(titleText, MENU_CATEGORY_FONT_SIZE / 10)
		call BlzFrameSetText(titleText, "Select a Hero")

		set regionText = BlzCreateFrameByType("TEXT", "regionText", heroInfo, "", 0)
		call BlzFrameSetPoint(regionText, FRAMEPOINT_TOP, heroInfo, FRAMEPOINT_TOP, 0, - 0.040)
		call BlzFrameSetTextAlignment(regionText, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
		call BlzFrameSetScale(regionText, MENU_CATEGORY_FONT_SIZE / 10)
		call BlzFrameSetText(regionText, "|cffffcc00Starting Zone|r")
		call BlzFrameSetVisible(regionText, false)

		set i = 0
		loop
			exitwhen i > 5

			if i < 3 then
				set j = i
			else
				set j = i - 3
			endif

			// Create a GLUETEXTBUTTON for the actual button.
			set g_buttons[i] = BlzCreateFrameByType("GLUETEXTBUTTON", "heroSelectionButton_" + I2S(i), heroInfo, "ScriptDialogButton", 0)
			call BlzFrameSetPoint(g_buttons[i], FRAMEPOINT_TOP, heroInfo, FRAMEPOINT_TOP, 0, -(j * frameHeight / 1.6) - 0.08)
			call BlzFrameSetSize(g_buttons[i], frameWidth / 1.5, frameHeight / 1.5)
			call BlzFrameSetText(g_buttons[i], REGION_NAMES[i])
			
			call SetRegionButtonFrames(i)
			// Set the textures on the icon child frames.
			call SetRegionButtonTextures(i, "")

			set trig = CreateTrigger()
			call BlzTriggerRegisterFrameEvent(trig, g_buttons[i], FRAMEEVENT_CONTROL_CLICK)
			call TriggerAddAction(trig, function OnRegionButtonClicked)

			call BlzFrameSetVisible(g_buttons[i], false)

			set i = i + 1
		endloop

		// Inventory Icons Grid (2x3)
		// Calculate starting position: to the right of region buttons, below regionText
		set invStartX = frameWidth / 4 + 0.005
		set invStartY = - 0.085
		set invIdx = 0
		set invRow = 0
		loop
			exitwhen invRow >= 3
			set invCol = 0
			loop
				exitwhen invCol >= 2
				set inventoryIconFrames[invIdx] = BlzCreateFrameByType("BACKDROP", "inventoryIcon_" + I2S(invIdx), heroInfo, "", 0)
				call BlzFrameSetSize(inventoryIconFrames[invIdx], MENU_BUTTON_SIZE, MENU_BUTTON_SIZE)
				call BlzFrameSetPoint(inventoryIconFrames[invIdx], FRAMEPOINT_TOPLEFT, heroInfo, FRAMEPOINT_TOPLEFT, invStartX + invCol * (MENU_BUTTON_SIZE + invGap), invStartY - invRow * (MENU_BUTTON_SIZE + invGap))
				// Set a default icon or leave blank; update later when hero is selected
				call BlzFrameSetTexture(inventoryIconFrames[invIdx], "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp", 0, true)
				call BlzFrameSetVisible(inventoryIconFrames[invIdx], false)
				
				// Create an invisible hover frame on top to handle mouse events for tooltips
				set inventoryIconHover[invIdx] = BlzCreateFrameByType("FRAME", "inventoryIconHover_" + I2S(invIdx), inventoryIconFrames[invIdx], "", 0)
				call BlzFrameSetAllPoints(inventoryIconHover[invIdx], inventoryIconFrames[invIdx])
				
				// Create tooltip for each inventory slot - attach to the hover frame instead
				call SetInventoryTooltip(invIdx, "Empty Slot", "No item equipped in this slot.")
				
				set invIdx = invIdx + 1
				set invCol = invCol + 1
			endloop
			set invRow = invRow + 1
		endloop
		// call BlzFrameSetPoint(heroSelectionButton[h], FRAMEPOINT_TOPLenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + MENU_LEFT_RIGHT_EDGE_GAP + xOffset + column * buttonSpacing - glueTextOffset, currentY + glueTextOffset )
		// call BlzFrameSetPoint(heroSelectionButton[h], FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + MENU_LEFT_RIGHT_EDGE_GAP + xOffset + column * buttonSpacing + MENU_BUTTON_SIZE + glueTextOffset, currentY - MENU_BUTTON_SIZE - glueTextOffset )
		
		//Reset
		set heroResetButton = BlzCreateFrameByType("GLUETEXTBUTTON", "heroResetButton", heroInfo, "ScriptDialogButton", 0)
		call BlzFrameSetPoint(heroResetButton, FRAMEPOINT_TOPLEFT, heroInfo, FRAMEPOINT_BOTTOMLEFT, menuWidth / 2 - 0.04, 0.028 )
		call BlzFrameSetPoint(heroResetButton, FRAMEPOINT_BOTTOMRIGHT, heroInfo, FRAMEPOINT_BOTTOMLEFT, menuWidth / 2 + 0.04, - 0.002)
		call BlzFrameSetText(heroResetButton, "|cffffcc00Reset|r")
		call BlzFrameSetVisible(heroResetButton, false)


		set trig = CreateTrigger()
		call BlzTriggerRegisterFrameEvent(trig, heroResetButton, FRAMEEVENT_CONTROL_CLICK )
		call TriggerAddAction(trig, function ResetHero)
		set trig = null
		
		
		//Main Menu
		set heroSelectionMenu = BlzCreateFrame("HeroSelectionMenu", fullScreenParent, 0, 0)
		call BlzFrameSetPoint(heroSelectionMenu, FRAMEPOINT_TOPLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal, MENU_Y_TOP )
		call BlzFrameSetPoint(heroSelectionMenu, FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + menuWidth, 0 )
		
		set heroSelectionButtonTrigger = CreateTrigger()
		call TriggerAddAction(heroSelectionButtonTrigger, function PreselectHero )
	
		set Ystart = MENU_Y_TOP - MENU_TOP_EDGE_GAP
		set currentYLowest = Ystart

		//Hero buttons
		set k = 1
		loop
			exitwhen k > NUMBER_OF_PAGES

			set currentY = Ystart
			set firstCategoryThisPage = true

			set i = 0
			loop
				exitwhen i > NUMBER_OF_CATEGORIES
				if PAGE_OF_CATEGORY[i] == k or(PAGE_OF_CATEGORY[i] == 0 and k == 1) then
					if i > 0 then
						if not firstCategoryThisPage or CATEGORY_NAMES[i] != null then
							set currentY = currentY - MENU_CATEGORY_GAP
						endif
						if not firstCategoryThisPage then
							set currentY = currentY - buttonSpacing
						endif

						if CATEGORY_NAMES[i] != null then
							set categoryScale = MENU_CATEGORY_FONT_SIZE / 10.
							set heroSelectionCategory[i] = BlzCreateFrameByType("TEXT", CATEGORY_NAMES[i], heroSelectionMenu, "", 0)
							call BlzFrameSetPoint(heroSelectionCategory[i], FRAMEPOINT_TOPLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal / categoryScale,(currentY + MENU_CATEGORY_GAP / 2 + MENU_CATEGORY_TITLE_Y + 0.02) / categoryScale)
							call BlzFrameSetPoint(heroSelectionCategory[i], FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT,(menuXLeftLocal + menuWidth) / categoryScale,(currentY + MENU_CATEGORY_GAP / 2 + MENU_CATEGORY_TITLE_Y - 0.02) / categoryScale)
							call BlzFrameSetTextAlignment(heroSelectionCategory[i], TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
							call BlzFrameSetScale(heroSelectionCategory[i], categoryScale)
							call BlzFrameSetText(heroSelectionCategory[i], CATEGORY_NAMES[i])

							if k != 1 then
								call BlzFrameSetVisible(heroSelectionCategory[i], false)
							endif
						endif
					endif

					set heroesThisCategory = 0
					set heroesThisCategoryLocal = 0
					set j = 1
					loop
						exitwhen j > NUMBER_OF_HEROES
						if Hero.list[j].category == i then
							set heroesThisCategory = heroesThisCategory + 1
							set whichHeroes[heroesThisCategory] = j
							if not Hero.list[j].unavailableToTeam[TEAM_OF_PLAYER[localPlayerId]] then
								set heroesThisCategoryLocal = heroesThisCategoryLocal + 1
							endif
						endif
						set j = j + 1
					endloop

					if i == 0 and heroesThisCategoryLocal > 0 then
						set hasNoCategoryHeroes = true
					endif
			
					set column = 0
					set newRow = true
					set j = 1
					set jLocal = 1
					loop
						exitwhen j > heroesThisCategory
						if newRow then
							if heroesThisCategoryLocal -(jLocal - 1) < MENU_NUMBER_OF_COLUMNS then
								set xOffset = buttonSpacing / 2 *(MENU_NUMBER_OF_COLUMNS -(heroesThisCategoryLocal -(jLocal - 1))) + widthDiff / 2
							else
								set xOffset = widthDiff / 2
							endif
							if jLocal != 1 then
								set currentY = currentY - buttonSpacing
							endif
						endif
						set h = whichHeroes[j]
			
						set heroSelectionButton[h] = BlzCreateFrameByType("GLUETEXTBUTTON", "heroSelectionButton_" + I2S(h), heroSelectionMenu, "ScriptDialogButton", 0)
						call BlzFrameSetPoint(heroSelectionButton[h], FRAMEPOINT_TOPLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + MENU_LEFT_RIGHT_EDGE_GAP + xOffset + column * buttonSpacing - glueTextOffset, currentY + glueTextOffset )
						call BlzFrameSetPoint(heroSelectionButton[h], FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + MENU_LEFT_RIGHT_EDGE_GAP + xOffset + column * buttonSpacing + MENU_BUTTON_SIZE + glueTextOffset, currentY - MENU_BUTTON_SIZE - glueTextOffset )
						
						call SetButtonFrames(h)
						call SetButtonTextures(h, not PRE_SELECT_BEFORE_ENABLED or Hero.list[h].unavailable)
						if Hero.list[h].tooltip != null then
							if not Hero.list[h].unavailable then
								call SetButtonTooltip(h, Hero.list[h].name, Hero.list[h].tooltip)
							else
								call SetButtonTooltip(h, Hero.list[h].name, Hero.list[h].tooltip + "|n|n|cffff0000Not available.|r")
							endif
						else
							static if HERO_SELECTION_ENABLE_DEBUG_MODE then
								call BJDebugMsg("|cffff0000Warning:|r Tooltip missing or invalid for hero " + Hero.list[h].name + "...")
							endif
						endif

						call BlzFrameSetVisible(heroSelectionButton[h], not Hero.list[h].unavailableToTeam[TEAM_OF_PLAYER[localPlayerId]] and k == 1)

						call BlzTriggerRegisterFrameEvent(heroSelectionButtonTrigger, heroSelectionButton[h], FRAMEEVENT_CONTROL_CLICK )
			
						if not Hero.list[h].unavailableToTeam[TEAM_OF_PLAYER[localPlayerId]] then
							set column = column + 1
							if column == MENU_NUMBER_OF_COLUMNS and jLocal < heroesThisCategoryLocal then
								set newRow = true
								set column = 0
							else
								set newRow = false
							endif
							set jLocal = jLocal + 1
						endif
						set j = j + 1
					endloop

					if i > 0 or hasNoCategoryHeroes then
						set firstCategoryThisPage = false
					endif
				endif

				set i = i + 1
			endloop

			if currentY < currentYLowest then
				set currentYLowest = currentY
			endif

			set k = k + 1
		endloop

		set currentY = currentYLowest
	
		//Random
		if MENU_INCLUDE_RANDOM_PICK or MENU_INCLUDE_SUGGEST_RANDOM or(NUMBER_OF_PAGES > 1 and PAGE_CYCLE_BUTTON_STYLE == "EnvelopRandomButton") then
			set currentY = currentY - buttonSpacing - MENU_HEROES_RANDOM_GAP
			set buttonsInRandomRow = 0
			static if MENU_INCLUDE_RANDOM_PICK then
				set buttonsInRandomRow = buttonsInRandomRow + 1
			endif
			static if MENU_INCLUDE_SUGGEST_RANDOM then
				set buttonsInRandomRow = buttonsInRandomRow + 1
			endif
			if(NUMBER_OF_PAGES > 1 and PAGE_CYCLE_BUTTON_STYLE == "EnvelopRandomButton") then
				set buttonsInRandomRow = buttonsInRandomRow + 2
			endif

			if HERO_SELECTION_ENABLE_DEBUG_MODE and MENU_NUMBER_OF_COLUMNS < buttonsInRandomRow then
				call BJDebugMsg("|cffff0000Warning:|r Not enough columns set to accomodate all buttons in the random row...")
			endif
		endif

		static if MENU_INCLUDE_RANDOM_PICK then

			if MENU_INCLUDE_SUGGEST_RANDOM then
				set xOffset = buttonSpacing / 2 *(MENU_NUMBER_OF_COLUMNS - 2) + widthDiff / 2
			else
				set xOffset = buttonSpacing / 2 *(MENU_NUMBER_OF_COLUMNS - 1) + widthDiff / 2
			endif
		
			set heroSelectionButton[RANDOM_HERO] = BlzCreateFrameByType("GLUETEXTBUTTON", "heroRandomButton", heroSelectionMenu, "ScriptDialogButton", 0)
			call BlzFrameSetPoint(heroSelectionButton[RANDOM_HERO], FRAMEPOINT_TOPLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + MENU_LEFT_RIGHT_EDGE_GAP + xOffset - glueTextOffset, currentY + glueTextOffset )
			call BlzFrameSetPoint(heroSelectionButton[RANDOM_HERO], FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + MENU_LEFT_RIGHT_EDGE_GAP + xOffset + MENU_BUTTON_SIZE + glueTextOffset, currentY - MENU_BUTTON_SIZE - glueTextOffset )

			call SetButtonFrames(RANDOM_HERO)
			call SetButtonTextures(RANDOM_HERO, not PRE_SELECT_BEFORE_ENABLED)
			call SetButtonTooltip(RANDOM_HERO, "Select Random", RANDOM_HERO_TOOLTIP)
			
			call BlzTriggerRegisterFrameEvent(heroSelectionButtonTrigger, heroSelectionButton[RANDOM_HERO], FRAMEEVENT_CONTROL_CLICK )
		endif

		//Suggest
		static if MENU_INCLUDE_SUGGEST_RANDOM then

			if MENU_INCLUDE_RANDOM_PICK then
				set xOffset = buttonSpacing / 2 * MENU_NUMBER_OF_COLUMNS + widthDiff / 2
			else
				set xOffset = buttonSpacing / 2 *(MENU_NUMBER_OF_COLUMNS - 1) + widthDiff / 2
			endif
		
			set heroSelectionButton[SUGGEST_RANDOM] = BlzCreateFrameByType("GLUETEXTBUTTON", "heroRandomButton", heroSelectionMenu, "ScriptDialogButton", 0)
			call BlzFrameSetPoint(heroSelectionButton[SUGGEST_RANDOM], FRAMEPOINT_TOPLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + MENU_LEFT_RIGHT_EDGE_GAP + xOffset - glueTextOffset, currentY + glueTextOffset )
			call BlzFrameSetPoint(heroSelectionButton[SUGGEST_RANDOM], FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + MENU_LEFT_RIGHT_EDGE_GAP + xOffset + MENU_BUTTON_SIZE + glueTextOffset, currentY - MENU_BUTTON_SIZE - glueTextOffset )
			
			call SetButtonFrames(SUGGEST_RANDOM)
			call SetButtonTextures(SUGGEST_RANDOM, not PRE_SELECT_BEFORE_ENABLED)
			call SetButtonTooltip(SUGGEST_RANDOM, "Suggest Random", SUGGEST_RANDOM_TOOLTIP)

			call BlzTriggerRegisterFrameEvent(heroSelectionButtonTrigger, heroSelectionButton[SUGGEST_RANDOM], FRAMEEVENT_CONTROL_CLICK )
		endif

		//Set Bottom Corners
		set menuHeight = MENU_Y_TOP -(currentY - buttonSpacing - MENU_BOTTOM_EDGE_GAP)
		if MENU_BORDER_TILE_SIZE > 0 then
			set menuHeight = R2I(menuHeight / MENU_BORDER_TILE_SIZE + 0.99) * MENU_BORDER_TILE_SIZE
		endif

		call BlzFrameSetPoint(heroSelectionMenu, FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + menuWidth, MENU_Y_TOP - menuHeight )

		//Page Cycle Buttons
		if NUMBER_OF_PAGES > 1 then
			set pageCycleTrigger = CreateTrigger()
			call TriggerAddAction(pageCycleTrigger, function CyclePage)
			set pageCycleButtonSpacing = buttonSpacing * MENU_PAGE_CYCLE_SCALE
			set pageCycleButtonSize = MENU_BUTTON_SIZE * MENU_PAGE_CYCLE_SCALE
			set pageCycleScaleOffset =(buttonSpacing - pageCycleButtonSpacing) / 2

			if PAGE_CYCLE_BUTTON_STYLE == "EnvelopRandomButton" then
				set pageCycleDownX = menuXLeftLocal + MENU_LEFT_RIGHT_EDGE_GAP + buttonSpacing / 2 * (MENU_NUMBER_OF_COLUMNS - buttonsInRandomRow) + widthDiff / 2
				set pageCycleUpX = menuXLeftLocal + MENU_LEFT_RIGHT_EDGE_GAP + buttonSpacing / 2 * (MENU_NUMBER_OF_COLUMNS + buttonsInRandomRow - 2) + widthDiff / 2
				set pageCycleDownY = currentY
				set pageCycleUpY = currentY
				set pageCycleTextType = false
			elseif PAGE_CYCLE_BUTTON_STYLE == "LeftRightMenuButton" then
				set pageCycleDownX = menuXLeftLocal + MENU_LEFT_RIGHT_EDGE_GAP + widthDiff / 2
				set pageCycleUpX = menuXLeftLocal + MENU_LEFT_RIGHT_EDGE_GAP + pageCycleButtonSpacing * (MENU_NUMBER_OF_COLUMNS - 1) + widthDiff / 2
				set pageCycleDownY = currentY
				set pageCycleUpY = currentY
				set pageCycleTextType = false
			elseif PAGE_CYCLE_BUTTON_STYLE == "BelowRandomButton" then
				set pageCycleDownX = MENU_LEFT_RIGHT_EDGE_GAP + buttonSpacing / 2 * (MENU_NUMBER_OF_COLUMNS - 2) + widthDiff / 2
				set pageCycleUpX = MENU_LEFT_RIGHT_EDGE_GAP + buttonSpacing / 2 * MENU_NUMBER_OF_COLUMNS + widthDiff / 2
				set currentY = currentY - pageCycleButtonSpacing - MENU_HEROES_RANDOM_GAP
				set pageCycleDownY = currentY
				set pageCycleUpY = currentY
				set pageCycleTextType = false

				set menuHeight = MENU_Y_TOP -(currentY - buttonSpacing - MENU_BOTTOM_EDGE_GAP)
				if MENU_BORDER_TILE_SIZE > 0 then
					set menuHeight = R2I(menuHeight / MENU_BORDER_TILE_SIZE + 0.99) * MENU_BORDER_TILE_SIZE
				endif
				call BlzFrameSetPoint(heroSelectionMenu, FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + menuWidth, MENU_Y_TOP - menuHeight )

			elseif PAGE_CYCLE_BUTTON_STYLE == "LeftRightMiddleButton" then
				set pageCycleDownX = menuXLeftLocal - pageCycleButtonSize / 2
				set pageCycleUpX = menuXLeftLocal + menuWidth - pageCycleButtonSize / 2
				set pageCycleDownY = MENU_Y_TOP -(menuHeight - pageCycleButtonSize) / 2
				set pageCycleUpY = pageCycleDownY
				set pageCycleTextType = false
			elseif PAGE_CYCLE_BUTTON_STYLE == "RightVerticalButton" then
				set pageCycleDownX = menuXLeftLocal + menuWidth //- pageCycleButtonSize/2
				set pageCycleUpX = menuXLeftLocal + menuWidth //- pageCycleButtonSize/2
				set pageCycleDownY = MENU_Y_TOP - menuHeight / 2
				set pageCycleUpY = MENU_Y_TOP - menuHeight / 2 + pageCycleButtonSpacing
				set pageCycleTextType = false
			elseif PAGE_CYCLE_BUTTON_STYLE == "LeftVerticalButton" then
				set pageCycleDownX = menuXLeftLocal + 0 - pageCycleButtonSize ///2
				set pageCycleUpX = menuXLeftLocal + 0 - pageCycleButtonSize ///2
				set pageCycleDownY = MENU_Y_TOP - menuHeight / 2
				set pageCycleUpY = MENU_Y_TOP - menuHeight / 2 + pageCycleButtonSpacing
				set pageCycleTextType = false
			elseif PAGE_CYCLE_BUTTON_STYLE == "EnvelopAcceptButton" then
				set pageCycleDownX = menuXLeftLocal + menuWidth / 2 - MENU_PAGE_CYCLE_SCALE * SELECT_BUTTON_WIDTH - SELECT_BUTTON_WIDTH / 2
				set pageCycleUpX = menuXLeftLocal + menuWidth / 2 + SELECT_BUTTON_WIDTH / 2
				set pageCycleDownY = MENU_Y_TOP - menuHeight
				set pageCycleUpY = pageCycleDownY
				set pageCycleTextType = true
			elseif PAGE_CYCLE_BUTTON_STYLE == "LeftRightBottomButton" then
				set pageCycleDownX = menuXLeftLocal
				set pageCycleUpX = menuXLeftLocal + menuWidth - SELECT_BUTTON_WIDTH * MENU_PAGE_CYCLE_SCALE
				set pageCycleDownY = MENU_Y_TOP - menuHeight
				set pageCycleUpY = pageCycleDownY
				set pageCycleTextType = true
			elseif PAGE_CYCLE_BUTTON_STYLE == "TangentTopButton" then
				set pageCycleDownX = menuXLeftLocal + menuWidth / 2 - SELECT_BUTTON_WIDTH * MENU_PAGE_CYCLE_SCALE
				set pageCycleUpX = menuXLeftLocal + menuWidth / 2
				set pageCycleDownY = MENU_Y_TOP - 0.0175
				set pageCycleUpY = pageCycleDownY
				set pageCycleTextType = true
			elseif PAGE_CYCLE_BUTTON_STYLE == "LeftRightTopButton" then
				set pageCycleDownX = menuXLeftLocal
				set pageCycleUpX = menuXLeftLocal + menuWidth - SELECT_BUTTON_WIDTH * MENU_PAGE_CYCLE_SCALE
				set pageCycleDownY = MENU_Y_TOP - 0.0175
				set pageCycleUpY = pageCycleDownY
				set pageCycleTextType = true
			elseif HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Unrecognized page cycle button style (" + PAGE_CYCLE_BUTTON_STYLE + ").")
			endif

			if pageCycleTextType then
				set heroSelectionButton[PAGE_DOWN] = BlzCreateFrameByType("GLUETEXTBUTTON", "pageDownButton", heroSelectionMenu, "ScriptDialogButton", 0)
				call BlzFrameSetPoint(heroSelectionButton[PAGE_DOWN], FRAMEPOINT_TOPLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, pageCycleDownX + MENU_PAGE_CYCLE_X_OFFSET, pageCycleDownY + 0.012 + 0.012 * SELECT_BUTTON_SCALE * MENU_PAGE_CYCLE_SCALE + MENU_PAGE_CYCLE_Y_OFFSET )
				call BlzFrameSetPoint(heroSelectionButton[PAGE_DOWN], FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, pageCycleDownX + MENU_PAGE_CYCLE_X_OFFSET + SELECT_BUTTON_WIDTH * MENU_PAGE_CYCLE_SCALE, pageCycleDownY - 0.003 - 0.003 * SELECT_BUTTON_SCALE * MENU_PAGE_CYCLE_SCALE + MENU_PAGE_CYCLE_Y_OFFSET )
				call BlzFrameSetText(heroSelectionButton[PAGE_DOWN], "Prev" )
				call BlzFrameSetScale(heroSelectionButton[PAGE_DOWN], SELECT_BUTTON_SCALE * MENU_PAGE_CYCLE_SCALE )
			else
				set heroSelectionButton[PAGE_DOWN] = BlzCreateFrameByType("GLUETEXTBUTTON", "pageDownButton", heroSelectionMenu, "ScriptDialogButton", 0)
				call BlzFrameSetPoint(heroSelectionButton[PAGE_DOWN], FRAMEPOINT_TOPLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, pageCycleDownX + MENU_PAGE_CYCLE_X_OFFSET - glueTextOffset + pageCycleScaleOffset, pageCycleDownY + glueTextOffset + MENU_PAGE_CYCLE_Y_OFFSET - pageCycleScaleOffset )
				call BlzFrameSetPoint(heroSelectionButton[PAGE_DOWN], FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, pageCycleDownX + MENU_PAGE_CYCLE_X_OFFSET + pageCycleButtonSize + glueTextOffset + pageCycleScaleOffset, pageCycleDownY - pageCycleButtonSize - glueTextOffset + MENU_PAGE_CYCLE_Y_OFFSET - pageCycleScaleOffset )
				call SetButtonFrames(PAGE_DOWN)
				call SetButtonTextures(PAGE_DOWN, not PRE_SELECT_BEFORE_ENABLED)
				call SetButtonTooltip(PAGE_DOWN, "Page Down", "Go to the previous page.")
			endif

			call BlzTriggerRegisterFrameEvent(pageCycleTrigger, heroSelectionButton[PAGE_DOWN], FRAMEEVENT_CONTROL_CLICK )

			if pageCycleTextType then
				set heroSelectionButton[PAGE_UP] = BlzCreateFrameByType("GLUETEXTBUTTON", "pageUpButton", heroSelectionMenu, "ScriptDialogButton", 0)
				call BlzFrameSetPoint(heroSelectionButton[PAGE_UP], FRAMEPOINT_TOPLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, pageCycleUpX - MENU_PAGE_CYCLE_X_OFFSET, pageCycleUpY + 0.012 + 0.012 * SELECT_BUTTON_SCALE * MENU_PAGE_CYCLE_SCALE + MENU_PAGE_CYCLE_Y_OFFSET )
				call BlzFrameSetPoint(heroSelectionButton[PAGE_UP], FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, pageCycleUpX - MENU_PAGE_CYCLE_X_OFFSET + SELECT_BUTTON_WIDTH * MENU_PAGE_CYCLE_SCALE, pageCycleUpY - 0.003 - 0.003 * SELECT_BUTTON_SCALE * MENU_PAGE_CYCLE_SCALE + MENU_PAGE_CYCLE_Y_OFFSET )
				call BlzFrameSetText(heroSelectionButton[PAGE_UP], "Next" )
				call BlzFrameSetScale(heroSelectionButton[PAGE_UP], SELECT_BUTTON_SCALE * MENU_PAGE_CYCLE_SCALE )
			else
				set heroSelectionButton[PAGE_UP] = BlzCreateFrameByType("GLUETEXTBUTTON", "pageUpButton", heroSelectionMenu, "ScriptDialogButton", 0)
				call BlzFrameSetPoint(heroSelectionButton[PAGE_UP], FRAMEPOINT_TOPLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, pageCycleUpX - MENU_PAGE_CYCLE_X_OFFSET - glueTextOffset + pageCycleScaleOffset, pageCycleUpY + glueTextOffset + MENU_PAGE_CYCLE_Y_OFFSET - pageCycleScaleOffset )
				call BlzFrameSetPoint(heroSelectionButton[PAGE_UP], FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, pageCycleUpX - MENU_PAGE_CYCLE_X_OFFSET + pageCycleButtonSize + glueTextOffset + pageCycleScaleOffset, pageCycleUpY - pageCycleButtonSize - glueTextOffset + MENU_PAGE_CYCLE_Y_OFFSET - pageCycleScaleOffset )
				call SetButtonFrames(PAGE_UP)
				call SetButtonTextures(PAGE_UP, not PRE_SELECT_BEFORE_ENABLED)
				call SetButtonTooltip(PAGE_UP, "Page Up", "Go to the next page.")
			endif

			call BlzTriggerRegisterFrameEvent(pageCycleTrigger, heroSelectionButton[PAGE_UP], FRAMEEVENT_CONTROL_CLICK )
		endif

		//Highlight
		set heroSelectionButtonHighlight = BlzCreateFrameByType("SPRITE", "SpriteName", heroSelectionMenu, "", 0)
		call BlzFrameSetModel(heroSelectionButtonHighlight, "UI\\Feedback\\Autocast\\UI-ModalButtonOn.mdl", 0)
		call BlzFrameSetScale(heroSelectionButtonHighlight, MENU_BUTTON_SIZE / 0.039)
		call BlzFrameSetVisible(heroSelectionButtonHighlight, false )

		//Accept
		set heroAcceptButton = BlzCreateFrameByType("GLUETEXTBUTTON", "heroAcceptButton", heroSelectionMenu, "ScriptDialogButton", 0)

		// call BlzFrameSetPoint( heroAcceptButton , FRAMEPOINT_TOPLEFT , fullScreenFrame , FRAMEPOINT_BOTTOMLEFT , 0.4-0.06, 0.13+0.03 )
		// call BlzFrameSetPoint( heroAcceptButton , FRAMEPOINT_BOTTOMRIGHT , fullScreenFrame , FRAMEPOINT_BOTTOMLEFT, 0.4+0.06, 0.13-0.03 )

		call BlzFrameSetPoint(heroAcceptButton, FRAMEPOINT_TOPLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + menuWidth / 2 - SELECT_BUTTON_WIDTH / 2, MENU_Y_TOP - menuHeight + 0.012 + 0.012 * SELECT_BUTTON_SCALE )
		call BlzFrameSetPoint(heroAcceptButton, FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + menuWidth / 2 + SELECT_BUTTON_WIDTH / 2, MENU_Y_TOP - menuHeight - 0.003 - 0.003 * SELECT_BUTTON_SCALE )
		call BlzFrameSetText(heroAcceptButton, SELECT_BUTTON_TEXT )
		call BlzFrameSetScale(heroAcceptButton, SELECT_BUTTON_SCALE )
		call BlzFrameSetEnable(heroAcceptButton, false )

		set trig = CreateTrigger()
		call BlzTriggerRegisterFrameEvent(trig, heroAcceptButton, FRAMEEVENT_CONTROL_CLICK )
		call TriggerAddAction(trig, function PickHero)
		set trig = null

		//Ban
		set heroBanButton = BlzCreateFrameByType("GLUETEXTBUTTON", "heroBanButton", heroSelectionMenu, "ScriptDialogButton", 0)
		call BlzFrameSetPoint(heroBanButton, FRAMEPOINT_TOPLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + menuWidth / 2 - SELECT_BUTTON_WIDTH / 2, MENU_Y_TOP - menuHeight + 0.012 + 0.012 * SELECT_BUTTON_SCALE )
		call BlzFrameSetPoint(heroBanButton, FRAMEPOINT_BOTTOMRIGHT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, menuXLeftLocal + menuWidth / 2 + SELECT_BUTTON_WIDTH / 2, MENU_Y_TOP - menuHeight - 0.003 - 0.003 * SELECT_BUTTON_SCALE )
		call BlzFrameSetText(heroBanButton, SELECT_BUTTON_TEXT )
		call BlzFrameSetText(heroBanButton, "Ban" )
		call BlzFrameSetEnable(heroBanButton, false )
		call BlzFrameSetVisible(heroBanButton, false)

		set trig = CreateTrigger()
		call BlzTriggerRegisterFrameEvent(trig, heroBanButton, FRAMEEVENT_CONTROL_CLICK )
		// call TriggerAddAction(trig, function BanHero )
		set trig = null
		
		//Ability Buttons
		set i = 1
		loop
			exitwhen i > NUMBER_OF_ABILITY_FRAMES
			set heroSelectionAbility[i] = BlzCreateFrameByType("BACKDROP", "heroSelectionAbility_" + I2S(i), heroSelectionMenu, "", 0)
			static if ABILITY_BUTTON_HORIZONTAL_LAYOUT then
				call BlzFrameSetPoint(heroSelectionAbility[i], FRAMEPOINT_TOPLEFT, heroSelectionMenu, FRAMEPOINT_TOPRIGHT, HERO_ABILITY_PREVIEW_BUTTON_X + HERO_ABILITY_PREVIEW_BUTTON_SIZE * (i - 1), HERO_ABILITY_PREVIEW_BUTTON_Y)
			else
				call BlzFrameSetPoint(heroSelectionAbility[i], FRAMEPOINT_TOPLEFT, heroSelectionMenu, FRAMEPOINT_TOPRIGHT, HERO_ABILITY_PREVIEW_BUTTON_X, HERO_ABILITY_PREVIEW_BUTTON_Y - HERO_ABILITY_PREVIEW_BUTTON_SIZE * (i - 1))
			endif
			call BlzFrameSetSize(heroSelectionAbility[i], HERO_ABILITY_PREVIEW_BUTTON_SIZE, HERO_ABILITY_PREVIEW_BUTTON_SIZE)
			call BlzFrameSetVisible(heroSelectionAbility[i], false )
			
			set heroSelectionAbilityHover[i] = BlzCreateFrameByType("FRAME", "heroIconFrameHover", heroSelectionAbility[i], "", 0)
			call BlzFrameSetAllPoints(heroSelectionAbilityHover[i], heroSelectionAbility[i] )
	
			set heroSelectionAbilityTooltip[i] = BlzCreateFrame("CustomTooltip", heroSelectionAbilityHover[i], 0, 0)
			if TOOLTIP_LOCK_TOP then
				call BlzFrameSetPoint(heroSelectionAbilityTooltip[i], FRAMEPOINT_TOPLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, tooltipLeftXLocal, TOOLTIP_Y )
			else
				call BlzFrameSetPoint(heroSelectionAbilityTooltip[i], FRAMEPOINT_BOTTOMLEFT, fullScreenFrame, FRAMEPOINT_BOTTOMLEFT, tooltipLeftXLocal, TOOLTIP_Y )
			endif
			call BlzFrameSetTooltip(heroSelectionAbilityHover[i], heroSelectionAbilityTooltip[i] )
			call BlzFrameSetSize(heroSelectionAbilityTooltip[i], TOOLTIP_WIDTH, 0.0 )
			set heroSelectionAbilityTooltipTitle[i] = BlzFrameGetChild(heroSelectionAbilityTooltip[i], 0)
			set heroSelectionAbilityTooltipText[i] = BlzFrameGetChild(heroSelectionAbilityTooltip[i], 1)
			
			set i = i + 1
		endloop
		
		call BlzFrameSetVisible(heroSelectionMenu, false)
		call NoCrash("InitMenu")
	endfunction

	//==========================================================================================================================================================
	//API
	//==========================================================================================================================================================

	function EveryoneHasHero takes nothing returns boolean
		return numPlayersWithHero == numSelectingPlayers
	endfunction

	function NoOneInHeroSelection takes nothing returns boolean
		return numPlayersInSelection == 0
	endfunction

	function EnablePlayerHeroSelection takes player whichPlayer, boolean enable returns nothing
		local integer i
		local integer P = GetPlayerId(whichPlayer)

		if not isInHeroSelection[P] then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Attempted to enable hero selection for player who is not in hero selection...")
			endif
			return
		endif

		call InitCrashCheck("EnablePlayerHeroSelection")
		
		if enable then
			if localPlayerId == P then
				call BlzFrameSetVisible(heroSelectionMenu, true)
				call BlzFrameSetVisible(heroInfo, true)
				set i = 1
				loop
					exitwhen i > PAGE_UP
					call SetButtonTextures(i, false)
					set i = i + 1
				endloop
			endif
			static if PHANTOM_HERO_WHEN_CANNOT_BE_PICKED then
				call BlzSetSpecialEffectColor(selectedHero[localPlayerId], 255, 255, 255 )
				call BlzSetSpecialEffectAlpha(selectedHero[localPlayerId], 255 )
			endif
		else
			if localPlayerId == P then
				set i = 1
				loop
					exitwhen i > NUMBER_OF_ABILITY_FRAMES
					call BlzFrameSetVisible(heroSelectionAbility[i], false )
					set i = i + 1
				endloop
			
				set i = 1
				loop
					exitwhen i > PAGE_UP
					call SetButtonTextures(i, true)
					set i = i + 1
				endloop

				call BlzFrameSetEnable(heroAcceptButton, false)
			endif
			
			static if PHANTOM_HERO_WHEN_CANNOT_BE_PICKED then
				call BlzSetSpecialEffectColor(selectedHero[localPlayerId], 0, 0, 0 )
				call BlzSetSpecialEffectAlpha(selectedHero[localPlayerId], 128 )
			endif
			set preselectedHeroIndex[P] = 0
		endif
		set heroSelectionDisabledForPlayer[P] = not enable

		call NoCrash("EnablePlayerHeroSelection")
	endfunction

	function EnablePlayerHeroPreselection takes player whichPlayer, boolean enable returns nothing
		local integer i
		local integer P = GetPlayerId(whichPlayer)

		if not isInHeroSelection[P] then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Attempted to enable hero preselection for player who is not in hero selection...")
			endif
			return
		endif

		call InitCrashCheck("EnablePlayerHeroPreselection")
		
		if enable then
			if GetLocalPlayer() == whichPlayer then
				set i = 1
				loop
					exitwhen i > PAGE_UP
					call SetButtonTextures(i, false)
					set i = i + 1
				endloop
			endif
		else
			if GetLocalPlayer() == whichPlayer then
				set i = 1
				loop
					exitwhen i > NUMBER_OF_ABILITY_FRAMES
					call BlzFrameSetVisible(heroSelectionAbility[i], false )
					set i = i + 1
				endloop
			
				set i = 1
				loop
					exitwhen i > PAGE_UP
					call SetButtonTextures(i, true)
					set i = i + 1
				endloop

				call BlzFrameSetVisible(heroSelectionButtonHighlight, false)
				call BlzFrameSetEnable(heroAcceptButton, false)
			endif
			
			call BlzSetSpecialEffectPosition(selectedHero[P], GARBAGE_DUMP_X, GARBAGE_DUMP_Y, 0)
			call DestroyEffect(selectedHero[P])
			call DestroyEffect(selectedHeroGlow[P])
			set preselectedHeroIndex[P] = 0
		endif
		set heroPreselectionDisabledForPlayer[P] = not enable

		call NoCrash("EnablePlayerHeroPreselection")
	endfunction

	function HeroSelectionAllRandom takes nothing returns nothing
		local integer i = 1
		local integer P
		local noArgCallback onAllRandom = HeroSelectionAllRandom

		if numPlayersInSelection == 0 then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Attempted to start hero ban phase, but no one is in hero selection right now...")
			endif
			return
		endif
		set storeHeroIndex = RANDOM_HERO
		set isForcedSelect = true
		loop
			exitwhen i > numSelectingPlayers
			set P = playerNumberOfSlot[i]
			if not playerHasHero[P] then
				set storePlayerIndex = P
				call PickHero()
			endif
			set i = i + 1
		endloop
		call onAllRandom.evaluate()
		set isForcedSelect = false
	endfunction

	function HeroSelectionPlayerForceSelect takes player whichPlayer, Hero whichHero returns nothing
		if not isInHeroSelection[GetPlayerId(whichPlayer)] then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Attempted to force select on a player who is not in hero selection...")
			endif
			return
		endif
		if playerHasHero[GetPlayerId(whichPlayer)] then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Attempted to force select on a player who already selected a hero...")
			endif
			return
		endif
		set isForcedSelect = true
		set storePlayerIndex = GetPlayerId(whichPlayer)
		set storeHeroIndex = whichHero.index
		call PickHero()
		set isForcedSelect = false
	endfunction

	function HeroSelectionPlayerForceRandom takes player whichPlayer returns nothing
		if not isInHeroSelection[GetPlayerId(whichPlayer)] then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Attempted to force random on a player who is not in hero selection...")
			endif
			return
		endif
		if playerHasHero[GetPlayerId(whichPlayer)] then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Attempted to force random on a player who already selected a hero...")
			endif
			return
		endif
		set isForcedSelect = true
		set storePlayerIndex = GetPlayerId(whichPlayer)
		set storeHeroIndex = RANDOM_HERO
		call PickHero()
		set isForcedSelect = false
	endfunction

	function HeroSelectionForceEnd takes nothing returns nothing
		local integer i = 1
		local integer P
		loop
			exitwhen i > numSelectingPlayers
			set P = playerNumberOfSlot[i]
			if not playerHasHero[P] then
				call HeroSelectionPlayerForceRandom(Player(P))
			endif
			set i = i + 1
		endloop
	endfunction

	function PlayerEscapeHeroSelection takes player whichPlayer, boolean isLoad returns nothing
		if not isInHeroSelection[GetPlayerId(whichPlayer)] then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				// call BJDebugMsg("|cffff0000Warning:|r Attempted to escape hero selection, but player is not in hero selection...")
			endif
			return
		endif
		call EscapePlayer(whichPlayer)
		// call EscapePlayerWithLoad(whichPlayer, isLoad)
	endfunction

	// function BanHeroFromSelectionForPlayer takes Hero whichHero, boolean disable, player whichPlayer returns nothing
	// 	call ExecuteBan(whichHero, disable, GetPlayerId(whichPlayer))
	// endfunction

	// function BanHeroFromSelection takes Hero whichHero, boolean disable returns nothing
	// 	call ExecuteBan(whichHero, disable, - 1)
	// endfunction

	function HeroSelectionSetTimeRemaining takes real time returns nothing
		call TimerStart(countdownTimer, time, false, function TimeExpires)
		call BlzFrameSetText(timerFrame, TIMER_TEXT + GetClockString(TimerGetRemaining(countdownTimer)))
		call BlzFrameSetVisible(timerFrame, isInHeroSelection[localPlayerId])
	endfunction

	function HeroSelectionAddTimeRemaining takes real time returns nothing
		call TimerStart(countdownTimer, TimerGetRemaining(countdownTimer) + time, false, function TimeExpires)
		call BlzFrameSetText(timerFrame, TIMER_TEXT + GetClockString(TimerGetRemaining(countdownTimer)))
		call BlzFrameSetVisible(timerFrame, isInHeroSelection[localPlayerId])
	endfunction
	
	function EnableHeroSelection takes nothing returns nothing
		local integer i
		local integer P
		local noArgCallback onEnable = HeroSelectionOnEnable

		if numPlayersInSelection == 0 then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Attempted to enable hero selection, but no one is in hero selection right now...")
			endif
			return
		endif

		call InitCrashCheck("EnableHeroSelection")

		// If any required frames are still null, touching them can crash the game.
		// Retry briefly instead of proceeding.
		if not HeroSelectionUIReady() then
			set enableHeroSelectionRetryAttempts = enableHeroSelectionRetryAttempts + 1
			if enableHeroSelectionRetryAttempts <= 200 then
				call TimerStart(enableHeroSelectionRetryTimer, 0.03, false, function EnableHeroSelection)
			else
				static if HERO_SELECTION_ENABLE_DEBUG_MODE then
					call BJDebugMsg("|cffff0000Warning:|r EnableHeroSelection UI not ready after retries.")
				endif
				set enableHeroSelectionRetryAttempts = 0
			endif
			return
		endif
		set enableHeroSelectionRetryAttempts = 0

		if TIME_LIMIT != 0 then
			call BlzFrameSetVisible(timerFrame, isInHeroSelection[localPlayerId])
			call TimerStart(countdownTimer, TIME_LIMIT, false, function TimeExpires)
			call TimerStart(countdownUpdateTimer, 1.0, true, function UpdateTimerFrame)
			call BlzFrameSetText(timerFrame, TIMER_TEXT + GetClockString(TimerGetRemaining(countdownTimer)))
		endif

		set i = 1
		loop
			exitwhen i > numSelectingPlayers
			set P = playerNumberOfSlot[i]
			if isInHeroSelection[P] then
				set heroSelectionDisabledForPlayer[P] = false
				set heroPreselectionDisabledForPlayer[P] = false
				set playerHasBan[P] = false
				if localPlayerId == P then
					call BlzFrameSetVisible(heroSelectionMenu, true)
					call BlzFrameSetVisible(heroInfo, true)
				endif
			endif
			static if PLAYER_TEXT_TAGS then
				set backgroundHeroTextTag[P] = CreateTextTag()
				call SetTextTagText(backgroundHeroTextTag[P], coloredPlayerName[P], 0.023)
				call SetTextTagPos(backgroundHeroTextTag[P], BACKGROUND_HERO_X[P], BACKGROUND_HERO_Y[P], 25)
				call SetTextTagVisibility(backgroundHeroTextTag[P], true)
			endif
			set i = i + 1
		endloop

		call BlzFrameSetVisible(heroAcceptButton, true )
		call BlzFrameSetVisible(heroBanButton, false )
		call BlzFrameSetEnable(heroBanButton, false )
		
		set captionAlphaMultiplier = 1
		if HERO_SELECTION_CAPTION != null then
			call BlzFrameSetVisible(captionFrame, isInHeroSelection[localPlayerId])
			if CAPTION_COLOR_1 != CAPTION_COLOR_2 or CAPTION_ALPHA_1 != CAPTION_ALPHA_2 then
				call AnimateCaption()
			endif
		endif
		
		if HeroCanBePicked(preselectedHeroIndex[localPlayerId], localPlayerId) then
			call BlzFrameSetEnable(heroAcceptButton, true )
			static if PHANTOM_HERO_WHEN_CANNOT_BE_PICKED then
				call BlzSetSpecialEffectColor(selectedHero[localPlayerId], 255, 255, 255 )
				call BlzSetSpecialEffectAlpha(selectedHero[localPlayerId], 255 )
			endif
		endif

		set inBanPhase = false
		
		set i = 1
		loop
			exitwhen i > NUMBER_OF_HEROES
			call SetButtonTextures(i, not HeroCanBePicked(i, localPlayerId))
			set i = i + 1
		endloop
		
		call SetButtonTextures(RANDOM_HERO, false)
		call SetButtonTextures(SUGGEST_RANDOM, false)
		call SetButtonTextures(PAGE_DOWN, false)
		call SetButtonTextures(PAGE_UP, false)

		call onEnable.evaluate()

		call NoCrash("EnableHeroSelection")
	endfunction

	function StartHeroSelectionTimer takes real timeout, code callback returns nothing
		call TimerStart(countdownTimer, timeout, false, callback)
		call BlzFrameSetVisible(timerFrame, isInHeroSelection[localPlayerId])
		call TimerStart(countdownUpdateTimer, 1.0, true, function UpdateTimerFrame)
		call BlzFrameSetText(timerFrame, TIMER_TEXT + GetClockString(TimerGetRemaining(countdownTimer)))
	endfunction

	// function StartHeroBanPhase takes real timeLimit returns nothing
	// 	local integer i = 1
	// 	local integer P

	// 	if numPlayersInSelection == 0 then
	// 		static if HERO_SELECTION_ENABLE_DEBUG_MODE then
	// 			call BJDebugMsg("|cffff0000Warning:|r Attempted to start hero ban phase, but no one is in hero selection right now...")
	// 		endif
	// 		return
	// 	endif

	// 	call InitCrashCheck("StartHeroBanPhase")

	// 	loop
	// 		exitwhen i > numSelectingPlayers
	// 		set P = playerNumberOfSlot[i]
	// 		set playerHasBan[P] = true
	// 		set heroPreselectionDisabledForPlayer[P] = false
	// 		if localPlayerId == P then
	// 			call BlzFrameSetVisible(heroSelectionMenu, true)
	// 			call BlzFrameSetVisible(heroInfo, true)
	// 		endif
	// 		set i = i + 1
	// 	endloop

	// 	set inBanPhase = true

	// 	set i = 1
	// 	loop
	// 		exitwhen i > NUMBER_OF_HEROES
	// 		call SetButtonTextures(i, not HeroCanBePicked(i, localPlayerId))
	// 		set i = i + 1
	// 	endloop

	// 	call SetButtonTextures(SUGGEST_RANDOM, false)
	// 	call SetButtonTextures(PAGE_DOWN, false)
	// 	call SetButtonTextures(PAGE_UP, false)

	// 	call BlzFrameSetVisible(heroAcceptButton, false)
	// 	call BlzFrameSetVisible(heroBanButton, true)

	// 	call BlzFrameSetEnable(heroBanButton, HeroCanBePicked(preselectedHeroIndex[localPlayerId], localPlayerId) and preselectedHeroIndex[P] != RANDOM_HERO )
	// 	call StartHeroSelectionTimer(timeLimit, function EnableHeroSelection)

	// 	call NoCrash("StartHeroBanPhase")
	// endfunction

	function PlayerReturnToHeroSelection takes player whichPlayer returns nothing
		local integer i
		local integer P = GetPlayerId(whichPlayer)
		local integer id
		local playerCallback onReturn = HeroSelectionOnReturn
		local framehandle consoleUIBackdrop = BlzGetFrameByName("ConsoleUIBackdrop", 0)
		local framehandle bottomUI = BlzGetFrameByName("ConsoleBottomBar", 0)
		local framehandle topUI = BlzGetFrameByName("ConsoleTopBar", 0)

		if heroSelectionMenu == null then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Attempted to return player to hero selection, but hero selection was not initialized...")
			endif
			return
		endif

		call InitCrashCheck("PlayerReturnToHeroSelection")

		set playerHasHero[P] = false
		set isInHeroSelection[P] = true
		set isRepicking[P] = true
		set numPlayersWithHero = numPlayersWithHero - 1
		set numPlayersInSelection = numPlayersInSelection + 1
		set heroIndexWasPicked[pickedHeroIndex[P]] = false
		set pickedHeroIndex[P] = 0

		static if not DELETE_BACKGROUND_HEROES_AFTER_END then
			call BlzSetSpecialEffectPosition(backgroundHero[P], GARBAGE_DUMP_X, GARBAGE_DUMP_Y, 0)
			call DeleteBackgroundHero(P)
		endif

		set i = 1
		loop
			exitwhen i > NUMBER_OF_HEROES
			call SetButtonTextures(i, not HeroCanBePicked(Hero.list[i], localPlayerId))
			set i = i + 1
		endloop

		call SetButtonTextures(RANDOM_HERO, false)
		call SetButtonTextures(SUGGEST_RANDOM, false)
		call SetButtonTextures(PAGE_DOWN, false)
		call SetButtonTextures(PAGE_UP, false)

		if localPlayerId == P then
			call ClearSelection()
			call BlzFrameSetVisible(heroSelectionMenu, true)
			call BlzFrameSetVisible(heroInfo, true)
			call BlzFrameSetVisible(heroSelectionButtonHighlight, false )
			static if HIDE_GAME_UI then
				call BlzHideOriginFrames(true)
				call BlzFrameSetAllPoints(BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0))
				call BlzFrameSetVisible(consoleUIBackdrop, false)
				call BlzFrameSetVisible(bottomUI, false)
				call BlzFrameSetVisible(topUI, false)
			endif
			
			call BlzFrameSetText(titleText, "Select a Hero")
			call BlzFrameSetVisible(regionText, false)
			set i = 0
			loop
				exitwhen i > 5
				call BlzFrameSetVisible(g_buttons[i], false)
				call BlzFrameSetVisible(inventoryIconFrames[i], false)
				set i = i + 1
			endloop
		endif

		static if CREATE_SHADOWS then
			call RemoveDestructable(foregroundHeroShadow)
			if preselectedHeroIndex[localPlayerId] == 0 or playerHasHero[localPlayerId] then
				set id = NO_SHADOW_DESTRUCTABLE_ID
			else
				set id = SHADOW_DESTRUCTABLE_ID
			endif
			set foregroundHeroShadow = CreateDestructable(id, localForegroundHeroX, localForegroundHeroY, 0, 1, 0)
		endif

		static if ENFORCE_CAMERA then
			call TimerStart(lockCameraTimer, 0.01, true, function LockSelecterCamera)
		endif

		call onReturn.evaluate(whichPlayer)

		call NoCrash("PlayerReturnToHeroSelection")
	endfunction
	
	function BeginHeroSelection takes nothing returns nothing
		local integer i = 1
		local integer P
		local noArgCallback onBegin = HeroSelectionOnBegin

		if heroSelectionMenu == null then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Attempted to begin hero selection, but hero selection was not initialized...")
			endif
			return
		endif

		call InitCrashCheck("BeginHeroSelection")

		static if HIDE_GAME_UI then
			call BlzHideOriginFrames(true)
			call BlzFrameSetAllPoints(BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0))
			call BlzFrameSetVisible(BlzGetFrameByName("ConsoleUIBackdrop", 0), false)
			call BlzFrameSetVisible(BlzGetFrameByName("ConsoleBottomBar", 0), false)
			call BlzFrameSetVisible(BlzGetFrameByName("ConsoleTopBar", 0), false)
		endif

		loop
			exitwhen i > numSelectingPlayers
			set P = playerNumberOfSlot[i]
			set isInHeroSelection[P] = true
			set numPlayersInSelection = numPlayersInSelection + 1
			if localPlayerId == P then
				call ClearSelection()
			endif
			set i = i + 1
		endloop

		static if CREATE_SHADOWS then
			set foregroundHeroShadow = CreateDestructable(NO_SHADOW_DESTRUCTABLE_ID, localForegroundHeroX, localForegroundHeroY, 0, 1, 0)
		endif

		static if SHOW_MENU_BEFORE_ENABLED then
			call BlzFrameSetVisible(heroSelectionMenu, true)
			call BlzFrameSetVisible(heroInfo, true)
		endif
		call BlzFrameSetVisible(heroSelectionButtonHighlight, false )

		static if ENFORCE_CAMERA then
			call TimerStart(lockCameraTimer, 0.01, true, function LockSelecterCamera)
		endif

		call onBegin.evaluate()

		call NoCrash("BeginHeroSelection")
	endfunction

	function RestartHeroSelection takes nothing returns nothing
		local integer i = 1
		local integer j
		local integer P
		local noArgCallback onRestart = HeroSelectionOnRestart

		if heroSelectionMenu == null then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Attempted to restart hero selection, but hero selection was not initialized...")
			endif
			return
		endif

		if numPlayersInSelection > 0 then
			static if HERO_SELECTION_ENABLE_DEBUG_MODE then
				call BJDebugMsg("|cffff0000Warning:|r Attempted to restart hero selection while there are players in hero selection...")
			endif
			return
		endif

		call InitCrashCheck("RestartHeroSelection")
		
		call onRestart.evaluate()

		loop
			exitwhen i > numSelectingPlayers
			set P = playerNumberOfSlot[i]
			set playerHasHero[P] = false
			set playerHasBan[P] = false
			set isInHeroSelection[P] = false
			set heroSelectionDisabledForPlayer[P] = true
			set pickedHeroIndex[P] = 0

			static if CREATE_BACKGROUND_HEROES and not DELETE_BACKGROUND_HEROES_AFTER_END then
				call BlzSetSpecialEffectPosition(backgroundHero[P], GARBAGE_DUMP_X, GARBAGE_DUMP_Y, 0)
				call DeleteBackgroundHero(P)
			endif
			set i = i + 1
		endloop

		set i = 1
		loop
			exitwhen i > NUMBER_OF_HEROES
			set heroIndexWasPicked[i] = false
			set j = 1
			loop
				exitwhen j > numSelectingPlayers
				set P = playerNumberOfSlot[i]
				set heroIndexWasBanned[i][j] = false
				set j = j + 1
			endloop
			set i = i + 1
		endloop

		set numPlayersWithHero = 0
		set numPlayersInSelection = 0

		call NoCrash("RestartHeroSelection")

		call BeginHeroSelection()
	endfunction

	function InitHeroSelection takes nothing returns nothing
		local integer i = 0
		local integer j
		local integer P
		local trigger leaveTrigger = CreateTrigger()
		local integer array teamSize
		local integer array slotInTeam
		local location tempLoc
		local real array cameraTargetPositionX
		local real array cameraTargetPositionY
		local real cameraEyePositionX
		local real cameraEyePositionY

		call InitCrashCheck("InitHeroSelection")

		call InitFullScreenParents()

		set GARBAGE_DUMP_X = GetRectMaxX(GetPlayableMapRect())
		set GARBAGE_DUMP_Y = GetRectMaxY(GetPlayableMapRect())

		set localPlayerId = GetPlayerId(GetLocalPlayer())
		call HeroSelectionInitPlayers()
		call HeroSelectionSetPlayerColors()

		//Player List
		set i = 0
		loop
			exitwhen i > 23
			static if not AUTO_SET_SELECTING_PLAYERS then
				if PLAYER_SELECTS_HERO[i] and GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
					set numSelectingPlayers = numSelectingPlayers + 1
					set playerNumberOfSlot[numSelectingPlayers] = i
					set coloredPlayerName[i] = PLAYER_COLOR[i] + GetPlayerName(Player(i)) + "|r"
					set heroPreselectionDisabledForPlayer[i] = not PRE_SELECT_BEFORE_ENABLED
					set heroSelectionDisabledForPlayer[i] = true
					if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
						set playerIsHuman[i] = true
						set numSelectingHumans = numSelectingHumans + 1
						call TriggerRegisterPlayerEvent(leaveTrigger, Player(i), EVENT_PLAYER_LEAVE)
					endif

					set j = 1
					loop
						exitwhen j > NUMBER_OF_HEROES
						set heroIndexWasBanned[j][i] = false
						set j = j + 1
					endloop
				endif
			else
				if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER then
					set numSelectingPlayers = numSelectingPlayers + 1
					set playerNumberOfSlot[numSelectingPlayers] = i
					set coloredPlayerName[i] = PLAYER_COLOR[i] + GetPlayerName(Player(i)) + "|r"
					set heroPreselectionDisabledForPlayer[i] = not PRE_SELECT_BEFORE_ENABLED
					set heroSelectionDisabledForPlayer[i] = true
					set playerIsHuman[i] = true
					set numSelectingHumans = numSelectingHumans + 1
					call TriggerRegisterPlayerEvent(leaveTrigger, Player(i), EVENT_PLAYER_LEAVE)

					set j = 1
					loop
						exitwhen j > NUMBER_OF_HEROES
						set heroIndexWasBanned[j][i] = false
						set j = j + 1
					endloop
				endif
			endif
			set i = i + 1
		endloop

		set NUMBER_OF_TEAMS = 0
		set i = 1
		loop
			exitwhen i > numSelectingPlayers
			set NUMBER_OF_TEAMS = IMaxBJ(NUMBER_OF_TEAMS, TEAM_OF_PLAYER[playerNumberOfSlot[i]])
			set i = i + 1
		endloop

		//Foreground hero locations are asynchronous. Background hero locations are not.
		static if SEPARATE_LOCATIONS_FOR_EACH_TEAM then
			call HeroSelectionInitArrays()
			set localForegroundHeroX = TEAM_FOREGROUND_HERO_X[TEAM_OF_PLAYER[localPlayerId]]
			set localForegroundHeroY = TEAM_FOREGROUND_HERO_Y[TEAM_OF_PLAYER[localPlayerId]]
			set localHeroSelectionAngle = TEAM_HERO_SELECTION_ANGLE[TEAM_OF_PLAYER[localPlayerId]]

			set i = 1
			loop
				exitwhen i > NUMBER_OF_TEAMS
				set cameraTargetPositionX[i] = TEAM_FOREGROUND_HERO_X[i] + Cos(Deg2Rad(TEAM_FOREGROUND_HERO_X[i])) * CAMERA_TARGET_OFFSET + Sin(Deg2Rad(TEAM_HERO_SELECTION_ANGLE[i])) * CAMERA_PERPENDICULAR_OFFSET
				set cameraTargetPositionY[i] = TEAM_FOREGROUND_HERO_Y[i] + Sin(Deg2Rad(TEAM_FOREGROUND_HERO_Y[i])) * CAMERA_TARGET_OFFSET - Cos(Deg2Rad(TEAM_HERO_SELECTION_ANGLE[i])) * CAMERA_PERPENDICULAR_OFFSET
				set i = i + 1
			endloop
		else
			set localForegroundHeroX = FOREGROUND_HERO_X
			set localForegroundHeroY = FOREGROUND_HERO_Y
			set localHeroSelectionAngle = HERO_SELECTION_ANGLE

			set i = 1
			loop
				exitwhen i > NUMBER_OF_TEAMS
				set cameraTargetPositionX[i] = FOREGROUND_HERO_X + Cos(Deg2Rad(localHeroSelectionAngle)) * CAMERA_TARGET_OFFSET + Sin(Deg2Rad(HERO_SELECTION_ANGLE)) * CAMERA_PERPENDICULAR_OFFSET
				set cameraTargetPositionY[i] = FOREGROUND_HERO_Y + Sin(Deg2Rad(localHeroSelectionAngle)) * CAMERA_TARGET_OFFSET - Cos(Deg2Rad(HERO_SELECTION_ANGLE)) * CAMERA_PERPENDICULAR_OFFSET
				set i = i + 1
			endloop
		endif

		call TriggerAddAction(leaveTrigger, function OnPlayerLeave)
		set leaveTrigger = null

		call SetCategories()
		call HeroDeclaration()

		set NUMBER_OF_HEROES = Hero.numHeroes
		set RANDOM_HERO = NUMBER_OF_HEROES + 1
		set SUGGEST_RANDOM = NUMBER_OF_HEROES + 2
		set PAGE_DOWN = NUMBER_OF_HEROES + 3
		set PAGE_UP = NUMBER_OF_HEROES + 4

		set i = 1
		loop
			exitwhen i > NUMBER_OF_HEROES
			set j = 0
			loop
				set j = j + 1
				exitwhen Hero.list[i].abilities[j] == 0
			endloop
			if j - 1 > NUMBER_OF_ABILITY_FRAMES then
				set NUMBER_OF_ABILITY_FRAMES = j - 1
			endif

			if Hero.list[i].category > NUMBER_OF_CATEGORIES then
				set NUMBER_OF_CATEGORIES = Hero.list[i].category
			endif

			call Hero.list[i].GetValues()

			set i = i + 1
		endloop

		set i = 1
		loop
			exitwhen i > NUMBER_OF_CATEGORIES
			set NUMBER_OF_PAGES = IMaxBJ(NUMBER_OF_PAGES, PAGE_OF_CATEGORY[i])
			set i = i + 1
		endloop

		//Camera
		call CameraSetupSetField(heroSelectionCamera, CAMERA_FIELD_ZOFFSET, CAMERA_Z_OFFSET, 0.0)
		call CameraSetupSetField(heroSelectionCamera, CAMERA_FIELD_ANGLE_OF_ATTACK, 360 - CAMERA_PITCH, 0.0)
		call CameraSetupSetField(heroSelectionCamera, CAMERA_FIELD_TARGET_DISTANCE, CAMERA_DISTANCE, 0.0)
		call CameraSetupSetField(heroSelectionCamera, CAMERA_FIELD_ROLL, 0.0, 0.0)
		call CameraSetupSetField(heroSelectionCamera, CAMERA_FIELD_FIELD_OF_VIEW, CAMERA_FIELD_OF_VIEW, 0.0)
		call CameraSetupSetField(heroSelectionCamera, CAMERA_FIELD_FARZ, 7500.0, 0.0)
		call CameraSetupSetField(heroSelectionCamera, CAMERA_FIELD_ROTATION, localHeroSelectionAngle, 0.0)
		call CameraSetupSetDestPosition(heroSelectionCamera, cameraTargetPositionX[TEAM_OF_PLAYER[localPlayerId]], cameraTargetPositionY[TEAM_OF_PLAYER[localPlayerId]], 0.0)

		//Background Heroes
		set i = 1
		loop
			exitwhen i > numSelectingPlayers
			set P = playerNumberOfSlot[i]
			set teamSize[TEAM_OF_PLAYER[P]] = teamSize[TEAM_OF_PLAYER[P]] + 1
			set slotInTeam[P] = teamSize[TEAM_OF_PLAYER[P]]
			set i = i + 1
		endloop

		set i = 1
		loop
			exitwhen i > numSelectingPlayers
			set P = playerNumberOfSlot[i]
			set tempLoc = GetPlayerBackgroundHeroLocation(P, i, numSelectingPlayers, TEAM_OF_PLAYER[P], slotInTeam[P], teamSize[TEAM_OF_PLAYER[P]])
			static if SEPARATE_LOCATIONS_FOR_EACH_TEAM then
				set cameraEyePositionX = cameraTargetPositionX[TEAM_OF_PLAYER[P]] - Cos(Deg2Rad(CAMERA_PITCH)) * Cos(Deg2Rad(TEAM_HERO_SELECTION_ANGLE[TEAM_OF_PLAYER[P]])) * CAMERA_DISTANCE
				set cameraEyePositionY = cameraTargetPositionY[TEAM_OF_PLAYER[P]] - Cos(Deg2Rad(CAMERA_PITCH)) * Sin(Deg2Rad(TEAM_HERO_SELECTION_ANGLE[TEAM_OF_PLAYER[P]])) * CAMERA_DISTANCE
				set BACKGROUND_HERO_X[P] = cameraEyePositionX - Sin(Deg2Rad(TEAM_HERO_SELECTION_ANGLE[TEAM_OF_PLAYER[P]])) * GetLocationX(tempLoc) + Cos(Deg2Rad(TEAM_HERO_SELECTION_ANGLE[TEAM_OF_PLAYER[P]])) * GetLocationY(tempLoc)
				set BACKGROUND_HERO_Y[P] = cameraEyePositionY + Cos(Deg2Rad(TEAM_HERO_SELECTION_ANGLE[TEAM_OF_PLAYER[P]])) * GetLocationX(tempLoc) + Sin(Deg2Rad(TEAM_HERO_SELECTION_ANGLE[TEAM_OF_PLAYER[P]])) * GetLocationY(tempLoc)
			else
				set cameraEyePositionX = cameraTargetPositionX[TEAM_OF_PLAYER[P]] - Cos(Deg2Rad(CAMERA_PITCH)) * Cos(Deg2Rad(HERO_SELECTION_ANGLE)) * CAMERA_DISTANCE
				set cameraEyePositionY = cameraTargetPositionY[TEAM_OF_PLAYER[P]] - Cos(Deg2Rad(CAMERA_PITCH)) * Sin(Deg2Rad(HERO_SELECTION_ANGLE)) * CAMERA_DISTANCE
				set BACKGROUND_HERO_X[P] = cameraEyePositionX - Sin(Deg2Rad(HERO_SELECTION_ANGLE)) * GetLocationX(tempLoc) + Cos(Deg2Rad(HERO_SELECTION_ANGLE)) * GetLocationY(tempLoc)
				set BACKGROUND_HERO_Y[P] = cameraEyePositionY + Cos(Deg2Rad(HERO_SELECTION_ANGLE)) * GetLocationX(tempLoc) + Sin(Deg2Rad(HERO_SELECTION_ANGLE)) * GetLocationY(tempLoc)
			endif
			call RemoveLocation(tempLoc)
			set i = i + 1
		endloop
		set tempLoc = null

		//Caption
		set captionFrame = BlzCreateFrameByType("TEXT", "captionFrame", BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), "", 0)
		call BlzFrameSetVisible(captionFrame, false)
		call BlzFrameSetEnable(captionFrame, false)
		call BlzFrameSetSize(captionFrame, 0.4, 0.05)
		call BlzFrameSetAbsPoint(captionFrame, FRAMEPOINT_CENTER, CAPTION_X, CAPTION_Y)
		call BlzFrameSetText(captionFrame, CAPTION_COLOR_1 + HERO_SELECTION_CAPTION + "|r")
		call BlzFrameSetTextAlignment(captionFrame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
		call BlzFrameSetScale(captionFrame, CAPTION_FONT_SIZE / 10.)
		call BlzFrameSetAlpha(captionFrame, CAPTION_ALPHA_1)

		//Timer
		set timerFrame = BlzCreateFrameByType("TEXT", "timerFrame", BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), "", 0)
		call BlzFrameSetVisible(timerFrame, false)
		call BlzFrameSetEnable(timerFrame, false)
		call BlzFrameSetSize(timerFrame, 0.15, 0.05)
		call BlzFrameSetAbsPoint(timerFrame, FRAMEPOINT_CENTER, TIMER_X, TIMER_Y)
		call BlzFrameSetTextAlignment(timerFrame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
		call BlzFrameSetScale(timerFrame, TIMER_FONT_SIZE / 10.)

		call NoCrash("InitHeroSelection")
		
		// Initialize reset confirmation dialogs
		set i = 0
		loop
			exitwhen i >= 24
			set resetConfirmDialog[i] = DialogCreate()
			call TriggerRegisterDialogEvent(resetDialogTrigger, resetConfirmDialog[i])
			set i = i + 1
		endloop
		call TriggerAddAction(resetDialogTrigger, function OnResetDialogButtonClick)
		
		// call InitRegionPanel()
		// call CreateCustomFrame()
		call InitMenu()
	endfunction
	
endlibrary