call SetUnitMoveSpeed( GetTriggerUnit(), ( GetUnitMoveSpeed(GetTriggerUnit()) * 1.25 ) )
call SetUnitMoveSpeed( GetTriggerUnit(), GetUnitDefaultMoveSpeed(GetTriggerUnit()) )
call BlzSetAbilityRealLevelFieldBJ( BlzGetUnitAbility(GetLastCreatedUnit(), 'A08I'), ABILITY_RLF_DURATION_HERO, 0, 5.5 )


if isUnitTargetable(GetEnumUnit()) then
endif

if ( not ( UnitHasBuffBJ(GetEnumUnit(), 'B01M') == false ) ) then
    return false
endif

call BlzSetAbilityIntegerLevelFieldBJ( BlzGetUnitAbility(udg_Temp_Unit, 'A0D0'), ABILITY_ILF_MANA_COST,GetUnitAbilityLevel(udg_Temp_Unit, 'A0D0') - 1, 0 )

call BlzSetUnitAbilityManaCost(udg_Temp_Unit, 'A0D0', GetUnitAbilityLevel(udg_Temp_Unit, 'A0D0') - 1, udg_HeroStatCalc )

function isBurning takes unit u returns boolean
    //Firelords
    if ( UnitHasBuffBJ(u, 'B00L') ) then
        return true
    endif
    //FlameStrike
    if ( UnitHasBuffBJ(u, 'BHfs') ) then
        return true
    endif
    //BreathOfFire (Includes Dragon's Breath)
    if ( UnitHasBuffBJ(u, 'BNbf') ) then
        return true
    endif
    //Soul Burn
    if ( UnitHasBuffBJ(u, 'BNso') ) then
        return true
    endif
    //Immolate
    if ( UnitHasBuffBJ(u, 'B00U') ) then
        return true
    endif
    //Rain of Fire
    if ( UnitHasBuffBJ(u, 'BNrd') ) then
        return true
    endif
    return false
endfunction    




set udg_Temp_Unit = caster
set udg_RealStatCalc = dmg

function SetHero take 
if IsUnitType(GetTriggerUnit(), UNIT_TYPE_HERO) then

endif



function CreateLivingBombDummy takes unit u returns nothing
    local integer lvl = GetUnitAbilityLevel(udg_Temp_Unit, 'A0DJ')
    call CreateNUnitsAtLoc( 1, 'e041', GetOwningPlayer(udg_Temp_Unit), udg_Temp_Unit_Point, 0.00 )
    call SetUnitAbilityLevel( u ,'A0DJ', lvl )
    call BlzSetUnitAbilityManaCost( u,'A0DJ' , lvl - 1, 0)
    call BlzSetUnitAbilityCooldown( u,'A0DJ' , lvl - 1, 0)
    call UnitApplyTimedLife( u, 'BTLF', 0.5 )
    call BlzSetAbilityRealLevelField( BlzGetUnitAbility(u, 'A0DJ'), ABILITY_RLF_PRIMARY_DAMAGE,  lvl - 1 , udg_RealStatCalc )
endfunction    


function MageSpellsNumb takes nothing returns nothing
    local integer i
    set i = 2
    loop 
        exitwhen i > 11
        if( GetDyingUnit() == udg_MageSpells[i] ) then
            set udg_Temp_Int = i
            exitwhen true
        endif
        set i = i + 1
    endloop
endfunction



function Trig_Execution_Sentence_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A06F' ) ) then
        return false
    endif
    return true
endfunction

function Trig_Execution_Sentence_Actions takes nothing returns nothing
    local unit ExecutionSentence
    set ExecutionSentence = GetSpellTargetUnit()
    call TriggerSleepAction( 2.55 )
    set udg_Temp_Unit_Point = GetUnitLoc(ExecutionSentence)
    call SetUnitPositionLoc( gg_unit_e01S_1241, udg_Temp_Unit_Point )
    call SetUnitPositionLoc( gg_unit_e01S_1243, udg_Temp_Unit_Point )
    call RemoveLocation (udg_Temp_Unit_Point)
    call SetUnitOwner( gg_unit_e01S_1241, GetOwningPlayer(GetTriggerUnit()), true )
    call SetUnitOwner( gg_unit_e01S_1243, GetOwningPlayer(GetTriggerUnit()), true )
    call IssueTargetOrderBJ( gg_unit_e01S_1243, "thunderbolt", ExecutionSentence )
    call SetUnitAbilityLevelSwapped( 'A06G', gg_unit_e01S_1241, GetUnitAbilityLevelSwapped('A06F', GetTriggerUnit()) )
    call IssueTargetOrderBJ( gg_unit_e01S_1241, "acidbomb", ExecutionSentence )
    set udg_RealStatCalc = I2R(( GetHeroStatBJ(bj_HEROSTAT_STR, GetTriggerUnit(), true) - GetHeroStatBJ(bj_HEROSTAT_STR, GetTriggerUnit(), false) ))
    set udg_RealStatCalc = ( 5.00 * udg_RealStatCalc )
    call TriggerSleepAction( 0.55 )
    call UnitDamageTargetBJ( GetTriggerUnit(), ExecutionSentence, ( ( 150.00 * I2R(GetUnitAbilityLevelSwapped('A06F', GetTriggerUnit())) ) + udg_RealStatCalc ), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC )
    call AddSpecialEffectTargetUnitBJ( "overhead", ExecutionSentence, "Abilities\\Spells\\Items\\AIda\\AIdaTarget.mdl" )
    call DestroyEffectBJ( GetLastCreatedEffectBJ() )
    call AddSpecialEffectTargetUnitBJ( "origin", ExecutionSentence, "war3mapImported\\HolyBlast.mdx" )
    call DestroyEffectBJ( GetLastCreatedEffectBJ() )
    set ExecutionSentence = null
