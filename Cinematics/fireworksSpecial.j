function FireworksSpecial takes nothing returns nothing
	local location center
	local location firework
	local integer i = 1
	local integer color
	local real size 
    
	set center = GetRectCenter(gg_rct_Party_Favors)

	loop 
		exitwhen i > 6

		set firework = PolarProjectionBJ(center, GetRandomReal(20, 240.0), GetRandomReal(0, 360.0))
		set size = GetRandomReal(0.35, 0.5)
	
		if GetRandomInt(1, 2) == 1 then
			call StopSoundBJ( gg_snd_FX_Firework_Whistle_01, false )
			call PlaySoundAtPointBJ( gg_snd_FX_Firework_Whistle_01, 81, firework, 0 )
		else
			call StopSoundBJ( gg_snd_FX_Firework_Whistle_02, false )
			call PlaySoundAtPointBJ( gg_snd_FX_Firework_Whistle_02, 81, firework, 0 )
		endif
		
		call AddSpecialEffectLocBJ( firework, "Abilities\\Spells\\Human\\Flare\\FlareCaster.mdl" )
		call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), size)
		call DestroyEffectBJ( GetLastCreatedEffectBJ() )

		call TriggerSleepAction(GetRandomReal(1.0, 1.3))
		if GetRandomInt(1, 2) == 1 then
			call StopSoundBJ( gg_snd_G_FireworkBoomGeneral5, false )
			call PlaySoundAtPointBJ( gg_snd_G_FireworkBoomGeneral5, 100, firework, 80 )
		else
			call StopSoundBJ( gg_snd_G_FireworkBoomGeneral6, false )
			call PlaySoundAtPointBJ( gg_snd_G_FireworkBoomGeneral6, 100, firework, 80 )
		endif

		set color = GetRandomInt(1, 4)
		if color == 1 then
			call AddSpecialEffectLocBJ( firework, "war3mapImported\\Fireworksred.mdx" )
		elseif color == 2 then
			call AddSpecialEffectLocBJ( firework, "war3mapImported\\Fireworksgreen.mdx" )
		elseif color == 3 then
			call AddSpecialEffectLocBJ( firework, "war3mapImported\\Fireworksblue.mdx" )
		else
			call AddSpecialEffectLocBJ( firework, "war3mapImported\\Fireworkspurple.mdx" )
		endif
		call RemoveLocation (firework)
		
		set size = size * 2
		call BlzSetSpecialEffectZ(GetLastCreatedEffectBJ(), BlzGetLocalSpecialEffectZ(GetLastCreatedEffectBJ()) + (size * 720) + GetRandomInt(17, 76))
		call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), (size * 1.26)) //GetRandomReal(0.9, 1.2)
		call BlzSetSpecialEffectYaw( GetLastCreatedEffectBJ(), Deg2Rad(GetRandomReal(0, 360.0)) )
		call DestroyEffectBJ( GetLastCreatedEffectBJ() )

		call TriggerSleepAction(GetRandomReal(1.1, 1.4))
		set i = i + 1
		
	endloop

	call RemoveLocation (center)

	set firework = null
	set center = null
endfunction