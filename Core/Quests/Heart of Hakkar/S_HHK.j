function Trig_S_HHK_Actions takes nothing returns nothing
    local location udg_Temp_Unit_Point
                       if IsAllianceHero( GetTriggerUnit() ) then
    set udg_TempString = "The Keeper's Task"
    set udg_TempString_Quest = "Kill Jammal'an & Hakkar, then return Hakkar's Heart to the Warden by Quel'danil Lodge."
    call TriggerExecute( gg_trg_Quest_Start_A )
    if IsPlayerInForce(GetLocalPlayer(), udg_AlliancePlayers) then
    call QuestSetEnabledBJ( true, udg_Quests[31] )
    call FlashQuestDialogButtonBJ(  )
    endif
    call DestroyEffectBJ( udg_QuestMarks[31] )
    call QuestSetCompletedBJ( udg_Quests[31], false )
    call CreateQuestItemBJ( udg_Quests[31], "TRIGSTR_4785" )
    set udg_QuestReqs[31] = GetLastCreatedQuestItemBJ()
    call CampaignMinimapIconUnitBJ( gg_unit_O001_0897, bj_CAMPPINGSTYLE_BOSS )
    call SetMinimapIconOrphanDestroy( GetLastCreatedMinimapIcon(), true )
    call SetMinimapIconVisible( GetLastCreatedMinimapIcon(), false )
    if IsPlayerInForce(GetLocalPlayer(), udg_AlliancePlayers) then
    call SetMinimapIconVisible( GetLastCreatedMinimapIcon(), true )
    endif
    call DisableTrigger( GetTriggeringTrigger() )
    call EnableTrigger( gg_trg_U_HHK_Jammalan )
    call EnableTrigger( gg_trg_U_HHK_Hakkar )
    call EnableTrigger( gg_trg_U_HHK_Acquire )
                       endif
    set udg_Temp_Unit_Point = null
endfunction

//===========================================================================
function InitTrig_S_HHK takes nothing returns nothing
    set gg_trg_S_HHK = CreateTrigger(  )
    call DisableTrigger( gg_trg_S_HHK )
    call TriggerRegisterEnterRectSimple( gg_trg_S_HHK, gg_rct_The_Heart_of_Hakkar )
    call TriggerAddAction( gg_trg_S_HHK, function Trig_S_HHK_Actions )
endfunction

