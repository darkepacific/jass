function TalentHolyPaladin takes nothing returns nothing
	local integer heroTypeId = 'H00M'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50)

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpellWithBoolean('A0AR', -25, 0, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Judgement"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_judgement.blp"

	set choice = TalentChoiceCreateBoolean(1)
	set udg_TalentChoiceHead[choice] = "Increased Self Healing"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHeal.blp"  
	set udg_TalentChoiceText[choice] = "Light of Dawn now heals you for an additional 12%" 

	set choice = TalentChoiceCreateImproveSpell('A0FX', -25, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Light of Dawn"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNManaRecharge.blp"


	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateBoolean(3)
	set udg_TalentChoiceHead[choice] = "Divine Punisher"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDoomhammer.blp"   
	set udg_TalentChoiceText[choice] = "Casting judgement on the same enemy in a row increases it's damage by 25%" 

	set choice = TalentChoiceCreateSustain(0, 150, 4)
	set udg_TalentChoiceHead[choice] = "Increased Mana and Armor"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpTwo.blp"

	set choice = TalentChoiceCreateBoolean(5) 
	set udg_TalentChoiceHead[choice] = "Avenge"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSunderingBlades.blp"
	set udg_TalentChoiceText[choice] = "When one of your minions die, increase the base damage of the others by 25%"
	
	
	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)

	call TalentChoiceCreateAddSpell('A01Q', true)  //Divine Shield
	call TalentChoiceCreateAddSpell('A0AP', true)  //Avenging Crusader
	call TalentChoiceCreateAddSpell('A0DK', true)  //Lay on Hands

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateImproveSpellWithBoolean('A00U', 0, -6.0, 9)
	set udg_TalentChoiceHead[choice] = "Blessing of Freedom"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBlessingOfFreedom.blp"
	set udg_TalentChoiceText[choice] = "Retribution now also removes all negative debuffs and increases the target's move speed by 35% for 2.5 sec. It's cooldown is also reduced. |n|nCooldown: -6.0"
	
	set choice = TalentChoiceCreateSustain(450, 450, 0)
	set udg_TalentChoiceHead[choice] = "Increased Health and Mana"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Misc_Gem_Sapphire_02.blp"

	set choice = TalentChoiceCreateBoolean(11) 
	set udg_TalentChoiceHead[choice] = "Grand Crusader"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNKnight.blp"
	set udg_TalentChoiceText[choice] = "Call to Arms now summons 4 units"
	

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateImproveSpellWithBoolean('A00U', -90, 0, 12)
	set udg_TalentChoiceHead[choice] = "Blessing of Wisdom"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_Holy_SealOfWisdom.blp"
	set udg_TalentChoiceText[choice] = "Retribtuion now restores 35% of the target's max mana, and its mana cost is reduced. |n|nMana cost: -90"

	set choice = TalentChoiceCreateReplaceAndImproveSpell('A0AR', 'A0EL', -25, 0, 0)
	set udg_TalentChoiceHead[choice] = "Holy Prism"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHolyPrism.blp"
	set udg_TalentChoiceText[choice] = "Replace Judgment for Holy Prism, an ability that heals or damages 1 target then reflects to damage or heal 5 other units. |n|nBenefits from all previous talent buffs to judgement."

	set choice = TalentChoiceCreateBoolean(14) 
	set udg_TalentChoiceHead[choice] = "Beacon of light"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBeaconOfLight.blp"
	set udg_TalentChoiceText[choice] = "You are now healed for 10% of all healing you do to allies"

	//50
	//Your summoned units now gain access to retribution aura and can now cast divine shields of their own
	//Cavalier - the movement speed bonus on your summoned units Crusader's Aura is increased from 10% to 25%
	//Steeds of glory - your summoned units gain access to the divine steed ability, allowing them to charge to a target location and knocking all enemy units out of the way
	//Blinding light - conscecation/hammer/divine storm - now blind all surrounding enemies causing them to miss their next attack
		// [Blinding Light] - essentially a fear, enemies wander aimlessly for 2 seconds

	//Uther's Counsel - reduce the base cooldown of all your ultimate abilities by 20% and increase the duration of all your buffs on other players by 10%
	//Overflowing Light - overhealing an ally now provides a shield equal to 50% of the amount overhealed for 3seconds

	//Blessing of Prot - Ret reduces all incoming phys damage on the target by 20% (can only check if cast on self or use SpellUnits)
	//Blessing of Spellwarding - Ret reduces all incoming magic or other damage on the target by 20% 

	// Path of Redemption when you die, gain the option to revive after 3 seconds with 30% health and mana (2 min cooldown)

	//LEVEL 50 - AI CHOICES

	// Radiant Dawn - when you overheal an ally, 30% of the overheal is split among nearby injured allies
	// Crusader's Zeal - each Judgement cast reduces the remaining cooldown of Avenging Crusader by 1 second (up to a cap per cast)
	// Sacred Barrier - Light of Dawn grants affected allies a small damage absorb shield for 4 seconds

	// Lightbringer - every 5th single-target heal you cast is duplicated at 40% effectiveness on a nearby injured ally
	// Divine Insight - your healing critical strikes refund 20% of the spell's mana cost
	// Bulwark of Faith - when you drop below 30% health, instantly gain a strong absorb shield (internal cooldown)

	// Cleansing Light - your primary heal removes 1 negative magic effect from its target
	// Guiding Beacon - Beacon of Light now also grants 5% bonus movement speed and 5% bonus armor to its target
	// Sanctified Ground - Consecration placed under an ally increases healing they receive by 10%

	// Hand of Sacrifice - transfers a portion of damage taken by an ally to you for a short duration, but also increases healing you receive
	// Eternal Crusade - killing blows by your summoned units briefly increase your spell power
	// Shimmering Aegis - periodic healing effects on a unit reduce the duration of incoming crowd control slightly

endfunction

//===========================================================================
function InitTrig_Talent_Holy_Paladin takes nothing returns nothing
	set gg_trg_Talent_Holy_Paladin = CreateTrigger(  )
	call TriggerAddAction( gg_trg_Talent_Holy_Paladin, function TalentHolyPaladin )
	call TalentHeroSetCopy('H031', 'H00M')	
endfunction


