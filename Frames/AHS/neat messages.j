library NeatMessages initializer Init

    /*
    ===========================================================================================
                                        Neat Text Messages
                                            by Antares
   
                Recreation of the default text messages with more customizability.
           
                                            How to import:
    Copy this library into your map. To get better looking messages with text shadow and an optional
    tooltip-like box around the text, copy the "NeatTextMessage.fdf" and "NeatMessageTemplates.toc" 
	files from the test map into your map without a subpath.
   
    Edit the parameters in the config section to your liking.
   
    Replace all DisplayTextToForce calls etc. with the appropriate function from this library.

    GUI users: You can use the REPLACE_BLIZZARD_FUNCTION_CALLS feature. This will replace all calls
    automatically. You don't need to do anything else. If you want to setup multiple message formats,
    copy the GUI globals into your map and look at how to setup custom formats with the examples provided
    in this map. This is not necessary if you want to stick exclusively to the message format you define
    in the config here.
   
    WARNING: Calling neat message functions (but not clear functions) from within local player code
    with REPLACE_BLIZZARD_FUNCTION_CALLS will cause a desync!
   
    Default text formatting can be overwritten by setting up NeatFormats. Examples are given in the
    test section. All formatting parameters that aren't set for a NeatFormat will use the default
    values instead.
   
    NeatMessage creator functions return an integer. This integer is a pointer to the created message
    that can be used to edit, extend, or remove the message. The returned integer is asynchronous
    and will be 0 for all players for whom the message isn't displayed.
   
    You can set up additional text windows with NeatWindow.create. If you create a neat message
    without specifying the window in which it should be created, it will always be created in the
    default window specified in the config. Additional windows are not available with the GUI
    features.

    ===========================================================================================
    API
    ===========================================================================================
   
    NeatMessage takes string whichMessage returns nothing
    NeatMessageToPlayer takes player whichPlayer, string whichMessage returns nothing
    NeatMessageToForce takes force whichForce, string whichMessage returns nothing
   
    NeatMessageTimed takes real duration, string whichMessage returns nothing
    NeatMessageToPlayerTimed takes player whichPlayer, real duration, string whichMessage returns nothing
    NeatMessageToForceTimed takes force whichForce, real duration, string whichMessage returns nothing
   
    NeatMessageFormatted takes string whichMessage, NeatFormat whichFormat returns nothing
    NeatMessageToPlayerFormatted takes player whichPlayer, string whichMessage, NeatFormat whichFormat returns nothing
    NeatMessageToForceFormatted takes force whichForce, string whichMessage, NeatFormat whichFormat returns nothing
   
    NeatMessageTimedFormatted takes real duration, string whichMessage, NeatFormat whichFormat returns nothing
    NeatMessageToPlayerTimedFormatted takes player whichPlayer, real duration, string whichMessage, NeatFormat whichFormat returns nothing
    NeatMessageToForceTimedFormatted takes force whichForce, real duration, string whichMessage, NeatFormat whichFormat returns nothing
   
    NeatMessageInWindow takes string whichMessage, NeatWindow whichWindow returns nothing
    NeatMessageToPlayerInWindow takes player whichPlayer, string whichMessage, NeatWindow whichWindow returns nothing
    NeatMessageToForceInWindow takes force whichForce, string whichMessage, NeatWindow whichWindow returns nothing
   
    NeatMessageTimedInWindow takes real duration, string whichMessage, NeatWindow whichWindow returns nothing
    NeatMessageToPlayerTimedInWindow takes player whichPlayer, real duration, string whichMessage, NeatWindow whichWindow returns nothing
    NeatMessageToForceTimedInWindow takes force whichForce, real duration, string whichMessage, NeatWindow whichWindow returns nothing
   
    NeatMessageFormattedInWindow takes string whichMessage, NeatFormat whichFormat, NeatWindow whichWindow returns nothing
    NeatMessageToPlayerFormattedInWindow takes player whichPlayer, string whichMessage, NeatFormat whichFormat, NeatWindow whichWindow returns nothing
    NeatMessageToForceFormattedInWindow takes force whichForce, string whichMessage, NeatFormat whichFormat, NeatWindow whichWindow returns nothing
   
    NeatMessageTimedFormattedInWindow takes real duration, string whichMessage, NeatFormat whichFormat, NeatWindow whichWindow returns nothing
    NeatMessageToPlayerTimedFormattedInWindow takes player whichPlayer, real duration, string whichMessage, NeatFormat whichFormat, NeatWindow whichWindow returns nothing
    NeatMessageToForceTimedFormattedInWindow takes force whichForce, real duration, string whichMessage, NeatFormat whichFormat, NeatWindow whichWindow returns nothing
   
    ===========================================================================================
   
    EditNeatMessage takes integer messagePointer, string newText returns nothing
    AddNeatMessageTimeRemaining takes integer messagePointer, real additionalTime returns nothing
    SetNeatMessageTimeRemaining takes integer messagePointer, real newTime returns nothing
    RemoveNeatMessage takes integer messagePointer returns nothing
    AutoSetNeatMessageTimeRemaining takes integer messagePointer, boolean accountForTimeElapsed returns nothing
    IsMessageDisplayed takes integer messagePointer returns boolean
   
    NeatMessageAddIcon takes integer messagePointer, real width, real height, string orientation, string texture
        (valid arguments for orientation are "topleft", "topright", "bottomleft", "bottomright")
    NeatMessageHideIcon takes integer messagePointer returns nothing
   
    ClearNeatMessages takes nothing returns nothing
    ClearNeatMessagesForPlayer takes player whichPlayer returns nothing
    ClearNeatMessagesForForce takes force whichForce returns nothing
    ClearNeatMessagesInWindow takes NeatWindow whichWindow returns nothing
    ClearNeatMessagesForPlayerInWindow takes player whichPlayer, NeatWindow whichWindow returns nothing
    ClearNeatMessagesForForceInWindow takes force whichForce, NeatWindow whichWindow returns nothing
   
    set myFormat = NeatFormat.create takes nothing returns NeatFormat
    set myFormat.spacing =
    set myFormat.fadeOutTime =
    set myFormat.fadeInTime =
    set myFormat.fontSize =
    set myFormat.minDuration =
    set myFormat.durationIncrease =
    set myFormat.verticalAlignment =
    set myFormat.horizontalAlignment =
    set myFormat.isBoxed =
    call myFormat.copy(copiedFormat)
   
    set myWindow = NeatWindow.create takes real xPosition, real yPosition, real width, real height, integer maxMessages, boolean topToBottom returns NeatWindow
   
    ===========================================================================================
    GUI API
    ===========================================================================================
   
    CreateNeatFormat takes string formatName returns nothing
    SetNeatFormat takes string formatName returns nothing
    ResetNeatVars takes nothing returns nothing
    ResetNeatFormat takes nothing returns nothing

    ===========================================================================================
    */

