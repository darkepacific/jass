//===========================================================================
// RAGNOK - FEL ORBS
//
// 3 Firebolt effects orbit Ragnok for 3.60 seconds.
//
// Periodic:
//      0.02 sec visual update
//
// Every 0.20 seconds:
//      150 magic damage in 250 AoE
//      If at least one enemy is hit, Ragnok restores 3% max HP
//
// Healing happens ONCE per damage cycle regardless of number of targets.
//===========================================================================


//===========================================================================
// FEL ORBS COOLDOWN END
//===========================================================================

function Ragnok_Fel_Orbs_Cooldown_End takes nothing returns nothing
        call EnableTrigger(gg_trg_Ragnok_Fel_Orbs)
endfunction


//===========================================================================
// FEL ORBS END
//===========================================================================

function Ragnok_Fel_Orbs_End takes nothing returns nothing

    call DisableTrigger(RFO_Periodic)

    if RFO_Orb1 != null then
        call DestroyEffect(RFO_Orb1)
    endif

    if RFO_Orb2 != null then
        call DestroyEffect(RFO_Orb2)
    endif

    if RFO_Orb3 != null then
        call DestroyEffect(RFO_Orb3)
    endif

    if RFO_Group != null then
        call DestroyGroup(RFO_Group)
    endif

    set RFO_Orb1 = null
    set RFO_Orb2 = null
    set RFO_Orb3 = null

    set RFO_Group = null
    set RFO_Caster = null

    set RFO_Tick = 0
    set RFO_DamageTick = 0
    set RFO_Angle = 0.00

    // Six additional seconds before Fel Orbs may trigger again.
    call TimerStart(RFO_CooldownTimer, 6.00, false, function Ragnok_Fel_Orbs_Cooldown_End)

endfunction


//===========================================================================
// FEL ORBS PERIODIC LOOP
//
// Runs every 0.02 seconds.
//
// Every 0.20 seconds:
//      150 magic damage in 250 AoE
//
// Healing scales with enemies hit:
//      1 enemy  = 1.5% max HP
//      2 enemies = 3.0% max HP
//      3+ enemies = 4.5% max HP
//===========================================================================

function Ragnok_Fel_Orbs_Periodic takes nothing returns nothing
    local unit u
    local effect damageEffect
    local effect healEffect

    local integer hitCount = 0

    local real cx
    local real cy
    local real cz

    // End immediately if Ragnok dies.
    if RFO_Caster == null or GetWidgetLife(RFO_Caster) <= 0.405 then
        call Ragnok_Fel_Orbs_End()
        return
    endif

    // 180 ticks * 0.02 = 3.60 seconds.
    if RFO_Tick >= 180 then
        call Ragnok_Fel_Orbs_End()
        return
    endif

    set cx = GetUnitX(RFO_Caster)
    set cy = GetUnitY(RFO_Caster)
    set cz = BlzGetUnitZ(RFO_Caster) + 100.00


    //===========================================================================
    // ORBIT ORBS
    //===========================================================================

    // Orb 1
    call BlzSetSpecialEffectX(RFO_Orb1, cx + 160.00 * Cos(RFO_Angle * bj_DEGTORAD))
    call BlzSetSpecialEffectY(RFO_Orb1, cy + 160.00 * Sin(RFO_Angle * bj_DEGTORAD))
    call BlzSetSpecialEffectZ(RFO_Orb1, cz)

    // Orb 2
    call BlzSetSpecialEffectX(RFO_Orb2, cx + 160.00 * Cos((RFO_Angle + 120.00) * bj_DEGTORAD))
    call BlzSetSpecialEffectY(RFO_Orb2, cy + 160.00 * Sin((RFO_Angle + 120.00) * bj_DEGTORAD))
    call BlzSetSpecialEffectZ(RFO_Orb2, cz)

    // Orb 3
    call BlzSetSpecialEffectX(RFO_Orb3, cx + 160.00 * Cos((RFO_Angle + 240.00) * bj_DEGTORAD))
    call BlzSetSpecialEffectY(RFO_Orb3, cy + 160.00 * Sin((RFO_Angle + 240.00) * bj_DEGTORAD))
    call BlzSetSpecialEffectZ(RFO_Orb3, cz)

    // Degrees every 0.02 seconds.
    set RFO_Angle = RFO_Angle + 6.00

    if RFO_Angle >= 360.00 then
        set RFO_Angle = RFO_Angle - 360.00
    endif


    //===========================================================================
    // DAMAGE TIMER
    //
    // 10 ticks * 0.02 = 0.20 seconds.
    //===========================================================================

    set RFO_DamageTick = RFO_DamageTick + 1

    if RFO_DamageTick >= 10 then

        set RFO_DamageTick = 0
        set hitCount = 0

        call GroupEnumUnitsInRange(RFO_Group, cx, cy, 250.00, null)

        loop
            set u = FirstOfGroup(RFO_Group)
            exitwhen u == null

            call GroupRemoveUnit(RFO_Group, u)

            if GetWidgetLife(u) > 0.405 and IsUnitEnemy(u, GetOwningPlayer(RFO_Caster)) then

                // Count enemies hit this damage cycle.
                set hitCount = hitCount + 1

                // Deal 150 magic damage.
                call UnitDamageTarget(RFO_Caster, u, 150.00, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)


                //===============================================================
                // DAMAGE EFFECTS
                //===============================================================

                set damageEffect = AddSpecialEffect("Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl", GetUnitX(u), GetUnitY(u))
                call BlzSetSpecialEffectZ(damageEffect, BlzGetUnitZ(u) + 60.00)
                call BlzSetSpecialEffectScale(damageEffect, 2.00)
                call DestroyEffect(damageEffect)

                set damageEffect = AddSpecialEffect("Abilities\\Weapons\\GreenDragonMissile\\GreenDragonMissile.mdl", GetUnitX(u), GetUnitY(u))
                call BlzSetSpecialEffectZ(damageEffect, BlzGetUnitZ(u) + 60.00)
                call DestroyEffect(damageEffect)

                set damageEffect = null

            endif
        endloop


        //=======================================================================
        // LIFE DRAIN
        //
        // 1 target  = 1.5%
        // 2 targets = 3.0%
        // 3+ targets = 4.5%
        //=======================================================================

        if hitCount > 0 then

            if hitCount > 3 then
                set hitCount = 3
            endif

            call PercentHealthRestore(0.015 * I2R(hitCount), RFO_Caster)

            set healEffect = AddSpecialEffectTarget("war3mapImported\\Heal Green.mdx", RFO_Caster, "origin")
            call DestroyEffect(healEffect)
            set healEffect = null

        endif

    endif

    set RFO_Tick = RFO_Tick + 1

    set u = null
    set damageEffect = null
    set healEffect = null
