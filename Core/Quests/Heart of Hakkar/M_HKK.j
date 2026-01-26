function Trig_M_The_Heart_of_Hakkar_Actions takes nothing returns nothing
    local integer udg_Temp_Int = 31
    local location p = null
    local effect fx = null
    set udg_TempString = ""
    if IsPlayerInForce(GetLocalPlayer(), udg_AlliancePlayers) then
    set udg_TempString = udg_ExclamationMark
    endif
    set p = GetRectCenter(gg_rct_The_Heart_of_Hakkar)
    set fx = AddSpecialEffectLocBJ( p, udg_TempString )
    if fx != null then
        call BlzSetSpecialEffectScale( fx, 1.30 )
        call BlzSetSpecialEffectYaw( fx, Deg2Rad(86.00) )
    endif
    call RemoveLocation (p)
    set udg_QuestMarks[31] = fx
    set p = null
    set fx = null
    set udg_TempString = "When this land was torn assunder it was the trolls who summoned the Titan's great reckoning. They destroyed the night elves homeland, Kalimdor."
    set udg_TempString = ( udg_TempString + " To this day the warden north of here has never forgiven them. Exact vengance for her and kill their leader, Jammal'an, and their Loa-God, Hakkar. Return to her with Hakkar's heart when you're done." )
    // Set Quest Rewards
    set udg_QUEST_XP[udg_Temp_Int] = 675
    set udg_QUEST_GOLD[udg_Temp_Int] = 150
    set udg_QUEST_LVL_REQ[udg_Temp_Int] = udg_QUEST_ZONE_2_LVL_REQ
    call QuestRewards_TextSet(udg_Temp_Int)
    // End Set Quest Rewards
    call CreateQuestBJ( bj_QUESTTYPE_OPT_DISCOVERED, "TRIGSTR_4783", udg_TempString, "ReplaceableTextures\\CommandButtons\\BTNHeart.blp" )
    set udg_Quests[31] = GetLastCreatedQuestBJ()
    call QuestSetEnabledBJ( false, GetLastCreatedQuestBJ() )
    call EnableTrigger( gg_trg_S_HHK )
endfunction

//===========================================================================
function InitTrig_M_The_Heart_of_Hakkar takes nothing returns nothing
    set gg_trg_M_The_Heart_of_Hakkar = CreateTrigger(  )
    call TriggerRegisterTimerEventSingle( gg_trg_M_The_Heart_of_Hakkar, 4.20 )
    call TriggerAddAction( gg_trg_M_The_Heart_of_Hakkar, function Trig_M_The_Heart_of_Hakkar_Actions )
endfunction