globals
    //=========================================================================================
    //Config
    //=========================================================================================
   
    //Default text formatting. Can be overwritten by setting up neatFormats.
    private constant real MESSAGE_MINIMUM_DURATION                 		= 2.5                    //Display duration of a message with zero characters.
    private constant real MESSAGE_DURATION_INCREASE_PER_CHARACTER  		= 0.12
    private constant real TEXT_MESSAGE_FONT_SIZE                   		= 14
    private constant real SPACING_BETWEEN_MESSAGES               		= 0.0
    private constant real FADE_IN_TIME                           		= 0.0
    private constant real FADE_OUT_TIME                           		= 1.8
    private constant textaligntype VERTICAL_ALIGNMENT                	= TEXT_JUSTIFY_MIDDLE    //TEXT_JUSTIFY_BOTTOM, TEXT_JUSTIFY_MIDDLE, or TEXT_JUSTIFY_TOP
    private constant textaligntype HORIZONTAL_ALIGNMENT           		= TEXT_JUSTIFY_CENTER    //TEXT_JUSTIFY_LEFT, TEXT_JUSTIFY_CENTER, or TEXT_JUSTIFY_RIGHT
    private constant boolean BOXED_MESSAGES                				= false                    //Create tooltip box around text messages? Requires .fdf file and INCLUDE_FDF enabled.
   
    //Default text window parameters.
    constant real TEXT_MESSAGE_X_POSITION                            = 0.225                    //0 = left, 1 = right (bottom-left corner)
    constant real TEXT_MESSAGE_Y_POSITION                             = 0.16                    //0 = bottom, 0.6 = top (bottom-left corner)
    constant real TEXT_MESSAGE_BLOCK_MAX_HEIGHT                     = 0.2                    //Maximum height of the entire text message block. Messages pushed out of that area will be removed.
    constant real TEXT_MESSAGE_BLOCK_WIDTH                            = 0.35
    constant integer MAX_TEXT_MESSAGES                                = 5                        //Maximum number of messages on the screen at the same time. If you want a non-scrolling window, simply set this number to 1.
    constant boolean MESSAGE_ORDER_TOP_TO_BOTTOM                    = false                    //Set true if new messages should appear above old messages.
   
    //Config
    private constant boolean INCLUDE_FDF                            = true                    //NeatMessage.fdf has been imported?
    private constant boolean COPY_TO_MESSAGE_LOG                    = true                    //(Only singleplayer) Copies messages to message log by printing out the message with DisplayTextToPlayer, then clearing all text. Will interfere with other default text messages.
    private constant boolean REPLACE_BLIZZARD_FUNCTION_CALLS        = false                    //Replaces Display(Timed)TextToForce, ClearTextMessages, and ClearTextMessagesBJ.
    private constant integer TOOLTIP_ABILITY                        = 'Amls'                //For REPLACE_BLIZZARD_FUNCTION_CALLS only. Any unused ability for which the library can change the tooltip to extract the TRIGSTR from.
   
    //=========================================================================================

    private boolean isSinglePlayer
    private timer masterTimer                                        = CreateTimer()
    private timer clearTextTimer                                     = CreateTimer()
    private integer numMessagesOnScreen                                = 0
    private boolean doNotClear                                        = false
    private integer messageCounter                                    = 0
    private integer array frameOfMessage
    private NeatWindow array windowOfMessage

    private constant real TIME_STEP                                    = 0.05

    NeatFormat DEFAULT_NEAT_FORMAT
    NeatWindow DEFAULT_NEAT_WINDOW
    private NeatWindow array neatWindow
    private integer numNeatWindows                                    = 0
endglobals

static if REPLACE_BLIZZARD_FUNCTION_CALLS then
    hook DisplayTextToForce DisplayTextToForceHook
    hook DisplayTimedTextToForce DisplayTimedTextToForceHook
    hook ClearTextMessagesBJ ClearNeatMessagesForForce
    hook ClearTextMessages ClearNeatMessages
endif

//=========================================================================================

private function ClearText takes nothing returns nothing
    set doNotClear = true
    call ClearTextMessages()
    set doNotClear = false
endfunction

private function GetAdjustedStringLength takes string whichString returns integer
    local integer rawLength = StringLength(whichString)
    local integer adjustedLength = rawLength
    local integer j = 0
    local string secondCharacter
    loop
    exitwhen j > rawLength - 10
        if SubString(whichString, j, j+1) == "|" then
            set secondCharacter = StringCase(SubString(whichString, j+1, j+2), false)
            if secondCharacter == "c" then
                set adjustedLength = adjustedLength - 10
                set j = j + 10
            elseif secondCharacter == "r" then
                set adjustedLength = adjustedLength - 2
                set j = j + 2
            endif
        else
            set j = j + 1
        endif
    endloop
    return adjustedLength
endfunction

private function ChangeTextFormatting takes NeatWindow w, integer whichFrame, NeatFormat whichFormat returns nothing
    if whichFormat == 0 then
        return
    endif
    set w.messageFormat[whichFrame] = whichFormat
    call BlzFrameSetScale(w.textCarryingFrame[whichFrame], whichFormat.fontSize/10.)
    call BlzFrameSetTextAlignment( w.textCarryingFrame[whichFrame], whichFormat.verticalAlignment, whichFormat.horizontalAlignment )
endfunction

globals
    NeatWindow myWindow
endglobals

