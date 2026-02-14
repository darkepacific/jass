function Trig_E_ASK_H_Func006Func001C takes nothing returns boolean
    if ( not ( GetItemTypeId(udg_P_Items[( udg_Bag_Num + udg_Bag_Iterator )]) == udg_ItemTypeCheck ) ) then
        return false
    endif
    return true
endfunction

function Trig_E_ASK_H_Actions takes nothing returns nothing
    local integer udg_Temp_Int = 169
    local location udg_Temp_Unit_Point
                       if IsHordeHero( GetTriggerUnit() ) then
    call SetBagNumber( GetOwningPlayer(GetTriggerUnit()) )
    set udg_ItemTypeCheck = 'I0AJ'
    set udg_Bag_Iterator = 1
    loop
        exitwhen udg_Bag_Iterator > 18
        if ( Trig_E_ASK_H_Func006Func001C() ) then
            call DisableTrigger( gg_trg_U_ASK_H)
            call DisableTrigger( GetTriggeringTrigger() )
            if IsPlayerInForce(GetLocalPlayer(), udg_HordePlayers) then
            call FlashQuestDialogButtonBJ(  )
            endif
            call QuestSetCompletedBJ( udg_Quests[udg_Temp_Int], true )
            call DestroyEffectBJ( udg_QuestMarks[udg_Temp_Int] )
            call DestroyMinimapIcon( udg_MiniMapIcon[udg_Temp_Int] )
            // Clean Up Items
            call CleanUpItems( udg_ItemTypeCheck )
            // Rewards
            set udg_XP = udg_QUEST_XP[udg_Temp_Int]
            set udg_Gold = udg_QUEST_GOLD[udg_Temp_Int]
            set udg_LVL_Req = udg_QUEST_LVL_REQ[udg_Temp_Int]
            set udg_TempString = "A Deadly New Ally"
            call TriggerExecute( gg_trg_Quest_Complete_H )
            // Create Skully
            call KillDestructable( gg_dest_B02P_35606 )
            set udg_Temp_Unit_Point = GetRectCenter(gg_rct_Start_Big_Cage_Agent_Skuly)
            call CreateNUnitsAtLoc( 1, 'E04R', Player(PLAYER_NEUTRAL_PASSIVE), udg_Temp_Unit_Point, 300.00 )
            call RemoveLocation (udg_Temp_Unit_Point)
            set udg_AgentSkully = GetLastCreatedUnit()
            call SetUnitInvulnerable( GetLastCreatedUnit(), true )
            call SetHeroLevelBJ( GetLastCreatedUnit(), 40, false )
            call MaxManaRestore( 1.0, udg_AgentSkully)
            call TriggerExecute( gg_trg_Quest_Rescue_Sound_H )
            call CreateTextTagUnitBJ( "TRIGSTR_11677", udg_AgentSkully, 0, 8.00, 100.00, 85.00, 65.00, 0 )
            call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 10.00, 90.00 )
            call cleanUpText(1.3, 1.0)
            call ShowTextTagForceBJ( false, GetLastCreatedTextTag(), GetPlayersAll() )
            call ShowTextTagForceBJ( true, GetLastCreatedTextTag(), udg_HordePlayers )
            call TriggerSleepAction( 12.00 )
            call DestructableRestoreLife( gg_dest_B02P_35606, 50.00, true )
            return
        else
        endif
        set udg_Bag_Iterator = udg_Bag_Iterator + 1
    endloop
                       endif
    set udg_Temp_Unit_Point = null
endfunction

//===========================================================================
function InitTrig_E_ASK_H takes nothing returns nothing
    set gg_trg_E_ASK_H = CreateTrigger(  )
    call DisableTrigger( gg_trg_E_ASK_H )
    call TriggerAddAction( gg_trg_E_ASK_H, function Trig_E_ASK_H_Actions )
endfunction

