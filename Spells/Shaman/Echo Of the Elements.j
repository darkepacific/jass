	function EchoOfTheElements takes nothing returns nothing
		set udg_Temp_Bool = false

		call Debug( BlzGetUnitStringField(udg_Temp_Unit , UNIT_SF_NAME) )

		if udg_TalentChoices[ GetPlayerId(GetOwningPlayer(udg_Temp_Unit)) * udg_NUM_OF_TC + 14 ]  then
			if ( GetRandomInt(1, 100) > 80) then
				set udg_Temp_Bool = true
				if udg_Temp_Unit == udg_yA_Ele_Sham then
					call AddSpecialEffectTargetUnitBJ( "overhead", udg_Temp_Unit, "war3mapImported\\RainbowMissile.mdx")
				else
					call AddSpecialEffectTargetUnitBJ( "chest", udg_Temp_Unit, "war3mapImported\\RainbowMissile.mdx")
				endif
				call DestroyEffectBJ( GetLastCreatedEffectBJ() )
				call CreateTextTagUnitBJ( "Echo of the Elements!", udg_Temp_Unit, 10.00, 9.00, 100, 90.00, 0.00, 0 )
				call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 0.00 )
				call cleanUpText( 1.2, 0.8)
				call ShowTextTagForceBJ( true, GetLastCreatedTextTag(), GetPlayersAll() )
			endif
		endif
	endfunction