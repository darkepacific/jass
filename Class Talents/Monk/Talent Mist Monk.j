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
	//(TIGER DASH) Tiger Palm/Radiant Dash - Dash to an ally or enemy, healing or damaging them
		//Maybe Roll - Roll in a direction, collinding with an ally or enemy, heals or damages them
	//Renewing Mist (heals then travels to another ally)
	//Spinning Crane Kick (Talent - Refreshing Jade Wind - Spin now heals all nearby allies )
	//Craking Jade Lightning
	//Essence Font

	//Lvl 5  -- Cooldowns and mana cost

	//lvl 10
	// Flat Bonus - Armor or Movementspeed
	// Vivify -  castin Q/E now instatly heal all targets with your renewing mist
	// Enveloping Mist - renewing mist and essence font now heals for 20% more and lasts for 2 seconds longer

	//Lvl 20
	//Firecracker Dragon - Channel a firecracker dragon that travels through enemies, slowing them dealing damage and healing allies
	//Statues - Summon Jade Serpent Statue/Summon Black Ox Statue/Summon White Tiger Statue/Summon Red Crane Statue
				//Jade heals all nearby allies
				//Black Ox taunts all nearby enemies
				//White Tiger increases all nearby allies attack and movespeed
				//Red Crade - increases all nearby allies mana regen and reduces your cooldowns
			    // (STATUES CAN BE DASHED TO)
	//Jade Fire Stomp




	//Lvl 30
	// [Expel Harm] - replaces renewing mist instead instanly apply heal your self for 200 hp and apply renewing mist to the closest allied lowest-health  target
	// [Ring of Peace] - spinning crane kick now knocs back all nearby enemies
	// [Rushing Wind Kick] - spinning crane kick now heals all nearby allies
	// [Blinding Winds] - spinning crane kick now blinds all nearby enemies

	// Lvl 40
	// Life Cocoon - Targets within your essence font that have renewing mist gain a shield for 10 seconds
		//(encase the target in a shield and increasing all new healing done to them by 20%) 
	// Thunder Focus Tea  - passive every 3 spell cast instantly regain back the full mana-cost of the spell or active incereases the next spell cast by 50% and resets the cooldown of the spell
	// Bonus Agility and Intelligence - +12 and 12

	//Ressucitate



	

	

	

endfunction

//===========================================================================
function InitTrig_Talent_Mist_Monk takes nothing returns nothing
    set gg_trg_Talent_Mist_Monk = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Mist_Monk, function TalentMistMonk )
    call TalentHeroSetCopy('E032', 'N041')	
endfunction
