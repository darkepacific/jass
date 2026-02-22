function Trig_Frozen_Orb_Conditions takes nothing returns boolean
    return GetSpellAbilityId() == 'A0D9'
endfunction

function Trig_Frozen_Orb_Actions takes nothing returns nothing
    local unit caster = GetTriggerUnit()
    local integer o
    local location pt_cast
    local location polar
    local location tgt

    // Pick the frost mage slot (only two frost mages exist)
    if (GetUnitTypeId(caster) == 'H00A') then
        set o = udg_z_MA_FROS_A
    else
        set o = udg_z_MA_FROS_H
    endif

    call PlaySoundOnUnitBJ(gg_snd_FrozenOrbCast, 90.00, caster)

    // Spawn orb slightly in front of caster
    set pt_cast = GetUnitLoc(caster)
    set polar = PolarProjectionBJ(pt_cast, 80.00, GetUnitFacing(caster))
    call CreateNUnitsAtLoc(1, 'e03Z', GetOwningPlayer(caster), polar, GetUnitFacing(caster))
    set udg_SpellUnits[o] = GetLastCreatedUnit()

    call RemoveLocation(polar)
    call RemoveLocation(pt_cast)

    // Order orb to move to target
    set tgt = GetSpellTargetLoc()
    call IssuePointOrderLocBJ(udg_SpellUnits[o], "move", tgt)
    call RemoveLocation(tgt)

    call FrozenOrb_Tick(caster, o)
    call GameTimeWait(0.4)
    call FrozenOrb_Tick(caster, o)
    call GameTimeWait(0.4)
    call FrozenOrb_Tick(caster, o)
    call GameTimeWait(0.4)
    call FrozenOrb_Tick(caster, o)
    call GameTimeWait(0.4)
    call FrozenOrb_Tick(caster, o)
    call GameTimeWait(0.4)

    call FrozenOrb_Explode(caster, o)

    set caster = null
endfunction

function InitTrig_Frozen_Orb takes nothing returns nothing
    set gg_trg_Frozen_Orb = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Frozen_Orb, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    call TriggerAddCondition(gg_trg_Frozen_Orb, Condition(function Trig_Frozen_Orb_Conditions))
    call TriggerAddAction(gg_trg_Frozen_Orb, function Trig_Frozen_Orb_Actions)
endfunction
