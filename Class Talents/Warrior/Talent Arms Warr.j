function TalentArmsWarr takes nothing returns nothing
	local integer heroTypeId = 'H01J'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpell('A04M', -30, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Cleave"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Warrior_Cleave.blp"

	set choice = TalentChoiceCreateSustain(250, 0, 0)
	set udg_TalentChoiceHead[choice] = "Increased Health"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPhilosophersStone.blp"

	set choice = TalentChoiceCreateImproveWeapon(0, 0, -0.37)	//Base is 2.2/1.83 - 1 = 20%
	set udg_TalentChoiceHead[choice] = "Increased Attack Speed"
	set udg_TalentChoiceText[choice] = "Attack Speed: +20%"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Weapon_ShortBlade_05.blp"


	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateImproveSpell('A04K', 0, -1.5)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Heroic Leap"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNExplosionToss.blp"

	set choice = TalentChoiceCreateMovement(30)
	set udg_TalentChoiceHead[choice] = "Increased Movement Speed"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed.blp"

	set choice = TalentChoiceCreateBoolean(5)
	set udg_TalentChoiceHead[choice] = "Bounding Stride"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHeroicLeap.blp"
	set udg_TalentChoiceText[choice] = "Gain a 70% ms buff for 2.5 sec after using Heroic Leap"

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpell('A02E',true)  //Execute
	call TalentChoiceCreateAddSpell('A07U',true) //Dragon Roar  
	call TalentChoiceCreateAddSpell('A006',true) //Warbreaker

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateBoolean(10) 
	set udg_TalentChoiceHead[choice] = "Piercing Howl"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMaskOfDeath.blp"
	set udg_TalentChoiceText[choice] = "Taunt now slows all enemy's movement speed by 60% for 4s and it's range is increased by 20%"
	
	set choice = TalentChoiceCreateBoolean(9) 
	set udg_TalentChoiceHead[choice] = "Crimson Tempest"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNVampBlood.blp"
	set udg_TalentChoiceText[choice] = "Bladestorm now heals for 18% of the damge done"

	set choice = TalentChoiceCreateStats(20, 0, 0)
	set udg_TalentChoiceHead[choice] = "Overwhelming: Str"
   	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp"

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateBoolean(12) 
	set udg_TalentChoiceHead[choice] = "Deep Wounds"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_BackStab.blp"
	set udg_TalentChoiceText[choice] = "Bladestorm now deals 30% more damage to targets that are slowed or stunned"

	set choice = TalentChoiceCreateBooleanWithAddedFunction(13,1) 
	set udg_TalentChoiceHead[choice] = "Second Wind"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Hunter_Harass.blp"
	set udg_TalentChoiceText[choice] = "Restores 6% max health and mana every second after leaving combat for 5 sec."
	
	set choice = TalentChoiceCreateAddAndHideSpell('A08F','A04N', false)
	set udg_TalentChoiceHead[choice] = "Die by the Sword"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Warrior_Challenge.blp"
	set udg_TalentChoiceText[choice] = "Gain an active ability that increases the passive dodge and crit chance on Grit to 100% for 3 sec."
		

	//LEVEL 50
	//Bladestorm now has a 35% chance to crit for a total str dmg per sec (120 + 80 at lvl40)
	//Cleaving Attack - replaces Grit, attacks hits all enemies in an AoE
	//Battle Shout - taunt now increases the damage of all allies within 500 range by 20% for 4 sec (basically a roar)
	//Impending Victory - Your next auto attack deals 300% more damage and heals you for 30% of the damage dealt. 
				// Our instantly deal damage to the target and heal you for 30% of max health. 30 sec cd
	// Skull Splitter - bash an enemies skull causing damage and them to take 20% more damage from you for 4 sec
	// Wrecking throw - throw your weapon at an enemy dealing damage and forcing them to swith to attack youing deals 500% more damage to shields
	//Haymaker - stuns and knocks an enemy back 500 range, dealing 200 damage enemies in the path are always knocked away and take 50% of the damage

	// set choice = TalentChoiceCreateBoolean(14) 
	// set udg_TalentChoiceHead[choice] = "Critical Storm"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNCriticalStrike.blp"
	// set udg_TalentChoiceText[choice] = "Bladestorm can now critically strike for 50% increased damage"

	//Taunt now silences and forces all enemies to attack you for the full duration (including bosses and players)

	

endfunction

//===========================================================================
function InitTrig_Talent_Arms_Warr takes nothing returns nothing
    set gg_trg_Talent_Arms_Warr = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Arms_Warr, function TalentArmsWarr )
    call TalentHeroSetCopy('H028', 'H01J')	
endfunction
