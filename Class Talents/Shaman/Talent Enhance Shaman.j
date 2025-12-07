function TalentEnhance_Shaman takes nothing returns nothing
	local integer heroTypeId = 'O00J'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//Update Spirit Wolf Descrip

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)

	set choice = TalentChoiceCreateImproveSpell('A08T', 0, -1.0)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown On Windfury"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNStormHammer.blp"

	set choice = TalentChoiceCreateImproveSpellWithBoolean('A08Q', -30, 0, 1)
	set udg_TalentChoiceHead[choice] = "Reduced Cost on Frost Shock"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNFrostshock.blp"
	set udg_TalentChoiceText[choice] = "Frost Shock, Mana cost: -30 |nAlso reduces the cost of Windfury Totem if it replaces this spell."

	set choice = TalentChoiceCreateImproveWeapon(0, 18, 0)
	set udg_TalentChoiceHead[choice] = "Increased Damage"
	set udg_TalentChoiceText[choice] = "Increase Base Attack Damage by 18"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpiritWalkerMasterTraining.blp"
	
	
	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	
	//Astral Recall
	set choice = TalentChoiceCreateBoolean(3) 
	set udg_TalentChoiceHead[choice] = "Astral Recall"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAstralRecal.blp"
	set udg_TalentChoiceText[choice] = "Hearthstone's cooldown is reduced by 45 sec"

	set choice = TalentChoiceCreateSustain(300, 0, 0)
	set udg_TalentChoiceHead[choice] = "Increased Health"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPhilosophersStone.blp"

	//Wellspring Vitality
	set choice = TalentChoiceCreateRegen(4.0, 4.0, 0, 0)
	set udg_TalentChoiceHead[choice] = "Increased Regen"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNWellSpring.blp"	

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)

	call TalentChoiceCreateAddSpell('A03A',true) //Bloodlust
	call TalentChoiceCreateAddSpell('A0DO',true) //Elemental Lord
	call TalentChoiceCreateAddSpell('AOr3',true) //Reincarnation


	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateBoolean(9) 
	set udg_TalentChoiceHead[choice] = "Earth Shield"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNEarthShield.blp"
	set udg_TalentChoiceText[choice] = "Increase the heal per attack on lightning shield to 3% Max HP"

	set choice = TalentChoiceCreateBoolean(10) 
	set udg_TalentChoiceHead[choice] = "Water Shield"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNWaterShield.blp"
	set udg_TalentChoiceText[choice] = "Lightning shield now restores 2% Max Mana to the target when attacked"

	set choice = TalentChoiceCreateBoolean(11) 
	set udg_TalentChoiceHead[choice] = "Fire Shield"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMoltenArmor.blp"
	set udg_TalentChoiceText[choice] = "Lightning Shield now creates a fire nova around the target when first cast dealing |cffffcc00100|r + |cffffcc002|r x |cc00099FFIntelligence|r Damage to all surrounding enemies."


	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	// set choice = TalentChoiceCreateBoolean(12) 
	set choice = TalentChoiceCreateImproveSpellWithBoolean('A08S', 0, -1.5, 12)
	set udg_TalentChoiceHead[choice] = "Cataclysm"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSundering.blp"
	set udg_TalentChoiceText[choice] = "Sundering now deals 9x Bonus Strength Damage and it's cooldown is reduced. |n|nCooldown: -1.5"

	set choice = TalentChoiceCreateReplaceAndImproveSpell('A08Q','A0DY', -30, 0, 1)
	set udg_TalentChoiceHead[choice] = "Windfury Totem"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNWindfury_Totem_Staff.blp"
	set udg_TalentChoiceText[choice] = "Replaces Frost Shock with Windfury Totem - a ward that grants increased movement and attack speed to all nearby allies. |nStacks with similar effects."

	set choice = TalentChoiceCreateStats(0, 20, 0)
	set udg_TalentChoiceHead[choice] = "Overwhelming: AGI"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAgi.blp"

	//50

	//Frost Fire  -- Frost shock now deals additional damage over time, equal to 8% the targets max hp
	//Ancestral Guidance - 12% of your damage is converted to self healing
	//Ascendance -- transforms you into an air ascendant

	//Nature's Guardian - gain a shield when reduced below 30% health for 25% of your max hp for 3 sec,


	//Fire Nova -- lightning shield now deals aoe int damage to enemies
	//Sundering -- now knocks units to the side as well
	//Earth Shield v2 -- now heals when any damage is taken
	//One with the pack -- turns you into a spirit wolf as well when you cast feral spirit


endfunction

//===========================================================================
function InitTrig_Talent_Enhance_Shaman takes nothing returns nothing
    set gg_trg_Talent_Enhance_Shaman = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Enhance_Shaman, function TalentEnhance_Shaman )
    call TalentHeroSetCopy('O00P', 'O00J')
endfunction


