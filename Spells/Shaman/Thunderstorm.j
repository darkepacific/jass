function Trig_Thunderstorm_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A0AK' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Thunderstorm_Func008Func001C takes nothing returns boolean
    if ( ( udg_RealStatCalc >= GetRandomReal(0, 1) ) ) then
        return true
    endif
    if ( ( udg_Temp_Bool == true ) ) then
        return true
    endif
    return false
endfunction

function Trig_Thunderstorm_Func008C takes nothing returns boolean
    if ( not Trig_Thunderstorm_Func008Func001C() ) then
        return false
    endif
    return true
endfunction

function Trig_Thunderstorm_Func013Func006Func019C takes nothing returns boolean
    if ( not ( IsUnitInGroup(GetEnumUnit(), udg_KnockBacks) == false ) ) then
        return false
    endif
    return true
endfunction

function Trig_Thunderstorm_Func013Func006C takes nothing returns boolean
    if ( not ( IsUnitEnemy(GetEnumUnit(), udg_X_Player_MUI) == true ) ) then
        return false
    endif
    if ( not ( IsUnitType(GetEnumUnit(), UNIT_TYPE_STRUCTURE) == false ) ) then
        return false
    endif
    if ( not ( IsUnitType(GetEnumUnit(), UNIT_TYPE_MAGIC_IMMUNE) == false ) ) then
        return false
    endif
    if ( not ( IsUnitType(GetEnumUnit(), UNIT_TYPE_FLYING) == false ) ) then
        return false
    endif
    if ( not ( BlzIsUnitInvulnerable(GetEnumUnit()) == false ) ) then
        return false
    endif
    if ( not ( IsUnitAliveBJ(GetEnumUnit()) == true ) ) then
        return false
    endif
    return true
endfunction

function Trig_Thunderstorm_Func013A takes nothing returns nothing
    if (udg_Player_Number < 99) then
    set udg_Temp_Unit = udg_Heroes[udg_Player_Number]
    else
    set udg_Temp_Unit = GetTriggerUnit()
    endif
    if ( Trig_Thunderstorm_Func013Func006C() ) then
        // dmg
        call UnitDamageTargetBJ( udg_Temp_Unit, GetEnumUnit(), udg_RealStatCalc, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC )
        call HasFirelords( GetEnumUnit() )
        // mvmnt
        set udg_Temp_Polar_Point = GetUnitLoc(GetEnumUnit())
        set udg_Temp_Real = AngleBetweenPoints(udg_Temp_Unit_Point, udg_Temp_Polar_Point)
        call RemoveLocation (udg_Temp_Polar_Point)
        set udg_Temp_Polar_Point = PolarProjectionBJ(udg_Temp_Unit_Point, ( 230.00 - 0.00 ), udg_Temp_Real)
        if not IsTerrainPathable( GetLocationX(udg_Temp_Polar_Point), GetLocationY(udg_Temp_Polar_Point), PATHING_TYPE_WALKABILITY) then
        call SetUnitPositionLoc( GetEnumUnit(), udg_Temp_Polar_Point )
        endif
        call AddSpecialEffectLocBJ( udg_Temp_Polar_Point, "Abilities\\Weapons\\Bolt\\BoltImpact.mdl" )
        call DestroyEffectBJ( GetLastCreatedEffectBJ() )
        call RemoveLocation (udg_Temp_Polar_Point)
        // KnockBackLoop Turn ON
        call UnitAddAbilityBJ( 'Amrf', GetEnumUnit() )
        call UnitRemoveAbilityBJ( 'Amrf', GetEnumUnit() )
        call SetUnitFlyHeightBJ( GetEnumUnit(), 135.00, 0.00 )
        if ( Trig_Thunderstorm_Func013Func006Func019C() ) then
            call GroupAddUnitSimple( GetEnumUnit(), udg_KnockBacks )
        else
            call FlushChildHashtableBJ( GetHandleIdBJ(GetEnumUnit()), GetLastCreatedHashtableBJ() )
        endif
        call SaveRealBJ( udg_Temp_Real, 0, GetHandleIdBJ(GetEnumUnit()), udg_KnockBacksHash )
        call SaveRealBJ( 4.00, 1, GetHandleIdBJ(GetEnumUnit()), udg_KnockBacksHash )
        call SaveRealBJ( 172.00, 2, GetHandleIdBJ(GetEnumUnit()), udg_KnockBacksHash )
        call SaveRealBJ( 13.00, 3, GetHandleIdBJ(GetEnumUnit()), udg_KnockBacksHash )
        call AddSpecialEffectTargetUnitBJ( "origin", GetEnumUnit(), "Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl" )
        call DestroyEffectBJ( GetLastCreatedEffectBJ() )
    else
    endif
