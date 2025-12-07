function TalentFrostMage takes nothing returns nothing
	local integer heroTypeId = 'H00A'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 	//Mark Level 10 as last choice, after the heroe picks it, the selection skills are removed.


	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)

	set choice = TalentChoiceCreateBoolean(0)
	set udg_TalentChoiceHead[choice] = "Frostbolt Stuns for Longer"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFrostBolt.blp"  
	set udg_TalentChoiceText[choice] = "Frostbolt now stuns for 1 second" 

	set choice = TalentChoiceCreateImproveSpell('A08I', -15, -1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Costs on Frostbolt"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNManaRecharge.blp"

	set choice = TalentChoiceCreateBoolean(1) 
	set udg_TalentChoiceHead[choice] = "Frostbolt Crits for More"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDarkRitual.blp"
	set udg_TalentChoiceText[choice] = "Frostbolt now Crits for 3 x Intelligence"


	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)

	set choice = TalentChoiceCreateBoolean(3) 
	set udg_TalentChoiceHead[choice] = "Perma-Frost"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBreathOfFrost.blp"
	set udg_TalentChoiceText[choice] = "Cone of Cold slow now lasts for 4 seconds "
	
	set choice = TalentChoiceCreateSustain(150, 150, 0)
	set udg_TalentChoiceHead[choice] = "Increase Health and Mana"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Misc_Gem_Sapphire_02.blp"
	 
	set choice = TalentChoiceCreateStats(0, 0, 10)
	set udg_TalentChoiceHead[choice] = "Improved: Int"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMantleOfIntelligence.blp"
	

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)

	call TalentChoiceCreateAddSpell('A024',true)  //Water Elemental
	call TalentChoiceCreateAddSpell('A08G',true)  //Ice Block
	call TalentChoiceCreateAddSpell('A0D9',true)  //Frozen Orb

	
	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	
	set choice = TalentChoiceCreateMovement(50)
	set udg_TalentChoiceHead[choice] = "Increased Movement Speed"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBoots.blp"

	set choice = TalentChoiceCreateBoolean(10) 
	set udg_TalentChoiceHead[choice] = "Freezing Rain"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBlizzard.blp"
	set udg_TalentChoiceText[choice] = "Blizzard does 20% extra damage to slowed units"
	
	set choice = TalentChoiceCreateStats(0, 0, 20)
	set udg_TalentChoiceHead[choice] = "Overwhelming: Int"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMagicalSentry.blp"


	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)

	set choice = TalentChoiceCreateReplaceSpell('A00H','A00R')
	set udg_TalentChoiceHead[choice] = "Arcane Brilliance"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBrilliance.blp"
	set udg_TalentChoiceText[choice] = "Replaces Arcane Intellect for a very strong Brilliance Aura"

	set choice = TalentChoiceCreateReplaceSpell('A00H','ANbl')
	set udg_TalentChoiceHead[choice] = "Blink"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBlink.blp"
	set udg_TalentChoiceText[choice] = "Replaces Arcane Intellect with Blink"

	set choice = TalentChoiceCreateReplaceSpell('A00H','A04I')
	set udg_TalentChoiceHead[choice] = "Counterspell"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFeedback.blp"
	set udg_TalentChoiceText[choice] = "Replaces Arcane Intellect with Counterspell"



	//LEVEL 50

	//Perma Frost - Frost nova now slows all enemies attackspeed and deals 20% more damage 


	//Ice Barrier - after casting water elemental, ice block, or frozen orb you gain armor for 4s equal to 20% total int
	//Ice Form - https://wowpedia.fandom.com/wiki/Ice_Form, body turns to ice, gaining magic immunity for 10 sec
	//Ice Flow - blizzard now channels by itself
	//Freezing Winds - After casting frozen orb reset the cooldown of cone of cold
	//Winter's Blessing - Gain 20% Base Cooldown Reduction, stacks with items but still cannot exceed 30% cooldown reduction
	//Ice Wall - Create a wall of ice that blocks movement for 4 sec (Probably better as a DK ability)


	//Icy veins - decrease the cooldowns and mana cost of Blizzard, Cone of Cold, and Frostbolt by 2.0s and 40 mana
	//Perma Frost - Frost Nove also slows enemies attack and movement speed 20% for 3s ontop of rooting them (Just use current Frost Nova Spell)

	
	//Frigid Winds - Blizzard now slows enemies by 20%
	
	//Ring of Frost - Summons a Ring of Frost for 10 sec at the target location. Enemies entering the ring are incapacitated for 10 sec. Limit 10 targets. When the incapacitate expires, enemies are slowed by 65% for 4 sec.
	

	// set choice = TalentChoiceCreateReplaceSpell('A00H','A00R')
	// set udg_TalentChoiceHead[choice] = "Ring of Frost"
	// set udg_TalentChoiceText[choice] = "Replaces Frost Nova for Ring of Frost"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBrilliance.blp"




endfunction

//===========================================================================
function InitTrig_Talent_Frost_Mage takes nothing returns nothing
    set gg_trg_Talent_Frost_Mage = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Frost_Mage, function TalentFrostMage )
    call TalentHeroSetCopy('U001', 'H00A')	
endfunction


