globals
	public trigger QuestLogTrigger
endglobals



local integer i = 0
loop
	exitwhen i > 11

	call DisplayTextToForce( GetPlayersAll(), "t " + BlzGetAbilityStringLevelField( BlzGetUnitAbilityByIndex( GetTriggerUnit(), i), ABILITY_SLF_TOOLTIP_NORMAL, 0) )
	call DisplayTextToForce( GetPlayersAll(), "c " + BlzGetUnitAbilityCooldownRemaining( GetTriggerUnit(), BlzGetUnitAbilityByIndex( GetTriggerUnit(), i).GetAbility ) )

	set i = i + 1
endloop


BlzGetUnitAbilityCooldownRemaining( GetTriggerUnit(), BlzGetUnitAbilityByIndex( GetTriggerUnit(), i) ) )

BlzFrameClick(BlzGetOriginFrame(ORIGIN_FRAME_SYSTEM_BUTTON, 3))


function Trig_Execution_Sentence_Actions takes nothing returns nothing
	local unit ExecutionSentence
	set ExecutionSentence = GetSpellTargetUnit()
	call TriggerSleepAction( 2.55 )
	set udg_Temp_Unit = GetTriggerUnit()
	set udg_Temp_Unit_Point = GetUnitLoc(ExecutionSentence)
	call SetUnitPositionLoc( gg_unit_e01S_1241, udg_Temp_Unit_Point )
	call SetUnitPositionLoc( gg_unit_e01S_1243, udg_Temp_Unit_Point )
	call RemoveLocation (udg_Temp_Unit_Point)
	call SetUnitOwner( gg_unit_e01S_1241, GetOwningPlayer(udg_Temp_Unit), true )
	call SetUnitOwner( gg_unit_e01S_1243, GetOwningPlayer(udg_Temp_Unit), true )
	call IssueTargetOrderBJ( gg_unit_e01S_1243, "thunderbolt", ExecutionSentence )
	call SetUnitAbilityLevelSwapped( 'A06G', gg_unit_e01S_1241, GetUnitAbilityLevelSwapped('A06F', udg_Temp_Unit) )
	call IssueTargetOrderBJ( gg_unit_e01S_1241, "acidbomb", ExecutionSentence )
	set udg_RealStatCalc = I2R(( GetHeroStatBJ(bj_HEROSTAT_STR, udg_Temp_Unit, true) - GetHeroStatBJ(bj_HEROSTAT_STR, udg_Temp_Unit, false) ))
	set udg_RealStatCalc = ( 5.00 * udg_RealStatCalc )
	call TriggerSleepAction( 0.55 )
	call UnitDamageTargetBJ( udg_Temp_Unit, ExecutionSentence, ( ( 150.00 * I2R(GetUnitAbilityLevelSwapped('A06F', udg_Temp_Unit)) ) + udg_RealStatCalc ), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC )
	call AddSpecialEffectTargetUnitBJ( "overhead", ExecutionSentence, "Abilities\\Spells\\Items\\AIda\\AIdaTarget.mdl" )
	call DestroyEffectBJ( GetLastCreatedEffectBJ() )
	call AddSpecialEffectTargetUnitBJ( "origin", ExecutionSentence, "war3mapImported\\HolyBlast.mdx" )
	call DestroyEffectBJ( GetLastCreatedEffectBJ() )
	set ExecutionSentence = null
endfunction


call SetUnitPositionLoc( gg_unit_e01S_1241, udg_Temp_Unit_Point )
call SetUnitOwner( gg_unit_e01S_1241, GetOwningPlayer(udg_Temp_Unit), true )
call SetUnitAbilityLevel( gg_unit_e01S_1241, 'A06G', GetUnitAbilityLevel(udg_Temp_Unit, 'A087') + 1)
call IssueTargetOrderBJ( gg_unit_e01S_1241, "acidbomb", GetEnumUnit() )




function Trig_Travel_Leap_Timer_Feral_NE_Actions takes nothing returns nothing
	set udg_Temp_Int = 28
	set udg_Temp_Unit = udg_yA_Feral_Druid
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
	endif
	call RemoveLocation (udg_Temp_Polar_Point)
endfunction

