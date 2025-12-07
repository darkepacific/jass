function TalentAfflictionWarlock takes nothing returns nothing
	local integer heroTypeId = 'E000'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//Abilities
		//Haunt
		//Drain Life - sould drain but 20% stronger
		//Corruption - if the target dies while under corruption it spreads to an enemy in 160 range
		//Felhound - 
		//Fear - 


	//Eye of Sargeras - https://www.hiveworkshop.com/threads/evil-eye.287867/
	//Eye of Sargeras soul burn/corruption now reduces enemie's armor and gives you vision of them
	//Replaces Fel Hound - https://www.hiveworkshop.com/threads/inquisitor.292820/
				//OR 	- https://www.hiveworkshop.com/threads/jailer.290533/
	//Corruption Projectile - https://www.hiveworkshop.com/threads/darknessbomb.243119/
	

	//Malganis - https://www.hiveworkshop.com/threads/malganis-the-eternal-one.309950/
	//Morag Brute - https://www.hiveworkshop.com/threads/moarg-brute.293388/
	//Improved Sargeras Model  - https://www.hiveworkshop.com/threads/sargeras-the-great-one.307294/
	//Archimonde - https://www.hiveworkshop.com/threads/lord-archimonde.293033/
	// Useful for something - https://www.hiveworkshop.com/threads/gatekeepers-pact.321922/
	//Archon - https://www.hiveworkshop.com/threads/hero_archon.268185/
	// & Fel Archon - https://www.hiveworkshop.com/threads/hero_felarchon.268135/

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpell('ANso', -30, 0)  //Would also need to improve mortal coil
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Soul Burn"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSoulBurn.blp"

	set choice = TalentChoiceCreateImproveSpell('A00D', 0, -1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Soul Drain"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_Shadow_Haunting.blp"

	set choice = TalentChoiceCreateSustain(150, 150, 0)
	set udg_TalentChoiceHead[choice] = "Increased Health and Mana by 150"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Misc_Gem_Sapphire_02.blp"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)

	set choice = TalentChoiceCreateStats(0, 0, 8)
	set udg_TalentChoiceHead[choice] = "Improved: Int"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMantleOfIntelligence.blp"
	
	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)

	call TalentChoiceCreateAddSpell('A02F',true) //Doom
	// call TalentChoiceCreateAddSpell('A02F',true) //Demonic Gateway
	// Life Tap
	// call TalentChoiceCreateAddSpell('A02F',true) //Shadowbolt Volley
		
	// Demonic Seed
		//Embeds a demon seed in the enemy target that will explode after 18 sec, dealing (215% of spell power) Shadow damage to all enemies within 10 yards and applying Corruption to them.
		//The seed will detonate early if the target is hit by other detonations, or takes (300% of spell power) damage from your spells.
	//Doom
	//A ghostly soul haunts the target, dealing (55% of Spell power) Shadow damage and increasing your damage dealt to the target by 10% for 15 sec.
		// If the target dies, Haunt's cooldown is reset.
	// Demonic Circle - fast and messy
	//Shadowbolt Volley


	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)


	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)

	//Bool
	//Your FelHound spell now summons two of them

	set choice = TalentChoiceCreateStats(0, 0, 20)
	set udg_TalentChoiceHead[choice] = "Overwhelming: Int"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMagicalSentry.blp"
	

	//LEVEL 50

	// Summon Jailer or Inquisitioner, replaces felhound
	// Sacrifice for shield
	// Gain sacrifice for instant heal

	//Corruption
	// Corruption now restores 8% missing mana everytime it spreads

	// Soulburn
	// Curse of Exhaustion - Soul Burn now reduces the enemy's momvement speed by 35%  	(Also causes Mortal Coil to slow)
	// Curse of Tongues - the Silence on Soul Burn is now increased by 2s/1s on units/heroes. (Also increases the fear on Mortal coil)
	// Mortail coil - horrifies a target into fleeing for 3sec (2.5sec Heroes) and regenerates 20% of your Max HP (Replaces Fear)	


	//Drain life
	// Increased healing on drain life
	// Drainlife now slows enemies for 40% while it is channelining on them
	// Increases Drainlife cast and channel range by 150
	// If any enemy dies while it is being souldrain instantly reset it's cooldown


endfunction

//===========================================================================
function InitTrig_Talent_Affliction_Warlock takes nothing returns nothing
    set gg_trg_Talent_Affliction_Warlock = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Affliction_Warlock, function TalentAfflictionWarlock )
    call TalentHeroSetCopy('E02V', 'E000')	
endfunction


