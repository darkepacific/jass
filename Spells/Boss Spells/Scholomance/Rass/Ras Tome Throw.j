function Trig_Ras_Tome_Throw_Conditions takes nothing returns boolean
    return GetUnitTypeId(GetTriggerUnit()) == 'U02F'
endfunction

function Trig_Ras_Tome_Throw_Actions takes nothing returns nothing
    if RectContainsUnit(gg_rct_Scholomance_Music, GetEventDamageSource()) then
        call DisableTrigger(GetTriggeringTrigger())

        call RTO_ThrowAtUnit(gg_unit_U02F_1167, GetEventDamageSource())

        call GameTimeWait(6.0)

        if IsUnitAlive(gg_unit_U02F_1167) then
            call RTO_Start(GetUnitX(gg_unit_U02F_1167), GetUnitY(gg_unit_U02F_1167))
        endif

        call GameTimeWait(2.0)
        call EnableTrigger(GetTriggeringTrigger())
    endif
endfunction

//===========================================================================
function InitTrig_Ras_Tome_Throw takes nothing returns nothing
    set gg_trg_Ras_Tome_Throw = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(gg_trg_Ras_Tome_Throw, EVENT_PLAYER_UNIT_DAMAGED)
    call TriggerAddCondition(gg_trg_Ras_Tome_Throw, Condition(function Trig_Ras_Tome_Throw_Conditions))
    call TriggerAddAction(gg_trg_Ras_Tome_Throw, function Trig_Ras_Tome_Throw_Actions)
endfunction