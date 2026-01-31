function TalentRetPaladin takes nothing returns nothing
	local integer heroTypeId = 'H00K'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpellWithBoolean('A0AR', -25, 0, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Judgement"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_judgement.blp"

	set choice = TalentChoiceCreateBoolean(1)
	set udg_TalentChoiceHead[choice] = "Increased Healing on Divine Storm"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_Holy_RetributionAura.blp"  
	set udg_TalentChoiceText[choice] = "Divine storm now heals 1% missing health each time it hits an enemy. |nMax healing 9% health." 

	set choice = TalentChoiceCreateImproveWeapon(0, 10, -0.2)
	set udg_TalentChoiceHead[choice] = "Increased Attack Damage and Speed"
	set udg_TalentChoiceText[choice] = "Attack Damage: +10  Attack Speed: +10%"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Hammer_10.blp"


	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateBoolean(3)
	set udg_TalentChoiceHead[choice] = "Divine Punisher"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDoomhammer.blp"  
	set udg_TalentChoiceText[choice] = "Casting judgement on the same enemy in a row increases it's damage by 25%" 

	set choice = TalentChoiceCreateSustain(150, 0, 4)
	set udg_TalentChoiceHead[choice] = "Increased Health and Armor"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpThree.blp"

	set choice = TalentChoiceCreateImproveSpellWithBoolean('A0DA', 0, 1.0, 4)
	set udg_TalentChoiceHead[choice] = "Fist of Justice"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNGauntletsOfOgrePower.blp"
	set udg_TalentChoiceText[choice] = "Blade of Justice now stuns targets for 1 sec, but it's cooldown is increased by 1 sec"

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)

	call TalentChoiceCreateAddSpell('A01Q', true)  //Divine Shield
	call TalentChoiceCreateAddSpell('A0AP', true)  //Avenging Crusader
	call TalentChoiceCreateAddSpell('A0EN', true)  //Wake of Ashes

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateImproveSpellWithBoolean('A00U', 0, -6.0, 9)
	set udg_TalentChoiceHead[choice] = "Blessing of Freedom"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBlessingOfFreedom.blp"
	set udg_TalentChoiceText[choice] = "Retribution now also removes all negative debuffs and increases the target's move speed by 35% for 2.5 sec. It's cooldown is also reduced. |n|nCooldown: -6.0"

	set choice = TalentChoiceCreateSustain(450, 450, 0)
	set udg_TalentChoiceHead[choice] = "Increased Health and Mana"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Misc_Gem_Sapphire_02.blp"

	set choice = TalentChoiceCreateStats(15, 15, 0)
	set udg_TalentChoiceHead[choice] = "Holy Seal of Might"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_Holy_SealOfWrath.blp"

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateImproveSpellWithBoolean('A00U', -90, 0, 12)
	set udg_TalentChoiceHead[choice] = "Blessing of Wisdom"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_Holy_SealOfWisdom.blp"
	set udg_TalentChoiceText[choice] = "Retribtuion now restores 35% of the target's max mana, and its mana cost is reduced. |n|nMana cost: -90"

	set choice = TalentChoiceCreateReplaceAndImproveSpell('A0AR', 'A0DN', -25, 0, 0)
	set udg_TalentChoiceHead[choice] = "Hammer of Wrath"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_paladin_hammerofwrath.blp"
	set udg_TalentChoiceText[choice] = "Replace Judgment for Hammer of Wrath; hurls a divine hammer that does 200 + 3x Str damage, increased by 1% per missing health the enemy has. |n|nBenefits from all previous talent buffs to judgement."

	set choice = TalentChoiceCreateAddAndHideSpell('A09D','A09D', false)
	set udg_TalentChoiceHead[choice] = "Seraphim"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSeraphim.blp"
	set udg_TalentChoiceText[choice] = "Gain 30% Crit Chance. |nStacks multaplicatively with items."
	

	//Scepeter of Avarice is a good icon for Paladin
	//ReplaceableTextures\CommandButtons\BTNTransmute.blp

	

	//50
	//Blessing of Spell Warding - Ret reduces all incoming non-physical damage on the target by 25%
		//Blessing of Prot - Ret reduces all incoming phys damage on the target by 20% 9Not needed, already gives armor)

	//[Divine Hammer] -- Divine Hammers spin around you dealing damage to enemies they hit
		// Divine storm summons a blessed hammer that orbits and deals damage to enemies it collides with
	
	//Final Verdict - 
	// Light's Wrath - after casting Divine storm, your next attack deals 100% bonus damage and heals you for 10% of the damage dealt
	//Blinding light - Divine storm - now blinds all surrounding enemies causing them to miss attacks for 1s



endfunction

//===========================================================================
function InitTrig_Talent_Ret_Paladin takes nothing returns nothing
	set gg_trg_Talent_Ret_Paladin = CreateTrigger(  )
	call TriggerAddAction( gg_trg_Talent_Ret_Paladin, function TalentRetPaladin )
	call TalentHeroSetCopy('H00R', 'H00K')	
endfunction