//===========================================================================
function InitTrig_Travel_Leap_Timer_Feral_NE takes nothing returns nothing
	set gg_trg_Travel_Leap_Timer_Feral_NE = CreateTrigger(  )
	call DisableTrigger( gg_trg_Travel_Leap_Timer_Feral_NE )
	call TriggerRegisterTimerEventPeriodic( gg_trg_Travel_Leap_Timer_Feral_NE, 0.02 )
	call TriggerAddAction( gg_trg_Travel_Leap_Timer_Feral_NE, function Trig_Travel_Leap_Timer_Feral_NE_Actions )
endfunction

SetPlayerAbilityAvailableBJ



function CheckIfMorphed takes integer uId returns boolean
	if ( uId == 'E00G' ) then
		return true
	endif
	if ( uId == 'E00I') then
		return true
	endif
	if ( uId == 'E00L') then
		return true
	endif
	if ( uId == 'E013') then
		return true
	endif
	if ( uId == 'E00O') then
		return true
	endif
	if ( uId == 'E014') then
		return true
	endif
	if ( uId == 'E00K') then
		return true
	endif
	if ( uId == 'E00M') then
		return true
	endif
	if ( uId == 'E00J') then
		return true
	endif
	if ( uId == 'E00N') then
		return true
	endif
	if ( uId == 'E011') then
		return true
	endif
	if ( uId == 'E012') then
		return true
	endif
	if ( uId == 'E02P') then
		return true
	endif
	if ( uId == 'E02Q') then
		return true
	endif
	if ( uId == 'E02R') then
		return true
	endif														
	if ( uId == 'E02S') then
		return true
	endif
	if ( uId == 'E02U') then
		return true
	endif
	if ( uId == 'E02J') then
		return true
	endif
	if ( uId == 'E02K') then
		return true
	endif
	if ( uId == 'E02L') then
		return true
	endif
	if ( uId == 'E02M') then
		return true
	endif
	if ( uId == 'E02N') then
		return true
	endif
	if ( uId == 'E02O') then
		return true
	endif
	if ( uId == 'E04B') then
		return true
	endif
	if ( uId == 'E01C') then
		return true
	endif
	if ( uId == 'E010') then
		return true
	endif
	if ( uId == 'E022') then
		return true
	endif
	if ( uId == 'E02W') then
		return true
	endif	
	return false
endfunction


//Cool Effects
//call AddSpecialEffectTargetUnitBJ( "overhead", target, "war3mapImported\\Azul Arrow.mdx" )
//"Abilities\\Weapons\\DragonHawkMissile\\DragonHawkMissile.mdl" 
// "Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl" 
// "Abilities\\Spells\\NightElf\\SpiritOfVengeance\\SpiritOfVengeanceBirthMissile.mdl" 
//Abilities\Spells\Orc\LightningBolt\LightningBoltMissile.mdl
//Abilities\Spells\Undead\AbsorbMana\AbsorbManaBirthMissile.mdl
//Abilities\Spells\Undead\FreezingBreath\FreezingBreathMissile.mdl
//Abilities\Spells\Undead\OrbOfDeath\AnnihilationMissile.mdl
//Abilities\Spells\Undead\Possession\PossessionMissile.mdl
//Abilities\Weapons\ProcMissile\ProcMissile.mdl
//Abilities\Weapons\SearingArrow\SearingArrowMissile.mdl //Combustion
//Abilities\Weapons\VengeanceMissile\VengeanceMissile.mdl //Blood DK
//Abilities\Weapons\ZigguratFrostMissile\ZigguratFrostMissile.mdl //Frost DK




function SetSapplingStats takes unit created, unit dying returns nothing
	call BlzSetUnitMaxHP( created, BlzGetUnitMaxHP(dying) / 2)
	call BlzSetUnitBaseDamage(created, BlzGetUnitBaseDamage(dying, 0) / 2, 0)
	call BlzSetUnitAttackCooldown(created, BlzGetUnitAttackCooldown(dying, 0), 0)
	call SetUnitMoveSpeed(created, GetUnitMoveSpeed( dying) )
	call UnitApplyTimedLifeBJ( 8.00, 'BEfn', created )	
endfunction

function CreateSappling takes unit dying returns nothing
	//set udg_Temp_Unit_Point = GetUnitLoc( dying)
	call CreateNUnitsAtLoc( 1, 'e01B', udg_X_Player_MUI, udg_Temp_Unit_Point, GetUnitFacing(dying) )
	call SetSapplingStats( GetLastCreatedUnit(), dying )
	//call RemoveLocation (udg_Temp_Unit_Point)
