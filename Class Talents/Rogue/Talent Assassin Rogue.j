function TalentAssassinRogue takes nothing returns nothing
	local integer heroTypeId = 'E03W'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 	

	//BTNHoldPosition.blp
	// Update Text on Crimson Tempest
	//Rescale Combo Orb in model editor

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpell('A04U', -15, -1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Costs on Vanish"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp"

	set choice = TalentChoiceCreateImproveSpell('A0AN', -20, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Mutilate"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Rogue_Mutilate.blp"

	set choice = TalentChoiceCreateImproveWeapon(0, 0, -0.41)	//Base is 2.05/1.64 = 25%
	set udg_TalentChoiceHead[choice] = "Increased Attack Speed"
	set udg_TalentChoiceText[choice] = "+25% Attack Speed"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Sword_12.blp"
	
	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateBoolean(3)
	set udg_TalentChoiceHead[choice] = "Shadow Stepper"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNShadowstep.blp"
	set udg_TalentChoiceText[choice] = "Shadow Step now jumps one more time and awards an additional combo point if more than one enemy is hit."

	set choice = TalentChoiceCreateMovement(30)
	set udg_TalentChoiceHead[choice] = "Hit and Run"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBoots.blp"

	set choice = TalentChoiceCreateImproveSpell('A017', -25, -2.5)
	set udg_TalentChoiceHead[choice] = "Reduced Costs on Eviscerate"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Rogue_Eviscerate.blp"

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpell('A04O',true) //Marked for Death
	call TalentChoiceCreateAddAndHideSpells("A0F2,A0F1",'A0F2','A0F1',true) //Envenom - All poison dmg types are reduced by spell resistance
	call TalentChoiceCreateAddSpell('A0F3',true) //Crimson Tempest

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateBoolean(9)
	set udg_TalentChoiceHead[choice] = "Infinity's Edge"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNCriticalStrike.blp"
	set udg_TalentChoiceText[choice] = "Mutilate and Shadowstep now critically strike for 300% damage."
	
	set choice = TalentChoiceCreateBoolean(10)
	set udg_TalentChoiceHead[choice] = "Ruthlessness"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFocusedAttacks.blp"
	set udg_TalentChoiceText[choice] = "Each time a combo-point is spent have a 33/66/100% chance to gain a new combo point, based on the number of points spent."

	set choice = TalentChoiceCreateStats(0, 20, 0)
	set udg_TalentChoiceHead[choice] = "Overwhelming: AGI"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAgi.blp"

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	//Energize - regenerate 8% of missing mana each second when out of combat
	// set choice = TalentChoiceCreateSustain(300, 600, 0)
	// set udg_TalentChoiceHead[choice] = "Vigor"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNvigor.blp"
	set choice = TalentChoiceCreateBoolean(12)
	set udg_TalentChoiceHead[choice] = "Soothing Darkness"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_Shadow_Twilight.blp"
	set udg_TalentChoiceText[choice] = "Heal and restore 2.5% hp and mana per sec while stealthed."

	set choice = TalentChoiceCreateBoolean(13) 
	set udg_TalentChoiceHead[choice] = "Cheat Death"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNCheatDeath.blp"
	set udg_TalentChoiceText[choice] = "Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 93% reduced damage. Cannot trigger more often than once per 60 sec."
	
	set choice = TalentChoiceCreateBoolean(14) 
	set udg_TalentChoiceHead[choice] = "Elaborate Planning"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMap.blp"
	set udg_TalentChoiceText[choice] = "After using a combo move, deal 12% increased damage to all enemies for 3 sec."
	//Nerf to 10%



	
	//LEVEL 50
	//Killing Spree - Killing an enemy instantly resets the cooldown on Mutilate and Shadowstep.
	//Shiny Knives - Multilate now blinds enemies for X sec
	//[Cheap Shot] - replace sap with cheap shot, an ability that stuns for 2s, or gain this ability while stealth, gens 1 combo point
	//Blind - gouge, garrote, rupture now also blind the target
	// Eviscerate now scales with bonus Agility dealing an additional 1,2,3x Dmg
	// Eviscerate now deals bonus damage againts enemies who are poisoned
	// Inc Attack Speed

	//Vendetta - enemies who are marked by your X take Y% inc dmg from you
	//Leaching Poison - heal for 20% of all damage you do

	//Deadly poison - empower your attacks to poison enemies and slow their movementspeed for X sec
	//Gain 1 extra combo point from sap and shadowstep if it hits an additional enemy 
	//Leech Poision - gain passive LS on attack


endfunction

//===========================================================================
function InitTrig_Talent_Assassin_Rogue takes nothing returns nothing
    set gg_trg_Talent_Assassin_Rogue = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Assassin_Rogue, function TalentAssassinRogue )
    call TalentHeroSetCopy('E001', 'E03W')	
endfunction
