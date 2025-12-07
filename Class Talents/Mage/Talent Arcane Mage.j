function TalentArcaneMage takes nothing returns nothing
	local integer heroTypeId = 'H02Q'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50)


	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateBoolean(0)
	set udg_TalentChoiceHead[choice] = "Improved Arcane Missiles"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNStarfall.blp"
	set udg_TalentChoiceText[choice] = "Arcane Missiles fires faster and 1 extra missile" 
	
	set choice = TalentChoiceCreateImproveSpell('A08A', 0, -1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Arcane Missiles"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDustClock.blp"

	set choice = TalentChoiceCreateImproveSpell('A00G', -30, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Arcane Explosion"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNWispSplode.blp"


	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateBoolean(2) //Uses 3 also in spell cast (3 not in use atm)
	set udg_TalentChoiceHead[choice] = "Clearcasting"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNManaBurn.blp"
	set udg_TalentChoiceText[choice] = "Each time you spend mana, you have a 20% chance to regain the mana you just spent."
	
	// set choice = TalentChoiceCreateSustain(150, 150, 0)
	// set udg_TalentChoiceHead[choice] = "Increase Health and Mana"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Misc_Gem_Sapphire_02.blp"
	 
	set choice = TalentChoiceCreateStats(0, 0, 10)
	set udg_TalentChoiceHead[choice] = "Improved: Int"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMantleOfIntelligence.blp"

	set choice = TalentChoiceCreateBoolean(4)
	set udg_TalentChoiceHead[choice] = "Enlightened"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHelix-Magnus.blp"
	set udg_TalentChoiceText[choice] = "Damage you deal while above 70% mana is increased by 10%"
	
	
	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpell('A08D',true)  //Teleport
	call TalentChoiceCreateAddSpell('A0DF',true)  //Alter Time -- needs second time cast
	call TalentChoiceCreateAddSpell('A08G',true)  //Ice Block
	//Time Stop - Send out two waves of time, iniitially greatly slowing enemies hit by the first wave then freezing all enemies in place for 2 secs hit by the second. Enemies who are hit are invulnerable but unable to take actions.


	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateMovement(50)
	set udg_TalentChoiceHead[choice] = "Increased Movement Speed"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_fire_burningspeed.blp"

	set choice = TalentChoiceCreateBoolean(10) 
	set udg_TalentChoiceHead[choice] = "Greater Invisibility"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp"
	set udg_TalentChoiceText[choice] = "The invisibility after using Blink lasts 3 sec longer"

	set choice = TalentChoiceCreateStats(0, 0, 20)
	set udg_TalentChoiceHead[choice] = "Overwhelming: Int"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMagicalSentry.blp"


	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateReplaceSpell('A00H','Aslo')
	set udg_TalentChoiceHead[choice] = "Slow"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSlow.blp"
	set udg_TalentChoiceText[choice] = "Replaces Arcane Intellect with Slow"

	set choice = TalentChoiceCreateReplaceSpell('A00H','A00R')
	set udg_TalentChoiceHead[choice] = "Arcane Brilliance"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBrilliance.blp"
	set udg_TalentChoiceText[choice] = "Replaces Arcane Intellect for a very strong Brilliance Aura"

	set choice = TalentChoiceCreateReplaceSpell('A00H','A04I')
	set udg_TalentChoiceHead[choice] = "Counterspell"
	set udg_TalentChoiceText[choice] = "Replaces Arcane Intellect with Counterspell"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFeedback.blp"

	//50
	//Poly Bomb - Replaces poly morph with a spell that polymorphs all enemies in an area for 3 seconds, when the effect ends they explode
		//Replace PolyMorph with Primastic Barrier
		//Replace Polymorph with ArcaneBarrage, an arcane (combopoints) spell that stores up to 4 points, each time you cast q or e
	//Arcane Orb - explodes on first enemy hit
	//Prismatic Barrier - After casting advance blink gain a barrier for X + Int, the shield is refreshed when the second illusion is cast



	//Rule of Threes - Every third Arcane missile that hits deals 150% more damage
	//Every 12s after you cast a spell create an arcane familiar that attacks enemies for 4 seconds and boosts your base intelligence by 30
	//Master of Time - Alter Time now resets the cooldown on blink
	//Reverberate - If arcane explosion hits at least 5 enemies it resets the cooldown on arcane missiles


endfunction

//===========================================================================
function InitTrig_Talent_Arcane_Mage takes nothing returns nothing
    set gg_trg_Talent_Arcane_Mage = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Arcane_Mage, function TalentArcaneMage )
    call TalentHeroSetCopy('H02T', 'H02Q')	
endfunction


