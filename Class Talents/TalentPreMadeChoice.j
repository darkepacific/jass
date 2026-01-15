//TalentPreMadeChoice 1.2b
//by Tasyen

// Contains Predefined ChoiceCreations

//API
//=========
//	function TalentChoiceCreateStats takes integer strAdd, integer agiAdd, integer intAdd returns integer
//		Create a new Choice which adds Str, agi and int.
//		The Choice is added to the last created Tier.
//		This also generates Main-Text showing the stats gained.
//		If you wana add pre Text do it as shown below
//		set udg_TalentChoiceText[udg_TalentChoiceLast] = "your Text" + udg_TalentChoiceText[udg_TalentChoiceLast]

//	function TalentChoiceCreateStr takes integer add returns integer
//	function TalentChoiceCreateAgi takes integer add returns integer
//	function TalentChoiceCreateInt takes integer add returns integer

//	function TalentChoiceCreateSustain takes integer lifeAdd, integer manaAdd, real armorAdd returns integer

//	function TalentChoiceCreateImproveWeapon takes integer weaponIndex, integer damageAdd, real cooldownAdd returns integer

//	function TalentChoiceCreateImproveSpell takes integer spell, integer manaCostAdd, real cooldownAdd returns integer
//		use negative values to improve the spell.


//	function TalentChoiceCreateAddSpell takes integer spell, boolean useButtonInfos returns integer
//		this choice will add 1 ability, if useButtonInfos is used then text, HeadLine and Icon are taken from the spell


//=======================

function TalentChoiceAddTextInt takes string name, integer value returns nothing
	if value != 0 then
		set udg_TalentChoiceText[udg_TalentChoiceLast] = udg_TalentChoiceText[udg_TalentChoiceLast] +name+"|r: "+ I2S(value) + " "
	endif
endfunction
function TalentChoiceAddTextIntAsObject takes string name, integer value returns nothing
	if value != 0 then
		set udg_TalentChoiceText[udg_TalentChoiceLast] = udg_TalentChoiceText[udg_TalentChoiceLast] +name+ GetObjectName(value)+"|r"
	endif
endfunction
function TalentChoiceAddTextReal takes string name, real value returns nothing
	if value != 0 then
		set udg_TalentChoiceText[udg_TalentChoiceLast] = udg_TalentChoiceText[udg_TalentChoiceLast] +name+"|r: "+ R2SW(value,1,1) + " "
	endif
endfunction
function TalentChoiceAddText takes string text returns nothing
	set udg_TalentChoiceText[udg_TalentChoiceLast] = udg_TalentChoiceText[udg_TalentChoiceLast] + text
endfunction

//RegenStats
function TalentChoiceRegenLearn takes nothing returns nothing
	call BlzSetUnitRealField( udg_Talent__Unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE, BlzGetUnitRealField(udg_Talent__Unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE) + udg_TalentChoiceReal1[udg_Talent__Choice] )
	call BlzSetUnitRealField( udg_Talent__Unit, UNIT_RF_MANA_REGENERATION, BlzGetUnitRealField(udg_Talent__Unit, UNIT_RF_MANA_REGENERATION) + udg_TalentChoiceReal2[udg_Talent__Choice] )
	call BlzSetUnitMaxHP(udg_Talent__Unit, BlzGetUnitMaxHP(udg_Talent__Unit) + udg_TalentChoiceInt1[udg_Talent__Choice])
	call BlzSetUnitMaxMana(udg_Talent__Unit, BlzGetUnitMaxMana(udg_Talent__Unit) + udg_TalentChoiceInt2[udg_Talent__Choice])
	call SetUnitState(udg_Talent__Unit, UNIT_STATE_LIFE, GetUnitState(udg_Talent__Unit,UNIT_STATE_LIFE) + udg_TalentChoiceInt1[udg_Talent__Choice])
	call SetUnitState(udg_Talent__Unit, UNIT_STATE_MANA, GetUnitState(udg_Talent__Unit,UNIT_STATE_MANA) + udg_TalentChoiceInt2[udg_Talent__Choice])
	if udg_TalentChoiceInt3[udg_Talent__Choice] != -1 then
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = true
	endif
endfunction
function TalentChoiceRegenReset takes nothing returns nothing
	call SetUnitState(udg_Talent__Unit, UNIT_STATE_LIFE, GetUnitState(udg_Talent__Unit,UNIT_STATE_LIFE) - udg_TalentChoiceInt1[udg_Talent__Choice])
	call SetUnitState(udg_Talent__Unit, UNIT_STATE_MANA, GetUnitState(udg_Talent__Unit,UNIT_STATE_MANA) - udg_TalentChoiceInt2[udg_Talent__Choice])
	call BlzSetUnitRealField( udg_Talent__Unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE, BlzGetUnitRealField(udg_Talent__Unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE) - udg_TalentChoiceReal1[udg_Talent__Choice] )
	call BlzSetUnitRealField( udg_Talent__Unit, UNIT_RF_MANA_REGENERATION, BlzGetUnitRealField(udg_Talent__Unit, UNIT_RF_MANA_REGENERATION) - udg_TalentChoiceReal2[udg_Talent__Choice] )
	call BlzSetUnitMaxHP(udg_Talent__Unit, BlzGetUnitMaxHP(udg_Talent__Unit) - udg_TalentChoiceInt1[udg_Talent__Choice])
	call BlzSetUnitMaxMana(udg_Talent__Unit, BlzGetUnitMaxMana(udg_Talent__Unit) - udg_TalentChoiceInt2[udg_Talent__Choice])
	if udg_TalentChoiceInt3[udg_Talent__Choice] != -1 then
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = false
	endif
endfunction

//Hero Stats
function TalentChoiceStatsLearn takes nothing returns nothing
	call SetHeroStr(udg_Talent__Unit, GetHeroStr(udg_Talent__Unit,false) + udg_TalentChoiceInt1[udg_Talent__Choice],true)
	call SetHeroAgi(udg_Talent__Unit, GetHeroAgi(udg_Talent__Unit,false) + udg_TalentChoiceInt2[udg_Talent__Choice],true)
	call SetHeroInt(udg_Talent__Unit, GetHeroInt(udg_Talent__Unit,false) + udg_TalentChoiceInt3[udg_Talent__Choice],true)
	if udg_TalentChoiceReal1[udg_Talent__Choice] != -1 then
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + R2I(udg_TalentChoiceReal1[udg_Talent__Choice])] = true
	endif