endfunction

//===========================================================================
// FEL ORBS START
//===========================================================================

function Ragnok_Fel_Orbs_Start takes unit caster returns nothing

    set RFO_Caster = caster

    set RFO_Tick = 0
    set RFO_DamageTick = 0
    set RFO_Angle = 0.00

    set RFO_Group = CreateGroup()

    set RFO_Orb1 = AddSpecialEffect("war3mapImported\\Firebolt.mdx", GetUnitX(caster), GetUnitY(caster))
    set RFO_Orb2 = AddSpecialEffect("war3mapImported\\Firebolt.mdx", GetUnitX(caster), GetUnitY(caster))
    set RFO_Orb3 = AddSpecialEffect("war3mapImported\\Firebolt.mdx", GetUnitX(caster), GetUnitY(caster))

    call EnableTrigger(RFO_Periodic)

endfunction


//===========================================================================
// FEL ORBS ACTIVATION TRIGGER
//===========================================================================

function Trig_Ragnok_Fel_Orbs_Conditions takes nothing returns boolean
    return GetUnitState(GetTriggerUnit(), UNIT_STATE_LIFE) <= GetUnitState(GetTriggerUnit(), UNIT_STATE_MAX_LIFE) * 0.90
endfunction


function Trig_Ragnok_Fel_Orbs_Actions takes nothing returns nothing

    call DisableTrigger(GetTriggeringTrigger())

    call Ragnok_Fel_Orbs_Start(GetTriggerUnit())

endfunction


//===========================================================================
function InitTrig_Ragnok_Fel_Orbs takes nothing returns nothing

    set gg_trg_Ragnok_Fel_Orbs = CreateTrigger()

    call TriggerRegisterUnitEvent(gg_trg_Ragnok_Fel_Orbs, gg_unit_H04F_0713, EVENT_UNIT_DAMAGED)

    call TriggerAddCondition(gg_trg_Ragnok_Fel_Orbs, Condition(function Trig_Ragnok_Fel_Orbs_Conditions))
    call TriggerAddAction(gg_trg_Ragnok_Fel_Orbs, function Trig_Ragnok_Fel_Orbs_Actions)


    //===========================================================================
    // Smooth 0.02 second orbital animation trigger.
    //===========================================================================

    set RFO_Periodic = CreateTrigger()

    call TriggerRegisterTimerEvent(RFO_Periodic, 0.02, true)
    call TriggerAddAction(RFO_Periodic, function Ragnok_Fel_Orbs_Periodic)

    call DisableTrigger(RFO_Periodic)


    // Cooldown timer.
    set RFO_CooldownTimer = CreateTimer()

endfunction