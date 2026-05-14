function LWoW_CleanDefaultUI takes nothing returns nothing
    local framehandle upkeepText = BlzGetFrameByName("ResourceBarUpkeepText", 0)
    local framehandle questButton = BlzGetFrameByName("UpperButtonBarQuestsButton", 0)
    local framehandle questAcceptButton
    local framehandle questItemList
    local framehandle questScrollBar

    // ResourceBarUpkeepText is a built-in text frame. Hiding text frames with
    // BlzFrameSetVisible is unsafe, so collapse it instead.
    if GetHandleId(upkeepText) != 0 then
        call BlzFrameSetSize(upkeepText, 0.0001, 0.0001)
    endif

    // Open and close the quest menu once so its internal frames initialize.
    // if GetHandleId(questButton) != 0 then
    //     call BlzFrameClick(questButton)
    // endif

    // set questAcceptButton = BlzGetFrameByName("QuestAcceptButton", 0)
    // set questItemList = BlzGetFrameByName("QuestItemListContainer", 0)
    // set questScrollBar = BlzGetFrameByName("QuestItemListScrollBar", 0)

    // if GetHandleId(questAcceptButton) != 0 then
    //     call BlzFrameClick(questAcceptButton)
    // endif

    // // Shrink reserved quest objective / defeat condition space.
    // if GetHandleId(questItemList) != 0 then
    //     call BlzFrameSetSize(questItemList, 0.01, 0.01)
    // endif

    // if GetHandleId(questScrollBar) != 0 then
    //     call BlzFrameSetSize(questScrollBar, 0.001, 0.001)
    // endif
endfunction

function InitTrig_LWoW_UI_Cleanup takes nothing returns nothing
    set gg_trg_LWoW_UI_Cleanup = CreateTrigger()
    call TriggerRegisterTimerEventSingle(gg_trg_LWoW_UI_Cleanup, 1.00)
    call TriggerAddAction(gg_trg_LWoW_UI_Cleanup, function LWoW_CleanDefaultUI)
endfunction