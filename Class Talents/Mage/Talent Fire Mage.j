function TalentFireMage takes nothing returns nothing
	local integer heroTypeId = 'H023'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//Change Fire Blast to 20/100%

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)

	set choice = TalentChoiceCreateImproveSpellWithBoolean('A00I', -15, 0, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Firebolt"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFireForTheCannon.blp"
	set udg_TalentChoiceText[choice] = "Firebolt, Mana cost: -15 |nFire Blast, Mana cost: -15"

	set choice = TalentChoiceCreateImproveSpellWithBoolean('AEbl', 0, -2.0, 1)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Blink"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBlink.blp"
	set udg_TalentChoiceText[choice] = "Blink, Cooldown: -2.0 |nLedegendary Blink, Cooldown: -2.0"

	set choice = TalentChoiceCreateBoolean(2)
	set udg_TalentChoiceHead[choice] = "Dragon's Wrath"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFire_Dragon.blp"
	set udg_TalentChoiceText[choice] = "+10 Burn Damage per sec on Dragon's Breath"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)

	// set choice = TalentChoiceCreateBoolean(3)
	// set udg_TalentChoiceHead[choice] = "Combustion"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSealoffire.blp" 
	// set udg_TalentChoiceText[choice] = "Firebolt, Fire Blast, and Blast Wave now deal 10% increased damage to targets that are already burning"

	set choice = TalentChoiceCreateBoolean(4)
	set udg_TalentChoiceHead[choice] = "Blazing Barrier"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMoltenArmor.blp" 
	set udg_TalentChoiceText[choice] = "Casting Blink now grants a shield, absorbing 8% of Total Health + 1 x Int damage for 3 sec"

	set choice = TalentChoiceCreateSustain(150, 150, 0)
	set udg_TalentChoiceHead[choice] = "Increased Health and Mana by 150"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Misc_Gem_Sapphire_02.blp"
	
	// set choice = TalentChoiceCreateStats(0, 0, 10)
	// set udg_TalentChoiceHead[choice] = "Improved: Int"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMantleOfIntelligence.blp"
	set choice = TalentChoiceCreateBoolean(5)
	set udg_TalentChoiceHead[choice] = "Alexstrasza's Fury"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAlexstrasza Dragon.blp" 
	set udg_TalentChoiceText[choice] = "Increases the burn duration on Dragon's Breath by 1 sec"
	
	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpell('A05E',true)
	call TalentChoiceCreateAddSpell('A0DJ',true) //Living bomb
	call TalentChoiceCreateAddSpell('A08G',true) //Ice Block

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateMovement(50)
	set udg_TalentChoiceHead[choice] = "Increased Movement Speed"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_fire_burningspeed.blp"

	//Needs to be a custom ability due to blink changes not taking effect until after ability is cast
	set choice = TalentChoiceCreateReplaceAndImproveSpell('AEbl','A0DB', 0, -2.0, 1)
	set udg_TalentChoiceHead[choice] = "Legendary Blink"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNLegendary_Blink_55.blp"
	set udg_TalentChoiceText[choice] = "Increases Blink distance by 300 (+65%)"

	set choice = TalentChoiceCreateStats(0, 0, 20)
	set udg_TalentChoiceHead[choice] = "Overwhelming: Int"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMagicalSentry.blp"

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	
	set choice = TalentChoiceCreateReplaceAndImproveSpell('A00I','A0DE', -15, 0, 0)
	set udg_TalentChoiceHead[choice] = "Fire Blast"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_Fire_Blast.blp"
	set udg_TalentChoiceText[choice] = "Replaces Fireball for Fire Blast, an instant damage spell with a chance to crit" //(Combustion crits if currently burning)
	
	set choice = TalentChoiceCreateReplaceSpell('A01V','A0DC')
	set udg_TalentChoiceHead[choice] = "Blast Wave"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBlast_Wave.blp"
	set udg_TalentChoiceText[choice] = "Replaces Frost Nova for Blast Wave, a high damage AoE Knockback"

	set choice = TalentChoiceCreateImproveSpellWithBoolean('AHfs', -50, -2.0, 14)
	set udg_TalentChoiceHead[choice] = "Improved Flame Strike"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNWallOfFire.blp"
	set udg_TalentChoiceText[choice] = "Reduces the mana cost by 50, cooldown by 2.0s, and casting time by half"

	//LEVEL 50

	// Sozen's Commet - All spells now automatically apply the Firelord's Debuff, that would otherwise only be applied via items.
	// Secondary Specialization - Blink gains a second charge and now casts an arcane explosion.
	// Pheonix - Gain the ability to summon a Pheonix.

	//[ Hot Hands] - Gain 20% Base Cooldown Reduction, stacks with items but still cannot exceed 30% cooldown reduction
	// Flamestrike - Gains a second charge
	// [Pheonix Flames] - Replaces Dragon's Breath with Pheonix Flames, a pheonix charges forth burning
	
	//Replaces Dragon's Breath with Pheonix Flames, a pheonix charges forth burning all enemies in it's wake and continues to attack them afterwards
	//[Ring of Fire] - summons a ring of fire for 6 s enemies who enter the ring of fire burn for 3% hp





endfunction

//===========================================================================
function InitTrig_Talent_Fire_Mage takes nothing returns nothing
    set gg_trg_Talent_Fire_Mage = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Fire_Mage, function TalentFireMage )
    call TalentHeroSetCopy('H009', 'H023')	
endfunction