endfunction

//===========================================================================
function InitTrig_Execution_Sentence takes nothing returns nothing
    set gg_trg_Execution_Sentence = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Execution_Sentence, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_Execution_Sentence, Condition( function Trig_Execution_Sentence_Conditions ) )
    call TriggerAddAction( gg_trg_Execution_Sentence, function Trig_Execution_Sentence_Actions )
endfunction





function Trig_Leap_Timer_Night_Elf_Func009Func008001001 takes nothing returns boolean
    return ( GetOwningPlayer(udg_Temp_Unit) == GetFilterPlayer() )
endfunction

function Trig_Leap_Timer_Blood_Elf_Actions takes nothing returns nothing
    set udg_Temp_Int = 13
    set udg_Temp_Unit = udg_yH_Marksman_Hunter
    set udg_Charge_Distance = DistanceBetweenPoints(udg_Point_Charge_Begin[udg_Temp_Int], udg_Point_Charge_End[udg_Temp_Int])
    set udg_RealStatCalc = AngleBetweenPoints(udg_Point_Charge_Begin[udg_Temp_Int], udg_Point_Charge_End[udg_Temp_Int])
    set udg_Temp_Polar_Point = PolarProjectionBJ(udg_Point_Charge_Begin[udg_Temp_Int], ( udg_Charge_Distance * ( udg_Charge_Loop[udg_Temp_Int] / 16.00 ) ), udg_RealStatCalc)
    if not IsTerrainPathable( GetLocationX(udg_Temp_Polar_Point), GetLocationY(udg_Temp_Polar_Point), PATHING_TYPE_WALKABILITY) then
    	call SetUnitPositionLocFacingLocBJ( udg_Temp_Unit, udg_Temp_Polar_Point, udg_Point_Charge_End[udg_Temp_Int] )
    endif
    call UnitAddAbilityBJ( 'Amrf', udg_Temp_Unit )
    call UnitRemoveAbilityBJ( 'Amrf', udg_Temp_Unit )
    if ( udg_Charge_Loop[udg_Temp_Int] < 16.00 ) then
        set udg_Charge_Loop[udg_Temp_Int] = ( udg_Charge_Loop[udg_Temp_Int] + 1 )
        call SetUnitFlyHeightBJ( udg_Temp_Unit, ( 225.00 * SinBJ(AcosBJ(( 1 - ( udg_Charge_Loop[udg_Temp_Int] / 8.00 ) ))) ), 0.00 )
    else
        call SetUnitFlyHeightBJ( udg_Temp_Unit, 0.00, 0.00 )
        call DestroyEffectBJ( udg_Charge_SE[udg_Temp_Int] )
        call RemoveLocation (udg_Point_Charge_Begin[udg_Temp_Int])
        call RemoveLocation (udg_Point_Charge_End[udg_Temp_Int])
        call DisableTrigger( GetTriggeringTrigger() )
        //call SetUserControlForceOn( GetPlayersMatching(Condition(function Trig_Leap_Timer_Night_Elf_Func009Func008001001)) )
    endif
    call RemoveLocation (udg_Temp_Polar_Point)
endfunction

//===========================================================================
function InitTrig_Leap_Timer_Blood_Elf takes nothing returns nothing
    set gg_trg_Leap_Timer_Blood_Elf = CreateTrigger(  )
    call DisableTrigger( gg_trg_Leap_Timer_Blood_Elf )
    call TriggerRegisterTimerEventPeriodic( gg_trg_Leap_Timer_Blood_Elf, 0.02 )
    call TriggerAddAction( gg_trg_Leap_Timer_Blood_Elf, function Trig_Leap_Timer_Blood_Elf_Actions )
endfunction




function FeignDeathHeal takes unit caster returns nothing
    if ChaliceCheck() then
        call SetUnitLifePercentBJ( caster, ( GetUnitLifePercent(caster) + ( ( 1 + udg_CHALICE_HEAL ) * ( 4.00 + I2R(GetUnitAbilityLevel(caster, 'A0A4')) ) ) ) )
    else
        call SetUnitLifePercentBJ( caster, ( GetUnitLifePercent(caster) + ( 4.00 + I2R(GetUnitAbilityLevel(caster, 'A0A4')) ) ) )
    endif
endfunction

