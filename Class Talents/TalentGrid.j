library TalentGridJUI uses TalentJUI, GenericFunctions
// TalentGrid for Talent Lui 1.36
// By Tasyen
//===========================================================================
//TalentGrid displays Tiers in rows one can scroll up and down.
//===========================================================================
    globals

        //public globals support being changed during the runtime

        //Pack = true, changes the Size of the UI so that the current displayed fits.
        //t is recommented to use a cornerPoint for PosType with enabled Pack
        public boolean Pack = true

        // Closes the UI when no unit is selected
        public boolean AutoCloseWithoutSelection = false        

        // Closes the UI after doing a choice without being able to pick again
        public boolean AutoCloseWhenDone = true

        //With false the unlearn Button won't exist
        //TalentBox.Control[GetConvertedPlayerId(player)].PreventResetButton = true will prevent player to use reset/Relearn button.
        public boolean HaveResetButton = true

        //MaxAmount of Options shown in the UI of one tier.
        //The Buttons start with 1 and include OptionMaxCount
        //One could still learn the Choice when a chat command would be provided.
        private integer OptionMaxCount = 5
        
        //The Buttons of the Grid to Pick/display choices.
        //ColsAmount should be equal or higher than the highest choice count in a tier
        private integer RowsAmount = 7
        private integer ColsAmount = 5

        private real ResetSizeX = 0.07
        private real ResetSizeY = 0.025
        
        //Default Position of the TalentGrid
        private real PosX = 0.05
        private real PosY = 0.55
        private framepointtype PosType = FRAMEPOINT_TOPLEFT

        public boolean OptionHaveTooltip = true
        // Tooltip Pos
        private boolean OptionTooltipFixedPos = true
        // Fixed
        private real OptionTooltipPosX = 0.79
        private real OptionTooltipPosY = 0.165
        private framepointtype OptionTooltipPos = FRAMEPOINT_BOTTOMRIGHT
        // Relative to TalentGrid
        private real OptionTooltipRelaPosX = 0.001
        private real OptionTooltipRelaPosY = -0.052
        private framepointtype OptionTooltipRelaPosA = FRAMEPOINT_TOPLEFT
        private framepointtype OptionTooltipRelaPosB = FRAMEPOINT_TOPRIGHT

        // XSize of the Tooltip
        private real OptionTooltipSizeX = 0.2

        //Bigger Options allow bigger texts, but also take more space of the screen, which reduces the possible amount of showing options in one tier.
        //XSize of an option in the TalentGrid
        private real OptionSizeX = 0.12 
        //YSize of an option in the TalentGrid
        private real OptionSizeY = 0.04

        public boolean OptionShowText = true

        //IconSize, should be smaller than OptionSizeY and OptionSizeX
        private real OptionIconSize = 0.03
        
        private real OptionLevelSizeX = 0.04
        //YSize of an option in the TalentGrid
        private real OptionLevelSizeY = 0.04
        
        

        //Default Position for the ShowTalentGridButton
        private real ShowButtonPosX = 0.04
        private real ShowButtonPosY = 0.16
        private framepointtype ShowButtonPosType = FRAMEPOINT_BOTTOMLEFT

        // Display a Sprite on the Show Button when the current Unit can do a choice
        public boolean ShowButtonSprite = true
        private string ShowButtonSpritePath = "ui/feedback/autocast/ui-modalbuttonon.mdx"
        private real ShowButtonSpriteSize = 0.039

        private string StringButtonResetTooltip = "Unlearn all Talents.|n|cffffcc00Cannot be done while in combat.|r"
        private string StringButtonResetText = "Reset"
        private string StringButtonUndoTooltip = "Unlearn last learned Talent.|n|cffffcc00Cannot be done while in combat.|r"
        private string StringButtonUndoText = "Undo"
        private string StringButtonShowText = "Talent|n(N)"
        private string StringTitlePrefix = "Talents: "
        private string StringNoTalentUser = "This unit does not have talents"

        //public trigger SelectTrigger

        public trigger WheelTrigger
        public trigger CloseTrigger
        public trigger ShowTrigger
        public trigger QuestLogTrigger
        public trigger SliderTrigger
        public trigger ResetTrigger
        public trigger UndoTrigger
        public trigger PickTrigger

        public framehandle FrameSlider
        public framehandle FrameParent
        public framehandle FrameItemParent
        public framehandle FrameShow
        public framehandle FrameShowSprite
        public framehandle FrameClose
        public framehandle FrameTitle
        public framehandle FrameReset
        public framehandle array FrameLevel
        public framehandle array FrameLevelText
        public framehandle array FrameSelected

        // the gridbuttons are a 2D array [rowIndex*rowMax + col]
        public framehandle array FrameItem
        public framehandle array FrameItemIcon
        public framehandle array FrameItemText
        public framehandle array FrameItemToolTip
        public framehandle array FrameItemToolTipText
        public framehandle array FrameItemToolTipIcon
        public framehandle array FrameItemToolTipName


        public integer array Offset
        public string array OptionTitleSufix
        public string array OptionTitlePrefix

        private timer SelectionCheckTimer
        private group SelectionCheckGroup
    endglobals
   
    function TalentGridUpdate takes player p returns nothing
        local integer playerId = GetPlayerId(p)
        
        local integer rows = RowsAmount
        local integer cols = ColsAmount
        local unit u = udg_TalentControlTarget[playerId]
        local integer unitHandle = GetHandleId(u)
        local integer unitCode = TalentGetUnitTypeId(u)
        
        local integer offset = Offset[playerId]
        local integer y = -1
        local integer x 
        local integer tierCount = 0
        local integer choice
        local integer tier
        local integer frameIndex
        local integer colsMax = 0
        local integer rowsMax = 0
        local integer level = 0
        local integer buttonUsed
        if GetLocalPlayer() != p then
            set u = null
            return
        endif
        if not TalentHas(u) then
            set u = null
            return
        endif
        call BlzFrameSetVisible(FrameShowSprite, ShowButtonSprite and TalentUnitHasChoice(unitHandle))
        call BlzFrameSetVisible(FrameShow, ShowButtonSprite and TalentUnitHasChoice(unitHandle))

        // walk the tiers of the current unit
        // pairs sorts it bad so loop from 1 to Talent[unitCode].MaxLevel
        //for level, tier in pairs(Talent[unitCode]["Tier"]) do
        loop
            exitwhen level > TalentHeroGetFinalTier(unitCode)
            set tier = TalentHeroGetTier(unitCode, level)
            if tier != 0 then
                set tierCount = tierCount + 1
                // skip tiers before offset
                if tierCount > offset then
                    set y = y + 1
                    exitwhen y > rows
                    if y > rowsMax then
                        set rowsMax = y
                    endif

                    call BlzFrameSetVisible(FrameLevel[y], true)
                    call BlzFrameSetText(FrameLevelText[y], I2S(level))

                    set buttonUsed = TalentUnitGetSelectionButtonUsed(unitHandle, tierCount)
                    if buttonUsed > 0 and TalentUnitGetSelectionsDoneCount(unitHandle) >= tierCount  then
                        call BlzFrameSetVisible(FrameSelected[y],true)
                    else
                        call BlzFrameSetVisible(FrameSelected[y],false)
                    endif

                    // walk the cols and update each button
                    set x = 1
                    loop
                        exitwhen x > cols
                        set choice = TalentTierGetChoice(tier, x)
                        set frameIndex = y*cols + x
                        if choice > 0 then
                            if x > colsMax then
                                set colsMax = x
                            endif

                            call BlzFrameSetVisible(FrameItem[frameIndex], true)
                            call BlzFrameSetEnable(FrameItem[frameIndex], GetPlayerAlliance(GetOwningPlayer(u), p, ALLIANCE_SHARED_CONTROL) and TalentUnitGetCurrentTierLevel(unitHandle) == level and TalentUnitHasChoice(unitHandle))
                            call BlzFrameSetTexture(FrameItemIcon[frameIndex], GetLocalizedString(udg_TalentChoiceIcon[choice]), 0, true)
                            call BlzFrameSetText(FrameItemText[frameIndex], GetLocalizedString(udg_TalentChoiceHead[choice]))
                            call BlzFrameSetVisible(FrameItemText[frameIndex], OptionShowText)
                            if OptionHaveTooltip then
                                call BlzFrameSetText(FrameItemToolTipText[frameIndex], GetLocalizedString(udg_TalentChoiceText[choice]))
                                call BlzFrameSetTexture(FrameItemToolTipIcon[frameIndex], GetLocalizedString(udg_TalentChoiceIcon[choice]), 0, true)
                                call BlzFrameSetText(FrameItemToolTipName[frameIndex], GetLocalizedString(udg_TalentChoiceHead[choice]))
                            endif
                            
                            if x == buttonUsed then 
                                call BlzFrameClearAllPoints(FrameSelected[y])
                                call BlzFrameSetAllPoints(FrameSelected[y], FrameItem[frameIndex])
                            endif
                        else
                            call BlzFrameSetVisible(FrameItem[frameIndex], false)
                        endif
                        set x = x + 1
                    endloop
					
                endif
            endif
            set level = level + 1
        endloop

        // hide the rows not used
        set y = y + 1
        loop
            exitwhen y >= RowsAmount
            call BlzFrameSetVisible(FrameLevel[y], false)
            call BlzFrameSetVisible(FrameSelected[y], false)
            set x = 1
            loop
                exitwhen x > cols
                call BlzFrameSetVisible(FrameItem[y*cols + x], false)
                set x = x + 1
            endloop
            set y = y + 1
        endloop
        
        if Pack then           
            call BlzFrameSetSize(FrameParent, 0.033 + OptionLevelSizeX + IMaxBJ(colsMax, 1)*OptionSizeX, 0.09 + OptionSizeY* (rowsMax + 1))
        endif

        set u = null
    endfunction

    function TalentGridShowEmpty takes player p returns nothing       
		if GetLocalPlayer() == p then
            call BlzFrameSetVisible(FrameItemParent, false)
			call BlzFrameSetText(FrameTitle, GetLocalizedString(StringNoTalentUser))
		endif
	endfunction

    function TalentGridShow takes unit target, player activePlayer returns nothing
        local integer playerId = GetPlayerId(activePlayer)
        local integer unitCode
        local integer count
        local integer loopA
        set udg_TalentControlTarget[playerId] = target // used look

        if TalentHas(target) then
            set Offset[playerId] = 0
            set unitCode = TalentGetUnitTypeId(target)
            set count = 0
            set loopA = 0
            loop
                exitwhen loopA > TalentHeroGetFinalTier(unitCode)
                if TalentHeroGetTier(unitCode, loopA) != 0 then
                    set count = count + 1
                endif
                set loopA = loopA + 1
            endloop

            if GetLocalPlayer() == activePlayer then
                call BlzFrameSetVisible(FrameSlider, count > RowsAmount)

                call BlzFrameSetText(FrameTitle, GetLocalizedString(StringTitlePrefix) + GetObjectName(unitCode))
                // if IsUnitType(target, UNIT_TYPE_HERO) then
                //     call BlzFrameSetText(FrameTitle, BlzFrameGetText(FrameTitle) + " ("+GetHeroProperName(target)+")" )
                // endif
            endif
            call BlzFrameSetMinMaxValue(FrameSlider, 0, IMaxBJ(0, count - RowsAmount))
            call BlzFrameSetVisible(FrameItemParent, true)
            
            call TalentGridUpdate(activePlayer)
            if HaveResetButton then
                call BlzFrameSetVisible(FrameReset, GetPlayerAlliance(GetOwningPlayer(udg_TalentControlTarget[playerId]), activePlayer, ALLIANCE_SHARED_CONTROL))
            endif
        else
            call TalentGridShowEmpty(activePlayer)
            if HaveResetButton then
                call BlzFrameSetVisible(FrameReset, false)
            endif
        endif
	endfunction


    // used for fixed Tooltips which don't change after the creation anymore
    public function CreateTooltip takes framehandle frame, string icon, string head, string text returns nothing
        // create an empty FRAME parent for the box BACKDROP, otherwise it can happen that it gets limited to the 4:3 Screen.
        local framehandle toolTipFrameFrame = BlzCreateFrame("TalentBoxTooltipBoxFrame", frame, 0, 0)
        local framehandle toolTipFrame = BlzGetFrameByName("TalentBoxTooltipBox", 0)
        local framehandle toolTipFrameIcon = BlzGetFrameByName("TalentBoxTooltipIcon", 0)
        local framehandle toolTipFrameName = BlzGetFrameByName("TalentBoxTooltipName", 0)
        local framehandle toolTipFrameSeperator = BlzGetFrameByName("TalentBoxTooltipSeperator", 0)
        local framehandle toolTipFrameText = BlzGetFrameByName("TalentBoxTooltipText", 0)
        call BlzFrameSetSize(toolTipFrameText, OptionTooltipSizeX, 0)
        call BlzFrameSetText(toolTipFrameText, GetLocalizedString(text))
        call BlzFrameSetText(toolTipFrameName, GetLocalizedString(head))
        call BlzFrameSetTexture(toolTipFrameIcon, GetLocalizedString(icon), 0, true)
        if OptionTooltipFixedPos then
            call BlzFrameSetAbsPoint(toolTipFrameText, OptionTooltipPos, OptionTooltipPosX, OptionTooltipPosY)
        else
            call BlzFrameSetPoint(toolTipFrameText, OptionTooltipRelaPosA, FrameParent, OptionTooltipRelaPosB, OptionTooltipRelaPosX, OptionTooltipRelaPosY)
        endif
        call BlzFrameSetPoint(toolTipFrame, FRAMEPOINT_TOPLEFT, toolTipFrameIcon, FRAMEPOINT_TOPLEFT, -0.005, 0.005)
        call BlzFrameSetPoint(toolTipFrame, FRAMEPOINT_BOTTOMRIGHT, toolTipFrameText, FRAMEPOINT_BOTTOMRIGHT, 0.005, -0.005)
        call BlzFrameSetTooltip(frame, toolTipFrameFrame)
    endfunction

    private function Reset takes unit u returns nothing
        call TalentResetDo(u, 99999, false)        
    endfunction

    private function Undo takes unit u returns nothing
        call TalentResetDo(u, 1, false)        
    endfunction

    private function ResetActionFuncDoA takes framehandle frame, player p returns nothing
        local integer playerId = GetPlayerId(p)

        call Reset(udg_TalentControlTarget[playerId])
        call TalentGridUpdate(p)
    endfunction

    private function ResetActionFunc takes nothing returns nothing
        call ResetActionFuncDoA(BlzGetTriggerFrame(), GetTriggerPlayer())
    endfunction

    private function UndoActionFuncDoA takes framehandle frame, player p returns nothing
        local integer playerId = GetPlayerId(p)

        call Undo(udg_TalentControlTarget[playerId])
        call TalentGridUpdate(p)
    endfunction

    private function UndoActionFunc takes nothing returns nothing
        call UndoActionFuncDoA(BlzGetTriggerFrame(), GetTriggerPlayer())
    endfunction

    private function PickActionFuncDo takes framehandle frame, player p returns nothing
        local integer playerId = GetPlayerId(p)
        local integer err
        local integer index = LoadInteger(udg_TalentHash, GetHandleId(frame), 0)

        set err = TalentPickDo(udg_TalentControlTarget[playerId], index)

        if (err == 0) then
            if AutoCloseWhenDone and not TalentUnitHasChoice(GetHandleId(udg_TalentControlTarget[playerId])) then
                if GetLocalPlayer() == p then
                    call BlzFrameClick(FrameClose)
                endif
            else
                call TalentGridUpdate(p)
            endif
        endif
    endfunction

    private function PickActionFunc takes nothing returns nothing
        call PickActionFuncDo(BlzGetTriggerFrame(), GetTriggerPlayer())
    endfunction

    private function SliderActionFunc takes nothing returns nothing
        local framehandle frame = BlzGetTriggerFrame()
        if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_WHEEL then
            if GetLocalPlayer() == GetTriggerPlayer() then
                if BlzGetTriggerFrameValue() > 0 then
                    call BlzFrameSetValue(frame, BlzFrameGetValue(frame) + 1)
                else
                    call BlzFrameSetValue(frame, BlzFrameGetValue(frame) - 1)
                endif
            endif
        else
            set Offset[GetPlayerId(GetTriggerPlayer())] = R2I(BlzGetTriggerFrameValue())
            call TalentGridUpdate(GetTriggerPlayer())
        endif
        set frame = null
    endfunction
    // this functions runs when not the slider is mouse wheel rolled
    private function WheelFunc takes framehandle frame, player p, real value returns nothing
        if GetLocalPlayer() == p then
            if value > 0 then
                call BlzFrameSetValue(FrameSlider, BlzFrameGetValue(FrameSlider) + 1)
            else
                call BlzFrameSetValue(FrameSlider, BlzFrameGetValue(FrameSlider) - 1)
            endif
        endif
    endfunction

    private function WheelActionFunc takes nothing returns nothing
        call WheelFunc(BlzGetTriggerFrame(), GetTriggerPlayer(), BlzGetTriggerFrameValue())
    endfunction

    private function CloseActionFunc takes nothing returns nothing
        if GetLocalPlayer() == GetTriggerPlayer() then
            call BlzFrameSetVisible(FrameParent, false)
            call TalentGridUpdate(GetTriggerPlayer() )
            //call BlzFrameSetVisible(FrameShow, true)
        endif
    endfunction

    private function ShowActionFunc takes nothing returns nothing
        local player p = GetTriggerPlayer()
        if GetLocalPlayer() == p then
            if (not BlzFrameIsVisible(FrameParent)) then
                call BlzFrameSetVisible(FrameParent, true)
                call BlzFrameSetVisible(FrameShow, false)
                call TalentGridUpdate(p)
                call PlaySoundBJ( gg_snd_QuestActivateWhat1)
            else
                call CloseActionFunc()
            endif
        endif
        set p = null
    endfunction

    function TalentGridCreate takes nothing returns nothing
        local integer rows = RowsAmount 
        local integer cols = ColsAmount
        local integer y
        local integer x
        local integer frameIndex
        local framehandle parent
        local framehandle tooltipFrame
        
        call BlzLoadTOCFile("war3mapImported/Talentbox.toc")
    
        set parent = BlzCreateFrameByType("BUTTON", "TalentGridParent", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        call BlzFrameSetAllPoints(BlzCreateFrameByType("BACKDROP", "TalentGridBackground", parent, "TalentBoxBackground", 0), parent)
        call BlzFrameSetSize(parent, 0.1, 0.1)
        call BlzFrameSetAbsPoint(parent, PosType, PosX, PosY)
        set FrameParent = parent
        call BlzTriggerRegisterFrameEvent(WheelTrigger, parent, FRAMEEVENT_MOUSE_WHEEL)

        set FrameTitle = BlzCreateFrame("TalentBoxTitle", parent, 0, 0)
        call BlzFrameSetPoint(FrameTitle, FRAMEPOINT_TOP, parent, FRAMEPOINT_TOP, 0.0, -0.024)
		call BlzFrameSetText(FrameTitle, GetLocalizedString(StringTitlePrefix))


        set FrameItemParent = BlzCreateFrameByType("FRAME", "TalentBoxOptionParent", parent, "", 0)
        
        set FrameClose = BlzCreateFrameByType("GLUETEXTBUTTON", "TalentCloseButton", parent, "ScriptDialogButton", 0)
        call BlzFrameSetText(FrameClose, "X")
		call BlzFrameSetSize(FrameClose, 0.035, 0.035)
        call BlzFrameSetPoint(FrameClose, FRAMEPOINT_TOPRIGHT, parent, FRAMEPOINT_TOPRIGHT, 0.0, 0)
        call BlzTriggerRegisterFrameEvent(CloseTrigger, FrameClose, FRAMEEVENT_CONTROL_CLICK)

        set FrameShow = BlzCreateFrameByType("GLUETEXTBUTTON", "TalentGridShowButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "ScriptDialogButton", 0)
        call BlzFrameSetSize(FrameShow, 0.05, 0.05)
		call BlzFrameSetText(FrameShow, GetLocalizedString(StringButtonShowText))
		call BlzFrameSetAbsPoint(FrameShow, ShowButtonPosType, ShowButtonPosX, ShowButtonPosY)
        call BlzTriggerRegisterFrameEvent(ShowTrigger, FrameShow, FRAMEEVENT_CONTROL_CLICK)

        set x = 2  
        loop
            exitwhen x > 13
            if GetPlayerController(Player(x)) == MAP_CONTROL_USER and GetPlayerSlotState(Player(x)) == PLAYER_SLOT_STATE_PLAYING then
                call BlzTriggerRegisterPlayerKeyEvent(ShowTrigger, Player(x), OSKEY_N, 0, true)
                // call BlzTriggerRegisterPlayerKeyEvent(QuestLogTrigger, Player(x), OSKEY_L, 0, true)
                call BlzTriggerRegisterPlayerKeyEvent(CloseTrigger, Player(x), OSKEY_ESCAPE, 0, true)
                call TriggerRegisterPlayerUnitEventSimple( CloseTrigger, Player(x), EVENT_PLAYER_HERO_LEVEL )
            endif
            set x = x + 1
        endloop

        set FrameShowSprite = BlzCreateFrameByType("SPRITE", "TalentGridShowButtonSprite", FrameShow, "", 0)
        call BlzFrameSetModel(FrameShowSprite, ShowButtonSpritePath, 0)
        call BlzFrameSetAllPoints(FrameShowSprite, FrameShow)
        call BlzFrameSetScale(FrameShowSprite, BlzFrameGetWidth(FrameShow)/ShowButtonSpriteSize)
        call BlzFrameSetVisible(FrameShowSprite, false)
 
        set y = 0
        loop
			
            exitwhen y >= rows
            set FrameLevel[y] = BlzCreateFrame("TalentBoxGridText", FrameItemParent, 0, 0)
            set FrameLevelText[y] = BlzGetFrameByName("TalentBoxGridTextValue", 0)
            call BlzFrameSetSize(FrameLevel[y], OptionLevelSizeX, OptionLevelSizeY)
            call BlzTriggerRegisterFrameEvent(WheelTrigger, FrameLevel[y], FRAMEEVENT_MOUSE_WHEEL)

            if y == 0 then
                call BlzFrameSetPoint(FrameLevel[y], FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, 0.015, -0.045)
            else
                call BlzFrameSetPoint(FrameLevel[y], FRAMEPOINT_TOPLEFT, FrameLevel[y - 1], FRAMEPOINT_BOTTOMLEFT, 0, 0)
            endif

            set x = 1  
            loop
                exitwhen x > cols
                set frameIndex = y*cols + x

                set FrameItem[frameIndex] =  BlzCreateFrame("TalentBoxGridItem", FrameItemParent, 0, 0)
                set FrameItemIcon[frameIndex] =  BlzGetFrameByName("TalentBoxGridItemIcon", 0)
                set FrameItemText[frameIndex] =  BlzGetFrameByName("TalentBoxGridItemTitle", 0)

                call BlzFrameSetSize(FrameItem[frameIndex], OptionSizeX, OptionSizeY)
                call BlzFrameSetSize(FrameItemIcon[frameIndex], OptionIconSize, OptionIconSize)
                call BlzFrameSetVisible(FrameItemText[frameIndex], OptionShowText)
                call SaveInteger(udg_TalentHash, GetHandleId(FrameItem[frameIndex]), 0, x)
                if x == 1 then				
                    call BlzFrameSetPoint(FrameItem[frameIndex], FRAMEPOINT_BOTTOMLEFT, FrameLevel[y], FRAMEPOINT_BOTTOMRIGHT, 0, 0)
                else
                    call BlzFrameSetPoint(FrameItem[frameIndex], FRAMEPOINT_BOTTOMLEFT, FrameItem[frameIndex - 1], FRAMEPOINT_BOTTOMRIGHT, 0, 0)
                endif
                call BlzTriggerRegisterFrameEvent(PickTrigger, FrameItem[frameIndex], FRAMEEVENT_CONTROL_CLICK)

                if OptionHaveTooltip then
                    // create an empty FRAME parent for the box BACKDROP, otherwise it can happen that it gets limited to the 4:3 Screen.
                    set tooltipFrame = BlzCreateFrame("TalentBoxTooltipBoxFrame", FrameItem[frameIndex], 0, 0)
                    set FrameItemToolTip[frameIndex] = BlzGetFrameByName("TalentBoxTooltipBox", 0)
                    set FrameItemToolTipIcon[frameIndex] = BlzGetFrameByName("TalentBoxTooltipIcon", 0)
                    set FrameItemToolTipName[frameIndex] = BlzGetFrameByName("TalentBoxTooltipName", 0)
                    set FrameItemToolTipText[frameIndex] = BlzGetFrameByName("TalentBoxTooltipText", 0)
                    call BlzFrameSetSize(FrameItemToolTipText[frameIndex], OptionTooltipSizeX, 0)
                    if OptionTooltipFixedPos then
                        call BlzFrameSetAbsPoint(FrameItemToolTipText[frameIndex], OptionTooltipPos, OptionTooltipPosX, OptionTooltipPosY)
                    else
                        call BlzFrameSetPoint(FrameItemToolTipText[frameIndex], OptionTooltipRelaPosA, FrameParent, OptionTooltipRelaPosB, OptionTooltipRelaPosX, OptionTooltipRelaPosY)
                    endif
                    call BlzFrameSetPoint(FrameItemToolTip[frameIndex], FRAMEPOINT_TOPLEFT, FrameItemToolTipIcon[frameIndex], FRAMEPOINT_TOPLEFT, -0.005, 0.005)
                    call BlzFrameSetPoint(FrameItemToolTip[frameIndex], FRAMEPOINT_BOTTOMRIGHT, FrameItemToolTipText[frameIndex], FRAMEPOINT_BOTTOMRIGHT, 0.005, -0.005)
                    call BlzFrameSetTooltip(FrameItem[frameIndex], tooltipFrame)
                endif
                set x = x + 1
            endloop

            set FrameSelected[y] = BlzCreateFrame("TalentHighlight", FrameItemParent, 0, 0)
            call BlzFrameSetVisible(FrameSelected[y], false)
            set y = y + 1
        endloop
        call BlzFrameSetSize(parent, 0.033 + OptionLevelSizeX + cols*OptionSizeX, 0.09 + OptionSizeY*rows)

        set FrameSlider = BlzCreateFrameByType("SLIDER", "FrameFlowSlider", FrameItemParent, "QuestMainListScrollBar", 0)
        call BlzFrameClearAllPoints(FrameSlider)
        call BlzFrameSetStepSize(FrameSlider, 1)
        call BlzFrameSetSize(FrameSlider, 0.012, BlzFrameGetHeight(FrameLevel[1]) * rows)
        call BlzFrameSetPoint(FrameSlider, FRAMEPOINT_TOPRIGHT, parent, FRAMEPOINT_TOPRIGHT, -0.0075, -0.045)
        call BlzFrameSetVisible(FrameSlider, true)
        call BlzTriggerRegisterFrameEvent(SliderTrigger, FrameSlider, FRAMEEVENT_MOUSE_WHEEL)
        call BlzTriggerRegisterFrameEvent(SliderTrigger, FrameSlider, FRAMEEVENT_SLIDER_VALUE_CHANGED)
        
        //Reset
        set FrameReset = BlzCreateFrameByType("GLUETEXTBUTTON", "TalentResetButton", FrameItemParent, "ScriptDialogButton", 0)
        call CreateTooltip(FrameReset, "UI/Widgets/EscMenu/Human/blank-background", StringButtonResetText, StringButtonResetTooltip)
        call BlzFrameSetText(FrameReset, GetLocalizedString(StringButtonResetText))
        call BlzFrameSetSize(FrameReset, ResetSizeX, ResetSizeY)
        call BlzFrameSetPoint(FrameReset, FRAMEPOINT_BOTTOMRIGHT, parent, FRAMEPOINT_BOTTOMRIGHT, -0.027, 0.02)
        call BlzTriggerRegisterFrameEvent(ResetTrigger, FrameReset, FRAMEEVENT_CONTROL_CLICK)
        call BlzFrameSetVisible(FrameReset, HaveResetButton)

        //Undo
        set FrameReset = BlzCreateFrameByType("GLUETEXTBUTTON", "TalentResetButton", FrameItemParent, "ScriptDialogButton", 0)
        call CreateTooltip(FrameReset, "UI/Widgets/EscMenu/Human/blank-background", StringButtonUndoText, StringButtonUndoTooltip)
        call BlzFrameSetText(FrameReset, GetLocalizedString(StringButtonUndoText))
        call BlzFrameSetSize(FrameReset, ResetSizeX, ResetSizeY)
        call BlzFrameSetPoint(FrameReset, FRAMEPOINT_BOTTOMRIGHT, parent, FRAMEPOINT_BOTTOMRIGHT, -0.093, 0.02)
        call BlzTriggerRegisterFrameEvent(UndoTrigger, FrameReset, FRAMEEVENT_CONTROL_CLICK)
        call BlzFrameSetVisible(FrameReset, HaveResetButton)

        call BlzFrameSetVisible(parent, false)
        call BlzFrameSetVisible(FrameShow, false)
    endfunction

    function OpenQuestLog takes nothing returns nothing
        // local player p = GetTriggerPlayer()
        // local framehandle f = BlzGetOriginFrame(ORIGIN_FRAME_SYSTEM_BUTTON,3)
        // call BlzFrameClick(BlzGetOriginFrame(ORIGIN_FRAME_SYSTEM_BUTTON,3))
        // // if GetLocalPlayer() != p then
        // //     call BlzFrameSetVisible(f, false)
        // // endif
        // set p = null
        // set f = null
    endfunction
    
    private function SelectActionFunc takes nothing returns nothing
        //GetPlayerId(GetTriggerPlayer())
        call PlayerNumbtoHeroesNumb()
        call TalentGridShow(udg_Heroes[udg_Player_Number], GetTriggerPlayer())
    endfunction
    private function TimerActionFunc takes nothing returns nothing
        call GroupEnumUnitsSelected(SelectionCheckGroup, GetLocalPlayer(), null)
        if AutoCloseWithoutSelection and GetHandleId(FirstOfGroup(SelectionCheckGroup)) == 0 then
            call BlzFrameSetVisible(FrameParent, false)
            //call BlzFrameSetVisible(FrameShow, true)
        else
            call TalentGridUpdate(GetLocalPlayer())
        endif
        call GroupClear(SelectionCheckGroup)
    endfunction
	function TalentGridInit takes nothing returns nothing

        //set SelectTrigger = CreateTrigger()
        //call TriggerRegisterUnitEvent( )
        //call TriggerRegisterAnyUnitEventBJ(SelectTrigger, EVENT_PLAYER_UNIT_SELECTED)
        //call TriggerAddAction(SelectTrigger, function SelectActionFunc)

        set WheelTrigger = CreateTrigger()
        call TriggerAddAction(WheelTrigger, function WheelActionFunc)
        set CloseTrigger = CreateTrigger()
        call TriggerAddAction(CloseTrigger, function CloseActionFunc)
        set ShowTrigger = CreateTrigger()
        call TriggerAddAction(ShowTrigger, function ShowActionFunc)
        call TriggerAddAction(ShowTrigger, function SelectActionFunc)
        // set QuestLogTrigger = CreateTrigger()
        // call TriggerAddAction(QuestLogTrigger, function OpenQuestLog)

        set SliderTrigger = CreateTrigger()
        call TriggerAddAction(SliderTrigger, function SliderActionFunc)
        set ResetTrigger = CreateTrigger()
        call TriggerAddAction(ResetTrigger, function ResetActionFunc)
        set UndoTrigger = CreateTrigger()
        call TriggerAddAction(UndoTrigger, function UndoActionFunc)
        set PickTrigger = CreateTrigger()
        call TriggerAddAction(PickTrigger, function PickActionFunc)


        call TalentGridCreate()
        static if LIBRARY_FrameLoader then
            call FrameLoaderAdd(function TalentGridCreate)
        endif
        set SelectionCheckTimer = CreateTimer()
        set SelectionCheckGroup = CreateGroup()
        call TimerStart(SelectionCheckTimer, 0.25, true, function TimerActionFunc)
    endfunction
endlibrary