function TalentBalDruid takes nothing returns nothing
	local integer heroTypeId = 'E00C'
	local integer choice
	local integer abilityId
	local string  addTxt = "|n|n|cffc0c0c0Also grants access to Starfall in Moonkin form and Tranquility in Treant form.|r"

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//Trees need to ramp up with a bloodlust style buff (stacking up to 3 times)
	//if unit type == tree, wait 1.0 sec check if still has buff, else skip

	//Add to typhoon Druid https://www.hiveworkshop.com/threads/arcanetowerattack.49956/ (ON unit hit)

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpell('A0D0', -20, -1.0)
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
	//Moon 
	set choice = TalentChoiceCreateBoolean(3) 
	set udg_TalentChoiceHead[choice] = "Starfire"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNStarfall_WoW.blp"
	set udg_TalentChoiceText[choice] = "Targets with moonfire now take 10% increased damage from you while they have the debuff."
	
	//Both  
	set choice = TalentChoiceCreateBoolean(4)
	set udg_TalentChoiceHead[choice] = "Blessing of Elune"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNRejuvenation.blp"
	set udg_TalentChoiceText[choice] = "Rejuvination now heals for 20% more. This stacks with other healing bonuses."

	//Tree  
	//set choice = TalentChoiceCreateBoolean(5)
	//set udg_TalentChoiceText[choice] = "Treants now grant allies Thorns Aura dealing 10% damage back to attackers"
	set choice = TalentChoiceCreateAddAndHideSpell('ACah','ACah', false)
	set udg_TalentChoiceHead[choice] = "Thorns Aura"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNThorns.blp"
	set udg_TalentChoiceText[choice] = "Passively gain access to Thorns Aura dealing 10% damage back to attackers."
	
	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	set choice = TalentChoiceCreateAddAndDisableSpell('A091', 'E00Z', 'E00C', 0 , 6 , true)	 //Renewal 
	set udg_TalentChoiceText[choice] = udg_TalentChoiceText[choice] + addTxt
	set choice = TalentChoiceCreateAddAndDisableSpell('A0E1', 'E00Z', 'E00C', 0 , 7 , true)  //Travel Form
	set udg_TalentChoiceText[choice] = udg_TalentChoiceText[choice] + addTxt
	set choice = TalentChoiceCreateAddAndDisableSpell('A0E4', 'E00Z', 'E00C', 0 , 8 , true)  //Typhoon
	set udg_TalentChoiceText[choice] = udg_TalentChoiceText[choice] + addTxt
	
	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	//Moon
	set choice = TalentChoiceCreateImproveSpellWithBoolean('A0CW', -35, -1.5, 9)
	set udg_TalentChoiceHead[choice] = "Reduced Costs on Eclipse"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNGenericSpellImmunity.blp"
	
	set choice = TalentChoiceCreateBoolean(10)
	set udg_TalentChoiceHead[choice] = "Swiftmend"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSwiftmend.blp"
	set udg_TalentChoiceText[choice] = "Using Rejuvination on a target that already has the buff immediately heals them for 20% of it's total amount, and reapplies the buff"

	set choice = TalentChoiceCreateBoolean(11)
	set udg_TalentChoiceHead[choice] = "Mass Entanglement"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMassEntanglement.blp"
	set udg_TalentChoiceText[choice] = "Entangling Roots now has a chance to hit up to 3 additional enemies near the primary target"

	//LEVEL 40
	//TREE LIGHTHING IS BUGGED
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateStats(12, 12, 12)
	set udg_TalentChoiceHead[choice] = "Mark of the Wild"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMarkOfTheWild.blp"  
	
	//Tree
	set choice = TalentChoiceCreateBoolean(13)
	set udg_TalentChoiceHead[choice] = "Flourish"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNReplenish.blp"
	set udg_TalentChoiceText[choice] = "The durations of Rejuvination and Wild Growth are increased by 3/2 sec"

	//Tree
	set choice = TalentChoiceCreateBoolean(14)
	set udg_TalentChoiceHead[choice] = "For the Trees"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNEnt.blp"
	set udg_TalentChoiceText[choice] = "When a treant dies a sappling takes it's place for 8 sec that has 50% of it's health and damage"

	//LEVEL 50

	//Moon - Cyclones knock up is increased to .5/1 sec in regular and  ecplise
		//Moon - Solar Power deals 20% increase damage to targets with moonfire
	//Moon - Stellar Drift - Ecplise now empowers Starfall causing the spell to cast 40% faster
	//Moon - Twin Moons - Moonfire hits 1 additional enemy
	
	//Moon - [Lunar Magic] - Damagine a target with Moonfire now refreshes the spell causing it to be recast on them automatically, 
		//this effect has a 3 second cooldown
	//Defense of the Ancients - Gain 650 Health and Mana, Casting Tranquility, Starfall, Travel Form, Renewal or Moonsoon now grants you a shield for 20% max health for 6 sec	
	//Tree - Cenarion Ward -While in Tree form Rejuvination now grants it's target a shield for 6 sec equal to 35% of the full heal amount to be healed

		//Revitalize - Return the spirit to a dead party member, reviving them with 50% health and mana
	//Invigorate - Immediately refresh the duration of your rejuvenate and wild growth, and instantly heal those affected by either for 200 health + 3xint
	//Ironbark  - reduce all incoming damage on a selected target by 20/30/40% for 4/6/8 seconds. Usable in all forms.


		//Both  - Renewal now scales off 6x Bonus Int
	//Both - [Remove Corruption] Rejuvination now removes negative buff

	//Tree - Abundance - Casting Rejuvination reduces the cooldown of Wild Growth by 1 sec (Check if ticks will be an issue)

	//Save for Druid of the nightmare - Everytime wild growth heals a treant, it now spawns a vine lasher, which attacks nearby enemies 
		//https://www.hiveworkshop.com/threads/pyrolia.48729/

	//Defense of the Ancients - Gain 650 Health and Mana, Casting your ultimate now grants you a shield for 20% max health for 6 sec	

	//Wellspring Vitality
	// set choice = TalentChoiceCreateRegen(15.0, 15.0, 450, 450)
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNWellSpring.blp"	
		


	//|nYou will also gain Starfall and Tranquility in Moonkin and Treant forms resepectively 
endfunction

//===========================================================================
function InitTrig_Talent_Bal_Druid takes nothing returns nothing
    set gg_trg_Talent_Bal_Druid = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Bal_Druid, function TalentBalDruid )
    call TalentHeroSetCopy('E00Z', 'E00C')
	//Morphs
	call TalentHeroSetCopy('E01C', 'E00C')
	call TalentHeroSetCopy('E010', 'E00C')
	call TalentHeroSetCopy('E022', 'E00C')
	call TalentHeroSetCopy('E02W', 'E00C')				
endfunction
