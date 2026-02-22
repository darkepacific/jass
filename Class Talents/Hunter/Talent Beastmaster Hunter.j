function TalentBMHunter takes nothing returns nothing
	local integer heroTypeId = 'H00L'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//Agi 47:62:77
	//Int 64:90:116
	//Stampede, firelords (bool)
	//Check overall firelords/reaper issue with BM Hunter

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateBoolean(0) 
	set udg_TalentChoiceHead[choice] = "Bonus Damage on Serpent Strike"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAbility_Hunter_QS.blp"
	set udg_TalentChoiceText[choice] = "Now deals 5 x Bonus Agility on Initial Strike"

	set choice = TalentChoiceCreateImproveSpell('A00B', -35, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana on Concussive Shot"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNStun.blp"

	set choice = TalentChoiceCreateImproveSpell('A05M', 0, -1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Arcane Shot"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNImpalingBolt.blp"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)

	set choice = TalentChoiceCreateBoolean(3) 
	// set udg_TalentChoiceHead[choice] = "Hydra's Bite"
	//set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNCorrosiveBreath.blp"
	// set udg_TalentChoiceText[choice] = "Serpent Sting now fires arrows at 2 additional enemies near your target, but deals 30% less damage to each target."
	set udg_TalentChoiceHead[choice] = "Chimaera Shot"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNChimaeraShot.blp"
	set udg_TalentChoiceText[choice] = "Serpent Sting now fires an additional arrow near the primary target that deals 50% of it's initial damage"

	set choice = TalentChoiceCreateMovement(30)
	set udg_TalentChoiceHead[choice] = "Increased Movement Speed"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSeaGiantWarStomp.blp"

	//Master of the Arcane - Killing a Unit with Arcane Shot now also resets it's cooldown
	set choice = TalentChoiceCreateStats(0, 0, 12)
	set udg_TalentChoiceHead[choice] = "Magical Boost: Int"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPipeOfInsight.blp"
	
	
	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	call TalentChoiceCreateAddSpell('A02G',true) //Serpent Trap
	call TalentChoiceCreateAddSpell('A0EJ',true)  //Animal Companions
	call TalentChoiceCreateAddSpellBasedOnUnitType('A0DI','A0ET', 'H00L',true)  //Stampede, 2nd spell is BE's

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	//Inc to 85
	set choice = TalentChoiceCreateImproveWeapon(0, 85, 0)
	set udg_TalentChoiceHead[choice] = "Increased Damage"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHumanMissileUpOne.blp"
	// set udg_TalentChoiceText[choice] = "Increase base Attack Damage by 85"

	set choice = TalentChoiceCreateImproveRange(0, 300.0, 150.0 )
	set udg_TalentChoiceHead[choice] = "Increased Range" //Aspect of the Eagle //Eyes of the Beast
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNScout.blp"

    set choice = TalentChoiceCreateStats(0, 20, 0)
  	set udg_TalentChoiceHead[choice] = "Overwhelming: AGI"
   	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAgi.blp"
	//Maybe replace with //Killshot - When a target is below 20% health, your shot spells 20% more damage


	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	set choice = TalentChoiceCreateImproveWeapon(0, 0, -1.06)	//BM Base is 2.46/1.4 - 1 = 75%
	set udg_TalentChoiceHead[choice] = "Increased Attack Speed"
	set udg_TalentChoiceText[choice] = "Attack Speed: +75%"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNBloodlust.blp"

	set choice = TalentChoiceCreateAddAndHideSpell('A0DH','A0EO', false)
	set udg_TalentChoiceHead[choice] = "Hunter's Mark"
	set udg_TalentChoiceText[choice] = "Gain the Hunter's Mark, an ability that marks an enemy giving vision of them and reducing their armor."
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHuntersMark.blp"

	set choice = TalentChoiceCreateBoolean(14) 
	set udg_TalentChoiceHead[choice] = "Pack Mentality"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAspectofthePack.blp"
	set udg_TalentChoiceText[choice] = "Increases the health, armor, attack damage, and movement speed of your pets. |n|nEach pet gains:|n+500 hp, +4 Armor,|n+200 damage, +50 speed"


	//[Camouflage] - you and your pet blend in your surroundings, hides aspect of the hawk
	
	//Killshot - When a target is below 50% health, your Q,W,E do 50% more damage

	//[Rawr Dinosaurs] - Dev
		// Friends of the Wild - Summon an Extra Pet Based on the zone, replace your pet with a legendary one
		//gain the ability to summon a Devilsaur, a powerful pet that deals massive damage and can cast warstomp
		//DevilSaur - bear upgrade
		//Triceratops - turtle upgrade
		//Pterrodax - raptor upgrade
		
		
	//[Flare] - reveals an area for 30s, reveals stealth heroes
	// Revive Pets, reduces the cooldown on your pet summon abilities by 15s,
		// Note: (will require improving 21 abilities OR setting bool in CD Maths to -15 before calc)
	//[Aspect of the Turtle] - Hides  aspect of the hawk, gain a shield that reduces all incoming damage by 30%
	// Wing Clip - increases the slow on serpent sting to 50%



endfunction

//===========================================================================
function InitTrig_Talent_Beastmaster_Hunter takes nothing returns nothing
    set gg_trg_Talent_Beastmaster_Hunter = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Beastmaster_Hunter, function TalentBMHunter )
    call TalentHeroSetCopy('H003', 'H00L')	//'H003' uses the same talents as 'H00L'
endfunction


