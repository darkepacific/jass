function TalentUnholyDeathKnight takes nothing returns nothing
	local integer heroTypeId = 'U036'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 	

	//Healing on DC off (not 20%)

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpell('A0DG', 0, - 2.0)
	set udg_TalentChoiceHead[choice] = "Tightening Grasp"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNspell_warlock_darkregeneration.blp"

	set choice = TalentChoiceCreateImproveSpellWithBoolean('A001', - 25, - 1.0, 1)
	set udg_TalentChoiceHead[choice] = "Reduced Costs on Death Coil"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDeathCoil.blp"

	set choice = TalentChoiceCreateRegen(2.0, 2.0, 0, 0)
	set udg_TalentChoiceHead[choice] = "Rapid Recomposition"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNRegenerationAura.blp"	
	
	
	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)

	set choice = TalentChoiceCreateBoolean(3)
	set udg_TalentChoiceHead[choice] = "Putrid Heart"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHeartOfSearinox.blp"
	set udg_TalentChoiceText[choice] = "Increases the damage and healing on Death Coil by 20%"	
	
	set choice = TalentChoiceCreateBoolean(4)
	set udg_TalentChoiceHead[choice] = "Back from the Grave"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAnimateDead.blp"
	set udg_TalentChoiceText[choice] = "Your death timer is reduced by 5 sec."//or 40% whichever the greater."

	set choice = TalentChoiceEnableTrigger(5)
	set udg_TalentChoiceHead[choice] = "Exhume Corpses"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMeatWagon.blp"
	set udg_TalentChoiceText[choice] = "Once every 20s you generate a random nearby corpse."


	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpell('A03L', true) //Path of Death  - creates slimes aftewards
	call TalentChoiceCreateAddSpell('A0FB',true) //Gargoyle  - //Lasts 20s, 60s cd, enemies that take damage from it are applied plage, has carrion swipe and stone form
	call TalentChoiceCreateAddSpell('A03Y', true) //Death and Decay 
	
	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateAddAndHideSpell('A0FE', 'AUau', false)
	set udg_TalentChoiceHead[choice] = "Death Gate"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDeath_Gate14.blp"
	set udg_TalentChoiceText[choice] = "Create a Death Gate allowing the Death Knight to travel from their current location to the closest graveyard for 15 sec."

	set choice = TalentChoiceCreateAddAndHideSpell('A0FK', 'AUau', false)
	set udg_TalentChoiceHead[choice] = "Wraith Walk"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNWraithWalk.blp"
	set udg_TalentChoiceText[choice] = "Enter the realm of shadows, removing negative buffs, allowing the ability to pass through units, and taking 50% damage for 4 sec, but become unable to attack or cast spells."

	set choice = TalentChoiceCreateStatsWithBoolean(20, 0, 0, 11, "Death Pact Cooldown: -2.5")
	set udg_TalentChoiceHead[choice] = "Strength of the Damned"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp"


	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateReplaceAndImproveSpell('A001', 'A0F4', - 25, - 1.0, 1)
	set udg_TalentChoiceHead[choice] = "Carrion Swarm"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNCarrionSwarm.blp"
	set udg_TalentChoiceText[choice] = "Replaces Death Coil; sends a horde of bats to damage enemies. The bats infect enemies with the plague. |n|nBenefits from all previous talent buffs to Death Coil."

	set choice = TalentChoiceCreateBoolean(13) 
	set udg_TalentChoiceHead[choice] = "Ebon Fever"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNOrbOfCorruption.blp"
	set udg_TalentChoiceText[choice] = "Virulent Plague passive deals 40% more damage"

	set choice = TalentChoiceCreateBoolean(14) 
	//Make inc range by 20%
	set udg_TalentChoiceHead[choice] = "Outbreak"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNOutbreak.blp"
	set udg_TalentChoiceText[choice] = "Epidemic's explosive damage is increased by 30% and if a target dies from the explosion instantly reset the cooldown."

	

	//50
	// set choice = TalentChoiceCreateAddAndHideSpell('A000', 'A03N', false)
	// set udg_TalentChoiceHead[choice] = "Apocalypse"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHornOfDoom.blp"
	// set udg_TalentChoiceText[choice] = "Create an explosion at a target location dealing damage and infecting all enemies with plague. |n Has a much farther range than most abilities. (1100)"

	// Plague Bomber - Gain a second charge of Epidemic, and the cooldown is reduced by 5 sec.


	//Persistent Plague - Virulent Plague last for 2s longer
	//Raise dead leave behind slimes that travel in a random direction and then explode after 3 sec
	//Permanent Ghoul - Dark Transformation
	//Death Pact - reduces the cooldown and manacost of Death-Pact, during Raise Dead.
	//Overwhelming STR
	//Necrotic Wounds - heal for 5% of all damage you do
	//Permanent Ghoul - lvl 30, permanently acquire a ghoul that attacks enemies near you. Evertime it dies a new one arrises.
	//Army of the Dead - summon a legion of 4/6/8 ghouls attacking anyhing they can
	//Unholy Blight - A spell now leaves behind a ravenous carrion swarm that infects enemies with the plague
		// Or a ravenous swarm of insects surrounds you, and infects them with virulent plague
	//Necrotic Aura - Enemies near you take 10% more damage from all sources

	// set choice = TalentChoiceCreateBoolean(4)
	// set udg_TalentChoiceHead[choice] = "All Will Serve"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAnimateDead.blp"
	// set udg_TalentChoiceText[choice] = "Increases the Maximum Number of Animated Dead by 2"


endfunction

//===========================================================================
function InitTrig_Talent_Unholy_Death_Knight takes nothing returns nothing
	set gg_trg_Talent_Unholy_Death_Knight = CreateTrigger(  )
	call TriggerAddAction( gg_trg_Talent_Unholy_Death_Knight, function TalentUnholyDeathKnight )
	call TalentHeroSetCopy('U03A', 'U036')	
endfunction