endfunction
function TalentChoiceStatsReset takes nothing returns nothing
	call Debug("Reset: " + I2S(udg_Talent__Choice) )
	call SetHeroStr(udg_Talent__Unit, GetHeroStr(udg_Talent__Unit,false) - udg_TalentChoiceInt1[udg_Talent__Choice],true)
	call SetHeroAgi(udg_Talent__Unit, GetHeroAgi(udg_Talent__Unit,false) - udg_TalentChoiceInt2[udg_Talent__Choice],true)
	call SetHeroInt(udg_Talent__Unit, GetHeroInt(udg_Talent__Unit,false) - udg_TalentChoiceInt3[udg_Talent__Choice],true)
	if udg_TalentChoiceReal1[udg_Talent__Choice] != -1 then
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + R2I(udg_TalentChoiceReal1[udg_Talent__Choice])] = false
	endif
endfunction

//Health, Mana, Armor
function TalentChoiceSustainLearn takes nothing returns nothing
	call BlzSetUnitMaxHP(udg_Talent__Unit, BlzGetUnitMaxHP(udg_Talent__Unit) + udg_TalentChoiceInt1[udg_Talent__Choice])
	call BlzSetUnitMaxMana(udg_Talent__Unit, BlzGetUnitMaxMana(udg_Talent__Unit) + udg_TalentChoiceInt2[udg_Talent__Choice])
	call BlzSetUnitArmor(udg_Talent__Unit, BlzGetUnitArmor(udg_Talent__Unit) + udg_TalentChoiceReal1[udg_Talent__Choice])
	call SetUnitState(udg_Talent__Unit, UNIT_STATE_LIFE, GetUnitState(udg_Talent__Unit,UNIT_STATE_LIFE) + udg_TalentChoiceInt1[udg_Talent__Choice])
	call SetUnitState(udg_Talent__Unit, UNIT_STATE_MANA, GetUnitState(udg_Talent__Unit,UNIT_STATE_MANA) + udg_TalentChoiceInt2[udg_Talent__Choice])
	if udg_TalentChoiceInt3[udg_Talent__Choice] != -1 then
		//Demon Armor Learn Effect
		if udg_TalentChoiceInt3[udg_Talent__Choice] == 11 then
			if  GetUnitTypeId(udg_Talent__Unit) == 'E000' or GetUnitTypeId(udg_Talent__Unit) == 'E04A' or GetUnitTypeId(udg_Talent__Unit) == 'E02V' or GetUnitTypeId(udg_Talent__Unit) == 'E02Z' then
				call StopSoundBJ( gg_snd_DemonArmor, false )
				call PlaySoundOnUnitBJ( gg_snd_DemonArmor, 100.00, udg_Talent__Unit )
				call SetUnitAbilityLevel( gg_unit_e03G_2001, 'A0BF', 13 )
				call IssueTargetOrder( gg_unit_e03G_2001, "innerfire", udg_Talent__Unit )
			endif
		endif
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = true
	endif
endfunction
function TalentChoiceSustainReset takes nothing returns nothing
	call SetUnitState(udg_Talent__Unit, UNIT_STATE_LIFE, GetUnitState(udg_Talent__Unit,UNIT_STATE_LIFE) - udg_TalentChoiceInt1[udg_Talent__Choice])
	call SetUnitState(udg_Talent__Unit, UNIT_STATE_MANA, GetUnitState(udg_Talent__Unit,UNIT_STATE_MANA) - udg_TalentChoiceInt2[udg_Talent__Choice])
	call BlzSetUnitMaxHP(udg_Talent__Unit, BlzGetUnitMaxHP(udg_Talent__Unit) - udg_TalentChoiceInt1[udg_Talent__Choice])
	call BlzSetUnitMaxMana(udg_Talent__Unit, BlzGetUnitMaxMana(udg_Talent__Unit) - udg_TalentChoiceInt2[udg_Talent__Choice])
	call BlzSetUnitArmor(udg_Talent__Unit, BlzGetUnitArmor(udg_Talent__Unit) - udg_TalentChoiceReal1[udg_Talent__Choice])
	if udg_TalentChoiceInt3[udg_Talent__Choice] != -1 then
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = false
	endif
endfunction

//Movespeed
function TalentChoiceMovementLearn takes nothing returns nothing
	call SetUnitMoveSpeed(udg_Talent__Unit, GetUnitDefaultMoveSpeed(udg_Talent__Unit) + udg_TalentChoiceReal1[udg_Talent__Choice])
	if udg_TalentChoiceInt3[udg_Talent__Choice] != -1 then
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = true
	endif
endfunction

function TalentChoiceMovementReset takes nothing returns nothing
	call SetUnitMoveSpeed(udg_Talent__Unit, GetUnitDefaultMoveSpeed(udg_Talent__Unit))
	if udg_TalentChoiceInt3[udg_Talent__Choice] != -1 then
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = false
	endif
endfunction

//Weapon Cooldown & Damage
function TalentChoiceImproveWeaponLearn takes nothing returns nothing
	call BlzSetUnitAttackCooldown(udg_Talent__Unit, BlzGetUnitAttackCooldown(udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice]) + udg_TalentChoiceReal1[udg_Talent__Choice], udg_TalentChoiceInt1[udg_Talent__Choice])
	call BlzSetUnitBaseDamage(udg_Talent__Unit, BlzGetUnitBaseDamage(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice]) + udg_TalentChoiceInt2[udg_Talent__Choice], udg_TalentChoiceInt1[udg_Talent__Choice])
	if udg_TalentChoiceInt3[udg_Talent__Choice] != -1 then
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = true
	endif
endfunction
function TalentChoiceImproveWeaponReset takes nothing returns nothing
	call BlzSetUnitAttackCooldown(udg_Talent__Unit, BlzGetUnitAttackCooldown(udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice]) - udg_TalentChoiceReal1[udg_Talent__Choice], udg_TalentChoiceInt1[udg_Talent__Choice])
	call BlzSetUnitBaseDamage(udg_Talent__Unit, BlzGetUnitBaseDamage(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice]) - udg_TalentChoiceInt2[udg_Talent__Choice], udg_TalentChoiceInt1[udg_Talent__Choice])
	if udg_TalentChoiceInt3[udg_Talent__Choice] != -1 then
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = false
	endif
endfunction

