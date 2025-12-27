library HeroScoreFrame initializer init_function requires optional FrameLoader, optional FrameHeroScoreFrameOptions, optional FrameNumberDialog
    // HeroScoreFrame 1.5e
    // by Tasyen
    
    // HeroScoreFrame is a Frame-UI System for a Hero-Centric map.
    // The UI is only shown while the player holds a key (default Tab) and shows some Infos about the Player's Heroes.
    
    // Throws realVariable events when the library HeroScoreFrameEventGUI is found.
    //    udg_HeroScoreFrame_PlayerA, udg_HeroScoreFrame_PlayerB, udg_HeroScoreFrame_Event, udg_HeroScoreFrame_Unit, udg_HeroScoreFrame_Icon[], udg_HeroScoreFrame_Text[]
    //    udg_HeroScoreFrame_Event 1.0 = Before Swaping players
    //    udg_HeroScoreFrame_Event 2.0 = After Swaping players
    //    udg_HeroScoreFrame_Event 3.0 = Before Switch Teams
    //    udg_HeroScoreFrame_Event 4.0 = After Switch Teams
    //    udg_HeroScoreFrame_Event 5.0 = Update ScoreFrameInfo
    //    udg_HeroScoreFrame_Event -1.0 = Request Swap
    //    udg_HeroScoreFrame_Event -2.0 = Share
    //    udg_HeroScoreFrame_Event -3.0 = ShareAdv
    
    // function HeroScoreFrameGetPlayerContext takes player p returns integer
    //  find the first used HeroScoreFrame used by Player and return the createContext
    //  returns -1, when the player does not use any
    
    // function HeroScoreFrameSetTargetUnit takes integer createContext, unit u returns nothing
    //  When AutoSearchTarget is active the unit should be owned by the player using that card
    
    // function HeroScoreFrameSetTargetPlayer takes integer createContext, player p returns nothing
    //  Makes the HeroScoreFrame with CreateContext target player
    //  A HeroSccoreFrame with player null will hide itself
    
    // function HeroScoreFrameSetTargetTimer takes integer createContext, timer t returns nothing
    //  Read timer to display AutoReviveTime
    
    // function HeroScoreFrameSetFaceOverlayText takes integer createContext, string text returns nothing
    //  Set Current Text of the OverlayText, is overwritten every Timeout when a timer is set
    
    // function HeroScoreFrameGetTargetPlayer takes integer createContext returns player
    // function HeroScoreFrameGetTargetUnit takes integer createContext returns unit
     
    // function HeroScoreFrameSetScale takes real scale returns nothing
    // function HeroScoreFrameSetAllyScale takes real scale returns nothing
    // function HeroScoreFrameSetTooltipScale takes real scale returns nothing
    globals
        // AutoRun(true) will create Itself at 0s, (false) you need to HeroScoreFrameInit()
        private boolean AutoRun = true
        public string TocPath = "war3mapImported\\HeroScoreFrame.toc"
    
        private constant integer eventNumberGold = 1
        private constant integer eventNumberLumber = 2
        // HideText(true) hides the score Icons and Texts between Face and Items
        public boolean HideText = false
        // HideTextPack(true) only works with HideText(true), Then it makes the Frames take less space.
        public boolean HideTextPack = true
        public real Scale = 0.8
    
        // SizeX Y should match fdf values
        public real SizeX = 0.22
        public real SizeXPacked = 0.22 - 0.054
        public real SizeY = 0.075
    
        // how many HeroCards are created in InitFrames
        private integer AutoCreateCount = GetBJMaxPlayers()
        // how many HeroCards are in one Col
        private integer Rows = 6    
        // X space between 2 Cols
        private real ColOffsetX = 0
    
        public real TooltipScale = 1.0
        private real TooltipWidth = 0.2
        private boolean TooltipFixedPosition = true
        private real TooltipFixedPositionX = 0.79
        private real TooltipFixedPositionY = 0.16
        private framepointtype TooltipFixedPositionPoint = FRAMEPOINT_BOTTOMRIGHT
        // AutoSearchTarget, when there is no valid Unit of the UIPlayer of a HeroScoreFrame search one
        private boolean AutoSearchTarget = true
        // FillByTeam(false) fill the UI based on PlayerNumber
        // FillByTeam(true) start with PlayerTeam than PlayerNumber
        // FillByTeam = false is recommented when there are no fixed Teams
        private boolean FillByTeam = true
        private boolean FillByTeamSkipCols = true
        // postion of the first HeroScoreFrame, 
        private real X = 0.4
        private real Y = 0.55
        private framepointtype Point = FRAMEPOINT_TOPRIGHT
        
        // Key has to be hold to show the UI
        private oskeytype TriggerKey = OSKEY_TAB
    
        public real AllyScale = 0.80
    
        // Fixed postion of the PlayerControl-PopUp,
        // disable fixed position with AllyPoint = null
        public framepointtype AllyPoint = FRAMEPOINT_TOPRIGHT
        public real AllyX = 0.79
        public real AllyY = 0.55
        // Read item specific text/icon, instead of itemCode text/icon.
        public boolean DynamicItems = true
    
        public boolean AutoSwapBot = true
        public boolean AllowDuelEnemies = true
        public integer SwitchAllianceType = bj_ALLIANCE_ALLIED_VISION // choose a bj_ALLIANCE_xxxx
        public boolean SwitchAllianceAdv = true // give adv shared Control, shows hero icons and other stuff. Ordering still requires bj_ALLIANCE_ALLIED_UNITS or bj_ALLIANCE_ALLIED_ADVUNITS
        // Interpret Swap onto Enemy Players as Team Switch
        // SwapEnemyIsSwitch(true) does not change units but Teams
        // SwapEnemyIsSwitch(false) does change units but no Teams
        public boolean SwapEnemyIsSwitch = true
        public boolean AllowDuelAllies = true
        public boolean AllowShareAdv = true
        public boolean AllowShare = true

        // When true, enables ALLIANCE_SHARED_ADVANCED_CONTROL for allied player pairs at game start.
        // Note: This affects gameplay (resource spending / advanced control) but can be used even if the
        // allied resources multiboard is suppressed via MultiboardSuppressDisplay(true).
        public boolean AutoEnableShareAdvAtStart = true
        
        public boolean AllowSendGoldAlly = true
        public boolean AllowSendLumberAlly = true
        public boolean AllowSendGoldEnemy = false
        public boolean AllowSendLumberEnemy = false
        //===========
        // system globals
        // Created contains the CreateContexts created.
        private integer array Created
        private integer CreatedCount = 0
        private integer ColStarts = 0
        
        // UiTargets are stored under CreateContext
        public unit array UiTargetUnit
        public player array UiTargetPlayer
        public timer array UiTargetTimer
        
        private group g = CreateGroup()
    
        private player array SelectedPlayer
        private boolean array Duel
        
        public string DUEL_COMBAT_ERROR_MSG = "Can't duel while a player is in combat."
    endglobals

    private function EnableShareAdv takes nothing returns nothing
        local integer i = 0
        local integer j
        local player pi
        local player pj

        if not AutoEnableShareAdvAtStart then
            return
        endif

        loop
            set pi = Player(i)
            if GetPlayerSlotState(pi) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(pi) == MAP_CONTROL_USER then
                set j = 0
                loop
                    set pj = Player(j)
                    if i != j and GetPlayerSlotState(pj) == PLAYER_SLOT_STATE_PLAYING and GetPlayerController(pj) == MAP_CONTROL_USER and IsPlayerAlly(pi, pj) then
                        call SetPlayerAlliance(pi, pj, ALLIANCE_SHARED_ADVANCED_CONTROL, true)
                    endif
                    set j = j + 1
                    exitwhen j >= bj_MAX_PLAYER_SLOTS
                endloop
            endif
            set i = i + 1
            exitwhen i >= bj_MAX_PLAYER_SLOTS
        endloop

        set pi = null
        set pj = null
    endfunction
    
    // can be used to prevent players from taking an UI
    // return false when no UI shall be used by that player
    private function AllowedPlayer takes player p returns boolean
        if GetPlayerSlotState(p) != PLAYER_SLOT_STATE_PLAYING then 
            return false
        endif
        if (GetPlayerController(p) != MAP_CONTROL_USER and GetPlayerController(p) != MAP_CONTROL_COMPUTER) then
            return false
        endif
        if p == Player(1) or p == Player(0) or p == Player(3) or p == Player(11) then
            return false
        endif
        return true
    endfunction
    
    // shown next to Share/Swap Buttons (current State)
    private function GetTexture takes boolean enabled returns string
        if enabled then
            return "ui\\widgets\\glues\\thumbsup-up"
        else
            return "ui\\widgets\\glues\\thumbsdown-up"
        endif
    endfunction
    
    public function ParentFunc takes nothing returns framehandle
        return BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0) 
    endfunction
    
    // FACE_COLOR_BACKGROUND(true) moves the playercolor below the Face. (false) To the top of a HeroScoreFrame
    private function FACE_COLOR_BACKGROUND takes nothing returns boolean
        return true
    endfunction
    
    //===========
    //===========
    function HeroScoreFrameGetPlayerContext takes player p returns integer
        local integer loopIndex = 0
        loop
            if UiTargetPlayer[Created[loopIndex]] == p then
                return Created[loopIndex]
            endif
            set loopIndex = loopIndex + 1
            exitwhen loopIndex >= CreatedCount
        endloop
            
        return - 1
    endfunction
    
    function HeroScoreFrameSetFaceOverlayText takes integer createContext, string text returns nothing
        call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameFaceTextOverLay", createContext), text)
    endfunction
    function HeroScoreFrameSetTargetTimer takes integer createContext, timer t returns nothing
        if createContext < 0 then 
            return
        endif
        set UiTargetTimer[createContext] = t
    endfunction
    
    function HeroScoreFrameSetTargetUnit takes integer createContext, unit u returns nothing
        if createContext < 0 then 
            return
        endif
        set UiTargetUnit[createContext] = u
    endfunction
    
    function HeroScoreFrameSetTargetPlayer takes integer createContext, player p returns nothing
        if createContext < 0 then 
            return
        endif
        set UiTargetPlayer[createContext] = p
    endfunction
    
    function HeroScoreFrameGetTargetUnit takes integer createContext returns unit
        return UiTargetUnit[createContext]
    endfunction
    
    function HeroScoreFrameGetTargetPlayer takes integer createContext returns player
        return UiTargetPlayer[createContext]
    endfunction
    
    function HeroScoreFrameSetTooltipScale takes real scale returns nothing
        set TooltipScale = scale
        call BlzFrameSetScale(BlzGetFrameByName("HeroScoreFrameTooltipParent", 0), scale)
    endfunction
    
    function HeroScoreFrameSetAllyScale takes real scale returns nothing
        set AllyScale = scale
        call BlzFrameSetScale(BlzGetFrameByName("HeroScoreFrameAlly", 0), scale)
    endfunction
    
    function HeroScoreFrameSetScale takes real scale returns nothing
        set Scale = scale
        call BlzFrameSetScale(BlzGetFrameByName("HeroScoreFrameParent", 0), scale)
        // Scale Tooltips/Ally, to undo the overall Scaling for them
        call HeroScoreFrameSetTooltipScale(TooltipScale)
        call HeroScoreFrameSetAllyScale(AllyScale)
        static if LIBRARY_FrameNumberDialog then
            call BlzFrameSetScale(BlzGetFrameByName("NumberDialog", 0), 1)
        endif
        static if LIBRARY_FrameHeroScoreFrameOptions then
            call BlzFrameSetScale(BlzGetFrameByName("HeroScoreFrameOptions", 0), 1)
        endif
    endfunction
    function HeroScoreFrameUpdateScale takes nothing returns nothing
        call HeroScoreFrameSetScale(Scale)
    endfunction
    
    private function GetDisabledIcon takes string icon returns string
        //ReplaceableTextures\CommandButtons\BTNHeroPaladin.tga -> ReplaceableTextures\CommandButtonsDisabled\DISBTNHeroPaladin.tga
        if SubString(icon, 34, 35) != "\\" then
            return icon
        endif //this string has not enough chars return it
        //string.len(icon) < 34 then return icon end //this string has not enough chars return it
        return SubString(icon, 0, 34) + "Disabled\\DIS" + SubString(icon, 35, StringLength(icon))
    endfunction
    
    public function CreateSimpleTooltipHSF takes framehandle frame, string wantedframeName, integer wantedCreateContext, string text returns framehandle
        // this FRAME is important when the Box is outside of 4:3 it can be limited to 4:3.
        local framehandle toolTipParent = BlzCreateFrameByType("FRAME", "", BlzGetFrameByName("HeroScoreFrameTooltipParent", 0), "", 0)
        local framehandle toolTipBox = BlzCreateFrame("TasToolTipBox", toolTipParent, 0, 0)
        local framehandle toolTip = BlzCreateFrameByType("TEXT", wantedframeName, toolTipBox, "TasTooltipText", wantedCreateContext)
            
        //local toolTip = BlzCreateFrame("TasButtonTextTemplate", toolTipBox, 0, 0)
        if TooltipFixedPosition then 
            call BlzFrameSetAbsPoint(toolTip, TooltipFixedPositionPoint, TooltipFixedPositionX, TooltipFixedPositionY)
        else
            call BlzFrameSetPoint(toolTip, FRAMEPOINT_TOP, frame, FRAMEPOINT_BOTTOM, 0, - 0.008)
        endif
            
        call BlzFrameSetPoint(toolTipBox, FRAMEPOINT_TOPLEFT, toolTip, FRAMEPOINT_TOPLEFT, - 0.008, 0.008)
        call BlzFrameSetPoint(toolTipBox, FRAMEPOINT_BOTTOMRIGHT, toolTip, FRAMEPOINT_BOTTOMRIGHT, 0.008, - 0.008)
        call BlzFrameSetText(toolTip, text)
        call BlzFrameSetTooltip(frame, toolTipParent)
        call BlzFrameSetSize(toolTip, TooltipWidth, 0)
        return toolTip
    endfunction
        
    private function Update takes unit u, integer frameIndex returns nothing
        local item i
        local integer itemTypeId
        local player p = UiTargetPlayer[frameIndex]
        local integer loopIndex = 0
            
        // show this HeroScoreFrame
        call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrame", frameIndex), true)
    
        // update Face Display
        if IsUnitType(u, UNIT_TYPE_DEAD) then
            call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameFaceBackdrop", frameIndex), GetDisabledIcon(BlzGetAbilityIcon(GetUnitTypeId(u))), 0, false)
            call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameFaceBackdropDisabled", frameIndex), GetDisabledIcon(BlzGetAbilityIcon(GetUnitTypeId(u))), 0, false)
            call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameFaceBackdropPushed", frameIndex), GetDisabledIcon(BlzGetAbilityIcon(GetUnitTypeId(u))), 0, false)
                
            if UiTargetTimer[frameIndex] != null then
                call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameFaceTextOverLay", frameIndex), I2S(R2I(TimerGetRemaining(UiTargetTimer[frameIndex]))))
            endif
            call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameFaceTextOverLay", frameIndex), true)
        else
            call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameFaceBackdrop", frameIndex), BlzGetAbilityIcon(GetUnitTypeId(u)), 0, false)
            call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameFaceBackdropDisabled", frameIndex), BlzGetAbilityIcon(GetUnitTypeId(u)), 0, false)
            call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameFaceBackdropPushed", frameIndex), BlzGetAbilityIcon(GetUnitTypeId(u)), 0, false)
            call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameFaceTextOverLay", frameIndex), false)
        endif
        
        // PlayerColor
        if GetHandleId(GetPlayerColor(p)) < 10 then
            call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFramePlayerColor", frameIndex), "ReplaceableTextures\\TeamColor\\TeamColor0" + I2S(GetHandleId(GetPlayerColor(p))), 0, false)
        else
            call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFramePlayerColor", frameIndex), "ReplaceableTextures\\TeamColor\\TeamColor" + I2S(GetHandleId(GetPlayerColor(p))), 0, false)
        endif
                
        // LevelBox
        call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameFaceChargeText", frameIndex), I2S(GetUnitLevel(u)))
        // Face Tooltip
        call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameFaceTooltipText", frameIndex), GetPlayerName(p) + " (" + GetUnitName(u) + " - " + GetHeroProperName(u) + ")")
            
        // Score Text
        call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameTextParent", frameIndex), not HideText)
        if HideText and HideTextPack then
            call BlzFrameSetSize(BlzGetFrameByName("HeroScoreFrame", frameIndex), SizeXPacked, SizeY)
        else
            call BlzFrameSetSize(BlzGetFrameByName("HeroScoreFrame", frameIndex), SizeX , SizeY)
        endif
    
        // Throw the event independent from HideText to avoid desync, but support async changes to HideText.
    
        if not HideText then
            static if LIBRARY_HeroScoreFrameEventGUI then
                call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameText1", frameIndex), udg_HeroScoreFrame_Text[1])
                call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameText2", frameIndex), udg_HeroScoreFrame_Text[2])
                call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameText3", frameIndex), udg_HeroScoreFrame_Text[3])
                call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameTextIcon1", frameIndex), udg_HeroScoreFrame_Icon[1], 0, false)
                call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameTextIcon2", frameIndex), udg_HeroScoreFrame_Icon[2], 0, false)
                call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameTextIcon3", frameIndex), udg_HeroScoreFrame_Icon[3], 0, false)
                call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameTextTooltip1", frameIndex), udg_HeroScoreFrame_Text[11])
                call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameTextTooltip2", frameIndex), udg_HeroScoreFrame_Text[12])
                call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameTextTooltip3", frameIndex), udg_HeroScoreFrame_Text[13])
            else
                call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameText1", frameIndex), I2S(GetPlayerScore(p, PLAYER_SCORE_UNITS_KILLED) - GetPlayerScore(p, PLAYER_SCORE_HEROES_KILLED)))
                call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameText2", frameIndex), I2S(GetPlayerScore(p, PLAYER_SCORE_HEROES_KILLED)))
                call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameText3", frameIndex), I2S(GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)))
            endif
                
        endif
        
        // update Item Display
        loop
            set i = UnitItemInSlot(u, loopIndex)
            set itemTypeId = GetItemTypeId(i)
            if itemTypeId > 0 then
                call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameItemSlotButton_" + I2S(loopIndex), frameIndex), true)
                if DynamicItems then
                    call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameItemSlotButton_" + I2S(loopIndex) + "Backdrop", frameIndex), BlzGetItemIconPath(i), 0, false)
                    call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameItemSlotButton_" + I2S(loopIndex) + "BackdropDisabled", frameIndex), BlzGetItemIconPath(i), 0, false)
                    call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameItemSlotButton_" + I2S(loopIndex) + "BackdropPushed", frameIndex), BlzGetItemIconPath(i), 0, false)
                    call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameItemSlotButtonTooltipText_" + I2S(loopIndex), frameIndex), GetItemName(i) + "\n" + BlzGetItemExtendedTooltip(i))
                else
                    call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameItemSlotButton_" + I2S(loopIndex) + "Backdrop", frameIndex), BlzGetAbilityIcon(itemTypeId), 0, false)
                    call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameItemSlotButton_" + I2S(loopIndex) + "BackdropDisabled", frameIndex), BlzGetAbilityIcon(itemTypeId), 0, false)
                    call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameItemSlotButton_" + I2S(loopIndex) + "BackdropPushed", frameIndex), BlzGetAbilityIcon(itemTypeId), 0, false)
                    call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameItemSlotButtonTooltipText_" + I2S(loopIndex), frameIndex), GetObjectName(itemTypeId) + "\n" + BlzGetAbilityExtendedTooltip(itemTypeId, 0))
                endif
                if GetItemCharges(i) > 0 then
                    call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameItemSlotButtonChargeText_" + I2S(loopIndex), frameIndex), I2S(GetItemCharges(i)))
                        
                    call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameItemSlotButtonChargeBox_" + I2S(loopIndex), frameIndex), true)
                else
                    call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameItemSlotButtonChargeBox_" + I2S(loopIndex), frameIndex), false)
                endif
            else
                call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameItemSlotButton_" + I2S(loopIndex), frameIndex), false)
            endif
            set loopIndex = loopIndex + 1
            exitwhen loopIndex >= 6
        endloop
        set i = null
        set p = null
        
    endfunction
        
    private function UpdateFrameAllyIcons takes player p returns nothing
        if GetLocalPlayer() == p then
            // PlayerColor
            if GetHandleId(GetPlayerColor(SelectedPlayer[GetPlayerId(p)])) < 10 then
                call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameAllyTargetPlayerColor", 0), "ReplaceableTextures\\TeamColor\\TeamColor0" + I2S(GetHandleId(GetPlayerColor(SelectedPlayer[GetPlayerId(p)]))), 0, false)
            else
                call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameAllyTargetPlayerColor", 0), "ReplaceableTextures\\TeamColor\\TeamColor" + I2S(GetHandleId(GetPlayerColor(SelectedPlayer[GetPlayerId(p)]))), 0, false)
            endif
            // revert Player in ALLIANCE_SHARED_ADVANCED_CONTROL because we want to see the target players face
            call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameAllyButtonShareAdvIcon", 0), GetTexture(GetPlayerAlliance(SelectedPlayer[GetPlayerId(p)], p, ALLIANCE_SHARED_ADVANCED_CONTROL)), 0, true)
            call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameAllyButtonShareIcon", 0), GetTexture(GetPlayerAlliance(p, SelectedPlayer[GetPlayerId(p)], ALLIANCE_SHARED_CONTROL)), 0, true)
            call BlzFrameSetTexture(BlzGetFrameByName("HeroScoreFrameAllyButtonSwapIcon", 0), GetTexture(Duel[GetPlayerId(p) * bj_MAX_PLAYER_SLOTS + GetPlayerId(SelectedPlayer[GetPlayerId(p)])]), 0, true)
    
            if not AllowSendGoldAlly and not AllowSendLumberAlly and not AllowSendGoldEnemy and not AllowSendLumberEnemy then
                call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameAllyIconButtonSendGold", 0), false)
                call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameAllyIconButtonSendLumber", 0), false)
                call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameAllyButtonSend", 0), false)
            else
                call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameAllyIconButtonSendGold", 0), true)
                call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameAllyIconButtonSendLumber", 0), true)
                call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameAllyButtonSend", 0), true)
            endif
    
            if IsPlayerAlly(p, SelectedPlayer[GetPlayerId(p)]) then
                call BlzFrameSetEnable(BlzGetFrameByName("HeroScoreFrameAllyIconButtonSendGold", 0), AllowSendGoldAlly)
                call BlzFrameSetEnable(BlzGetFrameByName("HeroScoreFrameAllyIconButtonSendLumber", 0), AllowSendLumberAlly)
                call BlzFrameSetEnable(BlzGetFrameByName("HeroScoreFrameAllyButtonSwap", 0), AllowDuelAllies)
                call BlzFrameSetEnable(BlzGetFrameByName("HeroScoreFrameAllyButtonShare", 0), AllowShare)
                call BlzFrameSetEnable(BlzGetFrameByName("HeroScoreFrameAllyButtonShareAdv", 0), AllowShareAdv)
            else
                call BlzFrameSetEnable(BlzGetFrameByName("HeroScoreFrameAllyIconButtonSendGold", 0), AllowSendGoldEnemy)
                call BlzFrameSetEnable(BlzGetFrameByName("HeroScoreFrameAllyIconButtonSendLumber", 0), AllowSendLumberEnemy)
                call BlzFrameSetEnable(BlzGetFrameByName("HeroScoreFrameAllyButtonSwap", 0), AllowDuelEnemies)
                call BlzFrameSetEnable(BlzGetFrameByName("HeroScoreFrameAllyButtonShare", 0), false)
                call BlzFrameSetEnable(BlzGetFrameByName("HeroScoreFrameAllyButtonShareAdv", 0), false)
            endif
    
        endif
    endfunction
    
    private function ShowFrameAlly takes player p, framehandle frame returns nothing
        if GetLocalPlayer() == p then
            call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameAlly", 0), AllowDuelEnemies or AllowDuelAllies or AllowShareAdv or AllowShare or AllowSendGoldAlly or AllowSendLumberAlly or AllowSendGoldEnemy or AllowSendLumberEnemy)
            if AllyPoint == null then
                call BlzFrameClearAllPoints(BlzGetFrameByName("HeroScoreFrameAlly", 0))
                call BlzFrameSetPoint(BlzGetFrameByName("HeroScoreFrameAlly", 0), FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPRIGHT, 0, 0)
            endif
            call UpdateFrameAllyIcons(p)
        endif
    endfunction
        
    private function HeroScoreFrameAction takes nothing returns nothing
        set SelectedPlayer[GetPlayerId(GetTriggerPlayer())] = UiTargetPlayer[(S2I(BlzFrameGetText(BlzGetTriggerFrame())))]
        call ShowFrameAlly(GetTriggerPlayer(), BlzGetTriggerFrame())
    endfunction
    
    private function HeroScoreFrameFaceAction takes nothing returns nothing
        set SelectedPlayer[GetPlayerId(GetTriggerPlayer())] = UiTargetPlayer[(S2I(BlzFrameGetText(BlzGetTriggerFrame())))]
        call ShowFrameAlly(GetTriggerPlayer(), BlzFrameGetParent(BlzGetTriggerFrame()))
    endfunction
        
    
    private function CreateHeroScoreFrame takes integer index returns nothing
        local trigger trig
        local framehandle frame = BlzCreateFrame("HeroScoreFrame", BlzGetFrameByName("HeroScoreFrameParent", 0), 0, index)
        local integer loopIndex = 0
        if GetHandleId(frame) == 0 then
            call BJDebugMsg("Error - Create HeroScoreFrame")
        endif
        if HideText then
            call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameTextParent", index), false)
            call BlzFrameSetSize(frame, BlzFrameGetWidth(frame) - 0.055, BlzFrameGetHeight(frame))
        endif
    
        if FACE_COLOR_BACKGROUND() then
            call BlzFrameClearAllPoints(BlzGetFrameByName("HeroScoreFramePlayerColor", index))
            call BlzFrameSetPoint(BlzGetFrameByName("HeroScoreFramePlayerColor", index), FRAMEPOINT_TOPLEFT, BlzGetFrameByName("HeroScoreFrameFace", index), FRAMEPOINT_TOPLEFT, - 0.002, 0.002)
            call BlzFrameSetPoint(BlzGetFrameByName("HeroScoreFramePlayerColor", index), FRAMEPOINT_BOTTOMRIGHT, BlzGetFrameByName("HeroScoreFrameFace", index), FRAMEPOINT_BOTTOMRIGHT, 0.002, - 0.002)
        endif
    
        if CreatedCount == 0 then 
            call BlzFrameSetAbsPoint(frame, Point, X, Y)
            set ColStarts = index
        elseif Rows > 0 and ModuloInteger(CreatedCount, Rows) == 0 then 
            call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, BlzGetFrameByName("HeroScoreFrame", ColStarts), FRAMEPOINT_TOPRIGHT, ColOffsetX, 0.0)
            set ColStarts = index
        else
            call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, BlzGetFrameByName("HeroScoreFrame", Created[CreatedCount]), FRAMEPOINT_BOTTOMLEFT, 0.0, 0.0)
        endif
        set CreatedCount = CreatedCount + 1
        set Created[CreatedCount] = index
        
        call CreateSimpleTooltipHSF(BlzGetFrameByName("HeroScoreFrameFace", index), "HeroScoreFrameFaceTooltipText", index, "test")
        
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, frame, FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function HeroScoreFrameAction)
    
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameFace", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function HeroScoreFrameFaceAction)
    
        call BlzFrameSetText(frame, I2S(index))
        call BlzFrameSetText(BlzGetFrameByName("HeroScoreFrameFace", index), I2S(index))
        call BlzFrameSetSize(BlzGetFrameByName("HeroScoreFrameFaceTooltipText", index), 0, 0)
        
        call CreateSimpleTooltipHSF(BlzGetFrameByName("HeroScoreFrameText1", index), "HeroScoreFrameTextTooltip1", index, GetLocalizedString("UNIT_COLUMN1"))
        call CreateSimpleTooltipHSF(BlzGetFrameByName("HeroScoreFrameText2", index), "HeroScoreFrameTextTooltip2", index, GetLocalizedString("HEROES_COLUMN1"))    
        call CreateSimpleTooltipHSF(BlzGetFrameByName("HeroScoreFrameText3", index), "HeroScoreFrameTextTooltip3", index, GetLocalizedString("GOLD"))
        
        static if not LIBRARY_HeroScoreFrameEventGUI then
            call BlzFrameSetSize(BlzGetFrameByName("HeroScoreFrameTextTooltip1", index), 0, 0)
            call BlzFrameSetSize(BlzGetFrameByName("HeroScoreFrameTextTooltip2", index), 0, 0)
            call BlzFrameSetSize(BlzGetFrameByName("HeroScoreFrameTextTooltip3", index), 0, 0)
        endif
        call BlzGetFrameByName("HeroScoreFrameTextTooltip1", index)
        call BlzGetFrameByName("HeroScoreFrameTextTooltip2", index)
        call BlzGetFrameByName("HeroScoreFrameTextTooltip3", index)
        call BlzGetFrameByName("HeroScoreFrameTextIcon1", index)
        call BlzGetFrameByName("HeroScoreFrameTextIcon2", index)
        call BlzGetFrameByName("HeroScoreFrameTextIcon3", index)
    
        loop
            call CreateSimpleTooltipHSF(BlzGetFrameByName("HeroScoreFrameItemSlotButton_" + I2S(loopIndex), index), "HeroScoreFrameItemSlotButtonTooltipText_" + I2S(loopIndex), index, "test")
            // Reserve HandleId
            call BlzGetFrameByName("HeroScoreFrameItemSlotButton_" + I2S(loopIndex) + "Backdrop", index)
            call BlzGetFrameByName("HeroScoreFrameItemSlotButton_" + I2S(loopIndex) + "BackdropDisabled", index)
            call BlzGetFrameByName("HeroScoreFrameItemSlotButton_" + I2S(loopIndex) + "BackdropPushed", index)
            call BlzGetFrameByName("HeroScoreFrameItemSlotButtonTooltipText_" + I2S(loopIndex), index)
            call BlzGetFrameByName("HeroScoreFrameItemSlotButtonChargeText_" + I2S(loopIndex), index)
            call BlzGetFrameByName("HeroScoreFrameItemSlotButtonChargeBox_" + I2S(loopIndex), index)
            set loopIndex = loopIndex + 1
            exitwhen loopIndex >= 6
        endloop
        call BlzGetFrameByName("HeroScoreFrameFaceTextOverLay", index) 
    endfunction
    
    private function SwapActionGroupA takes nothing returns nothing
        call SetUnitOwner(GetEnumUnit(), SelectedPlayer[GetPlayerId(GetTriggerPlayer())], true)
    endfunction
    private function SwapActionGroupB takes nothing returns nothing
        call SetUnitOwner(GetEnumUnit(), GetTriggerPlayer(), true)
    endfunction
    private function SwitchTeams takes player playerA, player playerB returns nothing
        local integer teamA = GetPlayerTeam(playerA)
        local integer teamB = GetPlayerTeam(playerB)
        local integer indexTemp = GetPlayerStartLocation(playerB)
        local integer i = 0
        local integer index
        local integer heroCardIndexA
        local integer heroCardIndexB
            
        local playercolor tempColor = GetPlayerColor(playerB)
        // Enemy Swap - Fixed Team Game -> swap Team
        if IsPlayerEnemy(playerA, playerB) and SwapEnemyIsSwitch then
            call SetPlayerTeam(playerA, teamB)
            call SetPlayerTeam(playerB, teamA)
    
            // swap used StartLocation
            call SetPlayerStartLocation(playerB, GetPlayerStartLocation(playerA))
            call SetPlayerStartLocation(playerA, indexTemp)
    
            // swap Alliance with others
            loop
                if Player(i) != playerA and Player(i) != playerB and IsPlayerAlly(playerA, Player(i)) != IsPlayerAlly(playerB, Player(i))  then
                    if IsPlayerAlly(playerA, Player(i)) then
                        call SetPlayerAllianceStateBJ(Player(i), playerB, SwitchAllianceType)
                        call SetPlayerAllianceStateBJ(playerB, Player(i), SwitchAllianceType)
                        if SwitchAllianceAdv then
                            call SetPlayerAlliance(Player(i), playerA, ALLIANCE_SHARED_ADVANCED_CONTROL, true)
                            call SetPlayerAlliance(playerA, Player(i), ALLIANCE_SHARED_ADVANCED_CONTROL, true)
                        endif
                        call SetPlayerAllianceStateBJ(Player(i), playerA, bj_ALLIANCE_UNALLIED)
                        call SetPlayerAllianceStateBJ(playerA, Player(i), bj_ALLIANCE_UNALLIED)
                    else
                        call SetPlayerAllianceStateBJ(Player(i), playerA, SwitchAllianceType)
                        call SetPlayerAllianceStateBJ(playerA, Player(i), SwitchAllianceType)
                        if SwitchAllianceAdv then
                            call SetPlayerAlliance(Player(i), playerB, ALLIANCE_SHARED_ADVANCED_CONTROL, true)
                            call SetPlayerAlliance(playerB, Player(i), ALLIANCE_SHARED_ADVANCED_CONTROL, true)
                        endif
                        call SetPlayerAllianceStateBJ(Player(i), playerB, bj_ALLIANCE_UNALLIED)
                        call SetPlayerAllianceStateBJ(playerB, Player(i), bj_ALLIANCE_UNALLIED)
                    endif
                endif
                set i = i + 1
                exitwhen i == bj_MAX_PLAYER_SLOTS
            endloop
                
            // find used UI
            set i = CreatedCount
            loop
                set index = Created[i]
                if playerA == UiTargetPlayer[index] then
                    set heroCardIndexA = index
                endif
                if playerB == UiTargetPlayer[index] then
                    set heroCardIndexB = index
                endif
                set i = i - 1
                exitwhen i <= 0
            endloop
                
            // swap UI
            call HeroScoreFrameSetTargetPlayer(heroCardIndexA, playerB)
            call HeroScoreFrameSetTargetPlayer(heroCardIndexB, playerA)
            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 30, "Switch Team: " + GetPlayerName(playerA) + " - " + GetPlayerName(playerB))
        endif
        
        set tempColor = null
    endfunction
    
        
    private function HeroScoreFrameAllyButtonDuelAction takes nothing returns nothing
        local integer indexA
        local integer indexB
        local integer heroNumbA
        local integer heroNumbB
        local location point
        local player playerA = GetTriggerPlayer()
        local player playerB = SelectedPlayer[GetPlayerId(GetTriggerPlayer())]
        local force forceA = GetForceOfPlayer(playerA)
        local force forceB = GetForceOfPlayer(playerB)
    
        set heroNumbA = GetPlayerHeroNumber(playerA)
        set heroNumbB = GetPlayerHeroNumber(playerB)

        call Debug("Player A: " + GetPlayerName(playerA))
        call Debug("Player B: " + GetPlayerName(playerB))
        call Debug("Hero Number A: " + I2S(heroNumbA))
        call Debug("Hero Number B: " + I2S(heroNumbB))

        if TimerGetRemaining(udg_DamageTimer[heroNumbA]) > 0.00 or TimerGetRemaining(udg_DamageTimer[heroNumbB]) > 0.00 then
            call ErrorMessage(DUEL_COMBAT_ERROR_MSG, playerA)
        else 
            if udg_IsThereADuel then
                call ErrorMessage("Another duel is already in progress.", playerA)
            elseif IsUnitDeadBJ(udg_Heroes[heroNumbA]) or IsUnitDeadBJ(udg_Heroes[heroNumbB]) then
                call ErrorMessage("Can't duel while dead.", playerA)
            elseif playerA != playerB then
                set indexA = GetPlayerId(playerA) * bj_MAX_PLAYER_SLOTS + GetPlayerId(playerB)
                call Debug("IndexA: " + I2S(indexA))
                set indexB = GetPlayerId(playerB) * bj_MAX_PLAYER_SLOTS + GetPlayerId(playerA)
                call Debug("IndexB: " + I2S(indexB))
                set Duel[indexA] = not Duel[indexA]
                if Duel[indexA] then
                    call DisplayTimedTextToPlayer(playerA, 0, 0, 30, "Duel request sent to " + GetPlayerName(playerB))
                    call DisplayTimedTextToPlayer(playerB, 0, 0, 30, GetPlayerName(playerA) + " requests a duel with you!")
                    call Debug("Requested Duel")
                    call PlayLocalSound(gg_snd_Rescue, playerB)
                    // if IsPlayerAlly(playerA, playerB) then
                    //     call BJDebugMsg("Warning! Dueling is in BETA and may cause errors. Please report any bugs to the map creator.")
                    // endif
                else
                    call DisplayTimedTextToPlayer(playerA, 0, 0, 30, "Duel request canceled")
                    call DisplayTimedTextToPlayer(playerB, 0, 0, 30, GetPlayerName(playerA) + " canceled the duel request.")
                    call Debug("Duel request canceled.")
                endif
                if Duel[indexA] and Duel[indexB] and (GetPlayerSlotState(playerB) == PLAYER_SLOT_STATE_PLAYING) then
                    
                    set HeroX[heroNumbA] = GetUnitX(udg_Heroes[heroNumbA])
                    set HeroY[heroNumbA] = GetUnitY(udg_Heroes[heroNumbA])
                    set HeroX[heroNumbB] = GetUnitX(udg_Heroes[heroNumbB])
                    set HeroY[heroNumbB] = GetUnitY(udg_Heroes[heroNumbB])
                    
                    set point = GetRectCenter(gg_rct_Zandala_Duel_N)
                    call SetUnitPositionLoc( udg_Heroes[heroNumbA], point )
                    call RemoveLocation (point)

                    set point = GetRectCenter(gg_rct_Zandala_Duel_S)
                    call SetUnitPositionLoc( udg_Heroes[heroNumbB], point )
                    call RemoveLocation (point)

                    call DisplayTimedTextToPlayer(playerA, 0, 0, 30, "Duel started!")
                    call DisplayTimedTextToPlayer(playerB, 0, 0, 30, "Duel started!")
                    
                    set udg_IsThereADuel = true

                    call PercentHealthRestore(100, udg_Heroes[heroNumbA])
                    call PercentHealthRestore(100, udg_Heroes[heroNumbB])
                    call PercentManaRestore(100, udg_Heroes[heroNumbA])
                    call PercentManaRestore(100, udg_Heroes[heroNumbB])

                    call SetForceAllianceStateBJ( forceA, forceB, bj_ALLIANCE_UNALLIED )
                    call SetForceAllianceStateBJ( forceB, forceA, bj_ALLIANCE_UNALLIED )

                    call PlayLocalSound(gg_snd_ArrangedTeamInvitation, playerA)
                    call PlayLocalSound(gg_snd_ArrangedTeamInvitation, playerB)

                    set Duel[indexA] = false
                    set Duel[indexB] = false
                    //Duel has started so need to update both players icons
                    call UpdateFrameAllyIcons(playerB)
                endif
                call UpdateFrameAllyIcons(playerA)
            endif
        endif

        set point = null
        set playerA = null
        set playerB = null
        call DestroyForce(forceA)
        call DestroyForce(forceB)
        set forceA = null
        set forceB = null
    endfunction
    
    private function HeroScoreFrameAllyButtonShareAction takes nothing returns nothing
        if GetTriggerPlayer() != SelectedPlayer[GetPlayerId(GetTriggerPlayer())] then
            call SetPlayerAlliance(GetTriggerPlayer(), SelectedPlayer[GetPlayerId(GetTriggerPlayer())], ALLIANCE_SHARED_CONTROL, not GetPlayerAlliance(GetTriggerPlayer(), SelectedPlayer[GetPlayerId(GetTriggerPlayer())], ALLIANCE_SHARED_CONTROL))
            // call SetPlayerAlliance(SelectedPlayer[GetPlayerId(GetTriggerPlayer())], GetTriggerPlayer(), ALLIANCE_SHARED_CONTROL, not GetPlayerAlliance(SelectedPlayer[GetPlayerId(GetTriggerPlayer())], GetTriggerPlayer(), ALLIANCE_SHARED_CONTROL))
            call UpdateFrameAllyIcons(GetTriggerPlayer())
        endif
    endfunction
    
    private function HeroScoreFrameAllyButtonShareAdvAction takes nothing returns nothing
        if GetTriggerPlayer() != SelectedPlayer[GetPlayerId(GetTriggerPlayer())] then
        
            // The clicking Player wants to see the face of the target Player
            call SetPlayerAlliance(SelectedPlayer[GetPlayerId(GetTriggerPlayer())], GetTriggerPlayer(), ALLIANCE_SHARED_ADVANCED_CONTROL, not GetPlayerAlliance(SelectedPlayer[GetPlayerId(GetTriggerPlayer())], GetTriggerPlayer(), ALLIANCE_SHARED_ADVANCED_CONTROL))
    
            call UpdateFrameAllyIcons(GetTriggerPlayer())
        endif
    endfunction
    
    private function ButtonCloseAction takes nothing returns nothing
        if GetLocalPlayer() == GetTriggerPlayer() then
            call BlzFrameSetVisible(BlzFrameGetParent(BlzGetTriggerFrame()), false)
        endif
    endfunction
    static if LIBRARY_FrameNumberDialog then
        private function ButtonSendGoldAction takes nothing returns nothing
            call ShowNumberDialog(GetTriggerPlayer(), 2, eventNumberGold)        
        endfunction
        private function ButtonSendLumberAction takes nothing returns nothing
            call ShowNumberDialog(GetTriggerPlayer(), 3, eventNumberLumber)
        endfunction
    
        private function SendGoldAction takes nothing returns nothing
            local integer amount = NumberDialogResult
            if GetPlayerState(NumberDialogPlayer, PLAYER_STATE_RESOURCE_GOLD) < amount then 
                set amount = GetPlayerState(NumberDialogPlayer, PLAYER_STATE_RESOURCE_GOLD)
            endif
            call AdjustPlayerStateBJ(- amount, NumberDialogPlayer, PLAYER_STATE_RESOURCE_GOLD)
            call AdjustPlayerStateBJ(amount, SelectedPlayer[GetPlayerId(NumberDialogPlayer)], PLAYER_STATE_RESOURCE_GOLD)
            call BJDebugMsg(GetPlayerName(GetTriggerPlayer()) + " sent " + GetPlayerName(SelectedPlayer[GetPlayerId(NumberDialogPlayer)]) + ": |cffffcc00" + I2S(amount) + " gold|r")
            set NumberDialogEvent = 0
        endfunction
        private function SendLumberAction takes nothing returns nothing
            local integer amount = NumberDialogResult
            if GetPlayerState(NumberDialogPlayer, PLAYER_STATE_RESOURCE_LUMBER) < amount then 
                set amount = GetPlayerState(NumberDialogPlayer, PLAYER_STATE_RESOURCE_LUMBER)
            endif
            call AdjustPlayerStateBJ(- amount, NumberDialogPlayer, PLAYER_STATE_RESOURCE_LUMBER)
            call AdjustPlayerStateBJ(amount, SelectedPlayer[GetPlayerId(NumberDialogPlayer)], PLAYER_STATE_RESOURCE_LUMBER)
            call BJDebugMsg(GetPlayerName(GetTriggerPlayer()) + " sent " + GetPlayerName(SelectedPlayer[GetPlayerId(NumberDialogPlayer)]) + ": |cff07c500" + I2S(amount) + " lumber|r")
            set NumberDialogEvent = 0
        endfunction
    endif  
    function CreateGeneratedFrameHeroScoreFrameAlly takes integer index returns nothing
        local trigger trig
        local framehandle frame = BlzCreateFrame("HeroScoreFrameAlly", BlzGetFrameByName("HeroScoreFrameParent", 0), 0, index)
        call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameAlly", 0), false)
        if AllyPoint != null then
            call BlzFrameSetAbsPoint(BlzGetFrameByName("HeroScoreFrameAlly", 0), AllyPoint, AllyX, AllyY)
        endif
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameAllyButtonSwap", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function HeroScoreFrameAllyButtonDuelAction)
    
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameAllyButtonShare", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function HeroScoreFrameAllyButtonShareAction)
    
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameAllyButtonShareAdv", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function HeroScoreFrameAllyButtonShareAdvAction)
    
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameAllyButtonClose", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function ButtonCloseAction)
    
        static if LIBRARY_FrameNumberDialog then
            set trig = CreateTrigger()
            call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameAllyIconButtonSendGold", index), FRAMEEVENT_CONTROL_CLICK)
            call TriggerAddAction(trig, function ButtonSendGoldAction)
    
            set trig = CreateTrigger()
            call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("HeroScoreFrameAllyIconButtonSendLumber", index), FRAMEEVENT_CONTROL_CLICK)
            call TriggerAddAction(trig, function ButtonSendLumberAction)
    
    
            set trig = CreateTrigger()
            call TriggerRegisterVariableEvent(trig, "NumberDialogEvent", EQUAL, eventNumberGold )
            call TriggerAddAction(trig, function SendGoldAction)
    
            set trig = CreateTrigger()
            call TriggerRegisterVariableEvent(trig, "NumberDialogEvent", EQUAL, eventNumberLumber)
            call TriggerAddAction(trig, function SendLumberAction)
        endif
        call BlzFrameSetEnable(BlzGetFrameByName("HeroScoreFrameAllyButtonSend", index), false)
    
        // Reserve HandleIds
        call BlzGetFrameByName("HeroScoreFrameAllyButtonShareAdvIcon", index)
        call BlzGetFrameByName("HeroScoreFrameAllyButtonShareIcon", index)
        call BlzGetFrameByName("HeroScoreFrameAllyButtonSwapIcon", index)
        call BlzGetFrameByName("HeroScoreFrameAllyTargetPlayerColor", index)
        call BlzGetFrameByName("HeroScoreFrameAllyIconButtonSendGold", index)
        call BlzGetFrameByName("HeroScoreFrameAllyIconButtonSendLumber", index)
        // call BlzFrameSetScale(frame, 1)
    endfunction
    
        
    private function InitFrames takes nothing returns nothing
        local integer i = 0
        local integer team = 0
        local integer remain
        local integer usedCounter = 0
        call BlzLoadTOCFile(TocPath)
        call BlzCreateFrameByType("FRAME", "HeroScoreFrameParent", ParentFunc(), "", 0)
        // has to be something acceptimg BlzFrameSetLevel in V1.31.1
        call BlzCreateFrameByType("BUTTON", "HeroScoreFrameTooltipParent", BlzGetFrameByName("HeroScoreFrameParent", 0), "", 0)
        call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameParent", 0), false)
            
    
        set CreatedCount = 0
        loop
            call CreateHeroScoreFrame(i)
            set i = i + 1
            exitwhen i >= AutoCreateCount
        endloop
    
        if FillByTeam then
            loop
                set i = 0
                loop
                    if GetPlayerTeam(Player(i)) == team and AllowedPlayer(Player(i)) then
                        call HeroScoreFrameSetTargetPlayer(usedCounter, Player(i))
                        set usedCounter = usedCounter + 1
                    endif
                    set i = i + 1
                    exitwhen i >= bj_MAX_PLAYERS
                endloop
                // Team finished jump to next col, if there are remaining spaces.
                    
                    
                if FillByTeamSkipCols then
                    set remain = ModuloInteger(usedCounter, Rows)
                    if remain > 0 and remain < Rows then
                        set usedCounter = usedCounter + (Rows - remain)
                    endif
                else
                    set usedCounter = usedCounter + 1
                endif
                set team = team + 1
                exitwhen team >= GetTeams()
            endloop
        else
            set i = 0
            loop
                if AllowedPlayer(Player(i)) then
                    call HeroScoreFrameSetTargetPlayer(usedCounter, Player(i))
                    set usedCounter = usedCounter + 1
                endif
                set i = i + 1
                exitwhen i >= bj_MAX_PLAYERS
            endloop
        endif
    
        call CreateGeneratedFrameHeroScoreFrameAlly(0)
        static if LIBRARY_FrameNumberDialog then
            call FrameNumberDialog_create(0, BlzGetFrameByName("HeroScoreFrameParent", 0))
        endif
        static if LIBRARY_FrameHeroScoreFrameOptions then
            call FrameHeroScoreFrameOptions_Create(0)
        endif
        // make the tooltipParent take the highest Layer of all silberlings, for some reasons this has to be done after all silberlings were created
        call BlzFrameSetLevel(BlzGetFrameByName("HeroScoreFrameTooltipParent", 0), 99)
        call HeroScoreFrameSetScale(Scale)
    endfunction
    
    private function TimerAction takes nothing returns nothing
        local integer loopIndex = CreatedCount
        local integer index 
        loop
            set index = Created[loopIndex]
            if UiTargetPlayer[index] != null then
                if AutoSearchTarget and (UiTargetUnit[index] == null or GetUnitTypeId(UiTargetUnit[index]) == 0 or GetOwningPlayer(UiTargetUnit[index]) != UiTargetPlayer[index] or not IsUnitType(UiTargetUnit[index], UNIT_TYPE_HERO)) then
                    call GroupEnumUnitsOfPlayer(g, UiTargetPlayer[index], null)
                    if IsUnitType(FirstOfGroup(g), UNIT_TYPE_HERO) then
                        set UiTargetUnit[index] = FirstOfGroup(g)
                        call Update(UiTargetUnit[index], index)
                    else
                        call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrame", index), false)
                    endif
                else
                    call Update(UiTargetUnit[index], index)
                endif
            else
                call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrame", index), false)
            endif
            set loopIndex = loopIndex - 1
            exitwhen loopIndex <= 0
        endloop
        call GroupClear(g)
    endfunction
    
    //Comment this in and the other out to return to before
    // private function KeyAction takes nothing returns nothing
    //     if GetLocalPlayer() == GetTriggerPlayer() then
    //         call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameParent", 0), (not BlzFrameIsVisible(BlzGetFrameByName("HeroScoreFrameParent", 0)) ) )
    //     endif
    // endfunction

    private function KeyAction takes nothing returns nothing
        if GetLocalPlayer() == GetTriggerPlayer() then
            call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameParent", 0), BlzGetTriggerPlayerIsKeyDown())
            if not BlzGetTriggerPlayerIsKeyDown() then
                call BlzFrameSetVisible(BlzGetFrameByName("HeroScoreFrameAlly", 0), false)
            endif
        endif
    endfunction
        
    function HeroScoreFrameInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        local integer loopIndex = 0
        call InitFrames()

        call EnableShareAdv()
            
        loop
            call BlzTriggerRegisterPlayerKeyEvent(t, Player(loopIndex), TriggerKey, 0, true)
            call BlzTriggerRegisterPlayerKeyEvent(t, Player(loopIndex), TriggerKey, 0, false) //Comment this line out to return to before
            set loopIndex = loopIndex + 1
            exitwhen loopIndex >= bj_MAX_PLAYER_SLOTS
        endloop
           
        call TriggerAddAction(t, function KeyAction)
        if AutoRun then
            call TimerStart(GetExpiredTimer(), 0.25, true, function TimerAction)
        else
            call TimerStart(CreateTimer(), 0.25, true, function TimerAction)
        endif
        static if LIBRARY_FrameLoader then
            call FrameLoaderAdd(function InitFrames)
        endif

        call MultiboardSuppressDisplay(true)
    endfunction
    
    private function init_function takes nothing returns nothing
        if AutoRun then
            call TimerStart(CreateTimer(), 0, false, function HeroScoreFrameInit)
        endif
    endfunction
endlibrary    