library HoverOriginButton initializer Init requires optional FrameLoader
    /* HoverOriginButton by Tasyen
     This System gives a easy way to setup callbacks when a Command/Item Button is hovered. It uses Tooltips hence the executed callbacks are async.
     I created this because one can do this Tooltip approach to know hovering only once per map so that systems don't have to fight over that feature but use it.
    
    function HoverOriginButtonAdd takes boolean forCommandButton, code action returns triggercondition
        the action happens when the user starts hovering a button
        forCommandButton (true) add to commandButton Actions
        action the callback
        use HoverOriginButton_CurrentSelectedButtonIndex to know the current hovered Button
        Beaware that for itemsButtons ItemButtonOffset is included
        function()
            yourCode
            yourCode
        end
        returns the new objects can be used for HoverOriginButtonRemove
    function HoverOriginButtonAddClose takes code action returns triggercondition
        add a callback that happens when the user stops hoveringer a Command/Item Button, async.
        function()
            yourCode
            yourCode
        end
    function HoverOriginButtonRemove takes triggercondition action returns nothing
        removes the table from the callback List
    */
    globals
        public framehandle array Frames
        public timer Timer
        public trigger ActionsItem
        public trigger ActionsCommand
        public trigger ActionsClose
        public integer CurrentSelectedButtonIndex = -1
        public integer ItemButtonOffset = 30
        
    endglobals
    private function TimerAction takes nothing returns nothing
        local boolean selectedAnything  = false
        local integer int 
        local integer tableIndex
        set int = 0
        loop
            exitwhen int > 11
            if BlzFrameIsVisible(Frames[int]) then
                set selectedAnything = true
    
                // the new selected is not the same as the current one?
                if CurrentSelectedButtonIndex != int then
                    set CurrentSelectedButtonIndex = int
                    call TriggerEvaluate(ActionsCommand)
                endif
                
            endif
            set int = int + 1
        endloop
           
        set int = 0
        loop
            exitwhen int > 5
            set tableIndex = int + ItemButtonOffset
                if BlzFrameIsVisible(Frames[tableIndex]) then
                    set selectedAnything = true
    
                    // the new selected is not the same as the current one?
                    if CurrentSelectedButtonIndex != tableIndex then
                        set CurrentSelectedButtonIndex = tableIndex
                        call TriggerEvaluate(ActionsItem)
                    endif
                    
                endif
            set int = int + 1
        endloop
    
        // now selects nothing?
        if not selectedAnything and CurrentSelectedButtonIndex != - 1 then
            call TriggerEvaluate(ActionsClose)
            set CurrentSelectedButtonIndex = -1
        endif
           
    endfunction
    private function InitFrames takes nothing returns nothing
        local framehandle frame
        local framehandle buttonFrame
        local integer int
        //create one tooltip frame for each command button
        set int = 0
        loop
            exitwhen int > 11
            set buttonFrame = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, int)
            set frame = BlzCreateFrameByType("SIMPLEFRAME", "", buttonFrame, "", 0)
            call BlzFrameSetTooltip(buttonFrame, frame)
            call BlzFrameSetVisible(frame, false)
            set Frames[int] = frame
            set int = int + 1
        endloop
    
        //create one tooltip frame for each command button
        set int = 0
        loop
            exitwhen int > 5
            set buttonFrame = BlzGetOriginFrame(ORIGIN_FRAME_ITEM_BUTTON, int)
            set frame = BlzCreateFrameByType("SIMPLEFRAME", "", buttonFrame, "", 0)
            call BlzFrameSetTooltip(buttonFrame, frame)
            call BlzFrameSetVisible(frame, false)
            set Frames[int + ItemButtonOffset] = frame
            set int = int + 1
        endloop
    
        set buttonFrame = null
        set frame = null
     
        call TimerStart(Timer, 1.0/32, true, function TimerAction)
    endfunction 
    private function At0s takes nothing returns nothing
        call InitFrames()
    endfunction
    private function Init takes nothing returns nothing
        set Timer = CreateTimer()
        set ActionsCommand = CreateTrigger()
        set ActionsClose = CreateTrigger()
        set ActionsItem = CreateTrigger()
        call TimerStart(Timer,0 ,false, function At0s)
        // Frame related code actions are not saved/Loaded, probably repeat them after Loading the game
        static if LIBRARY_FrameLoader then
            call FrameLoaderAdd(function InitFrames)
        endif
    endfunction
    function HoverOriginButtonAdd takes boolean forCommandButton, code action returns triggercondition
        if forCommandButton then
            return TriggerAddCondition(ActionsCommand, Condition(action) )
        else
            return TriggerAddCondition(ActionsItem, Condition(action) )
        endif
    endfunction
    function HoverOriginButtonAddClose takes code action returns triggercondition
        return TriggerAddCondition(ActionsClose, Condition(action) )
    endfunction
    function HoverOriginButtonRemove takes triggercondition action returns nothing
        call TriggerRemoveCondition(ActionsCommand, action)
        call TriggerRemoveCondition(ActionsItem, action)
        call TriggerRemoveCondition(ActionsClose, action)
    endfunction
    
endlibrary
    
    