function Trig_A_Ass_ComboGen_2x_Conditions takes nothing returns boolean
    return GetSpellAbilityUnit() == udg_yA_Ass_Rogue and udg_AAssEviscerate
endfunction

function Trig_A_Ass_ComboGen_2x_ShowOrb takes unit hero, integer orbIndex, string attachmentPoint returns nothing
    call DestroyEffectBJ(udg_AAssComboEffects[orbIndex])
    call AddSpecialEffectTargetUnitBJ(attachmentPoint, hero, "RedSpellOrb.mdx")
    call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.18)
    set udg_AAssComboEffects[orbIndex] = GetLastCreatedEffectBJ()
endfunction

function Trig_A_Ass_ComboGen_2x_Actions takes nothing returns nothing
    local unit hero = udg_yA_Ass_Rogue

    if udg_AAssComboPoints == 0.00 then
        call Trig_A_Ass_ComboGen_2x_ShowOrb(hero, 0, "overhead")
        call Trig_A_Ass_ComboGen_2x_ShowOrb(hero, 1, "right hand")
        call ComboGenShowText(hero, 2)
        set udg_AAssComboPoints = udg_AAssComboPoints + 2.00
    elseif udg_AAssComboPoints == 1.00 then
        call Trig_A_Ass_ComboGen_2x_ShowOrb(hero, 1, "right hand")
        call Trig_A_Ass_ComboGen_2x_ShowOrb(hero, 2, "left hand")
        call ComboGenShowText(hero, 2)
        set udg_AAssComboPoints = udg_AAssComboPoints + 2.00
    elseif udg_AAssComboPoints == 2.00 then
        call Trig_A_Ass_ComboGen_2x_ShowOrb(hero, 2, "left hand")
        call ComboGenShowText(hero, 1)
        set udg_AAssComboPoints = udg_AAssComboPoints + 1.00
    endif

    call ComboPointFrameSetPoints(hero, udg_AAssComboPoints)
    set hero = null
endfunction

//===========================================================================
function InitTrig_A_Ass_ComboGen_2x takes nothing returns nothing
    set gg_trg_A_Ass_ComboGen_2x = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_A_Ass_ComboGen_2x, Condition( function Trig_A_Ass_ComboGen_2x_Conditions ) )
    call TriggerAddAction( gg_trg_A_Ass_ComboGen_2x, function Trig_A_Ass_ComboGen_2x_Actions )
endfunction