//Sight and Weapon Range -- Weapon Real Fields are indexed at 1
function TalentChoiceImproveRangeLearn takes nothing returns nothing
	call BlzSetUnitRealField(udg_Talent__Unit, UNIT_RF_SIGHT_RADIUS, BlzGetUnitRealField(udg_Talent__Unit, UNIT_RF_SIGHT_RADIUS) + udg_TalentChoiceReal1[udg_Talent__Choice]) 
	call BlzSetUnitWeaponRealField(udg_Talent__Unit, UNIT_WEAPON_RF_ATTACK_RANGE, 1, BlzGetUnitWeaponRealField(udg_Talent__Unit, UNIT_WEAPON_RF_ATTACK_RANGE, udg_TalentChoiceInt1[udg_Talent__Choice]+1) + udg_TalentChoiceReal2[udg_Talent__Choice])
	call SetUnitAcquireRange(udg_Talent__Unit, GetUnitAcquireRange(udg_Talent__Unit) + udg_TalentChoiceReal2[udg_Talent__Choice]) //Was800
	//call BlzSetUnitWeaponRealField(udg_Talent__Unit, UNIT_WEAPON_RF_ATTACK_RANGE, 1, 650)  //Base + 50 + 100 = 750
	if udg_TalentChoiceInt3[udg_Talent__Choice] != -1 then
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = true
	endif
endfunction
function TalentChoiceImproveRangeReset takes nothing returns nothing
	call BlzSetUnitRealField(udg_Talent__Unit, UNIT_RF_SIGHT_RADIUS, BlzGetUnitRealField(udg_Talent__Unit, UNIT_RF_SIGHT_RADIUS) - udg_TalentChoiceReal1[udg_Talent__Choice]) 
	call BlzSetUnitWeaponRealField(udg_Talent__Unit, UNIT_WEAPON_RF_ATTACK_RANGE, 1, BlzGetUnitWeaponRealField(udg_Talent__Unit, UNIT_WEAPON_RF_ATTACK_RANGE, udg_TalentChoiceInt1[udg_Talent__Choice]+1) - udg_TalentChoiceReal2[udg_Talent__Choice])
	call SetUnitAcquireRange(udg_Talent__Unit, GetUnitAcquireRange(udg_Talent__Unit) - udg_TalentChoiceReal2[udg_Talent__Choice]) //Was 650
	//call BlzSetUnitWeaponRealField(udg_Talent__Unit, UNIT_WEAPON_RF_ATTACK_RANGE, 1, 350) // NewBase - 50 - 200 = 600
	if udg_TalentChoiceInt3[udg_Talent__Choice] != -1 then
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = false
	endif
endfunction

//Used for transforms
function ExemptSells takes integer abilId returns boolean
	if abilId == 'A0CW' then
		return false
	endif
	return true
endfunction

//Improve Spell -- Can improve 2 abilities of same tier or lower
function TalentChoiceImproveSpellLearn takes nothing returns nothing
	local integer i
	
	//Set Real2=0 for false
	//First checks if you have the first ability, then if youre improving more than one checks that as well
	if not( GetUnitAbilityLevel(udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice]) > 0) and ExemptSells(udg_TalentChoiceInt1[udg_Talent__Choice]) and udg_TalentChoiceInt3[udg_Talent__Choice] == 0 then
		call ErrorMessage( "That ability must have one hero point in it before being improved.", GetOwningPlayer(udg_Talent__Unit) )
		set udg_Talent__Error = 404
	elseif udg_TalentChoiceInt3[udg_Talent__Choice] != 0 and udg_TalentChoiceReal2[udg_Talent__Choice] == 0 and not ( ( GetUnitAbilityLevel(udg_Talent__Unit, udg_TalentChoiceInt3[udg_Talent__Choice]) > 0) and ( GetUnitAbilityLevel(udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice]) > 0)) then
		call ErrorMessage( "BOTH abilities must have one hero point in them before being improved.", GetOwningPlayer(udg_Talent__Unit) )
		set udg_Talent__Error = 404
	elseif udg_TalentChoiceReal2[udg_Talent__Choice] != 0 and not (( GetUnitAbilityLevel(udg_Talent__Unit, udg_TalentChoiceInt3[udg_Talent__Choice]) > 0) or ( GetUnitAbilityLevel(udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice]) > 0)) then
		call ErrorMessage( "That ability must have one hero point in it before being improved.", GetOwningPlayer(udg_Talent__Unit) )
		set udg_Talent__Error = 404
	else
		set i = BlzGetAbilityIntegerField(BlzGetUnitAbility(udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice]), ABILITY_IF_LEVELS)
		loop	
			exitwhen i == -1
				call BlzSetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i, BlzGetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i) + udg_TalentChoiceInt2[udg_Talent__Choice])
				call BlzSetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i, BlzGetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i) + udg_TalentChoiceReal1[udg_Talent__Choice])
			set i = i - 1
		endloop
		//Can also improve a 2nd spell, but this spell must already have been learned as well
		if udg_TalentChoiceInt3[udg_Talent__Choice] != 0 then
			set i = BlzGetAbilityIntegerField(BlzGetUnitAbility(udg_Talent__Unit, udg_TalentChoiceInt3[udg_Talent__Choice]), ABILITY_IF_LEVELS)
			loop	
				exitwhen i == -1
					call BlzSetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt3[udg_Talent__Choice], i, BlzGetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt3[udg_Talent__Choice], i) + udg_TalentChoiceInt2[udg_Talent__Choice])
					call BlzSetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt3[udg_Talent__Choice], i, BlzGetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt3[udg_Talent__Choice], i) + udg_TalentChoiceReal1[udg_Talent__Choice])
				set i = i - 1
			endloop
		endif
	endif
endfunction
function TalentChoiceImproveSpellReset takes nothing returns nothing
	local integer i
	set i = BlzGetAbilityIntegerField(BlzGetUnitAbility(udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice]), ABILITY_IF_LEVELS)
	loop	
		exitwhen i == -1
			call BlzSetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i, BlzGetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i) - udg_TalentChoiceInt2[udg_Talent__Choice])
			call BlzSetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i, BlzGetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i) - udg_TalentChoiceReal1[udg_Talent__Choice])
		set i = i - 1
	endloop
	if udg_TalentChoiceInt3[udg_Talent__Choice] != 0 then
		set i = BlzGetAbilityIntegerField(BlzGetUnitAbility(udg_Talent__Unit, udg_TalentChoiceInt3[udg_Talent__Choice]), ABILITY_IF_LEVELS)
		loop	
			exitwhen i == -1
				call BlzSetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt3[udg_Talent__Choice], i, BlzGetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt3[udg_Talent__Choice], i) - udg_TalentChoiceInt2[udg_Talent__Choice])
				call BlzSetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt3[udg_Talent__Choice], i, BlzGetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt3[udg_Talent__Choice], i) - udg_TalentChoiceReal1[udg_Talent__Choice])
			set i = i - 1
		endloop
	endif
