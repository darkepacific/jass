library CustomFrameDemo initializer Init
    // This library creates a custom frame with three buttons that have associated category text.
    // Each button is created as a GLUETEXTBUTTON, with its icon children used for displaying a fully-stretched texture.
    // The buttons highlight on hover and selection, with the first button auto‑selected.

    globals
        // Arrays for our category text and button handles.
        private framehandle titleText
        private framehandle array g_categoryText[3]
        private framehandle array g_buttons[3]
        private framehandle array g_buttonsIcon[3]
        private framehandle array g_buttonsIconClicked[3]
        // To keep track of which button is currently selected.
        integer g_SelectedIndex = 0
        // Define category names for each button.
        private string array REGION_NAMES[3]
        constant real MENU_CATEGORY_FONT_SIZE = 16	
    endglobals

    private function PlaySoundLocal takes string soundPath, boolean localPlayerCanHearSound returns nothing
		local real volume
		local sound s = CreateSound( soundPath , FALSE, FALSE, FALSE, 10, 10, "DefaultEAXON")
		call SetSoundChannel(s, 0)
		if localPlayerCanHearSound then
			set volume = 100
		else
			set volume = 0
		endif
		call SetSoundVolumeBJ( s , volume )
		call StartSound(s)
		call KillSoundWhenDone(s)
		set s = null
	endfunction

    private function SetButtonFrames_l takes integer whichButton returns nothing
        // Retrieve the child frames of this button, which will be used for the textures.
        set g_buttonsIcon[whichButton] = BlzFrameGetChild(g_buttons[whichButton], 0)
        set g_buttonsIconClicked[whichButton] = BlzFrameGetChild(g_buttons[whichButton], 1)
        // Clear and set the points for the clicked icon so it fully covers the button.
        call BlzFrameClearAllPoints(g_buttonsIconClicked[whichButton])
        call BlzFrameSetPoint(g_buttonsIconClicked[whichButton], FRAMEPOINT_BOTTOMLEFT, g_buttons[whichButton], FRAMEPOINT_BOTTOMLEFT, 0.001, 0.001)
        call BlzFrameSetPoint(g_buttonsIconClicked[whichButton], FRAMEPOINT_TOPRIGHT, g_buttons[whichButton], FRAMEPOINT_TOPRIGHT, - 0.001, - 0.001)
    endfunction

    function SetButtonTextures_l takes integer i, string iconPath returns nothing
        // Set the texture for the button icon.
        if i == 0 then 
            call BlzFrameSetTexture(g_buttonsIcon[i], "dun_morogh.blp", 0, true)
            call BlzFrameSetTexture(g_buttonsIconClicked[i], "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNGryphonAviary.blp", 0, true)
        elseif i == 1 then
            call BlzFrameSetTexture(g_buttonsIcon[i], "westfall.blp", 0, true)
            call BlzFrameSetTexture(g_buttonsIconClicked[i], "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNFarm.blp", 0, true)
        elseif i == 2 then
            call BlzFrameSetTexture(g_buttonsIcon[i], "teldrassil.blp", 0, true)
            call BlzFrameSetTexture(g_buttonsIconClicked[i], "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNTreeOfAges.blp", 0, true)
        endif
    endfunction


    // Mouse-click event callback.
    function OnButtonClicked takes nothing returns nothing
        local framehandle btn = BlzGetTriggerFrame()
        local integer i = 0
        local player whichPlayer = GetTriggerPlayer()
		local integer P = GetPlayerId(whichPlayer)

		call PlaySoundLocal( "Sound\\Interface\\BigButtonClick.flac" , GetPlayerId(GetLocalPlayer()) == P )
        // Find which button was clicked and update the selection.
        loop
            exitwhen i >= 3
            if btn == g_buttons[i] then
                // Set the new selection index.
                set g_SelectedIndex = i
                // call BJDebugMsg("Selected Category: " + REGION_NAMES[i])
                call BlzFrameSetText(g_buttons[i], REGION_NAMES[i] + "|n(Selected)")
            else
                call BlzFrameSetText(g_buttons[i], REGION_NAMES[i])
            endif
            set i = i + 1
        endloop
    endfunction

    // Main function to create the custom frame with category buttons.
    function CreateCustomFrame takes nothing returns nothing
        local framehandle heroInformation
        local integer i = 0
        // Define frame dimensions using relative values.
        local real frameWidth = 0.14
        local real frameHeight = 0.12
        local trigger t
        local string defualtSelectionText

        // Create the main container frame using "ScriptDialog" as a base.
        set heroInformation = BlzCreateFrame("ScriptDialog", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)
        // Anchor heroInformation to the right side of the screen.
        call BlzFrameSetPoint(heroInformation, FRAMEPOINT_RIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), FRAMEPOINT_RIGHT, - 0.0, 0.06)
        // Set the size of the main frame to enclose 3 buttons.
        call BlzFrameSetSize(heroInformation, frameWidth + 0.03, frameHeight * 3 + 0.03 + 0.06)

        // Set up the category names.
        set REGION_NAMES[0] = "Khaz Modan"
        set REGION_NAMES[1] = "Arathi Highlands"
        set REGION_NAMES[2] = "Teldrassil"

        set titleText = BlzCreateFrameByType("TEXT", "titleText", heroInformation, "", 0)
        call BlzFrameSetPoint(titleText, FRAMEPOINT_TOPLEFT, heroInformation, FRAMEPOINT_TOPLEFT, 0, 0)
        call BlzFrameSetPoint(titleText, FRAMEPOINT_BOTTOMRIGHT, heroInformation, FRAMEPOINT_TOPLEFT, frameWidth - 0.03, - 0.055)
        call BlzFrameSetText(titleText, "|cffffcc00Starting Zone|r")
        call BlzFrameSetTextAlignment(titleText, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
        call BlzFrameSetScale(titleText, MENU_CATEGORY_FONT_SIZE / 10)
        call BlzFrameSetVisible(titleText, true)

        loop
            exitwhen i >= 3

            // Create a GLUETEXTBUTTON for the actual button.
            set g_buttons[i] = BlzCreateFrameByType("GLUETEXTBUTTON", "heroSelectionButton_" + I2S(i), heroInformation, "ScriptDialogButton", 0)
            // Set the size of the button.
            call BlzFrameSetSize(g_buttons[i], frameWidth, frameHeight)
            // Position the button using relative offsets (adjust as needed).
            call BlzFrameSetPoint(g_buttons[i], FRAMEPOINT_TOPLEFT, heroInformation, FRAMEPOINT_TOPLEFT, 0.015, -(i * frameHeight) - 0.015 - 0.05)
            call BlzFrameSetVisible(g_buttons[i], true)

            // Set the text on the button.
            if i == 0 then
                set defualtSelectionText = "|n(Default)"
            else
                set defualtSelectionText = ""
            endif
            call BlzFrameSetText(g_buttons[i], REGION_NAMES[i] + defualtSelectionText)

            call SetButtonFrames_l(i)

            // Set the textures on the icon child frames.
            call SetButtonTextures_l(i, "")

            set t = CreateTrigger()
            call BlzTriggerRegisterFrameEvent(t, g_buttons[i], FRAMEEVENT_CONTROL_CLICK)
            call TriggerAddAction(t, function OnButtonClicked)

            set i = i + 1
        endloop

        // Auto-select the first button by highlighting it.
        set g_SelectedIndex = 0
    endfunction

    private function Init takes nothing returns nothing
        // Delay creation slightly to ensure all systems are ready.
        call TimerStart(CreateTimer(), 0.01, false, function CreateCustomFrame)
    endfunction

endlibrary
