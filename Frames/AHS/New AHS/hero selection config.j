library HeroSelectionConfig requires optional NeatMessages

	//=================================================================================================================================
	//These constants determine important aspects of the hero selection. You can fine-tune visuals, sounds etc. further down below.
	//=================================================================================================================================

	globals
		constant boolean HERO_SELECTION_ENABLE_DEBUG_MODE	= true					//Printout errors and check for function crashes.
	
		//Overall behavior.
		constant boolean HERO_CAN_BE_PICKED_MULTIPLE_TIMES	= false                 //Set to true if the same hero should be able to be picked multiple times.
		constant boolean AUTO_SET_SELECTING_PLAYERS			= false					//Set to true if hero selection should be enabled for all human players. Set to false if you want to set the player list manually (which can include computer players).
		constant boolean COMPUTER_AUTO_PICK_RANDOM_HERO		= false					//Set to true if computer players that are in hero selection should automatically pick a random hero after all human players have picked.
		constant boolean ESCAPE_PLAYER_AFTER_SELECTING		= true                 //Set to true if a player picking a hero should kick him or her out of the hero selection menu and camera.
		constant boolean CONCEAL_HERO_PICKS_FROM_ENEMIES    = false                 //Set to true if hero picks should be concealed from enemies (players in another team or all players if there are no teams), including emote, effect, and text messages.
		constant boolean MENU_INCLUDE_RANDOM_PICK			= false					//Include button for picking a random hero at the bottom of the menu.
		constant boolean MENU_INCLUDE_SUGGEST_RANDOM		= true					//Include button to pre-select a random hero next to the random pick button.
		constant real TIME_LIMIT							= 0						//Set a time limit after which players who haven't chosen a hero will be assigned one at random. Set to 0 for no time limit. 

		//Camera and foreground hero positions (background hero locations are set in GetPlayerBackgroundHeroLocation).
		constant boolean SEPARATE_LOCATIONS_FOR_EACH_TEAM	= false					//Set to true if each team gets a different selection screen (all following values will be ignored and you have to set the array equivalents in InitArrays).
		constant real FOREGROUND_HERO_X						= -16385//-128					//x-Position of foreground hero.
		constant real FOREGROUND_HERO_Y						= -13910//256					//y-Position of foreground hero.
		constant real HERO_SELECTION_ANGLE					= 180//0						//Hero selection viewing direction of camera (0 = facing east, 90 = facing north etc.).
		constant real FOREGROUND_HERO_Z						= 0								//z-Position of foreground hero.
		//You just need to enable vision for where the starting area is.

		//Visuals.
		constant boolean ENFORCE_CAMERA						= true					//Set to false if players' camera should not be changed during hero selection.
		constant boolean HIDE_GAME_UI                       = true                  //Set to true if all UI elements other than the hero selection menu should be hidden.
		constant boolean CREATE_FOREGROUND_HERO				= true					//Set to false if no foreground hero should appear on preselection.
		constant boolean CREATE_BACKGROUND_HEROES      		= false                  //Set to true if players should be able to see other players' picks in the background.
	endglobals

	//=================================================================================================================================

	globals
		string array CATEGORY_NAMES							//Names of the hero categories that appear in the hero selection menu.
		integer array PAGE_OF_CATEGORY						//Set the page at which that category appears within the menu. When there is more than one page, page cycle buttons appear in the menu.
		boolean array PLAYER_SELECTS_HERO					//List of all players that are supposed to participate in hero selection (true = participates).
		integer array TEAM_OF_PLAYER						//Team of player, 1, 2 etc. 0 = no teams.
		string array PLAYER_COLOR							//Hex color string (including "|cff") for each player.
	endglobals

	function SetCategories takes nothing returns nothing
		//Set the names of the categories in the hero selection menu. Starts at index 1. Set to null for no category caption.
		set CATEGORY_NAMES[1]						= "|cffffcc00Death Knight|r"
		set CATEGORY_NAMES[2]						= "|cffffcc00Demon Hunter|r"
		set CATEGORY_NAMES[3]						= "|cffffcc00Druid|r"
		set CATEGORY_NAMES[4]						= "|cffffcc00Hunter|r"
		set CATEGORY_NAMES[5]						= "|cffffcc00Mage|r"
		set CATEGORY_NAMES[6]						= "|cffffcc00Monk|r"
		set CATEGORY_NAMES[7]						= "|cffffcc00Paladin|r"
		set CATEGORY_NAMES[8]						= "|cffffcc00Priest|r"
		set CATEGORY_NAMES[9]						= "|cffffcc00Rogue|r"
		set CATEGORY_NAMES[10]						= "|cffffcc00Shaman|r"
		set CATEGORY_NAMES[11]						= "|cffffcc00Warlock|r"
		set CATEGORY_NAMES[12]						= "|cffffcc00Warrior|r"
		// set CATEGORY_NAMES[13]						= "|cffffcc00Extra|r"
		// set CATEGORY_NAMES[1]						= "|cffffcc00Warrior|r"
		// set CATEGORY_NAMES[2]						= "|cffffcc00Paladin|r"
		// set CATEGORY_NAMES[3]						= "|cffffcc00Hunter|r"
		// set CATEGORY_NAMES[4]						= "|cffffcc00Rogue|r"
		// set CATEGORY_NAMES[5]						= "|cffffcc00Priest|r"
		// set CATEGORY_NAMES[6]						= "|cffffcc00Shaman|r"
		// set CATEGORY_NAMES[7]						= "|cffffcc00Mage|r"
		// set CATEGORY_NAMES[8]						= "|cffffcc00Warlock|r"
		// set CATEGORY_NAMES[9]						= "|cffffcc00Druid|r"
		// set CATEGORY_NAMES[10]						= "|cffffcc00Death Knight|r"
		// set CATEGORY_NAMES[11]						= "|cffffcc00Monk|r"
		// set CATEGORY_NAMES[12]						= "|cffffcc00Demon Hunter|r"
		// set CATEGORY_NAMES[13]						= "|cffffcc00Extra|r"

		//Set the pages of the categories in the hero selection menu. Pages start at 1.
		set PAGE_OF_CATEGORY[1]						= 1
		set PAGE_OF_CATEGORY[2]						= 1
		set PAGE_OF_CATEGORY[3]						= 1
		set PAGE_OF_CATEGORY[4]						= 1
		set PAGE_OF_CATEGORY[5]						= 1
		set PAGE_OF_CATEGORY[6]						= 1
		set PAGE_OF_CATEGORY[7]						= 2
		set PAGE_OF_CATEGORY[8]						= 2
		set PAGE_OF_CATEGORY[9]						= 2
		set PAGE_OF_CATEGORY[10]					= 2
		set PAGE_OF_CATEGORY[11]					= 2
		set PAGE_OF_CATEGORY[12]					= 2
		// set PAGE_OF_CATEGORY[13]					= 3
	endfunction

	function HeroSelectionInitPlayers takes nothing returns nothing	
		//Set the list of players for which hero selection is enabled (only if AUTO_SET_SELECTING_PLAYERS = false). It is disabled here because computer players must be added to the hero selection.
		set PLAYER_SELECTS_HERO[0]					= false
		set PLAYER_SELECTS_HERO[1]					= false
		set PLAYER_SELECTS_HERO[2]					= true
		set PLAYER_SELECTS_HERO[3]					= false
		set PLAYER_SELECTS_HERO[4]					= true
		set PLAYER_SELECTS_HERO[5]					= true
		set PLAYER_SELECTS_HERO[6]					= true
		set PLAYER_SELECTS_HERO[7]					= true
		set PLAYER_SELECTS_HERO[8]					= true
		set PLAYER_SELECTS_HERO[9]					= true
		set PLAYER_SELECTS_HERO[10]					= true
		set PLAYER_SELECTS_HERO[11]					= false
	
		//Set the teams of players. Players with team 0 are enemies to all players.
		set TEAM_OF_PLAYER[0]						= 1
		set TEAM_OF_PLAYER[1]						= 2
		set TEAM_OF_PLAYER[2]						= 2
		set TEAM_OF_PLAYER[3]						= 1
		set TEAM_OF_PLAYER[4]						= 1
		set TEAM_OF_PLAYER[5]						= 1
		set TEAM_OF_PLAYER[6]						= 1
		set TEAM_OF_PLAYER[7]						= 2
		set TEAM_OF_PLAYER[8]						= 2
		set TEAM_OF_PLAYER[9]						= 2
		set TEAM_OF_PLAYER[10]						= 1
		set TEAM_OF_PLAYER[11]						= 2
	endfunction

	//=================================================================================================================================

	globals
		real array TEAM_FOREGROUND_HERO_X					//x-Position of foreground hero.
		real array TEAM_FOREGROUND_HERO_Y					//y-Position of foreground hero.
		real array TEAM_HERO_SELECTION_ANGLE				//Hero selection camera yaw in degrees (0 = facing east, 90 = facing north etc.).
	endglobals

	function HeroSelectionInitArrays takes nothing returns nothing
		//If you set SEPARATE_LOCATIONS_FOR_EACH_TEAM = true, initialize the above array variables here.
		set TEAM_FOREGROUND_HERO_X[1] = -128
		set TEAM_FOREGROUND_HERO_Y[1] = 256
		set TEAM_HERO_SELECTION_ANGLE[1] = 0
		set TEAM_FOREGROUND_HERO_X[2] = -128
		set TEAM_FOREGROUND_HERO_Y[2] = 256
		set TEAM_HERO_SELECTION_ANGLE[2] = 0
	endfunction
	
	function GetPlayerBackgroundHeroLocation takes integer playerIndex, integer whichSlot, integer numberOfPlayers, integer whichTeam, integer slotInTeam, integer teamSize returns location
		local real deltaHorizontal
		local real deltaVertical

		//=================================================================================================================================
		/*
		CREATE_BACKGROUND_HEROES only.
		Here you can customize the positions of the background heroes. Init loops through and calls this function for each player.

		Input:
		playerIndex
		whichSlot 				The position of the player when enumerating all players for which hero selection is enabled.
		numberOfPlayers 		The number of players for which hero selection is enabled.
		whichTeam 				The team the player is assigned to. Discard if there are no teams.
		slotInTeam 				The position of that player within his or her team. Discard if there are no teams.
		teamSize 				The size of the player's team. Discard if there are no teams.

		Output:
		deltaVertical			The distance between the background hero and the camera eye position along the camera viewing direction.
		deltaHorizontal			The offset between the background hero and the camera eye position perpendicular to the camera viewing direction.
		*/
		//==================================================================================================================================

		//Example code:
		local real angle
		local real dist
		local real BACKGROUND_HERO_OFFSET_BACKROW = 1050//1425
		local real BACKGROUND_HERO_OFFSET_FRONTROW = 850//1250

		if teamSize == 1 then
			set angle = 9
			set dist = BACKGROUND_HERO_OFFSET_BACKROW
		elseif slotInTeam == 1 then
			set angle = 5
			set dist = BACKGROUND_HERO_OFFSET_BACKROW
		elseif slotInTeam == 2 then
			set angle = 13
			set dist = BACKGROUND_HERO_OFFSET_BACKROW
		elseif slotInTeam == 3 then
			set angle = 17
			set dist = BACKGROUND_HERO_OFFSET_FRONTROW
		elseif slotInTeam == 4 then
			set angle = 21
			set dist = BACKGROUND_HERO_OFFSET_BACKROW
		else
			set angle = 9
			set dist = BACKGROUND_HERO_OFFSET_FRONTROW
		endif
		
		if whichTeam == 2 then
			set angle = -angle
		endif

		set deltaHorizontal = Sin(Deg2Rad(angle))*dist
		set deltaVertical = Cos(Deg2Rad(angle))*dist

		//==================================================================================================================================

		return Location(deltaHorizontal, deltaVertical)
	endfunction



	//==================================================================================================================================
	//													F I N E - T U N I N G
	//==================================================================================================================================



	globals
		//How hero selection looks like before it is enabled (you can ignore this if you plan on enabling hero selection right away).
		constant boolean SHOW_MENU_BEFORE_ENABLED			= false					//Set to true if players should be able to see the hero selection menu before hero selection is enabled.
		constant boolean PRE_SELECT_BEFORE_ENABLED          = false                 //Set to true if players should be able to pre-select heroes before hero selection is enabled.
		
		//Camera setup (ENFORCE_CAMERA).
		constant real CAMERA_PITCH							= 0//12					//Hero selection camera angle of attack in degrees. 0 = facing horizon, 90 = facing ground.
		constant real CAMERA_DISTANCE						= 1300					//Hero selection camera distance from camera target.
		constant real CAMERA_TARGET_OFFSET					= 500					//Distance between foreground hero and camera target. Positive = Camera target is behind the hero.
		constant real CAMERA_PERPENDICULAR_OFFSET			= 0//-10						//Shifts the camera left (negative) or right (positive) with respect to the foreground hero.
		constant real CAMERA_Z_OFFSET						= 80//100					//Hero selection camera z-offset.
		constant real CAMERA_FIELD_OF_VIEW					= 70					//Hero selection camera field of view.

		//Sounds and visuals of hero pre-selection (CREATE_FOREGROUND_HERO).
		constant string PRESELECT_EFFECT					= null					//Special effect played on the hero's position for the triggering player when switching to a new hero during pre-selection. Set to null for no effect.
		constant boolean PLAY_EMOTE_ON_PRESELECT			= true                  //Set to true if the hero should play its selection emote when the player switches to that hero during pre-selection.
		constant boolean PLAY_ANIMATION_ON_PRESELECT		= true                  //Set to true if the hero should play the selection animation when the player switches to that hero during pre-selection.
		constant boolean PHANTOM_HERO_WHEN_CANNOT_BE_PICKED	= true					//Set to true if a hero should be black and transparent when it is pre-selected but cannot be picked.
		// constant real FOREGROUND_HERO_Z						= 100						//z-Position of foreground hero.

		//Sounds and visuals on hero pick.
		constant string PICK_EFFECT							= "HolyLight.mdx"		//Special effect played on the hero's position for the triggering player when picking a hero. Set to null for no effect.
		constant string PICK_SOUND							= "Sound\\Interface\\ItemReceived.flac"	//Sound effect played for the triggering player when selecting a hero. Set to null for no sound.
		constant boolean PLAY_EMOTE_ON_PICK					= false                 //Set to true if a hero should play its selection emote when a player chooses that hero.
		constant boolean PLAY_ANIMATION_ON_PICK				= false                 //Set to true if a hero should play the selection animation when a player chooses that hero.
		constant real PLAYER_PICK_ESCAPE_DELAY				= 2.5					//Delay between selecting a hero and being kicked out of hero selection (ESCAPE_PLAYER_AFTER_SELECTING).
		constant real FOREGROUND_HERO_FADEOUT_DELAY			= 1.0                   //The time it takes for the foreground hero to start fading out after being selected.
		constant real FOREGROUND_HERO_FADEOUT_TIME			= 1.5                   //The time it takes for the foreground hero to fade out after being selected.
		constant string OTHER_PLAYER_HERO_PICK_SOUND		= "Sound\\Interface\\InGameChatWhat1.flac"	//Sound played when another player picks a hero. Set to null for no sound.
		
		//Text messages on hero pick.
		constant boolean CREATE_TEXT_MESSAGE_ON_PICK		= true					//Set to true if a text message should be sent to all other players when a hero is picked (except to enemies when concealed).
		constant real TEXT_MESSAGE_X_OFFSET					= 0.35					//x-Offset of text messages from default. Text messages will still suck. Recommend using NeatMessages.
		constant real TEXT_MESSAGE_Y_OFFSET					= 0						//y-Offset of text messages from default.
		constant boolean USE_HERO_PROPER_NAME				= false					//Instead of the hero's name, its proper name will be displayed in the text message. For example, "Uther" instead of "Paladin". Will temporarily create a hero to get the proper name.
		constant boolean MESSAGE_EVEN_WHEN_CONCEALED		= true					//Set to true if players should still get a message notifying that a player has picked a hero even when it is concealed which hero was picked (CONCEAL_HERO_PICKS_FROM_ENEMIES).
		constant boolean INCLUDE_PROGRESSION_IN_MESSAGE    	= false                 //Set to true if the displayed text message should include how many players have selected their hero.

		//Sounds and visuals of background heroes (CREATE_BACKGROUND_HEROES).
        constant boolean PLAYER_TEXT_TAGS                   = false                  //Create text tags that show the players' names over the background heroes.
		constant real BACKGROUND_HERO_FADEIN_TIME			= 1.0                   //The time it takes for the background hero to fade in after being selected.
		constant boolean PLAY_EMOTE_ON_BACKGROUND_HERO      = true                 	//Set to true if a hero should play its selection emote for all other players as it fades in.
		constant boolean PLAY_ANIMATION_ON_BACKGROUND_HERO  = true                  //Set to true if the background hero should play its selection animation as it fades in.
		constant string BACKGROUND_HERO_FADEIN_EFFECT       = "HolyLightRoyal.mdx"  //Special effect played on the background hero as it fades in.
		constant string BACKGROUND_HERO_SELF_HIGHLIGHT		= "RadianceHoly.mdx"	//Special effect added at the location of a player's own background hero to highlight it. Set to null for no highlight.
		constant real BACKGROUND_HERO_HIGHLIGHT_Z			= 70					//z-Position of background hero self highlight.
		constant real BACKGROUND_HERO_FACING_POINT_OFFSET	= -500					//Adjusts where the background heroes face. 0 = Background heroes will face the foreground hero. Negative value = Face a point closer to the camera. Positive value = Face a point further from the camera.
		constant string CONCEALED_HERO_EFFECT				= "Objects\\InventoryItems\\QuestionMark\\QuestionMark.mdl"	//Model for the background hero seen by a player for which the hero pick was concealed.

		//Last player picks a hero.
		constant real LAST_PLAYER_SELECT_END_DELAY			= 6.0					//The amount of time after the last player selects a hero and the hero selection ends (ignore if ESCAPE_PLAYER_AFTER_SELECTING)
		constant boolean DELETE_BACKGROUND_HEROES_AFTER_END	= false					//Set to false if background heroes should not get removed when hero selection ends. For example, when a player repicks, they are still there.

		//Layout of hero selection menu.
		constant integer MENU_NUMBER_OF_COLUMNS				= 3						//Number of hero buttons per row.
		constant real MENU_X_LEFT							= 0//0.68//0						//x-Position of left edge of hero selection menu.
		constant real MENU_X_RIGHT							= 0.8					//x-Position of right edge of hero selection menu.	
		constant real MENU_Y_TOP							= 0.585//0.55					//y-Position of top edge of hero selection menu.
		constant real MENU_BUTTON_SIZE						= 0.039					//Size of individual hero buttons.
		constant real MENU_LEFT_RIGHT_EDGE_GAP				= 0.02					//Gap between left and right edges of menu and first and last buttons.
		constant real MENU_TOP_EDGE_GAP						= 0.01//0.015					//Gap between top edge of menu and first button/first category title.
		constant real MENU_BOTTOM_EDGE_GAP					= 0.01//0.02					//Gap between bottom edge of menu and last button.
		constant real MENU_BUTTON_BUTTON_GAP				= 0.005					//Gap between two individual hero buttons.
		constant real MENU_CATEGORY_FONT_SIZE				= 16					//Font size of category titles.
		constant real MENU_CATEGORY_GAP						= 0.028					//Gap between buttons of two different categories.
		constant real MENU_CATEGORY_TITLE_Y					= -0.001				//y-Position shift between category title and center of gap between categories.
		constant real MENU_BORDER_TILE_SIZE					= 0.03					//This rounds up the width and height of the menu to an integer multiple of the specified number. This is useful if you're using a tiled border texture, so that there's no discontinuity in the texture.
																					//Value should be equal to BackdropCornerSize in the HeroSelectionMenu.fdf. Set to 0 to disable.
		constant real MENU_HEROES_RANDOM_GAP				= 0.02					//Additional gap between last hero button and random pick button.
		
		//Select button.
		constant string SELECT_BUTTON_TEXT					= "Accept"				//The text in the select hero button at the bottom of the menu.
		constant real SELECT_BUTTON_SCALE					= 1.0					//The scale of the select hero button at the bottom of the menu.
		constant real SELECT_BUTTON_WIDTH					= 0.092					//The width of the select hero button at the bottom of the menu.

		//Display of random options.
		constant string RANDOM_HERO_TOOLTIP					= "Choose a random hero."
		constant string SUGGEST_RANDOM_TOOLTIP				= "Suggest a random hero, but don't select it just yet."
		constant string RANDOM_HERO_ICON					= "ReplaceableTextures\\CommandButtons\\BTNRandomIncredibleIcon.blp"
		constant string SUGGEST_RANDOM_ICON					= "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp"
		constant boolean RANDOM_SELECT_CYCLE_STYLE			= true					//Set to true if the foreground hero should cycle randomly between different heroes while random hero is pre-selected. Set to false if a question mark should be shown.
		constant real RANDOM_SELECT_CYCLE_INTERVAL			= 0.2					//How fast the heroes are cycled through when random hero is pre-selected (RANDOM_SELECT_CYCLE_STYLE).
		
		//Layout of ability preview buttons.
		constant real HERO_ABILITY_PREVIEW_BUTTON_X			= 0.0//-0.22//0.0					//x-Position of topmost ability preview button relative to topright corner of menu.
		constant real HERO_ABILITY_PREVIEW_BUTTON_Y			= -0.016				//y-Position of topmost ability preview button relative to topright corner of menu.
		constant real HERO_ABILITY_PREVIEW_BUTTON_SIZE		= 0.04//0.025					//The size of the hero ability preview buttons that appear on the right side of the menu when pre-selecting a hero.
		constant boolean ABILITY_BUTTON_HORIZONTAL_LAYOUT	= false					//Set to true if ability preview buttons should be arranged horizontally instead of vertically.
		constant string HERO_ABILITY_LEVEL_DELIMITER		= " - ["				//To get the name of a hero ability without the level-text from the tooltip (such as "Stormbolt - [Level 1]" -> "Stormbolt"). This string is used to detect where the name of the ability ends. Change if ability names in tooltips are not correct. Set to null if not necessary.

		//Page cycle buttons (when multiple pages are set).
		constant string PAGE_CYCLE_BUTTON_STYLE				= "LeftVerticalButton"	//Set the page cycle button style. Styles are found in documentation.
		constant real MENU_PAGE_CYCLE_X_OFFSET				= 0.0					//x-Position of the page cycle buttons relative to the auto-position. Positive = moves inward. Negative = moves outward.
		constant real MENU_PAGE_CYCLE_Y_OFFSET				= 0.0					//y-Position of the page cycle up button relative to the auto-position.
		constant real MENU_PAGE_CYCLE_SCALE					= 1.0					//Sets the size of the page cycle buttons relative to hero buttons (for icon style buttons) or the accept button (for text style buttons).
		constant string MENU_PAGE_DOWN_ICON					= "ReplaceableTextures\\CommandButtons\\BTNCryptFiendBurrow.blp" //ArrowDown.blp" //NagaBurrow.blp"		//(for icon style buttons)
		constant string MENU_PAGE_UP_ICON					= "ReplaceableTextures\\CommandButtons\\BTNCryptFiendUnBurrow.blp" //ArrowUp.blp" //NagaUnBurrow.blp"	//(for icon style buttons)

		//Display of big caption.
		constant string HERO_SELECTION_CAPTION				= "Choose your Hero!"	//The text displayed on the screen during hero selection. Set null to omit text.
		constant real CAPTION_FONT_SIZE						= 30					//Font size of hero selection caption.
		constant real CAPTION_X								= 0.4					//x-Position of caption center.
		constant real CAPTION_Y								= 0.41					//y-Position of caption center.
		constant string CAPTION_COLOR_1						= "|cffffcc00"			//Caption will cycle between color 1 and color 2. Set the same for no color cycling.
		constant string CAPTION_COLOR_2						= "|cffffffff"			//Caption will cycle between color 1 and color 2. Set the same for no color cycling.
		constant integer CAPTION_ALPHA_1					= 255					//Caption will cycle between alpha 1 and alpha 2. Set the same for no alpha cycling.
		constant integer CAPTION_ALPHA_2					= 255					//Caption will cycle between alpha 1 and alpha 2. Set the same for no alpha cycling.
		constant real CAPTION_CYCLE_TIME					= 4.0					//The time it takes for the caption to cycle between color 1/2 and alpha 1/2.
		constant real CAPTION_FADEOUT_TIME					= 2.0					//The time it takes for the caption to fade out after a player has picked a hero. Set to -1 for no fade out.
	
		//Position of hero button and ability preview button mouse-over tooltips.
		constant real TOOLTIP_LEFT_X                        = 0.27//0.51
		constant real TOOLTIP_Y                      		= 0.12//0.13
		constant boolean TOOLTIP_LOCK_TOP					= false					//Set to true if TOOLTIP_Y should refer to top instead of bottom edge.
		constant real TOOLTIP_WIDTH                         = 0.29

		//Display of countdown timer.
		constant string TIMER_TEXT							= "Time Remaining: |cffffcc00"	//Text before the time remaining display
		constant string TIMER_BAN_PHASE_TEXT				= "Ban Phase: |cffffcc00"		//Text before the time remaining display during the ban phase.
		constant real TIMER_FONT_SIZE						= 11					//Font size of the time remaining display.
		constant real TIMER_X								= 0.4					//x-Position of center of the time remaining display.
		constant real TIMER_Y								= 0.59					//y-Position of the center of the time remaining display.

		//Shadows of heroes.
		constant boolean CREATE_SHADOWS						= false					//Create shadows with destructables for heroes (since they are special effects and don't have shadows). Import destructables from showcase map to enable.
		constant integer SHADOW_DESTRUCTABLE_ID				= 'Dsha'				//Destructable id of the shadow that's created for heroes.
		constant integer NO_SHADOW_DESTRUCTABLE_ID			= 'Dnsh'				//Dummy destructable without a shadow.
	endglobals

	//=================================================================================================================================

	function HeroSelectionSetPlayerColors takes nothing returns nothing
		//Set the colors of players shown for their names in text messages.
		set PLAYER_COLOR[0] 						= "|cffff0402"
		set PLAYER_COLOR[1] 						= "|cff1052ff"
		set PLAYER_COLOR[2] 						= "|cff1BE6BA"
		set PLAYER_COLOR[3] 						= "|cff8530b1"
		set PLAYER_COLOR[4] 						= "|cfffffc00"
		set PLAYER_COLOR[5] 						= "|cffff8a0d"
		set PLAYER_COLOR[6] 						= "|cff20bf00"
		set PLAYER_COLOR[7]							= "|cffE35BAF"
		set PLAYER_COLOR[8]							= "|cff949697"
		set PLAYER_COLOR[9] 						= "|cff7EBFF1"
		set PLAYER_COLOR[10] 						= "|cff106247"
		set PLAYER_COLOR[11] 						= "|cff4F2B05"
		set PLAYER_COLOR[12] 						= "|cff9C0000"
		set PLAYER_COLOR[13] 						= "|cff0000C2"
		set PLAYER_COLOR[14] 						= "|cff00EBEB"
		set PLAYER_COLOR[15]						= "|cffBE00FF"
		set PLAYER_COLOR[16]						= "|cffECCC86"
		set PLAYER_COLOR[17] 						= "|cffF7A48B"
		set PLAYER_COLOR[18] 						= "|cffBFFF80"
		set PLAYER_COLOR[19] 						= "|cffDBB8EC"
		set PLAYER_COLOR[20] 						= "|cff4F4F55"
		set PLAYER_COLOR[21] 						= "|cffECF0FF"
		set PLAYER_COLOR[22] 						= "|cff00781E"
		set PLAYER_COLOR[23]						= "|cffA46F34"
	endfunction

endlibrary