call BlzSetAbilityRealLevelFieldBJ( BlzGetUnitAbility( gg_unit_e00H_2048, 'A06H'), ABILITY_RLF_DURATION_HERO, ( 0 ), 0.75 )
call BlzSetAbilityRealLevelFieldBJ( BlzGetUnitAbility( gg_unit_e00H_2048, 'A06H'), ABILITY_RLF_DURATION_NORMAL, ( 0 ), 0.75 )

call BlzSetAbilityRealLevelFieldBJ( BlzGetUnitAbility( gg_unit_e00H_2048, 'A06H'), ABILITY_RLF_DURATION_HERO, ( 0 ), 0.2 )
call BlzSetAbilityRealLevelFieldBJ( BlzGetUnitAbility( gg_unit_e00H_2048, 'A06H'), ABILITY_RLF_DURATION_NORMAL, ( 0 ), 0.2 )



call BlzSetUnitBaseDamage(  GetLastCreatedUnit(), BlzGetUnitBaseDamage( GetLastCreatedUnit() , 0) + GetHeroStatBJ(bj_HEROSTAT_INT, udg_Temp_Unit, true) , 0)


function Trig_Haunting_Wave_Cast_Conditions takes nothing returns boolean
    if ( not ( GetSpellAbilityId() == 'A04V' ) ) then
        return false
    endif
    if ( not ( GetPlayerController(GetOwningPlayer(GetTriggerUnit())) == MAP_CONTROL_USER ) ) then
        return false
    endif
    return true
endfunction

function Trig_Haunting_Wave_Cast_Actions takes nothing returns nothing
    local location SpellLocation = GetSpellTargetLoc()
    local unit caster = GetTriggerUnit()
    set udg_Temp_Unit_Point = GetUnitLoc(caster)

    if ( caster == udg_yA_Dark_Ranger ) then
        set udg_o = udg_z_HU_DARK_A
    endif
    if ( caster == udg_yH_Dark_Ranger ) then
	set udg_o = udg_z_HU_DARK_H
    endif
    call PlaySoundOnUnitBJ( gg_snd_TempleOfTheDamnedWhat, 80.00, caster )
    
    set udg_Temp_Angle = AngleBetweenPoints(udg_Temp_Unit_Point, SpellLocation) 
    set udg_Temp_Polar_Point = PolarProjectionBJ( udg_Temp_Unit_Point, 100.00,  udg_Temp_Angle)
    call CreateNUnitsAtLoc( 1, 'e01M', GetOwningPlayer(caster), udg_Temp_Polar_Point , AngleBetweenPoints( udg_Temp_Unit_Point, udg_Temp_Polar_Point ) )
    set udg_SpellUnits[udg_o] = GetLastCreatedUnit()
    call UnitApplyTimedLifeBJ( 1.10, 'BTLF', udg_SpellUnits[udg_o] )
    call RemoveLocation(udg_Temp_Unit_Point)
    call RemoveLocation(udg_Temp_Polar_Point)

    set udg_Temp_Polar_Point = PolarProjectionBJ( SpellLocation, 520.00,  udg_Temp_Angle)
    call IssuePointOrderLocBJ( udg_SpellUnits[udg_o], "move", udg_Temp_Polar_Point )
    call RemoveLocation(udg_Temp_Polar_Point)
    
    call SetPlayerAbilityAvailableBJ( false, 'A04V', GetOwningPlayer(caster) )
    call UnitAddAbilityBJ( 'A05L', caster )
    if ( caster == udg_yA_Dark_Ranger ) then
        call EnableTrigger( gg_trg_Swap_Haunting_Wave_WG )
    endif
    if ( caster == udg_yH_Dark_Ranger ) then
        call EnableTrigger( gg_trg_Swap_Haunting_Wave_UD )
    endif
    
    call TriggerSleepAction( 1.10 )
    call UnitRemoveAbilityBJ( 'A05L', caster )
    call SetPlayerAbilityAvailableBJ( true, 'A04V', GetOwningPlayer(caster) )
    call BlzStartUnitAbilityCooldown( caster, 'A04V', BlzGetUnitAbilityCooldown(caster, 'A04V', GetUnitAbilityLevelSwapped('A04V', caster)) )
    if ( caster == udg_yA_Dark_Ranger ) then
        call DisableTrigger( gg_trg_Swap_Haunting_Wave_WG )
    endif
    if ( caster == udg_yH_Dark_Ranger ) then
        call DisableTrigger( gg_trg_Swap_Haunting_Wave_UD )
    endif

    call RemoveLocation(SpellLocation)
    set SpellLocation = null
    set caster = null
endfunction

//===========================================================================
function InitTrig_Haunting_Wave_Cast takes nothing returns nothing
    set gg_trg_Haunting_Wave_Cast = CreateTrigger(  )
    call TriggerRegisterAnyUnitEventBJ( gg_trg_Haunting_Wave_Cast, EVENT_PLAYER_UNIT_SPELL_EFFECT )
    call TriggerAddCondition( gg_trg_Haunting_Wave_Cast, Condition( function Trig_Haunting_Wave_Cast_Conditions ) )
    call TriggerAddAction( gg_trg_Haunting_Wave_Cast, function Trig_Haunting_Wave_Cast_Actions )
endfunction