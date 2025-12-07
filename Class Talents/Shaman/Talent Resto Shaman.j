function TalentResto_Shaman takes nothing returns nothing
	local integer heroTypeId = 'O00N'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateBoolean(0) 
	set udg_TalentChoiceHead[choice] = "Earth Shock now crits"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNEarthShock.blp"
	set udg_TalentChoiceText[choice] = "Earth shock now crits for 3x Int if the target is slowed."

	set choice = TalentChoiceCreateBoolean(1) 
	set udg_TalentChoiceHead[choice] = "Strikes Twice"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMonsoon.blp"
	set udg_TalentChoiceText[choice] = "Chain Lightning has a 8% increase chanced to Strike Twice"

	
	set choice = TalentChoiceCreateImproveSpell('A0AD', -25, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Riptide"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNRiptide.blp"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)

	//Astral Recall
	set choice = TalentChoiceCreateBoolean(3) 
	set udg_TalentChoiceHead[choice] = "Astral Recall"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAstralRecal.blp"
	set udg_TalentChoiceText[choice] = "Hearthstone's cooldown is reduced by 45 sec"

	//Mana Tide
	set choice = TalentChoiceCreateBoolean(4) 
	set udg_TalentChoiceHead[choice] = "Manatide"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNManaTotem.blp"
	set udg_TalentChoiceText[choice] = "Healing Ward now also regenates 25 mana per sec for nearby allies"

	//Wellspring Vitality
	set choice = TalentChoiceCreateRegen(4.0, 4.0, 0, 0)
	set udg_TalentChoiceHead[choice] = "Increased Regen"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNWellSpring.blp"	
	

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)

	call TalentChoiceCreateAddSpell('A03A',true) //Bloodlust
	call TalentChoiceCreateAddSpell('A0DO',true) //Elemental Lord
	call TalentChoiceCreateAddSpellWithBoolean('A0G4', true, 8) //Ancestral Spirit

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)

	//Lord of the Wards
	set choice = TalentChoiceCreateBoolean(9) 
	set udg_TalentChoiceHead[choice] = "Lord of the Wards"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSentryWard.blp"
	set udg_TalentChoiceText[choice] = "Wards now last twice as long"

	//Totemic Recall
	set choice = TalentChoiceCreateBoolean(10) 
	set udg_TalentChoiceHead[choice] = "Totemic Recall"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNTotemicRecall.blp"
	set udg_TalentChoiceText[choice] = "When one of your wards dies refund 80% of it's mana cost and reduce it's remaining cooldown by half"
	
	//Spirit Walker's Grace
	set choice = TalentChoiceCreateImproveSpellWithBoolean('A0AE', -25, 0, 11) 
	set udg_TalentChoiceHead[choice] = "Spiritwalker's Grace"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpiritWalkers.blp"
	set udg_TalentChoiceText[choice] = "Increases move speed by 50% for 4 sec when entering ghost wolf and the mana cost is removed."


	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)

	//High Tide
	set choice = TalentChoiceCreateBoolean(12) 
	set udg_TalentChoiceHead[choice] = "Chain Heal"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHealingWave.blp"
	set udg_TalentChoiceText[choice] = "Healing wave bounces to 1 additional target and it's fall off is reduced by half. |n|nDoes not apply to crit effects."

	//Torrent
	set choice = TalentChoiceCreateBoolean(13)
	set udg_TalentChoiceHead[choice] = "Torrent"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNCrushingWave.blp"
	set udg_TalentChoiceText[choice] = "Riptide now heals for 30% more. Stacks with other healing bonuses." 
	
	//Echo of the Elements
	set choice = TalentChoiceCreateBoolean(14) 
	set udg_TalentChoiceHead[choice] = "Echo of the Elements"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNEchooftheElements.blp"
	set udg_TalentChoiceText[choice] = "Gain 20% base Critical Strike chance on Earth Shock, Chain Lightning, and Healing Wave. This stacks with any other crit effects these spells already have, and ignores any other requirements they may have in order to crit."

	//50
	
	// Statis Totem - Gain the statis totem ability, which when placed will stun all nearby enemies for 2 sec. This ability has a 60 sec cooldown
	//Ascendance -- transforms you into water ascendant causing your healing abilities to cost no mana for the next 6s and reducing their cd's by an aditional 20%
	//Healing Rain - heales allies for hp each sec
	//Totem of the Tides - 2min cooldown drop a powerful totem that restores allies for 10% of their max hp and mana each sec for 4 sec
	//Nature's Guardian - gain a shield when reduced below 30% health for 25% of your max hp for 3 sec,
		//AncestralGuidance  - 12% of your damage is converted to self healing
	//Nature's Swiftness - activate your next healing ability costs no mana and has no cooldown.



endfunction

//===========================================================================
function InitTrig_Talent_Resto_Shaman takes nothing returns nothing
    set gg_trg_Talent_Resto_Shaman = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Resto_Shaman, function TalentResto_Shaman )
    call TalentHeroSetCopy('O00G', 'O00N')
	//Morphs
	call TalentHeroSetCopy('E00R', 'O00N')
	call TalentHeroSetCopy('E00S', 'O00N')
	call TalentHeroSetCopy('E00T', 'O00N')
	call TalentHeroSetCopy('E00U', 'O00N')
	call TalentHeroSetCopy('E03T', 'O00N')
	call TalentHeroSetCopy('E03U', 'O00N')
endfunction


