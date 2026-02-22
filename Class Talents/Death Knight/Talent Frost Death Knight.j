function TalentFrostDeathKnight takes nothing returns nothing
	local integer heroTypeId = 'U039'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 	

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	//Frigid Grasp
	set choice = TalentChoiceCreateImproveSpellWithBoolean('A02V', 0, -1.5, 0)
	set udg_TalentChoiceHead[choice] = "Reduced cooldown on Howling Blast"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBreathOfFrost.blp"

	set choice = TalentChoiceCreateImproveSpellWithBoolean('A037', - 25, 0, 1)
	set udg_TalentChoiceHead[choice] = "Reduced mana cost on Obliterate"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFrostSword.blp"

	set choice = TalentChoiceCreateImproveWeapon(0, 18, 0)
	set udg_TalentChoiceHead[choice] = "Increased Attack Damage"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Sword_12.blp"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateBoolean(3) 
	set udg_TalentChoiceHead[choice] = "Frozen Heart"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Misc_Gem_Sapphire_01.blp"
	set udg_TalentChoiceText[choice] = "Increase all spell damage done and anti-magic shields by 8%"

	//https://www.wowhead.com/spell=321995/hypothermic-presence (SOUND)
	set choice = TalentChoiceCreateImproveTwoSpells('A02V', 'A02J', - 40, 0, 0)
	set udg_TalentChoiceHead[choice] = "Hypothermic Presence"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFrost.blp"
	set udg_TalentChoiceText[choice] = "Embrace the ice in your veins reducing mana costs on Howling Blast and Remorseless Winter by 40"

	set choice = TalentChoiceCreateBoolean(5) 
	set udg_TalentChoiceHead[choice] = "Icy Talons"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNIcyTalons.blp"
	set udg_TalentChoiceText[choice] = "After casting Obliterate increase your attack speed by 50% for 4s"

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpell('A073', true)  //Frostwyrm's Fury
	call TalentChoiceCreateAddSpell('A0EP', true)  //Breath of Sindragosa 
	call TalentChoiceCreateAddSpell('A0G3', true)  //Pillar of Frost

	//Pillar of Frost - [Improves Frost Aua] Create a pillar of frost that blocks movement and chains all nearby enemies to it
	//Chains of Ice - slows nearby enemies MS
	//Enemies who try to leave the pillar's raidus are slowed and pulled back

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateMovement(60)
	set udg_TalentChoiceHead[choice] = "On a Pale Horse"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNUndeadHorse.blp"

	set choice = TalentChoiceCreateStats(20, 0, 0)
	set udg_TalentChoiceHead[choice] = "Overwhelming: Str"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp"

	set choice = TalentChoiceCreateAddAndHideSpell('A000', 'A03N', false)
	set udg_TalentChoiceHead[choice] = "Horn of Winter"
	set udg_TalentChoiceText[choice] = "Gain the Horn of Winter, an ability that grants all nearby allies 45% increased attack damage and movement speed for 10s"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHornOfDoom.blp"

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	//Impale Firelords bug
	//Add with boolean > and switch root to stun
	set choice = TalentChoiceCreateReplaceAndImproveSpellWithBoolean('A037', 'A01G', - 25, 0, 1, 12)
	set udg_TalentChoiceHead[choice] = "Glacial Advance and Stun"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNGlacier.blp"
	set udg_TalentChoiceText[choice] = "Replaces Obliterate for Glacial Advance, an impale spell that knocks up enemies in a target direction. Additionally Howling blast now stuns targets for 1.2 sec instead of rooting them. |n|nBenefits from all previous talent buffs to Obliterate."

	set choice = TalentChoiceCreateBoolean(13) 
	set udg_TalentChoiceHead[choice] = "Killing Machine"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNKillingMachine.blp"
	set udg_TalentChoiceText[choice] = "After taking 800 damage while in combat your next Obliterate is guaranteed to critically strike for 300% it's base value."

	set choice = TalentChoiceCreateBoolean(14) 
	set udg_TalentChoiceHead[choice] = "Icebound Fortitude"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNIceboundFortitude.blp"
	set udg_TalentChoiceText[choice] = "Reduce all damage taken by 15%"

	
	//50
	//Hypothermia - Enemies affected by your Frost Presence take 8% increase damage from all sources (if has buff and H is enemy and H has talent)
	//Blinding Sleet - Howling Blast now blinds targets for 1sec causing them to miss 33% of attacks for 2 sec.
	//Rime - Howling blast deals 35% more damage in it's center. And the root duration is increased by 0.5s.
	// Soul Reaper - Strike an enemy for (37.4% of Attack power) Shadowfrost damage and afflict the enemy with Soul Reaper. 
		//After 5 sec, if the target is below 35% health this effect will explode dealing an additional (171.6% of Attack power)
	//Obliterate now has a 50% base crit chance ontop of bonuses from items
	//Ice Wall - Create a wall of ice that blocks movement for 4 sec

endfunction

//===========================================================================
function InitTrig_Talent_Frost_Death_Knight takes nothing returns nothing
	set gg_trg_Talent_Frost_Death_Knight = CreateTrigger(  )
	call TriggerAddAction( gg_trg_Talent_Frost_Death_Knight, function TalentFrostDeathKnight )
	call TalentHeroSetCopy('U02Z', 'U039')	
endfunction