function Trig_The_Hunt_Tick_H_Actions takes nothing returns nothing
    local unit caster = udg_yH_Demon_Hunt
    local integer i = 46
    local integer o = udg_z_DH_VENG_H + 8
    local unit target = udg_SpellUnits[o]
    local location begin = GetUnitLoc( caster)
    local location end = GetUnitLoc( target)
    local real dist = DistanceBetweenPoints(begin, end)
    local real angle = AngleBetweenPoints(begin, end)
    local real damage = 0
    local real lvl 
    
    call SetUnitFacing(caster, angle)
    call PauseAddInvuln(caster, null)
    call UnitAddAbility( caster, 'Amrf' )
    call UnitShareVisionBJ( true, target , GetOwningPlayer(caster ) )
    
    call SetUnitPathing( caster, false)
    call SetUnitFlyHeight(caster, 100, 0.0)
    set udg_Charge_Loop[i] = udg_Charge_Loop[i] + 1

    if dist > 100 and udg_Charge_Loop[i] < 150 then
        call RemoveLocation(end)
        set end = PolarProjectionBJ(begin, 32 + udg_Charge_Loop[i], angle)
        call SetUnitPositionLocFacingBJ( caster, end, angle)
    else
        // calc dmg 
        set lvl = I2R(GetUnitAbilityLevel(caster, 'A0G2'))
        set damage = I2R(( GetHeroStatBJ(bj_HEROSTAT_AGI, caster, true)  )) //- GetHeroStatBJ(bj_HEROSTAT_AGI, caster, false)
        set damage = ( (2+lvl) * damage )
        set damage = damage + ( lvl * 100 )
        set damage = damage + 100
        call UnitDamageTargetBJ(caster, target, damage, ATTACK_TYPE_HERO , DAMAGE_TYPE_NORMAL )
        call DummyStun(caster, target, 1.0, begin)

        // apply firelords
        call HasFirelordsPlayerNumber(target, GetPlayerHeroNumber(GetOwningPlayer(caster)))

        call UnitShareVisionBJ( false, target , GetOwningPlayer(caster ) )
        call SetUnitPathing( caster, true)
        call SetUnitFlyHeight(caster,0, 0.0)
        call UnPauseAddInvuln(caster, null)

        call DestroyEffectBJ( udg_Charge_SE[i] )
        call DisableTrigger( GetTriggeringTrigger() )
    endif
   
    call UnitRemoveAbility( caster, 'Amrf' )
    call RemoveLocation(begin)
    call RemoveLocation(end)
    set begin = null
    set end = null
    set target = null
    set caster = null
endfunction


//===========================================================================
function InitTrig_The_Hunt_Tick_H takes nothing returns nothing
    set gg_trg_The_Hunt_Tick_H = CreateTrigger(  )
    call DisableTrigger( gg_trg_The_Hunt_Tick_H )
    call TriggerRegisterTimerEventPeriodic( gg_trg_The_Hunt_Tick_H, 0.02 )
    call TriggerAddAction( gg_trg_The_Hunt_Tick_H, function Trig_The_Hunt_Tick_H_Actions )
endfunction

