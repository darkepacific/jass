function PowerWordBarrierEffect takes nothing returns nothing
    local integer abilvl
    local real AOE

    if ModuloInteger(udg_SpellTicks[udg_Temp_Int], 4) == 0 then
	if ModuloInteger(udg_SpellTicks[udg_Temp_Int], 8) == 0 then
        	call PlaySoundAtPointBJ( gg_snd_SpiritTouch, 100, udg_Temp_Unit_Point, 250.00 )
        endif
        set abilvl = ( GetUnitAbilityLevelSwapped('A0FT', udg_Temp_Unit) * 1 )
        
        set AOE = ( ( 0.05 * I2R(abilvl) ) + 0.80 )
        call AddSpecialEffectLocBJ( udg_Temp_Unit_Point, "war3mapImported\\TheHolyBomb.mdx" )
        call BlzSetSpecialEffectAlpha( GetLastCreatedEffectBJ(), 125 )
        call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), AOE )
        call DestroyEffectBJ( GetLastCreatedEffectBJ() )

        set AOE = ( ( 0.10 * I2R(abilvl) ) + 1.70 )
        call AddSpecialEffectLocBJ( udg_Temp_Unit_Point, "Abilities\\Spells\\Undead\\ReplenishHealth\\ReplenishHealthCasterOverhead.mdl" )
        call BlzSetSpecialEffectZ( GetLastCreatedEffectBJ(), ( 150.00 + BlzGetLocalSpecialEffectZ(GetLastCreatedEffectBJ()) ) )
	call BlzSetSpecialEffectAlpha( GetLastCreatedEffectBJ(), 135 )
        call BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), AOE )
        call DestroyEffectBJ( GetLastCreatedEffectBJ() )
    endif

endfunction

function ApplyPowerWordBarrier takes unit caster, unit target returns nothing
	if not ( UnitHasBuffBJ(target, 'B033') ) then
		call Atonement ( caster, target)
 		call SetUnitAbilityLevel( gg_unit_e03G_2001, 'A0BF', 42 )
 		call IssueTargetOrder( gg_unit_e03G_2001, "innerfire", target )
	endif
endfunction

