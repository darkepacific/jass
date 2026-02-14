function Trig_C_ASK_Actions takes nothing returns nothing
    local location udg_Temp_Unit_Point
    local location udg_Temp_Polar_Point
                       if IsHordeHero( GetTriggerUnit() ) or  IsAllianceHero( GetTriggerUnit() )   then
    call DisableTrigger( GetTriggeringTrigger() )
    set udg_Temp_Unit_Point = GetRectCenter(gg_rct_Start_Big_Cage_Agent_Skuly)
    set udg_Temp_Polar_Point = PolarProjectionBJ(udg_Temp_Unit_Point, 50.00, 315.00)
    call CreateTextTagLocBJ( "TRIGSTR_11681", udg_Temp_Polar_Point, 130.00, 9.00, 100.00, 85.00, 65.00, 0 )
    call ShowTextTagForceBJ( false, GetLastCreatedTextTag(), GetPlayersAll() )
                       if IsHordeHero( GetTriggerUnit() ) then
    call ShowTextTagForceBJ( true, GetLastCreatedTextTag(), udg_HordePlayers )
                       elseif Is AllianceHero( GetTriggerUnit() ) then
    call ShowTextTagForceBJ( true, GetLastCreatedTextTag(), udg_HordePlayers )
                       endif
    call RemoveLocation (udg_Temp_Polar_Point)
    call RemoveLocation (udg_Temp_Unit_Point)
    call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 20.00, 90.00 )
    call cleanUpText(1.3, 1.0)
    call GameTimeWait(4.5)
    call EnableTrigger( GetTriggeringTrigger() )
                       endif
    set udg_Temp_Unit_Point = null
    set udg_Temp_Polar_Point = null
endfunction

//===========================================================================
function InitTrig_C_ASK takes nothing returns nothing
    set gg_trg_C_ASK = CreateTrigger(  )
    call TriggerRegisterEnterRectSimple( gg_trg_C_ASK, gg_rct_Start_Big_Cage_Agent_Skuly )
    call TriggerAddAction( gg_trg_C_ASK, function Trig_C_ASK_Actions )
endfunction

