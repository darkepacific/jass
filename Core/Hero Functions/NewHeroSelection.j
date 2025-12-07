function Trig_A_Resto_Sham_Actions takes nothing returns nothing
    if udg_yA_Resto_Sham == null then
        set bj_wantDestroyGroup = true
        call ForGroupBJ( GetUnitsInRectAll(gg_rct_A_Resto_Sham), function FindOnlyHeroInRegion )
        set udg_yA_Resto_Sham = udg_Temp_Unit
        call TriggerRegisterUnitEvent( gg_trg_Resto_Sham_Max, udg_Temp_Unit, EVENT_UNIT_HERO_LEVEL)
        call TriggerRegisterUnitEvent( gg_trg_Resto_Sham_Death, udg_Temp_Unit, EVENT_UNIT_DEATH)
    endif
    call DwarfStartingPoint(GetOwningPlayer(GetTriggerUnit()), udg_yA_Resto_Sham)
endfunction

//===========================================================================
function InitTrig_A_Resto_Sham takes nothing returns nothing
    set gg_trg_A_Resto_Sham = CreateTrigger(  )
    call TriggerRegisterEnterRectSimple( gg_trg_A_Resto_Sham, gg_rct_A_Resto_Sham )
    call TriggerAddCondition( gg_trg_A_Resto_Sham, Condition( function IsAllianceSoul ) )
    call TriggerAddAction( gg_trg_A_Resto_Sham, function Trig_A_Resto_Sham_Actions )
endfunction
