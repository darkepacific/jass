function TalentDarkRanger takes nothing returns nothing
	local integer heroTypeId = 'H02V'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//Add warning to HW if unable to move to location - "Can't path there"

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpell('A04V', - 25, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Haunting Wave"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHauntingWave.blp"

	//Black Arrw Damage is INSTANT in JASS needs to modify the abil itself like other spells, Arcane Shot
	set choice = TalentChoiceCreateBoolean(1) 
	set udg_TalentChoiceHead[choice] = "Bonus Damage on Black Arrow"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNTheBlackArrow.blp"
	set udg_TalentChoiceText[choice] = "Now deals 6 x Bonus Agility on Initial Strike"

	//Change the model of skeletons to have more armor
	set choice = TalentChoiceCreateBoolean(2) 
	set udg_TalentChoiceHead[choice] = "Stronger Skeletons"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNRaiseDead.blp"
	set udg_TalentChoiceText[choice] = "Increase the Damage of all Skeletons by 0.8 x Intelligence"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateImproveSpell('A04X', 0, - 10.0)
	set udg_TalentChoiceHead[choice] = "Reduced Spider Cooldown"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNConjuringWebs.blp"

	set choice = TalentChoiceCreateImproveStatWithBoolean(2, 0, 25, 0, 0, 4)
	set udg_TalentChoiceHead[choice] = "Increased Damage"
	set udg_TalentChoiceText[choice] = "Increase Base Attack Damage by 25"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Weapon_Bow_09.blp"

	set choice = TalentChoiceCreateStats(0, 0, 12)
	set udg_TalentChoiceHead[choice] = "Magical Boost: Int"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPipeOfInsight.blp"
	

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpell('A0FD',true) //Withering Fire - continuously fire arrows in a line 
	call TalentChoiceCreateAddSpell('A0FI', true) //Blighted Trap - when triggered two blighted dark hounds jump into action
	//Rain of Vengance - Summon two blighted darkhounds to charge at the target briefly stunning them for 1 sec and then continuing to attack enemies for 6 sec
	// call TalentChoiceCreateAddSpell('A0EI', true) //Freezing Trap
	call TalentChoiceCreateAddSpell('A0GC', true) //Reliquary of Souls
	//[Reliquary of Souls] - become a free floating banshee for 8 sec, that wails around the battlefield invulnerable, during this time the DR heals for 15/22.5/30% of all damage done
		//Use Soul Discharge and Singularity Purple

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateBoolean(9)
	set udg_TalentChoiceHead[choice] = "Wind Runner"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFadeStrike.blp"
	set udg_TalentChoiceText[choice] = "After casting Haunting wave gain a 60% attack speed and 20% movement speed buff for 2.75 sec"

	set choice = TalentChoiceCreateStats(0, 20, 0)
	set udg_TalentChoiceHead[choice] = "Overwhelming: AGI"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAgi.blp"

	set choice = TalentChoiceCreateBoolean(10) 
	set udg_TalentChoiceHead[choice] = "Skeletal Longevity"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSkeletalLongevity.blp"
	set udg_TalentChoiceText[choice] = "Increase the duration of all Skeletons by 10 sec"

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40) //A0EO
	set choice = TalentChoiceCreateAddAndHideSpell('ACch', 'A0GD', false)
	set udg_TalentChoiceHead[choice] = "Charm"
	set udg_TalentChoiceText[choice] = "Gain Charm, an ability that takes control of an enemy unit for 8 sec; may only charm 1 unit at a time."
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNCharm.blp"


	set choice = TalentChoiceCreateAddAndHideSpell('A0DH', 'A0GD', false)
	set udg_TalentChoiceHead[choice] = "Hunter's Mark"
	set udg_TalentChoiceText[choice] = "Gain Hunter's Mark, an ability that marks an enemy giving vision of them and reducing their armor."
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHuntersMark.blp"

	//Inc CD, lower skeletons hp/lvl
	set choice = TalentChoiceCreateAddAndHideSpell('AIfs', 'A0GD', false)
	set udg_TalentChoiceHead[choice] = "Skeletal Army"
	set udg_TalentChoiceText[choice] = "Gain Skeletal Army, an ability that instantly summons 3 skeleton maulers and 3 skeleton archers. Benefits from all other skeletal talents."
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSkeleton.Purple.blp"


	//50
	
	// Gain two charges of Haunting Wave
	// [Shadow arrow Volley] - black arrow fires at 2 more nearby targets
	// Back from the Shadowlands - When you die instead enter a stas`is and revive after 5 sec with 50% hp and mana.
	// Skeletal Magic - black arrow now summons powerful skeletal mages


	//[Camouflage] - blend into your surroundings, 
	//Screaming Wave - increase the range on Haunting Wave by 150 (improve and boolean)
	//Increased Attack Speed
		// set choice = TalentChoiceCreateImproveWeapon(0, 0, -1.06)	//BM Base is 2.46/1.4 - 1 = 75%
		// set udg_TalentChoiceHead[choice] = "Increased Attack Speed"
		// set udg_TalentChoiceText[choice] = "Increase Attack Speed by 75%"
		// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBloodlust.blp"

	//Blighted Quiver - Increase the number of charges on black arrow by 2
	//Penetrating Darkness - black arrow now pierces through all enemies in a line and applies the debuff



	
	//Chains of Domination - root an enemy in place for 1.25s during this time you're able to recast the ability in a target direction, a 2nd chain fires forth that if it makes contact with an another enemy, both are pulled towards each other and rooted for 2.5s, taking X damage
	//Replace Haunting wave with Chains of Domination, - a skill shot that shoots a chain at an enemy reactivating allows you to target another enemy and pull them both in, stunning and dealing damage

endfunction

//===========================================================================
function InitTrig_Talent_Dark_Ranger takes nothing returns nothing
	set gg_trg_Talent_Dark_Ranger = CreateTrigger(  )
	call TriggerAddAction( gg_trg_Talent_Dark_Ranger, function TalentDarkRanger )
	call TalentHeroSetCopy('H01I', 'H02V')
endfunction


