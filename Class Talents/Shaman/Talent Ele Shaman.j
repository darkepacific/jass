function TalentEle_Shaman takes nothing returns nothing
	local integer heroTypeId = 'O006'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	set choice = TalentChoiceCreateBoolean(0) 
	set udg_TalentChoiceHead[choice] = "Lava Burst"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNLavaBurst.blp"
	set udg_TalentChoiceText[choice] = "Aftershock now crits for an additional 1 x Agility"

	set choice = TalentChoiceCreateImproveSpell('AOcl', -25, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Chain Lightning"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNChainLightning.blp"

	set choice = TalentChoiceCreateBoolean(1) 
	set udg_TalentChoiceHead[choice] = "Strikes Twice"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNMonsoon.blp"
	set udg_TalentChoiceText[choice] = "Increase Chain Lightning's chance to Strike Twice by 8%"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)

	//Astral Recall
	set choice = TalentChoiceCreateBoolean(3) 
	set udg_TalentChoiceHead[choice] = "Astral Recall"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAstralRecal.blp"
	set udg_TalentChoiceText[choice] = "Hearthstone's cooldown is reduced by 45 sec"
	
	//Magma Totem
	set choice = TalentChoiceCreateBoolean(4) 
	set udg_TalentChoiceHead[choice] = "Magma Totem"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSelfDestruct.blp"
	set udg_TalentChoiceText[choice] = "Searing totems now unleash a fire nova around them when first placed dealing |cffffcc0050|r + |cffffcc002|r x |cc00099FFIntelligence|r Damage to all surrounding enemies."

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

	//Lord of the Wards
	set choice = TalentChoiceCreateBoolean(9) 
	set udg_TalentChoiceHead[choice] = "Lord of the Wards"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSentryWard.blp"
	set udg_TalentChoiceText[choice] = "Totems now last twice as long"

	//Totemic Recall
	set choice = TalentChoiceCreateBoolean(10) 
	set udg_TalentChoiceHead[choice] = "Totemic Recall"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNTotemicRecall.blp"
	set udg_TalentChoiceText[choice] = "When one of your totems die refund 80% of it's mana cost and reduce it's remaining cooldown by half"


	set choice = TalentChoiceCreateBoolean(11) 
	set udg_TalentChoiceHead[choice] = "Spiritwalker's Grace"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpiritWalkers.blp"
	set udg_TalentChoiceText[choice] = "Increases Movement speed by 50% for 3 sec after using Thunderstorm"

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)

	//Earth Grab
	set choice = TalentChoiceCreateBoolean(12) 
	set udg_TalentChoiceHead[choice] = "Earth Grab"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNEntanglingRoots.blp"
	set udg_TalentChoiceText[choice] = "Searing ward now slows all nearby enemies for 50% for 3 sec when first placed"
	
	//Echo of the Elements
	set choice = TalentChoiceCreateBoolean(14) 
	set udg_TalentChoiceHead[choice] = "Echo of the Elements"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNEchooftheElements.blp"
	set udg_TalentChoiceText[choice] = "Gain 20% base Critical Strike chance on Aftershock, Thunderstorm, and Chain Lightning. This stacks with any other crit effects these spells already have, and ignores any other requirements they may have in order to crit."

	set choice = TalentChoiceCreateStats(0, 20, 0)
	set udg_TalentChoiceHead[choice] = "Overwhelming: AGI"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAgi.blp"

	//50

	// Statis Totem - Gain the statis totem ability, which when placed will stun all nearby enemies for 2 sec. This ability has a 60 sec cooldown
	// Nature's Guardian - gain a shield when reduced below 30% health for 25% of your max hp for 3 sec,
	// Elemental Blast - After a brief 0.5s channel fire a giant bolt of lightning in a straight line damaing all enemies hits. Replaces chain lightning and benefits from all previous talent buffs to chain lightning.
	// Ascendance -- transforms you into a fire ascendant, replacing chain lightning with lava which deals 50% more damage

	// Elemental Resilience - Every 5th spell cast heal for 10% of your max hp
	// Ancestral Guidance - 12% of your damage is converted to self healing
	
	// Farsight
	// Elemental Mastery - 20% increased damage for 10 sec

endfunction

//===========================================================================
function InitTrig_Talent_Ele_Shaman takes nothing returns nothing
    set gg_trg_Talent_Ele_Shaman = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Talent_Ele_Shaman, function TalentEle_Shaman )
    call TalentHeroSetCopy('O00R', 'O006')
endfunction


