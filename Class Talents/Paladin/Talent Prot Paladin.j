function TalentProtPaladin takes nothing returns nothing
	local integer heroTypeId = 'H032'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 


	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateBoolean(0)
	set udg_TalentChoiceHead[choice] = "Increased Self Healing"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHolyBolt.blp"  
	set udg_TalentChoiceText[choice] = "Holy light now heals you for 14% of your missing health" 

	set choice = TalentChoiceCreateImproveSpell('AHhb', -25, - 1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Costs on Holy Light"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNManaRecharge.blp"

	set choice = TalentChoiceCreateBoolean(2) 
	set udg_TalentChoiceHead[choice] = "Increase damage Holy Light"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNImmolationOff.blp"
	set udg_TalentChoiceText[choice] = "Holy Light now deals 85% damage to undead"


	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)

	set choice = TalentChoiceCreateImproveSpellWithBoolean('A04R', 0, 1.0, 4)
	set udg_TalentChoiceHead[choice] = "Fist of Justice"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNGauntletsOfOgrePower.blp"
	set udg_TalentChoiceText[choice] = "Blessed shield now stuns it's primary target for 1.25s, but it's cooldown is increased by 1 second"

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
	set udg_TalentChoiceText[choice] = "Retribution now restores 35% of the target's max mana, and its mana cost is reduced. |n|nMana cost: -90"

	set choice = TalentChoiceCreateBoolean(13) 
	set udg_TalentChoiceHead[choice] = "Sacred Shield"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSacredShield.blp"
	set udg_TalentChoiceText[choice] = "Retribution and Holy Light now grant the target a shield for 4 sec that absorbs 100 + 1x Str + 1x Int damage"

	set choice = TalentChoiceCreateBoolean(14) 
	set udg_TalentChoiceHead[choice] = "Ardent Defender"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNArdent Defender.blp"
	set udg_TalentChoiceText[choice] = "When below 35% health, all damage taken is reduced by 35%."



	// 60
	// Guardian of Ancient Kings - when you take damage tha would otherwise be fatal, you are instead healed for 30% of your max health and take 50% reduced damage for 5s (60s cd)
	//Steeds of glory - your knights now gain access to the divine steed ability, allowing them to charge to a target location, knocking all enemy units out of the way
			// and the movement speed bonus on your summoned units Crusader's Aura is increased from 10% to 25%, and can also cast divine shield
	//Blessing of Kings - gain 20 Str, Agility and Int

	//Shield of the Righteous - casting blessed shield now increases your armor by a 12 for 3sec
	//Divine Toll - Blessed shield now is automatically cast on two additional targets
	//Blessing of Spellwarding - Ret reduces all incoming magic damage on the target by 20%

	//Light's Grace - holy light reduces all damage the target recieves by 5% for 5sec
	//Blessing of Prot - Ret reduces all incoming phys damage on the target by 20%

	//50
	//Your summoned units now gain access to retribution aura and can now cast divine shields of their own
	//Cavalier - the movement speed bonus on your summoned units Crusader's Aura is increased from 10% to 25%

	//Uther's Counsel - reduce the base cooldown of all your ultimate abilities by 20% and increase the duration of all your non-ultimate buffs by 10%

	//Blessed Shield - blessed shield now gains an additional charge and taunts enemies into attacking you
	// Consecration summons a blessed hammer that orbits and deals damage to enemies it collides with
	
	//Blessing of Kings - HL now increases an ally units damage by +50 for 3s after being cast on it
	//First Avenger - Blessed shield now bounces 2 additional times and grants you a shield for 3s equal to 20% of the damage done
	//Shield of virtue - blessed shield now interrupts all enemies it hits (store in a unit group then loop threw after wards (defer() ?))
	//Consecrated Ground - consecration initial burst now slows all enemy's movementspeed by 50%

endfunction

//===========================================================================
function InitTrig_Talent_Prot_Paladin takes nothing returns nothing
	set gg_trg_Talent_Prot_Paladin = CreateTrigger(  )
	call TriggerAddAction( gg_trg_Talent_Prot_Paladin, function TalentProtPaladin )
	call TalentHeroSetCopy('H033', 'H032')	
endfunction


