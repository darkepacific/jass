function TalentDiscPriest takes nothing returns nothing
	local integer heroTypeId = 'H03J'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 	

	//Add atonment tooltip
	//USE TWO PW:S CAUSE DISC ONE NEEDS TO SAY APPLIES ATTONEMNT BUT HOLY ONE SHOULD NOT

	//Nerf Thass Fireball Dmg by 100
	//TWH Needs 2 Rev's based on East & Wst
	//Add fast drum troll music to Hint
	
	//Add Dynamic resizing trigger to reset units back to default size

	//75/6  > SWP is divisible by 6, would just KISS for now and do 75/6
	//Consider 90 > 720

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)
	//Reduced Mana Cost Penance
	//Reduced Cooldown Shadow Mend

	set choice = TalentChoiceCreateBoolean(0)
	set udg_TalentChoiceHead[choice] = "Stronger Penance"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPenance.blp"
	set udg_TalentChoiceText[choice] = "Increase the Healing and Damage on Penance by 20%. This stacks with other bonuses."

	set choice = TalentChoiceCreateImproveSpellWithBoolean('A08V', 0, -1.25, 1)
	set udg_TalentChoiceHead[choice] = "Reduced Cooldown on Mind Blast"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNUnholyFrenzy.blp"

	set choice = TalentChoiceCreateSustain(0, 250, 0)
	set udg_TalentChoiceHead[choice] = "Gain Bonus Mana"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNINV_Misc_Gem_Sapphire_02.blp"



	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateSustain(300, 0, 0)
	set udg_TalentChoiceHead[choice] = "Power Word: Fortitude"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPowerWordFortitude.blp"

	//Power of the Darkside, every time an enemy is damage by Penance, have a 25% chance to reset the cooldown on your shadow mend and mind blast
		//(will reset 57% of the time)

	set choice = TalentChoiceCreateBoolean(4)
	set udg_TalentChoiceHead[choice] = "Evangelism"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAtonement.blp"
	set udg_TalentChoiceText[choice] = "Increase the effectiveness of Atonement by 20%."

	set choice = TalentChoiceCreateBoolean(5)
	set udg_TalentChoiceHead[choice] = "Symbol Of Hope"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSymbolOfHope.blp"
	set udg_TalentChoiceText[choice] = "Casting Shadow Mend on the same ally twice in a row now restores 8% of their maximum mana."
	

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)
	// TalentChoiceCreateAddAndHideSpell
	call TalentChoiceCreateAddSpell('A08Z', true) //Psychic Scream  -- 
	call TalentChoiceCreateAddSpell('A0FP', true) // Pain Suppression - Reduces all damage taken by a friendly target by 40% for 8 sec, ahd applies atonement
	call TalentChoiceCreateAddSpell('A0FT', true)// Power Word: Barrier

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)
	set choice = TalentChoiceCreateBoolean(9)
	set udg_TalentChoiceHead[choice] = "Silence"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNability_priest_silence.blp"
	set udg_TalentChoiceText[choice] = "Shadow Mend now silences targets for 2 sec. Heroes 1 sec."

	set choice = TalentChoiceCreateBoolean(10)
	set udg_TalentChoiceHead[choice] = "Desperate Prayer"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDesperatePrayer.blp"
	set udg_TalentChoiceText[choice] = "When lowered below 25% health, instantly heal for 25% of max health and increases your max HP by the same amount for 6s, this effect has a 45s cooldown"

	set choice = TalentChoiceCreateBoolean(11)
	set udg_TalentChoiceHead[choice] = "Innerfire"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNInnerFire.blp"
	set udg_TalentChoiceText[choice] = "Power Word: Shield now also applies inner fire increasing the target's armor by 25 and attack damage by 20%"

	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)

	set choice = TalentChoiceCreateBoolean(13)
	set udg_TalentChoiceHead[choice] = "Shadow Word: Death"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNShadowWordDeath.blp"
	set udg_TalentChoiceText[choice] = "Shadow Mend now instantly deals an additional 4 x Total Intelligence (Base + Bonus) magic damage when cast on targets with less than 33% hp."

	set choice = TalentChoiceCreateReplaceAndImproveSpell('A08V', 'A0FO', 0, -1.25, 1)
	set udg_TalentChoiceHead[choice] = "Renounce Darkness"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNHolyNova.blp"
	set udg_TalentChoiceText[choice] = "Replace Mind Blast with Holy Nova. Benefits from all previous talent buffs to Mind Blast."

	set choice = TalentChoiceCreateRegen(15.0, 15.0, 0, 0)
	set udg_TalentChoiceHead[choice] = "Divine Spirit"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDivineSpirit.blp"


	//LEVEL 50

	//Shrink Ray - penance now reduce's the enemy's damage by 20%
	//Halo - Send out a halo of light healing all allies the halo then bounces back at it full range damaging enemyes in its path.
	//Prayer of Mending - the next time an ally with shadowmend takes damage, the shadowmend spreads to another nearby ally healing them and also applying atonement. This effect has a 4 sec cooldown once triggered by any ally.
	//Power of the Darkside - increase all damage you deal by 25%
	
	//Power Word Shield's movement bonus is now increase to 40% and last for 4s

	//Masochism - When you cast Shadow Mend on yourself, its damage over time effect heals you instead, and reduces all damage you take by 10%.
	//Shadowy Tendril Casting X,Y,Z or Killing a unit causes a shadowy tendril to spawn nearby attacking all enemies. Lasts 5 sec.
	//Blaze of Light - the damage of penance is increased by 15% and it now increases or descreases the target's movement speed by 25%
	//Strenght of Soul - Power Word: Shield now reduces all incoming physical damage on the target by 15%
	//Power of the Darkside, every time an enemy is damage by you that has the SW:Pain buff, have a 20% chance to reset the cooldown on your penance


	//Affliction Purple
	//Green Heal recolored to purple
	//Metamorphosis
	//Psionic Shot Purple if death == stand
	//Radiance Silver & Holy
	//Righteous Guard - Death
	//Singulariy Purple /Orange/Blue
	//Singulariy II Orange
	// Void Disc - Death
	//Void Ball - Death

	//Resource Effect Target
	//Healing Salve (Might be good for atonement)
	//Spirit Link (Stand)
	//Proc Missile - Death  // Birth too overhead (Item attack slow)
	//BarkSkin


	//Item Illusions (ShadowMend)
	//Item Str Gain
	//Item Int Gain
	//Item temporary Area armor bonus
	//Ray of Disruption (Holy)
	//Gold Bottle Missile Death
	//Staff Sanctuary (Shield) & Scroll of Protection

	

endfunction

//===========================================================================
function InitTrig_Talent_Disc_Priest takes nothing returns nothing
	set gg_trg_Talent_Disc_Priest = CreateTrigger(  )
	call TriggerAddAction( gg_trg_Talent_Disc_Priest, function TalentDiscPriest )
	call TalentHeroSetCopy('H03I', 'H03J')	
endfunction
