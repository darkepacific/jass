//===========================================================================
// RAGNOK - FEL BURST
//
// Ragnok charges 600 units in a locked direction.
//
// Movement:
//      30 units every 0.02 sec
//      20 steps
//      600 total distance
//      0.40 sec total charge
//
// Burning Trail:
//      Every 5 movement ticks = 0.10 sec
//      180 AoE
//      300 magic damage
//      Each unit may only take trail damage once per charge
//
// Terminal Explosion:
//      300 AoE
//      800 magic damage
//===========================================================================


//===========================================================================
// FEL BURST COOLDOWN END
//===========================================================================

function Ragnok_Fel_Burst_Cooldown_End takes nothing returns nothing
        call EnableTrigger(gg_trg_Ragnok_Fel_Burst)
endfunction


//===========================================================================
// CREATE BURNING TRAIL PATCH
//===========================================================================

function Ragnok_Fel_Burst_Trail takes real x, real y returns nothing
    local effect e
    local unit u

    set e = AddSpecialEffect("war3mapImported\\Firebrand Shot Green.mdx", x, y)
    call BlzSetSpecialEffectScale(e, 2.00)
    call DestroyEffect(e)

    set e = null


    //===========================================================================
    // Damage enemies caught in this trail patch.
    // Each unit may only take trail damage once during the entire charge.
    //===========================================================================

    call GroupEnumUnitsInRange(RFB_Group, x, y, 180.00, null)

    loop
        set u = FirstOfGroup(RFB_Group)
        exitwhen u == null

        call GroupRemoveUnit(RFB_Group, u)

        if GetWidgetLife(u) > 0.405 and IsUnitEnemy(u, GetOwningPlayer(RFB_Caster)) and not IsUnitInGroup(u, RFB_TrailHit) then

            call UnitDamageTarget(RFB_Caster, u, 300.00, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)

            call GroupAddUnit(RFB_TrailHit, u)

        endif
    endloop

    set u = null
endfunction


//===========================================================================
// FEL BURST END
//===========================================================================

function Ragnok_Fel_Burst_End takes nothing returns nothing
    local effect e
    local unit u
    local real x
    local real y

    call DisableTrigger(RFB_Periodic)


    //===========================================================================
    // REMOVE CHARGE EFFECT
    //===========================================================================

    if RFB_ChargeEffect != null then
        call DestroyEffect(RFB_ChargeEffect)
        set RFB_ChargeEffect = null
    endif


    //===========================================================================
    // RESTORE RAGNOK
    //===========================================================================

    if RFB_Caster != null then
        call PauseUnit(RFB_Caster, false)
    endif


    //===========================================================================
    // TERMINAL EXPLOSION
    //===========================================================================

    if RFB_Caster != null and GetWidgetLife(RFB_Caster) > 0.405 then

        set x = GetUnitX(RFB_Caster)
        set y = GetUnitY(RFB_Caster)

        set e = AddSpecialEffect("war3mapImported\\Damnation Green.mdx", x, y)
        call DestroyEffect(e)
        set e = null

        call GroupEnumUnitsInRange(RFB_Group, x, y, 300.00, null)

        loop
            set u = FirstOfGroup(RFB_Group)
            exitwhen u == null

            call GroupRemoveUnit(RFB_Group, u)

            if GetWidgetLife(u) > 0.405 and IsUnitEnemy(u, GetOwningPlayer(RFB_Caster)) then

                call UnitDamageTarget(RFB_Caster, u, 800.00, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, WEAPON_TYPE_WHOKNOWS)

            endif
        endloop

    endif


    //===========================================================================
    // CLEANUP
    //===========================================================================

    if RFB_Group != null then
        call DestroyGroup(RFB_Group)
    endif

    if RFB_TrailHit != null then
        call DestroyGroup(RFB_TrailHit)
    endif

    set RFB_Group = null
    set RFB_TrailHit = null

    set RFB_Caster = null

    set RFB_Angle = 0.00
    set RFB_Step = 0

    set u = null
    set e = null


    call TimerStart(RFB_CooldownTimer, 9.00, false, function Ragnok_Fel_Burst_Cooldown_End)

endfunction


//===========================================================================
// FEL BURST PERIODIC
//
// Runs every 0.02 seconds.
//===========================================================================

