function Trig_H_Ass_ComboGen_IsComboGenerator takes integer abilityId returns boolean
    if abilityId == 'A0AM' then // Shadowstep (Acid)
        return true
    elseif abilityId == 'A09J' then // Garrote
        return true
    elseif abilityId == 'AEfk' then // Fan of Knives
        return true
    elseif abilityId == 'A06M' then // Smoke Bomb (Max)
        return true
    elseif abilityId == 'A04S' then // Sap
        return true
    endif
    return false
endfunction

function Trig_H_Ass_ComboGen_Conditions takes nothing returns boolean
    return GetSpellAbilityUnit() == udg_yH_Ass_Rogue and udg_HAssEviscerate and Trig_H_Ass_ComboGen_IsComboGenerator(GetSpellAbilityId())
endfunction

function Trig_H_Ass_ComboGen_ShowOrb takes unit hero, integer orbIndex, string attachmentPoint returns nothing
    call DestroyEffectBJ(udg_HAssComboEffects[orbIndex])
    call AddSpecialEffectTargetUnitBJ(attachmentPoint, hero, "RedSpellOrb.mdx")
    call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.18)
    set udg_HAssComboEffects[orbIndex] = GetLastCreatedEffectBJ()
endfunction

function Trig_H_Ass_ComboGen_ShowText takes unit hero returns nothing
    call CreateTextTagUnitBJ("TRIGSTR_5703", hero, 10.00, 8.00, 100, 100, 0.00, 0)
    call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 64, 0.00)
    call SetTextTagPermanentBJ(GetLastCreatedTextTag(), false)
    call SetTextTagLifespanBJ(GetLastCreatedTextTag(), 1.00)
    call SetTextTagFadepointBJ(GetLastCreatedTextTag(), 0.50)
    call ShowTextTagForceBJ(true, GetLastCreatedTextTag(), udg_HordePlayers)
endfunction

function Trig_H_Ass_ComboGen_Actions takes nothing returns nothing
    local unit hero = udg_yH_Ass_Rogue

    if udg_HAssComboPoints == 0.00 then
        call Trig_H_Ass_ComboGen_ShowOrb(hero, 0, "overhead")
    elseif udg_HAssComboPoints == 1.00 then
        call Trig_H_Ass_ComboGen_ShowOrb(hero, 1, "right hand")
    elseif udg_HAssComboPoints == 2.00 then
        call Trig_H_Ass_ComboGen_ShowOrb(hero, 2, "left hand")
    endif

    if udg_HAssComboPoints < 3.00 then
        call Trig_H_Ass_ComboGen_ShowText(hero)
        set udg_HAssComboPoints = udg_HAssComboPoints + 1.00
    endif

    call ComboPointFrameSetPoints(hero, udg_HAssComboPoints)
    set hero = null
endfunction

//===========================================================================
function InitTrig_H_Ass_ComboGen takes nothing returns nothing
    set gg_trg_H_Ass_ComboGen = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_H_Ass_ComboGen, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_H_Ass_ComboGen, Condition( function Trig_H_Ass_ComboGen_Conditions ) )
    call TriggerAddAction( gg_trg_H_Ass_ComboGen, function Trig_H_Ass_ComboGen_Actions )
endfunction