private function ChangeText takes NeatWindow w, integer whichFrame, string whichText returns nothing
	local real height

    call BlzFrameSetText( w.textCarryingFrame[whichFrame] , whichText )
    if w.maxTextMessages == 1 then
        call BlzFrameSetSize( w.textCarryingFrame[whichFrame] , w.width / (w.messageFormat[whichFrame].fontSize/10.) , w.maxHeight / (w.messageFormat[whichFrame].fontSize/10.) )
    else
        call BlzFrameSetSize( w.textCarryingFrame[whichFrame] , w.width / (w.messageFormat[whichFrame].fontSize/10.) , 0 )
        call BlzFrameSetSize( w.textCarryingFrame[whichFrame] , w.width / (w.messageFormat[whichFrame].fontSize/10.) , 0 )
    endif

    static if INCLUDE_FDF then
        call BlzFrameSetSize( w.textMessageFrame[whichFrame] , BlzFrameGetWidth(w.textMessageText[whichFrame]) + 0.008 , BlzFrameGetHeight(w.textMessageText[whichFrame]) + 0.009 )
        call BlzFrameSetPoint( w.textMessageBox[whichFrame] , FRAMEPOINT_BOTTOMLEFT , w.textMessageFrame[whichFrame] , FRAMEPOINT_BOTTOMLEFT , 0 , -0.0007*(w.messageFormat[whichFrame].fontSize-13) )
        call BlzFrameSetPoint( w.textMessageBox[whichFrame] , FRAMEPOINT_TOPRIGHT , w.textMessageFrame[whichFrame] , FRAMEPOINT_TOPRIGHT , 0 , 0 )
        set myWindow = w
    endif
	
	if w.textMessageIconOrientation[whichFrame] != null then
		set height = BlzFrameGetHeight(w.textMessageIcon[whichFrame])
		if BlzFrameGetHeight( w.textMessageFrame[whichFrame] ) < height then
			call BlzFrameSetSize( w.textCarryingFrame[whichFrame] , w.width / (w.messageFormat[whichFrame].fontSize/10.) , height - 0.018 )
			static if INCLUDE_FDF then
				call BlzFrameSetSize( w.textMessageFrame[whichFrame] , BlzFrameGetWidth(w.textMessageText[whichFrame]) + 0.008 , BlzFrameGetHeight(w.textMessageText[whichFrame]) + 0.009 )
				call BlzFrameSetPoint( w.textMessageBox[whichFrame] , FRAMEPOINT_BOTTOMLEFT , w.textMessageFrame[whichFrame] , FRAMEPOINT_BOTTOMLEFT , 0 , -0.0007*(w.messageFormat[whichFrame].fontSize-13) )
				call BlzFrameSetPoint( w.textMessageBox[whichFrame] , FRAMEPOINT_TOPRIGHT , w.textMessageFrame[whichFrame] , FRAMEPOINT_TOPRIGHT , 0 , 0 )
			endif
			set w.textHeight[whichFrame] = BlzFrameGetHeight(w.textMessageFrame[whichFrame]) + RMaxBJ(w.messageFormat[whichFrame].spacing , w.messageFormat[whichFrame+1].spacing)
		endif
    endif

    if whichText == "" then
        call BlzFrameSetVisible( w.textMessageFrame[whichFrame] , false )
        call BlzFrameSetAlpha( w.textMessageFrame[whichFrame] , 255 )
    else
        call BlzFrameSetVisible( w.textMessageFrame[whichFrame] , true )
    endif
endfunction

private function HideTextMessage takes NeatWindow w, integer whichFrame, boolean collapseFrame returns nothing
    if BlzFrameGetText(w.textCarryingFrame[whichFrame]) != "" then
        set numMessagesOnScreen = numMessagesOnScreen - 1
    endif

    call ChangeText(w,whichFrame,"")
    set w.messageTimeRemaining[whichFrame] = 0
    set frameOfMessage[w.messageOfFrame[whichFrame]] = -1
    set w.messageOfFrame[whichFrame] = 0
    if collapseFrame then
        set w.textHeight[whichFrame] = 0
    endif
    if w.textMessageIconOrientation[whichFrame] != null then
        call BlzFrameSetVisible( w.textMessageIcon[whichFrame] , false )
        call BlzFrameSetAlpha( w.textMessageIcon[whichFrame] , 255 )
    endif
endfunction

private function FadeoutLoop takes nothing returns nothing
    local integer i
    local integer j = 1
    local real scale
    local NeatWindow w
   
    if numMessagesOnScreen == 0 then
        return
    endif
   
    loop
    exitwhen j > numNeatWindows
        set w = neatWindow[j]
        set i = 0
        loop
        exitwhen i == w.maxTextMessages
            if w.messageTimeRemaining[i] > 0 then
                set w.messageTimeRemaining[i] = w.messageTimeRemaining[i] - TIME_STEP
                set w.messageTimeElapsed[i] = w.messageTimeElapsed[i] + TIME_STEP
                if w.messageTimeRemaining[i] < w.messageFormat[i].fadeOutTime then
                    if w.messageTimeRemaining[i] < 0 then
                        call HideTextMessage(w,i,false)
                    else
                        call BlzFrameSetAlpha( w.textMessageFrame[i] , R2I(255*w.messageTimeRemaining[i]/w.messageFormat[i].fadeOutTime) )
                    endif
                elseif w.messageTimeElapsed[i] < w.messageFormat[i].fadeInTime then
                    call BlzFrameSetAlpha( w.textMessageFrame[i] , R2I(255*w.messageTimeElapsed[i]/w.messageFormat[i].fadeInTime) )
                endif
                if w.textMessageIconOrientation[i] != null then
                    call BlzFrameSetAlpha( w.textMessageIcon[i] , BlzFrameGetAlpha(w.textMessageFrame[i]) )
                endif
            endif
            set i = i + 1
        endloop
        set j = j + 1
    endloop
endfunction

private function RepositionAllMessages takes NeatWindow w returns nothing
    local integer i
    local real array yOffset
    local real textBlockHeight
    //=========================================================================================
    //Get message heights
    //=========================================================================================

    set yOffset[0] = 0
    set textBlockHeight = w.textHeight[0]
    set i = 1
    loop
    exitwhen i > w.maxTextMessages - 1
        set yOffset[i] = yOffset[i-1] + w.textHeight[i-1]
        if BlzFrameGetText(w.textCarryingFrame[i]) != "" then
            set textBlockHeight = RMinBJ( yOffset[i] + w.textHeight[i] , w.maxHeight )
        endif
        set i = i + 1
    endloop
   
    //=========================================================================================
    //Reposition messages
    //=========================================================================================

    set i = 0
    loop
    exitwhen i > w.maxTextMessages - 1
        if yOffset[i] + w.textHeight[i] > w.maxHeight then
            call HideTextMessage(w,i,true)
        elseif w.isTopToBottom then
            call BlzFrameSetAbsPoint( w.textMessageFrame[i] , FRAMEPOINT_BOTTOMLEFT , w.xPosition , w.yPosition - w.textHeight[i] - yOffset[i] )
        else
            call BlzFrameSetAbsPoint( w.textMessageFrame[i] , FRAMEPOINT_BOTTOMLEFT , w.xPosition , w.yPosition + yOffset[i] )
        endif
        set i = i + 1
    endloop
endfunction

