function DummyRootSet takes player p, location point, real facing, integer lvl returns nothing
	call SetUnitOwner( gg_unit_e00H_2048, p, false )
    call SetUnitPositionLocFacingBJ(  gg_unit_e00H_2048, point, facing )
	call SetUnitAbilityLevel( gg_unit_e00H_2048, 'A03S', lvl )
endfunction

call DummyRootSet(  GetOwningPlayer(udg_Temp_Unit), udg_Point_Charge_Begin[udg_Temp_Int], udg_Facing_Angle, 1)


if IsUnitDead()



	call KillDestructable(udg_Graves[p])
	call ShowDestructable(udg_Graves[p], false)

	