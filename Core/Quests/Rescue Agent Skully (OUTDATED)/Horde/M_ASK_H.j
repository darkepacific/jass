function Trig_M_ASK_H_Actions takes nothing returns nothing
    local integer udg_Temp_Int = 169
    local location udg_Temp_Unit_Point
    local location udg_Temp_Polar_Point
    set udg_TempString = ""
    if IsPlayerInForce(GetLocalPlayer(), udg_HordePlayers) then
    set udg_TempString = udg_ExclamationMark
    endif
    set udg_Temp_Unit_Point = GetRectCenter(gg_rct_Start_Big_Cage_Agent_Skuly)
    set udg_Temp_Polar_Point = PolarProjectionBJ(udg_Temp_Unit_Point, 50.00, 315.00)
    call AddSpecialEffectLocBJ( udg_Temp_Polar_Point, udg_TempString )
    call RemoveLocation (udg_Temp_Polar_Point)
    call RemoveLocation (udg_Temp_Unit_Point)
    call BlzSetSpecialEffectOrientation( GetLastCreatedEffectBJ(), Deg2Rad(90.00), 0.00, 0.0 )
    call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), 1.20 )
    call BlzSetSpecialEffectZ( GetLastCreatedEffectBJ(), 150.00 )
    set udg_QuestMarks[udg_Temp_Int] = GetLastCreatedEffectBJ()
    set udg_TempString = "<The cage rustles violently.> This must hold a high priority capitive, but who could it be? Whoever it is, they will probably reward well for their release. Find the key. Start by freeing other captives."
    // Set Quest Rewards
    set udg_QUEST_XP[udg_Temp_Int] = 2000
    set udg_QUEST_GOLD[udg_Temp_Int] = 500
    call QuestRewards_TextSet(udg_Temp_Int)
    // End Set Quest Rewards
    call CreateQuestBJ( bj_QUESTTYPE_OPT_DISCOVERED, "TRIGSTR_11682", udg_TempString, "ReplaceableTextures\\CommandButtons\\BTNHuman_Female.blp" )
    set udg_Quests[udg_Temp_Int] = GetLastCreatedQuestBJ()
    call QuestSetCompletedBJ( udg_Quests[udg_Temp_Int], false )
    call QuestSetEnabledBJ( false, GetLastCreatedQuestBJ() )
    call EnableTrigger( gg_trg_S_ASK_H)
    set udg_Temp_Unit_Point = null
    set udg_Temp_Polar_Point = null
endfunction

//===========================================================================
function InitTrig_M_ASK_H takes nothing returns nothing
    set gg_trg_M_ASK_H = CreateTrigger(  )
    call TriggerRegisterTimerEventSingle( gg_trg_M_ASK_H, 2.35 )
    call TriggerAddAction( gg_trg_M_ASK_H, function Trig_M_ASK_H_Actions )
endfunction