private function AddTextMessage takes string whichText, real forcedDuration, NeatFormat whichFormat, NeatWindow w returns integer
    local integer i
    local real array yOffset
    local real textBlockHeight
    local framehandle tempFrame
   
    if whichText == "" then
        return 0
    endif
   
    static if COPY_TO_MESSAGE_LOG and not REPLACE_BLIZZARD_FUNCTION_CALLS then
        if isSinglePlayer then
            call DisplayTextToPlayer( GetLocalPlayer() , 0 , 0 , whichText + "
            " )
            call ClearTextMessages()
        endif
    endif
   
    if BlzFrameGetText(w.textCarryingFrame[w.maxTextMessages - 1]) == "" then
        set numMessagesOnScreen = numMessagesOnScreen + 1
    endif
   
    //=========================================================================================
    //Transfer messages to next frame
    //=========================================================================================
   
	set tempFrame = w.textMessageIcon[w.maxTextMessages - 1]
	if w.textMessageIconOrientation[w.maxTextMessages - 1] != null then
		call BlzFrameSetVisible( w.textMessageIcon[w.maxTextMessages - 1] , false )
		call BlzFrameSetAlpha( w.textMessageIcon[w.maxTextMessages - 1] , 255 )
	endif
   
    set i = w.maxTextMessages - 2
    loop
    exitwhen i < 0
        set w.messageTimeRemaining[i+1] = w.messageTimeRemaining[i]
        set w.messageTimeElapsed[i+1] = w.messageTimeElapsed[i]
		
        set w.textMessageIcon[i+1] = w.textMessageIcon[i]
        set w.textMessageIconOrientation[i+1] = w.textMessageIconOrientation[i]
        if w.textMessageIconOrientation[i] != null then
            if w.textMessageIconOrientation[i+1] == "topleft" then
                call BlzFrameSetPoint( w.textMessageIcon[i+1] , FRAMEPOINT_TOPRIGHT , w.textMessageFrame[i+1] , FRAMEPOINT_TOPLEFT , 0 , 0 )
            elseif w.textMessageIconOrientation[i+1] == "topright" then
                call BlzFrameSetPoint( w.textMessageIcon[i+1] , FRAMEPOINT_TOPLEFT , w.textMessageFrame[i+1] , FRAMEPOINT_TOPRIGHT , 0 , 0 )
            elseif w.textMessageIconOrientation[i+1] == "bottomleft" then
                call BlzFrameSetPoint( w.textMessageIcon[i+1] , FRAMEPOINT_BOTTOMRIGHT , w.textMessageFrame[i+1] , FRAMEPOINT_BOTTOMLEFT , 0 , 0 )
            elseif w.textMessageIconOrientation[i+1] == "bottomright" then
                call BlzFrameSetPoint( w.textMessageIcon[i+1] , FRAMEPOINT_BOTTOMLEFT , w.textMessageFrame[i+1] , FRAMEPOINT_BOTTOMRIGHT , 0 , 0 )
            endif
        endif
		
        call ChangeTextFormatting(w, i+1, w.messageFormat[i])
        set w.textHeight[i+1] = w.textHeight[i]
        call ChangeText(w, i+1, BlzFrameGetText(w.textCarryingFrame[i]))
        if w.messageOfFrame[i] != 0 then
            set w.messageOfFrame[i+1] = w.messageOfFrame[i]
            set frameOfMessage[w.messageOfFrame[i+1]] = i + 1
        endif
        if w.messageTimeRemaining[i+1] < w.messageFormat[i+1].fadeOutTime then
            call BlzFrameSetAlpha( w.textMessageFrame[i+1] , R2I(255*w.messageTimeRemaining[i+1]/w.messageFormat[i+1].fadeOutTime) )
        else
            call BlzFrameSetAlpha( w.textMessageFrame[i+1] , 255 )
        endif
        call BlzFrameSetVisible( w.textMessageFrame[i+1] , true )
        static if INCLUDE_FDF then
            call BlzFrameSetVisible( w.textMessageBox[i+1] , BlzFrameIsVisible(w.textMessageBox[i]) )
        endif

        set i = i - 1
    endloop
   
    set w.textMessageIcon[0] = tempFrame
   
    //=========================================================================================
    //Setup new message
    //=========================================================================================

    call ChangeTextFormatting(w, 0, whichFormat)
    call ChangeText(w, 0, whichText)
    set w.textHeight[0] = BlzFrameGetHeight(w.textMessageFrame[0]) + RMaxBJ(whichFormat.spacing , w.messageFormat[1].spacing)
    static if INCLUDE_FDF then
        call BlzFrameSetVisible( w.textMessageBox[0], whichFormat.isBoxed )
    endif
   
    if forcedDuration != 0 then
        set w.messageTimeRemaining[0] = forcedDuration + whichFormat.fadeOutTime
    else
        set w.messageTimeRemaining[0] = whichFormat.minDuration + whichFormat.durationIncrease*GetAdjustedStringLength(whichText) + whichFormat.fadeOutTime
    endif
    set w.messageTimeElapsed[0] = 0
   
    if whichFormat.fadeInTime > 0 then
        call BlzFrameSetAlpha(w.textMessageFrame[0] , 0)
    else
        call BlzFrameSetAlpha(w.textMessageFrame[0] , 255)
    endif
    call BlzFrameSetVisible( w.textMessageFrame[0] , true )
   
    set w.textMessageIconOrientation[0] = null
   
    if messageCounter == JASS_MAX_ARRAY_SIZE then
        set messageCounter = 1
    else
        set messageCounter = messageCounter + 1
    endif
    set w.messageOfFrame[0] = messageCounter
    set frameOfMessage[messageCounter] = 0
    set windowOfMessage[messageCounter] = w
   
    if w.maxTextMessages > 1 then
        call RepositionAllMessages(w)
    endif
   
    return messageCounter
endfunction

private function Init takes nothing returns nothing
    local integer i = 0
    local integer p
    local integer numPlayers
   
    static if INCLUDE_FDF then
        call BlzLoadTOCFile("NeatMessageTemplates.toc")
    endif
   
    call TimerStart( masterTimer , TIME_STEP , true , function FadeoutLoop )
   
    set DEFAULT_NEAT_FORMAT = NeatFormat.create()
    set DEFAULT_NEAT_WINDOW = NeatWindow.create(TEXT_MESSAGE_X_POSITION, TEXT_MESSAGE_Y_POSITION, TEXT_MESSAGE_BLOCK_WIDTH, TEXT_MESSAGE_BLOCK_MAX_HEIGHT, MAX_TEXT_MESSAGES, MESSAGE_ORDER_TOP_TO_BOTTOM)

    static if COPY_TO_MESSAGE_LOG then
        set p = 0
        set numPlayers = 0
        loop
        exitwhen p > 23
            if GetPlayerSlotState(Player(p)) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(Player(p)) == MAP_CONTROL_USER then
                set numPlayers = numPlayers + 1
            endif
            set p = p + 1
        endloop
       
        set isSinglePlayer = numPlayers == 1
    endif
   
    static if REPLACE_BLIZZARD_FUNCTION_CALLS then
        set currentNeatFormat = NeatFormat.create()
        call ExecuteFunc("ResetNeatVars")
    endif
endfunction

//===========================================================================================

struct NeatFormat
    real spacing = SPACING_BETWEEN_MESSAGES
    real fadeOutTime = FADE_OUT_TIME
    real fadeInTime = FADE_IN_TIME
    real fontSize = TEXT_MESSAGE_FONT_SIZE
    real minDuration = MESSAGE_MINIMUM_DURATION
    real durationIncrease = MESSAGE_DURATION_INCREASE_PER_CHARACTER
    textaligntype verticalAlignment = VERTICAL_ALIGNMENT
    textaligntype horizontalAlignment = HORIZONTAL_ALIGNMENT
    boolean isBoxed = BOXED_MESSAGES

    static method create takes nothing returns NeatFormat
        return NeatFormat.allocate()
    endmethod
   
    method copy takes NeatFormat copiedFormat returns nothing
        set .spacing = copiedFormat.spacing
        set .fadeOutTime = copiedFormat.fadeOutTime
        set .fadeInTime = copiedFormat.fadeInTime
        set .fontSize = copiedFormat.fontSize
        set .minDuration = copiedFormat.minDuration
        set .durationIncrease = copiedFormat.durationIncrease
        set .verticalAlignment = copiedFormat.verticalAlignment
        set .horizontalAlignment = copiedFormat.horizontalAlignment
        set .isBoxed = copiedFormat.isBoxed
    endmethod

endstruct

struct NeatWindow
    real xPosition
    real yPosition
    real maxHeight
    real width
    integer maxTextMessages
    boolean isTopToBottom

    framehandle array textMessageFrame[MAX_TEXT_MESSAGES]
    framehandle array textMessageText[MAX_TEXT_MESSAGES]
    framehandle array textMessageBox[MAX_TEXT_MESSAGES]
    framehandle array textCarryingFrame[MAX_TEXT_MESSAGES]
    framehandle array textMessageIcon[MAX_TEXT_MESSAGES]
    NeatFormat array messageFormat[MAX_TEXT_MESSAGES]
    real array messageTimeRemaining[MAX_TEXT_MESSAGES]
    real array messageTimeElapsed[MAX_TEXT_MESSAGES]
    real array textHeight[MAX_TEXT_MESSAGES]
    string array textMessageIconOrientation[MAX_TEXT_MESSAGES]
    integer array messageOfFrame[MAX_TEXT_MESSAGES]
   
    integer numMessagesOnScreen    = 0
   
    static method create takes real xPosition, real yPosition, real width, real maxHeight, integer maxTextMessages, boolean topToBottom returns NeatWindow
        local NeatWindow this = NeatWindow.allocate()
        local integer i = 0
       
        set .xPosition = xPosition
        set .yPosition = yPosition
        set .maxHeight = maxHeight
        set .width = width
        set .maxTextMessages = maxTextMessages
        set .isTopToBottom = topToBottom
        if isTopToBottom then
            set .yPosition = .yPosition + maxHeight
        endif
       
        set numNeatWindows = numNeatWindows + 1
        set neatWindow[numNeatWindows] = this

        loop
        exitwhen i > maxTextMessages - 1
            static if INCLUDE_FDF then
                set .textMessageFrame[i] = BlzCreateFrame("TextMessage", BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), 0, 0)
                set .textMessageText[i] = BlzFrameGetChild( .textMessageFrame[i],0)
                set .textMessageBox[i] = BlzFrameGetChild( .textMessageFrame[i],1)
                call BlzFrameSetSize(.textMessageText[i], width/(TEXT_MESSAGE_FONT_SIZE/10.), 0)
                call BlzFrameSetScale(.textMessageText[i], TEXT_MESSAGE_FONT_SIZE/10.)
                call BlzFrameSetAbsPoint(.textMessageFrame[i], FRAMEPOINT_BOTTOMLEFT, xPosition, yPosition)
                call BlzFrameSetTextAlignment(.textMessageText[i] , VERTICAL_ALIGNMENT , HORIZONTAL_ALIGNMENT)
                call BlzFrameSetVisible( .textMessageFrame[i] , false )
                call BlzFrameSetEnable(.textMessageFrame[i],false)
                call BlzFrameSetEnable(.textMessageText[i],false)
                call BlzFrameSetLevel(.textMessageText[i],1)
                call BlzFrameSetLevel(.textMessageBox[i],0)
                set .textCarryingFrame[i] = .textMessageText[i]
                set .textMessageIcon[i] = BlzCreateFrameByType("BACKDROP", "textMessageIcon" + I2S(i) , BlzGetFrameByName("ConsoleUIBackdrop",0), "", 0)
                call BlzFrameSetEnable(.textMessageIcon[i],false)
                call BlzFrameSetVisible(.textMessageIcon[i],false)
                set .messageFormat[i] = DEFAULT_NEAT_FORMAT
				call ChangeTextFormatting(this, i, DEFAULT_NEAT_FORMAT)
                call ChangeText(this, i, "")
            else
                set .textMessageFrame[i] = BlzCreateFrame("TextMessage", BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), 0, 0)
                call BlzFrameSetScale(.textMessageFrame[i], TEXT_MESSAGE_FONT_SIZE/10.)
                call BlzFrameSetTextAlignment(.textMessageFrame[i] , VERTICAL_ALIGNMENT , HORIZONTAL_ALIGNMENT)
                call BlzFrameSetAbsPoint(.textMessageFrame[i], FRAMEPOINT_BOTTOMLEFT, xPosition, yPosition)
                call BlzFrameSetVisible( .textMessageFrame[i] , false )
                call BlzFrameSetEnable(.textMessageFrame[i],false)
                set .textCarryingFrame[i] = .textMessageFrame[i]
                set .textMessageIcon[i] = BlzCreateFrameByType("BACKDROP", "textMessageIcon" + I2S(i) , BlzGetFrameByName("ConsoleUIBackdrop",0), "", 0)
                call BlzFrameSetEnable(.textMessageIcon[i],false)
                call BlzFrameSetVisible(.textMessageIcon[i],false)
                set .messageFormat[i] = DEFAULT_NEAT_FORMAT
				call ChangeTextFormatting(this, i, DEFAULT_NEAT_FORMAT)
                call ChangeText(this, i, "")
            endif

            set i = i + 1
        endloop
       
        return this
    endmethod
