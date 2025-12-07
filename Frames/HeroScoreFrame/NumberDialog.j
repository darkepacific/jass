library FrameNumberDialog
    globals
        public integer array Value
        public real array Action
        private string array IconType
        player NumberDialogPlayer
        integer NumberDialogResult
        real NumberDialogEvent
    endglobals
    private function Add takes player p, integer value returns nothing
        local integer playerId = GetPlayerId(p)
        set Value[playerId] = Value[playerId] * 10 + value
        if GetLocalPlayer() == p then
            call BlzFrameSetText(BlzGetFrameByName("NumberDisplayText", 0), I2S(Value[playerId]))
        endif
    endfunction
    function ShowNumberDialog takes player p, integer iconType, real actionNumber returns nothing
        if GetLocalPlayer() == p then
            call BlzFrameSetVisible(BlzGetFrameByName(IconType[1], 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName(IconType[2], 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName(IconType[3], 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName(IconType[iconType], 0), true)
            call BlzFrameSetVisible(BlzGetFrameByName("NumberDialog", 0), true)
        endif
        set Action[GetPlayerId(p)] = actionNumber
    endfunction
    private function ActionNumberButton0 takes nothing returns nothing
        call Add(GetTriggerPlayer(), 0)
    endfunction
    private function ActionNumberButton1 takes nothing returns nothing
        call Add(GetTriggerPlayer(), 1)
    endfunction
    private function ActionNumberButton2 takes nothing returns nothing
        call Add(GetTriggerPlayer(), 2)
    endfunction
    private function ActionNumberButton3 takes nothing returns nothing
        call Add(GetTriggerPlayer(), 3)
    endfunction
    private function ActionNumberButton4 takes nothing returns nothing
        call Add(GetTriggerPlayer(), 4)
    endfunction
    private function ActionNumberButton5 takes nothing returns nothing
        call Add(GetTriggerPlayer(), 5)
    endfunction
    private function ActionNumberButton6 takes nothing returns nothing
        call Add(GetTriggerPlayer(), 6)
    endfunction
    private function ActionNumberButton7 takes nothing returns nothing
        call Add(GetTriggerPlayer(), 7)
    endfunction
    private function ActionNumberButton8 takes nothing returns nothing
        call Add(GetTriggerPlayer(), 8)
    endfunction
    private function ActionNumberButton9 takes nothing returns nothing
        call Add(GetTriggerPlayer(), 9)
    endfunction
    private function ActionAcceptButton takes nothing returns nothing
        local integer playerId = GetPlayerId(GetTriggerPlayer())
        set NumberDialogPlayer = GetTriggerPlayer()
        set NumberDialogResult = Value[playerId]
        set NumberDialogEvent = Action[playerId]
        // call BJDebugMsg("Value: " + I2S(NumberDialogResult) + " Action: " + R2S(NumberDialogEvent))
        set Value[playerId] = 0
        if GetLocalPlayer() == NumberDialogPlayer then
            call BlzFrameSetText(BlzGetFrameByName("NumberDisplayText", 0), I2S(Value[playerId]))
        endif
        call BlzFrameSetVisible(BlzFrameGetParent(BlzGetTriggerFrame()), false)
    endfunction
    private function ActionCancelButton takes nothing returns nothing
        local integer playerId = GetPlayerId(GetTriggerPlayer())
        if Value[playerId] == 0 then
            call BlzFrameSetVisible(BlzFrameGetParent(BlzGetTriggerFrame()), false)
        else
            set Value[playerId] = 0
            call Add(GetTriggerPlayer(), 0)
        endif
    endfunction
    
    public function create takes integer index, framehandle parent returns nothing
        local trigger trig
        local boolean loaded = BlzLoadTOCFile("war3mapImported\\NumberDialog.toc")
        local framehandle frame = BlzCreateFrame("NumberDialog", parent, 0, index)
        call BlzFrameSetAbsPoint(BlzGetFrameByName("NumberDialog", 0), FRAMEPOINT_CENTER, 0.4, 0.3)
        if GetHandleId(frame) == 0 then
            call BJDebugMsg("Error - Creating NumberDialog")
        endif
        set IconType[1] = "NumberDialogTitelIcon"
        set IconType[2] = "NumberDialogTitelIconGold"
        set IconType[3] = "NumberDialogTitelIconLumber"
    
        call BlzGetFrameByName("NumberDisplayText", 0)
        call BlzGetFrameByName(IconType[1], 0)
        call BlzGetFrameByName(IconType[2], 0)
        call BlzGetFrameByName(IconType[3], 0)
        call BlzFrameSetVisible(frame, false)
    
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("NumberButton0", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function ActionNumberButton0)
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("NumberButton1", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function ActionNumberButton1)
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("NumberButton2", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function ActionNumberButton2)
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("NumberButton3", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function ActionNumberButton3)
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("NumberButton4", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function ActionNumberButton4)
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("NumberButton5", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function ActionNumberButton5)
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("NumberButton6", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function ActionNumberButton6)
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("NumberButton7", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function ActionNumberButton7)
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("NumberButton8", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function ActionNumberButton8)
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("NumberButton9", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function ActionNumberButton9)
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("AcceptButton", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function ActionAcceptButton)
        set trig = CreateTrigger()
        call BlzTriggerRegisterFrameEvent(trig, BlzGetFrameByName("CancelButton", index), FRAMEEVENT_CONTROL_CLICK)
        call TriggerAddAction(trig, function ActionCancelButton)
    endfunction
endlibrary