function Ragnok_Fel_Burst_Periodic takes nothing returns nothing
    local unit u

    local real x
    local real y
    local real nextX
    local real nextY

    local boolean collided = false


    //===========================================================================
    // INVALID / DEAD CASTER
    //===========================================================================

    if RFB_Caster == null or GetWidgetLife(RFB_Caster) <= 0.405 then
        call Ragnok_Fel_Burst_End()
        return
    endif


    //===========================================================================
    // FINISHED FULL 600 UNIT CHARGE
    //===========================================================================

    if RFB_Step >= 30 then
        call Ragnok_Fel_Burst_End()
        return
    endif


    //===========================================================================
    // CALCULATE NEXT POSITION
    //===========================================================================

    set x = GetUnitX(RFB_Caster)
    set y = GetUnitY(RFB_Caster)

    set nextX = x + 20.00 * Cos(RFB_Angle)
    set nextY = y + 20.00 * Sin(RFB_Angle)


    //===========================================================================
    // TERRAIN COLLISION
    //===========================================================================

    if IsTerrainPathable(nextX, nextY, PATHING_TYPE_WALKABILITY) then
        call Ragnok_Fel_Burst_End()
        return
    endif


    //===========================================================================
    // MOVE RAGNOK
    //===========================================================================

    call SetUnitX(RFB_Caster, nextX)
    call SetUnitY(RFB_Caster, nextY)

    set RFB_Step = RFB_Step + 1


    //===========================================================================
    // BURNING TRAIL
    //
    // Every 5 ticks:
    //
    //      5 * 0.02 = 0.10 seconds
    //===========================================================================

    if ModuloInteger(RFB_Step, 5) == 0 then

        call Ragnok_Fel_Burst_Trail(GetUnitX(RFB_Caster), GetUnitY(RFB_Caster))

    endif


    //===========================================================================
    // UNIT COLLISION
    //===========================================================================

    set x = GetUnitX(RFB_Caster)
    set y = GetUnitY(RFB_Caster)

    call GroupEnumUnitsInRange(RFB_Group, x, y, 90.00, null)

    loop
        set u = FirstOfGroup(RFB_Group)
        exitwhen u == null

        call GroupRemoveUnit(RFB_Group, u)

        if GetWidgetLife(u) > 0.405 and IsUnitEnemy(u, GetOwningPlayer(RFB_Caster)) then
            set collided = true
        endif
    endloop

    set u = null


    //===========================================================================
    // EXPLODE ON COLLISION OR FINAL STEP
    //===========================================================================

    if collided or RFB_Step >= 20 then
        call Ragnok_Fel_Burst_End()
    endif

endfunction


//===========================================================================
// FEL BURST START
//===========================================================================

function Ragnok_Fel_Burst_Start takes unit caster, unit target returns nothing
    local real startX
    local real startY
    local real targetX
    local real targetY
    local real facing

    set RFB_Caster = caster

    set RFB_Group = CreateGroup()
    set RFB_TrailHit = CreateGroup()

    set RFB_Step = 0

    set startX = GetUnitX(caster)
    set startY = GetUnitY(caster)

    set targetX = GetUnitX(target)
    set targetY = GetUnitY(target)

    // Lock direction when the charge begins.
    set RFB_Angle = Atan2(targetY - startY, targetX - startX)

    set facing = RFB_Angle * bj_RADTODEG


    //===========================================================================
    // PREPARE RAGNOK
    //===========================================================================

    call IssueImmediateOrder(caster, "stop")
    call PauseUnit(caster, true)

    call SetUnitFacing(caster, facing)


    //===========================================================================
    // CHARGE EFFECT
    //===========================================================================

    set RFB_ChargeEffect = AddSpecialEffectTarget("war3mapImported\\Valiant Charge Fel.mdx", caster, "origin")


    //===========================================================================
    // INITIAL TRAIL PATCH
    //===========================================================================

    call Ragnok_Fel_Burst_Trail(startX, startY)


    //===========================================================================
    // BEGIN SMOOTH PERIODIC MOVEMENT
    //===========================================================================

    call EnableTrigger(RFB_Periodic)

endfunction


//===========================================================================
// FEL BURST ACTIVATION
//===========================================================================

function Trig_Ragnok_Fel_Burst_Conditions takes nothing returns boolean
    return GetUnitState(GetTriggerUnit(), UNIT_STATE_LIFE) <= GetUnitState(GetTriggerUnit(), UNIT_STATE_MAX_LIFE) * 0.79
endfunction


function Trig_Ragnok_Fel_Burst_Actions takes nothing returns nothing
    local unit caster = GetTriggerUnit()
    local unit target = GetClosestEnemyHero(caster, 1000.00)

    if target != null then

        call DisableTrigger(GetTriggeringTrigger())

        call Ragnok_Fel_Burst_Start(caster, target)

    endif

    set target = null
    set caster = null
endfunction


//===========================================================================
function InitTrig_Ragnok_Fel_Burst takes nothing returns nothing

    set gg_trg_Ragnok_Fel_Burst = CreateTrigger()

    call TriggerRegisterUnitEvent(gg_trg_Ragnok_Fel_Burst, gg_unit_H04F_0713, EVENT_UNIT_DAMAGED)

    call TriggerAddCondition(gg_trg_Ragnok_Fel_Burst, Condition(function Trig_Ragnok_Fel_Burst_Conditions))
    call TriggerAddAction(gg_trg_Ragnok_Fel_Burst, function Trig_Ragnok_Fel_Burst_Actions)


    //===========================================================================
    // Smooth 0.02 second charge movement trigger.
    //===========================================================================

    set RFB_Periodic = CreateTrigger()

    call TriggerRegisterTimerEvent(RFB_Periodic, 0.02, true)
    call TriggerAddAction(RFB_Periodic, function Ragnok_Fel_Burst_Periodic)

    call DisableTrigger(RFB_Periodic)


    // Cooldown timer.
    set RFB_CooldownTimer = CreateTimer()

endfunction