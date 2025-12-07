function CreateLivingBombDummy takes integer o, unit mage returns nothing
	local integer lvl = GetUnitAbilityLevel(mage, 'A0DJ')
	if IsUnitDeadBJ(udg_SpellUnits[o + 36]) then
		set udg_SpellUnits[o + 36]  = null
	endif 
	if udg_SpellUnits[o + 36]  == null then
		call CreateNUnitsAtLoc( 1, 'e041', GetOwningPlayer(mage), udg_Temp_Unit_Point, 0.00 )
		set udg_SpellUnits[o + 36]  = GetLastCreatedUnit()
		call UnitApplyTimedLife( udg_SpellUnits[o + 36], 'BTLF', 1.5 )
	else
		call SetUnitPositionLoc(udg_SpellUnits[o + 36] , udg_Temp_Unit_Point)
		//call SetUnitOwner(udg_SpellUnits[o + 36], GetOwningPlayer(mage), false)
	endif
	call SetUnitAbilityLevel( udg_SpellUnits[o + 36]  , 'A0DJ', lvl )
	call BlzSetUnitAbilityManaCost( udg_SpellUnits[o + 36] , 'A0DJ' , lvl - 1, 0)
	call BlzSetUnitAbilityCooldown( udg_SpellUnits[o + 36] , 'A0DJ' , lvl - 1, 0)
	call BlzSetAbilityRealLevelField( BlzGetUnitAbility(udg_SpellUnits[o + 36] , 'A0DJ'), ABILITY_RLF_PRIMARY_DAMAGE, lvl - 1 , udg_RealStatCalc )
	call IssueTargetOrderBJ(udg_SpellUnits[o + 36], "acidbomb", GetEnumUnit() )
endfunction    

//needed because the buff check does not entirely work
function JustHadLivingBomb takes integer o, unit u returns boolean
	local integer i = 0
	loop
		exitwhen i > 11
		if udg_SpellUnits[o] == u or udg_SpellUnits[o + 12] == u then
			return true
		endif
		set o = o + 1
		set i = i + 1
	endloop
	return false
endfunction

function JustAquiredLivingBomb takes integer o, unit u returns boolean
	local integer i = 0
	loop
		exitwhen i > 11
		if udg_SpellUnits[o] == u then
			return true
		endif
		set o = o + 1
		set i = i + 1
	endloop
	return false
endfunction


function LivingBombAoE takes nothing returns nothing
	local integer i = 0
	local integer o = 0
	local unit mage
	if udg_o < udg_z_MA_FIRE_H then
		set o = udg_z_MA_FIRE_A + 16
		set mage = udg_yA_Fire_Mage
	else
		set o = udg_z_MA_FIRE_H + 16
		set mage = udg_yH_Fire_Mage
	endif
	
	if ( IsUnitTargetableEnemy(GetEnumUnit(), mage) ) then
		call UnitDamageTargetBJ( mage, GetEnumUnit(), udg_RealStatCalc, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC )
		call AddSpecialEffectTargetUnitBJ( "overhead", GetEnumUnit(), "Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdl" )
		call DestroyEffectBJ( GetLastCreatedEffectBJ() )
		call AddSpecialEffectTargetUnitBJ( "origin", GetEnumUnit(), "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl" )
		call DestroyEffectBJ( GetLastCreatedEffectBJ() )

		// Spread Logic
		//if not equal to exploding unit and don't already have the buff, apply buff if there is space
		if not (UnitHasBuffBJ(GetEnumUnit(), 'B01T')) and not JustHadLivingBomb(o, GetEnumUnit()) then

			loop
				exitwhen i > 11
				if udg_SpellUnits[o] == null then
					call CreateLivingBombDummy(o, mage)
					set udg_SpellUnits[o] = GetEnumUnit()
					set udg_SpellUnits[o + 24] = udg_SpellUnits[o] 
					if ( udg_Debug ) then
						call DisplayTextToForce( GetPlayersAll(), "Spread: " + I2S(o) + " " + I2S(GetHandleId(udg_SpellUnits[o])) )
					endif
					set i = 12
				endif
				set o = o + 1
				set i = i + 1 
			endloop
		endif
	endif

	set mage = null
endfunction

function LivingBombExplosion takes nothing returns nothing
	call AddSpecialEffectLocBJ( udg_Temp_Unit_Point, "Abilities\\Weapons\\SteamTank\\SteamTankImpact.mdl" )
	call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), 2.00 )
	call DestroyEffectBJ( GetLastCreatedEffectBJ() )
	
	set bj_wantDestroyGroup = true
	call ForGroupBJ( GetUnitsInRangeOfLocAll(300.00, udg_Temp_Unit_Point), function LivingBombAoE )
endfunction

function CheckLivingBombUnits takes nothing returns nothing
	local integer i = 0
	local integer o
	local integer start_o 
	local boolean hasBomb = false
	local location dummyIsland = GetRectCenter(gg_rct_DummyIsland)
	local unit mage = udg_Temp_Unit
	if mage == udg_yA_Fire_Mage then
		set o = udg_z_MA_FIRE_A + 16
	else 
		set o = udg_z_MA_FIRE_H + 16
	endif
	set start_o = o + 24

	call BlzSetAbilityIntegerField( BlzGetUnitAbility(mage, 'A0DJ'), ABILITY_IF_MISSILE_SPEED, 10000 )
	loop
		exitwhen i > 11
		if udg_SpellUnits[o] != null then
			if ( udg_Debug ) then
				call DisplayTextToForce( GetPlayersAll(), I2S(i) + ": " + I2S(GetHandleId(udg_SpellUnits[o]) ))
			endif
			if (not (UnitHasBuffBJ(udg_SpellUnits[o], 'B01T')) or not ( IsUnitAliveBJ(udg_SpellUnits[o]) )) and not JustAquiredLivingBomb(start_o, udg_SpellUnits[o]) then
				set udg_o = o
				set udg_Temp_Unit_Point = GetUnitLoc( udg_SpellUnits[o] )
				set udg_SpellUnits[o + 12] = udg_SpellUnits[o]
				set udg_SpellUnits[o] = null
				call LivingBombExplosion()
				call RemoveLocation(udg_Temp_Unit_Point)
			endif
		endif
		
		set o = o + 1
		set i = i + 1
	endloop
    
	set o = o - i
	set i = 0
	loop
		exitwhen i > 11
		set udg_SpellUnits[o + 12] = null
		set udg_SpellUnits[o + 24] = null
		//call SetUnitOwner(udg_SpellUnits[o + 36], Player(PLAYER_NEUTRAL_PASSIVE), false)
		// call SetUnitPositionLoc(udg_SpellUnits[o + 36] , dummyIsland)
		if udg_SpellUnits[o] != null then
			set hasBomb = true
		endif
		set o = o + 1
		set i = i + 1
	endloop
	call BlzSetAbilityIntegerField( BlzGetUnitAbility(mage, 'A0DJ'), ABILITY_IF_MISSILE_SPEED, 3000 )

	if not hasBomb then
		if o < udg_z_MA_FIRE_H then
			call DisableTrigger( gg_trg_Living_Bomb_Tick_A)
		else 
			call DisableTrigger( gg_trg_Living_Bomb_Tick_H)
		endif
		if ( udg_Debug ) then
			call DisplayTextToForce( GetPlayersAll(), "|cccFFFF00LB OFF|r" )
		endif
	endif
	set mage = null
	call RemoveLocation(dummyIsland)
	set dummyIsland = null
endfunction