endstruct

//===========================================================================================
//API
//===========================================================================================

//Constructors
//===========================================================================================

function NeatMessage takes string message returns integer
    return AddTextMessage(message, 0, DEFAULT_NEAT_FORMAT, DEFAULT_NEAT_WINDOW)
endfunction

function NeatMessageToPlayer takes player whichPlayer, string message returns integer
    if GetLocalPlayer() == whichPlayer then
        return AddTextMessage(message , 0, DEFAULT_NEAT_FORMAT, DEFAULT_NEAT_WINDOW)
    endif
    return 0
endfunction

function NeatMessageToForce takes force whichForce, string message returns integer
    if IsPlayerInForce( GetLocalPlayer() , whichForce ) then
        return AddTextMessage(message, 0, DEFAULT_NEAT_FORMAT, DEFAULT_NEAT_WINDOW)
    endif
    return 0
endfunction

function NeatMessageTimed takes real duration, string message returns integer
    return AddTextMessage(message, duration, DEFAULT_NEAT_FORMAT, DEFAULT_NEAT_WINDOW)
endfunction

function NeatMessageToPlayerTimed takes player whichPlayer, real duration, string message returns integer
    if GetLocalPlayer() == whichPlayer then
        return AddTextMessage(message, duration, DEFAULT_NEAT_FORMAT, DEFAULT_NEAT_WINDOW)
    endif
    return 0
