function TalentHolyPriest takes nothing returns nothing
	local integer heroTypeId = 'H02U'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 	

	//Create sparkly for glass bubbler
	//Rework Fear currently considered a positive buff (IF)
	//Ress bug might be coming from units who res during the cast or very close to the end of it

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	//Increase dmg smite
	set choice = TalentChoiceCreateImproveSpellWithBoolean('A02T', -10, -1.0, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Costs Smite"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_Smite.blp"

	set choice = TalentChoiceCreateImproveSpellWithBoolean('A08W', 0, -1.25, 1)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Holy Nova"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHolyNova.blp"
	
	set choice = TalentChoiceCreateSustain(0, 250, 0)
	set udg_TalentChoiceHead[choice] = "Gain Bonus Mana"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Misc_Gem_Sapphire_02.blp"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateSustain(300, 0, 0)
	set udg_TalentChoiceHead[choice] = "Power Word: Fortitude"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPowerWordFortitude.blp"

	set choice = TalentChoiceCreateBoolean(13)
	set udg_TalentChoiceHead[choice] = "Renew"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNRenew.blp"
	set udg_TalentChoiceText[choice] = "Heal now restores an additional 25% health over 6 sec. Stacks with other healing bonuses."

	set choice = TalentChoiceCreateBoolean(5)
	set udg_TalentChoiceHead[choice] = "Symbol Of Hope"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSymbolOfHope.blp"
	set udg_TalentChoiceText[choice] = "Casting Heal on the same ally twice in a row now restores 8% of their maximum mana."	

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpell('A08Z', true) //Psychic Scream  
	call TalentChoiceCreateAddSpellWithBoolean('A0FW', true, 7) //Resurrect 
	call TalentChoiceCreateAddSpell('A0FZ', true) // [Holy word salvation]


	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateReplaceAndImproveSpell('A02T', 'A0FR', -10, -1.0, 0)
	set udg_TalentChoiceHead[choice] = "Leap of Faith"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNLeapofFaith.blp"
	set udg_TalentChoiceText[choice] = "Replace Smite with Leap of Faith, an ability that pulls an ally unit to the priest. Benefits from all previous talent buffs to Smite."

	set choice = TalentChoiceCreateBoolean(10)
	set udg_TalentChoiceHead[choice] = "Desperate Prayer"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDesperatePrayer.blp"
	set udg_TalentChoiceText[choice] = "When lowered below 25% health, instantly heal for 25% of max health and increases your max HP by the same amount for 6s, this effect has a 45s cooldown"

	set choice = TalentChoiceCreateBoolean(11)
	set udg_TalentChoiceHead[choice] = "Innerfire"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNInnerFire.blp"
	set udg_TalentChoiceText[choice] = "Power Word: Shield now also applies inner fire increasing the target's armor by 25 and attack damage by 20%"

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateBoolean(12)
	set udg_TalentChoiceHead[choice] = "Chastise"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNChastiseAnduin.blp"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBlessedCircle.blp"
	set udg_TalentChoiceText[choice] = "Divine Star now roots enemies it passes through for 1.2 sec."

	set choice = TalentChoiceCreateImproveSpellWithBoolean('A00K', 35, 0, 4)
	set udg_TalentChoiceHead[choice] = "Greater Heal"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHeal.blp"
	set udg_TalentChoiceText[choice] = "Heal now heals for 35% more, but increases its mana cost by 35. Stacks with other healing bonuses."

	set choice = TalentChoiceCreateRegen(15.0, 15.0, 0, 0)
	set udg_TalentChoiceHead[choice] = "Divine Spirit"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDivineSpirit.blp"	

	//LEVEL 50
	//Want to Add
		//Halo
		//Light Bomb
		//Guardian Spirit
		//Spirit of Redemption

	//[Guardian Spirit] - Calls upon a guardian spirit to watch over the friendly target for 10 sec, increasing healing received by 60%. If the target would die, the Spirit sacrifices itself and restores the target to 40% health. (Castable while stunned cannot save the target from massive damage)
	// Halo/Light Bomb
	// Light well - Heal leaves behind a light well at the target that continues to heal nearby allies for 3% of there max hp for 6sec
		//Instead of a ward have it be a non-targetable dummy that casts a heal every 1.5s for 15s
	// Spirit of Redemption - while dead you become the Spirit of Redemption, allowing you to continue to cast heal and holy nova, and leap of faith for 6 seconds
		//Works by first asking if you want to revive, if not or revive is on cd then you become the spirit of redemption

	//Halo (replace DS) - create a circle of light that reaches out and heals all allies, then at it's apex returns damaging enemies on the way, does up to 50% more healing/damage the farther targets are away from the priest
			//Can benefit from roo
	//Flash Heal - instantly reset the cooldown on heal for targets with less than 30% health
	// [Light Bomb] - Designate an allied hero with the light, after 1.5s the light explodes healing them for Y and dealing X damage to and stunning all nearby enemies for Zs

	//Power Word Shield's movement bonus is now increase to 40% and last for 4s
    //Renew - Heal now heals for an additional 20% it's total over 4 sec
	//Desperate Prayer - Heal now has only a 0.5s cd but it's mana cost inc by 25 each time it is cast, this goes away 4 sec after not casting it
				//Hero unit, but with XP disabled, give it Heal, HN

	// [Circle of Healing] - Replace Holy Nova for an ability that does the full healing over 3 sec (1/3) ea sec

	// set choice = TalentChoiceCreateBoolean(x)
	// set udg_TalentChoiceHead[choice] = "Heaven's Arsenal"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHealCannon.blp"
	// set udg_TalentChoiceText[choice] = "Smite now hits 2 additional nearby enemies but deals 50% less damage."
	// - 

	

endfunction

//===========================================================================
function InitTrig_Talent_Holy_Priest takes nothing returns nothing
    set gg_trg_Talent_Holy_Priest = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Holy_Priest, function TalentHolyPriest )
    call TalentHeroSetCopy('H02W', 'H02U')	
endfunction
