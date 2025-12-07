function GetQuestLvlModifier takes player p returns real
    local real lvl_modifier
    if udg_LVL_Req <= 1 then
        return 1.0
    endif
    set lvl_modifier = I2R(GetHeroLevel(udg_Heroes[GetPlayerHeroNumber(p)])) / I2R(udg_LVL_Req)
    if lvl_modifier > 1.0 then
        set lvl_modifier = 1.0
    endif
    return lvl_modifier
endfunction

function QuestRewards_NotifyPlayer takes nothing returns nothing
    local player p = GetEnumPlayer()
    local real mod = GetQuestLvlModifier(p)
    local integer pXP = 0
    local integer pGold = 0
    local string rewardText = ""
    local force f = null

    if udg_XP > 0 then
        set pXP = R2I(I2R(udg_XP) * mod)
        if pXP > 0 then
            set rewardText = rewardText + "|cff8080ff+" + I2S(pXP) + " XP|r "
        endif
    endif

    if udg_Gold > 0 then
        set pGold = R2I(I2R(udg_Gold) * mod)
        if pGold > 0 then
            call AdjustPlayerStateBJ(pGold, p, PLAYER_STATE_RESOURCE_GOLD)
            set rewardText = rewardText + "|cffffcc00+" + I2S(pGold) + " Gold|r "
        endif
    endif

    if rewardText != "" then
        // Send quest completion message only to this player
        set f = CreateForce()
        call ForceAddPlayer(f, p)
        call QuestMessageBJ(f, bj_QUESTMESSAGE_COMPLETED, rewardText)
        call DestroyForce(f)
        set f = null
    endif

    set p = null
endfunction

function QuestRewards takes string faction returns nothing
    local force players = null
    local string rewardText = ""
    local integer i = 0
    local real lvl_modifier = 0
    
    if faction == "A" then
        set players = udg_AlliancePlayers
    elseif faction == "H" then
        set players = udg_HordePlayers
    else
        return // Invalid faction, exit function
    endif
    
    // Add XP if > 0
    if udg_XP > 0 then
        set rewardText = rewardText + "|cff8080ff+" + I2S(udg_XP) + " XP|r "

        loop
            exitwhen i > 9
            // if GetHeroLevel(udg_Heroes[i]) >= udg_LVL_Req then
            if IsAllianceHero(udg_Heroes[i] ) and faction == "A" then                 
                call AddHeroXP(udg_Heroes[i], R2I(I2R(udg_XP) * GetQuestLvlModifier(GetOwningPlayer(udg_Heroes[i]))), true)
            elseif IsHordeHero(udg_Heroes[i] ) and faction == "H" then
                call AddHeroXP(udg_Heroes[i], R2I(I2R(udg_XP) * GetQuestLvlModifier(GetOwningPlayer(udg_Heroes[i]))), true)
            endif
            set i = i + 1
        endloop
    endif

    // Notify each player individually and apply gold per player
    if udg_XP > 0 or udg_Gold > 0 then
        call ForForce(players, function QuestRewards_NotifyPlayer)
        set udg_XP = 0
        set udg_Gold = 0
    endif

    // Nullify local variables to prevent memory leaks
    set players = null
endfunction

function QuestRewards_RoundRewards takes integer quest_int returns nothing
    if udg_QUEST_XP[quest_int] > 0 then
        set udg_QUEST_XP[quest_int] =((udg_QUEST_XP[quest_int] + 4) / 5) * 5
    endif

    if udg_QUEST_GOLD[quest_int] > 0 then
        set udg_QUEST_GOLD[quest_int] =((udg_QUEST_GOLD[quest_int] + 4) / 5) * 5
    endif
endfunction

function QuestRewards_TextSet takes integer quest_int returns nothing
    set udg_QUEST_XP[quest_int] = R2I((I2R(udg_QUEST_XP[quest_int]) * udg_QUEST_XP_MULTIPLIER))
    set udg_QUEST_GOLD[quest_int] = R2I((I2R(udg_QUEST_GOLD[quest_int]) * udg_QUEST_GOLD_MULTIPLIER))
    call QuestRewards_RoundRewards(quest_int)
    if udg_QUEST_XP[quest_int] > 0 then
        set udg_TempString_Quest =(" +" +(I2S(udg_QUEST_XP[quest_int]) + " xp") )
    endif
    if udg_QUEST_GOLD[quest_int] > 0 then
        set udg_TempString_Quest =( (udg_TempString_Quest + " +") +(I2S(udg_QUEST_GOLD[quest_int]) + " gold") )
    endif
    set udg_TempString =(udg_TempString +("|n|n|cffffcc00Rewards:|r " + udg_TempString_Quest) )
    if udg_QUEST_LVL_REQ[quest_int] > 0 then
        set udg_TempString =(udg_TempString +("|n|cffc0c0c0Must be lvl " + I2S(udg_QUEST_LVL_REQ[quest_int]) + " or above to earn full rewards.|r") )
    endif
endfunction