endfunction

function NeatMessageToForceTimed takes force whichForce, real duration, string message returns integer
    if IsPlayerInForce( GetLocalPlayer() , whichForce ) then
        return AddTextMessage(message, duration, DEFAULT_NEAT_FORMAT, DEFAULT_NEAT_WINDOW)
    endif
    return 0
endfunction

function NeatMessageFormatted takes string message, NeatFormat whichFormat returns integer
    return AddTextMessage(message, 0, whichFormat, DEFAULT_NEAT_WINDOW)
endfunction

function NeatMessageToPlayerFormatted takes player whichPlayer, string message, NeatFormat whichFormat returns integer
    if GetLocalPlayer() == whichPlayer then
        return AddTextMessage(message , 0, whichFormat, DEFAULT_NEAT_WINDOW)
    endif
    return 0
endfunction

function NeatMessageToForceFormatted takes force whichForce, string message, NeatFormat whichFormat returns integer
    if IsPlayerInForce( GetLocalPlayer() , whichForce ) then
        return AddTextMessage(message, 0, whichFormat, DEFAULT_NEAT_WINDOW)
    endif
    return 0
endfunction

function NeatMessageToPlayerTimedFormatted takes player whichPlayer, real duration, string message, NeatFormat whichFormat returns integer
    if GetLocalPlayer() == whichPlayer then
        return AddTextMessage(message, duration, whichFormat, DEFAULT_NEAT_WINDOW)
    endif
    return 0
endfunction

function NeatMessageToForceTimedFormatted takes force whichForce, real duration, string message, NeatFormat whichFormat returns integer
    if IsPlayerInForce( GetLocalPlayer() , whichForce ) then
        return AddTextMessage(message, duration, whichFormat, DEFAULT_NEAT_WINDOW)
    endif
    return 0
endfunction

function NeatMessageTimedFormatted takes real duration, string message, NeatFormat whichFormat returns integer
    return AddTextMessage(message, duration, whichFormat, DEFAULT_NEAT_WINDOW)
endfunction

function NeatMessageInWindow takes string message, NeatWindow whichWindow returns integer
    return AddTextMessage(message, 0, DEFAULT_NEAT_FORMAT, whichWindow)
endfunction

function NeatMessageToPlayerInWindow takes player whichPlayer, string message, NeatWindow whichWindow returns integer
    if GetLocalPlayer() == whichPlayer then
        return AddTextMessage(message , 0, DEFAULT_NEAT_FORMAT, whichWindow)
    endif
    return 0
endfunction

function NeatMessageToForceInWindow takes force whichForce, string message, NeatWindow whichWindow returns integer
    if IsPlayerInForce( GetLocalPlayer() , whichForce ) then
        return AddTextMessage(message, 0, DEFAULT_NEAT_FORMAT, whichWindow)
    endif
    return 0
endfunction

function NeatMessageTimedInWindow takes real duration, string message, NeatWindow whichWindow returns integer
    return AddTextMessage(message, duration, DEFAULT_NEAT_FORMAT, whichWindow)
endfunction

function NeatMessageToPlayerTimedInWindow takes player whichPlayer, real duration, string message, NeatWindow whichWindow returns integer
    if GetLocalPlayer() == whichPlayer then
        return AddTextMessage(message, duration, DEFAULT_NEAT_FORMAT, whichWindow)
    endif
    return 0
endfunction

function NeatMessageToForceTimedInWindow takes force whichForce, real duration, string message, NeatWindow whichWindow returns integer
    if IsPlayerInForce( GetLocalPlayer() , whichForce ) then
        return AddTextMessage(message, duration, DEFAULT_NEAT_FORMAT, whichWindow)
    endif
    return 0
endfunction

function NeatMessageFormattedInWindow takes string message, NeatFormat whichFormat, NeatWindow whichWindow returns integer
    return AddTextMessage(message, 0, whichFormat, whichWindow)
endfunction

function NeatMessageToPlayerFormattedInWindow takes player whichPlayer, string message, NeatFormat whichFormat, NeatWindow whichWindow returns integer
    if GetLocalPlayer() == whichPlayer then
        return AddTextMessage(message , 0, whichFormat, whichWindow)
    endif
    return 0
endfunction

function NeatMessageToForceFormattedInWindow takes force whichForce, string message, NeatFormat whichFormat, NeatWindow whichWindow returns integer
    if IsPlayerInForce( GetLocalPlayer() , whichForce ) then
        return AddTextMessage(message, 0, whichFormat, whichWindow)
    endif
    return 0
endfunction

function NeatMessageToPlayerTimedFormattedInWindow takes player whichPlayer, real duration, string message, NeatFormat whichFormat, NeatWindow whichWindow returns integer
    if GetLocalPlayer() == whichPlayer then
        return AddTextMessage(message, duration, whichFormat, whichWindow)
    endif
    return 0
endfunction

function NeatMessageToForceTimedFormattedInWindow takes force whichForce, real duration, string message, NeatFormat whichFormat, NeatWindow whichWindow returns integer
    if IsPlayerInForce( GetLocalPlayer() , whichForce ) then
        return AddTextMessage(message, duration, whichFormat, whichWindow)
    endif
    return 0
endfunction

function NeatMessageTimedFormattedInWindow takes real duration, string message, NeatFormat whichFormat, NeatWindow whichWindow returns integer
    return AddTextMessage(message, duration, whichFormat, whichWindow)
endfunction

//Utility
//===========================================================================================

function EditNeatMessage takes integer messagePointer, string newText returns nothing
    local integer whichFrame = frameOfMessage[messagePointer]
    local NeatWindow whichWindow = windowOfMessage[messagePointer]

    if messagePointer == 0 or whichFrame == -1 then
        return
    endif

    call ChangeText(whichWindow, whichFrame, newText)
    set whichWindow.textHeight[whichFrame] = BlzFrameGetHeight(whichWindow.textMessageFrame[whichFrame]) + RMaxBJ(whichWindow.messageFormat[whichFrame].spacing , whichWindow.messageFormat[whichFrame+1].spacing)

    call RepositionAllMessages(whichWindow)
endfunction

function AddNeatMessageTimeRemaining takes integer messagePointer, real additionalTime returns nothing
    local integer whichFrame = frameOfMessage[messagePointer]
    local NeatWindow whichWindow = windowOfMessage[messagePointer]

    if messagePointer == 0 or whichFrame == -1 then
        return
    endif
   
    set whichWindow.messageTimeRemaining[whichFrame] = RMaxBJ(whichWindow.messageTimeRemaining[whichFrame] + additionalTime, whichWindow.messageFormat[whichFrame].fadeOutTime)
