//call ArmorDebuff( GetEnumUnit() )
//call ArmorDebuff( udg_Temp_Unit )

function ArmorDebug takes unit targetX, string tick returns nothing
    	if (udg_Debug) then
    		call DisplayTextToForce( GetPlayersAll(), tick )
		    call DisplayTextToForce( GetPlayersAll(), I2S(R2I(udg_U_ArmorStatCalc)) )
		    call DisplayTextToForce( GetPlayersAll(), BlzGetUnitStringField(targetX , UNIT_SF_NAME) )
            call DisplayTextToForce( GetPlayersAll(), BlzGetUnitStringField(udg_Temp_Unit , UNIT_SF_NAME) )
    	endif
endfunction


function CapArmorStatCalc takes real lower returns nothing
    if ( udg_U_ArmorStatCalc < lower  ) then
        set udg_U_ArmorStatCalc = lower
    endif
    if ( udg_U_ArmorStatCalc > 50.00  ) then
        set udg_U_ArmorStatCalc = 50.00
    endif
endfunction

function ArmorDebuff takes unit targetX returns nothing
    if (udg_Debug) then
    	call DisplayTextToForce( GetPlayersAll(), "Armor Debuff Triggered" )
        call DisplayTextToForce( GetPlayersAll(), BlzGetUnitStringField(targetX , UNIT_SF_NAME) )
        call DisplayTextToForce( GetPlayersAll(), BlzGetUnitStringField(udg_Temp_Unit , UNIT_SF_NAME) )
    endif
    if ( UnitHasBuffBJ(targetX, 'B012') == true ) then
       	call UnitRemoveBuffBJ( 'B012', targetX )
	    call UnitRemoveBuffBJ( 'B00Z', targetX )
        set udg_U_ArmorStatCalc = BlzGetUnitRealField(targetX, UNIT_RF_DEFENSE)
        set udg_U_ArmorStatCalc = ( udg_AD * 4 * udg_U_ArmorStatCalc )
        call CapArmorStatCalc(2.0)

        call SetUnitAbilityLevelSwapped( 'A0A1', gg_unit_e03J_2004, R2I(udg_U_ArmorStatCalc) )
        call IssueTargetOrderBJ( gg_unit_e03J_2004, "acidbomb", targetX )
        call ArmorDebug( targetX,"AD 4")
    elseif ( UnitHasBuffBJ(targetX, 'B011') == true ) then
		call UnitRemoveBuffBJ( 'B011', targetX )
		call UnitRemoveBuffBJ( 'B00Z', targetX )
		set udg_U_ArmorStatCalc = BlzGetUnitRealField(targetX, UNIT_RF_DEFENSE)
		set udg_U_ArmorStatCalc = ( udg_AD * 4 * udg_U_ArmorStatCalc )
	    call CapArmorStatCalc(2.0)

		call SetUnitAbilityLevelSwapped( 'A0A1', gg_unit_e03J_2004, R2I(udg_U_ArmorStatCalc) )
		call IssueTargetOrderBJ( gg_unit_e03J_2004, "acidbomb", targetX )
        call ArmorDebug( targetX,"AD 3")
	elseif ( UnitHasBuffBJ(targetX, 'B010') == true ) then
		call UnitRemoveBuffBJ( 'B010', targetX )
		call UnitRemoveBuffBJ( 'B00Z', targetX )
		set udg_U_ArmorStatCalc = BlzGetUnitRealField(targetX, UNIT_RF_DEFENSE)
		set udg_U_ArmorStatCalc = ( udg_AD * 3 * udg_U_ArmorStatCalc )
        call CapArmorStatCalc(2.0)

		call SetUnitAbilityLevelSwapped( 'A0A0', gg_unit_e03I_2003, R2I(udg_U_ArmorStatCalc) )
		call IssueTargetOrderBJ( gg_unit_e03I_2003, "acidbomb", targetX )	
        call ArmorDebug( targetX,"AD 2")	
    elseif ( UnitHasBuffBJ(targetX, 'B00Z') == true ) then
		call UnitRemoveBuffBJ( 'B00Z', targetX )
		set udg_U_ArmorStatCalc = BlzGetUnitRealField(targetX, UNIT_RF_DEFENSE)
		set udg_U_ArmorStatCalc = ( udg_AD * 2 * udg_U_ArmorStatCalc )
        call CapArmorStatCalc(1.0)

		call SetUnitAbilityLevelSwapped( 'A09Z', gg_unit_e03H_2002, R2I(udg_U_ArmorStatCalc) )
		call IssueTargetOrderBJ( gg_unit_e03H_2002, "acidbomb", targetX )      
        call ArmorDebug( targetX,"AD 1")
    else
        set udg_U_ArmorStatCalc = BlzGetUnitRealField(targetX, UNIT_RF_DEFENSE)
        set udg_U_ArmorStatCalc = ( udg_AD * udg_U_ArmorStatCalc )
        call CapArmorStatCalc(1.0)

        call SetUnitAbilityLevelSwapped( 'A09Y', gg_unit_e03G_2001, R2I(udg_U_ArmorStatCalc) )	
        call IssueTargetOrderBJ( gg_unit_e03G_2001, "acidbomb", targetX )
        call ArmorDebug( targetX,"AD 0")
    endif
endfunction
