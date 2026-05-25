function Trig_H_Ass_ComboGen_2x_Conditions takes nothing returns boolean
    return GetSpellAbilityUnit() == udg_yH_Ass_Rogue and udg_HAssEviscerate
endfunction

function Trig_H_Ass_ComboGen_2x_ShowOrb takes unit hero, integer orbIndex, string attachmentPoint returns nothing
    call DestroyEffectBJ(udg_HAssComboEffects[orbIndex])
    call AddSpecialEffectTargetUnitBJ(attachmentPoint, hero, "RedSpellOrb.mdx")
    call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.18)
    set udg_HAssComboEffects[orbIndex] = GetLastCreatedEffectBJ()
endfunction

function Trig_H_Ass_ComboGen_2x_ShowText takes unit hero, string text returns nothing
    call CreateTextTagUnitBJ(text, hero, 10.00, 8.00, 100, 100, 0.00, 0)
    call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 64, 0.00)
    call SetTextTagPermanentBJ(GetLastCreatedTextTag(), false)
    call SetTextTagLifespanBJ(GetLastCreatedTextTag(), 1.00)
    call SetTextTagFadepointBJ(GetLastCreatedTextTag(), 0.50)
    call ShowTextTagForceBJ(true, GetLastCreatedTextTag(), udg_HordePlayers)
endfunction

function Trig_H_Ass_ComboGen_2x_Actions takes nothing returns nothing
    local unit hero = udg_yH_Ass_Rogue

    if udg_HAssComboPoints == 0.00 then
        call Trig_H_Ass_ComboGen_2x_ShowOrb(hero, 0, "overhead")
        call Trig_H_Ass_ComboGen_2x_ShowOrb(hero, 1, "right hand")
        call Trig_H_Ass_ComboGen_2x_ShowText(hero, "TRIGSTR_5850")
        set udg_HAssComboPoints = udg_HAssComboPoints + 2.00
    elseif udg_HAssComboPoints == 1.00 then
        call Trig_H_Ass_ComboGen_2x_ShowOrb(hero, 1, "right hand")
        call Trig_H_Ass_ComboGen_2x_ShowOrb(hero, 2, "left hand")
        call Trig_H_Ass_ComboGen_2x_ShowText(hero, "TRIGSTR_2750")
        set udg_HAssComboPoints = udg_HAssComboPoints + 2.00
    elseif udg_HAssComboPoints == 2.00 then
        call Trig_H_Ass_ComboGen_2x_ShowOrb(hero, 2, "left hand")
        call Trig_H_Ass_ComboGen_2x_ShowText(hero, "TRIGSTR_2749")
        set udg_HAssComboPoints = udg_HAssComboPoints + 1.00
    endif

    call ComboPointFrameSetPoints(hero, udg_HAssComboPoints)
    set hero = null
endfunction

//===========================================================================
function InitTrig_H_Ass_ComboGen_2x takes nothing returns nothing
    set gg_trg_H_Ass_ComboGen_2x = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_H_Ass_ComboGen_2x, Condition( function Trig_H_Ass_ComboGen_2x_Conditions ) )
    call TriggerAddAction( gg_trg_H_Ass_ComboGen_2x, function Trig_H_Ass_ComboGen_2x_Actions )
endfunction

