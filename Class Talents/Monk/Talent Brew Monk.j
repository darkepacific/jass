function TalentBrewMonk takes nothing returns nothing
	local integer heroTypeId = 'N041'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 	
	
	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpell('AOw2', -30, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Leg Sweep"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_monk_legsweep.blp"

	set choice = TalentChoiceCreateSustain(150, 150, 0)
	set udg_TalentChoiceHead[choice] = "Increased Health and Mana"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNInnerPeace.blp"

	set choice = TalentChoiceCreateImproveSpell('ANbf', 0, -1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Breath of Fire"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBreathOfFire.blp"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateImproveSpell('A09F', -40, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Meditate"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMonk_ability_transcendence.blp"

	set choice = TalentChoiceCreateBoolean(4)
	set udg_TalentChoiceHead[choice] = "Peppers!"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHotPepper.blp"
	set udg_TalentChoiceText[choice] = "Breath of Fire's Burn damage is increased to 3x Bonus Intelligence."

	set choice = TalentChoiceCreateBoolean(5)
	set udg_TalentChoiceHead[choice] = "Provoke"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMonkProvoke.blp"
	set udg_TalentChoiceText[choice] = "Meditate now causes all enemies within 500 distance to switch to attacking you."
									// Make 600 distance, this effect triggers every second while meditating

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddAndDisableSpell('A09H', 'N041', 0, 0 , 6 , true) //Niuzao Black Ox
	call TalentChoiceCreateAddAndDisableSpell('A0E7', 'N041', 0, 0 , 7 , true) //Gift of the Ox
	call TalentChoiceCreateAddAndDisableSpell('A0E6', 'N041', 0, 0 , 8 , true) //Mighty Ox Kick

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	// set choice = TalentChoiceCreateBoolean(9)
	set choice = TalentChoiceCreateStatsWithBoolean(10, 0, 0, 9, "Roundhouse Kick now scales off Total Strength, 3 x (Base + Bonus)")
	set udg_TalentChoiceHead[choice] = "Roundhouse Kick"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNRising Sun Kick.blp"
	// set udg_TalentChoiceText[choice] = "Leg Sweep scaling damage increased to 7x Bonus Str"

	set choice = TalentChoiceCreateImproveStatWithBoolean(1, 0, 0, 50.0, 0.0, 10)
	set udg_TalentChoiceHead[choice] = "Increased Movement Speed"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_fire_burningspeed.blp"

	set choice = TalentChoiceCreateBoolean(11)
	set udg_TalentChoiceHead[choice] = "Magically Suspicious"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFrostBarrel.blp"
	set udg_TalentChoiceText[choice] = "Gain Magic Immunity when in Barrel Roll"

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateBoolean(12)
	set udg_TalentChoiceHead[choice] = "Breath In Breath Out"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNZen_Meditation.blp"
	set udg_TalentChoiceText[choice] = "If Meditate is cancelled in the first 3 seconds its remaining cooldown is reduced by 60%, and restores 350 mana."

	//set choice = TalentChoiceCreateAddSpell('ANdb', false)
	set choice = TalentChoiceCreateAddAndHideSpell('ANdb','ANdb', false)
	set udg_TalentChoiceHead[choice] = "Druken Brawler"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDrunkenDodge.blp"
	set udg_TalentChoiceText[choice] = "Gain 20% crit and 20% dodge chance."

	set choice = TalentChoiceCreateAddAndHideSpell('A0E5','A0E5', false)
	set udg_TalentChoiceHead[choice] = "Celestial Fortitude"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNCelestialDragon.blp"
	set udg_TalentChoiceText[choice] = "Gain 20% life steal on attack. Stacks with items."
		


	//LEVEL 50
	//Gift of the Eternal Vale - 20 Str 20 Agil 20 Int
	//Stagger - Delay damage taking 40% of it over 10s, create timer real, every 1s deal damage (Gain the shuffle ability which clears the stagger effect 60s cooldown)
		// How to implement: timer that runs every second, and a global value, each time the timer ticks, take 1/8th of all the total damage away (Shuffle clears the global)
	//Clear Mind - take 20% less damage while meditating, and 20% less after it ends for 3 seconds.
	//Clestial Brew - Gain a large shield after exiting meditation and increase the effectiveness of meditation
	//Exploding Keg - Throwing an exploding keg at a location that deal massive (int) damage and knocks all enemies back



	//Path of the Celestials - Meditate base cooldown reduced by 4 sec and take 40% less damage while channeling
	//[Ooo Gladly] - Barrel Scaling increased, and mana cost reduced/removed

endfunction

//===========================================================================
function InitTrig_Talent_Brew_Monk takes nothing returns nothing
    set gg_trg_Talent_Brew_Monk = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Brew_Monk, function TalentBrewMonk )
    call TalentHeroSetCopy('E032', 'N041')	
endfunction
