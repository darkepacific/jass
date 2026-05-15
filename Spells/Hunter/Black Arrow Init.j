function Trig_Black_Arrow_Init_Jass_Conditions takes nothing returns boolean
    if ( GetSpellAbilityId() == 'A05B'  ) then
        return true
    endif
    return false
endfunction


function Trig_Black_Arrow_Init_Jass_Actions takes nothing returns nothing
    local real dist
    local unit caster = GetTriggerUnit()
    set dist = 0.25
    if ( caster == udg_yH_Dark_Ranger ) then
        set udg_HunterShots[2] = GetSpellTargetUnit()
        call EnableTrigger( gg_trg_Black_Arrow_UD_Jass )
        set udg_Temp_Unit_Point = GetUnitLoc(caster)
        set udg_Temp_Polar_Point = GetUnitLoc(GetSpellTargetUnit())
        set dist = 0.25 + DistanceBetweenPoints(udg_Temp_Unit_Point, udg_Temp_Polar_Point)/3000
        call RemoveLocation(udg_Temp_Unit_Point)
        call RemoveLocation(udg_Temp_Polar_Point)
        call TriggerSleepAction(dist)
        call UnitDamageTargetBJ( caster, udg_HunterShots[2], ( 3.50 * ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, caster, true)) - I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, caster, false)) ) ), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC )
        call TriggerSleepAction( 0.96 )
        call DisableTrigger( gg_trg_Black_Arrow_UD_Jass )
    endif
    if( caster == udg_yA_Dark_Ranger ) then
        set udg_HunterShots[5] = GetSpellTargetUnit()
        call EnableTrigger( gg_trg_Black_Arrow_WG_Jass )
        set udg_Temp_Unit_Point = GetUnitLoc(caster)
        set udg_Temp_Polar_Point = GetUnitLoc(GetSpellTargetUnit())
        set dist = 0.25 + DistanceBetweenPoints(udg_Temp_Unit_Point, udg_Temp_Polar_Point)/3000
        call RemoveLocation(udg_Temp_Unit_Point)
        call RemoveLocation(udg_Temp_Polar_Point)
        call TriggerSleepAction(dist)
        call UnitDamageTargetBJ( caster, udg_HunterShots[5], ( 3.50 * ( I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, caster, true)) - I2R(GetHeroStatBJ(bj_HEROSTAT_AGI, caster, false)) ) ), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC )
        call TriggerSleepAction( 0.96 )
        call DisableTrigger( gg_trg_Black_Arrow_WG_Jass )
    endif
    set caster = null
endfunction

//===========================================================================
function InitTrig_Black_Arrow_Init_Jass takes nothing returns nothing
    set gg_trg_Black_Arrow_Init_Jass = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Black_Arrow_Init_Jass, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_Black_Arrow_Init_Jass, Condition( function Trig_Black_Arrow_Init_Jass_Conditions ) )
    call TriggerAddAction( gg_trg_Black_Arrow_Init_Jass, function Trig_Black_Arrow_Init_Jass_Actions )
endfunction

