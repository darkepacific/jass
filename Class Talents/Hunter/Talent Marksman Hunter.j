function TalentMarksmanHunter takes nothing returns nothing
	local integer heroTypeId = 'E03K'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateImproveSpell('A0A3', - 20, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Pounce"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPounce.blp"

	set choice = TalentChoiceCreateImproveTwoSpells('A0A2', 'A065', 0, -2.0, 1)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Multi-Shot"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNUpgradeMoonGlaive.blp"
	set udg_TalentChoiceText[choice] = "Multi-Shot  Cooldown: -2.0"

	set choice = TalentChoiceCreateImproveSpell('A05M', 0, - 1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Arcane Shot"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNImpalingBolt.blp"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateBoolean(3) 
	set udg_TalentChoiceHead[choice] = "Run Kitty Run"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpell_Holy_BlessingOfAgility.blp"
	set udg_TalentChoiceText[choice] = "Gain 15% increase movement speed for 2.5 sec when pouncing away from an enemy"

	set choice = TalentChoiceCreateBoolean(4) 
	set udg_TalentChoiceHead[choice] = "Disengage"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Rogue_Feint.blp"
	set udg_TalentChoiceText[choice] = "Pounce now travels backwards and gains 60 extra distance"

	set choice = TalentChoiceCreateStats(0, 0, 12)
	set udg_TalentChoiceHead[choice] = "Magical Boost: Int"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPipeOfInsight.blp"

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)

	//Make Feign Death F
	call TalentChoiceCreateAddSpell('A0A4', true) //Feign Death
	call TalentChoiceCreateAddSpell('A0ED', true) //Bursting Shot
	call TalentChoiceCreateAddSpell('A0EI', true) //Freezing Trap

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateImproveSpellWithBoolean('A0A3', 0, -1.0, 9) 
	set udg_TalentChoiceHead[choice] = "Posthaste"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPosthaste.blp"
	set udg_TalentChoiceText[choice] = "Pounce removes all negative debuffs and grants magic immunity while jumping. It's cooldown is also reduced. |n|nCooldown: -1.0"

	set choice = TalentChoiceCreateBoolean(10) 
	set udg_TalentChoiceHead[choice] = "Master of the Arcane"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNStarfall_WoW.blp"
	set udg_TalentChoiceText[choice] = "Killing a Unit with Arcane Shot now also resets it's cooldown and restores twice as much mana"

	set choice = TalentChoiceCreateStats(0, 20, 0)
	set udg_TalentChoiceHead[choice] = "Overwhelming: AGI"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAgi.blp"

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)

	set choice = TalentChoiceCreateBooleanWithImproveWeapon(12, 135)
	set udg_TalentChoiceHead[choice] = "Bonus Damage on Multi-Shot"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNImprovedBows.blp"
	set udg_TalentChoiceText[choice] = "Increase base Attack Damage by 135 while using Multi-Shot."

	//True Shot - Gain an ability that resets the cooldown of all shot spells

	// set choice = TalentChoiceCreateImproveStatWithBoolean(2, 0, 85, 0.0, 0.0, 12)
	// set choice = TalentChoiceCreateBoolean(12)
	// set udg_TalentChoiceHead[choice] = "Increased Damage"
	// set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNImprovedBows.blp"
	// set udg_TalentChoiceText[choice] = "Increase base Attack Damage by 85."

	set choice = TalentChoiceCreateAddAndHideSpell('A0DH','A08Y', false)
	set udg_TalentChoiceHead[choice] = "Hunter's Mark"
	set udg_TalentChoiceText[choice] = "Gain the Hunter's Mark, an ability that marks an enemy giving vision of them and reducing their armor."
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHuntersMark.blp"

	set choice = TalentChoiceCreateAddAndHideSpell('AEst','A08Y', false)
	set udg_TalentChoiceHead[choice] = "Owl Scout"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNScout.blp"
	set udg_TalentChoiceText[choice] = "Gain the Scout ability, allowing the ability to scout the map and detect invisible units"
		// the owl also provides the aspect of the hawk aura to nearby allies.	

	// Level 50

	//[Camouflage] - gain shadowmeld, while melded gain 15 hp regen/sec
	//Moon Sight - Arcane shot now tags targets with a debuff, for the next 3 sec all damage done to that target is increased by 15%
		//https://www.hiveworkshop.com/threads/peekays-moonsight.202089/
		//https://www.hiveworkshop.com/threads/moon-disc.261581/
	//Piercing Shot - Arcane shot now hits all enemies in a line and its damage scaling is increased to 3 x Int
		//BTN Rogue CheapShot
	//Killshot - When a target is below 20% health, your Arcane deals 20% more damage
	//Chimaera Shot - Arcane shot now fires a second shot at a second target, dealing 50% of its initial damage

	//If volley kills a unit, reset its cooldown (Takes damage is within X of Volley point), & killing unit == channeler
	//[Flare] - reveals all invisible enemies
	//[Aspect of the Turtle] - Replaces aspect of the hawk, gain a shield that reduces all incoming damage by 30%
	//[Chimaera Shot] - A two-headed shot that hits your primary target and another nearby target (replaces arcane shot) (OR) hits all enemies in a line

	//Trueshot Aura - gain access to true shot aura, increasing ranged attack damage of nearby allies
	//Trueshot - Resets the cooldown of all abilities of arcane shot, multi-shot, volley, and bursting shot (if currently not active)

	//Arcane Volley - replace arcane shot with an ability that fires 5 arcane shots in a cone, dealing 50% of the initial damage
	//Pinning Shot - Fire and arrow that pushes an enemy back, if they collide with terrain or destructables they are stunned for 1.5 sec and take bonus damage
endfunction

//===========================================================================
function InitTrig_Talent_Marksman_Hunter takes nothing returns nothing
	set gg_trg_Talent_Marksman_Hunter = CreateTrigger(  )
	call TriggerAddAction( gg_trg_Talent_Marksman_Hunter, function TalentMarksmanHunter )
	call TalentHeroSetCopy('E03Y', 'E03K')	
	//Morphs
	call TalentHeroSetCopy('E03M', 'E03K')
	call TalentHeroSetCopy('E03N', 'E03K')	
	call TalentHeroSetCopy('E03L', 'E03K')	
	call TalentHeroSetCopy('E03O', 'E03K')	
	call TalentHeroSetCopy('E03P', 'E03K')	
	call TalentHeroSetCopy('E03Q', 'E03K')	
	call TalentHeroSetCopy('E03R', 'E03K')	
	call TalentHeroSetCopy('E03S', 'E03K')		
	call TalentHeroSetCopy('E00D', 'E03K')
	call TalentHeroSetCopy('E042', 'E03K')
	call TalentHeroSetCopy('E043', 'E03K')	
	call TalentHeroSetCopy('E044', 'E03K')	
	call TalentHeroSetCopy('E045', 'E03K')	
	call TalentHeroSetCopy('E046', 'E03K')			
	call TalentHeroSetCopy('E047', 'E03K')	
	call TalentHeroSetCopy('E048', 'E03K')	
endfunction