endfunction

call CreateTextTagUnitBJ( "Swiftmend", GetSpellTargetUnit(), 10.00, 9.00, 20.00, 100.00, 0.00, 0 )
call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 0.00 )
call cleanUpText( 1.2, 0.8)
call ShowTextTagForceBJ( true, GetLastCreatedTextTag(), GetPlayersAll() )

function Trig_Arcane_Shot_NE_Actions takes nothing returns nothing
	local unit udg_Temp_Unit = udg_yA_Marksman_Hunter
	local integer bonusMana = ( 30 + ( 10 * GetUnitAbilityLevelSwapped('A05M', udg_Temp_Unit) ) )
	
	if udg_TalentChoices[ GetPlayerId(GetOwningPlayer( udg_Temp_Unit )) * udg_NUM_OF_TC + 12 ]  then
		set bonusMana = bonusMana * 2
		call BlzEndUnitAbilityCooldown( udg_Temp_Unit, 'A05M' )
	endif
	call PlaySoundOnUnitBJ( gg_snd_SiphonMana, 75.00, udg_Temp_Unit )
	call SetUnitManaBJ( udg_Temp_Unit, ( GetUnitStateSwap(UNIT_STATE_MANA, udg_Temp_Unit) + ( bonusMana ) ) )
	call CreateTextTagUnitBJ( ( "+" + ( I2S( bonusMana ) + " Mana!" ) ), udg_Temp_Unit, 0.00, 8.00, 50.00, 50.00, 100.00, 0 )
	call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64.00, 180.00 )
	call SetTextTagPermanentBJ( GetLastCreatedTextTag(), false )
	call SetTextTagLifespanBJ( GetLastCreatedTextTag(), 0.60 )
	call SetTextTagFadepointBJ( GetLastCreatedTextTag(), 0.40 )
	set udg_Temp_Unit = null 
endfunction




