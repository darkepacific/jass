function TalentMistMonk takes nothing returns nothing
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

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddAndDisableSpell('A09H', 'N041', 0, 0 , 6 , true) //Niuzao Black Ox
	call TalentChoiceCreateAddAndDisableSpell('A0E7', 'N041', 0, 0 , 7 , true) //Gift of the Ox
	call TalentChoiceCreateAddAndDisableSpell('A0E6', 'N041', 0, 0 , 8 , true) //Mighty Ox Kick

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateBoolean(9)
	set udg_TalentChoiceHead[choice] = "Roundhouse Kick"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNRising Sun Kick.blp"
	set udg_TalentChoiceText[choice] = "Leg Sweep scaling damage increased to 6x Bonus Str"

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
	set udg_TalentChoiceText[choice] = "If Meditate is cancelled in the first 3 seconds its remaining cooldown is reduced by half, and regain 45 mana."

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

	//Abilities
	//Tiger Palm   (Dash in a target directon and hit the closest enemy in melee range)
		//Roll in a target direction
	//Rising Sun Kick (Blackout Kick)
	    //Simply cast and hits the closest enemy in melee range (talent hits up to 3 enemies, resets cd on spinning crane kick)
	//Spinning Crane Kick
	//Fists of Fury	(Interupt and channel aoe damage)
	

	//Roll/Chi Torpedo/
	//Flying Serpent Kick - instantly lunge forward in the target direction, slows on enemies on land, recast to land early
	//Slicing Winds, channel for a second the longer channeled the farther travels

	//Ults
	//Invoke Xuen, the White Tiger
	//Storm, Earth, and Fire
	//Touch of Death

	//Talents
	//Expel Harm (Vivify/Chi Wave/Chi Burst) (Talent) (additional ability or every third cast) of tiger palm or blackout kick heals)



endfunction

//===========================================================================
function InitTrig_Talent_Mist_Monk takes nothing returns nothing
    set gg_trg_Talent_Mist_Monk = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Mist_Monk, function TalentMistMonk )
    call TalentHeroSetCopy('E032', 'N041')	
endfunction
