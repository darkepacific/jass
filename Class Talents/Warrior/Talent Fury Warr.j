function TalentFuryWarr takes nothing returns nothing
	local integer heroTypeId = 'H03E'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 	//Mark Level 10 as last choice, after the heroe picks it, the selection skills are removed.

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)

	set choice = TalentChoiceCreateImproveSpell('A05G', 0, -1.5)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Hamstring"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNShockwave.blp"

	set choice = TalentChoiceCreateSustain(0, 0, 4)
	set udg_TalentChoiceHead[choice] = "Increased Armor"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne.blp"

	set choice = TalentChoiceCreateImproveWeapon(0, 18, 0)
	set udg_TalentChoiceHead[choice] = "Increased Damage"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Sword_23.blp"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	
	set choice = TalentChoiceCreateBoolean(3) 
	set udg_TalentChoiceHead[choice] = "Blood Thirsty"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNVictory_Rush.blp"
	set udg_TalentChoiceText[choice] = "Blood Rush now heals for 8% Max HP"

	//Makgorawr - The buff on Mak'gora lasts 4 seconds longer
	//Warbringer - Bloodthrist slows enemies at the end of it's path for 1sec
	//Into the Fray - Killing a unit immediately resets the cooldown on Blood Thirst

	set choice = TalentChoiceCreateSustain(300, 0, 0)
	set udg_TalentChoiceHead[choice] = "Increased Health"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPhilosophersStone.blp"

	set choice = TalentChoiceCreateImproveWeapon(0, 0, -0.51)	//Base is 2.2/1.83 - 1 = 20%
	set udg_TalentChoiceHead[choice] = "Increased Attack Speed"
	set udg_TalentChoiceText[choice] = "Attack Speed: +30%"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpiritWalkerMasterTraining.blp"


	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)

	call TalentChoiceCreateAddSpell('A02E',true)  //Execute -- cooldown is reset if the unit dies within 1sec from this damage
	call TalentChoiceCreateAddSpell('A07U',true)  //Dragon Roar, deal  dmg around fear all enemies for 1.66 sec and increase the dmg of your Q an E by 300% for
	call TalentChoiceCreateAddSpell('A0DL',true)  //Recklessness


	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)

	set choice = TalentChoiceCreateBoolean(9) 
	set udg_TalentChoiceHead[choice] = "Endless Regeneration"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNRegenerate.blp"
	set udg_TalentChoiceText[choice] = "Instantly Heal for 25% Max HP after endless rage ends"

	set choice = TalentChoiceCreateMovement(50)
	set udg_TalentChoiceHead[choice] = "Increased Movement Speed"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_fire_burningspeed.blp"

	set choice = TalentChoiceCreateStats(20, 0, 0)
	set udg_TalentChoiceHead[choice] = "Overwhelming: Str"
   	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp"


	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateBoolean(12) 
	set udg_TalentChoiceHead[choice] = "Gul'dan Cheats!"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNGuldan2.blp"
	set udg_TalentChoiceText[choice] = "Start your Mak'Gora already with the first buff and the buffs last for 3 sec longer" //And can stack up to 4 times!

	set choice = TalentChoiceCreateBoolean(13) 
	set udg_TalentChoiceHead[choice] = "Raging Blow"
	set udg_TalentChoiceText[choice] = "Hamstring no longer slows targets but instead deals 60% more damage"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNRaging_Blow.blp"

	set choice = TalentChoiceCreateReplaceSpell('A05J','A07L')
	set udg_TalentChoiceHead[choice] = "Vampiric Aura"
	set udg_TalentChoiceText[choice] = "Replace berserker stance for Vampiric Aura with 35% Lifesteal"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNVampiricAura.blp"

	//LEVEL 50

	//Death Wish - Increase damage taken and done 15%
	//Enduring Rage - increase the duration of Endless Rage by 3 sec
	//Warbringer - Bloodthrist now slows enemies at the end of it's path for 3sec and Killing a unit immediately resets the cooldown on Blood Thirst
	//Wrecking throw - throw your weapon at an enemy dealing damage and forcing them to swith to attack youing deals 500% more damage to shields
	//Spell Block -  activate to reduce all incoming magic damage by 50% for 4s
	//Rampage - Unleashes a series of 4 brutal strikes
		
	//Into the Fray - Killing a unit immediately resets the cooldown on Blood Thirst



endfunction

//===========================================================================
function InitTrig_Talent_Fury_Warr takes nothing returns nothing
    set gg_trg_Talent_Fury_Warr = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Fury_Warr, function TalentFuryWarr )
    call TalentHeroSetCopy('H03D', 'H03E')	
endfunction
