library BetterDialogs initializer Init
    /*
    ===========================================================================================
                                        Better Dialogs
                                          by Antares
    
                    Create dialogs with button tooltips and cycle buttons.
            
                                        How to import:
 
    Copy this library into your map. Extract the .fdf files and the .toc file and import them
    into your map without a subfolder.
    
    The frame size values in the Config are designed to closely emulate the standard dialog.
    Edit them if you want to change the layout. You can also choose between standard tooltip 
    and escape menu style tooltips.
 
    You can change the values in the .fdf files, such as the border size (BackdropCornerSize),
    the tooltip text size (FrameFont), textbox position (SetPoint) etc. Preset values might
    not be appropriate for every race UI.
 
    ===========================================================================================
 
                                    How to create a dialog:

    Before creating a dialog, you have to create the data for the dialog buttons. Start with:

    local ButtonData myButtonData = InitButtonData()

    ButtonData is a container for the buttons you create for a dialog. Now create buttons and
    add them to the ButtonData container.

    local Button myButton = CreateButton(title, tooltip, callback)
    call AddButtonToData(myButtonData, myButton)

    or

    call CreateButtonForData(title, tooltip, callback, myButtonData)

    If the button shouldn't have a tooltip, pass null as the tooltip. If the button shouldn't
    have a callback, pass 0 as the callback.

    To create a cycle button, use:
    AddButtonCycleState(myButton, title, tooltip)
 
    The button callback is the function that is executed upon clicking the button. It is expected
    to be function with three arguments:
 
    function myCallback takes framehandle whichDialog, player whichPlayer, string buttonName returns nothing
 
    buttonName specifies the title of the button that was clicked. This allows you to use the
    same callback function for all buttons and execute the correct code based on which button
    was clicked. Alternatively, you can use a different callback function for each button.
    whichPlayer specifies the player that clicked the button.
 
    For cycling buttons, buttonName specifies the title that the button just cycled into.
 
    If the clicked button is supposed to close the associated dialog, include
    call CloseDialog(whichDialog)
    in the callback function.
 
    If a dialog is created for multiple players, each player sees a completely different copy of
    that dialog.

    The created ButtonData and Button structs will automatically be cleaned up when the dialog
    that is using them is closed for all players for which it was shown. You can disable this
    in the config.
 
    Examples are given in the test map.
 
    ===========================================================================================
    API
    ===========================================================================================
  
    CreateBetterDialogForPlayer takes player whichPlayer, string dialogTitle, ButtonData buttonData returns nothing
    CreateBetterDialogForForce takes force whichForce, string dialogTitle, ButtonData buttonData returns nothing
    CreateBetterDialogForAll takes string dialogTitle, ButtonData buttonData returns nothing
 
    CloseDialog takes framehandle whichDialog returns nothing
    CloseOpenDialogForPlayer takes player whichPlayer returns nothing
    GetOpenDialogOfPlayer takes player whichPlayer returns framehandle
    SaveAndHideOpenDialogForPlayer takes player whichPlayer returns framehandle
    ShowDialogToPlayer takes framehandle whichDialog, player whichPlayer

    InitButtonData takes nothing returns ButtonData
    CreateButton takes string title, string tooltip, buttonCallback callback returns Button
    AddButtonToData takes ButtonData whichButtonData, Button whichButton returns nothing
    CreateButtonForData takes string title, string tooltip, buttonCallback callback, ButtonData whichButtonData returns Button
    AddButtonCycleState takes Button whichButton, string title, string tooltip returns nothing
    RemoveButtonData takes ButtonData whichButtonData returns nothing
 
    ===========================================================================================*/
 
	globals
		//===========================================================================================
		//CONFIG
		//===========================================================================================	

		private constant real DIALOG_X                          = 0.4       //X-position of dialog center.
		private constant real DIALOG_Y                          = 0.3       //Y-position of dialog center.
		private constant real DIALOG_WIDTH                      = 0.285     //Should be integer multiple of BackdropCornerSize
		private constant real DIALOG_BOTTOM_GAP                 = 0.045     //Gap between bottom of lowest button and bottom of dialog.
		private constant real DIALOG_BORDER_TILE_SIZE           = 0.0475    //Fixes height of dialog to integer multiple of this value to ensure that texture is tiled smoothly. (same behavior as normal dialog)
	 
		private constant real DIALOG_TITLE_Y_OFFSET             = -0.07     //Gap between top of dialog and dialog title.
	 
		private constant real BUTTON_HEIGHT                     = 0.035
		private constant real BUTTON_WIDTH                      = 0.225
		private constant real BUTTON_SPACING                    = 0.003     //Gap between buttons.
		private constant real BUTTON_Y_OFFSET                   = -0.07     //Gap between top of dialog and first button.
	 
		private constant real TOOLTIP_Y_OFFSET                  = -0.005    //Difference in y-position of top edge of dialog and tooltip.
		private constant real TOOLTIP_WIDTH                     = 0.244     //Should be integer multiple of BackdropCornerSize
		private constant real TOOLTIP_FRAME_HEIGHT_BUFFER       = 0.045     //Difference in height between tooltip border and tooltip text box.
		private constant string TOOLTIP_STYLE                   = "EscMenu" //"EscMenu" or "Tooltip"
	 
		private constant boolean AUTO_CLEANUP_BUTTON_DATA       = true
	 
		//===========================================================================================
	 
		private constant real BUTTON_X_OFFSET                   = (DIALOG_WIDTH - BUTTON_WIDTH)/2
	 
		private framehandle array CurrentlyOpenDialog
		private hashtable hash                                  = InitHashtable()
		private boolean cleanUp                                 = false

		private integer BUTTON_KEY                              = 0
		private integer TOOLTIP_KEY                             = 1
		private integer STATE_KEY                               = 2
		private integer TRIGGER_KEY                             = 3
		private integer BUTTON_DATA_KEY                         = 0
		private integer PLAYER_KEY                              = -1
	endglobals
	
	private function Init takes nothing returns nothing
		call BlzLoadTOCFile("BetterDialogTemplates.toc")
	endfunction

    function interface buttonCallback takes framehandle dialogParent, player whichPlayer, string buttonName returns nothing
 
    private function PlayButtonClickForPlayer takes player whichPlayer returns nothing
        local sound s = CreateSound("Sound\\Interface\\BigButtonClick.flac", false, false, false, 10, 10, "DefaultEAXON" )
        local real volume
        if GetLocalPlayer() == whichPlayer then
            set volume = 100
        else
            set volume = 0
        endif
        call SetSoundVolumeBJ(s, volume)
        call StartSound(s)
        call KillSoundWhenDone(s)
        set s = null
    endfunction

    struct Button
        string array title[12]
        integer numCycleStates
        string array tooltip[12]
        buttonCallback callback

        static method create takes string title, string tooltip, buttonCallback callback returns Button
            local Button this = Button.allocate()
            set .numCycleStates = 1
            set .title[1] = title
            set .tooltip[1] = tooltip
            set .callback = callback
            return this
        endmethod

        method AddCycleState takes string title, string tooltip returns Button
            set .numCycleStates = .numCycleStates + 1
            set .title[.numCycleStates] = title
            set .tooltip[.numCycleStates] = tooltip
            return this
        endmethod
    endstruct

    struct ButtonData
        Button array buttons[12]
        integer numButtons
        integer numReferences

        static method create takes nothing returns ButtonData
            local ButtonData this = ButtonData.allocate()
            set .numButtons = 0
            set .numReferences = 0
            return this
        endmethod

        method AddButton takes Button whichButton returns ButtonData
            set .numButtons = .numButtons + 1
            set .buttons[.numButtons] = whichButton
            return this
        endmethod

        method ReduceReference takes nothing returns nothing
            set .numReferences = .numReferences - 1
            static if AUTO_CLEANUP_BUTTON_DATA then
                if .numReferences <= 0 then
                    call .destroy()
                endif
            endif
        endmethod

        method onDestroy takes nothing returns nothing
            local integer i = 1
            loop
                exitwhen i > .numButtons
                call .buttons[i].destroy()
                set i = i + 1
            endloop
        endmethod
    endstruct

    private function ButtonClick takes nothing returns nothing
        local player whichPlayer = GetTriggerPlayer()
        local trigger whichTrigger = GetTriggeringTrigger()
        local framehandle whichFrame = BlzGetTriggerFrame()
        local framehandle dialogParent = BlzFrameGetParent(whichFrame)
        local Button whichButton = LoadInteger(hash, GetHandleId(whichFrame), BUTTON_KEY)
        local integer whichState = LoadInteger(hash, GetHandleId(whichFrame), STATE_KEY)
        local framehandle tooltip
        local framehandle tooltipText
          
        call PlayButtonClickForPlayer(whichPlayer)

        if whichButton.numCycleStates > 1 then
            set whichState = ModuloInteger(whichState, whichButton.numCycleStates) + 1
            call BlzFrameSetText(whichFrame, whichButton.title[whichState])
            call SaveInteger(hash, GetHandleId(whichFrame), STATE_KEY, whichState)
            
            set tooltip = LoadFrameHandle(hash, GetHandleId(whichFrame), TOOLTIP_KEY)
            set tooltipText = BlzFrameGetChild(tooltip, 0)
            call BlzFrameSetText(tooltipText, whichButton.tooltip[whichState])
            call BlzFrameSetSize(tooltipText, TOOLTIP_WIDTH - 0.045, 0.0)
            call BlzFrameSetSize(tooltip, TOOLTIP_WIDTH, BlzFrameGetHeight(tooltipText) + TOOLTIP_FRAME_HEIGHT_BUFFER)
            call whichButton.callback.evaluate(dialogParent, GetTriggerPlayer(), whichButton.title[whichState])
        else
            call whichButton.callback.evaluate(dialogParent, GetTriggerPlayer(), whichButton.title[whichState])
        endif
		
		set whichPlayer = null
        set whichTrigger = null
        set whichFrame = null
        set dialogParent = null
        set tooltip = null
        set tooltipText = null
    endfunction
 
    private function SetupDialog takes player whichPlayer, string dialogTitle, ButtonData buttonData returns nothing

        local integer i
        local integer numberOfButtons = buttonData.numButtons

        local real dialogHeightEstimate = -BUTTON_Y_OFFSET + DIALOG_BOTTOM_GAP + numberOfButtons*BUTTON_HEIGHT + (numberOfButtons-1)*BUTTON_SPACING
        local real dialogHeight = R2I(dialogHeightEstimate/DIALOG_BORDER_TILE_SIZE + 0.5)*DIALOG_BORDER_TILE_SIZE
        local real heightDifference = dialogHeight - dialogHeightEstimate

        local framehandle dialogParent
        local framehandle dialogTitleFrame
        local framehandle tooltipText
        local framehandle buttonFrame
        local trigger buttonTrigger
        local framehandle tooltip

        local Button whichButton

        local integer parentId
        local integer id

        //===========================================================================================
        //Setup Dialog Background
        //===========================================================================================
 
        set dialogParent = BlzCreateFrame("BetterDialog", BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), 0, 0) //-@type framehandle
        call BlzFrameSetAbsPoint(dialogParent, FRAMEPOINT_TOPLEFT , DIALOG_X - DIALOG_WIDTH/2 , DIALOG_Y + dialogHeight/2 )
        call BlzFrameSetAbsPoint(dialogParent, FRAMEPOINT_BOTTOMRIGHT , DIALOG_X + DIALOG_WIDTH/2 , DIALOG_Y - dialogHeight/2 )
        call BlzFrameSetVisible( dialogParent, true )
        set parentId = GetHandleId(dialogParent)

        //===========================================================================================
        //Setup Dialog Title
        //===========================================================================================
         
        set dialogTitleFrame = BlzCreateFrameByType("TEXT", "dialogTitle", dialogParent, "", 0) //-@type framehandle
        call BlzFrameSetText(dialogTitleFrame, dialogTitle)
        call BlzFrameSetScale(dialogTitleFrame, 1.6)
        call BlzFrameSetPoint(dialogTitleFrame, FRAMEPOINT_TOPLEFT, dialogParent, FRAMEPOINT_TOPLEFT, 0, 0)
        call BlzFrameSetPoint(dialogTitleFrame, FRAMEPOINT_BOTTOMRIGHT, dialogParent, FRAMEPOINT_TOPRIGHT, 0, DIALOG_TITLE_Y_OFFSET - heightDifference/2)
        call BlzFrameSetTextAlignment(dialogTitleFrame, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
 
        //===========================================================================================
 
        set i = 1
        loop
            exitwhen i > numberOfButtons

            set whichButton = buttonData.buttons[i]
 
            //===========================================================================================
            //Setup Dialog Button
            //===========================================================================================
 
            set buttonFrame = BlzCreateFrameByType("GLUETEXTBUTTON", whichButton.tooltip[1] , dialogParent, "ScriptDialogButton", 0)
            call BlzFrameSetText(buttonFrame, whichButton.title[1])
            call BlzFrameSetPoint( buttonFrame, FRAMEPOINT_TOPLEFT, dialogParent, FRAMEPOINT_TOPLEFT, BUTTON_X_OFFSET , BUTTON_Y_OFFSET - (i-1)*(BUTTON_HEIGHT + BUTTON_SPACING) - heightDifference/2 )
            call BlzFrameSetPoint( buttonFrame, FRAMEPOINT_BOTTOMRIGHT, dialogParent, FRAMEPOINT_TOPLEFT, BUTTON_X_OFFSET + BUTTON_WIDTH , BUTTON_Y_OFFSET - BUTTON_HEIGHT - (i-1)*(BUTTON_HEIGHT + BUTTON_SPACING) - heightDifference/2 )

            call SaveFrameHandle(hash, parentId, i, buttonFrame)

            //===========================================================================================
            //Setup Button Tooltip
            //===========================================================================================
 
            if whichButton.tooltip[1] != null then
                set tooltip = BlzCreateFrame("BetterDialogTooltip" + TOOLTIP_STYLE, BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), 0, 0)
                call BlzFrameSetAbsPoint( tooltip , FRAMEPOINT_TOPLEFT , DIALOG_X + DIALOG_WIDTH/2 , DIALOG_Y + dialogHeight/2 + TOOLTIP_Y_OFFSET )
                call BlzFrameSetTooltip(buttonFrame, tooltip )
                set tooltipText = BlzFrameGetChild(tooltip, 0)
                call BlzFrameSetText( tooltipText, whichButton.tooltip[1] )
                call BlzFrameSetSize( tooltipText , TOOLTIP_WIDTH - 0.045 , 0.0 )
                call BlzFrameSetSize(tooltip , TOOLTIP_WIDTH , BlzFrameGetHeight(tooltipText) + TOOLTIP_FRAME_HEIGHT_BUFFER)
            endif
 
            //===========================================================================================
            //Setup Callback Function
            //===========================================================================================
 
            set buttonTrigger = CreateTrigger()
            call BlzTriggerRegisterFrameEvent(buttonTrigger, buttonFrame, FRAMEEVENT_CONTROL_CLICK)
            call TriggerAddAction(buttonTrigger, function ButtonClick)

            set id = GetHandleId(buttonFrame)
            call SaveInteger(hash, id, BUTTON_KEY, whichButton)
            call SaveInteger(hash, id, STATE_KEY, 1)
            call SaveFrameHandle(hash, id, TOOLTIP_KEY, tooltip)
            call SaveTriggerHandle(hash, id, TRIGGER_KEY, buttonTrigger)

            set i = i + 1
        endloop
 
        //===========================================================================================
 
        set CurrentlyOpenDialog[GetPlayerId(whichPlayer)] = dialogParent
        call SavePlayerHandle(hash, GetHandleId(dialogParent), PLAYER_KEY, whichPlayer)
        call SaveInteger(hash, GetHandleId(dialogParent), BUTTON_DATA_KEY, buttonData)
        set buttonData.numReferences = buttonData.numReferences + 1

        call BlzFrameSetVisible(dialogParent, GetLocalPlayer() == whichPlayer)
		
		set dialogParent = null
        set dialogTitleFrame = null
        set tooltipText = null
        set buttonFrame = null
        set buttonTrigger = null
        set tooltip = null
    endfunction
 
    //===========================================================================================
    //API
    //===========================================================================================

    function InitButtonData takes nothing returns ButtonData
        return ButtonData.create()
    endfunction

    function AddButtonToData takes ButtonData whichButtonData, Button whichButton returns nothing
        call whichButtonData.AddButton(whichButton)
    endfunction
    
    function CreateButton takes string title, string tooltip, buttonCallback callback returns Button
        return Button.create(title, tooltip, callback)
    endfunction

    function AddButtonCycleState takes Button whichButton, string title, string tooltip returns nothing
        call whichButton.AddCycleState(title, tooltip)
    endfunction

    function CreateButtonForData takes string title, string tooltip, buttonCallback callback, ButtonData buttonData returns Button
        local Button newButton = Button.create(title, tooltip, callback)
        call buttonData.AddButton(newButton)
		return newButton
    endfunction

    function RemoveButtonData takes ButtonData buttonData returns nothing
        call buttonData.destroy()
    endfunction

    function CloseDialog takes framehandle whichDialog returns nothing
        local integer i = 1
        local framehandle buttonFrame
        local integer parentId
        local integer id
        local ButtonData buttonData

        if whichDialog == null then
            return
        endif

        set parentId = GetHandleId(whichDialog)

        loop
            set buttonFrame = LoadFrameHandle(hash, parentId, i)
            exitwhen buttonFrame == null
            set id = GetHandleId(buttonFrame)
            call DestroyTrigger(LoadTriggerHandle(hash, id, TRIGGER_KEY))
            call BlzDestroyFrame(LoadFrameHandle(hash, id, TOOLTIP_KEY))
            call FlushChildHashtable(hash, id)
            call BlzDestroyFrame(buttonFrame)
            set i = i + 1
        endloop

        set buttonData = LoadInteger(hash, parentId, BUTTON_DATA_KEY)
        call buttonData.ReduceReference()
        set CurrentlyOpenDialog[GetPlayerId(LoadPlayerHandle(hash, parentId, PLAYER_KEY))] = null
        call FlushChildHashtable(hash, parentId)
        call BlzDestroyFrame(whichDialog)
        set buttonFrame = null
    endfunction

    function CloseOpenDialogForPlayer takes player whichPlayer returns nothing
        call CloseDialog(CurrentlyOpenDialog[GetPlayerId(whichPlayer)])
    endfunction

    function CloseOpenDialogForAll takes nothing returns nothing
        local integer i = 0
		loop
            exitwhen i > 23
            if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                call CloseDialog(CurrentlyOpenDialog[GetPlayerId(Player(i))])
            endif
			set i = i + 1
        endloop
    endfunction
 
    function CreateBetterDialogForAll takes string dialogTitle, ButtonData buttonData returns nothing
        local integer i = 0
        loop
            exitwhen i > 23
            if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                call CloseDialog(CurrentlyOpenDialog[i])
                call SetupDialog(Player(i), dialogTitle, buttonData)
            endif
			set i = i + 1
        endloop
    endfunction
 
    function CreateBetterDialogForForce takes force whichForce, string dialogTitle, ButtonData buttonData returns nothing
        local integer i = 0
        loop
            exitwhen i > 23
            if IsPlayerInForce(Player(i), whichForce) then
                call CloseDialog(CurrentlyOpenDialog[i])
                call SetupDialog(Player(i), dialogTitle, buttonData)
            endif
			set i = i + 1
        endloop
    endfunction
 
    function CreateBetterDialogForPlayer takes player whichPlayer, string dialogTitle, ButtonData buttonData returns nothing
        call CloseDialog(CurrentlyOpenDialog[GetPlayerId(whichPlayer)])
        call SetupDialog(whichPlayer, dialogTitle, buttonData)
    endfunction

    function GetOpenDialogOfPlayer takes player whichPlayer returns framehandle
        return CurrentlyOpenDialog[GetPlayerId(whichPlayer)]
    endfunction
 
    function SaveAndHideOpenDialogForPlayer takes player whichPlayer returns framehandle
        local framehandle whichDialog = CurrentlyOpenDialog[GetPlayerId(whichPlayer)]
        if GetLocalPlayer() == whichPlayer then
            call BlzFrameSetVisible(whichDialog, false)
        endif
        set CurrentlyOpenDialog[GetPlayerId(whichPlayer)] = null
        return whichDialog
    endfunction
 
    function ShowDialogToPlayer takes framehandle whichDialog, player whichPlayer returns nothing
        call CloseOpenDialogForPlayer(whichPlayer)
        if GetLocalPlayer() == whichPlayer then
            call BlzFrameSetVisible(whichDialog, true)
        endif
        set CurrentlyOpenDialog[GetPlayerId(whichPlayer)] = whichDialog
    endfunction
 
    //===========================================================================================
endlibrary