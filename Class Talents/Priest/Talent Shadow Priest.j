function TalentShadowPriest takes nothing returns nothing
	local integer heroTypeId = 'H00Q'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 	


	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	//Unable to target summoned units
	set choice = TalentChoiceCreateImproveSpell('A0GS', 0, -1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Shadow Word: Pain"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNShadow_Word_Pain.blp"

	set choice = TalentChoiceCreateImproveSpell('A003', 0, -1.25)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Mind Blast"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNUnholyFrenzy.blp"

	set choice = TalentChoiceCreateBoolean(2)
	set udg_TalentChoiceHead[choice] = "Improved Mind Blast"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNImprovedUnholyFrenzy.blp"
	set udg_TalentChoiceText[choice] = "Mind Blast now deals damage equal to 5x Bonus Int and has a 50% chance to generates an additional Shadow Orb."


	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)

	set choice = TalentChoiceCreateSustain(300, 0, 0)
	set udg_TalentChoiceHead[choice] = "Power Word: Fortitude"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPowerWordFortitude.blp"

	set choice = TalentChoiceCreateBoolean(4)
	set udg_TalentChoiceHead[choice] = "Mana Drain"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNManaDrain.blp"
	set udg_TalentChoiceText[choice] = "Mind Flay now drains mana equal to 50% of the damage dealt"

	set choice = TalentChoiceCreateBoolean(5)
	set udg_TalentChoiceHead[choice] = "Peak Insanity"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNNecromancer.blp"
	set udg_TalentChoiceText[choice] = "If any enemy dies while being mind flayed instantly reset its cooldown"


	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpell('A0FA', true) //Psychic Scream  -- 
	call TalentChoiceCreateAddSpellWithBoolean('A02M', true, 6) //Shadowform  
		//Void Tendril: summons shadowy tendrils out of the ground rooting all enemies in an area in place and dealing damage
	call TalentChoiceCreateAddSpell('A0FS', true)//Shadowfiend  - Can cast void tendril
	//attacks restore mana, void explosion
	//4k hp, high armor, can dispel magic is healed by vampiric embrace as well
	


	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)

	set choice = TalentChoiceCreateBoolean(9)
	set udg_TalentChoiceHead[choice] = "Silence"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNability_priest_silence.blp"
	set udg_TalentChoiceText[choice] = "Shadow Word Pain now silences targets for 2 sec. Heroes 1 sec."

	set choice = TalentChoiceCreateBoolean(10)
	set udg_TalentChoiceHead[choice] = "Soul Steal"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSoulSteal.blp"//LifeDrain.blp"
	set udg_TalentChoiceText[choice] = "Mind Flay now deals an additional 25% damage and heals for that same amount."

	set choice = TalentChoiceCreateImproveSpell('A0E9', 0, -5.0)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Vampiric Embrace"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNUnsummonBuilding.blp"

	// set choice = TalentChoiceCreateImproveSpell('A0FL', -25, 0)
	// set udg_TalentChoiceHead[choice] = "San'layn"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNShadow_Word_Pain.blp"
	// set udg_TalentChoiceText[choice] = "Reduce the cd of vamp embrace and increase the healing done by 5%"

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	//12
	set choice = TalentChoiceCreateBoolean(13)
	set udg_TalentChoiceHead[choice] = "Shadow Word: Death"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNShadowWordDeath.blp"
	set udg_TalentChoiceText[choice] = "Shadow Word Pain now instantly deals an additional 800 magic damage when cast on targets with less than 30% hp."

	set choice = TalentChoiceCreateBoolean(14)
	set udg_TalentChoiceHead[choice] = "Void Explosion"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNShadowWill.blp"
	set udg_TalentChoiceText[choice] = "If a target dies while mind flay is channeled on them, they explode in a burst of void dealing 500 + 5 x Bonus Intelligence damage to all enemies around them."

	set choice = TalentChoiceCreateRegen(15.0, 15.0, 0, 0)
	set udg_TalentChoiceHead[choice] = "Divine Spirit"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDivineSpirit.blp"	

	//LEVEL 50

	//https://www.hiveworkshop.com/threads/voidskullaura_v5.249731/

	//Void Shift:-- channel for 1 sec, if success swap health percentages with an enemy (Max 2000 hp difference)
		//Or maybe swap up to 1000 hp
		// when taken below 25% hp by an enemy swap health percentages

	// set choice = TalentChoiceCreateBoolean(x)
	// set udg_TalentChoiceHead[choice] = "Shadow Corruption"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNOrbOfCorruption.blp"
	// set udg_TalentChoiceText[choice] = "Gain a shadow orb each time a target with Shadow Word pain dies."

	// set choice = TalentChoiceCreateBoolean(x)
	// set udg_TalentChoiceHead[choice] = "Psychic Link"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNOrbOfCorruption.blp"
	// set udg_TalentChoiceText[choice] = "Casting Mind Blast now hits all targets with shadow word: pain currently inflicted on them as well."

	//Shadowy Apparition - once every 3rd spell cast a shadowy apparition flows ominiously towards the target dealing damage on arrival. 
		//(Make it a dummy with a slow moving acid projectile, where the projectile is a shade)
		//Or see the pyroblast spell

	//Spirit of Pain - become a dark angel after death, exploding after 5 seconds dealing damage to all enemies around you 
	//Shadowy Tendril Casting X,Y,Z or Killing a unit causes a shadowy tendril to spawn nearby attacking all enemies. Lasts 5 sec.
	//Shadowform: Increase all damage done by 10% (Set opac)
	


	/*
	https://www.hiveworkshop.com/threads/btnvoodoodoll-forest-troll-shadow-priest-icon-contest-18-entry.318507/
	https://www.hiveworkshop.com/threads/btneyeofshadows.169554/
	https://www.hiveworkshop.com/threads/btnspell_shadow_spectralsight.54579/
	https://www.hiveworkshop.com/threads/btnshadowbolt.248378/
	https://www.hiveworkshop.com/threads/cloak-of-flames-bundle.328107/
	https://www.hiveworkshop.com/threads/btninterruptcast.198253/
	*/
	
endfunction

//===========================================================================
function InitTrig_Talent_Shadow_Priest takes nothing returns nothing
    set gg_trg_Talent_Shadow_Priest = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Shadow_Priest, function TalentShadowPriest )
    call TalentHeroSetCopy('H00T', 'H00Q')	
endfunction
