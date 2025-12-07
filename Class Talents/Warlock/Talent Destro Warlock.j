function TalentDestroWarlock takes nothing returns nothing
	local integer heroTypeId = 'E02Z'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//https://www.hiveworkshop.com/threads/moarg-overlord.295043/
	//https://www.hiveworkshop.com/threads/core-hound.331564/
	//https://www.hiveworkshop.com/threads/demonic-gateway-warlock-spell.299354/
	//https://www.hiveworkshop.com/threads/murgul-warlock.298937/

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)

	set choice = TalentChoiceCreateImproveSpell('A094', 0, -1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Chaost Bolt"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFireForTheCannon.blp"

	set choice = TalentChoiceCreateImproveSpell('A099', -30, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Immolate"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNImmolationOn.blp"

	set choice = TalentChoiceCreateImproveSpellWithBoolean('AHbn', 0, -2.5, 2)
	set udg_TalentChoiceHead[choice] = "Netherwalk"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBanish.blp"
	set udg_TalentChoiceText[choice] = "Banish no longer slows movement when cast on yourself or an ally and it's cooldown is reduced by 2.5 seconds"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateBoolean(3)
	set udg_TalentChoiceHead[choice] = "Grimore of Sacrifice"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNNecromancerMaster.blp"
	set udg_TalentChoiceText[choice] = "Sacrificing Demon now increases the initial damage of your next Chaos Bolt or Immolate by 20%"

	set choice = TalentChoiceCreateBoolean(4)
	set udg_TalentChoiceHead[choice] = "Chaotic Increase"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNCorrosiveBreath.blp"
	set udg_TalentChoiceText[choice] = "Increases the base crit chance on Chaos Bolt by 8%"

	set choice = TalentChoiceCreateSustain(200, 100, 0)
	set udg_TalentChoiceHead[choice] = "Increased Health and Mana"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFaerieFire.blp"
	
	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpell('A09E',true) //Infernal
	call TalentChoiceCreateAddSpell('A0EA',true) //Hellfire (applies burning rush) 
	call TalentChoiceCreateAddSpell('A0EB',true) // Demonic Gateway

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateBoolean(9)
	set udg_TalentChoiceHead[choice] = "Fire and Brimstone"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFireRocks.blp"
	set udg_TalentChoiceText[choice] = "Rain of Fire now slows enemy's movement by 40%"

	set choice = TalentChoiceCreateImproveSpell('A09C', 0, -10.0)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Succubus"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_Shadow_SummonSuccubus.blp"

	set choice = TalentChoiceCreateImproveStatWithBoolean( 0, 400, 0, 6.0, 0.0, 11)
	set udg_TalentChoiceHead[choice] = "Demon Armor"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDemonArmor.blp"


	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateBoolean(12)
	set udg_TalentChoiceHead[choice] = "Mark of Kil'jaeden"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNKiljaedin.blp"
	set udg_TalentChoiceText[choice] = "Greatly increase your Succubus's health, damage, armor and mana"

	set choice = TalentChoiceCreateBoolean(13)
	set udg_TalentChoiceHead[choice] = "Rain of Hell Fire"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNRainOfFire.blp"
	set udg_TalentChoiceText[choice] = "Rain of Fire now deals 3x Bonus Intelligence"
	
	set choice = TalentChoiceCreateBoolean(14)
	set udg_TalentChoiceHead[choice] = "Sacrificial Lamb"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDemonicArtifact.blp"
	set udg_TalentChoiceText[choice] = "Sacrifice Demon now restores 66.6% more health and mana"



	//LEVEL 50

	// Bane of Havoc - (could replace banish) creates a demonic rift that casts banish on all enemies within a 160 range
	// Grimmore of Choas - Incease damage by 15% when below 40% health
	// Infernal Core - the infernal can now be sarcrificed as well
	// Shadowburn - Deal damage and make a target, gaining increase crit chance against them and causing them to explode whenever damage is applied
	// Channel Demon Fire - Replaces rain of fire, channel demon fire at a direct target, dealing massive damage, and benefits from all previous rain of fire talents
	// Dimnesion Rift - Creates a rift that fures chaos bolts at a target for 2 secs
endfunction

//===========================================================================
function InitTrig_Talent_Destro_Warlock takes nothing returns nothing
    set gg_trg_Talent_Destro_Warlock = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Destro_Warlock, function TalentDestroWarlock )
    call TalentHeroSetCopy('E04A', 'E02Z')	
endfunction