endfunction

function Trig_Thunderstorm_Actions takes nothing returns nothing
    set udg_Temp_Unit = GetTriggerUnit()
    call TriggerExecute( gg_trg_Firelords_Helper_Keep_Temp)
    set udg_RealStatCalc = I2R(( GetHeroStatBJ(bj_HEROSTAT_AGI, udg_Temp_Unit, true) - GetHeroStatBJ(bj_HEROSTAT_AGI, udg_Temp_Unit, false) ))
    set udg_RealStatCalc = ( 0.15 + ( 0.01 * udg_RealStatCalc ) )
    // Echo
    call EchoOfTheElements()
    if ( Trig_Thunderstorm_Func008C() ) then
        set udg_RealStatCalc = I2R(( GetHeroStatBJ(bj_HEROSTAT_INT, udg_Temp_Unit, true) - GetHeroStatBJ(bj_HEROSTAT_INT, udg_Temp_Unit, false) ))
        set udg_RealStatCalc = ( 6.00 * udg_RealStatCalc )
        set udg_HeroStatCalc = ( 100 + ( 50 * GetUnitAbilityLevelSwapped('A0AK', GetTriggerUnit()) ) )
        set udg_RealStatCalc = ( udg_RealStatCalc + I2R(udg_HeroStatCalc) )
        call CreateTextTagUnitBJ( ( "Crit" + "!" ), udg_Temp_Unit, 0.00, 12.00, 100, 0.00, 0.00, 0 )
        call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 90.00 )
        call SetTextTagPermanentBJ( GetLastCreatedTextTag(), false )
        call SetTextTagLifespanBJ( GetLastCreatedTextTag(), 0.80 )
        call ShowTextTagForceBJ( true, GetLastCreatedTextTag(), GetPlayersAll() )
    else
        set udg_RealStatCalc = I2R(( GetHeroStatBJ(bj_HEROSTAT_INT, udg_Temp_Unit, true) - GetHeroStatBJ(bj_HEROSTAT_INT, udg_Temp_Unit, false) ))
        set udg_RealStatCalc = ( 3.00 * udg_RealStatCalc )
    endif
    set udg_Temp_Unit_Point = GetUnitLoc(udg_Temp_Unit)
    call PlaySoundAtPointBJ( gg_snd_LightningBolt1, 100.00, udg_Temp_Unit_Point, 0 )
    set udg_X_Player_MUI = GetOwningPlayer(GetTriggerUnit())
    set bj_wantDestroyGroup = true
    call ForGroupBJ( GetUnitsInRangeOfLocAll(300.00, udg_Temp_Unit_Point), function Trig_Thunderstorm_Func013A )
    call EnableTrigger( gg_trg_KnockBackLoop)
    call RemoveLocation (udg_Temp_Unit_Point)
    // Spiritwalker
    call SpiritwalkersGrace( GetTriggerUnit(), 3)
endfunction

//===========================================================================
function InitTrig_Thunderstorm takes nothing returns nothing
    set gg_trg_Thunderstorm = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Thunderstorm, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_Thunderstorm, Condition( function Trig_Thunderstorm_Conditions ) )
    call TriggerAddAction( gg_trg_Thunderstorm, function Trig_Thunderstorm_Actions )
endfunction

