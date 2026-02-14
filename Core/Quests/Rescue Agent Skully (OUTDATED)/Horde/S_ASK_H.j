function Trig_S_ASK_H_Actions takes nothing returns nothing
    local integer udg_Temp_Int = 169
    local location udg_Temp_Unit_Point
    local location udg_Temp_Polar_Point
                       if IsHordeHero( GetTriggerUnit() ) then
    call DisableTrigger( GetTriggeringTrigger() )
    // Start Quest
    set udg_TempString = "Agent Skully"
    set udg_TempString_Quest = "Destroy cages until a key is found."
    call TriggerExecute( gg_trg_Quest_Start_H )
    call DestroyEffectBJ( udg_QuestMarks[udg_Temp_Int] )
    set udg_TempString = ""
    if IsPlayerInForce(GetLocalPlayer(), udg_HordePlayers) then
    set udg_TempString = udg_QuestionMark
    call QuestSetEnabledBJ( true, udg_Quests[udg_Temp_Int] )
    call FlashQuestDialogButtonBJ(  )
    endif
    // Create New Icons
    set udg_Temp_Unit_Point = GetRectCenter(gg_rct_Start_Big_Cage_Agent_Skuly)
    set udg_Temp_Polar_Point = PolarProjectionBJ(udg_Temp_Unit_Point, 50.00, 315.00)
    call AddSpecialEffectLocBJ( udg_Temp_Polar_Point, udg_TempString )
    call BlzSetSpecialEffectZ( GetLastCreatedEffectBJ(), 150.00 )
    set udg_QuestMarks[udg_Temp_Int] = GetLastCreatedEffectBJ()
    call CreateQuestItemBJ( udg_Quests[udg_Temp_Int], "TRIGSTR_11686" )
    call CampaignMinimapIconLocBJ( udg_Temp_Polar_Point, bj_CAMPPINGSTYLE_TURNIN )
    set udg_MiniMapIcon[udg_Temp_Int] = GetLastCreatedMinimapIcon()
    call SetMinimapIconVisible( GetLastCreatedMinimapIcon(), false )
    if IsPlayerInForce(GetLocalPlayer(), udg_HordePlayers) then
    call SetMinimapIconVisible( GetLastCreatedMinimapIcon(), true )
    endif
    call RemoveLocation (udg_Temp_Unit_Point)
    call RemoveLocation (udg_Temp_Polar_Point)
    // Turn On Triggers
    call EnableTrigger( gg_trg_U_ASK_H)
    call EnableTrigger( gg_trg_E_ASK_H)
                       endif
    set udg_Temp_Unit_Point = null
    set udg_Temp_Polar_Point = null
endfunction

//===========================================================================
function InitTrig_S_ASK_H takes nothing returns nothing
    set gg_trg_S_ASK_H = CreateTrigger(  )
    call DisableTrigger( gg_trg_S_ASK_H )
    call TriggerRegisterEnterRectSimple( gg_trg_S_ASK_H, gg_rct_Start_Big_Cage_Agent_Skuly )
    call TriggerAddAction( gg_trg_S_ASK_H, function Trig_S_ASK_H_Actions )
endfunction

