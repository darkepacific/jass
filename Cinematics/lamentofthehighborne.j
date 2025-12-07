function animateBanshees takes effect b1, effect b2, effect b3, effect b4, integer seq returns nothing
    if seq == 1 then
        if GetRandomReal(0.0,10.0) > 5.0 then
            call BlzPlaySpecialEffect( b1, ANIM_TYPE_SPELL )
            call BlzPlaySpecialEffect( b2, ANIM_TYPE_STAND )
            call BlzPlaySpecialEffect( b3, ANIM_TYPE_STAND )
            call BlzPlaySpecialEffect( b4, ANIM_TYPE_SPELL )
        else
            call BlzPlaySpecialEffect( b1, ANIM_TYPE_STAND )
            call BlzPlaySpecialEffect( b2, ANIM_TYPE_SPELL )
            call BlzPlaySpecialEffect( b3, ANIM_TYPE_SPELL )
            call BlzPlaySpecialEffect( b4, ANIM_TYPE_STAND )
        endif
    elseif seq == 2 then
        if GetRandomReal(0.0,10.0) > 5.0 then
            call BlzPlaySpecialEffect( b1, ANIM_TYPE_STAND )
            call BlzPlaySpecialEffect( b2, ANIM_TYPE_SPELL )
            call BlzPlaySpecialEffect( b3, ANIM_TYPE_STAND )
            call BlzPlaySpecialEffect( b4, ANIM_TYPE_SPELL )
        else
            call BlzPlaySpecialEffect( b1, ANIM_TYPE_SPELL )
            call BlzPlaySpecialEffect( b2, ANIM_TYPE_STAND )
            call BlzPlaySpecialEffect( b3, ANIM_TYPE_SPELL )
            call BlzPlaySpecialEffect( b4, ANIM_TYPE_STAND )
        endif
    endif
	call BlzSetSpecialEffectAlpha( b1, GetRandomInt(125,155) )
	call BlzSetSpecialEffectAlpha( b2, GetRandomInt(125,155) )
	call BlzSetSpecialEffectAlpha( b3, GetRandomInt(125,155) )
	call BlzSetSpecialEffectAlpha( b4, GetRandomInt(125,155) )
endfunction


//Lament_of_the_Highborne
function Lament_of_the_Highborne takes nothing returns nothing
	local effect b1
	local effect b2
	local effect b3
	local effect b4
	local effect m1
	local location sylvanas
	local location banshee
	local integer offset = 280
	local integer i = 1
    
	set sylvanas = GetRectCenter(gg_rct_Kill_Anduin)

	set banshee = PolarProjectionBJ(sylvanas, offset, 38)
	call AddSpecialEffectLocBJ( banshee, "units\\creeps\\BansheeGhost\\BansheeGhost.mdl" )
	call RemoveLocation (banshee)
	set b1 = GetLastCreatedEffectBJ()
	call BlzSetSpecialEffectAlpha( GetLastCreatedEffectBJ(), 145 )
	call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.9)
	call BlzSetSpecialEffectYaw( GetLastCreatedEffectBJ(), Deg2Rad(( 35.00 + 180.00 )) )

	set banshee = PolarProjectionBJ(sylvanas, offset, 72)
	call AddSpecialEffectLocBJ( banshee, "units\\creeps\\BansheeGhost\\BansheeGhost.mdl" )
	call RemoveLocation (banshee)
	set b2 = GetLastCreatedEffectBJ()
	call BlzSetSpecialEffectAlpha( GetLastCreatedEffectBJ(), 145 )
	call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.9)
	call BlzSetSpecialEffectYaw( GetLastCreatedEffectBJ(), Deg2Rad(( 75.00 + 180.00 )) )

	set banshee = PolarProjectionBJ(sylvanas, offset, 107)
	call AddSpecialEffectLocBJ( banshee, "units\\creeps\\BansheeGhost\\BansheeGhost.mdl" )
	call RemoveLocation (banshee)
	set b3 = GetLastCreatedEffectBJ()
	call BlzSetSpecialEffectAlpha( GetLastCreatedEffectBJ(), 145 )
	call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.9)
	call BlzSetSpecialEffectYaw( GetLastCreatedEffectBJ(), Deg2Rad(( 115.00 + 180.00 )) )

	set banshee = PolarProjectionBJ(sylvanas, offset, 142)
	call AddSpecialEffectLocBJ( banshee, "units\\creeps\\BansheeGhost\\BansheeGhost.mdl" )
	call RemoveLocation (banshee)
	set b4 = GetLastCreatedEffectBJ()
	call BlzSetSpecialEffectAlpha( GetLastCreatedEffectBJ(), 145 )
	call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.9)
	call BlzSetSpecialEffectYaw( GetLastCreatedEffectBJ(), Deg2Rad(( 155.00 + 180.00 )) )


	call AddSpecialEffectLocBJ( sylvanas, "war3mapImported\\MusicTarget.mdx" )
	set m1 = GetLastCreatedEffectBJ()
    call BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 1.2)
	call BlzSetSpecialEffectAlpha( GetLastCreatedEffectBJ(), 185 )

	call RemoveLocation (sylvanas)

    loop 
		exitwhen i > 24

		call TriggerSleepAction(2.0)
		call animateBanshees(b1,b2,b3,b4,GetRandomInt(1,2))
		set i = i + 1
		
	endloop

	call DestroyEffectBJ( b1 )
	call DestroyEffectBJ( b2 )
	call DestroyEffectBJ( b3 )
	call DestroyEffectBJ( b4 )
	call DestroyEffectBJ( m1 )

	set b1 = null
	set b2 = null
	set b3 = null
	set b4 = null
	set m1 = null
	set sylvanas = null
	set banshee = null
endfunction