endfunction

//Improves a Spell and Sets Boolean
function TalentChoiceImproveSpellWithBooleanLearn takes nothing returns nothing
	local integer i
	if not( GetUnitAbilityLevel(udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice]) > 0) and ExemptSells(udg_TalentChoiceInt1[udg_Talent__Choice]) then
		call ErrorMessage( "This ability must have one hero point in it before being improved.", GetOwningPlayer(udg_Talent__Unit) )
		set udg_Talent__Error = 404
	else
		set i = BlzGetAbilityIntegerField(BlzGetUnitAbility(udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice]), ABILITY_IF_LEVELS)
		loop	
			exitwhen i == -1
				call BlzSetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i, BlzGetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i) + udg_TalentChoiceInt2[udg_Talent__Choice])
				call BlzSetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i, BlzGetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i) + udg_TalentChoiceReal1[udg_Talent__Choice])
			set i = i - 1
		endloop
	endif
	set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = true
endfunction
function TalentChoiceImproveSpellWithBooleanReset takes nothing returns nothing
	local integer i
	set i = BlzGetAbilityIntegerField(BlzGetUnitAbility(udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice]), ABILITY_IF_LEVELS)
	loop	
		exitwhen i == -1
			call BlzSetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i, BlzGetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i) - udg_TalentChoiceInt2[udg_Talent__Choice])
			call BlzSetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i, BlzGetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i) - udg_TalentChoiceReal1[udg_Talent__Choice])
		set i = i - 1
	endloop
	set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = false
endfunction

//Improves a spell but only if a boolean in a prior tier was set to TRUE first
function TalentChoiceImproveSpellCheckBooleanLearn takes nothing returns nothing
	local integer i
	if udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + R2I(udg_TalentChoiceReal2[udg_Talent__Choice]) ] then
		set i = BlzGetAbilityIntegerField(BlzGetUnitAbility(udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice]), ABILITY_IF_LEVELS)
		loop	
			exitwhen i == -1
				call BlzSetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i, BlzGetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i) + udg_TalentChoiceInt2[udg_Talent__Choice])
				call BlzSetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i, BlzGetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i) + udg_TalentChoiceReal1[udg_Talent__Choice])
			set i = i - 1
		endloop
	endif

	if udg_TalentChoiceInt4[udg_Talent__Choice] != -1 then
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt4[udg_Talent__Choice]] = true
	endif
endfunction

function TalentChoiceImproveSpellCheckBooleanReset takes nothing returns nothing
	local integer i
	if udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + R2I(udg_TalentChoiceReal2[udg_Talent__Choice]) ] then
		set i = BlzGetAbilityIntegerField(BlzGetUnitAbility(udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice]), ABILITY_IF_LEVELS)
		loop	
			exitwhen i == -1
				call BlzSetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i, BlzGetUnitAbilityManaCost(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i) - udg_TalentChoiceInt2[udg_Talent__Choice])
				call BlzSetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i, BlzGetUnitAbilityCooldown(udg_Talent__Unit,udg_TalentChoiceInt1[udg_Talent__Choice], i) - udg_TalentChoiceReal1[udg_Talent__Choice])
			set i = i - 1
		endloop
	endif

	if udg_TalentChoiceInt4[udg_Talent__Choice] != -1 then
		set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt4[udg_Talent__Choice]] = false
	endif
endfunction

function TalentChoiceHideSpellLearn takes nothing returns nothing
	call BlzUnitHideAbility( udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice], true )
endfunction

function TalentChoiceHideSpellReset takes nothing returns nothing
	call BlzUnitHideAbility( udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice], false )
endfunction

function TalentChoiceKillUnitLearn takes nothing returns nothing
	local integer uId = GetUnitTypeId(udg_Talent__Unit)
	if ( uId == udg_TalentChoiceInt1[udg_Talent__Choice] ) then
		call KillUnit( udg_SpellUnits[ R2I(udg_TalentChoiceReal1[udg_Talent__Choice]) ])
	elseif ( uId == udg_TalentChoiceInt2[udg_Talent__Choice] ) then
		call KillUnit( udg_SpellUnits[ R2I(udg_TalentChoiceReal2[udg_Talent__Choice]) ])
	endif
	set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = true
endfunction

function TalentChoiceKillUnitReset takes nothing returns nothing
	local integer uId = GetUnitTypeId(udg_Talent__Unit)
	if ( uId == udg_TalentChoiceInt1[udg_Talent__Choice] ) then
		call KillUnit( udg_SpellUnits[ R2I(udg_TalentChoiceReal1[udg_Talent__Choice]) ])
	elseif ( uId == udg_TalentChoiceInt2[udg_Talent__Choice] ) then
		call KillUnit( udg_SpellUnits[ R2I(udg_TalentChoiceReal2[udg_Talent__Choice]) ])
	endif
	set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt3[udg_Talent__Choice]] = false
endfunction

function TalentChoiceDisableSpellLearn takes nothing returns nothing
	local integer uId = GetUnitTypeId(udg_Talent__Unit)
	if  not ( uId == udg_TalentChoiceInt2[udg_Talent__Choice] or uId == udg_TalentChoiceInt3[udg_Talent__Choice] ) then
		if  not ( uId == R2I(udg_TalentChoiceReal1[udg_Talent__Choice]) ) then
			call SetPlayerAbilityAvailableBJ( false, udg_TalentChoiceInt1[udg_Talent__Choice], GetOwningPlayer(udg_Talent__Unit) )
			// call BlzUnitDisableAbility( udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice], true, true )
		endif
	endif
	set udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + R2I(udg_TalentChoiceReal2[udg_Talent__Choice])] = true
endfunction

function TalentChoiceDisableSpellReset takes nothing returns nothing
	// call BlzUnitDisableAbility(udg_Talent__Unit, udg_TalentChoiceInt1[udg_Talent__Choice], false, false)
	call SetPlayerAbilityAvailableBJ( true, udg_TalentChoiceInt1[udg_Talent__Choice], GetOwningPlayer(udg_Talent__Unit) )
	set udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + R2I(udg_TalentChoiceReal2[udg_Talent__Choice])] = false
endfunction


