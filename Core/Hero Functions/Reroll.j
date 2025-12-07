function IsSummonedLikeUnit takes unit u returns boolean
    return (IsUnitType(u, UNIT_TYPE_SUMMONED) or GetUnitAbilityLevel(u, 'BTLF') > 0 or GetUnitAbilityLevel(u, 'BTLS') > 0)
endfunction

// Instantly kills all "summoned-like" units for a single player.
function KillAllSummonedUnitsForPlayer takes player whichPlayer returns nothing
    local group g = CreateGroup()
    local unit  u

    call GroupEnumUnitsOfPlayer(g, whichPlayer, null)
    loop
        set u = FirstOfGroup(g)
        exitwhen u == null
        call GroupRemoveUnit(g, u)

        if IsSummonedLikeUnit(u) then
            call KillUnit(u)
        endif
    endloop

    call DestroyGroup(g)
    set g = null
    set u = null
endfunction


function Trig_REROLL_Actions takes nothing returns nothing 
    local player p = GetTriggerPlayer() 
    local integer playerNumber = GetPlayerHeroNumber(p)
    local unit hero = udg_Heroes[playerNumber] 
    local location returnPoint
    local integer i = 0

    call Debug("Rerolling Player " + I2S(playerNumber) + "'s hero: " + GetUnitName(hero) )
    if IsInCombat(hero) then 
        call ErrorMessage("Cannot change heroes while in combat.", p)
        set p = null
        set hero = null
        return
    elseif CheckIfMorphed(hero) then 
        call ErrorMessage("Cannot change heroes while morphed.", p)
        set p = null
        set hero = null
        return 
    else
        //This line exists to see if a reroll is being done from the hero selection screen
        // if(udg_Heroes[playerNumber] != null) then 
        //Reset Items
            
        if(udg_Heroes[playerNumber] != null) then 
            // Cam and Replace 
            call StartTimerBJ(udg_RespawnTimer[playerNumber], false, 0.25) 
            call PauseTimerBJ(true, udg_RespawnTimer[playerNumber]) 
            call DestroyTimerDialogBJ(udg_DeathTimerWindows[playerNumber]) 
            call RemoveDestructable(udg_Graves[playerNumber]) 
            // call SetCameraFieldForPlayer(p, CAMERA_FIELD_TARGET_DISTANCE, udg_Z_Camera[playerNumber], 0) 
            set udg_Player_Music[playerNumber] = "WoW Music"

            call IssueImmediateOrderBJ(hero, "stop") 
            call TalentResetDo(hero, 999999, true )
            call SetUnitOwner(hero, Player(PLAYER_NEUTRAL_PASSIVE), true ) 
            set returnPoint = GetRectCenter(gg_rct_Reroll)
            call SetUnitPositionLoc(hero, returnPoint)
            call RemoveLocation(returnPoint)   
            call SetUnitInvulnerable(hero, true) 
            call PauseUnit(hero, true)    

            call RefreshTalentUINoSound(p) 
            if udg_GameMode == "Normal" then
                call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, 500)
            endif
            
            //Reset Inventory
            call ResetInventory(p)

            call KillAllSummonedUnitsForPlayer(p)

            // Turn off conditionals
            call TurnOffComboGen(hero)
            set udg_Heroes[playerNumber] = null 
            // May need to remove hero from 
        endif
 
        if GetLocalPlayer() == p then
            call ClearMapMusicBJ()
            call StopMusicBJ(false )
            call EndThematicMusicBJ()
            call PlayMusicBJ(gg_snd_Legends_of_Azeroth )
            
            call SetMusicVolumeBJ(80.00 )
        endif
        call PlayerReturnToHeroSelection(p)

        // endif 
    endif 
    set p = null 
    set hero = null 
    set returnPoint = null
endfunction 


//=========================================================================== 
function InitTrig_REROLL takes nothing returns nothing 
    set gg_trg_REROLL = CreateTrigger() 
    call TriggerAddAction(gg_trg_REROLL, function Trig_REROLL_Actions) 
endfunction 

