function TalentFeralDruid takes nothing returns nothing
	local integer heroTypeId = 'E00F'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 
	//Add Hide to Cat form  (add a decription that the cat has passive crit and dodge and hide the crit ability)
	//Swap location Cat and Bear - Make Cat on D
	//Roar is on D (Maybe switch to T)

	//If unit picks a morphed druid then simply disable appropriate abilities for that player based on unit type

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpell('A02Z', - 20, - 1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Costs on Moonfire"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNStarfall.blp"

	set choice = TalentChoiceCreateBoolean(1)
	set udg_TalentChoiceHead[choice] = "Strangling Roots"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNEntanglingRoots.blp"
	set udg_TalentChoiceText[choice] = "Entanging Roots now deals 1x Bonus Intelligence per second"

	set choice = TalentChoiceCreateBoolean(2)
	set udg_TalentChoiceHead[choice] = "Innervate"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_Nature_Lightning.blp"
	set udg_TalentChoiceText[choice] = "Rejuvination now also restores mana equal to 25% of the health restored"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	//Bear
	set choice = TalentChoiceCreateBoolean(3) 
	set udg_TalentChoiceHead[choice] = "Starfire"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNStarfall_WoW.blp" //BTNMoonFlare
	set udg_TalentChoiceText[choice] = "Targets with moonfire now take 10% increased damage from you while they have the debuff."
	
	//Both  
	set choice = TalentChoiceCreateBoolean(4)
	set udg_TalentChoiceHead[choice] = "Blessing of Elune"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNRejuvenation.blp"
	set udg_TalentChoiceText[choice] = "Rejuvination now heals for 20% more. This stacks with other healing bonuses."

	//Cat -- INCREASE MS
	set choice = TalentChoiceCreateBoolean(5)
	set udg_TalentChoiceHead[choice] = "Infected Wound"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Druid_Disembowel.blp"
	set udg_TalentChoiceText[choice] = "Rake now slows enemy attack and movement speed by 50% for 4 sec. |nAdditionally, it now scales off Total Agility for its periodic damage, 0.5 x (Base + Bonus)."

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddAndDisableSpell('A0CV', 'E00F', 'E02I', 0, 6, true)	 //Renewal
	call TalentChoiceCreateAddAndDisableSpell('A0E1', 'E00F', 'E02I', 0, 7, true)  //Travel Form
	call TalentChoiceCreateAddAndDisableSpell('A0E3', 'E00F', 'E02I', 0, 8, true)  //Survival Instints

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	//Bear 
	set choice = TalentChoiceCreateStatsWithBoolean(16, 0, 0, 9, "Maul now scales off Total Strength, 2.5 x (Base + Bonus)")
	set udg_TalentChoiceHead[choice] = "Strength of the Wild"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNStrengthOfTheWild.blp"

	//Both 
	set choice = TalentChoiceCreateBoolean(10)
	set udg_TalentChoiceHead[choice] = "Improved Thrash Damage"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Druid_Rake.blp"
	set udg_TalentChoiceText[choice] = "Thrash scaling increased to 6.5 x Bonus Agi/Str."
	
	//Cat 
	set choice = TalentChoiceCreateBooleanWithAddedFunction(11, 2)
	set udg_TalentChoiceHead[choice] = "Prowl"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNProwl.blp"
	set udg_TalentChoiceText[choice] = "Gain invisibility for 7 sec when shifting into Cat form, also gain the ability to Hide while in cat form."//"While hidden the druid regains 2.5% mana per second."

	// LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateStats(12, 12, 12)
	set udg_TalentChoiceHead[choice] = "Mark of the Wild"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMarkOfTheWild.blp"   

	//Both 
	set choice = TalentChoiceCreateBoolean(13)
	set udg_TalentChoiceHead[choice] = "Tooth and Claw"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNVampBlood.blp"
	set udg_TalentChoiceText[choice] = "Thrash now causes all enemies hit to bleed for an additional 33% magic damage over 3 sec."

	//Cat
	set choice = TalentChoiceCreateBoolean(14)
	set udg_TalentChoiceHead[choice] = "Predatory Swiftness"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPounce.blp"
	set udg_TalentChoiceText[choice] = "Killing a unit while morphed now grants a 50% movement and attack speed buff for 4 sec, and resets the cooldowns on Rip and Moonfire."
	
	// Refactor Druid to be the first one that scales off BASE stats

	//LEVEL 60
	// 	1. Greatly Inc hp in bear form, and roar now also reduces all damage done nearby enemies by 20% for 5 sec
	//Bear - Iron Fur - Reduce all incoming damage by 15% for 6 sec
	//https://www.hiveworkshop.com/threads/bear-bundle.328106/

	//Cat - [Feral Frenzy] - Channeled ability which supress for 3 sec causing them to take % health damage over 3 sec

	// 2. Ursocs Fury - Perm Inc str and agi each time you kill an enemy hero 10 lvls within ur own, up to 30 times
	//Tiger's Fury- When below 50% health deal 20% more damage
	//Rip and Tear - Rip now applies another DoT that deals an additional 20% of the total damage over 5 sec


	//Thrasher - reduces the cooldown of thrash by 1 sec, the mana cost by 50, and increases the damage by 20%

	//Defense of the Ancients - Gain 650 Health and Mana, Casting your ultimate now grants you a shield for 20% max health for 6 sec	

	//BTNEnchantedBears.blp
	//Bear - Demoralizing Roar, roar now also reduces the damage of all nearby enemies by 25% for 5 sec
	//Both - [Remove Corruption] Rejuvination now removes negative buff
	//Bear - Iron Fur - Reduce all incoming damage by 15% for 6 sec
	//Bear - [Ursocs Fury] - Each time you kill an enemy hero 10 lvls within ur own, gain 2% permanent strength, up to 30 times
	//Cat - [Tiger's Fury] - When below 50% health deal 15% more damage for 6 sec
	
	//Cat - increased duration on bleeds or increase base crit chance to 50%

		// 3. Cat Attack - The base damage of rip is increased to 700 and 100% crit chance
	//Rip + Agility x Number of Dots, Shred 120 + 1x bonus agi
	
	


endfunction

//===========================================================================
function InitTrig_Talent_Feral_Druid takes nothing returns nothing
	set gg_trg_Talent_Feral_Druid = CreateTrigger()
	call TriggerAddAction(gg_trg_Talent_Feral_Druid, function TalentFeralDruid )
	call TalentHeroSetCopy('E02I', 'E00F')
	//Morphs
	call TalentHeroSetCopy('E00G', 'E00F')
	call TalentHeroSetCopy('E00I', 'E00F')
	call TalentHeroSetCopy('E00L', 'E00F')
	call TalentHeroSetCopy('E013', 'E00F')
	call TalentHeroSetCopy('E00O', 'E00F')
	call TalentHeroSetCopy('E014', 'E00F')
	call TalentHeroSetCopy('E00K', 'E00F')
	call TalentHeroSetCopy('E00M', 'E00F')
	call TalentHeroSetCopy('E00J', 'E00F')
	call TalentHeroSetCopy('E00N', 'E00F')
	call TalentHeroSetCopy('E011', 'E00F')
	call TalentHeroSetCopy('E012', 'E00F')
	call TalentHeroSetCopy('E02P', 'E00F')
	call TalentHeroSetCopy('E02Q', 'E00F')
	call TalentHeroSetCopy('E02R', 'E00F')														
	call TalentHeroSetCopy('E02S', 'E00F')
	call TalentHeroSetCopy('E02T', 'E00F')
	call TalentHeroSetCopy('E02U', 'E00F')
	call TalentHeroSetCopy('E02J', 'E00F')
	call TalentHeroSetCopy('E02K', 'E00F')
	call TalentHeroSetCopy('E02L', 'E00F')
	call TalentHeroSetCopy('E02M', 'E00F')
	call TalentHeroSetCopy('E02N', 'E00F')
	call TalentHeroSetCopy('E02O', 'E00F')
endfunction


	