function TalentChoiceBooleanLearn takes nothing returns nothing //whichFunction
	set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt1[udg_Talent__Choice]] = true
	if udg_TalentChoiceInt3[udg_Talent__Choice] != -1 then
		if udg_TalentChoiceInt3[udg_Talent__Choice] == 1 then
			call OutOfCombatTalent(udg_Talent__Unit)
		endif
		//Hide Crit
		if udg_TalentChoiceInt3[udg_Talent__Choice] == 2 then
			if IsCatForm(udg_Talent__Unit) then
				// call AddSpellHideSpell( udg_Talent__Unit, 'Sshm', 'A038', false)
				call AddSpellHideSpell( udg_Talent__Unit, 'A0GW', 'A038', false)
			endif
		endif
		if udg_TalentChoiceInt3[udg_Talent__Choice] == 3 then
			if IsDemonForm( udg_Talent__Unit ) or IsMultiShotForm( udg_Talent__Unit ) then
				call BlzSetUnitBaseDamage(udg_Talent__Unit, BlzGetUnitBaseDamage(udg_Talent__Unit,0) + udg_TalentChoiceInt2[udg_Talent__Choice], 0)
				call BlzSetUnitBaseDamage(udg_Talent__Unit, BlzGetUnitBaseDamage(udg_Talent__Unit,1) + udg_TalentChoiceInt2[udg_Talent__Choice], 1)
			endif
		endif
	endif
endfunction
function TalentChoiceBooleanReset takes nothing returns nothing
	set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt1[udg_Talent__Choice]] = false
	if udg_TalentChoiceInt3[udg_Talent__Choice] != -1 then
		//Un-Hide Crit
		if udg_TalentChoiceInt3[udg_Talent__Choice] == 2 then
			if IsCatForm(udg_Talent__Unit) then
				// call RemoveSpellUnHideSpell( udg_Talent__Unit, 'Sshm', 'A038', true)
				call RemoveSpellUnHideSpell( udg_Talent__Unit, 'A0GW', 'A038', true)
			endif
		endif
		if udg_TalentChoiceInt3[udg_Talent__Choice] == 3 then
			if IsDemonForm( udg_Talent__Unit ) or IsMultiShotForm( udg_Talent__Unit ) then
				call BlzSetUnitBaseDamage(udg_Talent__Unit, BlzGetUnitBaseDamage(udg_Talent__Unit,0) - udg_TalentChoiceInt2[udg_Talent__Choice], 0)
				call BlzSetUnitBaseDamage(udg_Talent__Unit, BlzGetUnitBaseDamage(udg_Talent__Unit,1) - udg_TalentChoiceInt2[udg_Talent__Choice], 1)
			endif
		endif
	endif
endfunction

function TalentChoiceEnableTriggerLearn takes nothing returns nothing
	set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt1[udg_Talent__Choice]] = true
	if  udg_Talent__Unit == udg_yA_Unholy_DK  then
		call EnableTrigger(gg_trg_Exhume_Corpses_A)
	elseif udg_Talent__Unit == udg_yH_Unholy_DK then
		call EnableTrigger(gg_trg_Exhume_Corpses_H)
	endif
endfunction

function TalentChoiceDisableTriggerReset takes nothing returns nothing
	set  udg_TalentChoices[GetPlayerId(GetOwningPlayer(udg_Talent__Unit)) * udg_NUM_OF_TC + udg_TalentChoiceInt1[udg_Talent__Choice]] = false
	if  udg_Talent__Unit == udg_yA_Unholy_DK then
		call DisableTrigger(gg_trg_Exhume_Corpses_A)
	elseif udg_Talent__Unit == udg_yH_Unholy_DK then
		call DisableTrigger(gg_trg_Exhume_Corpses_H)
	endif
endfunction

/*
	Creates
*/

function TalentChoiceCreateStats takes integer strAdd, integer agiAdd, integer intAdd returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[0],udg_TalentPreMadeChoiceTrigger[1])
	set udg_TalentChoiceText[udg_TalentChoiceLast] = udg_TalentStrings[28]
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = strAdd
	set udg_TalentChoiceInt2[udg_TalentChoiceLast] = agiAdd
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = intAdd
	set udg_TalentChoiceReal1[udg_TalentChoiceLast] = -1
	call TalentChoiceAddTextInt(udg_TalentStrings[29] + " ",udg_TalentChoiceInt1[udg_TalentChoiceLast])
	call TalentChoiceAddTextInt(udg_TalentStrings[30]+ " ",udg_TalentChoiceInt2[udg_TalentChoiceLast])
	call TalentChoiceAddTextInt(udg_TalentStrings[31],udg_TalentChoiceInt3[udg_TalentChoiceLast])
	return udg_TalentChoiceLast
endfunction
function TalentChoiceCreateStatsWithBoolean takes integer strAdd, integer agiAdd, integer intAdd, integer choiceIndex, string addInfo returns integer
	call TalentChoiceCreateStats(strAdd,agiAdd,intAdd)
	set udg_TalentChoiceReal1[udg_TalentChoiceLast] = I2R(choiceIndex)
	set udg_TalentChoiceText[udg_TalentChoiceLast] = udg_TalentChoiceText[udg_TalentChoiceLast] + "|n|n" + addInfo
	return udg_TalentChoiceLast
endfunction

function TalentChoiceCreateStr takes integer add returns integer
	return TalentChoiceCreateStats(add,0,0)
endfunction
function TalentChoiceCreateAgi takes integer add returns integer
	return TalentChoiceCreateStats(0,add,0)
endfunction
function TalentChoiceCreateInt takes integer add returns integer
	return TalentChoiceCreateStats(0,0,add)
endfunction
function TalentChoiceCreateSustain takes integer lifeAdd, integer manaAdd, real armorAdd returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[2],udg_TalentPreMadeChoiceTrigger[3])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = lifeAdd
	set udg_TalentChoiceInt2[udg_TalentChoiceLast] = manaAdd
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = -1
	set udg_TalentChoiceReal1[udg_TalentChoiceLast] = armorAdd
	
	set udg_TalentChoiceText[udg_TalentChoiceLast] = udg_TalentStrings[20]
	call TalentChoiceAddTextInt(udg_TalentStrings[21],udg_TalentChoiceInt1[udg_TalentChoiceLast])
	call TalentChoiceAddTextInt(udg_TalentStrings[22],udg_TalentChoiceInt2[udg_TalentChoiceLast])
	call TalentChoiceAddTextReal(udg_TalentStrings[23],udg_TalentChoiceReal1[udg_TalentChoiceLast])
	return udg_TalentChoiceLast
