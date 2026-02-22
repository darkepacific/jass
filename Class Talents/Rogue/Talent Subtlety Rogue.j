function TalentSubtletyRogue takes nothing returns nothing
	local integer heroTypeId = 'E00E'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50)

	//Cannot Reroll while stealthed
	//Move Alliance selection island
	//Specify that Evis is physical damage

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpell('A00V', -15, -1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Costs on Vanish"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp"

	set choice = TalentChoiceCreateImproveSpell('A00W', 0, -1.5)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Gouge"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Gouge.blp"

	set choice = TalentChoiceCreateImproveWeapon(0, 0, -0.41)	//Base is 2.05/1.64 = 25%
	set udg_TalentChoiceHead[choice] = "Increased Attack Speed"
	set udg_TalentChoiceText[choice] = "Attack Speed: +25%"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Sword_12.blp"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)

	set choice = TalentChoiceCreateImproveSpellWithBoolean('A00W', -25, 0, 3)
	set udg_TalentChoiceHead[choice] = "Dirty Tricks"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Sap.blp"
	set udg_TalentChoiceText[choice] = "Reduces the mana cost on Gouge, Sap, and Nightblade by 25" 

	set choice = TalentChoiceCreateBoolean(4)
	set udg_TalentChoiceHead[choice] = "Shuriken Storm"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNShurikenRed.blp"
	set udg_TalentChoiceText[choice] = "Fan of Knives also triggers a storm of shurikens that fires half a second later for 50% damage and also generates 1 more combo point if an enemy is hit."

	set choice = TalentChoiceCreateImproveSpell('A017', -25, -2.5)
	set udg_TalentChoiceHead[choice] = "Reduced Costs on Eviscerate"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Rogue_Eviscerate.blp"

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpell('A06M',true) //[Smoke Bomb], Nerf/equalize smokebomb
	call TalentChoiceCreateAddSpell('A0EW',true) //[Secret Technique] - Finishing move - create shadow clones that attack enemies dealing damage
	call TalentChoiceCreateAddSpell('A0EX',true) //[Cloak of Shadows] - remove all negative debuffs, gain magic immunity for 5 sec

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateBoolean(9)
	set udg_TalentChoiceHead[choice] = "Find Weakness"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBreakingSmash.blp"
	set udg_TalentChoiceText[choice] = "Gouge and Nightblade now reduce the enemy's armor by 12 for 3 sec."

	set choice = TalentChoiceCreateBoolean(10)
	set udg_TalentChoiceHead[choice] = "Ruthlessness"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFocusedAttacks.blp"
	set udg_TalentChoiceText[choice] = "Each time a combo-point is spent have a 33/66/100% chance to gain a new combo point, based on the number of points spent."

	set choice = TalentChoiceCreateStats(0, 20, 0)
	set udg_TalentChoiceHead[choice] = "Overwhelming: AGI"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAgi.blp"


	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateSustain(300, 600, 6)
	set udg_TalentChoiceHead[choice] = "Vigor"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNvigor.blp"

	set choice = TalentChoiceCreateBoolean(13)
	set udg_TalentChoiceHead[choice] = "Soothing Darkness"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_Shadow_Twilight.blp"
	set udg_TalentChoiceText[choice] = "Heal and restore 2.5% hp and mana per sec while stealthed."

	set choice = TalentChoiceCreateBoolean(14)
	set udg_TalentChoiceHead[choice] = "Veil of Midnight"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNEvasion.blp"
	set udg_TalentChoiceText[choice] = "Gain 100% dodge while stealthed and for 2 sec after exiting stealth."


	
	//LEVEL 50  -- All combo point abilities place the rogue in combat

	//Shroud of Concealment - active instantly gain invisibility for yourself and all allies (within 900)/ passive stelth now casts invisibility on yourself and allies
	
	//Black Powder - Night blade now releases an explosion of black powder, dealing an additional 25% of its total damage to all enemies instantly in a 300 radius and silencing them for 2.5 sec
	
	//Shadow Dance - Energize now grants a short invisibility and 50% movement speed for 2 sec, and 1 combo point
	//Prey on the Weak - enemies disabled by sap take 25% increased damage from their next damage source	


	
	//Gloom Blade - your attacks now deal an additiona 10% universal damage (Universal damage is damage not reduced by armor or spell resistance)
	//[Cheap Shot] - replace sap with cheap shot, an ability that stuns for 2s

	//Backstab - requires stealth, stab the target, causing X Physical damage. Damage increased by 20% when you are behind your target
	//Inc Sap duraction against non-heroes
	//Shadow Focus - While Stealthed, you strike through the shadows and appear behind your target up to 25 yds away, dealing 25% additional damage.
	

endfunction

//===========================================================================
function InitTrig_Talent_Subtlety_Rogue takes nothing returns nothing
    set gg_trg_Talent_Subtlety_Rogue = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Subtlety_Rogue, function TalentSubtletyRogue )
    call TalentHeroSetCopy('E007', 'E00E')	
endfunction
