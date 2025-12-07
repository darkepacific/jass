function TalentDemonHunter takes nothing returns nothing
	local integer heroTypeId = 'E02E'
	local integer choice
	local integer abilityId

	call TalentHeroSetFinalTier(heroTypeId, 50) 

	//LEVEL 5
	call TalentHeroTierCreate(heroTypeId, 5)

	set choice = TalentChoiceCreateBoolean(0)
	set udg_TalentChoiceHead[choice] = "Increased Scaling on Furious Gaze"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDH_Gaze.blp"
	set udg_TalentChoiceText[choice] = "Furious Gaze now deals damage equal to 5x Bonus Agility."

	set choice = TalentChoiceCreateImproveSpell('A08H', - 20, 0)
	set udg_TalentChoiceHead[choice] = "Reduced Mana Cost on Immolation"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNImmolationOn.blp"

	set choice = TalentChoiceCreateSustain(0, 0, 4)
	set udg_TalentChoiceHead[choice] = "Increased Armor"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNDATier2.blp"

	//LEVEL 10
	call TalentHeroTierCreate(heroTypeId, 10)
	set choice = TalentChoiceCreateBoolean(3)
	set udg_TalentChoiceHead[choice] = "Sweeping Strike Refunds Mana"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNUpgradeMoonGlaive.blp"
	set udg_TalentChoiceText[choice] = "If sweeping strike hits at least 2 enemies at the end of its path, 50% of its mana cost is refunded."

	set choice = TalentChoiceCreateBoolean(4)
	set udg_TalentChoiceHead[choice] = "Increased Mana Burned +150"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNManaBurn.blp"
	set udg_TalentChoiceText[choice] = "Furious Gaze burns an additonal 150 mana off targets."

	set choice = TalentChoiceCreateAddAndHideSpell('A0FY','A0FY', false)
	set udg_TalentChoiceHead[choice] = "Critical Chaos"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNChaosStrike.blp" 
	set udg_TalentChoiceText[choice] = "Gain 8% Base Crit Chance on attack. Stacks multiplicatively with items."

	//Level 20
	call TalentHeroTierCreate(heroTypeId, 20)

	call TalentChoiceCreateAddSpell('A08K', true) //Imprison
	call TalentChoiceCreateAddSpell('A0G2', true) //The Hunt - Dive to an enemy anywhere on the map and deal 200/300/400 + 3/4/5 x Agility on Arrival.
		//20 + 10, Grant Vis at start / Deny Vision at end, can't be dispelled
	call TalentChoiceCreateAddSpell('A0G0', true) // [Fiery Brand] - Brands an enemy with a mark reducing all damage they do to you by 30%, this includes pets and other minions they may own as well. After this expires or is dispelled gain a shield equal to the amount of dmg done to the branded target.
		//Supporting Talents for Firey Brand: Revel in Pain, Fiery Demise, Burning Alive, Charred Flesh
	

	//LEVEL 30
	call TalentHeroTierCreate(heroTypeId, 30)

	set choice = TalentChoiceCreateBoolean(9)
	set udg_TalentChoiceHead[choice] = "Consume Magic"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPurge.blp"
	set udg_TalentChoiceText[choice] = "Furious Gaze removes all buffs from the target, deals 800 bonus damage to summoned units, and slows movement speed for 2 sec. "

	set choice = TalentChoiceCreateAddAndHideSpell('A0G1','AEev', false)
	set udg_TalentChoiceHead[choice] = "Spectral Sight"
    set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSpectralSight.blp"
	set udg_TalentChoiceText[choice] = "|cffffcc00Active:|r Reveal all enemy units in a 3000 radius for 4 sec. |n|n|cffc0c0c0Hides evasion.|r"

	set choice = TalentChoiceCreateStats(0, 20, 0)
	set udg_TalentChoiceHead[choice] = "Overwhelming: AGI"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNAgi.blp"
	
	//LEVEL 40
	call TalentHeroTierCreate(heroTypeId, 40)
	//Unit learns/unleans talent if in demon form add or remove AD
	//DH 48s cd (20s as DEmon), so realy 28s cd - 205 dmg
	set choice = TalentChoiceCreateBooleanWithImproveWeapon(12, 200)
	set udg_TalentChoiceHead[choice] = "Bonus Damage in Demon Form"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNWarglaive_of_Azzinoth.blp"
	set udg_TalentChoiceText[choice] = "Increase base Attack Damage by 200 while in Demon form."

	set choice = TalentChoiceCreateRegen(10, 0, 600, 0) 
	set udg_TalentChoiceHead[choice] = "I Am My Scars"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNPhantomClaws.blp"

	set choice = TalentChoiceCreateBoolean(14)
	set udg_TalentChoiceHead[choice] = "Soul Rending"
	set udg_TalentChoiceIcon[choice] = "ReplaceableTextures\\CommandButtons\\BTNSoulRending.blp"
	set udg_TalentChoiceText[choice] = "Heal for 12% of all damage done." 	//8% to 16% - Increased while metamorphosis is active


	// Level 50
	// [Chaos Nova] - unleash an AoE nova stunning all enemies, OR Immolation Aura now slow enemies hit by 20%
	// [Blur] - increase the effectiveness of evasion to 100% for 3 sec. https://wowpedia.fandom.com/wiki/Blur
	// [Chaos Brand] - brand a target increase all damage they take by 8%
	// [Fel Spike] - Surge with power increasing your armor by 20
	// [Demonic Ward] (PAS) - Reduce all magic damage taken by 25%. Stacks with similar effects.
	// [Fel Rush] - Sweeping strike leaves a patch of fire behind that burns enemies
	// [Relentless Fury] - (PAS) Heal for 10% of all damage done
	// [Nether Walk] - Banish self, gaining movement speed and becomin immune to physical damage but taking increased damage from magic (Hides Evasion)
	// I am My Scars - each time you take damage increase your damage done by 0.5% up to 20%. This bonus lasts until leaving combat.
	// Sweeping strike can now crit enemies at the end of its path for 300% damage



	// Vengeance - Tank
	// [Breath Fire] (Instead of Eye Beam)
	// [Throw Glaive] - Richochet ability that taunts the primary target hit  (Re-activate to dash to target)
	// [Shattered Souls/Soul Cleave] Slain enemies sometimes drop soul fragments that heal you 20% - chance, Soul cleaves forces 2 of these to drop
	// [Soul Barrier] - Shield yourself for 12 sec, absorbing (5 * Attack power * Percent health) damage. Consumes all Soul Fragments within 25 yds to add (1 * Attack power * Percent health) to the shield per fragment.
	
	// Havoc - DPS
	// [Blade Dance] - Strike up to 5 nearby enemies become invulnerable while striking
		// Yi style ability that hits all enemies within an area (3 charges(over 13 iter), one at 225 to 45°, 315 to 135°, and one at current facing to facing 180°)
	// [Chaos Strike] - (Hides Evasion) Slice in front of you dealing damage and regain 25 mana for each enemy hit up to 75 total.
	// [Vengeful Retreat] - (Hides Evasion) vault backwards removing all negative effects

	// Future
	// [Eye Beam]  / [Throw Glaive] (Turns into [Infernal Strike] in metamorphosis form) 
	// [Immolation]  / (Chaos Nova - reactivate while immolation is active to stun or inital burst stuns) 
	//	 				(Agonizing flames - get a ms boost when using immolation)
	// [Evasion]           (Chaos Strike, hides evasion, swipe in front restoring mana. Demon Spikes, hide evasion gain an armor boost)
	// 					/ (Vengeful Retreat (Hides Evasion) - vault backwards removing all negative effects)
	// [Sweeping Strike]  / [Fel Devestation] (channeled heals for 40% of damage dealt)
	// [Metamorphosis]  

	//20's
	// Imprison / Imprison
	// Blade Dance / Fiery Brand 
	// The Hunt	 /  [Spirit Bomb], enemies  (Shattered Souls & Soul Cleave)


	//Talents
	//(SIGILS) - can be talents were abilities cause things to be left on ground, i.e. immolation leaves a sigil of flame
	// [Glave Tempest] - throw 2 glaves forward that cycle back and forth dealing damage each time and slowing enemies hit
	// [Darkness] - (Hides Evasion) Creates Darkness around you blinding all enemies causing them to miss 50% of the time. (Cloud effect) (Or just tick/dummy/blind aoe)




	// https://www.hiveworkshop.com/threads/metamorphosis.303148/