endfunction


function TalentChoiceCreateRegen takes real hpGen, real manaGen, integer lifeAdd, integer manaAdd returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[18],udg_TalentPreMadeChoiceTrigger[19])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = lifeAdd
	set udg_TalentChoiceInt2[udg_TalentChoiceLast] = manaAdd
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = -1
	set udg_TalentChoiceReal1[udg_TalentChoiceLast] = hpGen
	set udg_TalentChoiceReal2[udg_TalentChoiceLast] = manaGen
	
	set udg_TalentChoiceText[udg_TalentChoiceLast] = udg_TalentStrings[20]
	call TalentChoiceAddTextReal(udg_TalentStrings[25],udg_TalentChoiceReal1[udg_TalentChoiceLast])
	if hpGen > 0 then
		call TalentChoiceAddText("|n")
	endif
	call TalentChoiceAddTextReal(udg_TalentStrings[26],udg_TalentChoiceReal2[udg_TalentChoiceLast])
	call TalentChoiceAddTextInt(udg_TalentStrings[21],udg_TalentChoiceInt1[udg_TalentChoiceLast])
	call TalentChoiceAddTextInt(udg_TalentStrings[22],udg_TalentChoiceInt2[udg_TalentChoiceLast])
	return udg_TalentChoiceLast
endfunction

function TalentChoiceCreateMovement takes real movementAdd returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[10],udg_TalentPreMadeChoiceTrigger[11])
	set udg_TalentChoiceReal1[udg_TalentChoiceLast] = movementAdd
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = -1

	set udg_TalentChoiceText[udg_TalentChoiceLast] = udg_TalentStrings[20]
	call TalentChoiceAddTextReal(udg_TalentStrings[24],udg_TalentChoiceReal1[udg_TalentChoiceLast])
	return udg_TalentChoiceLast
endfunction
function TalentChoiceCreateImproveWeapon takes integer weaponIndex, integer damageAdd, real cooldownAdd returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[4],udg_TalentPreMadeChoiceTrigger[5])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = weaponIndex
	set udg_TalentChoiceInt2[udg_TalentChoiceLast] = damageAdd
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = -1
	set udg_TalentChoiceReal1[udg_TalentChoiceLast] = cooldownAdd
	set udg_TalentChoiceReal2[udg_TalentChoiceLast] = -1
	set udg_TalentChoiceText[udg_TalentChoiceLast] = ""//udg_TalentStrings[15]+ I2S(udg_TalentChoiceInt1[udg_TalentChoiceLast])
	call TalentChoiceAddTextInt(udg_TalentStrings[16],udg_TalentChoiceInt2[udg_TalentChoiceLast])
	call TalentChoiceAddTextReal(udg_TalentStrings[17],udg_TalentChoiceReal1[udg_TalentChoiceLast])
	return udg_TalentChoiceLast
endfunction
function TalentChoiceCreateImproveRange takes integer weaponIndex, real sightRange, real weaponRange returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[12],udg_TalentPreMadeChoiceTrigger[13])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = weaponIndex
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = -1
	set udg_TalentChoiceReal1[udg_TalentChoiceLast] = sightRange
	set udg_TalentChoiceReal2[udg_TalentChoiceLast] = weaponRange
	set udg_TalentChoiceText[udg_TalentChoiceLast] = ""
	call TalentChoiceAddTextReal(udg_TalentStrings[18],udg_TalentChoiceReal1[udg_TalentChoiceLast])
	if(weaponRange != 0 and sightRange !=0  ) then
		set udg_TalentChoiceText[udg_TalentChoiceLast] = udg_TalentChoiceText[udg_TalentChoiceLast] + udg_TalentStrings[12]
	endif
	call TalentChoiceAddTextReal(udg_TalentStrings[19],udg_TalentChoiceReal2[udg_TalentChoiceLast])
	return udg_TalentChoiceLast
endfunction

function TalentChoiceCreateImproveStatWithBoolean takes integer whichImprove, integer int1, integer int2, real real1, real real2, integer choiceIndex returns integer
	if whichImprove == 0 then
		call TalentChoiceCreateSustain(int1, int2, real1)
	elseif whichImprove == 1 then
		call TalentChoiceCreateMovement(real1)
	elseif whichImprove == 2 then
		call TalentChoiceCreateImproveWeapon(int1, int2, real1)
	elseif whichImprove == 3 then
		call TalentChoiceCreateImproveRange(int1, real1, real2)
	elseif whichImprove == 4 then
		call TalentChoiceCreateRegen(real1, real2, int1, int2)
	elseif whichImprove == 5 then //Kill Unit on learn
		call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[24],udg_TalentPreMadeChoiceTrigger[25])
		//uIds
		set udg_TalentChoiceInt1[udg_TalentChoiceLast] = int1
		set udg_TalentChoiceInt2[udg_TalentChoiceLast] = int2
		//udg_o
		set udg_TalentChoiceReal1[udg_TalentChoiceLast] = real1
		set udg_TalentChoiceReal2[udg_TalentChoiceLast] = real2
	endif
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = choiceIndex

	return udg_TalentChoiceLast
endfunction


function TalentChoiceCreateImproveSpell takes integer spell, integer manaCostAdd, real cooldownAdd returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[6],udg_TalentPreMadeChoiceTrigger[7])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = spell
	set udg_TalentChoiceInt2[udg_TalentChoiceLast] = manaCostAdd
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = 0
	set udg_TalentChoiceReal1[udg_TalentChoiceLast] = cooldownAdd
	set udg_TalentChoiceText[udg_TalentChoiceLast] = udg_TalentStrings[9] + GetObjectName(spell)
	call TalentChoiceAddTextInt(udg_TalentStrings[10],udg_TalentChoiceInt2[udg_TalentChoiceLast])
	call TalentChoiceAddText(udg_TalentStrings[2])
	call TalentChoiceAddTextReal(udg_TalentStrings[11],udg_TalentChoiceReal1[udg_TalentChoiceLast])
	return udg_TalentChoiceLast
endfunction