endfunction

function SetNeatMessageTimeRemaining takes integer messagePointer, real newTime returns nothing
    local integer whichFrame = frameOfMessage[messagePointer]
    local NeatWindow whichWindow = windowOfMessage[messagePointer]

    if messagePointer == 0 or whichFrame == -1 then
        return
    endif   

    set whichWindow.messageTimeRemaining[whichFrame] = RMaxBJ(newTime, whichWindow.messageFormat[whichFrame].fadeOutTime)
endfunction

function AutoSetNeatMessageTimeRemaining takes integer messagePointer, boolean accountForTimeElapsed returns nothing
    local integer whichFrame = frameOfMessage[messagePointer]
    local NeatWindow whichWindow = windowOfMessage[messagePointer]
    local NeatFormat whichFormat = whichWindow.messageFormat[whichFrame]
   
    if messagePointer == 0 or whichFrame == -1 then
        return
    endif
   
    set whichWindow.messageTimeRemaining[whichFrame] = whichFormat.minDuration + whichFormat.durationIncrease*GetAdjustedStringLength(BlzFrameGetText(whichWindow.textCarryingFrame[whichFrame])) + whichFormat.fadeOutTime
    if accountForTimeElapsed then
        set whichWindow.messageTimeRemaining[whichFrame] = RMaxBJ(whichWindow.messageTimeRemaining[whichFrame] - whichWindow.messageTimeElapsed[whichFrame], whichFormat.fadeOutTime)
    endif
endfunction

function RemoveNeatMessage takes integer messagePointer returns nothing
    local integer whichFrame = frameOfMessage[messagePointer]
    local NeatWindow whichWindow = windowOfMessage[messagePointer]
   
    if messagePointer == 0 or whichFrame == -1 then
        return
    endif
   
    set whichWindow.messageTimeRemaining[whichFrame] = whichWindow.messageFormat[whichFrame].fadeOutTime
endfunction

function IsNeatMessageDisplayed takes integer messagePointer returns boolean
    return frameOfMessage[messagePointer] != -1
endfunction

function NeatMessageAddIcon takes integer messagePointer, real width, real height, string orientation, string texture returns nothing
    local integer whichFrame = frameOfMessage[messagePointer]
    local NeatWindow whichWindow = windowOfMessage[messagePointer]
   
    call BlzFrameSetVisible( whichWindow.textMessageIcon[whichFrame] , true )
    call BlzFrameSetAlpha( whichWindow.textMessageIcon[whichFrame] , 255 )
    call BlzFrameSetSize( whichWindow.textMessageIcon[whichFrame] , width , height )
    if orientation == "topleft" then
        call BlzFrameSetPoint( whichWindow.textMessageIcon[whichFrame] , FRAMEPOINT_TOPRIGHT , whichWindow.textMessageFrame[whichFrame] , FRAMEPOINT_TOPLEFT , 0 , 0 )
    elseif orientation == "topright" then
        call BlzFrameSetPoint( whichWindow.textMessageIcon[whichFrame] , FRAMEPOINT_TOPLEFT , whichWindow.textMessageFrame[whichFrame] , FRAMEPOINT_TOPRIGHT , 0 , 0 )
    elseif orientation == "bottomleft" then
        call BlzFrameSetPoint( whichWindow.textMessageIcon[whichFrame] , FRAMEPOINT_BOTTOMRIGHT , whichWindow.textMessageFrame[whichFrame] , FRAMEPOINT_BOTTOMLEFT , 0 , 0 )
    elseif orientation == "bottomright" then
        call BlzFrameSetPoint( whichWindow.textMessageIcon[whichFrame] , FRAMEPOINT_BOTTOMLEFT , whichWindow.textMessageFrame[whichFrame] , FRAMEPOINT_BOTTOMRIGHT , 0 , 0 )
    else
        debug call BJDebugMsg("Invalid icon orientation...")
        return
    endif
    call BlzFrameSetTexture( whichWindow.textMessageIcon[whichFrame] , texture , 0 , true )
    set whichWindow.textMessageIconOrientation[whichFrame] = orientation
   
    if BlzFrameGetHeight( whichWindow.textMessageFrame[whichFrame] ) < height then
        call BlzFrameSetSize( whichWindow.textCarryingFrame[whichFrame] , whichWindow.width / (whichWindow.messageFormat[whichFrame].fontSize/10.) , height - 0.018 )
        static if INCLUDE_FDF then
            call BlzFrameSetSize( whichWindow.textMessageFrame[whichFrame] , BlzFrameGetWidth(whichWindow.textMessageText[whichFrame]) + 0.008 , BlzFrameGetHeight(whichWindow.textMessageText[whichFrame]) + 0.009 )
            call BlzFrameSetPoint( whichWindow.textMessageBox[whichFrame] , FRAMEPOINT_BOTTOMLEFT , whichWindow.textMessageFrame[whichFrame] , FRAMEPOINT_BOTTOMLEFT , 0 , -0.0007*(whichWindow.messageFormat[whichFrame].fontSize-13) )
            call BlzFrameSetPoint( whichWindow.textMessageBox[whichFrame] , FRAMEPOINT_TOPRIGHT , whichWindow.textMessageFrame[whichFrame] , FRAMEPOINT_TOPRIGHT , 0 , 0 )
        endif
        set whichWindow.textHeight[whichFrame] = BlzFrameGetHeight(whichWindow.textMessageFrame[whichFrame]) + RMaxBJ(whichWindow.messageFormat[whichFrame].spacing , whichWindow.messageFormat[whichFrame+1].spacing)
        call RepositionAllMessages(whichWindow)
    endif
endfunction

function NeatMessageHideIcon takes integer messagePointer returns nothing
    local integer whichFrame = frameOfMessage[messagePointer]
    local NeatWindow whichWindow = windowOfMessage[messagePointer]
   
    call BlzFrameSetVisible( whichWindow.textMessageIcon[whichFrame] , false )
    set whichWindow.textMessageIconOrientation[whichFrame] = null
endfunction

function ClearNeatMessagesForPlayer takes player whichPlayer returns nothing
    local integer i
    local integer j = 1
    if GetLocalPlayer() == whichPlayer then
        loop
        exitwhen j > numNeatWindows
            set i = 0
            loop
            exitwhen i > neatWindow[j].maxTextMessages - 1
                call HideTextMessage(neatWindow[j], i, true)
                set i = i + 1
            endloop
            set j = j + 1
        endloop
    endif
endfunction

