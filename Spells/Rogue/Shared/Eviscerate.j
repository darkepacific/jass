function Trig_Eviscerate_IsSupportedHero takes unit hero returns boolean
    return hero == udg_yA_Ass_Rogue or hero == udg_yH_Ass_Rogue or hero == udg_yA_Combat_Rogue or hero == udg_yH_Combat_Rogue or hero == udg_yA_Subtle_Rogue or hero == udg_yH_Subtle_Rogue
endfunction

function Trig_Eviscerate_GetComboPoints takes unit hero returns real
    if hero == udg_yA_Ass_Rogue then
        return udg_AAssComboPoints
    elseif hero == udg_yH_Ass_Rogue then
        return udg_HAssComboPoints
    elseif hero == udg_yA_Combat_Rogue then
        return udg_WRComboPoints
    elseif hero == udg_yH_Combat_Rogue then
        return udg_URComboPoints
    elseif hero == udg_yA_Subtle_Rogue then
        return udg_NERComboPoints
    elseif hero == udg_yH_Subtle_Rogue then
        return udg_BERComboPoints
    endif
    return 0.00
endfunction

function Trig_Eviscerate_GetTextForce takes unit hero returns force
    if hero == udg_yA_Ass_Rogue or hero == udg_yA_Combat_Rogue or hero == udg_yA_Subtle_Rogue then
        return udg_AlliancePlayers
    endif
    return udg_HordePlayers
endfunction

function Trig_Eviscerate_ShowDamageText takes unit target, real amount, force textForce returns nothing
    call CreateTextTagUnitBJ((R2SW(amount, 4, 0) + " Damage!"), target, 13.00, 10.00, 100, 0.00, 0.00, 0)
    call SetTextTagVelocityBJ(GetLastCreatedTextTag(), 64, 90.00)
    call cleanUpText(1.0, 0.5)
    call ShowTextTagForceBJ(true, GetLastCreatedTextTag(), textForce)
endfunction

function Trig_Eviscerate_Conditions takes nothing returns boolean
    return GetSpellAbilityId() == 'A017' and Trig_Eviscerate_IsSupportedHero(GetTriggerUnit())
endfunction

function Trig_Eviscerate_Actions takes nothing returns nothing
    local unit caster = GetTriggerUnit()
    local unit target = GetSpellTargetUnit()
    local force textForce = Trig_Eviscerate_GetTextForce(caster)
    local real comboPoints = Trig_Eviscerate_GetComboPoints(caster)
    local integer abilityLevel = GetUnitAbilityLevel(caster, 'A017')
    local real bonusDamage = 100.00 * (comboPoints * I2R(abilityLevel))
    local real displayedDamage = (50.00 + (50.00 * I2R(abilityLevel))) + ((I2R(abilityLevel) * 100.00) * comboPoints)

    call PlaySoundOnUnitBJ(gg_snd_ArtilleryCorpseExplodeDeath1, 100.00, caster)
    call UnitDamageTargetBJ(caster, target, bonusDamage, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL)
    call Trig_Eviscerate_ShowDamageText(target, displayedDamage, textForce)
    call ResetComboPoints(caster)
    call GameTimeWait(0.10)
    call TryProcRuthlessness(caster, comboPoints, textForce)

    set textForce = null
    set target = null
    set caster = null
endfunction

//===========================================================================
function InitTrig_Eviscerate takes nothing returns nothing
    set gg_trg_Eviscerate = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Eviscerate, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_Eviscerate, Condition( function Trig_Eviscerate_Conditions ) )
    call TriggerAddAction( gg_trg_Eviscerate, function Trig_Eviscerate_Actions )
endfunction