function TalentChoiceCreateImproveTwoSpells takes integer spell, integer spell2, integer manaCostAdd, real cooldownAdd, real isOnlyOneSpellNeeded returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[6],udg_TalentPreMadeChoiceTrigger[7])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = spell
	set udg_TalentChoiceInt2[udg_TalentChoiceLast] = manaCostAdd
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = spell2
	set udg_TalentChoiceReal1[udg_TalentChoiceLast] = cooldownAdd
	set udg_TalentChoiceReal2[udg_TalentChoiceLast] = isOnlyOneSpellNeeded
	set udg_TalentChoiceText[udg_TalentChoiceLast] = udg_TalentStrings[9] + GetObjectName(spell) + " and " + GetObjectName(spell2)
	call TalentChoiceAddTextInt(udg_TalentStrings[10],udg_TalentChoiceInt2[udg_TalentChoiceLast])
	call TalentChoiceAddTextReal(udg_TalentStrings[11],udg_TalentChoiceReal1[udg_TalentChoiceLast])
	return udg_TalentChoiceLast
endfunction

function TalentChoiceCreateImproveSpellWithBoolean takes integer spell, integer manaCostAdd, real cooldownAdd, integer choiceIndex returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[14],udg_TalentPreMadeChoiceTrigger[15])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = spell
	set udg_TalentChoiceInt2[udg_TalentChoiceLast] = manaCostAdd
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = choiceIndex
	set udg_TalentChoiceReal1[udg_TalentChoiceLast] = cooldownAdd
	call TalentChoiceAddTextInt(udg_TalentStrings[10],udg_TalentChoiceInt2[udg_TalentChoiceLast])
	call TalentChoiceAddTextReal(udg_TalentStrings[11],udg_TalentChoiceReal1[udg_TalentChoiceLast])
	return udg_TalentChoiceLast
endfunction

//Replace and potentionally improve a spell - This will always replace a spell but will only improve it if the boolean passed in was set to true in a prior tier
function TalentChoiceCreateReplaceAndImproveSpell takes integer oldSpell, integer newSpell, integer manaCostAdd, real cooldownAdd, integer previousChoiceIndex returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[16],udg_TalentPreMadeChoiceTrigger[17])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = newSpell 		
	set udg_TalentChoiceInt2[udg_TalentChoiceLast] = manaCostAdd
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = oldSpell 	
	set udg_TalentChoiceInt4[udg_TalentChoiceLast] = -1 		
	set udg_TalentChoiceReal1[udg_TalentChoiceLast] = cooldownAdd
	set udg_TalentChoiceReal2[udg_TalentChoiceLast] = I2R(previousChoiceIndex)
	call TalentChoiceReplaceAbility(udg_TalentChoiceLast, oldSpell, newSpell)
	return udg_TalentChoiceLast
endfunction

function TalentChoiceCreateReplaceAndImproveSpellWithBoolean takes integer oldSpell, integer newSpell, integer manaCostAdd, real cooldownAdd, integer previousChoiceIndex, integer currentChoiceIndex returns integer	
	call TalentChoiceCreateReplaceAndImproveSpell(oldSpell, newSpell, manaCostAdd, cooldownAdd, previousChoiceIndex)
	set udg_TalentChoiceInt4[udg_TalentChoiceLast] = currentChoiceIndex 	
	return udg_TalentChoiceLast
endfunction

//heroTypeId corresponds to oldSpell1, else it will look to replace oldSpell2
function TalentChoiceCreateReplaceSpellBasedOnUnitType takes integer oldSpell1, integer oldSpell2, integer newSpell, integer heroTypeId returns integer
	//Potentional to Improve CD for future use
	// set udg_TalentChoiceReal1[udg_TalentChoiceLast] = cooldownAdd
	// set udg_TalentChoiceReal2[udg_TalentChoiceLast] = I2R(choiceIndex)
	if GetUnitTypeId( udg_Talent__Unit ) == heroTypeId then
		call TalentChoiceReplaceAbilityEx( oldSpell1, newSpell)
	else
		call TalentChoiceReplaceAbilityEx( oldSpell2, newSpell)
	endif
	return udg_TalentChoiceLast
endfunction

function TalentChoiceCreateBoolean takes integer choiceIndex returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[8], udg_TalentPreMadeChoiceTrigger[9])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = choiceIndex
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = -1
	return udg_TalentChoiceLast
endfunction

function TalentChoiceCreateBooleanWithAddedFunction takes integer choiceIndex, integer whichFunction returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[8], udg_TalentPreMadeChoiceTrigger[9])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = choiceIndex
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = whichFunction
	return udg_TalentChoiceLast
endfunction

function TalentChoiceCreateBooleanWithImproveWeapon takes integer choiceIndex, integer damageAdded returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[8], udg_TalentPreMadeChoiceTrigger[9])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = choiceIndex
	set udg_TalentChoiceInt2[udg_TalentChoiceLast] = damageAdded
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = 3
	return udg_TalentChoiceLast
endfunction

function TalentChoiceCreateAddSpell takes integer spell, boolean useButtonInfos returns integer
	call TalentChoiceCreateEx(null,null)
	call TalentChoiceAddAbility(udg_TalentChoiceLast, spell)
	if useButtonInfos then
		set udg_TalentChoiceText[udg_TalentChoiceLast] = BlzGetAbilityExtendedTooltip(spell,0) + "|n|n|cff707070Lvl 20 Talents automatically upgrade at levels 30 and 40."
		set udg_TalentChoiceHead[udg_TalentChoiceLast] = BlzGetAbilityTooltip(spell,0)
		set udg_TalentChoiceIcon[udg_TalentChoiceLast] = BlzGetAbilityIcon(spell)
	endif
	return udg_TalentChoiceLast
endfunction

function TalentChoiceCreateAddSpellWithBoolean takes integer spell, boolean useButtonInfos, integer choiceIndex returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[8], udg_TalentPreMadeChoiceTrigger[9])
	call TalentChoiceAddAbility(udg_TalentChoiceLast, spell)
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = choiceIndex
	if useButtonInfos then
		set udg_TalentChoiceText[udg_TalentChoiceLast] = BlzGetAbilityExtendedTooltip(spell,0) + "|n|n|cff707070Lvl 20 Talents automatically upgrade at levels 30 and 40."
		set udg_TalentChoiceHead[udg_TalentChoiceLast] = BlzGetAbilityTooltip(spell,0)
		set udg_TalentChoiceIcon[udg_TalentChoiceLast] = BlzGetAbilityIcon(spell)
	endif
	return udg_TalentChoiceLast
endfunction

