library HeroDeclaration

	globals
		Hero Arcane_Mage_A
		Hero Arcane_Mage_H
		Hero Arms_Warr_A
		Hero Arms_Warr_H
		Hero Ass_Rogue_A
		Hero Ass_Rogue_H
		Hero Bal_Druid_A
		Hero Bal_Druid_H
		Hero Beast_Hunter_A
		Hero Beast_Hunter_H
		Hero Blood_DK_A
		Hero Blood_DK_H
		Hero Brew_Monk_A
		Hero Brew_Monk_H
		Hero Combat_Rogue_A
		Hero Combat_Rogue_H
		Hero Dark_Ranger_A
		Hero Dark_Ranger_H
		Hero Havoc_DH_A
		Hero Havoc_DH_H
		Hero Demon_Warlock_A
		Hero Demon_Warlock_H
		Hero Destro_Warlock_A
		Hero Destro_Warlock_H
		Hero Disc_Priest_A
		Hero Disc_Priest_H
		Hero Ele_Sham_A
		Hero Ele_Sham_H
		Hero Enhance_Shaman_A
		Hero Enhance_Shaman_H
		Hero Feral_Druid_A
		Hero Feral_Druid_H
		Hero Fire_Mage_A
		Hero Fire_Mage_H
		Hero Frost_DK_A
		Hero Frost_DK_H
		Hero Frost_Mage_A
		Hero Frost_Mage_H
		Hero Fury_Warr_A
		Hero Fury_Warr_H
		Hero Holy_Pally_A
		Hero Holy_Pally_H
		Hero Holy_Priest_A
		Hero Holy_Priest_H
		Hero Marksman_Hunter_A
		Hero Marksman_Hunter_H
		Hero Prot_Pally_A
		Hero Prot_Pally_H
		Hero Prot_Warr_A
		Hero Prot_Warr_H
		Hero Resto_Sham_A
		Hero Resto_Sham_H
		Hero Ret_Pally_A
		Hero Ret_Pally_H
		Hero Shadow_Priest_A
		Hero Shadow_Priest_H
		Hero Subtle_Rogue_A
		Hero Subtle_Rogue_H
		Hero Unholy_DK_A
		Hero Unholy_DK_H
		
		// Hero Veng_DH_A
		// Hero Veng_DH_H

	endglobals
    
	function HeroDeclaration takes nothing returns nothing
		//========================================================================================
		//Here you declare all heroes in your map. The order in which you create them determine the order in which they appear in the hero selection menu.
		//The fields that should be set are:
		/*
		integer array abilities						The abilities of this hero. Starts at index 1.
		boolean array isNonHeroAbility				Set this flag if the ability at the index is a non-hero ability. This will make the tooltip instead of the research tooltip appear on mouse-over.
		integer unitId								Unit id of the hero.
		integer tooltip						Set up any non-hero ability with one level for each hero and write the hero's description in its tooltip.
		string selectEmote							Sound path of the emote the hero should play when selected.
		animtype selectAnim                         animType of select animation. For example, "spell" is ANIMTYPE_SPELL.
		subanimtype selectSubAnim                   subanimtype of select animation. For example "spell slam" is ANIMTYPE_SPELL + SUBANIMTYPE_SLAM.
		real selectAnimLength						Length of the select animation. If set incorrectly, animation will be interrupted or freeze.
		integer category							In which category in the menu should this hero be put?
		boolean needsHeroGlow						A hero glow will be added to heroes with models that don't have a glow. Requires "GeneralHeroGlow.mdx" to be imported.
		boolean unavailable							Heroes with this flag will appear in the menu but cannot be picked.
		boolean array unavailableToTeam				Hero will not appear in the menu for players in a team for which this flag was set. Can be used to create completely different hero rosters for different teams.
		*/
		//========================================================================================

		set Arcane_Mage_A = Hero.create()
		set Arcane_Mage_H = Hero.create()
		set Arms_Warr_A = Hero.create()
		set Arms_Warr_H = Hero.create()
		set Ass_Rogue_A = Hero.create()
		set Ass_Rogue_H = Hero.create()
		set Bal_Druid_A = Hero.create()
		set Bal_Druid_H = Hero.create()
		set Beast_Hunter_A = Hero.create()
		set Beast_Hunter_H = Hero.create()
		set Blood_DK_A = Hero.create()
		set Blood_DK_H = Hero.create()
		set Brew_Monk_A = Hero.create()
		set Brew_Monk_H = Hero.create()
		set Combat_Rogue_A = Hero.create()
		set Combat_Rogue_H = Hero.create()
		set Dark_Ranger_A = Hero.create()
		set Dark_Ranger_H = Hero.create()
		set Havoc_DH_A = Hero.create()
		set Havoc_DH_H = Hero.create()
		set Demon_Warlock_A = Hero.create()
		set Demon_Warlock_H = Hero.create()
		set Destro_Warlock_A = Hero.create()
		set Destro_Warlock_H = Hero.create()
		set Disc_Priest_A = Hero.create()
		set Disc_Priest_H = Hero.create()
		set Ele_Sham_A = Hero.create()
		set Ele_Sham_H = Hero.create()
		set Enhance_Shaman_A = Hero.create()
		set Enhance_Shaman_H = Hero.create()
		set Feral_Druid_A = Hero.create()
		set Feral_Druid_H = Hero.create()
		set Fire_Mage_A = Hero.create()
		set Fire_Mage_H = Hero.create()
		set Frost_DK_A = Hero.create()
		set Frost_DK_H = Hero.create()
		set Frost_Mage_A = Hero.create()
		set Frost_Mage_H = Hero.create()
		set Fury_Warr_A = Hero.create()
		set Fury_Warr_H = Hero.create()
		set Holy_Pally_A = Hero.create()
		set Holy_Pally_H = Hero.create()
		set Holy_Priest_A = Hero.create()
		set Holy_Priest_H = Hero.create()
		set Marksman_Hunter_A = Hero.create()
		set Marksman_Hunter_H = Hero.create()
		set Prot_Pally_A = Hero.create()
		set Prot_Pally_H = Hero.create()
		set Prot_Warr_A = Hero.create()
		set Prot_Warr_H = Hero.create()
		set Resto_Sham_A = Hero.create()
		set Resto_Sham_H = Hero.create()
		set Ret_Pally_A = Hero.create()
		set Ret_Pally_H = Hero.create()
		set Shadow_Priest_A = Hero.create()
		set Shadow_Priest_H = Hero.create()
		set Subtle_Rogue_A = Hero.create()
		set Subtle_Rogue_H = Hero.create()
		set Unholy_DK_A = Hero.create()
		set Unholy_DK_H = Hero.create()
		
		// set Veng_DH_A = Hero.create()
		// set Veng_DH_H = Hero.create()

		//========================================================================================

		set Arcane_Mage_A.abilities[1] = 'A08A'
		set Arcane_Mage_A.abilities[2] = 'A00H'
		set Arcane_Mage_A.abilities[3] = 'A00G'
		set Arcane_Mage_A.abilities[4] = 'A08B'
		set Arcane_Mage_A.abilities[5] = 'A00F'
		set Arcane_Mage_A.abilities[6] = 'A08D'
		set Arcane_Mage_A.abilities[7] = 'A0DF'
		set Arcane_Mage_A.abilities[8] = 'A08G'
		set Arcane_Mage_A.isNonHeroAbility[6] = true
		set Arcane_Mage_A.isNonHeroAbility[7] = true
		set Arcane_Mage_A.isNonHeroAbility[8] = true

		set Arcane_Mage_A.selectEmote = "Units\\NightElf\\Tyrande\\TyrandeWhat2.flac"
		set Arcane_Mage_A.unitId = 'H02Q'
		set Arcane_Mage_A.tooltip = "Master of arcane magic, excelling in ranged combat, illusions, time and invisibilty. |n|n|cffffcc00Roles: Damage|r|r"
		set Arcane_Mage_A.needsHeroGlow = false
		set Arcane_Mage_A.category = 5
		set Arcane_Mage_A.selectAnim = ANIM_TYPE_SPELL
		set Arcane_Mage_A.selectSubAnim = null
		set Arcane_Mage_A.selectAnimLength = 2.733
		set Arcane_Mage_A.unavailableToTeam[1] = true
		set Arcane_Mage_A.startingZone = 1  

		//========================================================================================

		set Arcane_Mage_H.abilities[1] = 'A08A'
		set Arcane_Mage_H.abilities[2] = 'A00H'
		set Arcane_Mage_H.abilities[3] = 'A00G'
		set Arcane_Mage_H.abilities[4] = 'A08B'
		set Arcane_Mage_H.abilities[5] = 'A00F'
		set Arcane_Mage_H.abilities[6] = 'A08D'
		set Arcane_Mage_H.abilities[7] = 'A0DF'
		set Arcane_Mage_H.abilities[8] = 'A08G'
		set Arcane_Mage_H.isNonHeroAbility[6] = true
		set Arcane_Mage_H.isNonHeroAbility[7] = true
		set Arcane_Mage_H.isNonHeroAbility[8] = true

		set Arcane_Mage_H.selectEmote = "Units\\Human\\Sorceress\\SorceressReady1.flac"
		set Arcane_Mage_H.unitId = 'H02T'
		set Arcane_Mage_H.tooltip = "Master of arcane magic, excelling in ranged combat, illusions, time and invisibilty. |n|n|cffffcc00Roles: Damage|r"
		set Arcane_Mage_H.needsHeroGlow = false
		set Arcane_Mage_H.category = 5
		set Arcane_Mage_H.selectAnim = ANIM_TYPE_SPELL
		set Arcane_Mage_H.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Arcane_Mage_H.selectAnimLength = 1.777
		set Arcane_Mage_H.unavailableToTeam[2] = true
		set Arcane_Mage_H.startingZone = 4

		//========================================================================================

		set Arms_Warr_A.abilities[1] = 'A04K'
		set Arms_Warr_A.abilities[2] = 'A04M'
		set Arms_Warr_A.abilities[3] = 'A04N'
		set Arms_Warr_A.abilities[4] = 'A02H'
		set Arms_Warr_A.abilities[5] = 'A014'
		set Arms_Warr_A.abilities[6] = 'A02E'
		set Arms_Warr_A.abilities[7] = 'A07U'
		set Arms_Warr_A.abilities[8] = 'A006'
		set Arms_Warr_A.isNonHeroAbility[6] = true
		set Arms_Warr_A.isNonHeroAbility[7] = true
		set Arms_Warr_A.isNonHeroAbility[8] = true

		set Arms_Warr_A.selectEmote = "Units\\Human\\Arthas\\ArthasReady1.flac"
		set Arms_Warr_A.unitId = 'H01J'
		set Arms_Warr_A.tooltip = "Master of melee combat, excelling in strength and weapon mastery. |n|n|cffffcc00Roles: Damage, Off-Tank|r"
		set Arms_Warr_A.needsHeroGlow = false
		set Arms_Warr_A.category = 12
		set Arms_Warr_A.selectAnim = ANIM_TYPE_ATTACK
		set Arms_Warr_A.selectSubAnim = SUBANIM_TYPE_SLAM
		set Arms_Warr_A.selectAnimLength = 1.133
		set Arms_Warr_A.unavailableToTeam[1] = true
		set Arms_Warr_A.startingZone = 1

		//========================================================================================

		set Arms_Warr_H.abilities[1] = 'A04K'
		set Arms_Warr_H.abilities[2] = 'A04M'
		set Arms_Warr_H.abilities[3] = 'A04N'
		set Arms_Warr_H.abilities[4] = 'A02H'
		set Arms_Warr_H.abilities[5] = 'A014'
		set Arms_Warr_H.abilities[6] = 'A02E'
		set Arms_Warr_H.abilities[7] = 'A07U'
		set Arms_Warr_H.abilities[8] = 'A006'
		set Arms_Warr_H.isNonHeroAbility[6] = true
		set Arms_Warr_H.isNonHeroAbility[7] = true
		set Arms_Warr_H.isNonHeroAbility[8] = true
		
		set Arms_Warr_H.selectEmote = "Units\\Orc\\Hellscream\\GromWarcry1.flac"
		set Arms_Warr_H.unitId = 'H028'
		set Arms_Warr_H.tooltip = "Master of melee combat, excelling in strength and weapon mastery. |n|n|cffffcc00Roles: Damage, Off-Tank|r"
		set Arms_Warr_H.needsHeroGlow = false
		set Arms_Warr_H.category = 12
		set Arms_Warr_H.selectAnim = ANIM_TYPE_ATTACK
		set Arms_Warr_H.selectSubAnim = SUBANIM_TYPE_SLAM
		set Arms_Warr_H.selectAnimLength = 1.133
		set Arms_Warr_H.unavailableToTeam[2] = true
		set Arms_Warr_H.startingZone = 3

		//================================================================================

		set Ass_Rogue_A.abilities[1] = 'A04U'
		set Ass_Rogue_A.abilities[2] = 'A0AN'
		set Ass_Rogue_A.abilities[3] = 'A04P'
		set Ass_Rogue_A.abilities[4] = 'A017'
		set Ass_Rogue_A.abilities[5] = 'A0AM'
		set Ass_Rogue_A.abilities[6] = 'A04O'
		set Ass_Rogue_A.abilities[7] = 'A0F2'
		set Ass_Rogue_A.abilities[8] = 'A0F3'
		set Ass_Rogue_A.isNonHeroAbility[6] = true
		set Ass_Rogue_A.isNonHeroAbility[7] = true
		set Ass_Rogue_A.isNonHeroAbility[8] = true
		
		set Ass_Rogue_A.selectEmote = "Units\\Creeps\\Bandit\\BanditPissed2.flac"
		set Ass_Rogue_A.unitId = 'E001'
		set Ass_Rogue_A.tooltip = "Master of stealth, poison, and assassination, excelling in quick and deadly strikes. |n|n|cffffcc00Roles: Damage|r"
		set Ass_Rogue_A.needsHeroGlow = false
		set Ass_Rogue_A.category = 9
		set Ass_Rogue_A.selectAnim = ANIM_TYPE_SPELL
		set Ass_Rogue_A.selectSubAnim = null
		set Ass_Rogue_A.selectAnimLength = 1.134
		set Ass_Rogue_A.unavailableToTeam[1] = true
		set Ass_Rogue_A.startingZone = 1

		//================================================================================

		set Ass_Rogue_H.abilities[1] = 'A04U'
		set Ass_Rogue_H.abilities[2] = 'A0AN'
		set Ass_Rogue_H.abilities[3] = 'A04P'
		set Ass_Rogue_H.abilities[4] = 'A017'
		set Ass_Rogue_H.abilities[5] = 'A0AM'
		set Ass_Rogue_H.abilities[6] = 'A04O'
		set Ass_Rogue_H.abilities[7] = 'A0F2'
		set Ass_Rogue_H.abilities[8] = 'A0F3'
		set Ass_Rogue_H.isNonHeroAbility[6] = true
		set Ass_Rogue_H.isNonHeroAbility[7] = true
		set Ass_Rogue_H.isNonHeroAbility[8] = true

		set Ass_Rogue_H.selectEmote = "Units\\Undead\\EvilSylvanas\\EvilSylvanasPissed1.flac"
		set Ass_Rogue_H.unitId = 'E03W'
		set Ass_Rogue_H.tooltip = "Master of stealth, poison, and assassination, excelling in quick and deadly strikes. |n|n|cffffcc00Roles: Damage|r"
		set Ass_Rogue_H.needsHeroGlow = false
		set Ass_Rogue_H.category = 9
		set Ass_Rogue_H.selectAnim = ANIM_TYPE_SPELL
		set Ass_Rogue_H.selectSubAnim = null
		set Ass_Rogue_H.selectAnimLength = 1.134
		set Ass_Rogue_H.unavailableToTeam[2] = true
		set Ass_Rogue_H.startingZone = 3

		//================================================================================

		set Bal_Druid_A.abilities[1] = 'A0D0'
		set Bal_Druid_A.abilities[2] = 'A030'
		set Bal_Druid_A.abilities[3] = 'A02Y'
		set Bal_Druid_A.abilities[4] = 'A0CS'
		set Bal_Druid_A.abilities[5] = 'A0CR'
		set Bal_Druid_A.abilities[6] = 'A091'
		set Bal_Druid_A.abilities[7] = 'A0E1'
		set Bal_Druid_A.abilities[8] = 'A0E4'
		set Bal_Druid_A.isNonHeroAbility[6] = true
		set Bal_Druid_A.isNonHeroAbility[7] = true
		set Bal_Druid_A.isNonHeroAbility[8] = true

		set Bal_Druid_A.selectEmote = "Units\\NightElf\\Dryad\\DryadWarcry1.flac"
		set Bal_Druid_A.unitId = 'E00Z'
		set Bal_Druid_A.tooltip = "Master of balance and restoration, harnessing the power of nature for healing and celestial forces for damage. |n|n|cffffcc00Roles: Damage, Healer|r"
		set Bal_Druid_A.needsHeroGlow = false
		set Bal_Druid_A.category = 3
		set Bal_Druid_A.selectAnim = ANIM_TYPE_MORPH
		set Bal_Druid_A.selectSubAnim = SUBANIM_TYPE_ALTERNATE_EX
		set Bal_Druid_A.selectAnimLength = 1.667//2.7333
		set Bal_Druid_A.unavailableToTeam[1] = true
		set Bal_Druid_A.startingZone = 1
		
		//================================================================================

		set Bal_Druid_H.abilities[1] = 'A0D0'
		set Bal_Druid_H.abilities[2] = 'A030'
		set Bal_Druid_H.abilities[3] = 'A02Y'
		set Bal_Druid_H.abilities[4] = 'A0CS'
		set Bal_Druid_H.abilities[5] = 'A0CR'
		set Bal_Druid_H.abilities[6] = 'A091'
		set Bal_Druid_H.abilities[7] = 'A0E1'
		set Bal_Druid_H.abilities[8] = 'A0E4'
		set Bal_Druid_H.isNonHeroAbility[6] = true
		set Bal_Druid_H.isNonHeroAbility[7] = true
		set Bal_Druid_H.isNonHeroAbility[8] = true

		set Bal_Druid_H.selectEmote = "Units\\Orc\\SpiritWalker\\WhiteTaurenWhat2.flac"
		set Bal_Druid_H.unitId = 'E00C'
		set Bal_Druid_H.tooltip = "Master of balance and restoration, harnessing the power of nature for healing and celestial forces for damage. |n|n|cffffcc00Roles: Damage, Healer|r"
		set Bal_Druid_H.needsHeroGlow = false
		set Bal_Druid_H.category = 3
		set Bal_Druid_H.selectAnim = ANIM_TYPE_SPELL
		set Bal_Druid_H.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Bal_Druid_H.selectAnimLength = 8.234
		set Bal_Druid_H.unavailableToTeam[2] = true
		set Bal_Druid_H.startingZone = 3

		//================================================================================

		set Beast_Hunter_A.abilities[1] = 'A00C'
		set Beast_Hunter_A.abilities[2] = 'A00B'
		set Beast_Hunter_A.abilities[3] = 'A05M'
		set Beast_Hunter_A.abilities[4] = 'A0CP'
		set Beast_Hunter_A.abilities[5] = 'A0EO'
		set Beast_Hunter_A.abilities[6] = 'A02G'
		set Beast_Hunter_A.abilities[7] = 'A0EJ'
		set Beast_Hunter_A.abilities[8] = 'A0DI'
		set Beast_Hunter_A.isNonHeroAbility[6] = true
		set Beast_Hunter_A.isNonHeroAbility[7] = true
		set Beast_Hunter_A.isNonHeroAbility[8] = true
		
		set Beast_Hunter_A.selectEmote = "Units\\Human\\Rifleman\\RiflemanWarcry1.flac"
		set Beast_Hunter_A.unitId = 'H00L'
		set Beast_Hunter_A.tooltip = "Master of beasts, excelling in ranged combat and summoning powerful animal companions. |n|n|cffffcc00Roles: Damage, Pet-Tanking|r"
		set Beast_Hunter_A.needsHeroGlow = false
		set Beast_Hunter_A.category = 4
		set Beast_Hunter_A.selectAnim = ANIM_TYPE_SPELL
		set Beast_Hunter_A.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Beast_Hunter_A.selectAnimLength = 2.000
		set Beast_Hunter_A.unavailableToTeam[1] = true
		set Beast_Hunter_A.startingZone = 0

		//================================================================================

		set Beast_Hunter_H.abilities[1] = 'A00C'
		set Beast_Hunter_H.abilities[2] = 'A00B'
		set Beast_Hunter_H.abilities[3] = 'A05M'
		set Beast_Hunter_H.abilities[4] = 'A0CP'
		set Beast_Hunter_H.abilities[5] = 'A0EO'
		set Beast_Hunter_H.abilities[6] = 'A02G'
		set Beast_Hunter_H.abilities[7] = 'A0EJ'
		set Beast_Hunter_H.abilities[8] = 'A0ET'
		set Beast_Hunter_H.isNonHeroAbility[6] = true
		set Beast_Hunter_H.isNonHeroAbility[7] = true
		set Beast_Hunter_H.isNonHeroAbility[8] = true
		
		set Beast_Hunter_H.selectEmote = "Units\\Creeps\\SylvanusWindrunner\\SylvanasPissed5.flac"
		set Beast_Hunter_H.unitId = 'H003'
		set Beast_Hunter_H.tooltip = "Master of beasts, excelling in ranged combat and summoning powerful animal companions. |n|n|cffffcc00Roles: Damage, Pet-Tanking|r"
		set Beast_Hunter_H.needsHeroGlow = false
		set Beast_Hunter_H.category = 4
		set Beast_Hunter_H.selectAnim = ANIM_TYPE_STAND
		set Beast_Hunter_H.selectSubAnim = SUBANIM_TYPE_VICTORY
		set Beast_Hunter_H.selectAnimLength = 3.734
		set Beast_Hunter_H.unavailableToTeam[2] = true
		set Beast_Hunter_H.startingZone = 4

		//================================================================================

		set Blood_DK_A.abilities[1] = 'A0DG'
		set Blood_DK_A.abilities[2] = 'A03U'
		set Blood_DK_A.abilities[3] = 'AUau'
		set Blood_DK_A.abilities[4] = 'A06J'
		set Blood_DK_A.abilities[5] = 'A03X'
		set Blood_DK_A.abilities[6] = 'A03Y'
		set Blood_DK_A.abilities[7] = 'A073'
		set Blood_DK_A.abilities[8] = 'A0FJ'
		set Blood_DK_A.isNonHeroAbility[6] = true
		set Blood_DK_A.isNonHeroAbility[7] = true
		set Blood_DK_A.isNonHeroAbility[8] = true

		set Blood_DK_A.selectEmote = "Units\\Undead\\EvilArthas\\EvilArthasWarcry1.flac"
		set Blood_DK_A.unitId = 'U01V'
		set Blood_DK_A.tooltip = "Master of blood magic, excelling in self-healing and sustaining through combat. |n|n|cffffcc00Roles: Tank|r"
		set Blood_DK_A.needsHeroGlow = false
		set Blood_DK_A.category = 1
		set Blood_DK_A.selectAnim = ANIM_TYPE_STAND
		set Blood_DK_A.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Blood_DK_A.selectAnimLength = 2.041
		set Blood_DK_A.unavailableToTeam[1] = true
		set Blood_DK_A.startingZone = 1

		//================================================================================

		set Blood_DK_H.abilities[1] = 'A0DG'
		set Blood_DK_H.abilities[2] = 'A03U'
		set Blood_DK_H.abilities[3] = 'AUau'
		set Blood_DK_H.abilities[4] = 'A06J'
		set Blood_DK_H.abilities[5] = 'AUan'
		set Blood_DK_H.abilities[6] = 'A03Y'
		set Blood_DK_H.abilities[7] = 'A073'
		set Blood_DK_H.abilities[8] = 'A0FJ'
		set Blood_DK_H.isNonHeroAbility[6] = true
		set Blood_DK_H.isNonHeroAbility[7] = true
		set Blood_DK_H.isNonHeroAbility[8] = true

		set Blood_DK_H.selectEmote = "Units\\Demon\\ChaosWarlord\\WarlordWarcry1.flac"
		set Blood_DK_H.unitId = 'U01U'
		set Blood_DK_H.tooltip = "Master of blood magic, excelling in self-healing and sustaining through combat. |n|n|cffffcc00Roles: Tank|r"
		set Blood_DK_H.needsHeroGlow = false
		set Blood_DK_H.category = 1
		set Blood_DK_H.selectAnim = ANIM_TYPE_ATTACK
		set Blood_DK_H.selectSubAnim = SUBANIM_TYPE_SLAM
		set Blood_DK_H.selectAnimLength = 1.400
		set Blood_DK_H.unavailableToTeam[2] = true
		set Blood_DK_H.startingZone = 3

		//================================================================================

		set Brew_Monk_A.abilities[1] = 'ANbf'
		set Brew_Monk_A.abilities[2] = 'ANdh'
		set Brew_Monk_A.abilities[3] = 'AOw2'
		set Brew_Monk_A.abilities[4] = 'A09G'
		set Brew_Monk_A.abilities[5] = 'A09F'
		set Brew_Monk_A.abilities[6] = 'A09H'
		set Brew_Monk_A.abilities[7] = 'A0E7'
		set Brew_Monk_A.abilities[8] = 'A0E6'
		set Brew_Monk_A.isNonHeroAbility[6] = true
		set Brew_Monk_A.isNonHeroAbility[7] = true
		set Brew_Monk_A.isNonHeroAbility[8] = true

		set Brew_Monk_A.selectEmote = "Units\\Creeps\\PandarenBrewmaster\\PandarenBrewmasterPissed1.flac"
		set Brew_Monk_A.unitId = 'N041'
		set Brew_Monk_A.tooltip = "Master of drunken combat; excellent in sustained fights. |n|n|cffffcc00Roles: Tank|r"
		set Brew_Monk_A.needsHeroGlow = false
		set Brew_Monk_A.category = 6
		set Brew_Monk_A.selectAnim = ANIM_TYPE_SPELL
		set Brew_Monk_A.selectSubAnim = null
		set Brew_Monk_A.selectAnimLength = 0.967
		set Brew_Monk_A.unavailableToTeam[1] = true
		set Brew_Monk_A.startingZone = 0

		//================================================================================

		set Brew_Monk_H.abilities[1] = 'ANbf'
		set Brew_Monk_H.abilities[2] = 'ANdh'
		set Brew_Monk_H.abilities[3] = 'AOw2'
		set Brew_Monk_H.abilities[4] = 'A09G'
		set Brew_Monk_H.abilities[5] = 'A09F'
		set Brew_Monk_H.abilities[6] = 'A09H'
		set Brew_Monk_H.abilities[7] = 'A0E7'
		set Brew_Monk_H.abilities[8] = 'A0E6'
		set Brew_Monk_H.isNonHeroAbility[6] = true
		set Brew_Monk_H.isNonHeroAbility[7] = true
		set Brew_Monk_H.isNonHeroAbility[8] = true

		set Brew_Monk_H.selectEmote = "Units\\Creeps\\PandarenBrewmaster\\PandarenBrewmasterPissed2.flac"
		set Brew_Monk_H.unitId = 'N041'
		set Brew_Monk_H.tooltip = "Master of drunken combat; excellent in sustained fights. |n|n|cffffcc00Roles: Tank|r"
		set Brew_Monk_H.needsHeroGlow = false
		set Brew_Monk_H.category = 6
		set Brew_Monk_H.selectAnim = ANIM_TYPE_SPELL
		set Brew_Monk_H.selectSubAnim = null
		set Brew_Monk_H.selectAnimLength = 0.967
		set Brew_Monk_H.unavailableToTeam[2] = true
		set Brew_Monk_H.startingZone = 3

		//================================================================================

		set Combat_Rogue_A.abilities[1] = 'A09V'
		set Combat_Rogue_A.abilities[2] = 'A0D6'
		set Combat_Rogue_A.abilities[3] = 'A09J'
		set Combat_Rogue_A.abilities[4] = 'A017'
		set Combat_Rogue_A.abilities[5] = 'A0DS'
		set Combat_Rogue_A.abilities[6] = 'A06I'
		set Combat_Rogue_A.abilities[7] = 'A0EZ'
		set Combat_Rogue_A.abilities[8] = 'A0F0'
		set Combat_Rogue_A.isNonHeroAbility[6] = true
		set Combat_Rogue_A.isNonHeroAbility[7] = true
		set Combat_Rogue_A.isNonHeroAbility[8] = true

		set Combat_Rogue_A.selectEmote = "Units\\Orc\\Spiritwolf\\SpiritwolfWhat1.flac"
		set Combat_Rogue_A.unitId = 'E01O'
		set Combat_Rogue_A.tooltip = "Master of combat, excelling in agility and sustained melee damage. |n|n|cffffcc00Roles: Damage|r"
		set Combat_Rogue_A.needsHeroGlow = false
		set Combat_Rogue_A.category = 9
		set Combat_Rogue_A.selectAnim = ANIM_TYPE_SPELL
		set Combat_Rogue_A.selectSubAnim = SUBANIM_TYPE_SLAM
		set Combat_Rogue_A.selectAnimLength = 3.133
		set Combat_Rogue_A.unavailableToTeam[1] = true
		set Combat_Rogue_A.startingZone = 1

		//================================================================================

		set Combat_Rogue_H.abilities[1] = 'A09V'
		set Combat_Rogue_H.abilities[2] = 'A0D6'
		set Combat_Rogue_H.abilities[3] = 'A09J'
		set Combat_Rogue_H.abilities[4] = 'A017'
		set Combat_Rogue_H.abilities[5] = 'A0DS'
		set Combat_Rogue_H.abilities[6] = 'A09U'
		set Combat_Rogue_H.abilities[7] = 'A0EZ'
		set Combat_Rogue_H.abilities[8] = 'A0F0'
		set Combat_Rogue_H.isNonHeroAbility[6] = true
		set Combat_Rogue_H.isNonHeroAbility[7] = true
		set Combat_Rogue_H.isNonHeroAbility[8] = true

		set Combat_Rogue_H.selectEmote = "Units\\Undead\\Shade\\ShadePissed2.flac"
		set Combat_Rogue_H.unitId = 'E035'
		set Combat_Rogue_H.tooltip = "Master of combat, excelling in agility and sustained melee damage. |n|n|cffffcc00Roles: Damage|r"
		set Combat_Rogue_H.needsHeroGlow = false
		set Combat_Rogue_H.category = 9
		set Combat_Rogue_H.selectAnim = ANIM_TYPE_ATTACK
		set Combat_Rogue_H.selectSubAnim = SUBANIM_TYPE_SLAM
		set Combat_Rogue_H.selectAnimLength = 1.000
		set Combat_Rogue_H.unavailableToTeam[2] = true
		set Combat_Rogue_H.startingZone = 3

		//================================================================================

		set Dark_Ranger_A.abilities[1] = 'A04V'
		set Dark_Ranger_A.abilities[2] = 'A04W'
		set Dark_Ranger_A.abilities[3] = 'A05B'
		set Dark_Ranger_A.abilities[4] = 'A04X'
		set Dark_Ranger_A.abilities[5] = 'A0GD'
		set Dark_Ranger_A.abilities[6] = 'A0FD'
		set Dark_Ranger_A.abilities[7] = 'A0FI'
		set Dark_Ranger_A.abilities[8] = 'A0GC'
		set Dark_Ranger_A.isNonHeroAbility[6] = true
		set Dark_Ranger_A.isNonHeroAbility[7] = true
		set Dark_Ranger_A.isNonHeroAbility[8] = true

		set Dark_Ranger_A.selectEmote = "Units\\NightElf\\HeroWarden\\HeroWardenPissed1.flac"
		set Dark_Ranger_A.unitId = 'H02V'
		set Dark_Ranger_A.tooltip = "Master of shadow magic, excelling in ranged combat and summoning undead minions. |n|n|cffffcc00Roles: Damage|r"
		set Dark_Ranger_A.needsHeroGlow = false
		set Dark_Ranger_A.category = 4
		set Dark_Ranger_A.selectAnim = ANIM_TYPE_ATTACK
		set Dark_Ranger_A.selectSubAnim = null
		set Dark_Ranger_A.selectAnimLength = 1.500
		set Dark_Ranger_A.unavailableToTeam[1] = true
		set Dark_Ranger_A.startingZone = 0

		//================================================================================

		set Dark_Ranger_H.abilities[1] = 'A04V'
		set Dark_Ranger_H.abilities[2] = 'A04W'
		set Dark_Ranger_H.abilities[3] = 'A05B'
		set Dark_Ranger_H.abilities[4] = 'A04X'
		set Dark_Ranger_H.abilities[5] = 'A0GD'
		set Dark_Ranger_H.abilities[6] = 'A0FD'
		set Dark_Ranger_H.abilities[7] = 'A0FI'
		set Dark_Ranger_H.abilities[8] = 'A0GC'
		set Dark_Ranger_H.isNonHeroAbility[6] = true
		set Dark_Ranger_H.isNonHeroAbility[7] = true
		set Dark_Ranger_H.isNonHeroAbility[8] = true

		set Dark_Ranger_H.selectEmote = "Units\\Creeps\\BansheeRanger\\DarkRangerWarcry1.flac"
		set Dark_Ranger_H.unitId = 'H01I'
		set Dark_Ranger_H.tooltip = "Master of shadow magic, excelling in ranged combat and summoning undead minions. |n|n|cffffcc00Roles: Damage|r"
		set Dark_Ranger_H.needsHeroGlow = false
		set Dark_Ranger_H.category = 4
		set Dark_Ranger_H.selectAnim = ANIM_TYPE_ATTACK
		set Dark_Ranger_H.selectSubAnim = null
		set Dark_Ranger_H.selectAnimLength = 1.334
		set Dark_Ranger_H.unavailableToTeam[2] = true
		set Dark_Ranger_H.startingZone = 3

		//================================================================================

		set Demon_Warlock_A.abilities[1] = 'ANso'
		set Demon_Warlock_A.abilities[2] = 'A00D'
		set Demon_Warlock_A.abilities[3] = 'A005'
		set Demon_Warlock_A.abilities[4] = 'A01E'
		set Demon_Warlock_A.abilities[5] = 'A039'
		set Demon_Warlock_A.abilities[6] = 'A02F'
		set Demon_Warlock_A.abilities[7] = 'A0EH'
		set Demon_Warlock_A.abilities[8] = 'A0EB'
		set Demon_Warlock_A.isNonHeroAbility[6] = true
		set Demon_Warlock_A.isNonHeroAbility[7] = true
		set Demon_Warlock_A.isNonHeroAbility[8] = true

		set Demon_Warlock_A.selectEmote = "Units\\Undead\\KelThuzadNecro\\KelThuzadWhat3.flac"
		set Demon_Warlock_A.unitId = 'E02V'
		set Demon_Warlock_A.tooltip = "Master of demonic magic, who summons legions of demons and draining souls. |n|n|cffffcc00Roles: Damage, Pet-Tanking|r"
		set Demon_Warlock_A.needsHeroGlow = false
		set Demon_Warlock_A.category = 11
		set Demon_Warlock_A.selectAnim = ANIM_TYPE_SPELL
		set Demon_Warlock_A.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Demon_Warlock_A.selectAnimLength = 1.667
		set Demon_Warlock_A.unavailableToTeam[1] = true
		set Demon_Warlock_A.startingZone = 1

		//================================================================================

		set Demon_Warlock_H.abilities[1] = 'ANso'
		set Demon_Warlock_H.abilities[2] = 'A00D'
		set Demon_Warlock_H.abilities[3] = 'A005'
		set Demon_Warlock_H.abilities[4] = 'A01E'
		set Demon_Warlock_H.abilities[5] = 'A039'
		set Demon_Warlock_H.abilities[6] = 'A02F'
		set Demon_Warlock_H.abilities[7] = 'A0EH'
		set Demon_Warlock_H.abilities[8] = 'A0EB'
		set Demon_Warlock_H.isNonHeroAbility[6] = true
		set Demon_Warlock_H.isNonHeroAbility[7] = true
		set Demon_Warlock_H.isNonHeroAbility[8] = true

		set Demon_Warlock_H.selectEmote = "Units\\Undead\\KelThuzadLich\\KelThuzadPissed5.flac"
		set Demon_Warlock_H.unitId = 'E000'
		set Demon_Warlock_H.tooltip = "Master of demonic magic, who summons legions of demons and draining souls. |n|n|cffffcc00Roles: Damage, Pet-Tanking|r"
		set Demon_Warlock_H.needsHeroGlow = false
		set Demon_Warlock_H.category = 11
		set Demon_Warlock_H.selectAnim = ANIM_TYPE_SPELL
		set Demon_Warlock_H.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Demon_Warlock_H.selectAnimLength = 1.30
		set Demon_Warlock_H.unavailableToTeam[2] = true
		set Demon_Warlock_H.startingZone = 3

		//================================================================================

		set Destro_Warlock_A.abilities[1] = 'A094'
		set Destro_Warlock_A.abilities[2] = 'AHbn'
		set Destro_Warlock_A.abilities[3] = 'A099'
		set Destro_Warlock_A.abilities[4] = 'A09C'
		set Destro_Warlock_A.abilities[5] = 'A09A'
		set Destro_Warlock_A.abilities[6] = 'A09E'
		set Destro_Warlock_A.abilities[7] = 'A0EA'
		set Destro_Warlock_A.abilities[8] = 'A0EB'
		set Destro_Warlock_A.isNonHeroAbility[6] = true
		set Destro_Warlock_A.isNonHeroAbility[7] = true
		set Destro_Warlock_A.isNonHeroAbility[8] = true

		set Destro_Warlock_A.selectEmote = "Units\\Creeps\\CentaurArcher\\CentaurArcherPissed1.flac"
		set Destro_Warlock_A.unitId = 'E04A'
		set Destro_Warlock_A.tooltip = "Master of destructive magic, excelling in chaos and fire spells. |n|n|cffffcc00Roles: Damage|r"
		set Destro_Warlock_A.needsHeroGlow = false
		set Destro_Warlock_A.category = 11
		set Destro_Warlock_A.selectAnim = ANIM_TYPE_SPELL
		set Destro_Warlock_A.selectSubAnim = null
		set Destro_Warlock_A.selectAnimLength = 2.000
		set Destro_Warlock_A.unavailableToTeam[1] = true
		set Destro_Warlock_A.startingZone = 0

		//================================================================================

		set Destro_Warlock_H.abilities[1] = 'A094'
		set Destro_Warlock_H.abilities[2] = 'AHbn'
		set Destro_Warlock_H.abilities[3] = 'A099'
		set Destro_Warlock_H.abilities[4] = 'A09C'
		set Destro_Warlock_H.abilities[5] = 'A09A'
		set Destro_Warlock_H.abilities[6] = 'A09E'
		set Destro_Warlock_H.abilities[7] = 'A0EA'
		set Destro_Warlock_H.abilities[8] = 'A0EB'
		set Destro_Warlock_H.isNonHeroAbility[6] = true
		set Destro_Warlock_H.isNonHeroAbility[7] = true
		set Destro_Warlock_H.isNonHeroAbility[8] = true

		set Destro_Warlock_H.selectEmote = "Units\\Orc\\Shaman\\ShamanWarcry1.flac"
		set Destro_Warlock_H.unitId = 'E02Z'
		set Destro_Warlock_H.tooltip = "Master of destructive magic, excelling in chaos and fire spells. |n|n|cffffcc00Roles: Damage|r"
		set Destro_Warlock_H.needsHeroGlow = false
		set Destro_Warlock_H.category = 11
		set Destro_Warlock_H.selectAnim = ANIM_TYPE_SPELL
		set Destro_Warlock_H.selectSubAnim = null
		set Destro_Warlock_H.selectAnimLength = 1.333
		set Destro_Warlock_H.unavailableToTeam[2] = true
		set Destro_Warlock_H.startingZone = 3

		//================================================================================
		set Disc_Priest_A.abilities[1] = 'A02P'
		set Disc_Priest_A.abilities[2] = 'A0FN'
		set Disc_Priest_A.abilities[3] = 'A08V'
		set Disc_Priest_A.abilities[4] = 'A090'
		set Disc_Priest_A.abilities[5] = 'A08R'
		set Disc_Priest_A.abilities[6] = 'A08Z'
		set Disc_Priest_A.abilities[7] = 'A0FP'
		set Disc_Priest_A.abilities[8] = 'A0FT'
		set Disc_Priest_A.isNonHeroAbility[6] = true
		set Disc_Priest_A.isNonHeroAbility[7] = true
		set Disc_Priest_A.isNonHeroAbility[8] = true

		set Disc_Priest_A.selectEmote = "Units\\Other\\DranaiAkama\\AkamaWhat5.flac"
		set Disc_Priest_A.unitId = 'H03J'
		set Disc_Priest_A.tooltip = "Master of discipline, excelling in healing and protective magic. |n|n|cffffcc00Roles: Healer, Damage|r"
		set Disc_Priest_A.needsHeroGlow = false
		set Disc_Priest_A.category = 8
		set Disc_Priest_A.selectAnim = ANIM_TYPE_STAND
		set Disc_Priest_A.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Disc_Priest_A.selectAnimLength = 1.333
		set Disc_Priest_A.unavailableToTeam[1] = true
		set Disc_Priest_A.startingZone = 0

		//================================================================================

		set Disc_Priest_H.abilities[1] = 'A02P'
		set Disc_Priest_H.abilities[2] = 'A0FN'
		set Disc_Priest_H.abilities[3] = 'A08V'
		set Disc_Priest_H.abilities[4] = 'A090'
		set Disc_Priest_H.abilities[5] = 'A08R'
		set Disc_Priest_H.abilities[6] = 'A08Z'
		set Disc_Priest_H.abilities[7] = 'A0FP'
		set Disc_Priest_H.abilities[8] = 'A0FT'
		set Disc_Priest_H.isNonHeroAbility[6] = true
		set Disc_Priest_H.isNonHeroAbility[7] = true
		set Disc_Priest_H.isNonHeroAbility[8] = true

		set Disc_Priest_H.selectEmote = "Units\\Creeps\\FemaleSatyr\\FemaleSatyrePissed3.flac"
		set Disc_Priest_H.unitId = 'H03I'
		set Disc_Priest_H.tooltip = "Master of discipline, excelling in healing and protective magic. |n|n|cffffcc00Roles: Healer, Damage|r"
		set Disc_Priest_H.needsHeroGlow = false
		set Disc_Priest_H.category = 8
		set Disc_Priest_H.selectAnim = ANIM_TYPE_SPELL
		set Disc_Priest_H.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Disc_Priest_H.selectAnimLength = 2.000
		set Disc_Priest_H.unavailableToTeam[2] = true
		set Disc_Priest_H.startingZone = 3

		//================================================================================

		set Ele_Sham_A.abilities[1] = 'A03Q'
		set Ele_Sham_A.abilities[2] = 'AOcl'
		set Ele_Sham_A.abilities[3] = 'A045'
		set Ele_Sham_A.abilities[4] = 'AOeq'
		set Ele_Sham_A.abilities[5] = 'A0AK'
		set Ele_Sham_A.abilities[6] = 'A03A'
		set Ele_Sham_A.abilities[7] = 'A0DO'
		set Ele_Sham_A.abilities[8] = 'AOr3'
		set Ele_Sham_A.isNonHeroAbility[6] = true
		set Ele_Sham_A.isNonHeroAbility[7] = true
		set Ele_Sham_A.isNonHeroAbility[8] = true

		set Ele_Sham_A.selectEmote = "Units\\Other\\DranaiAkama\\AkamaPissed9.flac"
		set Ele_Sham_A.unitId = 'O00R'
		set Ele_Sham_A.tooltip = "Master of elemental magic, excelling in lightning, fire, and earth spells. |n|n|cffffcc00Roles: Damage|r"
		set Ele_Sham_A.needsHeroGlow = false
		set Ele_Sham_A.category = 10
		set Ele_Sham_A.selectAnim = ANIM_TYPE_SPELL
		set Ele_Sham_A.selectSubAnim = null
		set Ele_Sham_A.selectAnimLength = 2.666
		set Ele_Sham_A.unavailableToTeam[1] = true
		set Ele_Sham_A.startingZone = 0

		//================================================================================

		set Ele_Sham_H.abilities[1] = 'A03Q'
		set Ele_Sham_H.abilities[2] = 'AOcl'
		set Ele_Sham_H.abilities[3] = 'A045'
		set Ele_Sham_H.abilities[4] = 'AOeq'
		set Ele_Sham_H.abilities[5] = 'A0AK'
		set Ele_Sham_H.abilities[6] = 'A03A'
		set Ele_Sham_H.abilities[7] = 'A0DO'
		set Ele_Sham_H.abilities[8] = 'AOr3'
		set Ele_Sham_H.isNonHeroAbility[6] = true
		set Ele_Sham_H.isNonHeroAbility[7] = true
		set Ele_Sham_H.isNonHeroAbility[8] = true

		set Ele_Sham_H.selectEmote = "Units\\Orc\\HeroShadowHunter\\ShadowHunterReady1.flac"
		set Ele_Sham_H.unitId = 'O006'
		set Ele_Sham_H.tooltip = "Master of elemental magic, excelling in lightning, fire, and earth spells. |n|n|cffffcc00Roles: Damage|r"
		set Ele_Sham_H.needsHeroGlow = false
		set Ele_Sham_H.category = 10
		set Ele_Sham_H.selectAnim = ANIM_TYPE_SPELL
		set Ele_Sham_H.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Ele_Sham_H.selectAnimLength = 3.000
		set Ele_Sham_H.unavailableToTeam[2] = true
		set Ele_Sham_H.startingZone = 3

		// ================================================================================
		set Enhance_Shaman_A.abilities[1] = 'A08T'
		set Enhance_Shaman_A.abilities[2] = 'A08U'
		set Enhance_Shaman_A.abilities[3] = 'A08Q'
		set Enhance_Shaman_A.abilities[4] = 'A08S'
		set Enhance_Shaman_A.abilities[5] = 'AOSf'
		set Enhance_Shaman_A.abilities[6] = 'A03A'
		set Enhance_Shaman_A.abilities[7] = 'A0DO'
		set Enhance_Shaman_A.abilities[8] = 'AOr3'
		set Enhance_Shaman_A.isNonHeroAbility[6] = true
		set Enhance_Shaman_A.isNonHeroAbility[7] = true
		set Enhance_Shaman_A.isNonHeroAbility[8] = true

		set Enhance_Shaman_A.selectEmote = "Units\\Human\\HeroMountainKing\\HeroMountainKingYesAttack2.flac"
		set Enhance_Shaman_A.unitId = 'O00P'
		set Enhance_Shaman_A.tooltip = "Master of the elements who enhances his weapon for devestating blows. |n|n|cffffcc00Roles: Damage, Off-Tank|r"
		set Enhance_Shaman_A.needsHeroGlow = false
		set Enhance_Shaman_A.category = 10
		set Enhance_Shaman_A.selectAnim = ANIM_TYPE_SPELL
		set Enhance_Shaman_A.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Enhance_Shaman_A.selectAnimLength = 2.000
		set Enhance_Shaman_A.unavailableToTeam[1] = true
		set Enhance_Shaman_A.startingZone = 0

		//================================================================================

		set Enhance_Shaman_H.abilities[1] = 'A08T'
		set Enhance_Shaman_H.abilities[2] = 'A08U'
		set Enhance_Shaman_H.abilities[3] = 'A08Q'
		set Enhance_Shaman_H.abilities[4] = 'A08S'
		set Enhance_Shaman_H.abilities[5] = 'AOSf'
		set Enhance_Shaman_H.abilities[6] = 'A03A'
		set Enhance_Shaman_H.abilities[7] = 'A0DO'
		set Enhance_Shaman_H.abilities[8] = 'AOr3'
		set Enhance_Shaman_H.isNonHeroAbility[6] = true
		set Enhance_Shaman_H.isNonHeroAbility[7] = true
		set Enhance_Shaman_H.isNonHeroAbility[8] = true

		set Enhance_Shaman_H.selectEmote = "Units\\Orc\\Thrall\\ThrallWarcry1.flac"
		set Enhance_Shaman_H.unitId = 'O00J'
		set Enhance_Shaman_H.tooltip = "Master of the elements who enhances his weapon for devestating blows. |n|n|cffffcc00Roles: Damage, Off-Tank|r"
		set Enhance_Shaman_H.needsHeroGlow = false
		set Enhance_Shaman_H.category = 10
		set Enhance_Shaman_H.selectAnim = ANIM_TYPE_ATTACK
		set Enhance_Shaman_H.selectSubAnim = null
		set Enhance_Shaman_H.selectAnimLength = 1.331
		set Enhance_Shaman_H.unavailableToTeam[2] = true
		set Enhance_Shaman_H.startingZone = 4

		//================================================================================

		set Feral_Druid_A.abilities[1] = 'A02Z'
		set Feral_Druid_A.abilities[2] = 'A030'
		set Feral_Druid_A.abilities[3] = 'A02Y'
		set Feral_Druid_A.abilities[4] = 'A035'
		set Feral_Druid_A.abilities[5] = 'A031'
		set Feral_Druid_A.abilities[6] = 'A0CV'
		set Feral_Druid_A.abilities[7] = 'A0E1'
		set Feral_Druid_A.abilities[8] = 'A0E3'
		set Feral_Druid_A.isNonHeroAbility[6] = true
		set Feral_Druid_A.isNonHeroAbility[7] = true
		set Feral_Druid_A.isNonHeroAbility[8] = true

		set Feral_Druid_A.selectEmote = "Units\\NightElf\\Furion\\FurionWarcry1.flac"
		set Feral_Druid_A.unitId = 'E00F'
		set Feral_Druid_A.tooltip = "Master of cat and bear forms, able to tank and deal bleed damage. |n|n|cffffcc00Roles: Tank, Damage|r"
		set Feral_Druid_A.needsHeroGlow = false
		set Feral_Druid_A.category = 3
		set Feral_Druid_A.selectAnim = ANIM_TYPE_SPELL
		set Feral_Druid_A.selectSubAnim = null
		set Feral_Druid_A.selectAnimLength = 2.666
		set Feral_Druid_A.unavailableToTeam[1] = true
		set Feral_Druid_A.startingZone = 1

		//================================================================================

		set Feral_Druid_H.abilities[1] = 'A02Z'
		set Feral_Druid_H.abilities[2] = 'A030'
		set Feral_Druid_H.abilities[3] = 'A02Y'
		set Feral_Druid_H.abilities[4] = 'A035'
		set Feral_Druid_H.abilities[5] = 'A031'
		set Feral_Druid_H.abilities[6] = 'A0CV'
		set Feral_Druid_H.abilities[7] = 'A0E1'
		set Feral_Druid_H.abilities[8] = 'A0E3'
		set Feral_Druid_H.isNonHeroAbility[6] = true
		set Feral_Druid_H.isNonHeroAbility[7] = true
		set Feral_Druid_H.isNonHeroAbility[8] = true

		set Feral_Druid_H.selectEmote = "Units\\Orc\\SpiritWalker\\WhiteTaurenWarcry1.flac"
		set Feral_Druid_H.unitId = 'E02I'
		set Feral_Druid_H.tooltip = "Master of cat and bear forms, able to tank and deal bleed damage. |n|n|cffffcc00Roles: Tank, Damage|r"
		set Feral_Druid_H.needsHeroGlow = false
		set Feral_Druid_H.category = 3
		set Feral_Druid_H.selectAnim = ANIM_TYPE_SPELL
		set Feral_Druid_H.selectSubAnim = SUBANIM_TYPE_SLAM
		set Feral_Druid_H.selectAnimLength = 1.167
		set Feral_Druid_H.unavailableToTeam[2] = true
		set Feral_Druid_H.startingZone = 4

		//================================================================================

		set Fire_Mage_A.abilities[1] = 'A00I'
		set Fire_Mage_A.abilities[2] = 'AEbl'
		set Fire_Mage_A.abilities[3] = 'A05D'
		set Fire_Mage_A.abilities[4] = 'AHfs'
		set Fire_Mage_A.abilities[5] = 'A01V'
		set Fire_Mage_A.abilities[6] = 'A05E'
		set Fire_Mage_A.abilities[7] = 'A0DJ'
		set Fire_Mage_A.abilities[8] = 'A08G'
		set Fire_Mage_A.isNonHeroAbility[6] = true
		set Fire_Mage_A.isNonHeroAbility[7] = true
		set Fire_Mage_A.isNonHeroAbility[8] = true

		set Fire_Mage_A.selectEmote = "Units\\Creeps\\LordGarithos\\GarithosYes5.flac"
		set Fire_Mage_A.unitId = 'H009'
		set Fire_Mage_A.tooltip = "Master of fire magic, excelling in destructive and area-of-effect spells. |n|n|cffffcc00Roles: Damage|r"
		set Fire_Mage_A.needsHeroGlow = false
		set Fire_Mage_A.category = 5
		set Fire_Mage_A.selectAnim = ANIM_TYPE_SPELL
		set Fire_Mage_A.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Fire_Mage_A.selectAnimLength = 1.667
		set Fire_Mage_A.unavailableToTeam[1] = true
		set Fire_Mage_A.startingZone = 1

		//================================================================================

		set Fire_Mage_H.abilities[1] = 'A00I'
		set Fire_Mage_H.abilities[2] = 'AEbl'
		set Fire_Mage_H.abilities[3] = 'A05D'
		set Fire_Mage_H.abilities[4] = 'AHfs'
		set Fire_Mage_H.abilities[5] = 'A01V'
		set Fire_Mage_H.abilities[6] = 'A05E'
		set Fire_Mage_H.abilities[7] = 'A0DJ'
		set Fire_Mage_H.abilities[8] = 'A08G'
		set Fire_Mage_H.isNonHeroAbility[6] = true
		set Fire_Mage_H.isNonHeroAbility[7] = true
		set Fire_Mage_H.isNonHeroAbility[8] = true

		set Fire_Mage_H.selectEmote = "Units\\Human\\HeroBloodElf\\BloodElfMageYesAttack1.flac"
		set Fire_Mage_H.unitId = 'H023'
		set Fire_Mage_H.tooltip = "Master of fire magic, excelling in destructive and area-of-effect spells. |n|n|cffffcc00Roles: Damage|r"
		set Fire_Mage_H.needsHeroGlow = false
		set Fire_Mage_H.category = 5
		set Fire_Mage_H.selectAnim = ANIM_TYPE_SPELL
		set Fire_Mage_H.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Fire_Mage_H.selectAnimLength = 2.000
		set Fire_Mage_H.unavailableToTeam[2] = true
		set Fire_Mage_H.startingZone = 4

		//================================================================================

		set Frost_DK_A.abilities[1] = 'A02V'
		set Frost_DK_A.abilities[2] = 'A037'
		set Frost_DK_A.abilities[3] = 'A03N'
		set Frost_DK_A.abilities[4] = 'A02J'
		set Frost_DK_A.abilities[5] = 'A0C5'
		set Frost_DK_A.abilities[6] = 'A073'
		set Frost_DK_A.abilities[7] = 'A0EP'
		set Frost_DK_A.abilities[8] = 'A0G3'
		set Frost_DK_A.isNonHeroAbility[6] = true
		set Frost_DK_A.isNonHeroAbility[7] = true
		set Frost_DK_A.isNonHeroAbility[8] = true

		set Frost_DK_A.selectEmote = "Units\\Orc\\Spiritwolf\\SpiritwolfWhat1.flac"
		set Frost_DK_A.unitId = 'U02Z'
		set Frost_DK_A.tooltip = "Master of frost magic, excelling in slowing and freezing enemies. |n|n|cffffcc00Roles: Damage, Off-Tank|r"
		set Frost_DK_A.needsHeroGlow = false
		set Frost_DK_A.category = 1
		set Frost_DK_A.selectAnim = ANIM_TYPE_SPELL
		set Frost_DK_A.selectSubAnim = SUBANIM_TYPE_SLAM
		set Frost_DK_A.selectAnimLength = 1.167
		set Frost_DK_A.unavailableToTeam[1] = true
		set Frost_DK_A.startingZone = 0

		//================================================================================

		set Frost_DK_H.abilities[1] = 'A02V'
		set Frost_DK_H.abilities[2] = 'A037'
		set Frost_DK_H.abilities[3] = 'A03N'
		set Frost_DK_H.abilities[4] = 'A02J'
		set Frost_DK_H.abilities[5] = 'A0C5'
		set Frost_DK_H.abilities[6] = 'A073'
		set Frost_DK_H.abilities[7] = 'A0EP'
		set Frost_DK_H.abilities[8] = 'A0G3'
		set Frost_DK_H.isNonHeroAbility[6] = true
		set Frost_DK_H.isNonHeroAbility[7] = true
		set Frost_DK_H.isNonHeroAbility[8] = true

		set Frost_DK_H.selectEmote = "Units\\Undead\\EvilArthas\\EvilArthasWarcry1.flac"
		set Frost_DK_H.unitId = 'U039'
		set Frost_DK_H.tooltip = "Master of frost magic, excelling in slowing and freezing enemies. |n|n|cffffcc00Roles: Damage, Off-Tank|r"
		set Frost_DK_H.needsHeroGlow = false
		set Frost_DK_H.category = 1
		set Frost_DK_H.selectAnim = ANIM_TYPE_SPELL
		set Frost_DK_H.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Frost_DK_H.selectAnimLength = 1.400
		set Frost_DK_H.unavailableToTeam[2] = true
		set Frost_DK_H.startingZone = 4

		//================================================================================

		set Frost_Mage_A.abilities[1] = 'A08I'
		set Frost_Mage_A.abilities[2] = 'A00H'
		set Frost_Mage_A.abilities[3] = 'A08J'
		set Frost_Mage_A.abilities[4] = 'A01Z'
		set Frost_Mage_A.abilities[5] = 'A01V'
		set Frost_Mage_A.abilities[6] = 'A024'
		set Frost_Mage_A.abilities[7] = 'A08G'
		set Frost_Mage_A.abilities[8] = 'A0D9'
		set Frost_Mage_A.isNonHeroAbility[6] = true
		set Frost_Mage_A.isNonHeroAbility[7] = true
		set Frost_Mage_A.isNonHeroAbility[8] = true

		set Frost_Mage_A.selectEmote = "Units\\Human\\Jaina\\JainaWarcry1.flac"
		set Frost_Mage_A.unitId = 'H00A'
		set Frost_Mage_A.tooltip = "Master of frost magic, excelling in freezing and controlling enemies. |n|n|cffffcc00Roles: Damage|r"
		set Frost_Mage_A.needsHeroGlow = false
		set Frost_Mage_A.category = 5
		set Frost_Mage_A.selectAnim = ANIM_TYPE_SPELL
		set Frost_Mage_A.selectSubAnim = null
		set Frost_Mage_A.selectAnimLength = 2.733
		set Frost_Mage_A.unavailableToTeam[1] = true
		set Frost_Mage_A.startingZone = 1

		//================================================================================

		set Frost_Mage_H.abilities[1] = 'A08I'
		set Frost_Mage_H.abilities[2] = 'A00H'
		set Frost_Mage_H.abilities[3] = 'A08J'
		set Frost_Mage_H.abilities[4] = 'A01Z'
		set Frost_Mage_H.abilities[5] = 'A01V'
		set Frost_Mage_H.abilities[6] = 'A024'
		set Frost_Mage_H.abilities[7] = 'A08G'
		set Frost_Mage_H.abilities[8] = 'A0D9'
		set Frost_Mage_H.isNonHeroAbility[6] = true
		set Frost_Mage_H.isNonHeroAbility[7] = true
		set Frost_Mage_H.isNonHeroAbility[8] = true

		set Frost_Mage_H.selectEmote = "Units\\Undead\\Banshee\\BansheeReady1.flac"
		set Frost_Mage_H.unitId = 'U001'
		set Frost_Mage_H.tooltip = "Master of frost magic, excelling in freezing and controlling enemies. |n|n|cffffcc00Roles: Damage|r"
		set Frost_Mage_H.needsHeroGlow = false
		set Frost_Mage_H.category = 5
		set Frost_Mage_H.selectAnim = ANIM_TYPE_SPELL
		set Frost_Mage_H.selectSubAnim = null
		set Frost_Mage_H.selectAnimLength = 1.500
		set Frost_Mage_H.unavailableToTeam[2] = true
		set Frost_Mage_H.startingZone = 3

		//================================================================================

		set Fury_Warr_A.abilities[1] = 'A05I'
		set Fury_Warr_A.abilities[2] = 'A05G'
		set Fury_Warr_A.abilities[3] = 'A05J'
		set Fury_Warr_A.abilities[4] = 'A05K'
		set Fury_Warr_A.abilities[5] = 'A05H'
		set Fury_Warr_A.abilities[6] = 'A02E'
		set Fury_Warr_A.abilities[7] = 'A07U'
		set Fury_Warr_A.abilities[8] = 'A0DL'
		set Fury_Warr_A.isNonHeroAbility[6] = true
		set Fury_Warr_A.isNonHeroAbility[7] = true
		set Fury_Warr_A.isNonHeroAbility[8] = true

		set Fury_Warr_A.selectEmote = "Units\\Human\\TheCaptain\\CaptainWarcry1.flac"
		set Fury_Warr_A.unitId = 'H03D'
		set Fury_Warr_A.tooltip = "Master of fury, excelling in relentless melee combat and berserker rage. |n|n|cffffcc00Roles: Damage, Off-Tank|r"
		set Fury_Warr_A.needsHeroGlow = false
		set Fury_Warr_A.category = 12
		set Fury_Warr_A.selectAnim = ANIM_TYPE_ATTACK
		set Fury_Warr_A.selectSubAnim = null
		set Fury_Warr_A.selectAnimLength = 1.331
		set Fury_Warr_A.unavailableToTeam[1] = true
		set Fury_Warr_A.startingZone = 1

		//================================================================================

		set Fury_Warr_H.abilities[1] = 'A05I'
		set Fury_Warr_H.abilities[2] = 'A05G'
		set Fury_Warr_H.abilities[3] = 'A05J'
		set Fury_Warr_H.abilities[4] = 'A05K'
		set Fury_Warr_H.abilities[5] = 'A05H'
		set Fury_Warr_H.abilities[6] = 'A02E'
		set Fury_Warr_H.abilities[7] = 'A07U'
		set Fury_Warr_H.abilities[8] = 'A0DL'
		set Fury_Warr_H.isNonHeroAbility[6] = true
		set Fury_Warr_H.isNonHeroAbility[7] = true
		set Fury_Warr_H.isNonHeroAbility[8] = true

		set Fury_Warr_H.selectEmote = "Units\\Orc\\Hellscream\\GromYesAttack2.flac"
		set Fury_Warr_H.unitId = 'H03E'
		set Fury_Warr_H.tooltip = "Master of fury, excelling in relentless melee combat and berserker rage. |n|n|cffffcc00Roles: Damage, Off-Tank|r"
		set Fury_Warr_H.needsHeroGlow = false
		set Fury_Warr_H.category = 12
		set Fury_Warr_H.selectAnim = ANIM_TYPE_SPELL
		set Fury_Warr_H.selectSubAnim = null
		set Fury_Warr_H.selectAnimLength = 1.333
		set Fury_Warr_H.unavailableToTeam[2] = true
		set Fury_Warr_H.startingZone = 4

		// ================================================================================

		set Holy_Pally_A.abilities[1] = 'A0AR'
		set Holy_Pally_A.abilities[2] = 'A00E'
		set Holy_Pally_A.abilities[3] = 'A04J'
		set Holy_Pally_A.abilities[4] = 'A01M'
		set Holy_Pally_A.abilities[5] = 'A00U'
		set Holy_Pally_A.abilities[6] = 'A01Q'
		set Holy_Pally_A.abilities[7] = 'A0AP'
		set Holy_Pally_A.abilities[8] = 'A0DK'
		set Holy_Pally_A.isNonHeroAbility[6] = true
		set Holy_Pally_A.isNonHeroAbility[7] = true
		set Holy_Pally_A.isNonHeroAbility[8] = true

		set Holy_Pally_A.selectEmote = "Units\\Human\\HeroPaladin\\HeroPaladinWarcry1.flac"
		set Holy_Pally_A.unitId = 'H00M'
		set Holy_Pally_A.tooltip = "Master of holy magic, excelling in healing and rallying allies. |n|n|cffffcc00Roles: Healer, Off-Tank|r"
		set Holy_Pally_A.needsHeroGlow = false
		set Holy_Pally_A.category = 7
		set Holy_Pally_A.selectAnim = ANIM_TYPE_SPELL
		set Holy_Pally_A.selectSubAnim = null
		set Holy_Pally_A.selectAnimLength = 2.167
		set Holy_Pally_A.unavailableToTeam[1] = true
		set Holy_Pally_A.startingZone = 1

		//================================================================================

		set Holy_Pally_H.abilities[1] = 'A0AR'
		set Holy_Pally_H.abilities[2] = 'A00E'
		set Holy_Pally_H.abilities[3] = 'A04J'
		set Holy_Pally_H.abilities[4] = 'A01M'
		set Holy_Pally_H.abilities[5] = 'A00U'
		set Holy_Pally_H.abilities[6] = 'A01Q'
		set Holy_Pally_H.abilities[7] = 'A0AP'
		set Holy_Pally_H.abilities[8] = 'A0DK'
		set Holy_Pally_H.isNonHeroAbility[6] = true
		set Holy_Pally_H.isNonHeroAbility[7] = true
		set Holy_Pally_H.isNonHeroAbility[8] = true

		set Holy_Pally_H.selectEmote = "Units\\Creeps\\SylvanusWindrunner\\SylvanasWarcry1.flac"
		set Holy_Pally_H.unitId = 'H031'
		set Holy_Pally_H.tooltip = "Master of holy magic, excelling in healing and rallying allies. |n|n|cffffcc00Roles: Healer, Off-Tank|r"
		set Holy_Pally_H.needsHeroGlow = false
		set Holy_Pally_H.category = 7
		set Holy_Pally_H.selectAnim = ANIM_TYPE_SPELL
		set Holy_Pally_H.selectSubAnim = null
		set Holy_Pally_H.selectAnimLength = 2.333
		set Holy_Pally_H.unavailableToTeam[2] = true
		set Holy_Pally_H.startingZone = 4

		//================================================================================

		set Holy_Priest_A.abilities[1] = 'A02T'
		set Holy_Priest_A.abilities[2] = 'A00K'
		set Holy_Priest_A.abilities[3] = 'A08W'
		set Holy_Priest_A.abilities[4] = 'A090'
		set Holy_Priest_A.abilities[5] = 'A0FU'
		set Holy_Priest_A.abilities[6] = 'A08Z'
		set Holy_Priest_A.abilities[7] = 'A0FW'
		set Holy_Priest_A.abilities[8] = 'A0FZ'
		set Holy_Priest_A.isNonHeroAbility[6] = true
		set Holy_Priest_A.isNonHeroAbility[7] = true
		set Holy_Priest_A.isNonHeroAbility[8] = true

		set Holy_Priest_A.selectEmote = "Units\\Human\\Jaina\\JainaYes4.flac"
		set Holy_Priest_A.unitId = 'H02U'
		set Holy_Priest_A.tooltip = "Master of holy magic, excelling in healing and protective spells. |n|n|cffffcc00Roles: Healer|r"
		set Holy_Priest_A.needsHeroGlow = false
		set Holy_Priest_A.category = 8
		set Holy_Priest_A.selectAnim = ANIM_TYPE_SPELL
		set Holy_Priest_A.selectSubAnim = null
		set Holy_Priest_A.selectAnimLength = 2.733
		set Holy_Priest_A.unavailableToTeam[1] = true
		set Holy_Priest_A.startingZone = 1

		//================================================================================

		set Holy_Priest_H.abilities[1] = 'A02T'
		set Holy_Priest_H.abilities[2] = 'A00K'
		set Holy_Priest_H.abilities[3] = 'A08W'
		set Holy_Priest_H.abilities[4] = 'A090'
		set Holy_Priest_H.abilities[5] = 'A0FU'
		set Holy_Priest_H.abilities[6] = 'A08Z'
		set Holy_Priest_H.abilities[7] = 'A0FW'
		set Holy_Priest_H.abilities[8] = 'A0FZ'
		set Holy_Priest_H.isNonHeroAbility[6] = true
		set Holy_Priest_H.isNonHeroAbility[7] = true
		set Holy_Priest_H.isNonHeroAbility[8] = true

		set Holy_Priest_H.selectEmote = "Units\\Human\\Sorceress\\SorceressYes4.flac"
		set Holy_Priest_H.unitId = 'H02W'
		set Holy_Priest_H.tooltip = "Master of holy magic, excelling in healing and protective spells. |n|n|cffffcc00Roles: Healer|r"
		set Holy_Priest_H.needsHeroGlow = false
		set Holy_Priest_H.category = 8
		set Holy_Priest_H.selectAnim = ANIM_TYPE_SPELL
		set Holy_Priest_H.selectSubAnim = null
		set Holy_Priest_H.selectAnimLength = 2.733
		set Holy_Priest_H.unavailableToTeam[2] = true
		set Holy_Priest_H.startingZone = 4

		// ================================================================================

		set Marksman_Hunter_A.abilities[1] = 'A0A3'
		set Marksman_Hunter_A.abilities[2] = 'A0A2'
		set Marksman_Hunter_A.abilities[3] = 'A05M'
		set Marksman_Hunter_A.abilities[4] = 'ANcs'
		set Marksman_Hunter_A.abilities[5] = 'A08Y'
		set Marksman_Hunter_A.abilities[6] = 'A0A4'
		set Marksman_Hunter_A.abilities[7] = 'A0ED'
		set Marksman_Hunter_A.abilities[8] = 'A0EI'
		set Marksman_Hunter_A.isNonHeroAbility[6] = true
		set Marksman_Hunter_A.isNonHeroAbility[7] = true
		set Marksman_Hunter_A.isNonHeroAbility[8] = true

		set Marksman_Hunter_A.selectEmote = "Units\\NightElf\\HeroMoonPriestess\\HeroMoonPriestessReady1.flac"
		set Marksman_Hunter_A.unitId = 'E03K'
		set Marksman_Hunter_A.tooltip = "Master of precision and speed, excelling in ranged combat and hitting multiple targets. |n|n|cffffcc00Roles: Damage|r"
		set Marksman_Hunter_A.needsHeroGlow = false
		set Marksman_Hunter_A.category = 4
		set Marksman_Hunter_A.selectAnim = ANIM_TYPE_SPELL
		set Marksman_Hunter_A.selectSubAnim = null
		set Marksman_Hunter_A.selectAnimLength = 1.333
		set Marksman_Hunter_A.unavailableToTeam[1] = true
		set Marksman_Hunter_A.startingZone = 0

		//================================================================================

		set Marksman_Hunter_H.abilities[1] = 'A0A3'
		set Marksman_Hunter_H.abilities[2] = 'A0A2'
		set Marksman_Hunter_H.abilities[3] = 'A05M'
		set Marksman_Hunter_H.abilities[4] = 'ANcs'
		set Marksman_Hunter_H.abilities[5] = 'A08Y'
		set Marksman_Hunter_H.abilities[6] = 'A0A4'
		set Marksman_Hunter_H.abilities[7] = 'A0ED'
		set Marksman_Hunter_H.abilities[8] = 'A0EI'
		set Marksman_Hunter_H.isNonHeroAbility[6] = true
		set Marksman_Hunter_H.isNonHeroAbility[7] = true
		set Marksman_Hunter_H.isNonHeroAbility[8] = true

		set Marksman_Hunter_H.selectEmote = "Units\\NightElf\\HeroMoonPriestess\\HeroMoonPriestessYesAttack1.flac"
		set Marksman_Hunter_H.unitId = 'E03Y'
		set Marksman_Hunter_H.tooltip = "Master of precision and speed, excelling in ranged combat and hitting multiple targets. |n|n|cffffcc00Roles: Damage|r"
		set Marksman_Hunter_H.needsHeroGlow = false
		set Marksman_Hunter_H.category = 4
		set Marksman_Hunter_H.selectAnim = ANIM_TYPE_SPELL
		set Marksman_Hunter_H.selectSubAnim = null
		set Marksman_Hunter_H.selectAnimLength = 1.333
		set Marksman_Hunter_H.unavailableToTeam[2] = true
		set Marksman_Hunter_H.startingZone = 4

		//================================================================================
		
		set Prot_Pally_A.abilities[1] = 'AHhb'
		set Prot_Pally_A.abilities[2] = 'A04R'
		set Prot_Pally_A.abilities[3] = 'A00M'
		set Prot_Pally_A.abilities[4] = 'A01M'
		set Prot_Pally_A.abilities[5] = 'A00U'
		set Prot_Pally_A.abilities[6] = 'A01Q'
		set Prot_Pally_A.abilities[7] = 'A0AP'
		set Prot_Pally_A.abilities[8] = 'A0DK'
		set Prot_Pally_A.isNonHeroAbility[6] = true
		set Prot_Pally_A.isNonHeroAbility[7] = true
		set Prot_Pally_A.isNonHeroAbility[8] = true

		set Prot_Pally_A.selectEmote = "Units\\NightElf\\Shandris\\ShandrisWarcry1.flac"
		set Prot_Pally_A.unitId = 'H033'
		set Prot_Pally_A.tooltip = "Master of protection, excelling in defensive and supportive abilities. |n|n|cffffcc00Roles: Tank, Off-Healer|r"
		set Prot_Pally_A.needsHeroGlow = true
		set Prot_Pally_A.category = 7
		set Prot_Pally_A.selectAnim = ANIM_TYPE_ATTACK
		set Prot_Pally_A.selectSubAnim = null
		set Prot_Pally_A.selectAnimLength = 0.933
		set Prot_Pally_A.unavailableToTeam[1] = true
		set Prot_Pally_A.startingZone = 1

		//================================================================================

		set Prot_Pally_H.abilities[1] = 'AHhb'
		set Prot_Pally_H.abilities[2] = 'A04R'
		set Prot_Pally_H.abilities[3] = 'A00M'
		set Prot_Pally_H.abilities[4] = 'A01M'
		set Prot_Pally_H.abilities[5] = 'A00U'
		set Prot_Pally_H.abilities[6] = 'A01Q'
		set Prot_Pally_H.abilities[7] = 'A0AP'
		set Prot_Pally_H.abilities[8] = 'A0DK'
		set Prot_Pally_H.isNonHeroAbility[6] = true
		set Prot_Pally_H.isNonHeroAbility[7] = true
		set Prot_Pally_H.isNonHeroAbility[8] = true

		set Prot_Pally_H.selectEmote = "Units\\Human\\BloodElfSpellThief\\SpellbreakerYesAttack1.flac"
		set Prot_Pally_H.unitId = 'H032'
		set Prot_Pally_H.tooltip = "Master of protection, excelling in defensive and supportive abilities. |n|n|cffffcc00Roles: Tank, Off-Healer|r"
		set Prot_Pally_H.needsHeroGlow = false
		set Prot_Pally_H.category = 7
		set Prot_Pally_H.selectAnim = ANIM_TYPE_ATTACK
		set Prot_Pally_H.selectSubAnim = SUBANIM_TYPE_SLAM
		set Prot_Pally_H.selectAnimLength = 1.000
		set Prot_Pally_H.unavailableToTeam[2] = true
		set Prot_Pally_H.startingZone = 4

		//================================================================================

		set Prot_Warr_A.abilities[1] = 'A018'
		set Prot_Warr_A.abilities[2] = 'AHtc'
		set Prot_Warr_A.abilities[3] = 'AHbh'
		set Prot_Warr_A.abilities[4] = 'AHav'
		set Prot_Warr_A.abilities[5] = 'A014'
		set Prot_Warr_A.abilities[6] = 'A02E'
		set Prot_Warr_A.abilities[7] = 'A07U'
		set Prot_Warr_A.abilities[8] = 'A0E0'
		set Prot_Warr_A.isNonHeroAbility[6] = true
		set Prot_Warr_A.isNonHeroAbility[7] = true
		set Prot_Warr_A.isNonHeroAbility[8] = true

		set Prot_Warr_A.selectEmote = "Units\\Human\\HeroMountainKing\\HeroMountainKingWarcry1.flac"
		set Prot_Warr_A.unitId = 'H010'
		set Prot_Warr_A.tooltip = "Master of protection, excelling in defensive tactics and absorbing damage. |n|n|cffffcc00Roles: Tank|r"
		set Prot_Warr_A.needsHeroGlow = false
		set Prot_Warr_A.category = 12
		set Prot_Warr_A.selectAnim = ANIM_TYPE_ATTACK
		set Prot_Warr_A.selectSubAnim = SUBANIM_TYPE_SLAM
		set Prot_Warr_A.selectAnimLength = 1.000
		set Prot_Warr_A.unavailableToTeam[1] = true
		set Prot_Warr_A.startingZone = 0

		//================================================================================

		set Prot_Warr_H.abilities[1] = 'A018'
		set Prot_Warr_H.abilities[2] = 'A034'
		set Prot_Warr_H.abilities[3] = 'A03D'
		set Prot_Warr_H.abilities[4] = 'ANav'
		set Prot_Warr_H.abilities[5] = 'A014'
		set Prot_Warr_H.abilities[6] = 'A02E'
		set Prot_Warr_H.abilities[7] = 'A07U'
		set Prot_Warr_H.abilities[8] = 'A0E0'
		set Prot_Warr_H.isNonHeroAbility[6] = true
		set Prot_Warr_H.isNonHeroAbility[7] = true
		set Prot_Warr_H.isNonHeroAbility[8] = true

		set Prot_Warr_H.selectEmote = "Units\\Orc\\HeroTaurenChieftain\\HeroTaurenChieftainWarcry1.flac"
		set Prot_Warr_H.unitId = 'H01T'
		set Prot_Warr_H.tooltip = "Master of protection, excelling in defensive tactics and absorbing damage. |n|n|cffffcc00Roles: Tank|r"
		set Prot_Warr_H.needsHeroGlow = false
		set Prot_Warr_H.category = 12
		set Prot_Warr_H.selectAnim = ANIM_TYPE_SPELL
		set Prot_Warr_H.selectSubAnim = SUBANIM_TYPE_SLAM
		set Prot_Warr_H.selectAnimLength = 1.167
		set Prot_Warr_H.unavailableToTeam[2] = true
		set Prot_Warr_H.startingZone = 4

		//================================================================================

		set Resto_Sham_A.abilities[1] = 'A09S'
		set Resto_Sham_A.abilities[2] = 'AOcl'
		set Resto_Sham_A.abilities[3] = 'A0AD'
		set Resto_Sham_A.abilities[4] = 'A0AE'
		set Resto_Sham_A.abilities[5] = 'A03C'
		set Resto_Sham_A.abilities[6] = 'A03A'
		set Resto_Sham_A.abilities[7] = 'A0DO'
		set Resto_Sham_A.abilities[8] = 'A0G4'
		set Resto_Sham_A.isNonHeroAbility[6] = true
		set Resto_Sham_A.isNonHeroAbility[7] = true
		set Resto_Sham_A.isNonHeroAbility[8] = true

		set Resto_Sham_A.selectEmote = "Units\\Human\\MortarTeam\\MortarTeamWhat1.flac"
		set Resto_Sham_A.unitId = 'O00G'
		set Resto_Sham_A.tooltip = "Master of restoration, excelling in healing, wards, and supportive magic. |n|n|cffffcc00Roles: Healer, Pet-Tanking|r"
		set Resto_Sham_A.needsHeroGlow = false
		set Resto_Sham_A.category = 10
		set Resto_Sham_A.selectAnim = ANIM_TYPE_STAND
		set Resto_Sham_A.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Resto_Sham_A.selectAnimLength = 1.333
		set Resto_Sham_A.unavailableToTeam[1] = true
		set Resto_Sham_A.startingZone = 0

		//================================================================================

		set Resto_Sham_H.abilities[1] = 'A09S'
		set Resto_Sham_H.abilities[2] = 'AOcl'
		set Resto_Sham_H.abilities[3] = 'A0AD'
		set Resto_Sham_H.abilities[4] = 'A0AE'
		set Resto_Sham_H.abilities[5] = 'A03C'
		set Resto_Sham_H.abilities[6] = 'A03A'
		set Resto_Sham_H.abilities[7] = 'A0DO'
		set Resto_Sham_H.abilities[8] = 'A0G4'
		set Resto_Sham_H.isNonHeroAbility[6] = true
		set Resto_Sham_H.isNonHeroAbility[7] = true
		set Resto_Sham_H.isNonHeroAbility[8] = true

		set Resto_Sham_H.selectEmote = "Units\\Orc\\HeroShadowHunter\\ShadowHunterWarcry1.flac"
		set Resto_Sham_H.unitId = 'O00N'
		set Resto_Sham_H.tooltip = "Master of restoration, excelling in healing, wards, and supportive magic. |n|n|cffffcc00Roles: Healer, Pet-Tanking|r"
		set Resto_Sham_H.needsHeroGlow = false
		set Resto_Sham_H.category = 10
		set Resto_Sham_H.selectAnim = ANIM_TYPE_STAND
		set Resto_Sham_H.selectSubAnim = SUBANIM_TYPE_VICTORY
		set Resto_Sham_H.selectAnimLength = 3.000
		set Resto_Sham_H.unavailableToTeam[2] = true
		set Resto_Sham_H.startingZone = 4

		//================================================================================

		set Ret_Pally_A.abilities[1] = 'A0AR'
		set Ret_Pally_A.abilities[2] = 'A0DA'
		set Ret_Pally_A.abilities[3] = 'A06D'
		set Ret_Pally_A.abilities[4] = 'A06F'
		set Ret_Pally_A.abilities[5] = 'A00U'
		set Ret_Pally_A.abilities[6] = 'A01Q'
		set Ret_Pally_A.abilities[7] = 'A0AP'
		set Ret_Pally_A.abilities[8] = 'A0EN'
		set Ret_Pally_A.isNonHeroAbility[6] = true
		set Ret_Pally_A.isNonHeroAbility[7] = true
		set Ret_Pally_A.isNonHeroAbility[8] = true

		set Ret_Pally_A.selectEmote = "Units\\Human\\HeroMountainKing\\HeroMountainKingReady1.flac"
		set Ret_Pally_A.unitId = 'H00K'
		set Ret_Pally_A.tooltip = "Master of retribution, excelling in melee combat and holy damage. |n|n|cffffcc00Roles: Damage|r"
		set Ret_Pally_A.needsHeroGlow = false
		set Ret_Pally_A.category = 7
		set Ret_Pally_A.selectAnim = ANIM_TYPE_STAND
		set Ret_Pally_A.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Ret_Pally_A.selectAnimLength = 1.667
		set Ret_Pally_A.unavailableToTeam[1] = true
		set Ret_Pally_A.startingZone = 0

		//================================================================================

		set Ret_Pally_H.abilities[1] = 'A0AR'
		set Ret_Pally_H.abilities[2] = 'A0DA'
		set Ret_Pally_H.abilities[3] = 'A06D'
		set Ret_Pally_H.abilities[4] = 'A06F'
		set Ret_Pally_H.abilities[5] = 'A00U'
		set Ret_Pally_H.abilities[6] = 'A01Q'
		set Ret_Pally_H.abilities[7] = 'A0AP'
		set Ret_Pally_H.abilities[8] = 'A0EN'
		set Ret_Pally_H.isNonHeroAbility[6] = true
		set Ret_Pally_H.isNonHeroAbility[7] = true
		set Ret_Pally_H.isNonHeroAbility[8] = true

		set Ret_Pally_H.selectEmote = "Units\\Human\\BloodElfSpellThief\\SpellbreakerWarcry1.flac"
		set Ret_Pally_H.unitId = 'H00R'
		set Ret_Pally_H.tooltip = "Master of retribution, excelling in melee combat and holy damage. |n|n|cffffcc00Roles: Damage|r"
		set Ret_Pally_H.needsHeroGlow = false
		set Ret_Pally_H.category = 7
		set Ret_Pally_H.selectAnim = ANIM_TYPE_SPELL
		set Ret_Pally_H.selectSubAnim = null
		set Ret_Pally_H.selectAnimLength = 1.534
		set Ret_Pally_H.unavailableToTeam[2] = true
		set Ret_Pally_H.startingZone = 4

		//================================================================================

		set Shadow_Priest_A.abilities[1] = 'A05F'
		set Shadow_Priest_A.abilities[2] = 'A0GS'
		set Shadow_Priest_A.abilities[3] = 'A003'
		set Shadow_Priest_A.abilities[4] = 'A0E9'
		set Shadow_Priest_A.abilities[5] = 'A007'
		set Shadow_Priest_A.abilities[6] = 'A0FA'
		set Shadow_Priest_A.abilities[7] = 'A02M'
		set Shadow_Priest_A.abilities[8] = 'A0FS'
		set Shadow_Priest_A.isNonHeroAbility[6] = true
		set Shadow_Priest_A.isNonHeroAbility[7] = true
		set Shadow_Priest_A.isNonHeroAbility[8] = true

		set Shadow_Priest_A.selectEmote = "Units\\Human\\Muradin\\MuradinYesAttack1.flac"
		set Shadow_Priest_A.unitId = 'H00T'
		set Shadow_Priest_A.tooltip = "Master of shadow magic, excelling in damage over time and mind control. |n|n|cffffcc00Roles: Damage|r"
		set Shadow_Priest_A.needsHeroGlow = true
		set Shadow_Priest_A.category = 8
		set Shadow_Priest_A.selectAnim = ANIM_TYPE_STAND
		set Shadow_Priest_A.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Shadow_Priest_A.selectAnimLength = 1.333
		set Shadow_Priest_A.unavailableToTeam[1] = true
		set Shadow_Priest_A.startingZone = 0

		//================================================================================

		set Shadow_Priest_H.abilities[1] = 'A05F'
		set Shadow_Priest_H.abilities[2] = 'A0GS'
		set Shadow_Priest_H.abilities[3] = 'A003'
		set Shadow_Priest_H.abilities[4] = 'A0E9'
		set Shadow_Priest_H.abilities[5] = 'A007'
		set Shadow_Priest_H.abilities[6] = 'A0FA'
		set Shadow_Priest_H.abilities[7] = 'A02M'
		set Shadow_Priest_H.abilities[8] = 'A0FS'
		set Shadow_Priest_H.isNonHeroAbility[6] = true
		set Shadow_Priest_H.isNonHeroAbility[7] = true
		set Shadow_Priest_H.isNonHeroAbility[8] = true

		set Shadow_Priest_H.selectEmote = "Units\\Undead\\KelThuzadNecro\\KelThuzadWarcry1.flac"
		set Shadow_Priest_H.unitId = 'H00Q'
		set Shadow_Priest_H.tooltip = "Master of shadow magic, excelling in damage over time and mind control. |n|n|cffffcc00Roles: Damage|r"
		set Shadow_Priest_H.needsHeroGlow = false
		set Shadow_Priest_H.category = 8
		set Shadow_Priest_H.selectAnim = ANIM_TYPE_STAND
		set Shadow_Priest_H.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Shadow_Priest_H.selectAnimLength = 1.667
		set Shadow_Priest_H.unavailableToTeam[2] = true
		set Shadow_Priest_H.startingZone = 3

		//================================================================================
		
		set Subtle_Rogue_A.abilities[1] = 'A00V'
		set Subtle_Rogue_A.abilities[2] = 'AEfk'
		set Subtle_Rogue_A.abilities[3] = 'A00W'
		set Subtle_Rogue_A.abilities[4] = 'A017'
		set Subtle_Rogue_A.abilities[5] = 'A010'
		set Subtle_Rogue_A.abilities[6] = 'A06M'
		set Subtle_Rogue_A.abilities[7] = 'A0EW'
		set Subtle_Rogue_A.abilities[8] = 'A0EX'
		set Subtle_Rogue_A.isNonHeroAbility[6] = true
		set Subtle_Rogue_A.isNonHeroAbility[7] = true
		set Subtle_Rogue_A.isNonHeroAbility[8] = true

		set Subtle_Rogue_A.selectEmote = "Units\\NightElf\\Maiev\\MaievWarcry1.flac"
		set Subtle_Rogue_A.unitId = 'E00E'
		set Subtle_Rogue_A.tooltip = "Master of stealth and evasion. |n|n|cffffcc00Roles: Damage|r"
		set Subtle_Rogue_A.needsHeroGlow = false
		set Subtle_Rogue_A.category = 9
		set Subtle_Rogue_A.selectAnim = ANIM_TYPE_SPELL
		set Subtle_Rogue_A.selectSubAnim = SUBANIM_TYPE_SLAM
		set Subtle_Rogue_A.selectAnimLength = 1.200
		set Subtle_Rogue_A.unavailableToTeam[1] = true
		set Subtle_Rogue_A.startingZone = 0

		//================================================================================

		set Subtle_Rogue_H.abilities[1] = 'A00V'
		set Subtle_Rogue_H.abilities[2] = 'AEfk'
		set Subtle_Rogue_H.abilities[3] = 'A00W'
		set Subtle_Rogue_H.abilities[4] = 'A017'
		set Subtle_Rogue_H.abilities[5] = 'A010'
		set Subtle_Rogue_H.abilities[6] = 'A06M'
		set Subtle_Rogue_H.abilities[7] = 'A0EW'
		set Subtle_Rogue_H.abilities[8] = 'A0EX'
		set Subtle_Rogue_H.isNonHeroAbility[6] = true
		set Subtle_Rogue_H.isNonHeroAbility[7] = true
		set Subtle_Rogue_H.isNonHeroAbility[8] = true

		set Subtle_Rogue_H.selectEmote = "Units\\NightElf\\Archer\\ArcherReady1.flac"
		set Subtle_Rogue_H.unitId = 'E007'
		set Subtle_Rogue_H.tooltip = "Master of stealth and evasion. |n|n|cffffcc00Roles: Damage|r"
		set Subtle_Rogue_H.needsHeroGlow = false
		set Subtle_Rogue_H.category = 9
		set Subtle_Rogue_H.selectAnim = ANIM_TYPE_SPELL
		set Subtle_Rogue_H.selectSubAnim = SUBANIM_TYPE_THROW
		set Subtle_Rogue_H.selectAnimLength = 0.9000
		set Subtle_Rogue_H.unavailableToTeam[2] = true
		set Subtle_Rogue_H.startingZone = 4

		//================================================================================
		
		set Unholy_DK_A.abilities[1] = 'A0DG'
		set Unholy_DK_A.abilities[2] = 'A001'
		set Unholy_DK_A.abilities[3] = 'AUau'
		set Unholy_DK_A.abilities[4] = 'A03J'
		set Unholy_DK_A.abilities[5] = 'AUan'
		set Unholy_DK_A.abilities[6] = 'A03L'
		set Unholy_DK_A.abilities[7] = 'A0FB'
		set Unholy_DK_A.abilities[8] = 'A03Y'
		set Unholy_DK_A.isNonHeroAbility[6] = true
		set Unholy_DK_A.isNonHeroAbility[7] = true
		set Unholy_DK_A.isNonHeroAbility[8] = true

		set Unholy_DK_A.selectEmote = "Units\\Undead\\HeroDeathKnight\\DeathKnightWarcry1.flac"
		set Unholy_DK_A.unitId = 'U03A'
		set Unholy_DK_A.tooltip = "Master of unholy magic, excelling in summoning undead and spreading diseases. |n|n|cffffcc00Roles: Damage, Off-Tank|r"
		set Unholy_DK_A.needsHeroGlow = false
		set Unholy_DK_A.category = 1
		set Unholy_DK_A.selectAnim = ANIM_TYPE_SPELL
		set Unholy_DK_A.selectSubAnim = SUBANIM_TYPE_CHANNEL
		set Unholy_DK_A.selectAnimLength = 1.625
		set Unholy_DK_A.unavailableToTeam[1] = true
		set Unholy_DK_A.startingZone = 1

		//================================================================================

		set Unholy_DK_H.abilities[1] = 'A0DG'
		set Unholy_DK_H.abilities[2] = 'A001'
		set Unholy_DK_H.abilities[3] = 'AUau'
		set Unholy_DK_H.abilities[4] = 'A03J'
		set Unholy_DK_H.abilities[5] = 'AUan'
		set Unholy_DK_H.abilities[6] = 'A03L'
		set Unholy_DK_H.abilities[7] = 'A0FB'
		set Unholy_DK_H.abilities[8] = 'A03Y'
		set Unholy_DK_H.isNonHeroAbility[6] = true
		set Unholy_DK_H.isNonHeroAbility[7] = true
		set Unholy_DK_H.isNonHeroAbility[8] = true

		set Unholy_DK_H.selectEmote = "Units\\Undead\\HeroFemaleDeathKnight\\HeroFemaleDeathKnightWarcry1.flac"
		set Unholy_DK_H.unitId = 'U036'
		set Unholy_DK_H.tooltip = "Master of unholy magic, excelling in summoning undead and spreading diseases. |n|n|cffffcc00Roles: Damage, Off-Tank|r"
		set Unholy_DK_H.needsHeroGlow = false
		set Unholy_DK_H.category = 1
		set Unholy_DK_H.selectAnim = ANIM_TYPE_SPELL
		set Unholy_DK_H.selectSubAnim = null
		set Unholy_DK_H.selectAnimLength = 1.500
		set Unholy_DK_H.unavailableToTeam[2] = true
		set Unholy_DK_H.startingZone = 3

		//================================================================================

		set Havoc_DH_A.abilities[1] = 'A08L'
		set Havoc_DH_A.abilities[2] = 'A08H'
		set Havoc_DH_A.abilities[3] = 'AEev'
		set Havoc_DH_A.abilities[4] = 'A01Y'
		set Havoc_DH_A.abilities[5] = 'A04L'
		set Havoc_DH_A.abilities[6] = 'A08K'
		set Havoc_DH_A.abilities[7] = 'A0G2'
		set Havoc_DH_A.abilities[8] = 'A0G0'
		set Havoc_DH_A.isNonHeroAbility[6] = true
		set Havoc_DH_A.isNonHeroAbility[7] = true
		set Havoc_DH_A.isNonHeroAbility[8] = true

		set Havoc_DH_A.selectEmote = "Units\\NightElf\\HeroDemonHunter\\HeroDemonHunterWarcry1.flac"
		set Havoc_DH_A.unitId = 'E02C'
		set Havoc_DH_A.tooltip = "Master of havoc, excelling in agility and evasion. |n|n|cffffcc00Roles: Damage, Off-Tank|r"
		set Havoc_DH_A.needsHeroGlow = false
		set Havoc_DH_A.category = 2
		set Havoc_DH_A.selectAnim = ANIM_TYPE_ATTACK
		set Havoc_DH_A.selectSubAnim = null
		set Havoc_DH_A.selectAnimLength = 0.900
		set Havoc_DH_A.unavailableToTeam[1] = true
		set Havoc_DH_A.startingZone = 0

		//================================================================================

		set Havoc_DH_H.abilities[1] = 'A08L'
		set Havoc_DH_H.abilities[2] = 'A08H'
		set Havoc_DH_H.abilities[3] = 'AEev'
		set Havoc_DH_H.abilities[4] = 'A01Y'
		set Havoc_DH_H.abilities[5] = 'A04L'
		set Havoc_DH_H.abilities[6] = 'A08K'
		set Havoc_DH_H.abilities[7] = 'A0G2'
		set Havoc_DH_H.abilities[8] = 'A0G0'
		set Havoc_DH_H.isNonHeroAbility[6] = true
		set Havoc_DH_H.isNonHeroAbility[7] = true
		set Havoc_DH_H.isNonHeroAbility[8] = true

		set Havoc_DH_H.selectEmote = "Units\\Human\\Kael\\KaelYesAttack1.flac"
		set Havoc_DH_H.unitId = 'E02E'
		set Havoc_DH_H.tooltip = "Master of havoc, excelling in agility and evasion. |n|n|cffffcc00Roles: Damage, Off-Tank|r"
		set Havoc_DH_H.needsHeroGlow = false
		set Havoc_DH_H.category = 2
		set Havoc_DH_H.selectAnim = ANIM_TYPE_ATTACK
		set Havoc_DH_H.selectSubAnim = null
		set Havoc_DH_H.selectAnimLength = 0.900
		set Havoc_DH_H.unavailableToTeam[2] = true
		set Havoc_DH_H.startingZone = 4

		//================================================================================

		// set Veng_DH_A.abilities[1] = 'A08M'
		// set Veng_DH_A.abilities[2] = 'A08N'
		// set Veng_DH_A.abilities[3] = 'AEev'
		// set Veng_DH_A.abilities[4] = 'A01Y'
		// set Veng_DH_A.abilities[5] = 'A04L'
		// set Veng_DH_A.abilities[6] = 'A08O'
		// set Veng_DH_A.abilities[7] = 'A0G5'
		// set Veng_DH_A.abilities[8] = 'A0G6'
		// set Veng_DH_A.isNonHeroAbility[6] = true
		// set Veng_DH_A.isNonHeroAbility[7] = true
		// set Veng_DH_A.isNonHeroAbility[8] = true

		// set Veng_DH_A.selectEmote = "Units\\NightElf\\HeroDemonHunter\\HeroDemonHunterWarcry1.flac"
		// set Veng_DH_A.unitId = 'E02C'
		// set Veng_DH_A.tooltip = "Master of vengeance, excelling in tanking and absorbing damage. |n|n|cffffcc00Roles: Tank, Off-Damage|r"
		// set Veng_DH_A.needsHeroGlow = false
		// set Veng_DH_A.category = 2
		// set Veng_DH_A.selectAnim = ANIM_TYPE_ATTACK
		// set Veng_DH_A.selectSubAnim = SUBANIM_TYPE_SLAM
		// set Veng_DH_A.selectAnimLength = 1.200
		// set Veng_DH_A.unavailableToTeam[1] = true

		// //================================================================================

		// set Veng_DH_H.abilities[1] = 'A08M'
		// set Veng_DH_H.abilities[2] = 'A08N'
		// set Veng_DH_H.abilities[3] = 'AEev'
		// set Veng_DH_H.abilities[4] = 'A01Y'
		// set Veng_DH_H.abilities[5] = 'A04L'
		// set Veng_DH_H.abilities[6] = 'A08O'
		// set Veng_DH_H.abilities[7] = 'A0G5'
		// set Veng_DH_H.abilities[8] = 'A0G6'
		// set Veng_DH_H.isNonHeroAbility[6] = true
		// set Veng_DH_H.isNonHeroAbility[7] = true
		// set Veng_DH_H.isNonHeroAbility[8] = true

		// set Veng_DH_H.selectEmote = "Units\\Human\\Kael\\KaelYesAttack2.flac"
		// set Veng_DH_H.unitId = 'E02E'
		// set Veng_DH_H.tooltip = "Master of vengeance, excelling in tanking and absorbing damage. |n|n|cffffcc00Roles: Tank, Off-Damage|r"
		// set Veng_DH_H.needsHeroGlow = false
		// set Veng_DH_H.category = 2
		// set Veng_DH_H.selectAnim = ANIM_TYPE_ATTACK
		// set Veng_DH_H.selectSubAnim = SUBANIM_TYPE_SLAM
		// set Veng_DH_H.selectAnimLength = 1.200
		// set Veng_DH_H.unavailableToTeam[2] = true

	endfunction

endlibrary