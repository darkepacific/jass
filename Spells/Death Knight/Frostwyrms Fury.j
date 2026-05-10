function Trig_Frostwyrms_Fury_Conditions takes nothing returns boolean
    return ( GetSpellAbilityId() == 'A073' ) 
    // Lich King
    // if ( GetSpellAbilityUnit() == gg_unit_Uear_1259 )
endfunction

function Trig_Frostwyrms_Fury_Actions takes nothing returns nothing
    local integer udg_Temp_Int
    local location PathofFrost1
    local location PathofFrost2
    local location PathofFrost3 
    local unit caster = GetTriggerUnit()

    if ( GetSpellAbilityUnit() == udg_yH_Frost_DK ) then
        set udg_Temp_Int = 0
    elseif ( GetSpellAbilityUnit() == udg_yA_Frost_DK ) then
        set udg_Temp_Int = 3
    elseif ( GetSpellAbilityUnit() == udg_yH_Blood_DK ) then
        set udg_Temp_Int = 9
    elseif ( GetSpellAbilityUnit() == udg_yA_Blood_DK ) then
        set udg_Temp_Int = 12
    endif
    set PathofFrost1 = GetUnitLoc(caster())
    set PathofFrost2 = GetSpellTargetLoc()
    set PathofFrost3 = PolarProjectionBJ(PathofFrost2, 450.00, AngleBetweenPoints(PathofFrost2, PathofFrost1))
    call CreateNUnitsAtLoc( 1, 'u026', GetOwningPlayer(caster()), PathofFrost3, bj_UNIT_FACING )
    call UnitApplyTimedLifeBJ( 1.50, 'BTLF', GetLastCreatedUnit() )
    call RemoveLocation (PathofFrost3)

    set PathofFrost2 = PolarProjectionBJ(PathofFrost2, -900.00, AngleBetweenPoints(PathofFrost2, PathofFrost1))
    call IssuePointOrderLocBJ( GetLastCreatedUnit(), "move", PathofFrost2 )
    call RemoveLocation (PathofFrost2)
    call TriggerSleepAction( 0.25 )

    set udg_HeroStatCalc = ( GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) - GetHeroStatBJ(bj_HEROSTAT_INT, caster, false) )
    set udg_RealStatCalc = ( udg_RealStatCalc / 2.00 )
    set udg_RealStatCalc = ( ( 1.00 + udg_RealStatCalc ) + ( ( I2R(GetUnitAbilityLevelSwapped('A073', caster)) - 1 ) * 10.00 ) )
    if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(caster)) * udg_NUM_OF_TC + 3 ]  then
    set udg_RealStatCalc = ( udg_RealStatCalc * 1.08 )
    endif
    if ( udg_RealStatCalc > 100.00 ) then
        set udg_RealStatCalc = 100.00
    endif
    set udg_PathofFrost[( udg_Temp_Int + 2 )] = PolarProjectionBJ(udg_PathofFrost[( udg_Temp_Int + 1 )], 200.00, AngleBetweenPoints(udg_PathofFrost[( udg_Temp_Int + 1 )], udg_PathofFrost[udg_Temp_Int]))
    call CreateNUnitsAtLoc( 1, 'e025', GetOwningPlayer(caster), udg_PathofFrost[( udg_Temp_Int + 2 )], bj_UNIT_FACING )
    call SetUnitAbilityLevelSwapped( 'A01F', GetLastCreatedUnit(), R2I(udg_RealStatCalc) )
    call IssueTargetOrderBJ( GetLastCreatedUnit(), "frostnova", GetLastCreatedUnit() )
    call UnitApplyTimedLifeBJ( 0.85, 'BTLF', GetLastCreatedUnit() )
    call RemoveLocation (PathofFrost3)
    
    call TriggerSleepAction( 0.25 )
    set udg_HeroStatCalc = ( GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) - GetHeroStatBJ(bj_HEROSTAT_INT, caster, false) )
    set udg_RealStatCalc = ( udg_RealStatCalc / 2.00 )
    set udg_RealStatCalc = ( ( 1.00 + udg_RealStatCalc ) + ( ( I2R(GetUnitAbilityLevelSwapped('A073', caster)) - 1 ) * 10.00 ) )
    if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(caster)) * udg_NUM_OF_TC + 3 ]  then
    set udg_RealStatCalc = ( udg_RealStatCalc * 1.08 )
    endif
    if ( udg_RealStatCalc > 100.00 ) then
        set udg_RealStatCalc = 100.00
    endif
    call CreateNUnitsAtLoc( 1, 'e025', GetOwningPlayer(caster()), udg_PathofFrost[( udg_Temp_Int + 1 )], bj_UNIT_FACING )
    call SetUnitAbilityLevelSwapped( 'A01F', GetLastCreatedUnit(), R2I(udg_RealStatCalc) )
    call IssueTargetOrderBJ( GetLastCreatedUnit(), "frostnova", GetLastCreatedUnit() )
    call UnitApplyTimedLifeBJ( 0.85, 'BTLF', GetLastCreatedUnit() )
    call CreateNUnitsAtLoc( 1, 'e026', GetOwningPlayer(caster()), udg_PathofFrost[( udg_Temp_Int + 1 )], bj_UNIT_FACING )
    call SetUnitAbilityLevelSwapped( 'A072', GetLastCreatedUnit(), R2I(udg_RealStatCalc) )
    call IssueTargetOrderBJ( GetLastCreatedUnit(), "frostnova", GetLastCreatedUnit() )
    call UnitApplyTimedLifeBJ( 0.85, 'BTLF', GetLastCreatedUnit() )
    call TriggerSleepAction( 0.25 )
    set caster = caster()
    set udg_HeroStatCalc = ( GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) - GetHeroStatBJ(bj_HEROSTAT_INT, caster, false) )
    set udg_RealStatCalc = ( udg_RealStatCalc / 2.00 )
    set udg_RealStatCalc = ( ( 1.00 + udg_RealStatCalc ) + ( ( I2R(GetUnitAbilityLevelSwapped('A073', caster)) - 1 ) * 10.00 ) )
    if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(caster)) * udg_NUM_OF_TC + 3 ]  then
    set udg_RealStatCalc = ( udg_RealStatCalc * 1.08 )
    endif
    if ( udg_RealStatCalc > 100.00 ) then
        set udg_RealStatCalc = 100.00
    endif
    set udg_PathofFrost[( udg_Temp_Int + 2 )] = PolarProjectionBJ(udg_PathofFrost[( udg_Temp_Int + 1 )], -200.00, AngleBetweenPoints(udg_PathofFrost[( udg_Temp_Int + 1 )], udg_PathofFrost[udg_Temp_Int]))
    call CreateNUnitsAtLoc( 1, 'e025', GetOwningPlayer(caster), udg_PathofFrost[( udg_Temp_Int + 2 )], bj_UNIT_FACING )
    set udg_HeroStatCalc = ( GetHeroStatBJ(bj_HEROSTAT_INT, caster, true) - GetHeroStatBJ(bj_HEROSTAT_INT, caster, false) )
    call SetUnitAbilityLevelSwapped( 'A01F', GetLastCreatedUnit(), R2I(udg_RealStatCalc) )
    call IssueTargetOrderBJ( GetLastCreatedUnit(), "frostnova", GetLastCreatedUnit() )
    call UnitApplyTimedLifeBJ( 0.85, 'BTLF', GetLastCreatedUnit() )
    
    call RemoveLocation (PathofFrost1)
    call RemoveLocation (PathofFrost2)
    call RemoveLocation (PathofFrost3)

    set PathofFrost1 = null
    set PathofFrost2 = null
    set PathofFrost3 = null
endfunction

//===========================================================================
function InitTrig_Frostwyrms_Fury takes nothing returns nothing
    set gg_trg_Frostwyrms_Fury = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Frostwyrms_Fury, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_Frostwyrms_Fury, Condition( function Trig_Frostwyrms_Fury_Conditions ) )
    call TriggerAddAction( gg_trg_Frostwyrms_Fury, function Trig_Frostwyrms_Fury_Actions )
endfunction