function TalentChoiceCreateAddAndHideSpell takes integer spell, integer hiddenSpell, boolean useButtonInfos returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[20],udg_TalentPreMadeChoiceTrigger[21])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = hiddenSpell
	call TalentChoiceAddAbility(udg_TalentChoiceLast, spell)
	if useButtonInfos then
		set udg_TalentChoiceText[udg_TalentChoiceLast] = BlzGetAbilityExtendedTooltip(spell,0)
		set udg_TalentChoiceHead[udg_TalentChoiceLast] = BlzGetAbilityTooltip(spell,0)
		set udg_TalentChoiceIcon[udg_TalentChoiceLast] = BlzGetAbilityIcon(spell)
	endif
	return udg_TalentChoiceLast
endfunction

//Warning! Need to manually remove the 2nd spell in talent.j under prevSelections[i] == 2
function TalentChoiceCreateAddAndHideSpells takes string abilityCodes, integer toolTipAbility, integer hiddenSpell, boolean useButtonInfos returns integer
	//local integer toolTipAbility = 	S2I(SubStringBJ(abilityCodes,0,4))
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[20],udg_TalentPreMadeChoiceTrigger[21])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = hiddenSpell
	call TalentChoiceAddSpells(udg_TalentChoiceLast, abilityCodes)
	if useButtonInfos then
		set udg_TalentChoiceText[udg_TalentChoiceLast] = BlzGetAbilityExtendedTooltip(toolTipAbility,0)
		set udg_TalentChoiceHead[udg_TalentChoiceLast] = BlzGetAbilityTooltip(toolTipAbility,0)
		set udg_TalentChoiceIcon[udg_TalentChoiceLast] = BlzGetAbilityIcon(toolTipAbility)
	endif
	return udg_TalentChoiceLast
endfunction


//3 more ints, so 3 unit types
function TalentChoiceCreateAddAndDisableSpell takes integer spell, integer form1, integer form2, integer form3, integer whichChoice , boolean useButtonInfos returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[22],udg_TalentPreMadeChoiceTrigger[23])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = spell
	set udg_TalentChoiceInt2[udg_TalentChoiceLast] = form1
	set udg_TalentChoiceInt3[udg_TalentChoiceLast] = form2
	set udg_TalentChoiceReal1[udg_TalentChoiceLast] = I2R(form3)
	set udg_TalentChoiceReal2[udg_TalentChoiceLast] = I2R(whichChoice)
	call TalentChoiceAddAbility(udg_TalentChoiceLast, spell)
	if useButtonInfos then
		set udg_TalentChoiceText[udg_TalentChoiceLast] = BlzGetAbilityExtendedTooltip(spell,0)
		set udg_TalentChoiceHead[udg_TalentChoiceLast] = BlzGetAbilityTooltip(spell,0)
		set udg_TalentChoiceIcon[udg_TalentChoiceLast] = BlzGetAbilityIcon(spell)
	endif
	return udg_TalentChoiceLast
endfunction

//Does not work on init
function TalentChoiceCreateAddSpellBasedOnUnitType takes integer spell1, integer spell2, integer unitType, boolean useButtonInfos returns integer
	call TalentChoiceCreateEx(null,null)
	if unitType == GetUnitTypeId(udg_Talent__Unit) then
		call TalentChoiceAddAbility(udg_TalentChoiceLast, spell1)
		if useButtonInfos then
			set udg_TalentChoiceText[udg_TalentChoiceLast] = BlzGetAbilityExtendedTooltip(spell1,0)
			set udg_TalentChoiceHead[udg_TalentChoiceLast] = BlzGetAbilityTooltip(spell1,0)
			set udg_TalentChoiceIcon[udg_TalentChoiceLast] = BlzGetAbilityIcon(spell1)
		endif
	else
		call TalentChoiceAddAbility(udg_TalentChoiceLast, spell2)
		if useButtonInfos then
			set udg_TalentChoiceText[udg_TalentChoiceLast] = BlzGetAbilityExtendedTooltip(spell2,0)
			set udg_TalentChoiceHead[udg_TalentChoiceLast] = BlzGetAbilityTooltip(spell2,0)
			set udg_TalentChoiceIcon[udg_TalentChoiceLast] = BlzGetAbilityIcon(spell2)
		endif
	endif
	return udg_TalentChoiceLast
endfunction

function TalentChoiceEnableTrigger takes integer choiceIndex returns integer
	call TalentChoiceCreateTriggerEx(udg_TalentPreMadeChoiceTrigger[26], udg_TalentPreMadeChoiceTrigger[27])
	set udg_TalentChoiceInt1[udg_TalentChoiceLast] = choiceIndex
	return udg_TalentChoiceLast
endfunction

//===========================================================================
function InitTrig_TalentPreMadeChoice takes nothing returns nothing
	set udg_TalentPreMadeChoiceTrigger[0] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[1] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[2] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[3] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[4] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[5] = CreateTrigger()	
	set udg_TalentPreMadeChoiceTrigger[6] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[7] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[8] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[9] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[10] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[11] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[12] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[13] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[14] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[15] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[16] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[17] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[18] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[19] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[20] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[21] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[22] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[23] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[24] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[25] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[26] = CreateTrigger()
	set udg_TalentPreMadeChoiceTrigger[27] = CreateTrigger()

	
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[0], function TalentChoiceStatsLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[1], function TalentChoiceStatsReset)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[2], function TalentChoiceSustainLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[3], function TalentChoiceSustainReset)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[4], function TalentChoiceImproveWeaponLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[5], function TalentChoiceImproveWeaponReset)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[6], function TalentChoiceImproveSpellLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[7], function TalentChoiceImproveSpellReset)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[8], function TalentChoiceBooleanLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[9], function TalentChoiceBooleanReset)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[10], function TalentChoiceMovementLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[11], function TalentChoiceMovementReset)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[12], function TalentChoiceImproveRangeLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[13], function TalentChoiceImproveRangeReset)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[14], function TalentChoiceImproveSpellWithBooleanLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[15], function TalentChoiceImproveSpellWithBooleanReset)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[16], function TalentChoiceImproveSpellCheckBooleanLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[17], function TalentChoiceImproveSpellCheckBooleanReset)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[18], function TalentChoiceRegenLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[19], function TalentChoiceRegenReset)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[20], function TalentChoiceHideSpellLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[21], function TalentChoiceHideSpellReset)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[22], function TalentChoiceDisableSpellLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[23], function TalentChoiceDisableSpellReset)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[24], function TalentChoiceKillUnitLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[25], function TalentChoiceKillUnitReset)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[26], function TalentChoiceEnableTriggerLearn)
	call TriggerAddAction(udg_TalentPreMadeChoiceTrigger[27], function TalentChoiceDisableTriggerReset)	

	//Note: Make sure to create the trigger too!!

endfunction
