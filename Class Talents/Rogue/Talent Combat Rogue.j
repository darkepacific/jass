function TalentCombatRogue takes nothing returns nothing
	local integer heroTypeId = 'E035'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//BTNBanditSpearThrower 
	//BTNSeaGiantWarStomp
	//Agi: 20:50:66:82
	
	// y =( Pow(bj_E,( x/-200) ) ) *RAbsBJ( 250  * Cos(x / 51 ))

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveTwoSpells('A09V', 'A0SD', -20, 0, 1)
	set udg_TalentChoiceHead[choice] = "Reduced Mana on Slice & Dice"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Rogue_SliceDice.blp"
	set udg_TalentChoiceText[choice] = "Slice and Dice |nMana Cost: -20"

	set choice = TalentChoiceCreateBoolean(2)
	set udg_TalentChoiceHead[choice] = "Hemorrhage"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Rogue_Garrote.blp"
	set udg_TalentChoiceText[choice] = "Garrote's scaling damage is increased to 4x Bonus Agility."

	set choice = TalentChoiceCreateSustain(0, 0, 4)
	set udg_TalentChoiceHead[choice] = "Increased Armor"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNLeatherUpgradeOne.blp"


	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)

	// set choice = TalentChoiceCreateBoolean(3)
	// set udg_TalentChoiceHead[choice] = "Lock Pick"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMoonKey.blp"
	// set udg_TalentChoiceText[choice] = "All gates and other locked features automatically open when you pass by. "

	set choice = TalentChoiceCreateBoolean(3)
	set udg_TalentChoiceHead[choice] = "Loot and Plunder"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNChestOfGold.blp" //BTNPillage.blp
	set udg_TalentChoiceText[choice] = "Gain up to 30% extra gold on all kills"

	set choice = TalentChoiceCreateBoolean(4)
	set udg_TalentChoiceHead[choice] = "Cheap Shots"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNShurikenRed.blp"
	set udg_TalentChoiceText[choice] = "Shurikens now briefly slow enemies for 0.5 sec on the way out and back"

	set choice = TalentChoiceCreateImproveSpell('A017', -25, -2.5)
	set udg_TalentChoiceHead[choice] = "Reduced Costs on Eviscerate"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Rogue_Eviscerate.blp"

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpellBasedOnUnitType('A09U','A06I', 'E035',true)	//Night Stalk
	call TalentChoiceCreateAddSpell('A0EZ',true) //Roll the Bones
	call TalentChoiceCreateAddSpell('A0F0',true) //Fire the Cannons 

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateBoolean(9)
	set udg_TalentChoiceHead[choice] = "Shield Break"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBreakingSmash.blp"
	set udg_TalentChoiceText[choice] = "Deal 200% bonus damage to shields"
	// set choice = TalentChoiceCreateBoolean(9)
	// set udg_TalentChoiceHead[choice] = "Find Weakness"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBreakingSmash.blp"
	// set udg_TalentChoiceText[choice] = "Garrote now reduces the enemy's armor by 12 for 3 sec."
	// set choice = TalentChoiceCreateBoolean(9)
	// set udg_TalentChoiceHead[choice] = "Killing Spree"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Rogue_Eviscerate.blp"
	// set udg_TalentChoiceText[choice] = "Killing an enemy instantly resets the cooldown on Eviscerate and awards 40 mana."

	set choice = TalentChoiceCreateBoolean(10)
	set udg_TalentChoiceHead[choice] = "Ruthlessness"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFocusedAttacks.blp" //Ability_Druid_Disembowel
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
	set udg_TalentChoiceHead[choice] = "Cheat Death"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNCheatDeath.blp"
	set udg_TalentChoiceText[choice] = "Fatal attacks instead reduce you to 7% of your maximum health. For 3 sec afterward, you take 93% reduced damage. Cannot trigger more often than once per 60 sec."

	set choice = TalentChoiceCreateAddAndHideSpell('ACce','ACce', false)
	set udg_TalentChoiceHead[choice] = "Blade Furry"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNArcaniteMelee.blp"
	set udg_TalentChoiceText[choice] = "Your attacks now damage nearby enemies for 35% of the damage"

	//LEVEL 50
	
	// Ultimate Boost -
	    //Night Stalk - now lasts for 30 sec
        //Fire the Cannons - cooldown reduced by 20 sec
		//Snake Eyes - Roll the Bones has 33% chance to grant all 3 buffs
	// Stacked the Deck - Every 3rd card roll the bones now grants all 3 buffs, their effects are still proportional to the number of combo points spent
	//Rigged Dice - Roll the Bones has increased chance to grant heal at low HP, and other buffs at high hp	

	//Between the eyes - Finishing move that deal damage from afar, knocking back and breifly stunning them (Replaces Eviscerate) 
		//the closer the rogue is to the target it will knock both the rogue and the target back upto 250 distance
	//Grappling Hook - Replaces Death sentence, can now be targeted anywhere and roots all enemies in a small area



	//Combat Potency - you have a 30% chance to regain 10 mana whenever dealing damage
	
	//Killing Spree - Killing an enemy instantly resets the cooldown on Eviscerate
	//Dirty Tricks - certain spells no longer cost mana

	//Hunger for blood - Deal increased damage to targets with a bleed effect
	// https://wowpedia.fandom.com/wiki/Hunger_for_Blood
	//https://www.hiveworkshop.com/threads/hunger-for-blood.333521/


endfunction

//===========================================================================
function InitTrig_Talent_Combat_Rogue takes nothing returns nothing
    set gg_trg_Talent_Combat_Rogue = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Combat_Rogue, function TalentCombatRogue )
    call TalentHeroSetCopy('E01O', 'E035')	
	//Morphs
	//WR
	call TalentHeroSetCopy('E01T', 'E035')
	call TalentHeroSetCopy('E01Y', 'E035')
	call TalentHeroSetCopy('E01Z', 'E035')
	call TalentHeroSetCopy('E01V', 'E035')
	call TalentHeroSetCopy('E01X', 'E035')
	call TalentHeroSetCopy('E020', 'E035')
	call TalentHeroSetCopy('E01W', 'E035')
	call TalentHeroSetCopy('E01U', 'E035')
	//UR
	call TalentHeroSetCopy('E036', 'E035')
	call TalentHeroSetCopy('E03A', 'E035')
	call TalentHeroSetCopy('E03B', 'E035')
	call TalentHeroSetCopy('E037', 'E035')
	call TalentHeroSetCopy('E039', 'E035')
	call TalentHeroSetCopy('E038', 'E035')
	call TalentHeroSetCopy('E03C', 'E035')
	call TalentHeroSetCopy('E03D', 'E035')
endfunction
