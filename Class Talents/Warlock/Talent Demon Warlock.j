function TalentDemonWarlock takes nothing returns nothing
	local integer heroTypeId = 'E000'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//Cures - https://www.hiveworkshop.com/threads/hell-cursed.322446/
	//Create soulstone/soul shard https://www.hiveworkshop.com/threads/soul-discharge.315414/
	//Implosion - https://www.hiveworkshop.com/threads/nether-blast.318806/
	//Felstalker - https://www.hiveworkshop.com/threads/nightprowler.292759/
	//Fellord - https://www.hiveworkshop.com/threads/fellord.290855/  blue
	//Mortalcoil - https://www.hiveworkshop.com/threads/the-cursed-skull.291175/



	//Fix 

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpell('ANso', -30, 0)  //Would also need to improve mortal coil
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Soul Burn"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSoulBurn.blp"

	set choice = TalentChoiceCreateImproveSpell('A00D', -25, -1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Costs on Drain Soul"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_Shadow_Haunting.blp"

	set choice = TalentChoiceCreateBoolean(2)
	set udg_TalentChoiceHead[choice] = "Increased Healing on Drain Soul"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNLifeDrain.blp"
	set udg_TalentChoiceText[choice] = "Drain Soul now heals for 20% more. Stacks with other bonuses."


	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)

	set choice = TalentChoiceCreateBoolean(3)
	set udg_TalentChoiceHead[choice] = "Curse of Exhaustion"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNGrimWard.blp"
	set udg_TalentChoiceText[choice] = "Drain Soul now slows enemy's movement speed by 40% while it's channeling on them"

	set choice = TalentChoiceCreateSustain(200, 100, 0)
	set udg_TalentChoiceHead[choice] = "Increased Health and Mana"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFaerieFire.blp"
	
	set choice = TalentChoiceCreateBoolean(5)
	set udg_TalentChoiceHead[choice] = "Reaper of Souls"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Misc_Amethyst.blp"
	set udg_TalentChoiceText[choice] = "If any enemy dies while being soul drained instantly reset its cooldown"


	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpell('A02F',true) //Doom
	call TalentChoiceCreateAddSpell('A0EH',true) // Demonic Tyrant
	call TalentChoiceCreateAddSpell('A0EB',true) // Demonic Gateway
	//Create a boolean for each hero (isMoving)
		//if isMoving then Ignore gate logic
	
	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	//Give Soulstone a 13s CD, have 50 mana cost, and make this eliminate the manacost, will prevent talent shifting
	set choice = TalentChoiceCreateBoolean(10)
	set udg_TalentChoiceHead[choice] = "Demonic Soul Bind"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNUsedSoulGem.blp"
	set udg_TalentChoiceText[choice] = "Soulstones now only requires 6 Soul Shards to create"

	set choice = TalentChoiceCreateBoolean(14)
	set udg_TalentChoiceHead[choice] = "Lord of the Imps"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBerserkForTrolls.blp"
	set udg_TalentChoiceText[choice] = "Gain 1 extra Imp on Evil Imps cast"

	set choice = TalentChoiceCreateImproveStatWithBoolean( 0, 400, 0, 6.0, 0.0, 11)
	set udg_TalentChoiceHead[choice] = "Demon Armor"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDemonArmor.blp"


	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	//Bool
	set choice = TalentChoiceCreateReplaceSpell('A01E','A0EF')
	set udg_TalentChoiceHead[choice] = "Summon Felguard"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNWarlockFelGuard.blp"
	set udg_TalentChoiceText[choice] = "Replaces your Void Walker with a powerful Felguard"

	set choice = TalentChoiceCreateRegen(15.0, 15.0, 0, 0)
	set udg_TalentChoiceHead[choice] = "Demonic Regeneration"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDemonForgedAtlas.blp"	

	//Boolean with Kill
	set choice = TalentChoiceCreateImproveStatWithBoolean( 5, 'E000', 'E02V', udg_z_WL_DEMO_H, udg_z_WL_DEMO_A, 13)
	set udg_TalentChoiceHead[choice] = "Sacrifice Voidwalker"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSacrificeShield.blp"
	set udg_TalentChoiceText[choice] = "Allows you to sacrifice your Voidwalker for a 1200 hp shield for 4 sec"



	//Implosion - replaces Evil Imps while on cooldown, gain an active ability that pulls all nearby imps to a location 
		//and explodes them dealing massive damage to all nearby enemies. (Replaces Evil Imps) 
		//(boolean, replaces Imps when active similar to HW) causes all current Imps to violently explode dealing X damage around them
	//Soul Link - while you and your Demon are alive you both take 20% less damage
	//Create Healthstone - 7th ability, allows you to consume a soulshard to create a healthstone that heals for X health, healtstones are consumable and tradeable to other players
		// Killing a unit with Soulburn now also generates a Soulshard, +10 Int

	
	// Curse of Tongues - the duration of Soul Burn is now increased by 2/1s on units and heroes. (Also increases the fear on Mortal coil)


	//Replace with Bool
	// Increase Range on Souldrain - Increases Souldrain's cast and channel range by 150 (ReplaceSpellWithBoolean)
	
	//Replace
	// Create Healthstone - (Replaces soulstone) Creates a healthstone that heals (same as max) soulstone, but requires half as many soulstones, may only carry one at a time.

	// Fel Domination - whenever your voidwalker dies instantly reset it's remaining cooldown

	//Replace
	// Mortail coil - horrifies a target into fleeing for 3sec (2.5sec Heroes) and regenerates 20% of your Max HP (Replaces Soul Burn)	

	// Demonic Circle
	// Subjugate Demon
	// Hand of Guldan, Calls down a demonic meteor stunning and dealing damage on impact. 
			//The meteor is full of Evil Imps which burst forth to attack nearby targets.



	//LEVEL 50

		// Fel Domination - whenever your voidwalker dies instantly reset it's remaining cooldown
			// Summon Pitlord

	// Imps
		// Hand of Guldan, Calls down a demonic meteor stunning and dealing damage on impact. The meteor is full of Evil Imps which burst forth to attack nearby targets.
		// Killing a unit with soul drain now has a 25% chance to reset the cooldown on Evil Imps
		// Inner Demons - you passively summon an Imp to fight for you every 30s
			// Call Dreadstalkers - replaces Evil Imps


	// Soulburn
			// Curse of Exhaustion - Soul Burn now reduces the enemy's momvement speed by 35%  	(Also causes Mortal Coil to slow)
		// Curse of Tongues - the Silence on Soul Burn is now increased by 2s/1s on units/heroes. (Also increases the fear on Mortal coil)
		// Mortail coil - horrifies a target into fleeing for 3sec (2.5sec Heroes) and regenerates 20% of your Max HP (Replaces Soul Burn)	


	//Soulstone & Souldran
		// Increased healing on soul drain
		// Create Healthstone - creates a healthstone that heals that same amount of health as a soulstone, but requires half as many soulstones, may only carry one at a time.
		// Curse of Exhaustion -  Souldrain now slows enemies for 50% while it is channelining on them
		// Increases Souldrain's cast and channel range by 150
		// If any enemy dies while it is being souldrain instantly reset it's cooldown

			// Mana Drain - Soul drain also drains mana 
			// Create Soulwell - replaces Soulstone - creates a well that when clicked on generates a Healthstone for an ally in their bonus bag space, healthstones cannot be destroyed or traded



endfunction

//===========================================================================
function InitTrig_Talent_Demon_Warlock takes nothing returns nothing
    set gg_trg_Talent_Demon_Warlock = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Demon_Warlock, function TalentDemonWarlock )
    call TalentHeroSetCopy('E02V', 'E000')	
endfunction


