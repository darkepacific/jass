function Trig_U_HHK_Jammalan_Conditions takes nothing returns boolean
    if ( not ( GetUnitTypeId(GetTriggerUnit()) == 'O001' ) ) then
        return false
    endif
    return true
endfunction

function Trig_U_HHK_Jammalan_Actions takes nothing returns nothing
    // FT Gen
    set udg_TempString = "Jammal'an the Prophet"
    call QuestUnitSlain( GetTriggerUnit())
    // End FT Gen
    // Quest Update
    call QuestItemSetDescriptionBJ( udg_QuestReqs[31], "TRIGSTR_1951" )
    call QuestItemSetCompletedBJ( udg_QuestReqs[31], true )
    call CreateQuestItemBJ( udg_Quests[31], "TRIGSTR_3158" )
    set udg_QuestReqs[31] = GetLastCreatedQuestItemBJ()
    call DisableTrigger( GetTriggeringTrigger() )
    // Spawn Hakkar
    call TriggerExecute(gg_trg_Hakkar_Spawn)
endfunction

//===========================================================================
function InitTrig_U_HHK_Jammalan takes nothing returns nothing
    set gg_trg_U_HHK_Jammalan = CreateTrigger(  )
    call DisableTrigger( gg_trg_U_HHK_Jammalan )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_U_HHK_Jammalan, EVENT_PLAYER_UNIT_DEATH )
    call TriggerAddCondition( gg_trg_U_HHK_Jammalan, Condition( function Trig_U_HHK_Jammalan_Conditions ) )
    call TriggerAddAction( gg_trg_U_HHK_Jammalan, function Trig_U_HHK_Jammalan_Actions )
endfunction

