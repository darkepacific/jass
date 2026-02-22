globals
    unit gg_FrozenOrb_Caster = null
    real gg_FrozenOrb_Dmg = 0.00
endglobals

//================ DAMAGE CALCULATIONS =================

function CalculateFrozenOrbDmg takes unit caster, boolean isExploding returns real
    local integer lvl = GetUnitAbilityLevel(caster, 'A0D9')
    local integer baseInt = GetHeroStatBJ(bj_HEROSTAT_INT, caster, false)
    local integer totalInt = GetHeroStatBJ(bj_HEROSTAT_INT, caster, true)
    local integer bonusInt = totalInt - baseInt

    local real flat
    local real baseCoeff
    local real bonusCoeff

    if not isExploding then
        if (lvl <= 1) then
            set flat = 30.00
            set baseCoeff = 0.25
            set bonusCoeff = 0.50
        elseif (lvl == 2) then
            set flat = 45.00
            set baseCoeff = 0.25
            set bonusCoeff = 0.75
        else
            set flat = 5.00
            set baseCoeff = 0.50
            set bonusCoeff = 1.00
        endif
    else
        if (lvl <= 1) then
            set flat = 220.00
            set baseCoeff = 1.75
            set bonusCoeff = 3.50
        elseif (lvl == 2) then
            set flat = 310.00
            set baseCoeff = 1.75
            set bonusCoeff = 5.25
        else
            set flat = 35.00
            set baseCoeff = 5.00
            set bonusCoeff = 7.00
        endif
    endif

    return flat + baseCoeff * I2R(baseInt) + bonusCoeff * I2R(bonusInt)
endfunction

//================ DAMAGE APPLICATION =================

function FrozenOrb_GroupDamage takes nothing returns nothing
    local unit u = GetEnumUnit()

    call SetUnitOwner( gg_unit_e028_1863, GetOwningPlayer(gg_FrozenOrb_Caster), true )
    if (IsUnitTargetableEnemy(u, gg_FrozenOrb_Caster)) then
        call IssueTargetOrderBJ(gg_unit_e028_1863, "slow", u)
        call DestroyEffect(AddSpecialEffectTarget("origin", u, "war3mapImported\\Blizzard II Missile"))
        call UnitDamageTarget(gg_FrozenOrb_Caster, u, gg_FrozenOrb_Dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)
        call HasFirelords(u)
    endif

    set u = null
endfunction

function FrozenOrb_ApplyAoE takes unit caster, integer o, real radius, real dmg, boolean killOrb returns nothing
    local unit orb = udg_SpellUnits[o]
    local location p

    if (caster == null or orb == null) then
        return
    endif

    set udg_Temp_Unit = caster
    call TriggerExecute(gg_trg_Firelords_Helper)

    set gg_FrozenOrb_Caster = caster
    set gg_FrozenOrb_Dmg = dmg

    set p = GetUnitLoc(orb)

    if (killOrb) then
        call KillUnit(orb)
    endif

    call DestroyEffect(AddSpecialEffectLoc("war3mapImported\\RemorselessWinter.mdx", p))

    set bj_wantDestroyGroup = true
    call ForGroupBJ(GetUnitsInRangeOfLocAll(radius, p), function FrozenOrb_GroupDamage)

    call RemoveLocation(p)

    set p = null
    set orb = null
endfunction

function FrozenOrb_Tick takes unit caster, integer o returns nothing
    call FrozenOrb_ApplyAoE(caster, o, 250.00, CalculateFrozenOrbDmg(caster, false), false)
endfunction

function FrozenOrb_Explode takes unit caster, integer o returns nothing
    call FrozenOrb_ApplyAoE(caster, o, 300.00, CalculateFrozenOrbDmg(caster, true), true)
endfunction
