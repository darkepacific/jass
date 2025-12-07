function TalentBloodDeathKnight takes nothing returns nothing
	local integer heroTypeId = 'U01V'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 	
	
	//DG's bugged

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpell('A0DG', 0, -2.0)
	set udg_TalentChoiceHead[choice] = "Tightening Grasp"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNspell_warlock_darkregeneration.blp"

	set choice = TalentChoiceCreateImproveSpell('A03U', -25, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana on Heart-Seeking Strike"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_BackStab.blp"
	
	set choice = TalentChoiceCreateSustain(0, 0, 4)
	set udg_TalentChoiceHead[choice] = "Increased Armor"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNUNholyArmor.blp"
	
	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	
	set choice = TalentChoiceCreateBoolean(3)
	set udg_TalentChoiceHead[choice] = "Blood for Blood"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBlood Strike.blp"
	set udg_TalentChoiceText[choice] = "Heart-Seeking Strike's damage is increased by 50% but now costs 4% of current HP."

	set choice = TalentChoiceCreateBoolean(4)
	set udg_TalentChoiceHead[choice] = "Back from the Grave"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAnimateDead.blp"
	set udg_TalentChoiceText[choice] = "Your death timer is reduced by 5 sec."

	//With Boolean, Heart Seeking Strike's healing is increased by 20%
	set choice = TalentChoiceCreateAddAndHideSpell('A0F6','A0F6', false)
	set udg_TalentChoiceHead[choice] = "Voracious"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTN.Vampire.Critical.blp"
	set udg_TalentChoiceText[choice] = "Gain 8% life steal on attack. Stacks with items."

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)

	call TalentChoiceCreateAddSpell('A03Y',true)  //Death and Decay
	call TalentChoiceCreateAddSpell('A073', true)  //Frostwyrm's Fury
	call TalentChoiceCreateAddSpellWithBoolean('A0FJ', true, 8)  //Bonestorm

	//Base 10/14/18/25 +22-39  +18

	//BlzGetUnitArmor
	//Charges Generted by dealing physical damage against enemies
	//Increases Armor and DMG by 2/3/4, up to 4 stacks, lasts 10s, having at least 1 stack allows you to a
	// activate this ability gaining a shield equal to 2% max hp * total armor for 3 sec
	// and deal damage to all enemies equal to 2 * (bonus strength + bonus armor) over 3 sec
	//Killing a unit drops a bone charge, walking over this instantly grants 6 stacks
	// Reinforced Bones - Bonestorm can now stack up to 6 times and the shield is increased by 50%

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateAddAndHideSpell('A0F5','AUau', false)
	set udg_TalentChoiceHead[choice] = "Dancing Rune Weapon"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDancingRuneWeapon.blp"  //BTNBloodsword.blp
	set udg_TalentChoiceText[choice] = "Gain an ability to summon a rune weapon to attack your enemies. The weapon's damage scales with |cffF04020Bonus Strength|r and can cast Bladestorm."

	set choice = TalentChoiceCreateAddAndHideSpell('A0F9','AUau', false)
	set udg_TalentChoiceHead[choice] = "Anti-Magic Shell"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAntiMagicShell.blp"
	set udg_TalentChoiceText[choice] = "Gain an ability to to cast anti-magic shell on yourself that shields from |cffffcc00400|r + |cffffcc006|r x |cffF04020Bonus Strength|r magic damage."

	set choice = TalentChoiceCreateBoolean(11) 
	set udg_TalentChoiceHead[choice] = "Will of the Necropolis"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBlackCitadel.blp"
	set udg_TalentChoiceText[choice] = "Damage taken below 30% hp is reduced by 40%"
	
	
	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateSustain(900, 0, 0)
	set udg_TalentChoiceHead[choice] = "Veteran of the 3rd War"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFlamedFlag.blp" 	//BTNTuskarrBanner

	set choice = TalentChoiceCreateBoolean(13) 
	set udg_TalentChoiceHead[choice] = "Bloodworms"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBloodworm.blp" 
	set udg_TalentChoiceText[choice] = "Dealing Physical damage with Attacks and Heart-Seeking Strike has a chance to create a bloodworm, they deal minor damage and then burst after 8s. Each time a bloodworm dies they heal you for 8% missing hp."

	set choice = TalentChoiceCreateBoolean(14) 
	set udg_TalentChoiceHead[choice] = "Blood Plague"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBlood Boil.blp"
	set udg_TalentChoiceText[choice] = "Death's Grasp and Heart-Seeking Strike now apply a blood plague that deals |cffffcc0080|r + |cffffcc000.5|r x |cc00096FFBonus Intelligence|r + |cffffcc000.5|r x |cfff04020Bonus Strength|r damage per sec for 7 sec."


	
	//50
	// Defy Death - When you take fatal damage, you instead drop to 20% health gain 20% attack speed and become immune to all damage for 3 sec. 3 min cooldown.
	
	//There will be blood - reduce the cooldown of Blood Pact by 5s (Increase base amount to 30 all levels)
	//Dark Succesor - When you kill an enemy your next Heart-Seeking Strike within 8s has its healing increased by 50%
		//https://www.wowhead.com/spell=178819/dark-succor
	//Mastery: Blood Shield - Each time you heal yourself with Heart-Seeking Strike, you gain 12% of the base amount healed as a Physical damage absorption shield.
	//[Vampiric Blood] - embrace undeath increasing health regen and healing recieved by 20%	
	//[Dark Command] - command the target to attack you (put on Death Grip)
	//[Blood Drinker] - Drain X health from target of 3sec
	//^Dark Conversion - Channel on an enemy Hero for 0.75 seconds, then swap Health percentages with the target over 3 seconds.
	//Gorefiends Grasp - Death grip now grabs up to 1 more neaby target
	//[Sacrifical Pact] - sacrificing a raised undead deals AoE dmg
	//Blood Strike - And instant strike ability the deals more damage the more diseases the target has
		// https://wowpedia.fandom.com/wiki/Blood_Strike
	//Decomposing Aura - all enemies in 450 range continually loose 2% of there maximum hp
		//PAS: Blood Plague ACT: Blood Boil
		//Blood Plague - Q,W, R now apply a blood plague, disease that deals damage and drains health
		//Blood Boil - deals aoe shadow damage and inflicts all enemies with Blood Plague



endfunction

//===========================================================================
function InitTrig_Talent_Blood_Death_Knight takes nothing returns nothing
    set gg_trg_Talent_Blood_Death_Knight = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Blood_Death_Knight, function TalentBloodDeathKnight )
    call TalentHeroSetCopy('U01U', 'U01V')	
endfunction