function ClearNeatMessages takes nothing returns nothing
    local integer i
    local integer j = 1

    if doNotClear then
        return
    endif

    loop
    exitwhen j > numNeatWindows
        set i = 0
        loop
        exitwhen i > neatWindow[j].maxTextMessages - 1
            call HideTextMessage(neatWindow[j], i, true)
            set i = i + 1
        endloop
        set j = j + 1
    endloop
endfunction

function ClearNeatMessagesForForce takes force whichForce returns nothing
    local integer i
    local integer j = 1
   
    if IsPlayerInForce(GetLocalPlayer() , whichForce) then
        loop
        exitwhen j > numNeatWindows
            set i = 0
            loop
            exitwhen i > neatWindow[j].maxTextMessages - 1
                call HideTextMessage(neatWindow[j], i, true)
                set i = i + 1
            endloop
            set j = j + 1
        endloop
    endif
endfunction

function ClearNeatMessagesForPlayerInWindow takes player whichPlayer, NeatWindow whichWindow returns nothing
    local integer i
    if GetLocalPlayer() == whichPlayer then
        set i = 0
        loop
        exitwhen i > whichWindow.maxTextMessages - 1
            call HideTextMessage(whichWindow, i, true)
            set i = i + 1
        endloop
    endif
endfunction

function ClearNeatMessagesInWindow takes NeatWindow whichWindow returns nothing
    local integer i

    set i = 0
    loop
    exitwhen i > whichWindow.maxTextMessages - 1
        call HideTextMessage(whichWindow, i, true)
        set i = i + 1
    endloop
endfunction

function ClearNeatMessagesForForceInWindow takes force whichForce, NeatWindow whichWindow returns nothing
    local integer i
   
    if IsPlayerInForce(GetLocalPlayer() , whichForce) then
        set i = 0
        loop
        exitwhen i > whichWindow.maxTextMessages - 1
            call HideTextMessage(whichWindow, i, true)
            set i = i + 1
        endloop
    endif
endfunction

//===========================================================================================
//GUI API
//===========================================================================================

static if REPLACE_BLIZZARD_FUNCTION_CALLS then
    globals
        NeatFormat currentNeatFormat
        private hashtable GUIhash = InitHashtable()
    endglobals

    function CreateNeatFormat takes string formatName returns nothing
        local NeatFormat whichFormat = NeatFormat.create()
        call SaveInteger( GUIhash , StringHash(formatName) , 0 , whichFormat )
        set whichFormat.spacing = udg_spacing
        set whichFormat.minDuration = udg_minDuration
        set whichFormat.durationIncrease = udg_durationIncrease
        set whichFormat.isBoxed = udg_isBoxed
        set whichFormat.fadeOutTime = udg_fadeOutTime
        set whichFormat.fadeInTime = udg_fadeInTime
        set whichFormat.fontSize = udg_fontSize

        if udg_verticalAlignment == "bottom" then
            set whichFormat.verticalAlignment = TEXT_JUSTIFY_BOTTOM
        elseif udg_verticalAlignment == "middle" then
            set whichFormat.verticalAlignment = TEXT_JUSTIFY_MIDDLE
        elseif udg_verticalAlignment == "top" then
            set whichFormat.verticalAlignment = TEXT_JUSTIFY_TOP
        else
            debug call BJDebugMsg("Invalid vertical alignment specificed. Valid types are bottom, middle, and top.")
        endif

        if udg_horizontalAlignment == "left" then
            set whichFormat.horizontalAlignment = TEXT_JUSTIFY_LEFT
        elseif udg_horizontalAlignment == "center" then
            set whichFormat.horizontalAlignment = TEXT_JUSTIFY_CENTER
        elseif udg_horizontalAlignment == "right" then
            set whichFormat.horizontalAlignment = TEXT_JUSTIFY_RIGHT
        else
            debug call BJDebugMsg("Invalid horizontal alignment specificed. Valid types are left, center, and right.")
        endif
    endfunction

    function SetNeatFormat takes string formatName returns nothing
        local NeatFormat whichFormat = LoadInteger( GUIhash , StringHash(formatName) , 0 )
        if whichFormat == 0 then
            debug call BJDebugMsg("Could not find neat format with specified name...")
        else
            set currentNeatFormat = whichFormat
        endif
    endfunction
   
    function ResetNeatVars takes nothing returns nothing
        set udg_spacing = SPACING_BETWEEN_MESSAGES
        set udg_minDuration = MESSAGE_MINIMUM_DURATION
        set udg_durationIncrease = MESSAGE_DURATION_INCREASE_PER_CHARACTER
        set udg_isBoxed = BOXED_MESSAGES
        set udg_fadeOutTime = FADE_OUT_TIME
        set udg_fadeInTime = FADE_IN_TIME
        set udg_fontSize = TEXT_MESSAGE_FONT_SIZE
        if VERTICAL_ALIGNMENT == TEXT_JUSTIFY_BOTTOM then
            set udg_verticalAlignment = "bottom"
        elseif VERTICAL_ALIGNMENT == TEXT_JUSTIFY_MIDDLE then
            set udg_verticalAlignment = "middle"
        elseif VERTICAL_ALIGNMENT == TEXT_JUSTIFY_TOP then
            set udg_verticalAlignment = "top"
        endif

        if HORIZONTAL_ALIGNMENT == TEXT_JUSTIFY_LEFT then
            set udg_horizontalAlignment = "left"
        elseif HORIZONTAL_ALIGNMENT == TEXT_JUSTIFY_CENTER then
            set udg_horizontalAlignment = "center"
        elseif HORIZONTAL_ALIGNMENT == TEXT_JUSTIFY_RIGHT then
            set udg_horizontalAlignment = "right"
        endif
    endfunction
   
    function ResetNeatFormat takes nothing returns nothing
        set currentNeatFormat = DEFAULT_NEAT_FORMAT
    endfunction

//===========================================================================================
//GUI Helper functions
//===========================================================================================

    function DisplayTextToForceHook takes force whichForce, string message returns nothing
        local string extractedString
        call BlzSetAbilityTooltip( TOOLTIP_ABILITY , message , 0 )
        set extractedString = BlzGetAbilityTooltip( TOOLTIP_ABILITY , 0 )
        call NeatMessageToForceFormatted( whichForce , extractedString , currentNeatFormat )
        call TimerStart( clearTextTimer , 0.0 , false , function ClearText )
    endfunction
   
    function DisplayTimedTextToForceHook takes force whichForce, real duration, string message returns nothing
        local string extractedString
        call BlzSetAbilityTooltip( TOOLTIP_ABILITY , message , 0 )
        set extractedString = BlzGetAbilityTooltip( TOOLTIP_ABILITY , 0 )
        call NeatMessageToForceTimedFormatted( whichForce , duration , extractedString, currentNeatFormat )
        call TimerStart( clearTextTimer , 0.0 , false , function ClearText )
    endfunction
endif

endlibrary