//Lament_of_the_Highborne
function Lament_of_the_Highborne takes nothing returns nothing
	local effect b1
	local effect b2
	local effect b3
	local effect b4
	local effect m1
	local location sylvanas
	local location banshee
	local integer offset = 280

	set sylvanas = GetRectCenter(gg_rct_Sylvanas)

	set banshee = PolarProjectionBJ(sylvanas, offset, 38)
	call AddSpecialEffectLocBJ( banshee, "units\\creeps\\BansheeGhost\\BansheeGhost.mdl" )
	call RemoveLocation (banshee)
	set b1 = GetLastCreatedEffectBJ()
	call BlzSetSpecialEffectAlpha( GetLastCreatedEffectBJ(), 145 )
	call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.9)
	call BlzSetSpecialEffectYaw( GetLastCreatedEffectBJ(), Deg2Rad(( 35.00 + 180.00 )) )

	set banshee = PolarProjectionBJ(sylvanas, offset, 72)
	call AddSpecialEffectLocBJ( banshee, "units\\creeps\\BansheeGhost\\BansheeGhost.mdl" )
	call RemoveLocation (banshee)
	set b2 = GetLastCreatedEffectBJ()
	call BlzSetSpecialEffectAlpha( GetLastCreatedEffectBJ(), 145 )
	call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.9)
	call BlzSetSpecialEffectYaw( GetLastCreatedEffectBJ(), Deg2Rad(( 75.00 + 180.00 )) )

	set banshee = PolarProjectionBJ(sylvanas, offset, 107)
	call AddSpecialEffectLocBJ( banshee, "units\\creeps\\BansheeGhost\\BansheeGhost.mdl" )
	call RemoveLocation (banshee)
	set b3 = GetLastCreatedEffectBJ()
	call BlzSetSpecialEffectAlpha( GetLastCreatedEffectBJ(), 145 )
	call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.9)
	call BlzSetSpecialEffectYaw( GetLastCreatedEffectBJ(), Deg2Rad(( 115.00 + 180.00 )) )

	set banshee = PolarProjectionBJ(sylvanas, offset, 142)
	call AddSpecialEffectLocBJ( banshee, "units\\creeps\\BansheeGhost\\BansheeGhost.mdl" )
	call RemoveLocation (banshee)
	set b4 = GetLastCreatedEffectBJ()
	call BlzSetSpecialEffectAlpha( GetLastCreatedEffectBJ(), 145 )
	call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.9)
	call BlzSetSpecialEffectYaw( GetLastCreatedEffectBJ(), Deg2Rad(( 155.00 + 180.00 )) )


	call AddSpecialEffectLocBJ( sylvanas, "war3mapImported\\MusicTarget.mdx" )
	set m1 = GetLastCreatedEffectBJ()
	call BlzSetSpecialEffectAlpha( GetLastCreatedEffectBJ(), 185 )

	call RemoveLocation (sylvanas)

	call TriggerSleepAction(8.0)
	if GetRandomReal(0.0,10.0) > 5.0 then
		call BlzPlaySpecialEffect( b1, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b2, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b3, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b4, ANIM_TYPE_SPELL )
	else
		call BlzPlaySpecialEffect( b1, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b2, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b3, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b4, ANIM_TYPE_STAND )
	endif
	call TriggerSleepAction(8.0)
	if GetRandomReal(0.0,10.0) > 5.0 then
		call BlzPlaySpecialEffect( b1, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b2, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b3, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b4, ANIM_TYPE_SPELL )
	else
		call BlzPlaySpecialEffect( b1, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b2, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b3, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b4, ANIM_TYPE_STAND )
	endif
	call TriggerSleepAction(8.0)
	if GetRandomReal(0.0,10.0) > 5.0 then
		call BlzPlaySpecialEffect( b1, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b2, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b3, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b4, ANIM_TYPE_SPELL )
	else
		call BlzPlaySpecialEffect( b1, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b2, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b3, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b4, ANIM_TYPE_STAND )
	endif
	call TriggerSleepAction(8.0)
	if GetRandomReal(0.0,10.0) > 5.0 then
		call BlzPlaySpecialEffect( b1, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b2, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b3, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b4, ANIM_TYPE_SPELL )
	else
		call BlzPlaySpecialEffect( b1, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b2, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b3, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b4, ANIM_TYPE_STAND )
	endif
	call TriggerSleepAction(8.0)
	if GetRandomReal(0.0,10.0) > 5.0 then
		call BlzPlaySpecialEffect( b1, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b2, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b3, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b4, ANIM_TYPE_SPELL )
	else
		call BlzPlaySpecialEffect( b1, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b2, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b3, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b4, ANIM_TYPE_STAND )
	endif
	call TriggerSleepAction(8.0)
	if GetRandomReal(0.0,10.0) > 5.0 then
		call BlzPlaySpecialEffect( b1, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b2, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b3, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b4, ANIM_TYPE_SPELL )
	else
		call BlzPlaySpecialEffect( b1, ANIM_TYPE_STAND )
		call BlzPlaySpecialEffect( b2, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b3, ANIM_TYPE_SPELL )
		call BlzPlaySpecialEffect( b4, ANIM_TYPE_STAND )
	endif
	//call GameTimeWait(48.0)

	call DestroyEffectBJ( b1 )
	call DestroyEffectBJ( b2 )
	call DestroyEffectBJ( b3 )
	call DestroyEffectBJ( b4 )
	call DestroyEffectBJ( m1 )

	set b1 = null
	set b2 = null
	set b3 = null
	set b4 = null
	set m1 = null
	set sylvanas = null
	set banshee = null
endfunction


function Add50Gold takes nothing returns nothing
	call AdjustPlayerStateBJ( 50, GetEnumPlayer(), PLAYER_STATE_RESOURCE_GOLD )
endfunction

function CompleteQuest takes integer xp, integer gold, integer faction returns nothing
	local integer i
	local integer e
	local force team

	if faction == 'A' then
		call TriggerExecute( gg_trg_Quest_Complete_A )
		set i = 4
		set e = 7
		set team = udg_AlliancePlayers
	else
		call TriggerExecute( gg_trg_Quest_Complete_H )
		set i = 0
		set e = 3
		set team = udg_HordePlayers		
	endif

	//Add XP
	loop
		exitwhen i > e
		call AddHeroXP( udg_Heroes[i], xp, true )
		// call AdjustPlayerStateBJ( gold, GetOwningPlayer(udg_Heroes[i]), PLAYER_STATE_RESOURCE_GOLD )
		set i = i + 1
	endloop

	//Add Gold
	set i = 0
	loop
		exitwhen i >= gold
		call ForForce( team, function Add50Gold )
		set i = i + 50
	endloop

	set team = null
endfunction