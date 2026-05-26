function ProcRuthlessness takes unit hero returns nothing
    if hero == udg_yA_Ass_Rogue then
        call TriggerExecute(gg_trg_A_Ass_ComboGen)
    elseif hero == udg_yH_Ass_Rogue then
        call TriggerExecute(gg_trg_H_Ass_ComboGen)
    elseif hero == udg_yA_Combat_Rogue then
        call TriggerExecute(gg_trg_WR_ComboGen)
    elseif hero == udg_yH_Combat_Rogue then
        call TriggerExecute(gg_trg_UR_ComboGen)
    elseif hero == udg_yA_Subtle_Rogue then
        call TriggerExecute(gg_trg_NER_ComboGen)
    elseif hero == udg_yH_Subtle_Rogue then
        call TriggerExecute(gg_trg_BER_ComboGen)
    endif
endfunction

function TryProcRuthlessness takes unit hero, real comboPointsSpent, force textForce returns nothing
    local integer talentIndex = GetPlayerId(GetOwningPlayer(hero)) * udg_NUM_OF_TC + 10

    if comboPointsSpent > 0.00 and udg_TalentChoices[talentIndex] and GetRandomReal(0.0, 2.99) < comboPointsSpent then
        call CreateTextTagUnitBJ("Ruthless", hero, 12.00, 9.00, 40.00, 100.00, 40.00, 0)
        call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 64, 90.00)
        call cleanUpText(1.0, 0.5)
        call ShowTextTagForceBJ(true, GetLastCreatedTextTag(), textForce)
        call ProcRuthlessness(hero)
    endif
endfunction