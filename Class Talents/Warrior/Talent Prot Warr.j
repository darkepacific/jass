function TalentProtWarr takes nothing returns nothing
	local integer heroTypeId = 'H010'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//https://www.hiveworkshop.com/threads/warlord.335698/ Warlord Model

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)

	set choice = TalentChoiceCreateImproveSpell('A018', -20, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Charge"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Warrior_Charge.blp"

	set choice = TalentChoiceCreateSustain(0, 0, 4)
	set udg_TalentChoiceHead[choice] = "Increased Armor"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne.blp"

	set choice = TalentChoiceCreateImproveWeapon(0, 18, 0)
	set udg_TalentChoiceHead[choice] = "Increased Damage"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Sword_23.blp"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateBoolean(3) 
	set udg_TalentChoiceHead[choice] = "Into the Fray"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNInto_The_Fray.blp"
	set udg_TalentChoiceText[choice] = "Killing a unit immediately resets the cooldown on Charge"

	set choice = TalentChoiceCreateSustain(300, 0, 0)
	set udg_TalentChoiceHead[choice] = "Increased Health"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPhilosophersStone.blp"

	set choice = TalentChoiceCreateImproveWeapon(0, 0, -0.51)	//Base is 2.2/1.83 - 1 = 20%
	set udg_TalentChoiceHead[choice] = "Increased Attack Speed"
	set udg_TalentChoiceText[choice] = "Attack Speed: +30%"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpiritWalkerMasterTraining.blp"

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)

	call TalentChoiceCreateAddSpell('A02E',true) //Execute
	call TalentChoiceCreateAddSpell('A07U',true) //Dragon Roar
	call TalentChoiceCreateAddSpell('A0E0',true) //Shield Wall - reduce all incoming dmg by 40% for 4 seconds  40/30/20s cd

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)

	set choice = TalentChoiceCreateBoolean(9) 
	set udg_TalentChoiceHead[choice] = "Thunderstruck"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_thunderking_overcharge.blp"
	set udg_TalentChoiceText[choice] = "Thunderclap and War Stomp now deal 300 extra damage."

	set choice = TalentChoiceCreateBoolean(10) 
	set udg_TalentChoiceHead[choice] = "Ignore Pain"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNIgnore_Pain.blp"
	set udg_TalentChoiceText[choice] = "Reduce all damage you take by 12%."

	set choice = TalentChoiceCreateStats(20, 0, 0)
	set udg_TalentChoiceHead[choice] = "Overwhelming: Str"
   	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp"

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)

	set choice = TalentChoiceCreateBoolean(12) 
	set udg_TalentChoiceHead[choice] = "Fresh Meat"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNCorpseExplode.blp"
	set udg_TalentChoiceText[choice] = "Charge now heals you for 9% of your max health on arrival, when used on a different target from it's last cast"
	
	set choice = TalentChoiceCreateBooleanWithAddedFunction(13,1) 
	set udg_TalentChoiceHead[choice] = "Second Wind"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Hunter_Harass.blp"
	set udg_TalentChoiceText[choice] = "Restores 6% max health and mana every second after leaving combat for 5 sec."

	set choice = TalentChoiceCreateRegen(30.0, 0, 0, 0)
	set udg_TalentChoiceHead[choice] = "Greatly Increased Health Regen"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNNeverSurrender.blp"	


	//LEVEL 50
	// set choice = TalentChoiceCreateReplaceSpellBasedOnUnitType('AHbh','A03D','NEWS', 'H010')
	// set udg_TalentChoiceHead[choice] = "Disarm"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Warrior_Disarm.blp"
	// set udg_TalentChoiceText[choice] = "Hides Bash - disarms a target interrupting them and reducing all damage they deal by 25% for 4s"


	//Spell Block - Hides bash, activate to reduce all incoming magic damage by 50% for 4s

	//Haymaker - stuns and knocks an enemy back 500 range, dealing 200 damage enemies in the path are always knocked away and take 50% of the damage
	//Shockwave - the warrior unleashes a slow moving wave the deals heavy damage and stuns enemies in it's path
	//Shield Slam - replaces bash, slam you shield forward stunning any targets in front of you and dealing X damage
	//Slam - hides bash - your next attack is garanteed to bash and stun for twice as long and deal bonus damage

	//Ferocious Taunt - taunt now ticks twice more after the initial cast, retaunting enemies again

	//Berserker Stance - Greatly increase attack speed

	//Ravager - improves bash, throws a whirling weapon that creates that casts bladestorm at a target location
	// Wrecking throw - throw your weapon at an enemy dealing damage and forcing them to swith to attack youing deals 500% more damage to shields


	//Double Time - Reduced cooldown on charge by 1s and increased range by 50
	//Piercing Howl - aunt now slows all enemy's movement speed by 60% for 4s and it's range is increased by 20%
	


endfunction

//===========================================================================
function InitTrig_Talent_Prot_Warr takes nothing returns nothing
    set gg_trg_Talent_Prot_Warr = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Prot_Warr, function TalentProtWarr )
    call TalentHeroSetCopy('H01T', 'H010')	
endfunction