endfunction

//===========================================================================
function InitTrig_Talent_Demon_Hunter takes nothing returns nothing
	set gg_trg_Talent_Demon_Hunter = CreateTrigger(  )
	call TriggerAddAction( gg_trg_Talent_Demon_Hunter, function TalentDemonHunter )
	call TalentHeroSetCopy('E02C', 'E02E')	
	//Morphs
	call TalentHeroSetCopy('E02F', 'E02E')
	call TalentHeroSetCopy('Edmm', 'E02E')	
endfunction



//	Vengance ===========================================================================



//[Throw Glaive]&[Fel Blade] - Throw a glaive that bounces, then on recast charge to the target
// Immolation
//[Fracture]&[Soul Cleave] -- Physically slash in front of you cleaving two lesseer soul fragements
	// Visiscously strike up to 5 enemies in front of you, healing for 20% of the damage done, consumes up to two soul fragments to increase healing by for an additional 10% per fragment.
//Fel Devestation -- Unleash the fel within you, damaging enemies directly in front of you for Fire damage over 2 sec, and healing for 40% of the damage dealt. 
//Infernal Metamorphasis - Leap to a location, dealing damage to enemies in the area, will turn into a demon form for 15 sec


//Fiery Brand (Reduces the damage the enemy does to you)
//Imprison
//Place a Sigil of chains down, after 1 sec it activates pulling in all enemies dealing tones of damage and slowing by 70% them for 6 sec
	//Master of Sigils - Gain Options for 4 different sigils (Including Sigil of Chain)



// Demon Spikes -- increase armor and dodge chance



//Bulk Extraction  - Demolish the spirt of all those around you dealing damage, and (generating and) extracting up to 5 less soul fragments from them
//Spirt Bomb - Consume up to 5 available Soul Fragments then explode, damaging nearby enemies for (36.5% of Attack power) Fire damage per fragment consumed, and afflicting them with Frailty for 6 sec, causing you to heal for 8% of damage you deal to them. Deals reduced damage beyond 8 targets.


//(Made up)Soul Barrier - Shield yourself for 12 sec, absorbing (5 * Attack power * Percent health) damage. Consumes all Soul Fragments within 25 yds to add (1 * Attack power * Percent health) to the shield per fragment.
//Shattered Souls - Slain enemies sometimes drop soul fragments that heal you 20% - chance, Soul cleaves forces 2 of these to drop


// Havoc ===========================================================================

// Just Replace fiery brand with Blade Dance
//[Blade Dance] - Strike up to 5 nearby enemies become invulnerable while striking
//[Blur] - increase the effectiveness of evasion to 100% for 3 sec. https://wowpedia.fandom.com/wiki/Blur
//[Fel Barrage] - Replaces immolation aura, deals damage to all enemies over 8 sec (fires little projectiles at them)
